//
//  LMTBSDKHelper.m
//  lingmall
//
//  Created by Cary on 2017/2/7.
//  Copyright © 2017年 lingmall. All rights reserved.
//

#import "LMTBSDKHelper.h"
#import "UIImage+Save.h"
#import "FICUtilities.h"
#import <Photos/Photos.h>
#import "TBPSSizeUtil.h"
#import "WZTBCacheManager.h"

@interface LMTBSDKHelper ()

@property (strong, nonatomic) dispatch_queue_t diskIOQueue;

@end

@implementation LMTBSDKHelper

+ (instancetype)sharedInstance{
    static LMTBSDKHelper * helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!helper) {
            helper = [[LMTBSDKHelper alloc] init];
        }
    });
    return helper;
}

- (instancetype)init {
    if (self = [super init]) {
        _diskIOQueue = dispatch_queue_create("LMTBSDKHelper diskIOQueue", NULL);
    }
    return self;
}


- (NSMutableArray <TBImage *>*)convertAssetsToTBImages:(NSArray *) assets {
    NSMutableArray * tbImages = [NSMutableArray arrayWithCapacity:assets.count];
    
    //convert assets to tbImage
    for (id asset in assets){
        
        NSString *name = [[[asset localIdentifier] componentsSeparatedByString:@"/"] firstObject];
        TBImage *tbImage = [[TBImage alloc] initWithIdentifier:name];
        
        NSString *sPath = [[WZTBCacheManager sharedInstance] defaultCachePathForKey:name size:TBPSImageSize_s cacheType:WZTBCacheType_Local_NormalSize];
        NSString *lPath = [[WZTBCacheManager sharedInstance] defaultCachePathForKey:name size:TBPSImageSize_l cacheType:WZTBCacheType_Local_NormalSize];
        
        [tbImage setImagePath:sPath size:TBImageSize_s];
        [tbImage setImagePath:lPath size:TBImageSize_l];
        
        [tbImages addObject:tbImage];
    }
    
    return tbImages;
}

- (NSString *) imageCachePathForAsset:(NSString*) name size:(TBImageSize) size {
    NSString *cachePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"ImageCache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:cachePath isDirectory:NULL]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%zd", name, size]];
    return filePath;
}


- (void)downloadTBImages:(NSArray *)tbImages withImageSize:(TBImageSize)imageSize progressBlock:(void (^)(NSInteger, NSInteger, float))progressBlock completionBlock:(void (^)(NSInteger, NSInteger, NSError *))completionBlock {
    
    [self preloadImageWithEnumerator:[tbImages objectEnumerator] imageSize:imageSize currentIdx:0 successCount:0 total:tbImages.count continueIfError:YES previousError:nil progressBlock:progressBlock completionBlock:completionBlock];
}

