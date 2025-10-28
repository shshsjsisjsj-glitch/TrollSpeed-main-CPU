//
//  DrawHelper.h
//  TrollSpeed
//
//  Created by 十三哥 on 2024/6/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@interface DrawHelper : NSObject
// 查询颜色
+ (UIColor *)colorForKey:(NSInteger)key;

// 绘制文字
+ (void)drawText:(NSString *)text atPoint:(CGPoint)point withFontSize:(CGFloat)fontSize andColor:(UIColor *)color;

// 绘制射线
+ (void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth;

// 绘制矩形（空心）
+ (void)drawRectangleWithRect:(CGRect)rect borderColor:(UIColor *)borderColor;

// 绘制矩形（填充）
+ (void)drawFilledRectangleWithRect:(CGRect)rect fillColor:(UIColor *)fillColor;

// 绘制圆形（空心）
+ (void)drawCircleWithCenter:(CGPoint)center radius:(CGFloat)radius borderColor:(UIColor *)borderColor  lineWidth:(CGFloat)lineWidth;

// 绘制半圆弧（空心）
+ (void)drawArcWithCenter:(CGPoint)center radius:(CGFloat)radius borderColor:(UIColor *)borderColor lineWidth:(CGFloat)lineWidth arcLength:(CGFloat)arcLength;

// 绘制圆形（填充）
+ (void)drawFilledCircleWithCenter:(CGPoint)center radius:(CGFloat)radius fillColor:(UIColor *)fillColor;

@end


NS_ASSUME_NONNULL_END
