//
//  FTImageView.m
//  File Transmiter
//
//  Created by dobby on 2018/11/12.
//  Copyright © 2018 dobby. All rights reserved.
//

#import "FTImageView.h"

@implementation FTImageView

/* 重写扩大点击区域: */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat m_offset = 20;
    CGSize curSize = self.bounds.size;
    CGRect hitRect = CGRectMake(0 - m_offset, 0 - m_offset, curSize.width + m_offset, curSize.height + m_offset);
    return CGRectContainsPoint(hitRect, point) ? self : nil;
}

@end
