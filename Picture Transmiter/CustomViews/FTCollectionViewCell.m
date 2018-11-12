//
//  FTCollectionViewCell.m
//  File Transmiter
//
//  Created by Dobby on 2018/11/10.
//  Copyright © 2018 dobby. All rights reserved.
//

#import "FTCollectionViewCell.h"

#define CELL_NIB_NAME @"FTCollectionViewCell"
#define CELL_DELETE_IMGNAME @"delete"
@interface FTCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *imagePath;
@property (weak, nonatomic) IBOutlet UIImageView *deleteImageView;

@end

@implementation FTCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self = [[[NSBundle mainBundle] loadNibNamed:CELL_NIB_NAME owner:self options:nil] lastObject];
    }
    
    /*
     删除通过手势点击, 发一个删除通知 , info[tag]
     */
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] init];
//    [self.deleteImageView addGestureRecognizer:tapGR];
    
    [_deleteImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postDeleteItem)]];
    [_deleteImageView setUserInteractionEnabled:YES];
    
    return self;
}



- (void)postDeleteItem {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MARK
                                                        object:self
                                                      userInfo:@{@"tag": [NSNumber numberWithInteger:self.deleteImageView.tag]}];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MARK
//                                                        object:self
//                                                      userInfo:@{@"imgPath": self.imagePath}];
}

+ (instancetype)collectionViewCellWithImageName:(NSString *)imageName deleteImageTag:(NSInteger)tag
{
    FTCollectionViewCell *ftcell = [[FTCollectionViewCell alloc] init];
    [ftcell.imageView setImage:[UIImage imageNamed:imageName]];
    [ftcell.deleteImageView setImage:[UIImage imageNamed:CELL_DELETE_IMGNAME]];
    [ftcell.deleteImageView setTag:tag];
    return ftcell;
}

+ (instancetype)collectionViewCellWithImagePath:(NSString *)imagePath deleteImageTag:(NSInteger)tag
{
    FTCollectionViewCell *ftcell = [[FTCollectionViewCell alloc] init];
    [ftcell.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    [ftcell setImagePath:imagePath];
    [ftcell.deleteImageView setImage:[UIImage imageNamed:CELL_DELETE_IMGNAME]];
    [ftcell.deleteImageView setTag:tag];
    return ftcell;
}

+ (instancetype)collectionViewCellWithImage:(UIImage *)image deleteImageTag:(NSInteger)tag
{
    FTCollectionViewCell *ftcell = [[FTCollectionViewCell alloc] init];
    [ftcell.imageView setImage:image];
    [ftcell.deleteImageView setImage:[UIImage imageNamed:CELL_DELETE_IMGNAME]];
    [ftcell.deleteImageView setTag:tag];
    return ftcell;
}

- (BOOL)isEmptyCell {
    return self.imageView.image == nil ? YES : NO;
}

- (void)updateDeleteImageTag:(NSUInteger)tag
{
    [self.deleteImageView setTag:tag];
}

- (void)setDataImage:(UIImage *)img andDeleteTag:(NSInteger)tag
{
    [self.imageView setImage:img];
    [self.deleteImageView setTag:tag];
}

- (void)setDataImageWithPath:(NSString *)imgPath andDeleteTag:(NSInteger)tag
{
    [self setImagePath:imgPath];
    [self.imageView setImage:[UIImage imageWithContentsOfFile:imgPath]];
    [self.deleteImageView setTag:tag];
}

@end
