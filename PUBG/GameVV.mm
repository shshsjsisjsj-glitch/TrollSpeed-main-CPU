
#import "GameVV.h"
#include "string"
#import "PUBGTypeHeader.h"
#import "PUBGDataModel.h"
#include <vector>
#include <mach/mach.h>
@interface GameVV()

@property (nonatomic,  assign) FVector2D canvas;
@property (nonatomic,strong) NSMutableArray * 人物缓存;
@property (nonatomic,strong) NSMutableArray * 物资缓存;
@property (nonatomic,strong) NSMutableArray * PlayArray;
@property (nonatomic,strong) NSMutableArray * WZArray;
@end

@implementation GameVV

mach_port_t task;
bool wzkg;
static FMinimalViewInfo POV;
+ (instancetype)factory
{
    static GameVV *fact;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fact = [[GameVV alloc] init];
    });
    return fact;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([UIScreen mainScreen].bounds.size.width<[UIScreen mainScreen].bounds.size.height) {
            _canvas.X = [UIScreen mainScreen].bounds.size.height;
            _canvas.Y = [UIScreen mainScreen].bounds.size.width;
        }else{
            _canvas.X = [UIScreen mainScreen].bounds.size.width;
            _canvas.Y = [UIScreen mainScreen].bounds.size.height;
        }
        
    }
    return self;
}

#pragma mark - 内存读写 声明

extern "C" kern_return_t
mach_vm_region_recurse(
                       vm_map_t                 map,
                       mach_vm_address_t        *address,
                       mach_vm_size_t           *size,
                       uint32_t                 *depth,
                       vm_region_recurse_info_t info,
                       mach_msg_type_number_t   *infoCnt);

extern "C" kern_return_t
mach_vm_read_overwrite(
                       vm_map_t           target_task,
                       mach_vm_address_t  address,
                       mach_vm_size_t     size,
                       mach_vm_address_t  data,
                       mach_vm_size_t     *outsize);

extern "C" kern_return_t
mach_vm_write(
              vm_map_t                          map,
              mach_vm_address_t                 address,
              pointer_t                         data,
              __unused mach_msg_type_number_t   size);
#pragma mark - 坐标相关=============
int Gworld_address = 0xBF4DE58;
int GName_address = 0xBBD0BC8;
int Level_address = 0x90;
int TeamID_address = 0xa80;
int myTeam_address = 0x9c0;
int HealthMax_address = 0xe00;
int Health_address = 0xdf8;
int VehicleCommonComponent_address = 0xa40;
int VehicleHPMax_address = 0x1bc;
int VehicleHP_address = 0x1c0;
int NetDrive_address = 0x98;
int ServerConnection_address = 0x88;
int PlayerController_address = 0x30;
int mySelf_address = 0x548;
int PlayerCameraManager_address = 0x5d0;
int POV_address = 0x1130;
int bDead_address = 0xe60;
int IsAi_address = 0xa9c;
int PlayName_address = 0xa00;
int RootComponent_address = 0x268;
int pawn_address = 0x548;
int WeaponManagerComponent_address = 0x2be0;
int CachedCurUseWeapon_address = 0x368;
int ShootWeaponComponent_address = 0x12f8;
int OwnerShootWeapon_address = 0x2f8;
int ShootWeaponEntityComp_address = 0x1310;
int 无后1 = 0x17c0;
int 镜防1 = 0x18f8;
int 枪防1 = 0x18d8;
int 瞬击1 = 0x1314;
int LastUpdateStatusKeyList_address = 0x2e18;
int EquipWeapon_address = 0x20;
int RepWeaponID1 = 0xab0;
int Mesh_address = 0x5c8;
int MeshTrans1 = 0x1c8;
int boneArray1 = 0x720;
int isFire1 = 0x1fb8;
int 视角追1 = 0x5e0;
int 骨骼1 = 0x19c;
int 聚点1 = 0x1814;
int CurrentWeaponReplicated1 = 0x608;
int BulletFireSpeed1 = 0x1314;
int WeaponID1 = 0x118;
int Character1 = 0x558;
int openghtsight1 = 0x1518;
int bIsWeaponFiring1 = 0x1fb8;
int VelocitySafty1 = 0xee4;
int ControlRotation1 = 0x570;
int povaddr1 = 0x5b0;
int FOV1 = 0x30;
#pragma mark - 读取进程pid
int getProcesses(NSString *Name)
{
    size_t length = 0;
    static const int mib[] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    int err = sysctl((int *)mib, (sizeof(mib) / sizeof(*mib)) - 1, NULL, &length, NULL, 0);
    if (err == -1) {
        err = errno;
    }
    
    if (err == 0) {
        struct kinfo_proc *procBuffer = (struct kinfo_proc *)malloc(length);
        if(procBuffer == NULL) {
            return -1;
        }
        
        sysctl( (int *)mib, (sizeof(mib) / sizeof(*mib)) - 1, procBuffer, &length, NULL, 0);
        
        int count = (int)length / sizeof(struct kinfo_proc);
        for (int i = 0; i < count; ++i) {
            const char *procname = procBuffer[i].kp_proc.p_comm;
            if (strstr(procname, Name.UTF8String)) {
                return procBuffer[i].kp_proc.p_pid;
            }
        }
    }
    return -1;
}
#pragma mark - 读取进程Task
mach_port_t getTask(int pid)
{
    
    task_for_pid(mach_task_self(), pid, &task);
    return task;
}
#pragma mark - 读取进程BaseAddress
vm_map_offset_t getBaseAddress(mach_port_t task)
{
    vm_map_offset_t vmoffset = 0;
    vm_map_size_t vmsize = 0;
    uint32_t nesting_depth = 0;
    struct vm_region_submap_info_64 vbr;
    mach_msg_type_number_t vbrcount = 16;
    kern_return_t kret = mach_vm_region_recurse(task, &vmoffset, &vmsize, &nesting_depth, (vm_region_recurse_info_t)&vbr, &vbrcount);
    if (kret == KERN_SUCCESS) {
        NSLog(@"[yiming] %s : %016llX %lld bytes.", __func__, vmoffset, vmsize);
    } else {
        NSLog(@"[yiming] %s : FAIL.", __func__);
    }
    
    return vmoffset;
}
#pragma mark - 内存封装============
static BOOL isValidAddress(uintptr_t address)
{
    if (address && address > 0x100000000 && address < kAddrMax) {
        return YES;
    }
    return NO;
}
static BOOL readMemory(uintptr_t address, size_t size ,void *buffer )
{
    mach_vm_size_t otu_size = 0;
    kern_return_t error = mach_vm_read_overwrite((vm_map_t)task, (mach_vm_address_t)address, (mach_vm_size_t)size, (mach_vm_address_t)buffer, &otu_size);
    if (error != KERN_SUCCESS || otu_size != size) {
        return NO;
    }
    return YES;
}
static BOOL writeMemory(uintptr_t address, int size ,void *buffer )
{
    if (!isValidAddress(address)) return NO;
    
    kern_return_t error = mach_vm_write(task, (mach_vm_address_t)address, (vm_offset_t)buffer, (mach_msg_type_number_t)size);
    if(error != KERN_SUCCESS) {
        return NO;
    }
    
    return YES;
}
static kern_return_t read_mem(vm_map_offset_t address, mach_vm_size_t size, void *buffer)
{
    kern_return_t kert = mach_vm_read_overwrite(task, address, size, (mach_vm_address_t)(buffer), &size); // AAR in Kernel
    
    
    return kert;
}
static bool Read(long ptr, int length, void *buffer){
   if(ptr <= 0 || ptr > 100000000000 || isnan(ptr))return false;
   vm_size_t size = 0;
   kern_return_t error = vm_read_overwrite(task, (vm_address_t)ptr, length, (vm_address_t)buffer, &size);
   if(error != KERN_SUCCESS || size != length) {
      return false;
   }
   return true;
}
template<typename T> T Read(long address)
{
    T data;
    Read(address, sizeof(T), reinterpret_cast<void *>(&data));
    return data;
}


