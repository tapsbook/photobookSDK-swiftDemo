//
//  TBUserTrackerManager.h
//  TapsbookSDK
//
//  Created by Cary on 2017/4/27.
//  Copyright © 2017年 tapsbook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBUserTrackerManager : NSObject

+ (instancetype)sharedInstance;


/**
 使用umeng需要在应用中初始化umeng  sdk不会做初始化

 @param usingType 使用事件收集策略
 */
+ (void)setupTBUserTrackerUsingType:(TBUserTrackerUsingType)usingType;

@end
