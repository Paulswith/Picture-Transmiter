//
//  FTInfoShower.m
//  File Transmiter
//
//  Created by Dobby on 2018/11/12.
//  Copyright © 2018 dobby. All rights reserved.
//

#import "FTInfoShower.h"
#import "MBProgressHUD.h"

@implementation FTInfoShower

+ (void)showToastWithMsg:(NSString *)msg inView:(UIView *)sView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sView animated:YES];
    [hud setMode:MBProgressHUDModeText];
    [hud.label setText:msg];
    
    dispatch_time_t poptime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(poptime, dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
}


+ (void)showProgressWithBarInView:(UIView *)sView runningBlick:(SSHConnectionType (^)(void))runningFunc
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sView animated:YES];

    // Set the bar determinate mode to show task progress.
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = NSLocalizedString(@"Loading...", @"HUD loading title");

    // block 修改值:
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        if (runningFunc) {
            runningFunc();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
}



@end