- (void)preloadImageWithEnumerator:(NSEnumerator *)enumerator imageSize:(TBImageSize)imageSize currentIdx:(NSInteger)currentIdx successCount:(NSInteger)successCount total:(NSInteger)total continueIfError:(BOOL)continueIfError previousError:(NSError *)previousError progressBlock:(void (^)(NSInteger, NSInteger, float))progressBlock completionBlock:(void (^)(NSInteger, NSInteger, NSError *))completionBlock {
    
    TBImage * tbImage = [enumerator nextObject];
    
    if (tbImage) {
        dispatch_queue_t diskIOQueue = self.diskIOQueue;
        
        PHAsset * asset;
        NSString * identifier = tbImage.identifier;
        NSString * name = identifier;
        
        //get asset
        if ([tbImage.identifier hasPrefix:@"assets-library://"]) {
            name = [[self photoIDFromAssetURLStr:identifier] stringByAppendingFormat:@"/L0/001/"];
            NSURL *assetsURL = [NSURL URLWithString:tbImage.identifier];
            PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[assetsURL] options:nil];
            asset = result.firstObject;
        }
        else {
            PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil];
            asset = result.firstObject;
        }
        
        if (!asset) {
            //error : asset not found
            NSError * error = [NSError errorWithDomain:@"com.dingmall" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"asset not found"}];
            [tbImage failedGettingImageWithSize:imageSize errorDescription:[error localizedDescription]];
            
            if (continueIfError) {
                //when error go on
                [self preloadImageWithEnumerator:enumerator imageSize:imageSize currentIdx:currentIdx+1 successCount:successCount total:total continueIfError:continueIfError previousError:error progressBlock:progressBlock completionBlock:completionBlock];
            } else {
                completionBlock(currentIdx,total,error);
            }
        } else {
            //set xxl size
            //判断打印的照片是否清晰
            tbImage.xxlSizeInPixel = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            
            //size
            CGSize boundingSize = [TBPSSizeUtil sizeFromPSImageSize:(TBPSImageSize)imageSize];
            CGSize convertedSize = boundingSize;
            if (asset.pixelHeight * asset.pixelWidth > 0) {
                CGSize photoSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
                convertedSize = [TBPSSizeUtil convertSize:photoSize toSize:boundingSize contentMode:UIViewContentModeScaleAspectFill];
            } else {
                NSAssert(NO, @"asset should have size");
            }
            
            //path
            CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(identifier);
            NSString * uuid = FICStringWithUUIDBytes(UUIDBytes);
            
            //check
            NSString * path = [[WZTBCacheManager sharedInstance] defaultCachePathForKey:uuid size:(TBPSImageSize)imageSize isRemote:NO];
            BOOL exists = [[WZTBCacheManager sharedInstance] diskImageExistsWithKey:uuid size:(TBPSImageSize)imageSize isRemote:NO];
            
            if (!exists) {
                path = [[WZTBCacheManager sharedInstance] defaultCachePathForKey:uuid size:(TBPSImageSize)imageSize isRemote:YES];
                exists = [[WZTBCacheManager sharedInstance] diskImageExistsWithKey:uuid size:(TBPSImageSize)imageSize isRemote:YES];
            }
            
            if (exists && path) {
                //exists? refresh callback
                [tbImage setImagePath:path size:imageSize];
                
                if (progressBlock) {
                    progressBlock(currentIdx,total,1);
                }
                
                [self preloadImageWithEnumerator:enumerator imageSize:imageSize currentIdx:currentIdx+1 successCount:successCount+1 total:total continueIfError:continueIfError previousError:previousError progressBlock:progressBlock completionBlock:completionBlock];
            }
            else {
                //request image
                
                void (^successResultHandlerBlock)(UIImage *result, NSDictionary *info, BOOL isRemote) = ^(UIImage *result, NSDictionary *info, BOOL isRemote){
                    //request success
                    WZTBCacheType cacheType = [[WZTBCacheManager sharedInstance] cacheTypeFromSize:(TBPSImageSize)imageSize isRemote:isRemote];
                    
                    NSString *path = [[WZTBCacheManager sharedInstance] defaultCachePathForKey:uuid size:(TBPSImageSize)imageSize cacheType:cacheType];
                    
                    dispatch_async(diskIOQueue, ^{
                        BOOL imageWrittenToDisk = [result writeToFile:path withCompressQuality:1];
                        if (imageWrittenToDisk) {
                            NSLog(@"written to disk success");
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [tbImage setImagePath:path size:imageSize];
                            
                            if (progressBlock) {
                                progressBlock(currentIdx, total, 1);
                            }
                            
                            [self preloadImageWithEnumerator:enumerator imageSize:imageSize currentIdx:currentIdx+1 successCount:successCount+1 total:total continueIfError:continueIfError previousError:previousError progressBlock:progressBlock completionBlock:completionBlock];
                        });
                    });
                    
                };
                void (^failedResultHandlerBlock)(UIImage *result, NSDictionary *info, BOOL isRemote) = ^(UIImage *result, NSDictionary *info, BOOL isRemote) {
                    //request failure
                    NSError *error = info[PHImageErrorKey];
                    if (!error) {
                        error = [NSError errorWithDomain:@"com.dingmall" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"asset not imported",}];
                    }
                    completionBlock(currentIdx, total, error);
                };

                
                PHImageRequestOptions * requestOptions = [[PHImageRequestOptions alloc] init];
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                requestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
                requestOptions.networkAccessAllowed = NO;
                requestOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
                    if (progressBlock) {
                        progressBlock(currentIdx, total, progress);
                    }
                };
                @autoreleasepool {
                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:convertedSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        if (result) {
                            successResultHandlerBlock(result, info, NO);
                        }
                        else {
                            requestOptions.networkAccessAllowed = YES;
                            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:convertedSize contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                                if (result) {
                                    successResultHandlerBlock(result, info, YES);
                                }
                                else {
                                    failedResultHandlerBlock(result, info, YES);
                                }
                            }];
                        }
                    }];
                }
                
                //base options is not support
//                @autoreleasepool {
//                    [[TZImageManager manager] getPhotoWithAsset:asset photoWidth:convertedSize.width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//                        if (photo) {
//                            successResultHandlerBlock(photo, info, isDegraded);
//                        } else {
//                            failedResultHandlerBlock(photo, info, isDegraded);
//                        }
//                    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
//                        if (progressBlock) {
//                            progressBlock(currentIdx, total, progress);
//                        }
//                    } networkAccessAllowed:NO];
//                }
            }
        }
        
    }else {
        completionBlock(successCount,total,previousError);
    }
}

#pragma mark - Helper

- (NSString *)photoIDFromAssetURLStr:(NSString *)assetURLStr {
    /*
     The API doesn't provide any method to get a unique identifier from an ALAsset object
     But the [[ALAsset defaultRepresentation] url] method, according to Apple's documentation,
     returns a "persistent URL uniquely identifying the representation."
     
     This URL looks like : assets-library://asset/asset.JPG?id=BFFEB67F-0212-4CB3-844A-D14C0A3FA69F&ext=JPG
     I assume that the string "BFFEB67F-0212-4CB3-844A-D14C0A3FA69F" is unique.
     Let's retrieve it and use it as photoId
     */
    NSString * assetsURLString = assetURLStr;
    
    // let's retrieve the id in two times.
    // First, let's truncate the string to something similar to : BFFEB67F-0212-4CB3-844A-D14C0A3FA69F&ext=JPG
    NSString * firstDelimiter = @"id=";
    NSRange rangeOfFirstDelimiter = [assetsURLString rangeOfString:firstDelimiter];
    if ( rangeOfFirstDelimiter.location == NSNotFound ) {
        // if, for some reason, the delimiter was not found, let's return an empty string
        return @"";
    }
    NSUInteger indexOfFirstCharacterOfId = rangeOfFirstDelimiter.location + rangeOfFirstDelimiter.length;
    assetsURLString = [assetsURLString substringFromIndex:indexOfFirstCharacterOfId];
    
    // Now, let's get the substring until the "&ext=???" part
    NSString * secondDelimiter = @"&ext";
    NSRange rangeOfSecondDelimiter = [assetsURLString rangeOfString:secondDelimiter];
    NSUInteger indexOfSecondDelimiter = rangeOfSecondDelimiter.location;
    if ( indexOfSecondDelimiter == NSNotFound ){
        // if, for some reason, the delimiter was not found, let's return an empty string
        return @"";
    }
    
    NSString * photoId = [assetsURLString substringToIndex:indexOfSecondDelimiter];
    
    return photoId;
}


@end
