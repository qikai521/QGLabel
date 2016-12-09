//
//  NSString+ImageType.h
//  QGLabel
//
//  Created by qikai on 16/12/7.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QGLabelImage.h"
@interface NSString (QGImageType)

+(QGImageType)contentTypeForImageName:(NSString *)imageName;

@end

@interface UIImageView (Gif)

+ (UIImageView *)imageViewWithGIFName:(NSString *)imageName
                                frame:(CGRect)frame;
@end
