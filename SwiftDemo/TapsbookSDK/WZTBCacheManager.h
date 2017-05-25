//
//  WZTBCacheManager.h
//  Swip
//
//  Created by Xinrong Guo on 8/14/15.
//  Copyright (c) 2015 Ziqi Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDImageCache.h>
#import "TBPSSizeUtil.h"

typedef NS_ENUM(NSInteger, WZTBCacheType) {
    WZTBCacheType_Local_NormalSize = 100,
    WZTBCacheType_Local_FullSize,
    WZTBCacheType_Remote_NormalSize,
    WZTBCacheType_Remote_FullSize,
};

@interface WZTBCacheManager : NSObject

@property (readonly, nonatomic) NSString *cacheDir;

+ (instancetype)sharedInstance;

- (void)storeImage:(UIImage *)image forKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote;
- (void)storeImage:(UIImage *)image forKey:(NSString *)key size:(TBPSImageSize)size withCacheType:(WZTBCacheType)cacheType;

- (void)removeImageForKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote withCompletion:(SDWebImageNoParamsBlock)completion;
- (void)removeImageForKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType withCompletion:(SDWebImageNoParamsBlock)completion;

- (NSString *)defaultCachePathForKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote;
- (NSString *)defaultCachePathForKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType;

- (BOOL)diskImageExistsWithKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote;
- (BOOL)diskImageExistsWithKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType;

- (UIImage *)imageFromDiskCacheForKey:(NSString *)key size:(TBPSImageSize)size isRemote:(BOOL)isRemote;
- (UIImage *)imageFromDiskCacheForKey:(NSString *)key size:(TBPSImageSize)size cacheType:(WZTBCacheType)cacheType;


// Helper
- (WZTBCacheType)cacheTypeFromSize:(TBPSImageSize)size isRemote:(BOOL)isRemote;

- (void)cleanImageCacheWithCacheType:(WZTBCacheType)cacheType;

// Clean
- (void)cleenAllCache;
- (unsigned long long)totalCacheSizeInBytes;

/**
 缓存图片的disk地址
 @return path
 */
+ (NSString *)imageCacheDirectory;

@end
