//
//  LMTBSDKHelper.h
//  lingmall
//
//  Created by Cary on 2017/2/7.
//  Copyright © 2017年 lingmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TapsbookSDK/TapsbookSDK.h>

@interface LMTBSDKHelper : NSObject

+ (instancetype)sharedInstance;

- (NSMutableArray <TBImage *>*)convertAssetsToTBImages:(NSArray *) assets;

- (void)downloadTBImages:(NSArray *)tbImages
           withImageSize:(TBImageSize)imageSize
           progressBlock:(void (^)(NSInteger currentIdx, NSInteger totalCount, float ratio))progressBlock
         completionBlock:(void (^)(NSInteger currentIdx, NSInteger totalCount, NSError *error))completionBlock;

@end
