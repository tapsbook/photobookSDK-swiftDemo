//
//  NSFileManager+TBDirSize.h
//  Swip
//
//  Created by Xinrong Guo on 8/18/15.
//  Copyright (c) 2015 Ziqi Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (TBDirSize)

/**
 获取cache的size

 @param size &size
 @param directoryURL 沙盒地址
 @param error error
 @return yes or no
 */
- (BOOL)tb_getAllocatedSize:(unsigned long long *)size
           ofDirectoryAtURL:(NSURL *)directoryURL
                      error:(NSError * __autoreleasing *)error;

/**
 获取cache的size 大小

 @param size &size
 @param option NSDirectoryEnumerationOptions
 @param fileNameFilter 过滤标识
 @param directoryURL 地址
 @param error 错误信息
 @return yes or no
 */
- (BOOL)tb_getAllocatedSize:(unsigned long long *)size
                     option:(NSDirectoryEnumerationOptions)option
                     filter:(NSString *)fileNameFilter
           ofDirectoryAtURL:(NSURL *)directoryURL
                      error:(NSError * __autoreleasing *)error;

@end