#pragma mark - 坐标转换===============
static FVector3D minusTheVector(FVector3D first, FVector3D second)
{
    static FVector3D ret;
    ret.X = first.X - second.X;
    ret.Y = first.Y - second.Y;
    ret.Z = first.Z - second.Z;
    return ret;
}

static float theDot(FVector3D v1, FVector3D v2)
{
    return v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;
}

static float getDistance(FVector3D a, FVector3D b)
{
    static FVector3D ret;
    ret.X = a.X - b.X;
    ret.Y = a.Y - b.Y;
    ret.Z = a.Z - b.Z;
    return sqrt(ret.X * ret.X + ret.Y * ret.Y + ret.Z * ret.Z);
}

static D3DXMATRIX toMATRIX(FRotator rot)
{
    static float RadPitch, RadYaw, RadRoll, SP, CP, SY, CY, SR, CR;
    D3DXMATRIX M;
    
    RadPitch = rot.Pitch * M_PI / 180;
    RadYaw = rot.Yaw * M_PI / 180;
    RadRoll = rot.Roll * M_PI / 180;
    
    SP = sin(RadPitch);
    CP = cos(RadPitch);
    SY = sin(RadYaw);
    CY = cos(RadYaw);
    SR = sin(RadRoll);
    CR = cos(RadRoll);
    
    M._11 = CP * CY;
    M._12 = CP * SY;
    M._13 = SP;
    M._14 = 0.f;
    
    M._21 = SR * SP * CY - CR * SY;
    M._22 = SR * SP * SY + CR * CY;
    M._23 = -SR * CP;
    M._24 = 0.f;
    
    M._31 = -(CR * SP * CY + SR * SY);
    M._32 = CY * SR - CR * SP * SY;
    M._33 = CR * CP;
    M._34 = 0.f;
    
    M._41 = 0.f;
    M._42 = 0.f;
    M._43 = 0.f;
    M._44 = 1.f;
    
    return M;
}


#pragma mark - 世界坐标转屏幕2D坐标
static void getTheAxes(FRotator rot, FVector3D *x, FVector3D *y, FVector3D *z){
    D3DXMATRIX M = toMATRIX(rot);
    
    x->X = M._11;
    x->Y = M._12;
    x->Z = M._13;
    
    y->X = M._21;
    y->Y = M._22;
    y->Z = M._23;
    
    z->X = M._31;
    z->Y = M._32;
    z->Z = M._33;
}

static FVector2D worldToScreen(FVector3D worldLocation, FMinimalViewInfo camViewInfo, FVector2D canvas){
    static FVector2D Screenlocation;
    
    FVector3D vAxisX, vAxisY, vAxisZ;
    getTheAxes(camViewInfo.Rotation, &vAxisX, &vAxisY, &vAxisZ);
    
    FVector3D vDelta = minusTheVector(worldLocation, camViewInfo.Location);
    FVector3D vTransformed;
    
    vTransformed.X = theDot(vDelta, vAxisY);
    vTransformed.Y = theDot(vDelta, vAxisZ);
    vTransformed.Z = theDot(vDelta, vAxisX);
    
    if (vTransformed.Z < 1.0f) {
        vTransformed.Z = 1.0f;
    }
    
    float FOV = camViewInfo.FOV;
    float ScreenCenterX = canvas.X / 2;
    float ScreenCenterY = canvas.Y / 2;
    float BonesX=ScreenCenterX + vTransformed.X * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.Z;
    float BonesY=ScreenCenterY - vTransformed.Y * (ScreenCenterX / tanf(FOV * (float)M_PI / 360.f)) / vTransformed.Z;
    
    
    Screenlocation.X = BonesX;
    Screenlocation.Y = BonesY;
    
    return Screenlocation;
}

static FVectorRect worldToScreenForRect(FVector3D worldLocation, FMinimalViewInfo camViewInfo, FVector2D canvas)
{
    FVectorRect rect;
    
    FVector3D Pos2 = worldLocation;
    Pos2.Z += 90.f;
    
    
    FVector2D CalcPos = worldToScreen(worldLocation ,camViewInfo,canvas);
    
    FVector2D CalcPos2 = worldToScreen(Pos2 ,camViewInfo,canvas);
    
    rect.H = CalcPos.Y - CalcPos2.Y;
    rect.W = rect.H / 2.5;
    rect.X = CalcPos.X - rect.W;
    rect.Y = CalcPos2.Y;
    rect.W = rect.W * 2;
    rect.H = rect.H * 2;
    
    return rect;
}
#pragma mark - 游戏数据

static NSString* getFNameFromID(uintptr_t gnamePtr, int classId){
    static char g_nameBuf[128];
    if (classId > 0 && classId < 2000000) {
        int page = classId / 16384;
        int index = classId % 16384;
        uintptr_t pageAddr = Read<uintptr_t>(gnamePtr + page * sizeof(uintptr_t));
        uintptr_t nameAddr = Read<uintptr_t>(pageAddr + index * sizeof(uintptr_t)) + 0xE;
        
        readMemory(nameAddr, sizeof(g_nameBuf), g_nameBuf);
        return [NSString stringWithUTF8String:g_nameBuf];
    }
    return nil;
}

static NSString* getPlayerName(uintptr_t player){
    char Name[128];
    unsigned short buf16[16] = {0};
    uintptr_t PlayerName = Read<uintptr_t>(player + PlayName_address);
    if (!isValidAddress(PlayerName)) return nil;
    if (!readMemory(PlayerName, 28, buf16)) return nil;
    
    unsigned short *tempbuf16 = buf16;
    char *tempbuf8 = Name;
    char *buf8 = tempbuf8 + 32;
    for (int i = 0; i < 28 && tempbuf8 + 3 < buf8; i++) {
        if (*tempbuf16 <= 0x007F) {
            *tempbuf8++ = (char) *tempbuf16;
        } else if (*tempbuf16 <= 0x07FF) {
            *tempbuf8++ = (*tempbuf16 >> 6) | 0xC0;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        } else {
            *tempbuf8++ = (*tempbuf16 >> 12) | 0xE0;
            *tempbuf8++ = ((*tempbuf16 >> 6) & 0x3F) | 0x80;
            *tempbuf8++ = (*tempbuf16 & 0x3F) | 0x80;
        }
        tempbuf16++;
    }
    *tempbuf8 = '\0';
    
    return [NSString stringWithUTF8String:Name];
}

#pragma mark - 玩家骨骼相关=========
static D3DXMATRIX toMatrixWithScale(FVector4D rotation, FVector3D translation, FVector3D scale3D){
    static D3DXMATRIX ret;
    
    float x2, y2, z2, xx2, yy2, zz2, yz2, wx2, xy2, wz2, xz2, wy2 = 0.f;
    ret._41 = translation.X;
    ret._42 = translation.Y;
    ret._43 = translation.Z;
    
    x2 = rotation.X * 2;
    y2 = rotation.Y * 2;
    z2 = rotation.Z * 2;
    
    xx2 = rotation.X * x2;
    yy2 = rotation.Y * y2;
    zz2 = rotation.Z * z2;
    
    ret._11 = (1 - (yy2 + zz2)) * scale3D.X;
    ret._22 = (1 - (xx2 + zz2)) * scale3D.Y;
    ret._33 = (1 - (xx2 + yy2)) * scale3D.Z;
    
    yz2 = rotation.Y * z2;
    wx2 = rotation.W * x2;
    ret._32 = (yz2 - wx2) * scale3D.Z;
    ret._23 = (yz2 + wx2) * scale3D.Y;
    
    xy2 = rotation.X * y2;
    wz2 = rotation.W * z2;
    ret._21 = (xy2 - wz2) * scale3D.Y;
    ret._12 = (xy2 + wz2) * scale3D.X;
    
    xz2 = rotation.X * z2;
    wy2 = rotation.W * y2;
    ret._31 = (xz2 + wy2) * scale3D.Z;
    ret._13 = (xz2 - wy2) * scale3D.X;
    
    ret._14 = 0.f;
    ret._24 = 0.f;
    ret._34 = 0.f;
    ret._44 = 1.f;
    
    return ret;
}

