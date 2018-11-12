//
//  FTDataModel.h
//  File Transmiter
//
//  Created by Dobby on 2018/11/11.
//  Copyright © 2018 dobby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FTDataModel : NSObject

@property(strong, nonatomic)NSString *imgPath;
@property(strong, nonatomic)UIImage *image;

+ (instancetype)dataModelWith:(UIImage *)image imageLocalPath:(NSString *)imgpath;
@end

NS_ASSUME_NONNULL_END
