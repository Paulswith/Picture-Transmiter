//
//  FTCollectionViewCell.h
//  File Transmiter
//
//  Created by Dobby on 2018/11/10.
//  Copyright © 2018 dobby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define NOTIFICATION_MARK @"DeletaItemWithTagId"

@interface FTCollectionViewCell : UICollectionViewCell
// 如果是NSData另说.
+ (instancetype)collectionViewCellWithImageName:(NSString *)imageName deleteImageTag:(NSInteger)tag;

+ (instancetype)collectionViewCellWithImage:(UIImage *)image deleteImageTag:(NSInteger)tag;

+ (instancetype)collectionViewCellWithImagePath:(NSString *)imagePath deleteImageTag:(NSInteger)tag;

- (BOOL)isEmptyCell;
- (void)updateDeleteImageTag:(NSUInteger)tag;
- (void)setDataImage:(UIImage *)img andDeleteTag:(NSInteger)tag;
- (void)setDataImageWithPath:(NSString *)imgPath andDeleteTag:(NSInteger)tag;
@end

NS_ASSUME_NONNULL_END
