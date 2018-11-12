//
//  FTFilesHandle.m
//  File Transmiter
//
//  Created by dobby on 2018/11/12.
//  Copyright © 2018 dobby. All rights reserved.
//

#import "FTFilesHandle.h"

@implementation FTFilesHandle

+ (void)removeAllItemAtDirectory:(NSString *)directoryPath
{
    NSFileManager *maneger = [NSFileManager defaultManager];
    NSArray *allfiles = [maneger contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *filename in allfiles) {
        NSString *fullPath = [directoryPath stringByAppendingPathComponent:filename];
        if ([maneger isDeletableFileAtPath:fullPath]) {
            [maneger removeItemAtPath:fullPath error:nil];
        }
    }
}

@end
