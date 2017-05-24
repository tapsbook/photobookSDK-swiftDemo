//
//  TBFacebookManager.h
//  TapsbookSDK
//
//  Created by Xinrong Guo on 12/4/15.
//  Copyright © 2015 tapsbook. All rights reserved.
//

#import <TapsbookSDK/TapsbookSDK.h>
#import "TBSocialManager.h"

@interface TBFacebookManager : TBSocialManager

/**
 ios9以上请使用该方法
 */
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options ;

@end
