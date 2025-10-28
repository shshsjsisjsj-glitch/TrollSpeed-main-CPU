//
//  hudapp-bridging-header.h
//  TrollSpeed
//
//  Created by Lessica on 2024/1/25.
//

#ifndef hudapp_bridging_header_h
#define hudapp_bridging_header_h

#import <Foundation/Foundation.h>

#import "HUDHelper.h"

typedef NSString * HUDUserDefaultsKey;

static HUDUserDefaultsKey const HUDUserDefaultsKeySelectedMode = @"selectedMode";
static HUDUserDefaultsKey const HUDUserDefaultsKeySelectedModeLandscape = @"selectedModeLandscape";
static HUDUserDefaultsKey const HUDUserDefaultsKeyCurrentPositionY = @"currentPositionY";
static HUDUserDefaultsKey const HUDUserDefaultsKeyCurrentLandscapePositionY = @"currentLandscapePositionY";
static HUDUserDefaultsKey const HUDUserDefaultsKeyPassthroughMode = @"passthroughMode";
static HUDUserDefaultsKey const HUDUserDefaultsKeySingleLineMode = @"singleLineMode";
static HUDUserDefaultsKey const HUDUserDefaultsKeyUsesBitrate = @"usesBitrate";
static HUDUserDefaultsKey const HUDUserDefaultsKeyUsesArrowPrefixes = @"usesArrowPrefixes";
static HUDUserDefaultsKey const HUDUserDefaultsKeyUsesLargeFont = @"usesLargeFont";
static HUDUserDefaultsKey const HUDUserDefaultsKeyUsesRotation = @"usesRotation";
static HUDUserDefaultsKey const HUDUserDefaultsKeyUsesInvertedColor = @"usesInvertedColor";
static HUDUserDefaultsKey const HUDUserDefaultsKeyKeepInPlace = @"keepInPlace";
static HUDUserDefaultsKey const HUDUserDefaultsKeyHideAtSnapshot = @"hideAtSnapshot";

static HUDUserDefaultsKey const HUDUserDefaultsKeyUsesCustomFontSize = @"usesCustomFontSize";
static HUDUserDefaultsKey const HUDUserDefaultsKeyRealCustomFontSize = @"realCustomFontSize";
static HUDUserDefaultsKey const HUDUserDefaultsKeyUsesCustomOffset = @"usesCustomOffset";
static HUDUserDefaultsKey const HUDUserDefaultsKeyRealCustomOffsetX = @"realCustomOffsetX";
static HUDUserDefaultsKey const HUDUserDefaultsKeyRealCustomOffsetY = @"realCustomOffsetY";

//ESP
//
//static HUDUserDefaultsKey const 绘制总开关 = @"绘制总开关";
//static HUDUserDefaultsKey const 过直播开关 = @"过直播开关";
//static HUDUserDefaultsKey const 无后座开关 = @"无后座开关";
//static HUDUserDefaultsKey const 自瞄开关 = @"自瞄开关";
//static HUDUserDefaultsKey const 追踪开关 = @"追踪开关";
//static HUDUserDefaultsKey const 手雷预警开关 = @"手雷预警开关";
//static HUDUserDefaultsKey const 聚点开关 = @"聚点开关";
//static HUDUserDefaultsKey const 防抖开关 = @"防抖开关";
//static HUDUserDefaultsKey const 射线开关 = @"射线开关";
//static HUDUserDefaultsKey const 骨骼开关 = @"骨骼开关";
//static HUDUserDefaultsKey const 方框开关 = @"方框开关";
//static HUDUserDefaultsKey const 距离开关 = @"距离开关";
//static HUDUserDefaultsKey const 血条开关 = @"血条开关";
//static HUDUserDefaultsKey const 背景开关 = @"背景开关";
//
//static HUDUserDefaultsKey const 边缘开关 = @"边缘开关";
//static HUDUserDefaultsKey const 附近人数开关 = @"附近人数开关";
//static HUDUserDefaultsKey const 手持武器开关 = @"手持武器开关";
//
//static HUDUserDefaultsKey const 物资总开关 = @"物资总开关";
//static HUDUserDefaultsKey const 载具开关 = @"载具开关";
//static HUDUserDefaultsKey const 药品开关 = @"药品开关";
//static HUDUserDefaultsKey const 投掷物开关 = @"投掷物开关";
//static HUDUserDefaultsKey const 配件开关 = @"配件开关";
//static HUDUserDefaultsKey const 子弹开关 = @"子弹开关";
//static HUDUserDefaultsKey const 其他物资开关 = @"其他物资开关";
//static HUDUserDefaultsKey const 高级物资开关 = @"高级物资开关";
//static HUDUserDefaultsKey const 头盔开关 = @"头盔开关";
//static HUDUserDefaultsKey const 背包开关 = @"背包开关";
//static HUDUserDefaultsKey const 物资调试开关 = @"物资调试开关";


#endif /* hudapp_bridging_header_h */
