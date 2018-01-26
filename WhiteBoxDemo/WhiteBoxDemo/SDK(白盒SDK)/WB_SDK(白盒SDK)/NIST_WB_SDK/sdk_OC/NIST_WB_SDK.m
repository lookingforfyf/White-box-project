//
//  NIST_WB_SDK.m
//  WhiteBoxSDK(白盒SDK)
//
//  Created by 范云飞 on 2017/10/30.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_WB_SDK.h"

@interface NIST_WB_SDK ()
{
    @private
    NSString * splitChar;           /* \n分隔符 */
    NSString * sVERSION;            /* 安全模块版本 */
    NSString * sDEVICE_FEATURES;    /* 设备特征信息 */
    NSString * sTERM_ID;            /* 终端编号 */
    NSString * sSEC_PIN;            /* 安全模块PIN码 */
    NSString * bDFV_1;              /* 设备特征值SM3(DFC) DFC：设备特征码*/
    NSString * bDFV_2;              /* 设备特征值SM3(DFC\nTERMID) DFC：设备特征码*/
    NSString * bZCODE;              /* 安全认证码 */
    NSString * bRANDS;              /* 内部随机数 */
    NSString * bTOKEN;              /* 外部随机数 */
    NSString * bZW_KEY;             /* 动态协商秘钥ZW */
    NSString * bSESSION_ID;         /* 会话标识 */
}
@end

@implementation NIST_WB_SDK
#pragma mark - 单例
static NIST_WB_SDK * nist_wb_sdk = nil;
+ (NIST_WB_SDK *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nist_wb_sdk = [[NIST_WB_SDK alloc]init];
    });
    return nist_wb_sdk;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!nist_wb_sdk)
    {
        nist_wb_sdk = [super allocWithZone:zone];
    }
    return nist_wb_sdk;
}

- (id)copy
{
    return self;
}

- (id)mutableCopy
{
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    splitChar = SPLIT_CHAR;
}

#pragma mark - 获取安全模块版本号
- (void)getVersion:(success)success
           failure:(failure)failure
{
    if (sVERSION == nil || sVERSION.length == 0)
    {
        if (![[NIST_Read_Write shareInstance]pubkeyVersion])
        {
            NSLog(@"获取安全模块版本号失败");
            NSDictionary * dic = @{
                                   @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_FAIL_TO_GET_SECURITY_MODULE_VERSION_NUMBER],
                                   @"Msg":NIST_FAIL_TO_GET_SECURITY_MODULE_VERSION_NUMBER_MSG
                                   };
            failure(dic);
            return;
        }
        NSString * version = [[NIST_Read_Write shareInstance]pubkeyVersion];
        sVERSION = version;
    }
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":sVERSION ? sVERSION : @""
                           };
    success(dic);
    return;
}