static D3DXMATRIX matrixMultiplication(D3DXMATRIX M1, D3DXMATRIX M2)
{
    static D3DXMATRIX ret;
    ret._11 = M1._11 * M2._11 + M1._12 * M2._21 + M1._13 * M2._31 + M1._14 * M2._41;
    ret._12 = M1._11 * M2._12 + M1._12 * M2._22 + M1._13 * M2._32 + M1._14 * M2._42;
    ret._13 = M1._11 * M2._13 + M1._12 * M2._23 + M1._13 * M2._33 + M1._14 * M2._43;
    ret._14 = M1._11 * M2._14 + M1._12 * M2._24 + M1._13 * M2._34 + M1._14 * M2._44;
    ret._21 = M1._21 * M2._11 + M1._22 * M2._21 + M1._23 * M2._31 + M1._24 * M2._41;
    ret._22 = M1._21 * M2._12 + M1._22 * M2._22 + M1._23 * M2._32 + M1._24 * M2._42;
    ret._23 = M1._21 * M2._13 + M1._22 * M2._23 + M1._23 * M2._33 + M1._24 * M2._43;
    ret._24 = M1._21 * M2._14 + M1._22 * M2._24 + M1._23 * M2._34 + M1._24 * M2._44;
    ret._31 = M1._31 * M2._11 + M1._32 * M2._21 + M1._33 * M2._31 + M1._34 * M2._41;
    ret._32 = M1._31 * M2._12 + M1._32 * M2._22 + M1._33 * M2._32 + M1._34 * M2._42;
    ret._33 = M1._31 * M2._13 + M1._32 * M2._23 + M1._33 * M2._33 + M1._34 * M2._43;
    ret._34 = M1._31 * M2._14 + M1._32 * M2._24 + M1._33 * M2._34 + M1._34 * M2._44;
    ret._41 = M1._41 * M2._11 + M1._42 * M2._21 + M1._43 * M2._31 + M1._44 * M2._41;
    ret._42 = M1._41 * M2._12 + M1._42 * M2._22 + M1._43 * M2._32 + M1._44 * M2._42;
    ret._43 = M1._41 * M2._13 + M1._42 * M2._23 + M1._43 * M2._33 + M1._44 * M2._43;
    ret._44 = M1._41 * M2._14 + M1._42 * M2._24 + M1._43 * M2._34 + M1._44 * M2._44;
    return ret;
}

static FTransform getMatrixConversion(uintptr_t address){
    static FTransform ret;
    readMemory(address, sizeof(float), &ret.Rotation.X);
    readMemory(address+4, sizeof(float), &ret.Rotation.Y);
    readMemory(address+8, sizeof(float), &ret.Rotation.Z);
    readMemory(address+12, sizeof(float), &ret.Rotation.W);
    
    readMemory(address+16, sizeof(float), &ret.Translation.X);
    readMemory(address+20, sizeof(float), &ret.Translation.Y);
    readMemory(address+24, sizeof(float), &ret.Translation.Z);
    
    readMemory(address+32, sizeof(float), &ret.Scale3D.X);
    readMemory(address+36, sizeof(float), &ret.Scale3D.Y);
    readMemory(address+40, sizeof(float), &ret.Scale3D.Z);
    
    return ret;
}

static FVector3D getBoneWithRotation(uintptr_t mesh, int Id, FTransform publicObj){
    static FTransform BoneMatrix;
    static FVector3D output = {0, 0, 0};
    
    uintptr_t addr;  //boneArray
    if (!readMemory(mesh + boneArray1, sizeof(uintptr_t), &addr)) {
        return output;
    }
    BoneMatrix = getMatrixConversion(addr + Id * 0x30);
    
    D3DXMATRIX LocalSkeletonMatrix =toMatrixWithScale(BoneMatrix.Rotation, BoneMatrix.Translation, BoneMatrix.Scale3D);
    
    D3DXMATRIX PartTotheWorld = toMatrixWithScale(publicObj.Rotation, publicObj.Translation, publicObj.Scale3D);
    
    D3DXMATRIX NewMatrix = matrixMultiplication(LocalSkeletonMatrix, PartTotheWorld);
    
    FVector3D BoneCoordinates;
    BoneCoordinates.X = NewMatrix._41;
    BoneCoordinates.Y = NewMatrix._42;
    BoneCoordinates.Z = NewMatrix._43;
    
    return BoneCoordinates;
}

static FVector3D getRelativeLocation(uintptr_t actor){
    uintptr_t RootComponent = Read<uintptr_t>(actor + RootComponent_address);
    static FVector3D value;
    readMemory(RootComponent + 0x1c0, sizeof(FVector3D), &value);
    return value;
}


static FMinimalViewInfo getPOV(uintptr_t povAddr){
    FMinimalViewInfo POV;
    POV.Location.X = Read<float>(povAddr);
    POV.Location.Y = Read<float>(povAddr + 4);
    POV.Location.Z = Read<float>(povAddr + 4 + 4);
    
    POV.Rotation.Pitch = Read<float>(povAddr + 0x18);
    POV.Rotation.Yaw = Read<float>(povAddr + 0x18 + 4);
    POV.Rotation.Roll = Read<float>(povAddr + 0x18 + 4 + 4);
    POV.FOV = Read<float>(povAddr + 0x30);
    
    return POV;
}
#pragma mark - 追踪函数
- (BOOL)getInsideFov:(FVector2D)bone radius:(float)radius
{
    FVector2D Cenpoint;
    Cenpoint.X = bone.X - (self.canvas.X / 2);
    Cenpoint.Y = bone.Y - (self.canvas.Y / 2);
    if (Cenpoint.X * Cenpoint.X + Cenpoint.Y * Cenpoint.Y <= radius * radius) {
        return YES;
    }
    return NO;
}
- (int)getCenterOffsetForVector:(FVector2D)point
{
    return sqrt(pow(point.X - self.canvas.X/2, 2.0) + pow(point.Y - self.canvas.Y/2, 2.0));
}
- (FRotator)calcAngle:(FVector3D)aimPos
{
    FRotator rot;
    rot.Yaw = ((float)(atan2f(aimPos.Y, aimPos.X)) * (float)(180.f / M_PI));
    rot.Pitch = ((float)(atan2f(aimPos.Z,
                                sqrtf(aimPos.X * aimPos.X +
                                      aimPos.Y * aimPos.Y +
                                      aimPos.Z * aimPos.Z))) * (float)(180.f / M_PI));
    rot.Roll = 0.f;
    return rot;
}
- (FRotator)clamp:(FRotator)Rotation
{
    if (Rotation.Yaw > 180.f) {
        Rotation.Yaw -= 360.f;
    } else if (Rotation.Yaw < -180.f) {
        Rotation.Yaw += 360.f;
    }
    
    if (Rotation.Pitch > 180.f) {
        Rotation.Pitch -= 360.f;
    } else if (Rotation.Pitch < -180.f) {
        Rotation.Pitch += 360.f;
    }
    
    if (Rotation.Pitch < -89.f) {
        Rotation.Pitch = -89.f;
    } else if (Rotation.Pitch > 89.f) {
        Rotation.Pitch = 89.f;
    }
    
    Rotation.Roll = 0.f;
    
    return Rotation;
}
#pragma mark - 读取游戏数据-OC
bool  绘制总开关,过直播开关, 无后座开关,自瞄开关,追踪开关,手雷预警开关,聚点开关,防抖开关;
bool  射线开关,骨骼开关,方框开关,距离开关,血条开关,名字开关,背景开关,边缘开关,附近人数开关,手持武器开关;
bool  物资总开关,载具开关,药品开关,投掷物开关,枪械开关,配件开关,子弹开关,其他物资开关,高级物资开关,倍镜开关,头盔开关,护甲开关,背包开关,物资调试开关;
float 追踪距离;
float 追踪圆圈;
int 追踪部位;
float 自瞄速度;

