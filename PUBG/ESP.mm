#import "ESP.h"
#import "GameVV.h"
#import "PUBGDataModel.h"
#import "DrawHelper.h"
#import "HUDRootViewController.h"



@interface ESP ()
@property (nonatomic,  assign) BOOL isGameStarted;
@end

@implementation ESP{
    dispatch_source_t timer1;
    dispatch_source_t timer2;
    NSMutableDictionary *userDefaults;
    CGFloat kWidth;
    CGFloat kHeight;

}
+ (instancetype)sharedInstance {
    static ESP *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ESP alloc] init];
        // 在这里进行初始化设置（如果需要的话）
    });
    return sharedInstance;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 创建并启动第一个定时器
    [self startTimer1];
    
    // 创建并启动第二个定时器
    [self startTimer2];
    
    kWidth  = [UIScreen mainScreen].bounds.size.width;
    kHeight = [UIScreen mainScreen].bounds.size.height;
    if (kWidth<kHeight) {
        kHeight  = [UIScreen mainScreen].bounds.size.width;
        kWidth = [UIScreen mainScreen].bounds.size.height;
    }
    
}
- (void)startTimer1 {
    // 使用GCD创建一个定时器，每秒执行一次
    timer1 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (timer1) {
        dispatch_source_set_timer(timer1, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 0); // 每秒执行
        dispatch_source_set_event_handler(timer1, ^{
            //读取开关
            [[GameVV factory] getBool];
            //读取进程
            self.isGameStarted = getGame();
            //每秒读取一次玩家数组
            [[GameVV factory] getNSArray];
            
            
        });
        dispatch_resume(timer1); // 启动定时器
    }
}

- (void)startTimer2 {
    // 使用GCD创建一个定时器，
    timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (timer2) {
        dispatch_source_set_timer(timer2, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC / 120 , 0); // 每5秒执行
        dispatch_source_set_event_handler(timer2, ^{
            // 清除所有子视图
            for (UIView *subview in self.view.subviews) {
                [subview removeFromSuperview];
            }
            //游戏启动才绘制
            if (self.isGameStarted) {
                //绘制
                [self drawNextFrame];
            }
            
        });
        dispatch_resume(timer2); // 启动定时器
    }
}

