//
//  ButtonViewController.m
//  TrollSpeed
//
//  Created by 十三哥 on 2024/6/21.
//

#import "ButtonViewController.h"
#import "GameVV.h"

@interface ButtonViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *buttonTitles; // 存储按钮标题的数组

@end

@implementation ButtonViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置视图背景色
    self.view.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.5];

    // 初始化毛玻璃效果
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.alpha = 0.95;
    blurView.frame = self.view.bounds;

    // 将毛玻璃视图添加到视图层级的底层
    [self.view insertSubview:blurView atIndex:0];

    self.buttonTitles = @[@"ESP总开关", @"附近人数", @"绘制射线", @"绘制方框", @"绘制名字", @"绘制距离", @"绘制玩家血条", @"绘制骨骼", @"玩家信息背景", @"手持武器开关", @"物资总开关", @"🚕载具显示", @"💊药品显示", @"💣投掷物显示", @"🔫枪械显示", @"配件显示", @"🔭倍镜显示", @"🎩头盔显示", @"👗护甲显示", @"🎒背包显示", @"高级物资显示", @"子弹", @"其他物资",@"物资调试开关", @"无后坐", @"聚点", @"防抖"];

    [self setupScrollView];

    [self createCustomButtons];
    
    //设置标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.text = @"绘制设置";
    titleLabel.font = [UIFont boldSystemFontOfSize:25];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.5];
    [titleLabel sizeToFit];
    titleLabel.layer.cornerRadius = 8;
    titleLabel.clipsToBounds = YES;
    [self.view addSubview:titleLabel];
    // 设置标题
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10].active = YES;
    [titleLabel.widthAnchor constraintEqualToConstant:self.view.frame.size.width - 20].active = YES;
    [titleLabel.heightAnchor constraintEqualToConstant:40].active = YES;
    
    
    // 创建关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.backgroundColor = [[UIColor systemBackgroundColor] colorWithAlphaComponent:0.5];
    closeButton.layer.cornerRadius = 15;
    closeButton.layer.masksToBounds = YES;
    [closeButton setImage:[UIImage systemImageNamed:@"arrowshape.turn.up.backward"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    // 创建关闭按钮
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15].active = YES;
    [closeButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:15].active = YES;
    [closeButton.widthAnchor constraintEqualToConstant:30].active = YES;
    [closeButton.heightAnchor constraintEqualToConstant:30].active = YES;
   
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // 在这里更新布局
    [self updateLayoutForSize:size];
}

- (void)updateLayoutForSize:(CGSize)size {
    // 根据新的 size 更新 ScrollView 的 contentSize 等
    // 可以重新调用 createCustomButtons 方法来重新计算和布局按钮和滑条
    [self createCustomButtons];
}

- (void)closeViewController {
    // 在这里实现关闭视图控制器的逻辑
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    // 在 setupScrollView 方法中
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:70].active = YES;
    [self.scrollView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.scrollView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

}

