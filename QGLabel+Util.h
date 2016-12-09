//
//  QGLabel+Util.h
//  QGLabel
//
//  Created by qikai on 16/12/7.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGLabel.h"
#import <CoreText/CoreText.h>
@class QGLabelLink;
@class QGLabelImage;

@interface QGLabel (Util)

@property (nonatomic ,assign,readonly )CTFrameRef frameRef;
//存放linkArr的数组
@property (nonatomic ,assign ,readonly )NSMutableArray *linkArr;
//存放图片模型的数组
@property (nonatomic, assign,readonly  )NSMutableArray *imageDatas;


//公共方法, 检测当前点击的位置 是否在链接 的位置上 ,如果是的话 返回一个link对象如果点击的不在上面就返回一个nil
-(QGLabelLink *)touchLinkInPosition:(CGPoint )position;

//判断当前点击的位置 是否处于一张图片上 ，如果是的话就返回一张图片，如果不在的话就返回nil
-(QGLabelImage *)touchImageInPosition:(CGPoint )position;


@end
