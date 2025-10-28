//
//  DrawHelper.m
//  TrollSpeed
//
//  Created by 十三哥 on 2024/6/21.
//

#import "DrawHelper.h"

@implementation DrawHelper
//全局字典
static NSMutableDictionary *colorDict = nil;
//初始化
+ (void)initialize {
    if (self == [DrawHelper class]) {
        colorDict = [[NSMutableDictionary alloc] init];
    }
}
#pragma mark - 根据对标读取颜色
+ (UIColor *)colorForKey:(NSInteger)key {
    NSNumber *keyNumber = @(key);
    UIColor *color = colorDict[keyNumber];
    if (color) {
        return color;
    } else {
        CGFloat r = arc4random_uniform(256) / 255.0;
        CGFloat g = arc4random_uniform(256) / 255.0;
        CGFloat b = arc4random_uniform(256) / 255.0;
        color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        colorDict[keyNumber] = color;
        return color;
    }
}

#pragma mark - 绘制文字
+ (void)drawText:(NSString *)text atPoint:(CGPoint)point withFontSize:(CGFloat)fontSize andColor:(UIColor *)color {
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
        NSForegroundColorAttributeName: color
    };
    [text drawAtPoint:point withAttributes:attributes];
}

#pragma mark - 绘制射线
+ (void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withColor:(UIColor *)color lineWidth:(CGFloat)lineWidth {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    [color setStroke];
    path.lineWidth = lineWidth; // 设置线宽
    [path stroke];
}


#pragma mark - 绘制矩形（空心）
+ (void)drawRectangleWithRect:(CGRect)rect borderColor:(UIColor *)borderColor {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    [borderColor setStroke];
    [path stroke];
}

#pragma mark - 绘制矩形（填充）
+ (void)drawFilledRectangleWithRect:(CGRect)rect fillColor:(UIColor *)fillColor {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    
    [fillColor setFill];
    [path fill];
}

#pragma mark - 绘制圆形（空心）
+ (void)drawCircleWithCenter:(CGPoint)center radius:(CGFloat)radius borderColor:(UIColor *)borderColor  lineWidth:(CGFloat)lineWidth{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    path.lineWidth = lineWidth; // 设置线宽
    [borderColor setStroke];
    [path stroke];
}
#pragma mark - 绘制半圆弧（空心）
+ (void)drawArcWithCenter:(CGPoint)center radius:(CGFloat)radius borderColor:(UIColor *)borderColor lineWidth:(CGFloat)lineWidth arcLength:(CGFloat)arcLength {
    // 计算起始角度和结束角度
    CGFloat startAngle = -M_PI_2;  // 从12点钟方向开始，这里是-90度
    CGFloat endAngle = startAngle + arcLength * M_PI * 2;  // 根据arcLength计算结束角度

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    path.lineWidth = lineWidth;
    path.lineCapStyle = kCGLineCapRound; // 设置线端样式为圆形
    
    [borderColor setStroke];
    [path stroke];
}


#pragma mark - 绘制圆形（填充）
+ (void)drawFilledCircleWithCenter:(CGPoint)center radius:(CGFloat)radius fillColor:(UIColor *)fillColor {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    [fillColor setFill];
    [path fill];
}

@end

