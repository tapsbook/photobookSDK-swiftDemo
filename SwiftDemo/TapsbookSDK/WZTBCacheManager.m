//
//  WZTBCacheManager.m
//  Swip
//
//  Created by Xinrong Guo on 8/14/15.
//  Copyright (c) 2015 Ziqi Wu. All rights reserved.
//

#import "WZTBCacheManager.h"
#import "NSFileManager+TBDirSize.h"

static NSString * kWZTBSDImageCacheNameSpace = @"com.dingmall.tbsdimagecache";

@interface WZTBCacheManager ()

@property (strong, nonatomic) NSString *cacheDir;
@property (strong, nonatomic) NSMutableDictionary *imageCacheDict;

@end

@implementation WZTBCacheManager

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cacheDir = [paths[0] stringByAppendingPathComponent:@"com.dingmall.images"];
        
        _imageCacheDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (SDImageCache *)imageCacheWithCacheType:(WZTBCacheType)cacheType {
    SDImageCache *imageCache = self.imageCacheDict[@(cacheType)];
    
    if (imageCache == nil) {
        imageCache = [self createImageCacheWithCacheType:cacheType];
        
        self.imageCacheDict[@(cacheType)] = imageCache;
    }
    
    return imageCache;
}

- (SDImageCache *)createImageCacheWithCacheType:(WZTBCacheType)cacheType {
    NSInteger maxCacheAge = 60 * 60 * 24 * 7; // Seconds, 1 week
    NSInteger maxCacheSize = 0; // Byte
    
    switch (cacheType) {
        case WZTBCacheType_Local_NormalSize:
            
            break;
        case WZTBCacheType_Local_FullSize:
            maxCacheAge = 60 * 60 * 24; // 1 day
            maxCacheSize = 1024 * 1024 * 900; //800MB
            break;
        case WZTBCacheType_Remote_NormalSize:
            
            break;
        case WZTBCacheType_Remote_FullSize:
            
            break;
    }
    
    NSString *nameSpace = [self nameSpaceFromCacheType:cacheType];
    SDImageCache *imageCache = [[SDImageCache alloc] initWithNamespace:nameSpace diskCacheDirectory:self.cacheDir];
    imageCache.maxCacheAge = maxCacheAge;
    imageCache.maxCacheSize = maxCacheSize;
    return imageCache;
}

#pragma mark -

- (void)storeImage:(UIImage *)image forKey:(NSString *)key size:(TBPSImageSize)size withCacheType:(WZTBCacheType)cacheType {
    [self storeImage:image forKey:key size:size toDisk:YES withCacheType:cacheType];
}

- (void)storeImage:(UIImage *)image forKey:(NSString *)key size:(TBPSImageSize)size toDisk:(BOOL)toDisk withCacheType:(WZTBCacheType)cacheType {
    SDImageCache *cache = [self imageCacheWithCacheType:cacheType];
    NSString *newKey = [self newKeyWithKey:key size:size];
    
    [cache storeImage:image forKey:newKey toDisk:toDisk];
}

- (void)removeImageForKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType withCompletion:(SDWebImageNoParamsBlock)completion {
    [self removeImageForKey:key size:size fromDisk:YES cacheType:cacheType withCompletion:completion];
}

- (void)removeImageForKey:(NSString *)key size:(TBPSImageSize)size fromDisk:(BOOL)fromDisk cacheType:(WZTBCacheType)cacheType withCompletion:(SDWebImageNoParamsBlock)completion {
    SDImageCache *cache = [self imageCacheWithCacheType:cacheType];
    NSString *newKey = [self newKeyWithKey:key size:size];
    
    [cache removeImageForKey:newKey fromDisk:fromDisk withCompletion:completion];
}

- (NSString *)defaultCachePathForKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType {
    SDImageCache *cache = [self imageCacheWithCacheType:cacheType];
    NSString *newKey = [self newKeyWithKey:key size:size];
    
    NSString *path = [cache defaultCachePathForKey:newKey];
    
    return path;
}

