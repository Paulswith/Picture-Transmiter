//
//  FTDataModel.m
//  File Transmiter
//
//  Created by Dobby on 2018/11/11.
//  Copyright © 2018 dobby. All rights reserved.
//

#import "FTDataModel.h"

@implementation FTDataModel

+ (instancetype)dataModelWith:(UIImage *)image imageLocalPath:(NSString *)imgpath
{
    FTDataModel *dModel = [FTDataModel new];
    dModel.image = image;
    dModel.imgPath = imgpath;
    return dModel;
}
@end
