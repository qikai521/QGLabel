//
//  QGLabel.h
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QGLabelLink.h"
#import "QGLabelImage.h"
@class QGLabel;
@protocol QGLabelDelegate <NSObject>

/**
 * 选中超文本的回调
 * -> 被选中的超文本selectedLink
 */
- (void)attributedLabel:(QGLabel *)label selectedLink:(QGLabelLink *)selectedLink;

/**
 * 选中图片的回调
 * -> 被选中的图片selectedImage
 */
- (void)attributedLabel:(QGLabel *)label selectedImage:(QGLabelImage *)selectedImage;

@end



@interface QGLabel : UIView

@property (nonatomic, weak) id<QGLabelDelegate> delegate;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIFont *linkFont;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIColor *linkColor;

@property (nonatomic, assign) NSUInteger numberOfLines;

@property (nonatomic ,strong )UIColor *hightLightColor;

@property (nonatomic, assign) CGSize imageSize;

- (void)setText:(NSString *)text;

- (void)setAttributedText:(NSAttributedString *)attributedText;

- (void)addCustomLink:(NSString *)link;
- (void)addCustomLink:(NSString *)link
            linkColor:(UIColor *)linkColor
             linkFont:(UIFont *)linkFont;

@end