- (void)drawNextFrame{
    
    // 创建绘图上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kWidth, kHeight), NO, 0.0);
    //开始读取数据和绘制
    // 绘制文字
    UIColor *color = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    NSString *text = [NSString stringWithFormat:@"感谢使用 Gworld:0x%lx  总开关:%@ task:%d",Gworld,绘制总开关?@"开":@"关",task];
    [DrawHelper drawText:text atPoint:CGPointMake(50 , 10) withFontSize:10.0 andColor:color];
    
    if(绘制总开关){
       
        NSArray*playerArray=[[GameVV factory] getData];
        NSString *text = [NSString stringWithFormat:@"playerArray:%ld",playerArray.count];
        
        [DrawHelper drawText:text atPoint:CGPointMake(50 , 25) withFontSize:10.0 andColor:color];
        //绘制玩家
        if (附近人数开关) {
            int 真人=0;
            int 人机=0;
            //单独统计ai 真人 只绘制一次附近人数
            for (NSInteger i = 0; i < playerArray.count; i++){
                PUBGPlayerModel *model = playerArray[i];
                if (model.isAI) {
                    人机++;
                }else{
                    真人++;
                }
            }
            NSString *resnhustr;
            if (playerArray.count == 0) {
                resnhustr = @"安全";
            } else {
                resnhustr = [NSString stringWithFormat:@" 真人:%d AI:%d", 真人,人机];
            }
            // 绘制文字
            
            UIColor *color = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
            [DrawHelper drawText:resnhustr atPoint:CGPointMake(kWidth/2 , 10) withFontSize:20.0 andColor:color];
                
        }
        
        for (NSInteger i = 0; i < playerArray.count; i++) {
            PUBGPlayerModel *model = playerArray[i];
            static CGFloat x = 0;
            static CGFloat y = 0;
            static CGFloat w = 0;
            static CGFloat h = 0;
            //开始绘制 解析玩家方框
            x = model.rect.X;
            y = model.rect.Y;
            w = model.rect.W;
            h = model.rect.H;
            float xd = x+w/2;
            float yd = y;
            
            //屏幕外面 只绘制射线然后跳出 执行下一个玩家 避免绘制其他占用内存CPU===============
            if (model.isPm==NO){
                if(射线开关){
                    // 绘制射线
                    UIColor *color = model.isAI ? [UIColor colorWithRed:0 green:1 blue:0 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                    [DrawHelper drawLineFromPoint:CGPointMake(kWidth/2, 40) toPoint:CGPointMake(xd, yd-40) withColor:color lineWidth:1];
                        
                }
                continue;
            }
            
            
            //屏幕里面 由开关控制绘制内容=======================
            //射线
            if(射线开关){
                // 绘制射线
                UIColor *color = model.isAI ? [UIColor colorWithRed:0 green:1 blue:0 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                [DrawHelper drawLineFromPoint:CGPointMake(kWidth/2, 40) toPoint:CGPointMake(xd, yd-40) withColor:color lineWidth:1];
                
            }
            if(追踪开关){
                
                UIColor *color = model.isAI ? [UIColor colorWithRed:0 green:1 blue:0 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                [DrawHelper drawCircleWithCenter:CGPointMake(kWidth/2, kHeight/2) radius:追踪圆圈 borderColor:color lineWidth:1];
            }
            
            if(背景开关){
                //信息背景
                UIColor * 背景颜色 = model.isAI ? [UIColor greenColor] : [DrawHelper colorForKey:model.TeamID];
                [DrawHelper drawLineFromPoint:CGPointMake(xd-40,yd-16) toPoint:CGPointMake(xd+40,yd-16) withColor:背景颜色 lineWidth:20];
                //对标背景
                UIColor * 对标背景颜色 = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
                [DrawHelper drawLineFromPoint:CGPointMake(xd-40,yd-16) toPoint:CGPointMake(xd-25,yd-16) withColor:对标背景颜色 lineWidth:20];
            }
            if (名字开关) {
                //名字
                if (model.PlayerName.length>1) {
                    UIColor * color = [[UIColor whiteColor] colorWithAlphaComponent:1];
                    [DrawHelper drawText:model.PlayerName atPoint:CGPointMake(xd+10 , y-21) withFontSize:10 andColor:color];
                }
                
                
                //对标
                if (model.TeamID > 0) {
                    UIColor * color = [[UIColor redColor] colorWithAlphaComponent:1];
                    NSString * TeamID = [NSString stringWithFormat:@"%d",model.TeamID];
                    [DrawHelper drawText:TeamID atPoint:CGPointMake(xd-30 , y-21) withFontSize:10 andColor:color];
                }
                
            }
            
            if(距离开关 && (int)model.Distance>1){
                //距离
                NSString *str = [NSString stringWithFormat:@"%dm",(int)model.Distance];
                UIColor * color = [[UIColor yellowColor] colorWithAlphaComponent:1];
                [DrawHelper drawText:str atPoint:CGPointMake(xd+20, yd-35) withFontSize:12 andColor:color];
                
            }
            
            if(血条开关){
                //血条直线-----------
                //血条背景
                UIColor *color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
                [DrawHelper drawLineFromPoint:CGPointMake(xd-40,yd-9) toPoint:CGPointMake(xd+40,yd-9) withColor:color lineWidth:3];
                
                //血条
                UIColor *hpcolor = model.isAI ? [UIColor colorWithRed:0 green:0 blue:1 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                [DrawHelper drawLineFromPoint:CGPointMake(xd-40,yd-9) toPoint:CGPointMake(xd-40+0.8*model.Health,yd-9) withColor:hpcolor lineWidth:3];
                
                //血条圆弧-----------
                //背景
                [DrawHelper drawArcWithCenter:CGPointMake(xd-40,yd-9) radius:20 borderColor:color lineWidth:3 arcLength:1];
                //血条
                [DrawHelper drawArcWithCenter:CGPointMake(xd-40,yd-9) radius:20 borderColor:hpcolor lineWidth:3 arcLength:model.Health/100];
                
            }
            
            if (手持武器开关 && model.WeaponName.length>1) {
                NSString *str = [NSString stringWithFormat:@"%@",model.WeaponName?model.WeaponName:@""];
                UIColor *color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
                [DrawHelper drawText:str atPoint:CGPointMake(xd-20, yd-35) withFontSize:10 andColor:color];
            }
            
            if(方框开关){
                for (int i = 0; i < 8; i++) {
                    float x1 = 0.0, y1 = 0.0, x2 = 0.0, y2 = 0.0;
                    switch (i) {
                        case 0: // 左上角横线
                            x1 = x;
                            y1 = y;
                            x2 = x + w / 4;
                            y2 = y;
                            break;
                        case 1: // 右上角横线
                            x1 = x + w;
                            y1 = y;
                            x2 = x + w - w/4;
                            y2 = y;
                            break;
                        case 2: // 左下角横线
                            x1 = x;
                            y1 = y + h;
                            x2 = x + w/4;
                            y2 = y + h;
                            break;
                        case 3: // 右下角横线
                            x1 = x + w;
                            y1 = y + h;
                            x2 = x + w - w/4;
                            y2 = y + h;
                            break;
                        case 4: // 左上侧竖线
                            x1 = x;
                            y1 = y;
                            x2 = x;
                            y2 = y + h / 4;
                            break;
                        case 5: // 右上侧竖线
                            x1 = x + w;
                            y1 = y;
                            x2 = x + w;
                            y2 = y + h / 4;
                            break;
                        case 6: // 左侧底部部竖线
                            x1 = x;
                            y1 = y + h;
                            x2 = x;
                            y2 = y + h - h/4;
                            break;
                        case 7: // 右侧底部部竖线
                            x1 = x + w;
                            y1 = y + h;
                            x2 = x + w;
                            y2 = y + h - h/4;
                            break;
                    }
                    UIColor *color = model.isAI ? [UIColor colorWithRed:0 green:1 blue:0 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                    [DrawHelper drawLineFromPoint:CGPointMake(x1, y1) toPoint:CGPointMake(x2, y2) withColor:color lineWidth:1];
                    
                }
                
            }
            if (骨骼开关) {
                UIColor *color = model.isAI ? [UIColor colorWithRed:0 green:1 blue:0 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                //躯干
                [DrawHelper drawLineFromPoint:CGPointMake(model._0.X, model._0.Y) toPoint:CGPointMake(model._1.X, model._1.Y) withColor:color lineWidth:1];
                
                [DrawHelper drawLineFromPoint:CGPointMake(model._1.X, model._1.Y) toPoint:CGPointMake(model._2.X, model._2.Y) withColor:color lineWidth:1];
                [DrawHelper drawLineFromPoint:CGPointMake(model._2.X, model._2.Y) toPoint:CGPointMake(model._3.X, model._3.Y) withColor:color lineWidth:1];
                [DrawHelper drawLineFromPoint:CGPointMake(model._3.X, model._3.Y) toPoint:CGPointMake(model._4.X, model._4.Y) withColor:color lineWidth:1];
                [DrawHelper drawLineFromPoint:CGPointMake(model._4.X, model._4.Y) toPoint:CGPointMake(model._5.X, model._4.Y) withColor:color lineWidth:1];
                
                //胸-有肩膀-右肘-右手
                [DrawHelper drawLineFromPoint:CGPointMake(model._2.X, model._2.Y) toPoint:CGPointMake(model._6.X, model._6.Y) withColor:color lineWidth:1];
                [DrawHelper drawLineFromPoint:CGPointMake(model._6.X, model._6.Y) toPoint:CGPointMake(model._7.X, model._7.Y) withColor:color lineWidth:1];
                [DrawHelper drawLineFromPoint:CGPointMake(model._7.X, model._7.Y) toPoint:CGPointMake(model._8.X, model._8.Y) withColor:color lineWidth:1];
                //
                //胸-腰-盆骨
                [DrawHelper drawLineFromPoint:CGPointMake(model._2.X, model._2.Y) toPoint:CGPointMake(model._9.X, model._9.Y) withColor:color lineWidth:1];
                [DrawHelper drawLineFromPoint:CGPointMake(model._9.X, model._9.Y) toPoint:CGPointMake(model._10.X, model._10.Y) withColor:color lineWidth:1];
                [DrawHelper drawLineFromPoint:CGPointMake(model._10.X, model._10.Y) toPoint:CGPointMake(model._11.X, model._11.Y) withColor:color lineWidth:1];
                
                //盆骨-左盆骨
                [DrawHelper drawLineFromPoint:CGPointMake(model._5.X, model._5.Y) toPoint:CGPointMake(model._12.X, model._12.Y) withColor:color lineWidth:1];
                //左盆骨-左膝盖
                [DrawHelper drawLineFromPoint:CGPointMake(model._12.X, model._12.Y) toPoint:CGPointMake(model._13.X, model._13.Y) withColor:color lineWidth:1];
                //左膝盖-左脚
                [DrawHelper drawLineFromPoint:CGPointMake(model._13.X, model._13.Y) toPoint:CGPointMake(model._14.X, model._14.Y) withColor:color lineWidth:1];
                
                //盆骨-右盆骨
                [DrawHelper drawLineFromPoint:CGPointMake(model._5.X, model._5.Y) toPoint:CGPointMake(model._15.X, model._15.Y) withColor:color lineWidth:1];
                //右盆骨-右膝盖
                [DrawHelper drawLineFromPoint:CGPointMake(model._15.X, model._15.Y) toPoint:CGPointMake(model._16.X, model._16.Y) withColor:color lineWidth:1];
                //右膝盖-右脚
                [DrawHelper drawLineFromPoint:CGPointMake(model._16.X, model._16.Y) toPoint:CGPointMake(model._17.X, model._17.Y) withColor:color lineWidth:1];
            }
        }
        
        if(物资总开关){
            NSArray*wzArray=[[GameVV factory] getwzData];
            for (NSInteger i = 0; i < wzArray.count; i++){
                PUBGPlayerWZ *mode = wzArray[i];
                UIColor *color;
                //根据物资分类 设置不同颜色
                switch (mode.Fenlei) {
                    case 0:
                        color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
                        break;
                    case 1:
                        color = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
                        break;
                    case 2:
                        color = [UIColor colorWithRed:1 green:0 blue:1 alpha:1];
                        break;
                    case 3:
                        color = [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
                        break;
                    case 4:
                        color = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                        break;
                    case 5:
                        color = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
                        break;
                    case 6:
                        color = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
                        break;
                    case 7:
                        color = [UIColor colorWithRed:1 green:0.5 blue:1 alpha:1];
                        break;
                    case 8:
                        color = [UIColor colorWithRed:0.5 green:1 blue:1 alpha:1];
                        break;
                    case 9:
                        color = [UIColor colorWithRed:1 green:1 blue:0.5 alpha:1];
                        break;
                    case 10:
                        color = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
                        break;
                    case 11:
                        color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
                        break;
                    case 12:
                        color = [UIColor colorWithRed:0.2 green:1 blue:0.5 alpha:1];
                        break;
                    case 13:
                        color = [UIColor colorWithRed:1 green:0.2 blue:0.9 alpha:1];
                        break;
                    case 14:
                        color = [UIColor colorWithRed:0.3 green:0.6 blue:0.2 alpha:1];
                        break;
                    default:
                        color = [UIColor colorWithRed:0.9 green:0.5 blue:0.1 alpha:1];
                        break;
                }
                //绘制
                [DrawHelper drawText:mode.Name atPoint:CGPointMake(mode.WuZhi2D.X , mode.WuZhi2D.Y) withFontSize:10 andColor:color];
            }
        }
        
    }
    
    // 将绘制的内容添加到视图上
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // 将绘制结果显示在视图上，比如将图片添加到UIImageView中
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
}
@end

