//
//  Wow-Bridgr-Header.h
//  Wow
//
//  Created by adiel on 13/04/2016.
//  Copyright © 2016 adiel. All rights reserved.
//

#ifndef Wow_Bridgr_Header_h
#define Wow_Bridgr_Header_h
#define WZProductType_8x8softcover @"SOFT88"
#define WZProductType_8x8hardcover @"HARD88"
#define WZProductType_6x6softcover @"SOFT66"
#define WZProductType_8x8layflat @"LAYFLAT88"

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")

#import <Availability.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <TapsbookSDK/TapsbookSDK.h>
#import <TapsbookSDK/TBSDKAlbumManager+StoreLogin.h>
#import <TapsbookSDK/TBSDKAlbumManager+StoreOrderList.h>
#import <TapsbookSDK/TBSDKAlbumManager+Checkout.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
//#import "iCarousel.h"
#import "UIImage+Save.h"
#import "TBPSSizeUtil.h"
#import "LMTBSDKHelper.h"
//#import "XMLDictionary.h"
//#import "extobjc.h"

#import "ALAssetRepresentation+Helper.h"
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <FBSDKShareKit/FBSDKShareKit.h>
//#import <GooglePlus/GooglePlus.h>
//#import <GoogleOpenSource/GoogleOpenSource.h>
//#import <SimpleAuth/SimpleAuth.h>
#import <TapsbookSDK/TBWeChatManager.h>
#import <TapsbookSDK/TBFacebookManager.h>

//#import <AFNetworking/AFNetworking.h>
//#import "MHFacebookImageViewer.h"
//#import "UIAlertView+BlocksKit.h"
#endif /* Wow_Bridgr_Header_h */
