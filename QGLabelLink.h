//
//  QGLabelLink.h
//  QGLabel
//
//  Created by qikai on 16/12/6.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QGLabelLink : NSObject
@property (nonatomic, copy) NSString *text;

/**
 * 超文本内容在字符串中所在的位置
 */
@property (nonatomic, assign) NSRange range;
@end
