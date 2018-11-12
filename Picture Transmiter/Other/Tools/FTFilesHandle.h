//
//  FTFilesHandle.h
//  File Transmiter
//
//  Created by dobby on 2018/11/12.
//  Copyright © 2018 dobby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FTFilesHandle : NSObject

+ (void)removeAllItemAtDirectory:(NSString *)directoryPath;

@end

NS_ASSUME_NONNULL_END