uintptr_t Gworld;
uintptr_t GName;
uintptr_t GBase;
//读取进程
bool getGame(){
    NSString*gameName = @"ShadowTrackerExt";
    pid_t gamePid = getProcesses(gameName);
    if (gamePid != -1) {
        task = getTask(gamePid);
        if (task) {
            GBase = getBaseAddress(task);
            if (GBase) {
                return YES;
            }
        }
    }
    
    return NO;
}
//读取玩家数组
NSMutableDictionary *userDefaults;
- (void)getBool{
    userDefaults = [[NSDictionary dictionaryWithContentsOfFile:USER_DEFAULTS_PATH] mutableCopy] ?: [NSMutableDictionary dictionary];
    //因为滑条储存的是0~1 需要乘于相应倍数
    追踪距离 = 500 * [[userDefaults objectForKey:@"滑条0"] floatValue];
    追踪圆圈 = 200 * [[userDefaults objectForKey:@"滑条1"] floatValue];
    自瞄速度 = 100 * [[userDefaults objectForKey:@"滑条2"] floatValue];
    
    绘制总开关 = [[userDefaults objectForKey: @"开关0"] boolValue];
    附近人数开关 = [[userDefaults objectForKey:@"开关1"] boolValue];
    射线开关 = [[userDefaults objectForKey: @"开关2"] boolValue];
    方框开关 = [[userDefaults objectForKey: @"开关3"] boolValue];
    名字开关 = [[userDefaults objectForKey: @"开关4"] boolValue];
    距离开关 = [[userDefaults objectForKey: @"开关5"] boolValue];
    血条开关 = [[userDefaults objectForKey: @"开关6"] boolValue];
    骨骼开关 = [[userDefaults objectForKey: @"开关7"] boolValue];
    背景开关 = [[userDefaults objectForKey: @"开关8"] boolValue];
    手持武器开关 = [[userDefaults objectForKey: @"开关9"] boolValue];
   
    物资总开关 = [[userDefaults objectForKey: @"开关10"] boolValue];
    载具开关 = [[userDefaults objectForKey: @"开关11"] boolValue];
    药品开关 = [[userDefaults objectForKey: @"开关12"] boolValue];
    投掷物开关 = [[userDefaults objectForKey: @"开关13"] boolValue];
    枪械开关 = [[userDefaults objectForKey: @"开关14"] boolValue];
    配件开关 = [[userDefaults objectForKey: @"开关15"] boolValue];
    倍镜开关 = [[userDefaults objectForKey: @"开关16"] boolValue];
    头盔开关 = [[userDefaults objectForKey: @"开关17"] boolValue];
    护甲开关 = [[userDefaults objectForKey: @"开关18"] boolValue];
    背包开关 = [[userDefaults objectForKey: @"开关19"] boolValue];
    高级物资开关 = [[userDefaults objectForKey: @"开关20"] boolValue];
    子弹开关 = [[userDefaults objectForKey: @"开关21"] boolValue];
    其他物资开关 = [[userDefaults objectForKey: @"开关22"] boolValue];
    物资调试开关 = [[userDefaults objectForKey: @"开关23"] boolValue];
    无后座开关 = [[userDefaults objectForKey: @"开关24"] boolValue];
    聚点开关 = [[userDefaults objectForKey: @"开关25"] boolValue];
    防抖开关 = [[userDefaults objectForKey: @"开关26"] boolValue];
    
    
}

