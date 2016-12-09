//
//  QGLabelImage.h
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, QGImageType){
    QGImageType_PNG = 0,
    QGImageType_GIF = 1,
    QGImageType_RUL = 2
};


@interface QGLabelImage : NSObject

@property (nonatomic ,copy )NSString *imageName;

@property (nonatomic ,assign )CGSize imageSize;

@property (nonatomic ,assign )NSInteger position;

@property (nonatomic ,assign )QGImageType imageType;

/**
 * 占位图片属性字符的字体fontRef
 * ->此处为方便计算Ascent和Descent
 */
@property (nonatomic, assign) CTFontRef fontRef;

/**
 * 图片与文字的上下左右的间距
 */
@property (nonatomic, assign) UIEdgeInsets imageInsets;


@end