- (void)createCustomButtons {
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat buttonSpacing = 10;
    CGFloat availableWidth = screenWidth - buttonSpacing;

    CGFloat x = 0;
    CGFloat y = 0;

    for (int i = 0; i < self.buttonTitles.count; i++) {
        
        
        //读取标题
        NSString *title = self.buttonTitles[i];

        //设置按钮背景
        UIView *customButton = [[UIView alloc] init];
        customButton.tag = i;
        customButton.layer.cornerRadius = 8;
        customButton.clipsToBounds = YES;
        

        //设置标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.text = title;
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textColor = [UIColor labelColor];
        [titleLabel sizeToFit];
        titleLabel.frame = CGRectMake(5, 5, titleLabel.frame.size.width, titleLabel.frame.size.height);
        [customButton addSubview:titleLabel];
        

        //设置副标题
        UILabel *subtitleLabel = [[UILabel alloc] init];
        subtitleLabel.font = [UIFont boldSystemFontOfSize:12];
        subtitleLabel.textColor = [UIColor secondaryLabelColor];
        //读取本地开关
        NSString *buttonBool = [NSString stringWithFormat:@"开关%d", i];
        BOOL isClicked = [[NSUserDefaults standardUserDefaults] boolForKey:buttonBool];
        //赋值文字
        NSString *subtitle = isClicked ? @"已开启" : @"已关闭";
        subtitleLabel.text = subtitle;
        [subtitleLabel sizeToFit];
        subtitleLabel.frame = CGRectMake(5, 5 + titleLabel.frame.size.height, MAX(titleLabel.frame.size.width, 60), titleLabel.frame.size.height);
        [customButton addSubview:subtitleLabel];

        //获取标题长度
        CGFloat titleWidth = [title sizeWithAttributes:@{NSFontAttributeName: titleLabel.font}].width + 20;
        CGFloat buttonWidth = MAX(MIN(titleWidth, availableWidth), 80);
        
        if (x + buttonWidth + buttonSpacing > screenWidth) {
            x = 0;
            y += 44 + buttonSpacing;  // 增加 10 作为上下行之间的间隙
        }

        customButton.frame = CGRectMake(x + buttonSpacing, y, buttonWidth, 44);

        x = customButton.frame.origin.x + customButton.frame.size.width;

        [customButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customButtonClicked:)]];
        
        
        [self.scrollView addSubview:customButton];
        [self setUI:customButton];
        
    }
    CGFloat totalHeight = y + 44;
    
    //滑条
    CGFloat sliderSpacing = 10;
    CGFloat sliderWidth = screenWidth - 2 * sliderSpacing;
    NSArray *sliderTitle = @[@"追踪距离",@"追踪圆圈大小",@"追踪自瞄数度"];
    
    for (int i = 0; i < 3; i++) {
        NSString *sliderKey = [NSString stringWithFormat:@"滑条%d",i];
        float sliderValue = [[NSUserDefaults standardUserDefaults] floatForKey:sliderKey];
        // 创建背景视图
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(sliderSpacing, y + 44 + 10, sliderWidth, 80)];
        backgroundView.backgroundColor = [[UIColor secondarySystemBackgroundColor] colorWithAlphaComponent:0.9];
        backgroundView.layer.cornerRadius = 8;
        backgroundView.layer.masksToBounds = YES;
        // 创建滑条标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-20, 20)];
        titleLabel.text = sliderTitle[i];
        [backgroundView addSubview:titleLabel];
        
        // 创建滑条
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(120, 30, sliderWidth - 130, 20)];
        slider.tag = i;
        slider.value = sliderValue?sliderValue:0; // 设置初始值
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [backgroundView addSubview:slider];
        
        // 显示滑条的值
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 70, 20)];
        [backgroundView addSubview:valueLabel];
        
        [self.scrollView addSubview:backgroundView];
        
        y += backgroundView.frame.size.height + sliderSpacing;
        
        
    }
    totalHeight = y + 80;
    
    self.scrollView.contentSize = CGSizeMake(screenWidth, totalHeight);
    
}
//开关调用
- (void)customButtonClicked:(UITapGestureRecognizer *)gestureRecognizer {
    UIView *customButton = (UIView *)gestureRecognizer.view;
    NSString *buttonBool = [NSString stringWithFormat:@"开关%ld", (long)[customButton tag]];
    BOOL isClicked = [[NSUserDefaults standardUserDefaults] boolForKey:buttonBool];
    isClicked =!isClicked;  // 切换点击状态
    [[NSUserDefaults standardUserDefaults] setBool:isClicked forKey:buttonBool];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setUI:customButton];
    
}
//滑条调用
- (void)sliderValueChanged:(UISlider *)slider {
    UILabel *valueLabel = (UILabel *)[slider.superview.subviews objectAtIndex:2];
    valueLabel.text = [NSString stringWithFormat:@"%.2f", slider.value];
    NSString *sliderKey = [NSString stringWithFormat:@"滑条%ld",(long)slider.tag];
    [[NSUserDefaults standardUserDefaults] setFloat: slider.value forKey:sliderKey];
}

- (void)setUI:(UIView*)customButton{
   
    NSString *buttonBool = [NSString stringWithFormat:@"开关%ld", (long)[customButton tag]];
    BOOL isClicked = [[NSUserDefaults standardUserDefaults] boolForKey:buttonBool];
    
    UILabel *subtitleLabel = [customButton.subviews objectAtIndex:1];
    NSString *subtitle = isClicked? @"已开启" : @"已关闭";
    subtitleLabel.text = subtitle;

    UIColor *color = isClicked? [[UIColor systemBlueColor] colorWithAlphaComponent:0.9] : [[UIColor secondarySystemBackgroundColor] colorWithAlphaComponent:0.9];
    customButton.backgroundColor = color;
    [[GameVV factory] getBool];
}
@end