- (void)getNSArray {
    //获取数据基础字典 可以降低到2秒一次 避免绘制函数高频读取不必要固定数据消耗内存
    self.人物缓存 = @[].mutableCopy;
    self.物资缓存 = @[].mutableCopy;
    Gworld = Read<uintptr_t>(GBase + Gworld_address);
    GName = Read<uintptr_t>(GBase + GName_address);
    const float hpValues[] = {100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200, 210, 220};
    const int hpValueCount = sizeof(hpValues) / sizeof(float);
    // 获取视角信息
    uintptr_t NetDriver = Read<uintptr_t>(Gworld + NetDrive_address);
    
    if (!isValidAddress(NetDriver))return;
    uintptr_t ServerConnection = Read<uintptr_t>(NetDriver + ServerConnection_address);
    
    if (!isValidAddress(ServerConnection))return;
    uintptr_t PlayerController = Read<uintptr_t>(ServerConnection + PlayerController_address);
    
    if (!isValidAddress(PlayerController))return;
    uintptr_t PlayerCameraManager = Read<uintptr_t>(PlayerController + PlayerCameraManager_address);
   
    if (!isValidAddress(PlayerCameraManager))return;
    uintptr_t mySelf = Read<uintptr_t>(PlayerController + mySelf_address);
    
    if (!isValidAddress(mySelf))return;
    int myTeam = Read<int>(PlayerController + myTeam_address);
   
    uint64_t level = Read<uintptr_t>(Gworld + Level_address);
    uint64_t actorArray = Read<uintptr_t>(level + 0xA0);
    
    int actorCount = Read<int>(level + 0xA8);
    
    for (int i = 0; i < actorCount; i++) {
        uintptr_t player = Read<uintptr_t>(actorArray + i * 8);
        int FNameID = Read<int>(player + 0x18);
        NSString* ClassName = getFNameFromID(GName, FNameID);
        
        //不包含PlayerPawn的都是物质
        if (![ClassName containsString:@"PlayerPawn"] && ClassName.length >5) {
            
            if(物资总开关){
                static NSString*wzName=nil;//声明函数内全局变量
                PUBGPlayerWZ *model=[[PUBGPlayerWZ alloc] init];
                if (物资调试开关) {
                    model.Name = ClassName;//调试模式下 直接吧模型名字添加到物资名字进行绘制 方便自己识别记住名字登记
                    model.Player = player;//储存物资编号
                    model.Fenlei = 99;
                    [self.物资缓存 addObject:model];
                    continue;//添加会记得跳出本次匹配 避免执行后面的if
                }else{
                    //优先吧最常见的 的东西 最长开的东西放在前面 当多个开关开启时 因为物资都在附近10米左右 避免先进行无效物资匹配
                    if (投掷物开关 || 手雷预警开关) {
                        //判断字符串包含 手雷 闪光 获取 后期铝热蛋等自己调试模式添加
                        if ([ClassName containsString:@"Grenade"]){
                            model.Name=@"雷";//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            model.Fenlei=0;
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                        if ([ClassName containsString:@"Fire"]){
                            model.Name=@"火";//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            model.Fenlei=0;
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                        if ([ClassName containsString:@"Burn"]){
                            model.Name=@"闪";//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            model.Fenlei=0;
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                        
                    }
                    if (高级物资开关 ) {
                        wzName=[self reName:ClassName ID:8];
                        if(wzName){
                            model.Fenlei=8;
                            model.Name=[self reName:ClassName ID:8];//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (药品开关 ) {
                        wzName=[self reName:ClassName ID:2];
                        if(wzName){
                            model.Fenlei=2;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (枪械开关 ) {
                        wzName=[self reName:ClassName ID:4];
                        if(wzName){
                            model.Fenlei=4;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (载具开关 ) {
                        wzName=[self reName:ClassName ID:1];
                        if(wzName){
                            model.Fenlei=1;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                            
                        }
                    }
                    if (配件开关 ) {
                        wzName=[self reName:ClassName ID:5];
                        if(wzName){
                            model.Fenlei=5;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (倍镜开关 ) {
                        wzName=[self reName:ClassName ID:9];
                        if(wzName){
                            model.Fenlei=9;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (头盔开关 ) {
                        wzName=[self reName:ClassName ID:10];
                        if(wzName){
                            model.Fenlei=10;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (护甲开关 ) {
                        wzName=[self reName:ClassName ID:11];
                        if(wzName){
                            model.Fenlei=11;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (背包开关 ) {
                        wzName=[self reName:ClassName ID:12];
                        if(wzName){
                            model.Fenlei=12;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (子弹开关 ) {
                        wzName=[self reName:ClassName ID:6];
                        if(wzName){
                            model.Fenlei=6;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                    if (其他物资开关 ) {
                        wzName=[self reName:ClassName ID:7];
                        if(wzName){
                            model.Fenlei=7;
                            model.Name=wzName;//储存查询到的真正名字字符串
                            model.Player=player;//储存物资编号
                            [self.物资缓存 addObject:model];//匹配到就添加到数组
                            continue;//添加会记得跳出本次匹配 避免执行后面的if
                        }
                    }
                   
                }
            }
            
        }else{
            //读取玩家基础固定数据
            float hpmax = Read<float>(player + HealthMax_address);
            for (int j = 0; j < hpValueCount; j++) {
                if (hpmax == hpValues[j]) {
                    //初始化模型
                    PUBGPlayerModel *model=[[PUBGPlayerModel alloc] init];
                    //死亡判断
                    bool bDead = Read<bool>(player + bDead_address) & 1;
                    if (bDead) continue;
                    //排除自己
                    if (player == mySelf) continue;
                    //获取对标
                    model.TeamID = Read<int>(player + TeamID_address);
                    //排除队友
                    if (model.TeamID == myTeam) continue;
                    //人机判断
                    model.isAI = Read<int>(player + IsAi_address) != 0;
                    
                    //读取储存player
                    model.Player = player;
                    //存储玩家数组
                    [self.人物缓存 addObject:model];
                    
                }
                
            }
            
        }
        
    }
    
   
    
}
//读取玩家
- (NSMutableArray*)getData {
    // 初始化玩家字典
    if (!绘制总开关)return nil;
    //初始化骨骼关节点
    static int Bones[18] = {6,5,4,3,2,1,12,13,14,34,35,36,56,57,58,60,61,62};
    static FVector2D Bones_Pos[18];
    self.PlayArray = @[].mutableCopy;
    
    // 获取视角信息
    uintptr_t NetDriver = Read<uintptr_t>(Gworld + NetDrive_address);
    if (!isValidAddress(NetDriver))return self.人物缓存;
    uintptr_t ServerConnection = Read<uintptr_t>(NetDriver + ServerConnection_address);
    if (!isValidAddress(ServerConnection))return self.人物缓存;
    uintptr_t PlayerController = Read<uintptr_t>(ServerConnection + PlayerController_address);
    if (!isValidAddress(PlayerController))return self.人物缓存;
    uintptr_t PlayerCameraManager = Read<uintptr_t>(PlayerController + PlayerCameraManager_address);
    if (!isValidAddress(PlayerCameraManager))return self.人物缓存;
    //POV信息
    readMemory(PlayerCameraManager + POV_address+ 0x10, sizeof(FMinimalViewInfo), &POV);
    long povaddr = PlayerCameraManager + povaddr1 + 0x10;
    POV.FOV = Read<float>(povaddr + FOV1);
    
    if(无后座开关 || 追踪开关){
        //无后坐武器相关
        uintptr_t selflocalPlayerbase = Read<uintptr_t>(PlayerController + pawn_address);
        uintptr_t WeaponManagerComponent =Read<uintptr_t>(selflocalPlayerbase + WeaponManagerComponent_address);
        uintptr_t cachedCurUseWeapon =Read<uintptr_t>(WeaponManagerComponent + CachedCurUseWeapon_address);
        uintptr_t shootWeaponComponent =Read<uintptr_t>(cachedCurUseWeapon + ShootWeaponComponent_address);
        uintptr_t ownerShootWeapon =Read<uintptr_t>(shootWeaponComponent + OwnerShootWeapon_address);
        uintptr_t ShootWeaponEntityComp=Read<uintptr_t>(ownerShootWeapon + ShootWeaponEntityComp_address);
        if(无后座开关){
            float RecoilKickADS = 0.1;
            writeMemory(ShootWeaponEntityComp + 无后1, sizeof(float), &RecoilKickADS);
        }
        if(聚点开关){
            float 聚点散布 = 0.1;
            writeMemory(ShootWeaponEntityComp + 聚点1, sizeof(float), &聚点散布);
        }
    }
    
    //读取玩家高频更新数据数据
    for (PUBGPlayerModel *model in self.人物缓存) {
        //默认为NO 屏幕外面
        model.isPm=NO;
        //读取玩家地址
        uintptr_t player = model.Player;
        if (!isValidAddress(player)){
            continue;
        }
        //判断死亡
        bool bDead = Read<bool>(player + bDead_address) & 1;
        if (bDead) {
            continue;
        }
        //读取血量
        model.Health = Read<float>(player + Health_address) / Read<float>(player + HealthMax_address) * 100;
        // 计算距离
        FVector3D WorldLocation = getRelativeLocation(player);
        model.Distance = getDistance(WorldLocation, POV.Location) / 100;
        if (model.Distance<0 || model.Distance>500 || WorldLocation.X<0 || WorldLocation.Y<0) continue;
        model.isAI = Read<int>(player + IsAi_address) != 0;
        //读取储存名字
        model.PlayerName = getPlayerName(player);
        //地图3D转屏幕2D
        FVector2D PM2D = worldToScreen(WorldLocation, POV, self.canvas);
        //玩家方框
        model.rect=worldToScreenForRect(WorldLocation, POV, self.canvas);
        //绘制屏幕内
        if (PM2D.X>0 && PM2D.X<self.canvas.X && PM2D.Y>0 &&PM2D.Y<self.canvas.Y) {
            //屏幕内 读取绘制数据
            model.isPm=YES;
            uintptr_t Mesh = Read<uintptr_t>(player + Mesh_address);
            FTransform RelativeScale3D = getMatrixConversion(Mesh + 0x1a4 + 0xc);
            // 计算骨骼位置
            if (骨骼开关) {
                for (int j = 0; j < 18; j++) {
                    FVector3D boneWorldLocation = getBoneWithRotation(Mesh, Bones[j], RelativeScale3D);
                    Bones_Pos[j] = worldToScreen(boneWorldLocation, POV, self.canvas);
                }
                //循环完毕 骨骼点储存到玩家模型
                //循环完毕 骨骼点储存到玩家模型
                model._0 = Bones_Pos[0];
                model._1 = Bones_Pos[1];
                model._2 = Bones_Pos[2];
                model._3 = Bones_Pos[3];
                model._4 = Bones_Pos[4];
                model._5 = Bones_Pos[5];
                model._6 = Bones_Pos[6];
                model._7 = Bones_Pos[7];
                model._8 = Bones_Pos[8];
                model._9 = Bones_Pos[9];
                model._10 = Bones_Pos[10];
                model._11 = Bones_Pos[11];
                model._12 = Bones_Pos[12];
                model._13 = Bones_Pos[13];
                model._14 = Bones_Pos[14];
                model._15 = Bones_Pos[15];
                model._16 = Bones_Pos[16];
                model._17 = Bones_Pos[17];
                
            }
            if (手持武器开关) {
                int WeaponId = 0;
                uintptr_t WeaponManagerComponent =Read<uintptr_t>(player+ WeaponManagerComponent_address);
                uintptr_t CurrentWeaponReplicated = Read<uintptr_t>(WeaponManagerComponent+CurrentWeaponReplicated1);
                WeaponId= Read<int>(CurrentWeaponReplicated+RepWeaponID1);
                model.WeaponName=[self souchistr:WeaponId];
            }
            if (追踪开关) {
                FVector3D AimbotWorldLocation = getBoneWithRotation(Mesh, 追踪部位, RelativeScale3D);
                FVector2D AimbotScreenLocation = worldToScreen(AimbotWorldLocation, POV, self.canvas);
                float markDistance = self.canvas.X;
                CGPoint markScreenPos = CGPointMake(self.canvas.X/2, self.canvas.Y/2);
                if ([self getInsideFov:AimbotScreenLocation radius:追踪圆圈]) {
                    int tDistance = [self getCenterOffsetForVector:AimbotScreenLocation];
                    if (tDistance <= 追踪圆圈 && tDistance < markDistance) {
                        追踪圆圈 = [self banjing:AimbotScreenLocation.X y:AimbotScreenLocation.Y];
                        markDistance = tDistance;
                        markScreenPos.x = AimbotScreenLocation.X;
                        markScreenPos.y = AimbotScreenLocation.Y;
                        // 自己枪械开镜或者开火
                       
                        uintptr_t Character = Read<uintptr_t>(PlayerController + 0x538);
                        BOOL bIsWeaponFiring = Read<bool>(Character + 0x1c48);
                        BOOL bIsGunADS = Read<bool>(Character + 0x13f8);
                        if (bIsWeaponFiring || bIsGunADS ) {
                            // 自瞄目标距离
                            float distance = getDistance(AimbotWorldLocation, POV.Location) / 100;
                            
                            float temp = 1.23f;
                            float Gravity = 5.72f;
                            
                            if (distance < 5000.f)       temp = 1.8f;  else if (distance < 10000.f) temp = 1.72f;
                            else if (distance < 15000.f) temp = 1.23f; else if (distance < 20000.f) temp = 1.24f;
                            else if (distance < 25000.f) temp = 1.25f; else if (distance < 30000.f) temp = 1.26f;
                            uintptr_t WeaponManagerComponent =Read<uintptr_t>(player+ 0x2780);
                            uintptr_t CurrentWeaponReplicated = Read<uintptr_t>(WeaponManagerComponent+0x568);
                            uintptr_t ShootWeaponEntityComp = Read<uintptr_t>(CurrentWeaponReplicated+0x11b8);
                            
                            float BulletFireSpeed = Read<float>(ShootWeaponEntityComp + 0x12e4);
                            
                            float BulletFlyTime = distance / BulletFireSpeed;
                            float secFlyTime = BulletFlyTime * temp;
                            
                            // 目标移动速度
                            
                            FVector3D VelocitySafty = Read<FVector3D>(player + 0xe4c);
                            
                            // 预判目标位置
                            FVector3D delta;
                            delta.X = VelocitySafty.X * secFlyTime;
                            delta.Y = VelocitySafty.Y * secFlyTime;
                            delta.Z = VelocitySafty.Z * secFlyTime;
                            
                            if (distance > 10000.f) {
                                delta.Z += 0.5 * Gravity * BulletFlyTime * BulletFlyTime * 5.0f;
                            }
                            
                            FVector3D targetlocation;
                            targetlocation.X = AimbotWorldLocation.X - POV.Location.X + delta.X;
                            targetlocation.Y = AimbotWorldLocation.Y - POV.Location.Y + delta.Y;
                            targetlocation.Z = AimbotWorldLocation.Z - POV.Location.Z + delta.Z;
                            
                            // 目标位置角度
                            FRotator Rotation = [self calcAngle:targetlocation];
                            
                            // 自己位置角度
                            FRotator ControlRotation;
                            
                            readMemory(PlayerController + 0x560, sizeof(FRotator), &ControlRotation);
                            
                            // 平滑自瞄角度
                            FRotator clampRotation;
                            clampRotation.Yaw = Rotation.Yaw - ControlRotation.Yaw;
                            clampRotation.Pitch = Rotation.Pitch - ControlRotation.Pitch;
                            clampRotation.Roll = Rotation.Roll - ControlRotation.Roll;
                            
                            FRotator aimbotRotation;
                            aimbotRotation.Yaw = ControlRotation.Yaw + [self clamp:clampRotation].Yaw * 自瞄速度;
                            aimbotRotation.Pitch = ControlRotation.Pitch + [self clamp:clampRotation].Pitch * 自瞄速度;
                            float pitch = atan2f(targetlocation.Z, sqrt(pow(targetlocation.X, 2) + pow(targetlocation.Y, 2))) * 57.29577951308f;
                            float yaw = atan2f(targetlocation.Y, targetlocation.X) * 57.29577951308f;
                            
                            
                            float Yaw = aimbotRotation.Yaw;
                            float Pitch = aimbotRotation.Pitch;
                            if (!isnan(Yaw) && !isnan(Pitch)) {
                                
                                // 开火自瞄
                                if(自瞄开关){
                                    if(model.Health!=0 && bIsGunADS && model.Distance<=追踪距离)
                                    {
                                        //开镜自瞄
                                        writeMemory(PlayerController + 0x560, sizeof(float), &Pitch);
                                        
                                        writeMemory(PlayerController + 0x560+ 4, sizeof(float), &Yaw);
                                    }
                                    if (model.Health!=0 && model.Distance<=追踪距离) {
                                        
                                        //开火自瞄
                                        
                                        writeMemory(PlayerController + 0x560, sizeof(float), &Pitch);
                                        
                                        writeMemory(PlayerController + 0x560+ 4, sizeof(float), &Yaw);
                                        
                                    }
                                }
                                if(追踪开关){
                                    if ( model.Distance <= 追踪距离) {
                                        
                                        writeMemory(PlayerCameraManager + 0x5c8, sizeof(float), &pitch);
                                        
                                        writeMemory(PlayerCameraManager + 0x5c8 + 4, sizeof(float), &yaw);
                                        
                                    }
                                    
                                }
                            }
                        }
                        
                        
                    }
                    
                }
                
                
            }
            
        }
        [self.PlayArray addObject:model];
    }
    
    return self.PlayArray;
}

// 读取物资数据
- (NSMutableArray*)getwzData {
    self.WZArray = @[].mutableCopy;
    for (PUBGPlayerWZ *model in self.物资缓存) {
        uintptr_t player =model.Player;
        if (!isValidAddress(player)) continue;
        //玩家字典那是1秒一次的 真正绘制可能0.01秒 所以这里要从新更新物资的具体屏幕坐标
        FVector3D WorldLocation = getRelativeLocation(player);
        if(WorldLocation.X<=0 || WorldLocation.Y<=0 || WorldLocation.Z<=0) continue;
        //地图3D转屏幕2D
        FVector2D PM2D = worldToScreen(WorldLocation, POV, self.canvas);
        if (PM2D.X<0 && PM2D.X>self.canvas.X && PM2D.Y<0 &&PM2D.Y>self.canvas.Y) continue;
        model.JuLi = getDistance(WorldLocation, POV.Location) / 100;// 储存计算距离
        model.WuZhi2D=PM2D;//存储物资屏幕坐标系
        if(物资调试开关){
            int FNameID = Read<int>(player + 0x18);
            model.Name = getFNameFromID(GName, FNameID);
        }
        [self.WZArray addObject:model];
    }
    
    return self.WZArray;
    
}

//物资名字优化
static NSDictionary *vehicleNames[20];
-(NSString*)reName:(NSString*)NameStr ID:(int)ID
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vehicleNames[1] = @{
            
            //载具
            @"VH_BRDM_C" : @"装甲车",
            @"VH_CoupeRB_1_C" : @"双座跑车",
            @"VH_Dacia_New_C" : @"轿车",
            @"VH_Mountainbike_Training_C" : @"自行车",
            @"PickUp_BP_Mountainbike1_C" : @"自行车",
            @"Skill_Spawn_Mountaibike_C" : @"自行车",
            @"VH_Mountainbike_C" : @"自行车",
            @"VH_StationWagon_C" : @"旅行车",
            @"VH_Dacia_3_New_" : @"轿车",
            
            @"VH_PG117_C" : @"大船",
            @"VH_Scooter_C" : @"小绵羊",
            @"VH_UAZ01_New_C" : @"吉普",
            @"VH_Dacia_3_New_C" : @"吉普",
            
            @"BP_VH_Buggy_C" : @"蹦蹦",
            @"BP_VH_Buggy_3_C" : @"蹦蹦",
            @"BP_VH_Buggy_2_C" : @"蹦蹦",
            
            @"AquaRail_1_C" : @"冲锋艇",
            @"BP_VH_Bigfoot_C" : @"大脚车",
            @"Rony_01_C" : @"皮卡",
            @"Rony_3_C" : @"皮卡",
            @"Rony_2_C" : @"皮卡",
            @"VH_Motorcycle_C" : @"摩托车",
            @"PickUp_BP_VH_SplicedTrain_C" : @"磁吸小火车",
            @"GasCanBattery_Destructible_Pickup_C" : @"汽油桶",
            @"BP_Grenade_EmergencyCall_Weapon_C" : @"紧急呼救器",
            @"BP_EmergencyCall_ChildActor_C" : @"紧急呼救器"
        };
        vehicleNames[2] = @{
            
            //药品
            @"Bandage_Pickup_C" : @"绷带",
            @"Skill_Bandage_BP_C" : @"绷带",
            @"Skill_Painkiller_BP_C" : @"止疼药",
            @"Injection_Pickup_C" : @"肾上腺素",
            @"Skill_AdrenalineSyringe_BP_C" : @"肾上腺素",
            @"Firstaid_Pickup_C" : @"急救包",
            @"FirstAidbox_Pickup_C" : @"医疗箱",
            @"BP_revivalAED_Pickup_C" : @"[好东西]自救器",
            
            @"Drink_Pickup_C" : @"能量饮料",
            @"Skill_EnergyDrink_BP_C" : @"能量饮料",
            @"AttachActor_EnergyDrink_BP_C" : @"能量饮料"
        };
        vehicleNames[3] = @{
            
            @"BP_Grenade_Shoulei_Weapon_Wrapper_C" : @"手雷",
            @"BP_Grenade_Burn_Weapon_Wrapper_C" : @"手雷",
            @"BP_Grenade_Smoke_Weapon_Wrapper_C" : @"烟雾弹",
            
            @"BP_Grenade_Stun_Weapon_C" : @"手雷",
            @"BP_Grenade_Burn_Weapon_C" : @"手雷",
            @"ProjGrenade_BP_C" : @"手雷"
            
            
        };
        vehicleNames[4] = @{
            //枪械
            @"BP_Rifle_G36_Wrapper_C" : @"[好东西]MG3",
            @"BP_Sniper_QBU_Wrapper" : @"QBU",
            
            @"BP_Rifle_HoneyBadger_C" : @"蜜獾步枪",
            @"BP_ShotGun_S12K_C" : @"S12K",
            @"BP_ShotGun_S686_C" : @"S686",
            @"BP_Sniper_MK12_Wrapper" : @"MK12",
            @"BP_MachineGun_PP19_C" : @"野牛冲锋枪",
            @"BP_MachineGun_UMP9_Wrapper" : @"UMP9",
            @"BP_MachineGun_P90CG17_C" : @"[好东西]P90",
            @"BP_MachineGun_Vector_C" : @"维克托",
            @"BP_MachineGun_Uzi_Wrapper" : @"Uzi",
            @"BP_Rifle_DP28_Wrapper_C" : @"大盘鸡",
            @"BP_Other_HuntingBow_C" : @"爆炸烈弓",
            @"BP_Other_M249_Wrapper" : @"大菠萝",
            @"BP_Rifle_AKM_Wrapper_C" : @"AKM",
            @"BP_Rifle_AUG_Wrapper_C" : @"AUG",
            @"BP_Rifle_Groza_Wrapper_C" : @"[好东西]Groza",
            @"BP_Rifle_M416_Wrapper_C" : @"M416",
            @"BP_Rifle_M417_Wrapper_C" : @"M417",
            @"BP_Rifle_Mk47_Wrapper_C" : @"Mk47",
            @"BP_Sniper_SLR_Wrapper" : @"SLR",
            
            @"BP_Rifle_QBZ_Wrapper_C" : @"QBZ",
            @"BP_Rifle_SCAR_Wrapper_C" : @"SCAR-L",
            @"BP_Sniper_AWM_Wrapper" : @"[好东西]AWM",
            @"BP_Sniper_Kar98k_Wrapper_C" : @"Kar98k",
            @"BP_Sniper_M200_C" : @"M200",
            @"BP_Sniper_M24_Wrapper" : @"M24",
            @"BP_Sniper_MK14_Wrapper" : @"Mk14",
            @"BP_Sniper_SKS_Wrapper" : @"SKS",
            @"BP_Sniper_VSS_Wrapper" : @"VSS",
            @"BP_Rifle_M16A4_Wrapper_C" : @"M16A4",
            @"BP_Rifle_M762_Wrapper_C" : @"M762",
            @"BP_Rifle_VAL_C" : @"VAL",
            @"BP_Sniper_Mini14_Wrapper" : @"Mini14",
            
            @"BP_Other_PKM_C" : @"PKM轻机枪"
            
            
        };
        vehicleNames[5] = @{
            
            //配件
            @"BP_DJ_Large_E_Pickup_C" : @"步枪扩容",
            @"BP_DJ_Large_Q_Pickup_C" : @"步枪快速弹夹",
            @"BP_QK_Large_Compensator_Pickup_C" : @"步枪补偿器",
            @"BP_QK_Large_FlashHider_Pickup_C" : @"步枪消焰器",
            @"BP_WB_Angled_Pickup_C" : @"直角前握把",
            @"BP_WB_HalfGrip_Pickup_C" : @"半截红握把",
            @"BP_WB_LightGrip_Pickup_C" : @"轻型握把",
            @"BP_WB_Vertical_Pickup_C" : @"垂直握把",
            @"BP_WB_ThumbGrip_Pickup_C" : @"拇指握把",
            @"BP_QT_ZH_Pickup_C" : @"撞火枪托",
            @"BP_QT_A_Pickup_C" : @"战术枪托",
            @"BP_QT_Sniper_Pickup_C" : @"托腮板",
            @"BP_QK_DuckBill_Pickup_C" : @"鸭嘴",
            @"BP_QK_Large_Suppressor_Pickup_C" : @"狙击消音器",
            @"BP_QK_Sniper_FlashHider_Pickup_C" : @"狙击消焰器",
            @"BP_DJ_Sniper_Q_Pickup_C" : @"狙击快速弹夹",
            @"QK_Sniper_Compensator" : @"狙击补偿",
            @"BP_QK_Sniper_Compensator_Pickup_C" : @"狙击补偿",
            
            
            @"BP_QK_Mid_Compensator_Pickup_C" : @"冲锋枪补偿器",
            @"BP_QK_Mid_Suppressor_Pickup_C" : @"冲锋枪消音器",
            @"BP_QK_Mid_FlashHider_Pickup_C" : @"冲锋枪消焰器",
            @"BP_QT_UZI_Pickup_C" : @"UZI枪托"
            
        };
        vehicleNames[6] = @{
            
            //子弹
            @"BP_Ammo_556mm_Pickup_C" : @"[子弹]556",
            @"BP_Ammo_762mm_Pickup_C" : @"[子弹]762",
            @"BP_Ammo_9mm_Pickup_C" : @"[子弹]9毫米",
            @"BP_Ammo_300Magnum_Pickup_C" : @"[子弹]ARM子弹",
            @"BP_Ammo_50BMG_Pickup_C" : @"[子弹].50子弹",
            @"BP_Ammo_45ACP_Pickup_C" : @"[子弹].45子弹"
            
        };
        vehicleNames[7] = @{
            
            //其他物品
            @"BP_AirDropBox_C" : @"空投箱",
            @"BP_Pistol_Flaregun_Wrapper_C" : @"信号枪",
            @"AirDropListWrapperActor" : @"空投箱",
            @"BP_AirDropPlane_C" : @"空投飞机",
            @"BP_Grenade_EmergencyCall_Weapon_C" : @"紧急呼救器",
            @"BP_EmergencyCall_ChildActor_C" : @"紧急呼救器",
            @"BP_WEP_Sickle_Pickup_C" : @"镰刀",
            @"BP_WEP_Pan_C" : @"平底锅",
            
            @"CharacterDeadInventoryBox_C" : @"骨灰盒",
            @"BP_RevivalTower_CG22_C" : @"复活基站"
            
        };
        vehicleNames[8] = @{
            //枪械
            @"MG3BP_Other_MG3_C" : @"[好东西]MG3",
            @"BP_MachineGun_P90CG17_C" : @"[好东西]P90",
            @"BP_Rifle_AUG_C" : @"AUG",
            @"BP_Rifle_Groza_C" : @"[好东西]Groza",
            @"BP_Sniper_AWM_C" : @"[好东西]AWM",
            
            @"BP_Sniper_MK14_Wrapper" : @"Mk14",
            
            
            @"MovingTargetRoom_1574_AWM_Wrapper1_CA" : @"[好东西]AWM",
            
            //倍镜
            @"BP_MZJ_4X_Pickup_C" : @"4倍瞄准镜",
            @"BP_MZJ_6X_Pickup_C" : @"[好东西]6倍瞄准镜",
            @"BP_MZJ_8X_Ballistics_Pickup_C" : @"[好东西]8倍瞄准镜",
            
            //背包
            
            @"PickUp_BP_Bag_Lv3_C" : @"[好东西]三级包",
            @"PickUp_BP_Bag_Lv3_B_C" : @"[好东西]三级包",
            
            //头盔
            
            @"PickUp_BP_Helmet_Lv3_C" : @"[好东西]三级头",
            @"PickUp_BP_Helmet_Lv3_B_C" : @"[好东西]三级头",
            
            //护甲
            
            @"PickUp_BP_Armor_Lv3_C" : @"[好东西]三级甲",
            //药品
            
            @"FirstAidbox_Pickup_C" : @"医疗箱",
            @"BP_revivalAED_Pickup_C" : @"[好东西]自救器",
            
            //配件
            
            
            //其他物品
            @"BP_AirDropBox_C" : @"空投箱",
            @"BP_Pistol_Flaregun_Wrapper_C" : @"信号枪",
            @"AirDropListWrapperActor" : @"空投箱",
            
            @"BP_Grenade_EmergencyCall_Weapon_C" : @"紧急呼救器",
            @"BP_EmergencyCall_ChildActor_C" : @"紧急呼救器",
            
        };
        vehicleNames[9] = @{
            
            //倍镜
            @"BP_MZJ_HD_Pickup_C" : @"红点",
            @"BP_MZJ_QX_Pickup_C" : @"全息",
            @"BP_MZJ_2X_Pickup_C" : @"2倍瞄准镜",
            @"BP_MZJ_3X_Pickup_C" : @"3倍瞄准镜",
            @"BP_MZJ_4X_Pickup_C" : @"4倍瞄准镜",
            @"BP_MZJ_6X_Pickup_C" : @"[好东西]6倍瞄准镜",
            @"BP_MZJ_8X_Ballistics_Pickup_C" : @"[好东西]8倍瞄准镜",
            
        };
        vehicleNames[10] = @{
            
            //头盔
            @"PickUp_BP_Helmet_Lv1_C" : @"一级头",
            @"PickUp_BP_Helmet_Lv1_B_C" : @"一级头",
            @"PickUp_BP_Helmet_Lv2_C" : @"二级头",
            @"PickUp_BP_Helmet_Lv2_B_C" : @"二级头",
            @"PickUp_BP_Helmet_Lv3_C" : @"[好东西]三级头",
            @"PickUp_BP_Helmet_Lv3_B_C" : @"[好东西]三级头",
            
            //护甲
            @"PickUp_BP_Armor_Lv1_C" : @"一级甲",
            @"PickUp_BP_Armor_Lv2_C" : @"二级甲",
            @"PickUp_BP_Armor_Lv3_C" : @"[好东西]三级甲"
            
            
        };
        vehicleNames[11] = @{
            
            //护甲
            @"PickUp_BP_Armor_Lv1_C" : @"一级甲",
            @"PickUp_BP_Armor_Lv2_C" : @"二级甲",
            @"PickUp_BP_Armor_Lv3_C" : @"[好东西]三级甲"
            
            
        };
        vehicleNames[12] = @{
            
            //背包
            @"PickUp_BP_Bag_Lv1_C" : @"一级包",
            @"PickUp_BP_Bag_Lv1_B_C" : @"一级包",
            @"PickUp_BP_Bag_Lv2_C" : @"二级包",
            @"PickUp_BP_Bag_Lv2_B_C" : @"二级包",
            @"PickUp_BP_Bag_Lv3_C" : @"[好东西]三级包",
            @"PickUp_BP_Bag_Lv3_B_C" : @"[好东西]三级包"
            
            
        };
        
    });
    
    return [vehicleNames[ID] objectForKey:NameStr]?[vehicleNames[ID] objectForKey:NameStr]:nil;
}
//手持武器优化
- (NSString*)souchistr:(int)wqid{
    static NSDictionary *souchiNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        souchiNames = @{
            @(0): @"拳头",
            @(101001): @"AKM",
            @(101002): @"M16A-4",
            @(101003): @"SCAR-L",
            @(101004): @"M416",
            @(101005): @"Groza",
            @(101006): @"AUG",
            @(101007): @"QBZ",
            @(101008): @"M762",
            @(101009): @"Mk47",
            @(101010): @"C36C",
            @(101011): @"AC-VAL",
            @(101012): @"突击枪",
            @(103001): @"Kar98k",
            @(103002): @"M24",
            @(103003): @"AWM",
            @(103004): @"SKS",
            @(103005): @"VSS",
            @(103006): @"Mini14",
            @(103007): @"MK-14",
            @(103008): @"Win94",
            @(103009):@"SLR",
            @(103010): @"QBU",
            @(103011): @"莫辛纳甘",
            @(103012): @"AMR",
            @(103013): @"M417",
            @(103014): @"MK20",
            @(102001): @"Uzi",
            @(102105): @"P90",
            @(102002): @"UMP9",
            @(102003): @"Vector",
            @(102004): @"TommyGun",
            @(102005): @"野牛",
            @(102007): @"MP5K",
            @(104001): @"S686",
            @(104002): @"S1897",
            @(104003): @"S12K",
            @(104004): @"DBS",
            @(104006): @"SawedOff",
            @(104100): @"SPAS-12",
            @(106001): @"P92",
            @(106002): @"P1911",
            @(106003): @"R1895",
            @(106004): @"P18C",
            @(106005): @"R45",
            @(106010): @"沙漠之鹰"
        };
    });
    return souchiNames[@(wqid)] ?: @"";
}
//传入被追踪玩家的屏幕xy坐标
-(float)banjing:(float)x y:(float)y{
    float 横向距离 = fabs(x - [UIScreen mainScreen].bounds.size.width/2);//和屏幕中间的距离 取正值
    float 纵向距离 = fabs(y - [UIScreen mainScreen].bounds.size.height/2);//和屏幕中间的距离 取正值
    //勾股定理得到斜边长
    float 斜边长度 = sqrtf(横向距离 * 横向距离 + 纵向距离 * 纵向距离);
    float 半径 = 斜边长度+20;//半径加20 防止刚好画圈在玩家身上影响美观 既 准星正对玩家半径为0 也有20的圈
    if (半径>150)半径=150;//限制最大值
    return 半径;
}
@end