#pragma mark - 安全模块自检
- (void)selfCheckZSec:(success)success
              failure:(failure)failure
{
    /* 设备自检 */
    if (selfCheckSDK())
    {
        NSLog(@"设备自检失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_DEVICE_FAILED_TO_SELF_CHECK],
                               @"Msg":NIST_DEVICE_FAILED_TO_SELF_CHECK_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 加密公钥签名验签 */
    if (![[NIST_Read_Write shareInstance]pubkeyVersion] || ![[NIST_Read_Write shareInstance]signPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkeySign])
    {
        NSLog(@"公钥文件缓存为空");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PUBLIC_KEY_FILE_IS_EMPTY],
                               @"Msg":NIST_PUBLIC_KEY_FILE_IS_EMPTY_MSG
                               };
        failure(dic);
        return;
    }
    NSString * version = [[NIST_Read_Write shareInstance]pubkeyVersion];        //16进制
    NSString * pukSign = [[NIST_Read_Write shareInstance]signPubkey];           //16进制
    NSString * pukEnc  = [[NIST_Read_Write shareInstance]encryptPubkey];        //16进制
    NSString * sign    = [[NIST_Read_Write shareInstance]encryptPubkeySign];    //16进制
    if (pukSign.length != 128 || pukEnc.length != 128 || sign.length != 128)
    {
        NSLog(@"公钥文件长度错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PUBLIC_KEY_FILE_LENGTH_ERROR],
                               @"Msg":NIST_PUBLIC_KEY_FILE_LENGTH_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    sVERSION = version;
    NSString * px      = [pukSign substringWithRange:NSMakeRange(0, 64)];
    NSString * py      = [pukSign substringWithRange:NSMakeRange(64, 64)];
    NSString * msg     = pukEnc;
    NSString * signR   = [sign substringWithRange:NSMakeRange(0, 64)];
    NSString * signS   = [sign substringWithRange:NSMakeRange(64, 64)];
    NSString * za      = [[NSString alloc]init];
    [NIST_SSL sm2_sign_pre:px py:py za:&za];
    if (za == nil || za.length == 0)
    {
        NSLog(@"计算za错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_ZA_ERROR],
                               @"Msg":NIST_CALCULATE_ZA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:msg signR:signR signS:signS])
    {
        NSLog(@"加密公钥验签失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED],
                               @"Msg":NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED_MSG
                               };
        failure(dic);
        return ;
    }
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":NIST_SECURITY_MODULE_SELF_CHECK_SUCCESS_MAG
                           };
    success(dic);
    return;
}

#pragma mark - 生成随机数
- (void)generateRands:(NSString *)seed
                  len:(NSInteger)len
              success:(success)success
              failure:(failure)failure
{
    unsigned char rnd[len];
    SM2_gen_rand(rnd, (int)len);
    NSString * random = [NIST_Tool stringFromByte:rnd len:len];
    
    /* random去盐 */
    NSString * ran = [[NSString alloc]init];
    NSString * hexSeed = [NIST_Tool hexStringFromString:seed];
    [NIST_SSL daSalt:hexSeed data:random ouput:&ran];
    if (ran == nil || ran.length == 0)
    {
        NSLog(@"计算随机数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_RANDOM_NUMBER_ERROR],
                               @"Msg":NIST_CALCULATE_RANDOM_NUMBER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":ran ? ran : @""
                           };
    success(dic);
    return;
}

#pragma mark - 硬件特征信息枚举
- (void)probeDeviceFeatures:(success)success
                    failure:(failure)failure
{
    /* 获取硬件特征信息 */
    NSString * deviceFeatures = [NSString stringWithFormat:@"%@+%@+%@+%@+%@+%@+%@+%@+%@+%@+%@",[NIST_Device_Info getSystemPlatform],
                                                                                               [NIST_Device_Info getDeviceModel],
                                                                                               [NIST_Device_Info getFirmwareVersion],
                                                                                               [NIST_Device_Info getDeviceSerialNumber],
                                                                                               [NIST_Device_Info getCPUModel],
                                                                                               [NIST_Device_Info getGPUModel],
                                                                                               [NIST_Device_Info getMACAddress],
                                                                                               [NIST_Device_Info getResolution],
                                                                                               [NIST_Device_Info getBasebandVersion],
                                                                                               [NIST_Device_Info getSIMCardSerialNumber],
                                                                                               [NIST_Device_Info gettelephoneNumber]
                                 ];
    if (deviceFeatures.length == 0 || deviceFeatures == nil)
    {
        NSLog(@"枚举硬件特征信息错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_ENUMERATE_HARDWARE_FEATURE_INFORMATION_ERROR],
                               @"Msg":NIST_ENUMERATE_HARDWARE_FEATURE_INFORMATION_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 计算DFV */
    NSString * dfv = [NIST_SSL sm3:deviceFeatures];
    if (dfv == nil || dfv.length == 0)
    {
        NSLog(@"特征信息SM3HASH计算错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_FEATURE_INFORMATION_SM3_CALCULATION_FAILED],
                               @"Msg":NIST_FEATURE_INFORMATION_SM3_CALCULATION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    
    /**
     先判断 sDEVICE_FEATURES 和 bDFV_1 是否为空
     1.如果为空：把计算的deviceFeatures和dfv分别赋值
     2.如果不为空：分别对比是否一致
     */
    if (sDEVICE_FEATURES == nil || sDEVICE_FEATURES.length == 0 || bDFV_1 == nil || bDFV_1.length == 0)
    {
        sDEVICE_FEATURES = deviceFeatures;
        bDFV_1 = dfv;
    }
    else
    {
        if (![deviceFeatures isEqualToString:sDEVICE_FEATURES])
        {
            NSLog(@"两次枚举的硬件特征信息不相同");
            NSDictionary * dic = @{
                                   @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT],
                                   @"Msg":NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT_MSG
                                   };
            failure(dic);
            return;
        }
        else if (![dfv isEqualToString:bDFV_1])
        {
            NSLog(@"两次计算的bDFV_1不相同");
            NSDictionary * dic = @{
                                   @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATED_BDFV1_IS_DIFFERENT],
                                   @"Msg":NIST_CALCULATED_BDFV1_IS_DIFFERENT_MSG
                                   };
            failure(dic);
            return;
        }
    }
    
    /* 判断是不是第一次sm3hash生成摘要 */
    if (![[NIST_Read_Write shareInstance]dfc] || ![[NIST_Read_Write shareInstance]dfv1])
    {
        /* 第一次sm3hash生成摘要，写入文件 */
        [[NIST_Read_Write shareInstance]readWriteKey:FILE_DEV_FEATURE_SIGNATURE Value:deviceFeatures];
        [[NIST_Read_Write shareInstance]readWriteKey:FILE_DEV_FEATURE_DFV1 Value:dfv];
    }
    else
    {
        /* 如果不是第一次sm3算法生成摘要，拿本次生成的摘要和缓存的摘要作比较 */
        NSString * dfc = [[NIST_Read_Write shareInstance]dfc];
        NSString * dfv1 = [[NIST_Read_Write shareInstance]dfv1];
        if (![deviceFeatures isEqualToString:dfc])
        {
            NSLog(@"两次枚举的硬件特征信息不相同");
            NSDictionary * dic = @{
                                   @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT],
                                   @"Msg":NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT_MSG
                                   };
            failure(dic);
            return;
        }
        else if (![dfv isEqualToString:dfv1])
        {
            NSLog(@"两次计算的bDFV_1不相同");
            NSDictionary * dic = @{
                                   @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATED_BDFV1_IS_DIFFERENT],
                                   @"Msg":NIST_CALCULATED_BDFV1_IS_DIFFERENT_MSG
                                   };
            failure(dic);
            return;
        }
    }
    
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":sDEVICE_FEATURES ? sDEVICE_FEATURES : @""
                           };
    success(dic);
    return;
}

#pragma mark - 终端编号核验
- (void)checkTermId:(success)success
            failure:(failure)failure
{
    /* 判断缓存的终端编号及签名是否存在 */
    if (![[NIST_Read_Write shareInstance]termId] || ![[NIST_Read_Write shareInstance]termIdSign])
    {
        NSLog(@"终端编号或签名为空");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TERMINAL_NUMBER_OR_SIGNATURE_IS_BLANK],
                               @"Msg":NIST_TERMINAL_NUMBER_OR_SIGNATURE_IS_BLANK_MSG
                               };
        failure(dic);
        return;
    }
    NSString * termId = [[NIST_Read_Write shareInstance]termId];
    NSString * termSign = [[NIST_Read_Write shareInstance]termIdSign];
    
    /* 加密公钥签名验签 */
    if (![[NIST_Read_Write shareInstance]pubkeyVersion] || ![[NIST_Read_Write shareInstance]signPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkeySign])
    {
        NSLog(@"公钥文件缓存为空");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PUBLIC_KEY_FILE_IS_EMPTY],
                               @"Msg":NIST_PUBLIC_KEY_FILE_IS_EMPTY_MSG
                               };
        failure(dic);
        return;
    }
    NSString * pukSign = [[NIST_Read_Write shareInstance]signPubkey];           //16进制
    NSString * pukEnc  = [[NIST_Read_Write shareInstance]encryptPubkey];        //16进制
    NSString * sign    = [[NIST_Read_Write shareInstance]encryptPubkeySign];    //16进制
    if (pukSign.length != 128 || pukEnc.length != 128 || sign.length != 128)
    {
        NSLog(@"公钥文件长度错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PUBLIC_KEY_FILE_LENGTH_ERROR],
                               @"Msg":NIST_PUBLIC_KEY_FILE_LENGTH_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    NSString * px      = [pukSign substringWithRange:NSMakeRange(0, 64)];
    NSString * py      = [pukSign substringWithRange:NSMakeRange(64, 64)];
    NSString * msg     = termId;
    NSString * enc     = pukEnc;
    NSString * signR   = [sign substringWithRange:NSMakeRange(0, 64)];
    NSString * signS   = [sign substringWithRange:NSMakeRange(64, 64)];
    NSString * za      = [[NSString alloc]init];
    [NIST_SSL sm2_sign_pre:px py:py za:&za];
    if (za == nil || za.length == 0)
    {
        NSLog(@"计算za错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_ZA_ERROR],
                               @"Msg":NIST_CALCULATE_ZA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:enc signR:signR signS:signS])
    {
        NSLog(@"加密公钥验签失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED],
                               @"Msg":NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 终端编号签名验签 */
    unsigned char sign_r[32], sign_s[32], signData[64];
    int idx = 0;
    //    memcpy(sign_r, [[signR dataUsingEncoding:NSUTF8StringEncoding] bytes], 32);
    //    memcpy(sign_s, [[signS dataUsingEncoding:NSUTF8StringEncoding] bytes], 32);
    memcpy(signData, [[NIST_Tool nsdataFromHexString:termSign] bytes], 64);
    for (int i = 0; i < 32; i++)
    {
        sign_r[i] = signData[idx++];
    }
    for (int i = 0; i < 32; i++)
    {
        sign_s[i] = signData[idx++];
    }
    NSString * sign_r1 = [NIST_Tool stringFromByte:sign_r len:32];
    NSString * sign_s1 = [NIST_Tool stringFromByte:sign_s len:32];
    //    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:[NIST_Tool hexStringFromString:msg] signR:sign_r1 signS:sign_s1])
    //    {
    //        NSLog(@"终端编号签名验签");
    //        return -1;
    //    }
    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:msg signR:sign_r1 signS:sign_s1])
    {
        NSLog(@"终端编号签名验签失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TERMINAL_NUMBER_SIGNATURE_VERIFICATION_FAILED],
                               @"Msg":NIST_TERMINAL_NUMBER_SIGNATURE_VERIFICATION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":NIST_TERMINAL_NUMBER_CHECK_PASS
                           };
    success(dic);
    return;
}

#pragma mark - 安全认证码核验
- (void)checkZcode:(success)success
           failure:(failure)failure
{
    /* 终端编号核验 */
//    if ([self checkTermId])
//    {
//        NSLog(@"终端编号核验失败");
//        NSDictionary * dic = @{
//                               @"ErrorCode":[NSString stringWithFormat:@"%ld",NIST_TERMINAL_NUMBER_VERIFICATION_FAILED],
//                               @"Msg":@"终端编号核验失败"
//                               };
//        failure(dic);
//        return;
//    }
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]checkTermId:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        NSLog(@"%@",[dict objectForKey:@"Msg"]);
        failure(dict);
        return;
    }
    
    /* 判断是否缓存终端文件 */
    if (![[NIST_Read_Write shareInstance]termId] || ![[NIST_Read_Write shareInstance]termIdSign] || ![[NIST_Read_Write shareInstance]zcode])
    {
        NSLog(@"终端编号文件为空");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TERMINAL_NUMBER_FILE_IS_EMPTY],
                               @"Msg":NIST_TERMINAL_NUMBER_FILE_IS_EMPTY_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 安全认证码核验 */
    NSString * ftermId = [[NIST_Read_Write shareInstance]termId];
    NSString * fzcode = [[NIST_Read_Write shareInstance]zcode];
    NSString * zcode = [NIST_SSL sm3:ftermId];
    //    [NIST_SSL encryptZTA:zcode ciphertxt:&zcode];
    //    [NIST_SSL decryptZTB:zcode plaintxt:&zcode];
    //    [NIST_SSL encryptZUA:zcode ciphertxt:&zcode];
    //    [NIST_SSL decryptZUB:zcode plaintxt:&zcode];
    //    [NIST_SSL encryptZSA:zcode ciphertxt:&zcode];
    //    [NIST_SSL decryptZSB:zcode plaintxt:&zcode];
    if ( 0 != [NIST_SSL data:zcode zcode:&zcode])
    {
        NSLog(@"计算ZCODE失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_ZCODE_FAILED],
                               @"Msg":NIST_CALCULATE_ZCODE_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    if (![zcode isEqualToString:fzcode])
    {
        NSLog(@"安全认证码核验失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECURITY_AUTHENTICATION_CODE_CHECK_FAILED],
                               @"Msg":NIST_SECURITY_AUTHENTICATION_CODE_CHECK_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    bZCODE = zcode;
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":NIST_SECURITY_AUTHENTICATION_CODE_CHECK_PASS
                           };
    success(dic);
    return;
}

#pragma mark - 计算安全DFV2
- (void)generateDFV2:(NSString *)deviceFeatures
             success:(success)success
             failure:(failure)failure
{
    /* 判断是否枚举硬件特征信息 */
    if (sDEVICE_FEATURES == nil || sDEVICE_FEATURES.length == 0)
    {
        NSLog(@"枚举硬件特征信息错误");
//        [self probeDeviceFeatures];
        __block NSDictionary * dic;
        [[NIST_WB_SDK shareInstance]probeDeviceFeatures:^(NSDictionary *data) {
            dic = data;
        } failure:^(NSDictionary *error) {
            dic = error;
        }];
        if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
        {
            failure(dic);
            return;
        }
    }
    deviceFeatures = (deviceFeatures == nil || deviceFeatures.length == 0) ? sDEVICE_FEATURES : deviceFeatures;
    
    /* 判断TERM_ID是否为空 */
    if (sTERM_ID == nil || sTERM_ID.length == 0)
    {
//        [self checkTermId];
        __block NSDictionary * dic;
        [[NIST_WB_SDK shareInstance]checkTermId:^(NSDictionary *data) {
            dic = data;
        } failure:^(NSDictionary *error) {
            dic = error;
        }];
        if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
        {
            failure(dic);
            return;
        }
    }
    if (![deviceFeatures isEqualToString:sDEVICE_FEATURES] || sTERM_ID == nil || sTERM_ID.length == 0)
    {
        NSLog(@"两次枚举的硬件特征信息不相同");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT],
                               @"Msg":NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 计算DFV2 */
    NSString * dfc2 = [NSString stringWithFormat:@"%@%@%@",sDEVICE_FEATURES,splitChar,sTERM_ID];
    bDFV_2 = [NIST_SSL sm3:dfc2];
    if (bDFV_2 == nil || bDFV_2.length == 0)
    {
        NSLog(@"计算bDFV_2错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_BDFV2_ERROR],
                               @"Msg":NIST_CALCULATE_BDFV2_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":bDFV_2 ? bDFV_2 : @""
                           };
    success(dic);
    return;
}

#pragma mark - 终端编号申请数据
- (void)createTermIdRequestData:(NSString *)devicefeature
                        success:(success)success
                        failure:(failure)failure
{
    /* 判断并核验枚举的硬件特征信息 */
    if (sDEVICE_FEATURES == nil || sDEVICE_FEATURES.length == 0)
    {
        NSLog(@"枚举的硬件特征信息错误");
//        [self probeDeviceFeatures];
        __block NSDictionary * dic;
        [[NIST_WB_SDK shareInstance]probeDeviceFeatures:^(NSDictionary *data) {
            dic = data;
        } failure:^(NSDictionary *error) {
            dic = error;
        }];
        if ([[dic objectForKey:@"ErrorCode"] integerValue] != 100000)
        {
            failure(dic);
            return;
        }
    }
    if (![devicefeature isEqualToString:sDEVICE_FEATURES] || devicefeature == nil || devicefeature.length == 0)
    {
        NSLog(@"两次枚举的硬件特征信息不相同");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT],
                               @"Msg":NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 未预先设置安全模块PIN码 */
    if (sSEC_PIN == nil || sSEC_PIN.length == 0)
    {
        NSLog(@"sSEC_PIN为空");
        //        if (![self setSecPin:0 pin:@""])
        //        {
        //            NSLog(@"设置PIN码失败");
        //            return 0;
        //        }
        return;
    }
    
    /* 获取当前时间戳 */
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970] * 1000;
    NSString * timeStr = [NSString stringWithFormat:@"%f",time];
    unsigned long T0 = [timeStr longLongValue];
    timeStr = [NSString stringWithFormat:@"%lu",T0];
//    bRANDS = [self generateRands:timeStr len:32];
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]generateRands:timeStr len:32 success:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        bRANDS = [dict objectForKey:@"Msg"];
    }
    
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 安全模块版本号 */
//    [msgBuffer appendString:[self getVersion]];
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        [msgBuffer appendString:[dict objectForKey:@"Msg"]];
    }
    [msgBuffer appendString:splitChar];
    /* 安全模块PIN码 */
    [msgBuffer appendString:sSEC_PIN];
    [msgBuffer appendString:splitChar];
    /* 随机数 */
    [msgBuffer appendString:bRANDS];
    [msgBuffer appendString:splitChar];
    /* 硬件特征信息 */
    [msgBuffer appendString:sDEVICE_FEATURES];
    [msgBuffer appendString:splitChar];
    /* 时间 */
    [msgBuffer appendString:timeStr];
    
    /* 用加密公钥进行加密 */
    NSString * cipher = [[NSString alloc]init];
    if (![[NIST_Read_Write shareInstance]pubkeyVersion] || ![[NIST_Read_Write shareInstance]signPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkeySign])
    {
        NSLog(@"公钥文件缓存为空");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TERMINAL_NUMBER_FILE_IS_EMPTY],
                               @"Msg":NIST_PUBLIC_KEY_FILE_IS_EMPTY_MSG
                               };
        failure(dic);
        return;
    }
    NSString * version = [[NIST_Read_Write shareInstance]pubkeyVersion];
    NSString * pukSign = [[NIST_Read_Write shareInstance]signPubkey];           //16进制
    NSString * pukEnc  = [[NIST_Read_Write shareInstance]encryptPubkey];        //16进制
    NSString * sign    = [[NIST_Read_Write shareInstance]encryptPubkeySign];    //16进制
    if (pukSign.length != 128 || pukEnc.length != 128 || sign.length != 128)
    {
        NSLog(@"公钥文件长度错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PUBLIC_KEY_FILE_LENGTH_ERROR],
                               @"Msg":NIST_PUBLIC_KEY_FILE_LENGTH_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    sVERSION = version;
    NSString * px      = [pukSign substringWithRange:NSMakeRange(0, 64)];
    NSString * py      = [pukSign substringWithRange:NSMakeRange(64, 64)];
    NSString * msg     = pukEnc;
    NSString * signR   = [sign substringWithRange:NSMakeRange(0, 64)];
    NSString * signS   = [sign substringWithRange:NSMakeRange(64, 64)];
    NSString * za      = [[NSString alloc]init];
    [NIST_SSL sm2_sign_pre:px py:py za:&za];
    if (za == nil || za.length == 0)
    {
        NSLog(@"计算za错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_ZA_ERROR],
                               @"Msg":NIST_CALCULATE_ZA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:msg signR:signR signS:signS])
    {
        NSLog(@"加密公钥验签失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED],
                               @"Msg":NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 申请终端编号请求数据加密 */
    NSString * en_x = [pukEnc substringWithRange:NSMakeRange(0, 64)];
    NSString * en_y = [pukEnc substringWithRange:NSMakeRange(64, 64)];
    [NIST_SSL sm2_encrypt:en_x py:en_y plain:[NIST_Tool hexStringFromString:msgBuffer] rand:NULL cipher:&cipher];
    if (cipher == nil || cipher.length == 0)
    {
        NSLog(@"申请终端编号数据加密失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_APPLY_FOR_TERMINAL_NUMBER_DATA_ENCRYPTION_FAILURE],
                               @"Msg":NIST_APPLY_FOR_TERMINAL_NUMBER_DATA_ENCRYPTION_FAILURE_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 生成请求数据 */
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_1,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 终端编号装载
- (void)setupTermId:(NSString *)deviceFeatures
         termIdData:(NSString *)termIdData
            success:(success)success
            failure:(failure)failure
{
    /* 判断bRANDS和入参是否错误 */
    if (bRANDS == nil || bRANDS.length == 0 || deviceFeatures == nil || deviceFeatures.length == 0 || termIdData == nil || termIdData.length == 0)
    {
        NSLog(@"终端编号装载参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TERMINAL_NUMBER_LOADING_PARAMETER_ERROR],
                               @"Msg":NIST_TERMINAL_NUMBER_LOADING_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 使用\n分割termIdData */
    NSArray * recvMsg = [termIdData componentsSeparatedByString:SPLIT];
    if (recvMsg.count != 2 || recvMsg == nil)
    {
        NSLog(@"申请终端编号应答数据错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_APPLY_FOR_TERMINAL_NUMBER_RESPONSE_DATA_ERROR],
                               @"Msg":NIST_APPLY_FOR_TERMINAL_NUMBER_RESPONSE_DATA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 去盐 */
    NSString * termSign = [recvMsg objectAtIndex:0];
    NSString * cipher = [recvMsg objectAtIndex:1];
    [NIST_SSL daSalt:bRANDS data:cipher ouput:&cipher];
    [NIST_SSL daSalt:bDFV_1 data:cipher ouput:&cipher];
    
    /* 终端编号申请流程完成随机数销毁 */
    bRANDS = nil;
    
    /* 去除termId左侧的F */
    NSString * termId = cipher;
    termId = [NIST_Tool leftTrimString:termId padding:@"F"];
    
    /* 加密公钥签名验签 */
    if (![[NIST_Read_Write shareInstance]pubkeyVersion] || ![[NIST_Read_Write shareInstance]signPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkey] || ![[NIST_Read_Write shareInstance]encryptPubkeySign])
    {
        NSLog(@"公钥文件缓存为空");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PUBLIC_KEY_FILE_IS_EMPTY],
                               @"Msg":NIST_PUBLIC_KEY_FILE_IS_EMPTY_MSG
                               };
        failure(dic);
        return;
    }
    NSString * pukSign = [[NIST_Read_Write shareInstance]signPubkey];           //16进制
    NSString * pukEnc  = [[NIST_Read_Write shareInstance]encryptPubkey];        //16进制
    NSString * sign    = [[NIST_Read_Write shareInstance]encryptPubkeySign];    //16进制
    if (pukSign.length != 128 || pukEnc.length != 128 || sign.length != 128)
    {
        NSLog(@"公钥文件长度错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PUBLIC_KEY_FILE_LENGTH_ERROR],
                               @"Msg":NIST_PUBLIC_KEY_FILE_LENGTH_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    NSString * px      = [pukSign substringWithRange:NSMakeRange(0, 64)];
    NSString * py      = [pukSign substringWithRange:NSMakeRange(64, 64)];
    NSString * msg     = termId;
    NSString * enc     = pukEnc;
    NSString * signR   = [sign substringWithRange:NSMakeRange(0, 64)];
    NSString * signS   = [sign substringWithRange:NSMakeRange(64, 64)];
    NSString * za      = [[NSString alloc]init];
    [NIST_SSL sm2_sign_pre:px py:py za:&za];
    if (za == nil || za.length == 0)
    {
        NSLog(@"计算za错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_ZA_ERROR],
                               @"Msg":NIST_CALCULATE_ZA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:enc signR:signR signS:signS])
    {
        NSLog(@"加密公钥签名验签错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED],
                               @"Msg":NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 终端编号签名验签 */
    unsigned char sign_r[32], sign_s[32], signData[64];
    int idx = 0;
    //    memcpy(sign_r, [[signR dataUsingEncoding:NSUTF8StringEncoding] bytes], 32);
    //    memcpy(sign_s, [[signS dataUsingEncoding:NSUTF8StringEncoding] bytes], 32);
    memcpy(signData, [[NIST_Tool nsdataFromHexString:termSign] bytes], 64);
    for (int i = 0; i < 32; i++)
    {
        sign_r[i] = signData[idx++];
    }
    for (int i = 0; i < 32; i++)
    {
        sign_s[i] = signData[idx++];
    }
    NSString * sign_r1 = [NIST_Tool stringFromByte:sign_r len:32];
    NSString * sign_s1 = [NIST_Tool stringFromByte:sign_s len:32];
    NSLog(@"***********%@",[NIST_Tool hexStringFromString:msg]);
    //    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:[NIST_Tool hexStringFromString:msg] signR:sign_r1 signS:sign_s1])
    //    {
    //        NSLog(@"终端编号签名验签失败");
    //        return -1;
    //    }
    if (0 != [NIST_SSL sm2_verify:px py:py za:za msg:msg signR:sign_r1 signS:sign_s1])
    {
        NSLog(@"终端编号签名验签失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TERMINAL_NUMBER_SIGNATURE_VERIFICATION_FAILED],
                               @"Msg":NIST_TERMINAL_NUMBER_SIGNATURE_VERIFICATION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    sTERM_ID = termId;
    
    /* 计算Zcode */
    NSString * zcode = [NIST_SSL sm3:termId];
    //    [NIST_SSL encryptZTA:zcode ciphertxt:&zcode];
    //    [NIST_SSL decryptZTB:zcode plaintxt:&zcode];
    //    [NIST_SSL encryptZUA:zcode ciphertxt:&zcode];
    //    [NIST_SSL decryptZUB:zcode plaintxt:&zcode];
    //    [NIST_SSL encryptZSA:zcode ciphertxt:&zcode];
    //    [NIST_SSL decryptZSB:zcode plaintxt:&zcode];
    if ( 0 != [NIST_SSL data:zcode zcode:&zcode])
    {
        NSLog(@"计算ZCODE失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_ZCODE_FAILED],
                               @"Msg":NIST_CALCULATE_ZCODE_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    bZCODE = zcode;
    
    /* 写TERM-ID文件 */
    [[NIST_Read_Write shareInstance]readWriteKey:FILE_TERM_ID_NUM Value:sTERM_ID];
    [[NIST_Read_Write shareInstance]readWriteKey:FILE_TERM_ID_SIGN Value:termSign];
    [[NIST_Read_Write shareInstance]readWriteKey:FILE_TERM_ID_ZCODE Value:bZCODE];
    
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":NIST_TERMINAL_NUMBER_LOADING_SUCCESS
                           };
    success(dic);
    return;
}

#pragma mark - 双向认证申请
- (void)applyAuthentication:(success)success
                    failure:(failure)failure
{
    /* 未进行硬件信息枚举、终端编号核验、安全认证码核验 */
    if (sDEVICE_FEATURES == nil || sDEVICE_FEATURES.length == 0 || sTERM_ID == nil || sTERM_ID.length == 0 || bZCODE == nil || bZCODE.length == 0)
    {
        NSLog(@"双向认证申请参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TWOWAY_AUTHENTICATION_APPLICATION_PARAMETER_ERROR],
                               @"Msg":NIST_TWOWAY_AUTHENTICATION_APPLICATION_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 安全模块自检失败 */
//    if ([self selfCheckZSec])
//    {
//        NSLog(@"安全模块自检失败");
//        NSDictionary * dic = @{
//                               @"ErrorCode":[NSString stringWithFormat:@"%ld",NIST_DEVICE_FAILED_TO_SELF_CHECK],
//                               @"Msg":@"安全模块自检失败"
//                               };
//        failure(dic);
//        return;
//    }
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]selfCheckZSec:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    
    /* 计算DFV2 */
    if (bDFV_2 == nil || bDFV_2.length == 0)
    {
//        [self generateDFV2:sDEVICE_FEATURES];
        [[NIST_WB_SDK shareInstance]generateDFV2:sDEVICE_FEATURES success:^(NSDictionary *data) {
            dict = data;
        } failure:^(NSDictionary *error) {
            dict = error;
        }];
        if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
        {
            failure(dict);
            return;
        }
    }
    
    /* 获取当前时间戳 */
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970] * 1000;
    NSString * timeStr = [NSString stringWithFormat:@"%f",time];
    unsigned long T0 = [timeStr longLongValue];
    timeStr = [NSString stringWithFormat:@"%lu",T0];
//    bRANDS = [self generateRands:timeStr len:32];
    [[NIST_WB_SDK shareInstance]generateRands:timeStr len:32 success:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        bRANDS = [dict objectForKey:@"Msg"];
    }
    
    /* 安全模块版本+终端编号+安全认证码+DFV2+随机数+T0 */
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 安全模块版本 */
//    [msgBuffer appendString:[self getVersion]];
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        [msgBuffer appendString:[dict objectForKey:@"Msg"]];
    }
    [msgBuffer appendString:splitChar];
    /* 终端编号 */
    [msgBuffer appendString:sTERM_ID];
    [msgBuffer appendString:splitChar];
    /* 安全认证码 */
    [msgBuffer appendString:bZCODE];
    [msgBuffer appendString:splitChar];
    /* DFV2 */
    [msgBuffer appendString:bDFV_2];
    [msgBuffer appendString:splitChar];
    /* 随机数 */
    [msgBuffer appendString:bRANDS];
    [msgBuffer appendString:splitChar];
    /* 时间 */
    [msgBuffer appendString:timeStr];
    
    /* 填充为8的整数倍 */
    msgBuffer = [NIST_Tool stringPadding:msgBuffer cnt:8 padding:splitChar];
    
    /* ZTA加密 */
    NSString * cipher = [[NSString alloc]init];
    if (0 != [NIST_SSL encryptZTA:[NIST_Tool hexStringFromString:msgBuffer] ciphertxt:&cipher])
    {
        NSLog(@"双向认证申请数据加密失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_TWOWAY_AUTHENTICATION_APPLICATION_DATA_ENCRYPTION_FAILED],
                               @"Msg":NIST_TWOWAY_AUTHENTICATION_APPLICATION_DATA_ENCRYPTION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 生成请求数据 */
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_2,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 挑战码认证数据
- (void)tokenRequestData:(NSString *)token
                 success:(success)success
                 failure:(failure)failure
{
    /* 判断参数 */
    if (bRANDS == nil || bRANDS.length == 0 || sTERM_ID == nil || sTERM_ID.length == 0 || bZCODE == nil || bZCODE.length == 0 || bDFV_2 == nil || bDFV_2.length == 0)
    {
        NSLog(@"挑战码认证数据请求参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CHALLENGE_CODE_AUTHENTICATION_DATA_REQUEST_PARAMETER_ERROR],
                               @"Msg":NIST_CHALLENGE_CODE_AUTHENTICATION_DATA_REQUEST_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 解密 */
    NSString * plain = [[NSString alloc]init];
    [NIST_SSL decryptZTB:token plaintxt:&plain];
    
    /* 还原挑战码 */
    [NIST_SSL daSalt:bRANDS data:plain ouput:&plain];
    
    /* ZTA */
    NSString * cipher = [[NSString alloc]init];
    [NIST_SSL encryptZTA:plain ciphertxt:&cipher];
    
    /* ^TERMID */
    NSString * hash = [NIST_SSL sm3:sTERM_ID];
    [NIST_SSL daSalt:hash data:cipher ouput:&cipher];
    
    /* ZTB */
    [NIST_SSL decryptZTB:cipher plaintxt:&plain];
    
    /* ^ZCODE */
    [NIST_SSL daSalt:bZCODE data:plain ouput:&plain];
    
    /* ZTA */
    [NIST_SSL encryptZTA:plain ciphertxt:&cipher];
    
    /* 生成请求数据 */
    __block NSDictionary * dict;
    NSString * version;
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        version = [dict objectForKey:@"Msg"];
    }
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",version,splitChar,bDFV_2,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 挑战码反向认证
- (void)tokenResponseDataChecked:(NSString *)token
                         success:(success)success
                         failure:(failure)failure
{
    /* 判断参数是否出错 */
    if (bDFV_1 == nil || bDFV_1.length == 0 || token == nil || token.length == 0)
    {
        NSLog(@"挑战码反向认证参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_PARAMETER_ERROR],
                               @"Msg":NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 判断token是否是8的整数倍 */
    if ((token.length % 8) != 0)
    {
        NSLog(@"挑战码反向认证的token数据错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_TOKEN_DATA_ERROR],
                               @"Msg":NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_TOKEN_DATA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* ZTB */
    NSString * session_id = [[NSString alloc]init];
    [NIST_SSL decryptZTB:token plaintxt:&session_id];
    
    /* 去盐 */
    [NIST_SSL daSalt:bDFV_1 data:session_id ouput:&session_id];
    if (session_id == nil || session_id.length == 0)
    {
        NSLog(@"计算session_id失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_SESSIONID_FAILURE],
                               @"Msg":NIST_CALCULATE_SESSIONID_FAILURE_MSG
                               };
        failure(dic);
        return;
    }
    bSESSION_ID = session_id;
    /* 判断是否缓存session_id */
    //    if (![[NIST_Read_Write shareInstance]session_id])
    //    {
    //        NSLog(@"缓存的session_id失败");
    //        NSLog(@"%@",[NIST_Tool stringFromHexString:bSESSION_ID]);
    //        [[NIST_Read_Write shareInstance]setValue:bSESSION_ID forKey:[NIST_Tool stringFromHexString:bSESSION_ID]];
    //        return -1;
    //    }
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":NIST_CHALLEGNE_CODE_REVERSE_AUTHENTICATION_PASS
                           };
    success(dic);
    return;
}

#pragma mark - 用户绑定申请
- (void)bandUserLoginDevice:(NSString *)userId
                    success:(success)success
                    failure:(failure)failure
{
    /* 判断参数 */
    if (userId == nil || userId.length == 0)
    {
        NSLog(@"用户绑定申请参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%ld",NIST_USER_BINDING_APPLICATION_PARAMETER_ERROR],
                               @"Msg":NIST_USER_BINDING_APPLICATION_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 计算DFV2，安全模块自检 */
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]generateDFV2:nil success:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    if (bSESSION_ID == nil || bSESSION_ID.length == 0)
    {
//        NSLog(@"计算DFV2错误");
//        NSDictionary * dic = @{
//                               @"ErrorCode":[NSString stringWithFormat:@"%ld",NIST_CALCULATE_BDFV2_ERROR],
//                               @"Msg":@"计算DFV2错误"
//                               };
//        failure(dic);
        NSLog(@"bSESSION_ID为空");
        return;
    }
//    if ([self selfCheckZSec])
//    {
//        NSLog(@"设备自检失败");
//        NSDictionary * dic = @{
//                               @"ErrorCode":[NSString stringWithFormat:@"%ld",NIST_DEVICE_FAILED_TO_SELF_CHECK],
//                               @"Msg":@"设备自检失败"
//                               };
//        failure(dic);
//        return;
//    }
    [[NIST_WB_SDK shareInstance]selfCheckZSec:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    
    /* 获取当前时间戳 */
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970] * 1000;
    NSString * timeStr = [NSString stringWithFormat:@"%f",time];
    unsigned long T0 = [timeStr longLongValue];
    timeStr = [NSString stringWithFormat:@"%lu",T0];
//    bRANDS = [self generateRands:timeStr len:32];
    [[NIST_WB_SDK shareInstance]generateRands:timeStr len:32 success:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        bRANDS = [dict objectForKey:@"Msg"];
    }
    
    /* 安全模块版本+终端编号+安全认证码+用户标识+随机数+T0 */
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 安全模块版本 */
//    [msgBuffer appendString:[self getVersion]];
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        [msgBuffer appendString:[dict objectForKey:@"Msg"]];
    }
    [msgBuffer appendString:splitChar];
    /* 终端编号 */
    [msgBuffer appendString:sTERM_ID];
    [msgBuffer appendString:splitChar];
    /* 安全认证码 */
    [msgBuffer appendString:bZCODE];
    [msgBuffer appendString:splitChar];
    /* 会话标识 */
    [msgBuffer appendString:bSESSION_ID];
    [msgBuffer appendString:splitChar];
    /* 用户标识 */
    [msgBuffer appendString:userId];
    [msgBuffer appendString:splitChar];
    /* 添加手机号，暂时先加\n */
    [msgBuffer appendString:@"15137162459"];
    [msgBuffer appendString:splitChar];
    /* 随机数 */
    [msgBuffer appendString:bRANDS];
    [msgBuffer appendString:splitChar];
    /* 时间 */
    [msgBuffer appendString:timeStr];
    
    /* 填充为8的整数倍 */
    msgBuffer = [NIST_Tool stringPadding:msgBuffer cnt:8 padding:splitChar];
    
    /* ZUA加密 */
    NSString * cipher = [[NSString alloc]init];
    [NIST_SSL encryptZUA:[NIST_Tool hexStringFromString:msgBuffer] ciphertxt:&cipher];
    
    /* 生成请求数据 */
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_2,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 用户绑定认证数据
- (void)optRequestData:(NSString *)mode
                userId:(NSString *)userId
                inData:(NSString *)inData
               success:(success)success
               failure:(failure)failure
{
    /* 参数判断 */
    if (bSESSION_ID == nil || bSESSION_ID.length == 0 || bDFV_2 == nil || bDFV_2.length == 0 || bRANDS == nil || bRANDS.length == 0 || mode == nil || mode.length == 0 || userId == nil || userId.length == 0 || inData == nil | inData.length == 0)
    {
        NSLog(@"用户绑定认证数据参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_USER_BINGDING_AUTHENTICATION_DATA_PARAMETER_ERROR],
                               @"Msg":NIST_USER_BINGDING_AUTHENTICATION_DATA_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 数据填充 */
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 用户标识 */
    [msgBuffer appendString:userId];
    [msgBuffer appendString:splitChar];
    /* 会话标识 */
    [msgBuffer appendString:bSESSION_ID];
    [msgBuffer appendString:splitChar];
    /* OTP/SOTP */
    if ([mode isEqualToString:@"OTP"])
    {
        [msgBuffer appendString:inData];
    }
    else if ([mode isEqualToString:@"SOTP"])
    {
        [NIST_SSL decryptZUB:inData plaintxt:&inData];
        [NIST_SSL daSalt:bRANDS data:inData ouput:&inData];
        [msgBuffer appendString:inData];
        bRANDS = nil;
    }
    else
    {
        return;
    }
    
    /* 填充为8的整数倍 */
    msgBuffer = [NIST_Tool stringPadding:msgBuffer cnt:8 padding:splitChar];
    
    /* ZUA加密 */
    NSString * cipher = [[NSString alloc]init];
    [NIST_SSL encryptZUA:[NIST_Tool hexStringFromString:msgBuffer] ciphertxt:&cipher];
    
    /* 生成请求数据 */
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_2,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 用户绑定反向认证
- (void)optResponseDataChecked:(NSString *)userId
                         token:(NSString *)token
                       success:(success)success
                       failure:(failure)failure
{
    /* 按\n分割字符串 */
    NSArray * msg = [token componentsSeparatedByString:SPLIT];
    
    /* 判断参数 */
    if (userId == nil || userId.length == 0 || sTERM_ID == nil || sTERM_ID.length == 0 || msg.count < 2 || ![msg.firstObject isEqualToString:@"00"] || token == nil || token.length == 0)
    {
        NSLog(@"用户绑定反向认证参数出错");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_USER_BINDING_REVERSE_AUTHENTICATION_PARAMETER_ERROR],
                               @"Msg":NIST_USER_BINDING_REVERSE_AUTHENTICATION_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* sm3hash */
    NSString * tmp = [NSString stringWithFormat:@"%@%@%@",sTERM_ID,splitChar,userId];
    NSString * hash = [NIST_SSL sm3:tmp];
    if (![hash isEqualToString:[msg objectAtIndex:1]])
    {
        NSLog(@"用户绑定反向认证数据SM3HASH失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_USER_BINDING_REVERSE_AUTHENTICATION_DATA_SMHASH_FAILED],
                               @"Msg":NIST_USER_BINDING_REVERSE_AUTHENTICATION_DATA_SMHASH_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":NIST_USER_BINDING_REVERSE_AUTHENTICATION_PASS
                           };
    failure(dic);
}

#pragma mark - 用户登录认证数据
- (void)loginRequestData:(NSString *)userId
                 success:(success)success
                 failure:(failure)failure
{
    /* 判断参数 */
    if (userId == nil || userId.length == 0 || bDFV_2 == nil || bDFV_2.length == 0 || sTERM_ID == nil || sTERM_ID.length == 0 || bSESSION_ID == nil || bSESSION_ID.length == 0)
    {
        NSLog(@"用户登录认证数据参数出错");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_USER_LOGIN_AUTHENTICATION_DATA_PARAMETER_ERROR],
                               @"Msg":NIST_USER_LOGIN_AUTHENTICATION_DATA_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 获取当前时间戳 */
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970] * 1000;
    NSString * timeStr = [NSString stringWithFormat:@"%f",time];
    unsigned long T0 = [timeStr longLongValue];
    timeStr = [NSString stringWithFormat:@"%lu",T0];
    
    /* 填充数据 */
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 用户标识 */
    [msgBuffer appendString:userId];
    [msgBuffer appendString:splitChar];
    /* 终端编号 */
    [msgBuffer appendString:sTERM_ID];
    [msgBuffer appendString:splitChar];
    /* 会话标识 */
    [msgBuffer appendString:bSESSION_ID];
    [msgBuffer appendString:splitChar];
    /* 时间 */
    [msgBuffer appendString:timeStr];
    
    /* 填充为8的倍数 */
    msgBuffer = [NIST_Tool stringPadding:msgBuffer cnt:8 padding:splitChar];
    
    /* ZUA加密 */
    NSString * cipher = [[NSString alloc]init];
    [NIST_SSL encryptZUA:[NIST_Tool hexStringFromString:msgBuffer] ciphertxt:&cipher];
    
    /* 生成请求数据 */
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_2,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 用户登录认证结果
- (void)loginResponseDataChecked:(NSString *)userId
                           token:(NSString *)token
                         success:(success)success
                         failure:(failure)failure
{
    /* 按\n分割字符串 */
    NSArray * msg = [token componentsSeparatedByString:SPLIT];
    
    /* 判断参数 */
    if (userId == nil || userId.length == 0 || token == nil || token.length == 0 || sTERM_ID == nil || sTERM_ID.length == 0 || msg.count < 2 || ![[msg objectAtIndex:0] isEqualToString:@"00"])
    {
        NSLog(@"用户登录认证结果数据参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_PARAMETER_ERROR],
                               @"Msg":NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* sm3hash */
    NSString * tmp = [NSString stringWithFormat:@"%@%@%@",sTERM_ID,splitChar,userId];
    NSString * hash = [NIST_SSL sm3:tmp];
    if (![hash isEqualToString:[msg objectAtIndex:1]])
    {
        NSLog(@"用户登录认证结果数据SM3HASH失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_SM3HASH_FAILED],
                               @"Msg":NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_SM3HASH_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":NIST_USER_LOGIN_AUTHENTICATION_RESULT_PASS
                           };
    success(dic);
    return;
}

#pragma mark - 秘钥协商申请
- (void)applykeyAgreement:(NSString *)userId
                 bussType:(NSString *)bussType
                  success:(success)success
                  failure:(failure)failure
{
    /* 判断参数 */
    if (userId == nil || userId.length == 0 || bussType == nil || bussType.length == 0 || bDFV_2 == nil || bDFV_2.length == 0 || sTERM_ID == nil || sTERM_ID.length == 0 || bSESSION_ID == nil || bSESSION_ID.length == 0)
    {
        NSLog(@"秘钥协商申请请求参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_APPLICATION_REQUEST_PARAMETER_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_APPLICATION_REQUEST_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 未预先输入安全模块PIN码 */
    if (sSEC_PIN == nil || sSEC_PIN.length == 0)
    {
        NSLog(@"未预先输入安全模块PIN码");
        //        if (![self setSecPin:1 pin:@""])
        //        {
        //            NSLog(@"安全PIN码设置失败");
        //            return 0;
        //        }
        return;
    }
    
    /* 获取当前时间戳 */
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970] * 1000;
    NSString * timeStr = [NSString stringWithFormat:@"%f",time];
    unsigned long T0 = [timeStr longLongValue];
    timeStr = [NSString stringWithFormat:@"%lu",T0];
//    bRANDS = [self generateRands:timeStr len:32];
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]generateRands:timeStr len:32 success:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        bRANDS = [dict objectForKey:@"Msg"];
    }
    
    /* 填充数据 */
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 用户标识 */
    [msgBuffer appendString:userId];
    [msgBuffer appendString:splitChar];
    /* 业务类型 */
    [msgBuffer appendString:bussType];
    [msgBuffer appendString:splitChar];
    /* 终端编号 */
    [msgBuffer appendString:sTERM_ID];
    [msgBuffer appendString:splitChar];
    /* 安全模块PIN码 */
    [msgBuffer appendString:sSEC_PIN];
    [msgBuffer appendString:splitChar];
    /* 会话标识 */
    [msgBuffer appendString:bSESSION_ID];
    [msgBuffer appendString:splitChar];
    /* 随机数 */
    [msgBuffer appendString:bRANDS];
    [msgBuffer appendString:splitChar];
    /* 时间 */
    [msgBuffer appendString:timeStr];
    
    /* 填充为8的整数倍 */
    msgBuffer = [NIST_Tool stringPadding:msgBuffer cnt:8 padding:splitChar];
    
    /* ZSA加密 */
    NSString * cipher = [[NSString alloc]init];
    [NIST_SSL encryptZSA:[NIST_Tool hexStringFromString:msgBuffer] ciphertxt:&cipher];
    
    /* 生成请求数据 */
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_2,splitChar,cipher];
    sSEC_PIN = nil;
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 秘钥协商数据
- (void)keyAgreementRequestData:(NSString *)userId
                       bussType:(NSString *)bussType
                          token:(NSString *)token
                        success:(success)success
                        failure:(failure)failure
{
    /* 判断参数 */
    //    if (userId == nil || userId.length ==0 || bussType == nil || bussType.length == 0 || token == nil ||token.length == 0 || bRANDS == nil || bRANDS.length == 0 || bTOKEN == nil || bTOKEN.length == 0)
    //    {
    //        NSLog(@"秘钥协商数据参数出错");
    //        return 0;
    //    }
    if (userId == nil || userId.length ==0 || bussType == nil || bussType.length == 0 || token == nil ||token.length == 0 || bRANDS == nil || bRANDS.length == 0)
    {
        NSLog(@"秘钥协商数据请求参数出错");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_DATA_REQUEST_PARAMETER_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_DATA_REQUEST_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 安\n分割token */
    NSArray * tokens = [token componentsSeparatedByString:SPLIT];
    if (tokens.count < 2 || ![[tokens objectAtIndex:0] isEqualToString:@"00"])
    {
        NSLog(@"秘钥协商数据的token错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_DATA_TOKEN_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_DATA_TOKEN_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* ZSB */
    NSString * cipher = [tokens objectAtIndex:1];
    NSString * plain = [[NSString alloc]init];
    [NIST_SSL decryptZSB:cipher plaintxt:&plain];
    
    /* 按\n分割plain */
    NSString * temp = [NIST_Tool stringFromHexString:plain];
    tokens = [temp componentsSeparatedByString:SPLIT];
    
    /* 业务类型不匹配 */
    if (tokens == nil || tokens.count < 4 || ![userId isEqualToString:[tokens objectAtIndex:0]] || ![bussType isEqualToString:[tokens objectAtIndex:1]])
    {
        NSLog(@"秘钥协商数据业务类型不匹配");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_DATA_BUSINESS_TYPE_DOES_NOT_MATCH],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_DATA_BUSINESS_TYPE_DOES_NOT_MATCH_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 获取协商类型 */
    NSString * strategy = [tokens objectAtIndex:2];
    
    /* bTOKEN去盐 */
    bTOKEN = [tokens objectAtIndex:3];
    NSString * btoken = [[NSString alloc]init];
    [NIST_SSL daSalt:bRANDS data:bTOKEN ouput:&btoken];
    
    /* ZTA&&ZTB */
    NSString * cipher1 = [[NSString alloc]init];
    [NIST_SSL encryptZTA:bRANDS ciphertxt:&cipher1];
    [NIST_SSL decryptZTB:cipher1 plaintxt:&cipher1];
    
    /* ZUA&&ZUB */
    NSString * cipher2 = [[NSString alloc]init];
    [NIST_SSL encryptZUA:btoken ciphertxt:&cipher2];
    [NIST_SSL decryptZUB:cipher2 plaintxt:&cipher2];
    
    /* 去盐 */
    [NIST_SSL daSalt:cipher1 data:cipher2 ouput:&cipher2];
    
    /* 填充数据 */
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 用户标识 */
    [msgBuffer appendString:userId];
    [msgBuffer appendString:splitChar];
    /* 业务类型 */
    [msgBuffer appendString:bussType];
    [msgBuffer appendString:splitChar];
    /* 协商策略 */
    [msgBuffer appendString:strategy];
    [msgBuffer appendString:splitChar];
    /* 终端编号 */
    [msgBuffer appendString:sTERM_ID];
    [msgBuffer appendString:splitChar];
    /* 会话标识 */
    [msgBuffer appendString:bSESSION_ID];
    [msgBuffer appendString:splitChar];
    /* 协商过程数据 */
    [msgBuffer appendString:cipher2];
    [msgBuffer appendString:splitChar];
    
    /* 填充为8的整数倍 */
    msgBuffer = [NIST_Tool stringPadding:msgBuffer cnt:8 padding:splitChar];
    
    /* ZSA加密 */
    [NIST_SSL encryptZSA:[NIST_Tool hexStringFromString:msgBuffer] ciphertxt:&cipher];
    
    /* 生成请求数据 */
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_2,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 秘钥协商认证
- (void)keyAgreementResponseData:(NSString *)userId
                        bussType:(NSString *)bussType
                           token:(NSString *)token
                         success:(success)success
                         failure:(failure)failure
{
    /* 判断参数 */
    if (userId == nil || userId.length == 0 || bussType == nil || bussType.length == 0 || token == nil || token.length == 0 || bRANDS == nil || bRANDS.length == 0 || bTOKEN == nil || bTOKEN.length ==0)
    {
        NSLog(@"秘钥协商认证请求参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_PARAMETER_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 按\n分割token */
    NSArray * tokens = [token componentsSeparatedByString:SPLIT];
    if (tokens == nil || tokens.count < 2 || ![[tokens objectAtIndex:0] isEqualToString:@"00"])
    {
        NSLog(@"秘钥协商认证请求的token错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKEN_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKEN_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* ZSB */
    NSString * cipher = [tokens objectAtIndex:1];
    NSString * plain = [[NSString alloc]init];
    [NIST_SSL decryptZSB:cipher plaintxt:&plain];
    NSString * temp = [NIST_Tool stringFromHexString:plain];
    
    /* 按\n分割temp */
    tokens = [temp componentsSeparatedByString:SPLIT];
    if (tokens == nil || tokens.count < 4)
    {
        NSLog(@"秘钥协商认证请求的tokens错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKENS_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKENS_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    if (![userId isEqualToString:[tokens objectAtIndex:0]] || ![bussType isEqualToString:[tokens objectAtIndex:1]])
    {
        return;
    }
    
    /* ZTA&&ZTB */
    NSString * cipher1 = [[NSString alloc]init];
    NSString * btoken = [[NSString alloc]init];
    
    [NIST_SSL daSalt:bRANDS data:bTOKEN ouput:&btoken];
    
    [NIST_SSL encryptZTA:btoken ciphertxt:&cipher1];
    [NIST_SSL decryptZTB:cipher1 plaintxt:&cipher1];
    
    /* ZUA&&ZUB */
    NSString * cipher2 = [[NSString alloc]init];
    [NIST_SSL encryptZUA:bRANDS ciphertxt:&cipher2];
    [NIST_SSL decryptZUB:cipher2 plaintxt:&cipher2];
    
    /* cipher2去盐 */
    [NIST_SSL daSalt:cipher1 data:cipher2 ouput:&cipher2];
    if (![cipher2 isEqualToString:[tokens objectAtIndex:3]])
    {
        return;
    }
    
    /* ZTA(bRANDS), ZUA(cipher) */
    [NIST_SSL encryptZTA:bRANDS ciphertxt:&cipher];
    [NIST_SSL daSalt:btoken data:cipher ouput:&cipher];
    [NIST_SSL encryptZUA:cipher ciphertxt:&cipher];
    
    /* 设置bZW_KEY */
    NSString * key = [[NSString alloc]init];
    [NIST_SSL decryptZUB:cipher plaintxt:&key];
    bZW_KEY = key;
    [NIST_SSL decryptZTB:bZW_KEY plaintxt:&key];
    bZW_KEY = key;
    
    NSString * keyF = [key substringWithRange:NSMakeRange(0, 32)];
    NSString * keyS = [key substringWithRange:NSMakeRange(32, 32)];
    [NIST_SSL daSalt:keyF data:keyS ouput:&key];
    bZW_KEY = key;
    
    /* 填充数据 */
    NSMutableString * msgBuffer = [[NSMutableString alloc]init];
    /* 用户标识 */
    [msgBuffer appendString:userId];
    [msgBuffer appendString:splitChar];
    /* 业务类型 */
    [msgBuffer appendString:bussType];
    [msgBuffer appendString:splitChar];
    /* 协商策略 */
    [msgBuffer appendString:[tokens objectAtIndex:2]];
    [msgBuffer appendString:splitChar];
    /* 终端编号 */
    [msgBuffer appendString:sTERM_ID];
    [msgBuffer appendString:splitChar];
    /* 会话标识 */
    [msgBuffer appendString:bSESSION_ID];
    [msgBuffer appendString:splitChar];
    /* 协商过程数据 */
    [msgBuffer appendString:cipher];
    [msgBuffer appendString:splitChar];
    
    /* 填充为8的整数倍 */
    msgBuffer = [NIST_Tool stringPadding:msgBuffer cnt:8 padding:splitChar];
    
    /* ZSA加密 */
    [NIST_SSL encryptZSA:[NIST_Tool hexStringFromString:msgBuffer] ciphertxt:&cipher];
    
    /* 生成请求数据 */
    __block NSDictionary * dict;
    [[NIST_WB_SDK shareInstance]getVersion:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    NSString * request = [NSString stringWithFormat:@"%@%@%@%@%@",[dict objectForKey:@"Msg"],splitChar,bDFV_2,splitChar,cipher];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":request ? request : @""
                           };
    success(dic);
    return;
}

#pragma mark - 秘钥协商确认
- (void)keyAgreementConfirm:(NSString *)userId
                   bussType:(NSString *)bussType
                      token:(NSString *)token
                    success:(success)success
                    failure:(failure)failure
{
    /* 判断参数 */
    if (userId == nil || userId.length ==0 || bussType == nil || bussType.length == 0 || token == nil || token.length == 0 || bRANDS == nil || bRANDS.length == 0 || bTOKEN == nil || bTOKEN.length == 0)
    {
        NSLog(@"秘钥协商确认参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_CONFIRM_PARAMETER_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_CONFIRM_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 按\n分割token */
    NSArray * tokens = [token componentsSeparatedByString:SPLIT];
    if (tokens == nil || tokens.count < 2 || ![[tokens objectAtIndex:0] isEqualToString:@"00"])
    {
        bZW_KEY = nil;
        return;
    }
    
    /* 用协商密钥进行解密 */
    NSString * cipher = [tokens objectAtIndex:1];
    NSString * plain =[[NSString alloc]init];
    if (bZW_KEY == nil || cipher == nil || cipher.length == 0 || (cipher.length % 16) != 0)
    {
        NSLog(@"秘钥协商认证返回数据错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNS_DATA_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNS_DATA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    if (0 != [NIST_SSL sm4_decrypt:cipher plain:&plain key:bZW_KEY])
    {
        NSLog(@"秘钥协商SM4解密失败");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_SM4_DECRYPTION_FAILED],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_SM4_DECRYPTION_FAILED_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 按\n分割plain */
    NSString * temp = [NIST_Tool stringFromHexString:plain];
    tokens = [temp componentsSeparatedByString:SPLIT];
    if (tokens == nil || tokens.count < 4)
    {
        NSLog(@"秘钥协商认证返回的token错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNED_TOKEN_ERROR],
                               @"Msg":NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNED_TOKEN_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    if (![userId isEqualToString:[tokens objectAtIndex:0]] || ![bussType isEqualToString:[tokens objectAtIndex:1]])
    {
        return;
    }
    
    /* 动态白盒 */
    if ([@"ZALG" isEqualToString:[tokens objectAtIndex:2]])
    {
        NSString * zw = [tokens objectAtIndex:3];
        if (zw == nil || zw.length == 0)
        {
            NSLog(@"zw计算出错");
            NSDictionary * dic = @{
                                   @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_CALCULATE_ZW_ERROR],
                                   @"Msg":NIST_CALCULATE_ZW_ERROR_MSG
                                   };
            failure(dic);
            return;
        }
        [[NIST_Read_Write shareInstance]readWriteKey:FILE_DYN_ZALG Value:zw];
    }
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SUCCESS],
                           @"Msg":NIST_SECRET_KEY_NEGOTIATION_CONFIRM_PASS
                           };
    success(dic);
    return;
}

#pragma mark - 设置安全模块PIN码
- (void)setSecPin:(NSInteger)mode
              pin:(NSString *)pin
          success:(success)success
          failure:(failure)failure
{
    NSString * mask0 = @"KEY5678BORAD1234";
    NSString * mask1 = @"BOARD1234KEY5678";
    char mask0i[mask0.length];
    char mask1i[mask1.length];
    strcpy(mask0i, [mask0 UTF8String]);
    strcpy(mask1i, [mask1 UTF8String]);
    
    if (pin == nil || pin.length == 0)
    {
        NSLog(@"pin码为空");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_PIN_NUMBER_IS_EMPTY],
                               @"Msg":NIST_PIN_NUMBER_IS_EMPTY_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 0设置 1验证 */
    pin = [pin uppercaseString];
    NSMutableString * TEMP_PIN = [[NSMutableString alloc]init];
    if (mode == 0)
    {
        sSEC_PIN = @"01";
    }
    else
    {
        sSEC_PIN = @"02";
    }
    [TEMP_PIN appendString:sSEC_PIN];
    
    /* pin码混淆 */
    int idx;
    for (int i = 0; i < pin.length; i++)
    {
        char temp[pin.length];
        strcpy(temp, [pin UTF8String]);
        char tmp = temp[i];
        if (tmp >= '0' && tmp <= '9')
        {
            idx = tmp - '0';
        }
        else if (tmp >= 'A' && tmp <= 'F')
        {
            idx = tmp - 'A' + 10;
        }
        else
        {
            sSEC_PIN = nil;
            return;
        }
        
        if (mode == 0)
        {
            [TEMP_PIN appendString:[NSString stringWithFormat:@"%c",mask0i[idx]]];
        }
        else
        {
            [TEMP_PIN appendString:[NSString stringWithFormat:@"%c",mask1i[idx]]];
        }
    }
    sSEC_PIN = [NSString stringWithFormat:@"%@",TEMP_PIN];
    NSDictionary * dic = @{
                           @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                           @"Msg":NIST_SET_PIN_SUCCESS
                           };
    success(dic);
    return;
}

#pragma mark - 申请安全模块
- (void)applySecModule:(success)success
               failure:(failure)failure
{
    /* 获取安全模块版本号 */
    char ver[48];
    getVersion(ver);
    NSString * version = [NSString stringWithFormat:@"%s",ver];
    
    /* 枚举特征信息 */
//    NSString * devFeature = [self probeDeviceFeatures];
//    if (devFeature == nil || devFeature.length == 0)
//    {
//        NSLog(@"枚举硬件特征信息错误");
//        NSDictionary * dic = @{
//                               @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_ENUMERATE_HARDWARE_FEATURE_INFORMATION_ERROR],
//                               @"Msg":@"枚举硬件特征信息错误"
//                               };
//        failure(dic);
//        return;
//    }
    __block NSDictionary * dict;
    NSString * devFeature;
    [[NIST_WB_SDK shareInstance]probeDeviceFeatures:^(NSDictionary *data) {
        dict = data;
    } failure:^(NSDictionary *error) {
        dict = error;
    }];
    if ([[dict objectForKey:@"ErrorCode"] integerValue] != 100000)
    {
        failure(dict);
        return;
    }
    else
    {
        devFeature = [dict objectForKey:@"Msg"];
    }
    
    /* 拼接字符串 */
    NSString * module = [NSString stringWithFormat:@"%@%@%@",version,splitChar,devFeature];
    NSDictionary * dic = @{
                            @"ErrorCode":[NSString stringWithFormat:@"%ld",(long)NIST_SUCCESS],
                            @"Msg":module ? module : @""
                            };
    success(dic);
    return;
}

#pragma mark - 安装安全模块
- (void)installSecModule:(NSString *)data
                 success:(success)success
                 failure:(failure)failure
{
    /* 判断参数是否出错 */
    if (data == nil || data.length == 0)
    {
        NSLog(@"装载安全模块参数错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_LOAD_SECURITY_MODULE_PARAMETER_ERROR],
                               @"Msg":NIST_LOAD_SECURITY_MODULE_PARAMETER_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 按\n分割data */
    NSArray * moduleArr = [data componentsSeparatedByString:SPLIT];
    if(moduleArr.count < 4)
    {
        NSLog(@"申请安全模块返回数据错误");
        NSDictionary * dic = @{
                               @"ErrorCode":[NSString stringWithFormat:@"%d",NIST_SECURITY_MODULE_APPLICATION_RETURNS_DATA_ERROR],
                               @"Msg":NIST_SECURITY_MODULE_APPLICATION_RETURNS_DATA_ERROR_MSG
                               };
        failure(dic);
        return;
    }
    
    /* 写入公钥文件 */
    [[NIST_Read_Write shareInstance]readWriteKey:FILE_PUK_CERT_VERSION Value:[moduleArr objectAtIndex:0]];
    [[NIST_Read_Write shareInstance]readWriteKey:FILE_PUK_CERT_SIGN_PUBKEY Value:[moduleArr objectAtIndex:1]];
    [[NIST_Read_Write shareInstance]readWriteKey:FILE_PUK_CERT_ENCRYPT_PUBKEY Value:[moduleArr objectAtIndex:2]];
    [[NIST_Read_Write shareInstance]readWriteKey:FILE_PUK_CERT_SIGN_VALUE Value:[moduleArr objectAtIndex:3]];
    
    NSDictionary * dic = @{
                           @"ErrorCode":@"100000",
                           @"Msg":NIST_SECURITY_MODULE_IS_LOADED_SUCCESS
                           };
    success(dic);
    return;
}

#pragma mark - sm4加解密
- (int)sm4_encrypt:(NSString *)plain
            cipher:(NSString *__autoreleasing *)cipher
{
    if (plain == nil || plain.length == 0 || cipher == NULL || bZW_KEY == nil || bZW_KEY.length == 0)
    {
        return -1;
    }
    //    NSData * plainNSData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    //    NSData * keyNSData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData * plainNSData = [NIST_Tool nsdataFromHexString:plain];
    NSData * keyNSData = [NIST_Tool nsdataFromHexString:bZW_KEY];
    unsigned char plainData[[plainNSData length]];
    unsigned char keyData[[keyNSData length]];
    unsigned char cipherData[[plainNSData length]];
    memcpy(plainData, [plainNSData bytes], (int)[plainNSData length]);
    memcpy(keyData, [keyNSData bytes], (int)[keyNSData length]);
    if (0 != SM4_encrypt(plainData, (int)sizeof(plainData), cipherData, keyData))
    {
        return -1;
    }
    NSString * cipherStr = [NIST_Tool stringFromByte:cipherData len:sizeof(cipherData)];
    *cipher = cipherStr;
    return 0;
}

- (int)sm4_decrypt:(NSString *)cipher
             plain:(NSString *__autoreleasing *)plain
{
    if (cipher == nil || cipher.length == 0 || plain == NULL || bZW_KEY == nil || bZW_KEY.length == 0)
    {
        return -1;
    }
    //    NSData * ciphertNSData = [cipher dataUsingEncoding:NSUTF8StringEncoding];
    //    NSData * keyNSData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData * ciphertNSData = [NIST_Tool nsdataFromHexString:cipher];
    NSData * keyNSData = [NIST_Tool nsdataFromHexString:bZW_KEY];
    unsigned char cipherData[[ciphertNSData length]];
    unsigned char keyData[[keyNSData length]];
    unsigned char plainData[[ciphertNSData length]];
    memcpy(cipherData, [ciphertNSData bytes], (int)[ciphertNSData length]);
    memcpy(keyData, [keyNSData bytes], (int)[keyNSData length]);
    if (0 != SM4_decrypt(cipherData, (int)sizeof(cipherData), plainData, keyData))
    {
        return -1;
    }
    NSString * plainStr = [NIST_Tool stringFromByte:plainData len:sizeof(plainData)];
    *plain = plainStr;
    return 0;
}

#pragma mark - MLeaksFinder（内存泄漏检测工具）
- (BOOL)willDealloc
{
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf assertNotDealloc];
    });
    return YES;
}

- (void)assertNotDealloc
{
    NSAssert(NO, @"内存泄漏");
}

@end
