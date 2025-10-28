//
//  HUDRootViewController.h
//  TrollSpeed
//
//  Created by Lessica on 2024/1/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUDRootViewController: UIViewController
+ (BOOL)passthroughMode;
- (void)resetLoopTimer;
- (void)stopLoopTimer;
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSMutableDictionary *userDefaults;
@end

NS_ASSUME_NONNULL_END
