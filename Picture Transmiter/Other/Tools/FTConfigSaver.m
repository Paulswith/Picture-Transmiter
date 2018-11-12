//
//  FTConfigSaver.m
//  File Transmiter
//
//  Created by dobby on 2018/11/12.
//  Copyright © 2018 dobby. All rights reserved.
//

#import "FTConfigSaver.h"

@implementation FTConfigSaver

+ (void)storeConfigSaveKey:(NSString *)key withValue:(id)value
{
    NSUserDefaults *defaulter =  [NSUserDefaults standardUserDefaults];
    [defaulter setValue:value forKey:key];
    [defaulter synchronize];
}

+ (id)queryValueWithKey:(NSString *)key
{
    NSUserDefaults *defaulter =  [NSUserDefaults standardUserDefaults];
    return [defaulter valueForKey:key];
}


@end
