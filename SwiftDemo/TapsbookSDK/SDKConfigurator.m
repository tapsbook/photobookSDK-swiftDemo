//
//  SDKConfigurator.m
//  TapsbookSDKDemo
//
//  Created by Xinrong Guo on 14-6-30.
//  Copyright (c) 2014年 tapsbook. All rights reserved.
//

#import "SDKConfigurator.h"
#import <TapsbookSDK/TapsbookSDK.h>
#import <TapsbookSDK/TBProduct.h>

static NSString * const kTBS3AppKey = @"AKIAJ7D2AGAC6S24OXMQ";
static NSString * const kTBS3AppSecret = @"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";
#if DEBUG
static NSString * const kTBS3BucketNameDefault = @"tapstest";
static NSString * const kStripeKey = @"pk_test_d5alHjczpNGKCRL539vo14TL";
#else
//USE CDN link
static NSString * const kTBS3BucketNameDefault = @"tapsbookapp";
static NSString * const kStripeKey = @"pk_live_vgeBiZVkdp1z3yWpBQgjjQjp";
#endif

@implementation SDKConfigurator

- (NSDictionary *)basicSettings {
    NSDictionary *settings = @{
                               kTBSDKBasics : @{
                                       kTBAppName : @"TBSDKDemo",             // (Required) Your app name, this name will show up in app UI messages
                                       kTBAppKey : @"",                       // (Required)
                                       kTBAppSecret : @"",                    // (Required)
                                       
                                       kTBSupportedRegions : @[               // (Optional) TBSDKRegions, customize the SDK to support multiple ship to regions (countries)
                                               // TBSDKRegions
//                                               @(TBSDKRegion_UnitedStates),
                                               @(TBSDKRegion_China)
                                               ],
                                       
                                       kTBMerchantKeys : @{                   // (Required) Your app keys that you setup from http://dashboard.tapsbook.com, Append a string prefix "test_[ACTUAL_KEY]" will connect to the test server
                                               // Region : merchantKey
#ifdef DEBUG
                                               @(TBSDKRegion_UnitedStates) :@"live_canvas_7c5041f868a53ab26abf24b110d9bec7",
                                               //live_canvas_7c5041f868a53ab26abf24b110d9bec7
                                               //
                                               @(TBSDKRegion_China) :
                                                   @"live_clntw_1bad7d47623c98b4d280c823dc08866e",
                                               //live_192f1444303ff0fff8461ad9f72be65e                                         //                         //live_tpsbk_a724462b7f2694f53631ac1c445908b7
                                               //                                     @"live_CLEEN_192f1444303ff0fff8461ad9f72be65e",
                                               //                                     @"test_CLEEN_587a7f4ae3b2060a4822aadafb6f72fb",
#else
                                               @(TBSDKRegion_UnitedStates) : @"live_CLEEN_6d11aa4454d745d25322085911a0ec60",
                                               @(TBSDKRegion_China) :
                                                   @"live_CLEEN_192f1444303ff0fff8461ad9f72be65e",
                                               //    live_tpsbk_a724462b7f2694f53631ac1c445908b7                                 @"",
#endif
                                               kTBMerchantKeyDefault : @"test_CLEEN_587a7f4ae3b2060a4822aadafb6f72fb",   // (Optional) The default key
                                               },
                                       kTBStripeKeys : @{                     // (Required) Stripe uses this key to create a charge token to make the charge on the tapsbook eCommerce server.
                                               // Region : stripeKey
                                               
#ifdef DEBUG
                                               kTBStripeKeyDefault : @"pk_test_d5alHjczpNGKCRL539vo14TL",
#else
                                               kTBStripeKeyDefault : @"pk_test_d5alHjczpNGKCRL539vo14TL",
#endif
                                               },
                                       },
                               
                               kTBAppLogoPaths : @{                         // (Optional) Your app logo that will be printed on the back cover, assuming the back cover has a design include the app logo
                                       //                                             kTBImageSizeS : [[NSBundle mainBundle] pathForResource:@"cleen-cover-logo-small" ofType:@"png"],
                                       //                                             kTBImageSizeL : [[NSBundle mainBundle] pathForResource:@"cleen-cover-logo-small" ofType:@"png"],
                                       //                                             kTBImageSizeXXL : [[NSBundle mainBundle] pathForResource:@"cleen-cover-logo" ofType:@"png"],
                                       },
                               
                               kTBAWSS3 : @{
                                       kTBAWSS3AppKey : kTBS3AppKey,                      // (Optional) Your AWS s3 cloud storage account, SDK will upload the rendered images to the AWS s3 location, you may need to set your own clean up policy to remove these images routinely
                                       kTBAWSS3AppSecret : kTBS3AppSecret,                // (Optional) Your AWS s3 cloud storage account secret
                                       kTBAWSS3BucketName : kTBS3BucketNameDefault,       // (Optional) AWS uses bucket name to organize your uploaded images, your images will be uploaded to this URL pattern
                                       },
                               
                               kTBBookGeneration : @{
                                       kTBTemplateDatabaseName : @"TBTemplate_MultiProduct_02_example.sqlite",
                                       // (Optional)
//                                       kTBTemplateDatabaseName : @"TBTemplate_MultiProduct_02_example.sqlite", // (Optional) The name of the template database
                                       kTBDefaultThemeID : @{              // (Optional)
                                               @(TBProductType_Photobook) : @200,
                                               @(TBProductType_Canvas) : @1000,
                                               @(TBProductType_Pillow) : @2000,
                                               @(TBProductType_Phonecase) : @3000
                                               },
                                       kTBUseSameBackgroundImageOnTheSameSpread : @{    // (Optional) Retrun YES is you want SDK's page generation use the same background image on the same spread
                                               @(TBProductType_Photobook) : @YES,
                                               @(TBProductType_Canvas) : @NO,
                                               @(TBProductType_Pillow) : @NO,
                                               @(TBProductType_Phonecase) : @NO,
                                               @(TBProductType_Calendar) : @NO,
                                               @(TBProductType_Card) : @NO,
                                               },
                                       kTBPageViewDisplayEdgeInsets : @{
                                               @(TBProductType_Pillow) : [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(5, 60, 10, 60)],
                                               @(TBProductType_Phonecase) : [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(30, 10, 10, 10)]
                                               },
                                       kTBMaxNumberofImagesPerPage : @{                 // (Optional)
                                               @(TBProductType_Photobook) : @2,
                                               @(TBProductType_Canvas) : @1,
                                               @(TBProductType_Pillow) : @1,
                                               @(TBProductType_Phonecase) : @1,
                                               @(TBProductType_Calendar) : @1,
                                               @(TBProductType_Card) : @1,
                                               },
                                       kTBMinNumberofImagesPerPage : @{                 // (Optional)
                                               @(TBProductType_Photobook) : @1,
                                               @(TBProductType_Canvas) : @1,
                                               @(TBProductType_Pillow) : @1,
                                               @(TBProductType_Phonecase) : @1,
                                               @(TBProductType_Calendar) : @1,
                                               @(TBProductType_Card) : @1,
                                               },
                                       kTBMaxNumberofImagesPerSpread : @{               // (Optional)
                                               @(TBProductType_Photobook) : @3,
                                               @(TBProductType_Canvas) : @1,
                                               @(TBProductType_Pillow) : @1,
                                               @(TBProductType_Phonecase) : @1,
                                               @(TBProductType_Calendar) : @1,
                                               @(TBProductType_Card) : @1,
                                               },
                                       kTBMinNumberofImagesPerSpread : @{               // (Optional)
                                               @(TBProductType_Photobook) : @2,
                                               @(TBProductType_Canvas) : @1,
                                               @(TBProductType_Pillow) : @1,
                                               @(TBProductType_Phonecase) : @1,
                                               @(TBProductType_Calendar) : @1,
                                               @(TBProductType_Card) : @1,
                                               },
                                       kTBAllowAddOrRemovePage : @{                     // (Optional)
                                               @(TBProductType_Photobook) : @YES,
                                               @(TBProductType_Canvas) : @NO,
                                               @(TBProductType_Pillow) : @NO,
                                               @(TBProductType_Phonecase) : @NO,
                                               @(TBProductType_Calendar) : @NO,
                                               @(TBProductType_Card) : @NO,
                                               },
                                       },
                               
                               kTBBehaviorCustomization : @{
                                       kTBUseEmptyTemplateForPageWithNoContent : @YES,
                                       kTBRemindUserToOrderWhenClosingBooks : @NO,      // (Optional) Whether to remind a user they will lose their work in progress if they close.
                                       kTBShowOptionsOfBuildingPagesManuallyOrAutomatically : @{  // (Optional)
                                               @(TBProductType_Photobook) : @NO,
                                               @(TBProductType_Canvas) : @NO,
                                               @(TBProductType_Pillow) : @NO,
                                               @(TBProductType_Phonecase) : @NO,
                                               @(TBProductType_Calendar) : @NO,
                                               @(TBProductType_Card) : @NO,
                                               },
                                       //                                       kTBShowPhotoMenuByDefault:@YES,
                                       
                                       kTBUseEmptyTemplateForPageWithNoContent : @NO,   // (Optional)
                                       
                                       //                                       kTBRequireBookTitle: @NO,
                                       
                                       kTBLoadProductFromServerWhenPreparingLocalAlbum : @(YES), // (Optional)
                                       },
                               
                               kTBCheckoutCustomization : @{                    // (Optional)
                                       kTBNoCover : @{                                  // (Optional) YES if you don't need a cover or the cover is not customizable
                                               @(TBProductType_Photobook) : @NO,
                                               @(TBProductType_Canvas) : @YES,
                                               @(TBProductType_Calendar) : @YES,
                                               @(TBProductType_Card) : @YES,
                                               },
                                       kTBSendAlbumJSONDictToHostingApp : @NO,          // (Optional) YES when you want to generate page image on your own.
                                       },
                               kTBHostingAppInfo : @{
                                       kTBHostingAppName : @"SwiftDemo", // TODO:i18n
                                       kTBHostingAppIconName : @"AppIcon60x60",
                                       },
                               };
    
    return settings;
}


- (float)taxRateForCountry:(NSString *)country state:(NSString *)state city:(NSString *)city {
    float rate = 0;
    if ([country isEqualToString:@"United States"] && [state isEqualToString:@"North Carolina"]){
        rate = 0.0675;
    }
    return rate;
    
}

- (BOOL)canRearrangePageAtIndex:(NSInteger)index isSpread:(BOOL)isSpread {
    if (index < 2) {
        return NO;
    }
    else {
        return YES;
    }
}

- (NSDictionary *)colorSettins {
    NSDictionary *result = @{
                             kTBPageVCTopMenuOrderBookButtonColorNormal : [UIColor redColor],
                             };
    return result;
}

@end
