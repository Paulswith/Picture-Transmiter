//
//  FTInfoShower.h
//  File Transmiter
//
//  Created by Dobby on 2018/11/12.
//  Copyright © 2018 dobby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SSHConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface FTInfoShower : NSObject

+ (void)showToastWithMsg:(NSString *)msg inView:(UIView *)sView;
+ (void)showProgressWithBarInView:(UIView *)sView runningBlick:(SSHConnectionType(^)(void))runningFunc;

//- (void)eat:(void(^)(NSString*))block;


@end

NS_ASSUME_NONNULL_END
