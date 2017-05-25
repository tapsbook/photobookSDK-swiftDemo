//
//  NSFileManager+TBDirSize.m
//  Swip
//
//  Created by Xinrong Guo on 8/18/15.
//  Copyright (c) 2015 Ziqi Wu. All rights reserved.
//

#import "NSFileManager+TBDirSize.h"

@implementation NSFileManager (TBDirSize)

// https://github.com/NikolaiRuhe/NRFoundation/blob/master/NRFoundation/NRFileManager.m

// This method calculates the accumulated size of a directory on the volume in bytes.
//
// As there's no simple way to get this information from the file system it has to crawl the entire hierarchy,
// accumulating the overall sum on the way. The resulting value is roughly equivalent with the amount of bytes
// that would become available on the volume if the directory would be deleted.
//
// Caveat: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
// directories, hard links, ...).
- (BOOL)tb_getAllocatedSize:(unsigned long long *)size
           ofDirectoryAtURL:(NSURL *)directoryURL
                      error:(NSError * __autoreleasing *)error {
    return [self tb_getAllocatedSize:size option:0 filter:nil ofDirectoryAtURL:directoryURL error:error];
}

- (BOOL)tb_getAllocatedSize:(unsigned long long *)size
                     option:(NSDirectoryEnumerationOptions)option
                     filter:(NSString *)fileNameFilter
           ofDirectoryAtURL:(NSURL *)directoryURL
                      error:(NSError * __autoreleasing *)error {
    NSParameterAssert(size != NULL);
    NSParameterAssert(directoryURL != nil);
    
    // We'll sum up content size here:
    unsigned long long accumulatedSize = 0;
    
    // prefetching some properties during traversal will speed up things a bit.
    NSArray *prefetchedProperties = @[
                                      NSURLIsRegularFileKey,
                                      NSURLFileAllocatedSizeKey,
                                      NSURLTotalFileAllocatedSizeKey,
                                      ];
    
    // The error handler simply signals errors to outside code.
    __block BOOL errorDidOccur = NO;
    BOOL (^errorHandler)(NSURL *, NSError *) = ^(NSURL *url, NSError *localError) {
        if (error != NULL)
            *error = localError;
        errorDidOccur = YES;
        return NO;
    };
    
    // We have to enumerate all directory contents, including subdirectories.
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryURL
                                                             includingPropertiesForKeys:prefetchedProperties
                                                                                options:option
                                                                           errorHandler:errorHandler];
    
    // Start the traversal:
    for (NSURL *contentItemURL in enumerator) {
        if (fileNameFilter && ( [contentItemURL.absoluteString rangeOfString:fileNameFilter].location != NSNotFound) ) {
            continue; // Ignore anything except regular files.
        }
        
        // Bail out on errors from the errorHandler.
        if (errorDidOccur)
            return NO;
        
        // Get the type of this item, making sure we only sum up sizes of regular files.
        NSNumber *isRegularFile;
        if (! [contentItemURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:error])
            return NO;
        if (! [isRegularFile boolValue])
            continue; // Ignore anything except regular files.
        
        // To get the file's size we first try the most comprehensive value in terms of what the file may use on disk.
        // This includes metadata, compression (on file system level) and block size.
        NSNumber *fileSize;
        if (! [contentItemURL getResourceValue:&fileSize forKey:NSURLTotalFileAllocatedSizeKey error:error])
            return NO;
        
        // In case the value is unavailable we use the fallback value (excluding meta data and compression)
        // This value should always be available.
        if (fileSize == nil) {
            if (! [contentItemURL getResourceValue:&fileSize forKey:NSURLFileAllocatedSizeKey error:error])
                return NO;
            
            NSAssert(fileSize != nil, @"huh? NSURLFileAllocatedSizeKey should always return a value");
        }
        
        // We're good, add up the value.
        accumulatedSize += [fileSize unsignedLongLongValue];
    }
    
    // Bail out on errors from the errorHandler.
    if (errorDidOccur)
        return NO;
    
    // We finally got it.
    *size = accumulatedSize;
    return YES;
}




@end
