//
//  TBStoreInfo.h
//  TapsbookSDK
//
//  Created by Cary on 2017/3/2.
//  Copyright © 2017年 tapsbook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBStoreInfo : NSObject

/** 
 画像
 */
@property (copy, nonatomic) NSString *avatar_url;

/** 
 store name
 */
@property (copy, nonatomic) NSString *name;

/**
 store key,对应 merchantKey
 */
@property (copy, nonatomic) NSString *store_api_key;

/**
 store_code
 */
@property (copy, nonatomic) NSString *store_key;


- (instancetype)initWithDict:(NSDictionary *)dict;

- (NSDictionary *)toDict;


@end
