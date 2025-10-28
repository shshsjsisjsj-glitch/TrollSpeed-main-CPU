
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <vector>
#include <mach/mach.h>
#include <mach/vm_map.h>
#include <mach-o/dyld.h>
#include <mach-o/getsect.h>
#include <mach-o/dyld_images.h>
#include <sys/sysctl.h>
#include <dlfcn.h>

#import "PUBGTypeHeader.h"

#define kAddrMax 0xFFFFFFFFF

NS_ASSUME_NONNULL_BEGIN
int getProcesses(NSString *Name);
mach_port_t getTask(int pid);
vm_map_offset_t getBaseAddress(mach_port_t task);

bool getGame();
extern uintptr_t Gworld;
extern uintptr_t GName;
extern uintptr_t GBase;
extern mach_port_t task;

extern bool  绘制总开关,过直播开关, 无后座开关,自瞄开关,追踪开关,手雷预警开关,聚点开关,防抖开关;
extern bool  射线开关,骨骼开关,方框开关,距离开关,血条开关,名字开关,背景开关,边缘开关,附近人数开关,手持武器开关;
extern bool  物资总开关,载具开关,药品开关,投掷物开关,枪械开关,配件开关,子弹开关,其他物资开关,高级物资开关,倍镜开关,头盔开关,护甲开关,背包开关,物资调试开关;
extern float 追踪距离;
extern float 追踪圆圈;
extern int 追踪部位;
extern float 自瞄速度;
@interface GameVV : NSObject
- (void)getNSArray;
- (NSMutableArray*)getData;
- (NSMutableArray*)getwzData;
+ (instancetype)factory;
- (void)getBool;

@end

NS_ASSUME_NONNULL_END
