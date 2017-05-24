//
//  TBProduct.h
//  TapsbookSDK
//
//  Created by Xinrong Guo on 10/28/15.
//  Copyright © 2015 tapsbook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBProductType) {
    TBProductType_Photobook = 1,
    TBProductType_Canvas    = 2,
    TBProductType_Calendar  = 3,
    TBProductType_Card      = 4,
    TBProductType_Pillow    = 5,
    TBProductType_Phonecase = 6,
    TBProductType_Mug       = 7,
    TBProductType_Tshirt    = 8,
    TBProductType_Bookbag   = 9,
    TBProductType_Postage   = 10,
    TBProductType_Photoprint= 11,
    TBProductType_Lomocard  = 12,
    TBProductType_Framedart = 13,
    TBProductType_Udisk     = 14,
    TBProductType_Undefined = 10000
};

@interface TBProduct : NSObject

+ (TBProductType) typeFromString:(NSString *)stringName;

+ (NSString *)typeString:(NSString *)stringName;

@end