- (BOOL)diskImageExistsWithKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType {
    SDImageCache *cache = [self imageCacheWithCacheType:cacheType];
    NSString *newKey = [self newKeyWithKey:key size:size];
    
    BOOL result = [cache diskImageExistsWithKey:newKey];
    
    return result;
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType {
    SDImageCache *cache = [self imageCacheWithCacheType:cacheType];
    NSString *newKey = [self newKeyWithKey:key size:size];
    
    UIImage *result = [cache imageFromDiskCacheForKey:newKey];
    
    return result;
}

#pragma mark - Quick

- (void)storeImage:(UIImage *)image forKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote {
    WZTBCacheType cacheType = [self cacheTypeFromSize:size isRemote:isRemote];
    
    [self storeImage:image forKey:key size:size withCacheType:cacheType];
}

- (void)removeImageForKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote withCompletion:(SDWebImageNoParamsBlock)completion {
    WZTBCacheType cacheType = [self cacheTypeFromSize:size isRemote:isRemote];
    
    [self removeImageForKey:key size:size cacheType:cacheType withCompletion:completion];
}

- (NSString *)defaultCachePathForKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote {
    WZTBCacheType cacheType = [self cacheTypeFromSize:size isRemote:isRemote];
    
    return [self defaultCachePathForKey:key size:size cacheType:cacheType];
}

- (BOOL)diskImageExistsWithKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote {
    WZTBCacheType cacheType = [self cacheTypeFromSize:size isRemote:isRemote];
    
    return [self diskImageExistsWithKey:key size:size cacheType:cacheType];
}

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote {
    WZTBCacheType cacheType = [self cacheTypeFromSize:size isRemote:isRemote];
    
    return [self imageFromDiskCacheForKey:key size:size cacheType:cacheType];
}

#pragma mark - Helper

- (WZTBCacheType)cacheTypeFromSize:(TBPSImageSize)size isRemote:(BOOL)isRemote {
    WZTBCacheType cacheTypes[2][2] = {{WZTBCacheType_Local_NormalSize, WZTBCacheType_Local_FullSize}, {WZTBCacheType_Remote_NormalSize, WZTBCacheType_Remote_FullSize}};
    
    WZTBCacheType type = cacheTypes[isRemote ? 1 : 0][size == TBPSImageSize_xxl ? 1 : 0];
    
    return type;
}

- (NSString *)newKeyWithKey:(NSString *)key size:(TBPSImageSize)size {
    NSString *result = [NSString stringWithFormat:@"%@%@", [TBPSSizeUtil prefixStringOfSize:size], key];
    return result;
}

- (NSString *)nameSpaceFromCacheType:(WZTBCacheType)cacheType {
    NSString *result;
    
    switch (cacheType) {
        case WZTBCacheType_Local_NormalSize:
            result = @"WZTBCacheType_Local_NormalSize";
            break;
        case WZTBCacheType_Local_FullSize:
            result = @"WZTBCacheType_Local_FullSize";
            break;
        case WZTBCacheType_Remote_NormalSize:
            result = @"WZTBCacheType_Remote_NormalSize";
            break;
        case WZTBCacheType_Remote_FullSize:
            result = @"WZTBCacheType_Remote_FullSize";
            break;
            
    }
    
    return result;
}

#pragma mark - Clean SD Cache

- (void)cleanImageCacheWithCacheType:(WZTBCacheType)cacheType {
    SDImageCache *cache = [self imageCacheWithCacheType:cacheType];
    //notice the difference between clearDisk and cleanDisk
    //clearDisk removes everything under the folder
    //cleanDisk removes only the files that over maxSize or old than maxAge
    [cache cleanDisk];
}

#pragma mark - Clean

- (void)cleenAllCache {
    [[NSFileManager defaultManager] removeItemAtPath:self.cacheDir error:NULL];
    
    [self cleanRelease126LegacyCache];
}

//this is a bug caused by https://github.com/tapsbook/cleen-iOS/issues/423
- (void)cleanRelease126LegacyCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *rootCacheDir = paths[0];
    
    NSString *extension = @"png";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:rootCacheDir error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([[filename pathExtension] isEqualToString:extension]) {
            
            [fileManager removeItemAtPath:[rootCacheDir stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}

- (unsigned long long)totalCacheSizeInBytes {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *rootCacheDir = paths[0];
    NSURL *rootCacheDirURL = [NSURL fileURLWithPath:rootCacheDir];
    
    unsigned long long rootSize = 0;
    NSError *rootError;
    BOOL rootSuccess = [[NSFileManager defaultManager]
                        tb_getAllocatedSize:&rootSize
                        option:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                        filter:@".png"
                        ofDirectoryAtURL:rootCacheDirURL error:&rootError];
    if (!rootSuccess) {
        NSLog(@"error: %@", rootError.localizedDescription);
    }
    
    NSURL *cacheDirURL = [NSURL fileURLWithPath:self.cacheDir];
    
    unsigned long long size = 0;
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] tb_getAllocatedSize:&size ofDirectoryAtURL:cacheDirURL error:&error];
    
    if (!success) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    
    return size+rootSize;
}

+ (NSString *)imageCacheDirectory
{
    return [WZTBCacheManager sharedInstance].cacheDir;
}


@end
