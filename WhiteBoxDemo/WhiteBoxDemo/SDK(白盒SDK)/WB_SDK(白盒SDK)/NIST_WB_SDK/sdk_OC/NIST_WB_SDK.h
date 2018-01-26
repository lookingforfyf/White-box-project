//
//  NIST_WB_SDK.h
//  WhiteBoxSDK(白盒SDK)
//
//  Created by 范云飞 on 2017/10/30.
//  Copyright © 2017年 范云飞. All rights reserved.
//


/***********************************************
 本类主要负责：
 1.业务处理类，最终要暴露给用户使用的SDK头文件
 ***********************************************/
#import <Foundation/Foundation.h>

#pragma mark - SDK操作成功或者失败的回调
typedef void(^success)(NSDictionary * data);
typedef void(^failure)(NSDictionary * error);

#pragma mark - sdk_C头文件
#import "NIST_WB_SDK_Header.h"
#import "NIST_WB_SDK_Model.h"

#pragma mark - 分隔符
#define SPLIT_CHAR          @"\n";                                                               /* 分隔符(填充数据时用) */
#define SPLIT               @"\n"                                                                /* 分割数据 */

#pragma mark - 白盒SDK操作的状态码
/**
 成功
 */
#define NIST_SUCCESS                                                              100000                    /* 成功 */
#define NIST_SUCCESS_MSG                                                          @"成功"

/**
 获取安全模块版本号
 */
#define NIST_FAIL_TO_GET_SECURITY_MODULE_VERSION_NUMBER                           100001                    /* 获取安全模块版本号失败 */
#define NIST_FAIL_TO_GET_SECURITY_MODULE_VERSION_NUMBER_MSG                       @"获取安全模块版本号失败"

/**
 设备安全模块自检
 */
#define NIST_DEVICE_FAILED_TO_SELF_CHECK                                          100002                    /* 设备自检失败 */
#define NIST_DEVICE_FAILED_TO_SELF_CHECK_MSG                                      @"设备自检失败"

#define NIST_PUBLIC_KEY_FILE_IS_EMPTY                                             100003                    /* 公钥文件为空 */
#define NIST_PUBLIC_KEY_FILE_IS_EMPTY_MSG                                         @"公钥文件缓存为空"

#define NIST_PUBLIC_KEY_FILE_LENGTH_ERROR                                         100004                    /* 公钥文件长度错误 */
#define NIST_PUBLIC_KEY_FILE_LENGTH_ERROR_MSG                                     @"公钥文件长度错误"

#define NIST_CALCULATE_ZA_ERROR                                                   100005                    /* 计算za错误 */
#define NIST_CALCULATE_ZA_ERROR_MSG                                               @"计算za错误"

#define NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED                            100006                    /* 加密公钥验签失败 */
#define NIST_ENCRYPTION_PUBLIC_KEY_VERIFICATION_FAILED_MSG                        @"加密公钥验签失败"

#define NIST_SECURITY_MODULE_SELF_CHECK_SUCCESS_MAG                               @"安全模块自检通过"          /* 安全模块自检通过 */

/**
 生成随机数
 */
#define NIST_CALCULATE_RANDOM_NUMBER_ERROR                                        100007                    /* 计算随机数错误 */
#define NIST_CALCULATE_RANDOM_NUMBER_ERROR_MSG                                    @"计算随机数错误"

/**
 枚举硬件特征信息
 */
#define NIST_ENUMERATE_HARDWARE_FEATURE_INFORMATION_ERROR                         100008                    /* 枚举硬件特征信息错误 */
#define NIST_ENUMERATE_HARDWARE_FEATURE_INFORMATION_ERROR_MSG                     @"枚举硬件特征信息错误"

#define NIST_FEATURE_INFORMATION_SM3_CALCULATION_FAILED                           100009                    /* 特征信息SM3HASH计算失败 */
#define NIST_FEATURE_INFORMATION_SM3_CALCULATION_FAILED_MSG                       @"特征信息SM3HASH计算错误"

#define NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT            100010                    /* 两次枚举的硬件特征信息不相同 */
#define NIST_HARDWARE_CHARACTERISTICS_OF_TWO_ENUMERATION_ARE_DIFFERENT_MSG        @"两次枚举的硬件特征信息不相同"

#define NIST_CALCULATED_BDFV1_IS_DIFFERENT                                        100011                    /* 两次计算的bDFV_1不相同 */
#define NIST_CALCULATED_BDFV1_IS_DIFFERENT_MSG                                    @"两次计算的bDFV_1不相同"

/**
 终端编号核验
 */
#define NIST_TERMINAL_NUMBER_OR_SIGNATURE_IS_BLANK                                100012                    /* 终端编号或签名为空 */
#define NIST_TERMINAL_NUMBER_OR_SIGNATURE_IS_BLANK_MSG                            @"终端编号或签名为空"

#define NIST_TERMINAL_NUMBER_SIGNATURE_VERIFICATION_FAILED                        100013                    /* 终端编号签名验签失败 */
#define NIST_TERMINAL_NUMBER_SIGNATURE_VERIFICATION_FAILED_MSG                    @"终端编号签名验签失败"

#define NIST_TERMINAL_NUMBER_CHECK_PASS                                           @"终端编号核验通过"          /* 终端编号核验通过 */

/**
 安全认证码核验
 */
#define NIST_TERMINAL_NUMBER_FILE_IS_EMPTY                                        100015                    /* 终端编号文件为空 */
#define NIST_TERMINAL_NUMBER_FILE_IS_EMPTY_MSG                                    @"终端编号文件为空"

#define NIST_CALCULATE_ZCODE_FAILED                                               100016                    /* 计算ZCODE失败 */
#define NIST_CALCULATE_ZCODE_FAILED_MSG                                           @"计算ZCODE失败"

#define NIST_SECURITY_AUTHENTICATION_CODE_CHECK_FAILED                            100017                    /* 安全认证码核验失败 */
#define NIST_SECURITY_AUTHENTICATION_CODE_CHECK_FAILED_MSG                        @"安全认证码核验失败"

#define NIST_SECURITY_AUTHENTICATION_CODE_CHECK_PASS                              @"安全认证码核验通过"        /* 安全认证码核验通过 */

/**
 计算安全DFV2
 */
#define NIST_CALCULATE_BDFV2_ERROR                                                100018                    /* 计算bDFV_2错误 */
#define NIST_CALCULATE_BDFV2_ERROR_MSG                                            @"计算bDFV_2错误"

/**
 终端编号申请数据
 */
#define NIST_APPLY_FOR_TERMINAL_NUMBER_DATA_ENCRYPTION_FAILURE                    100019                    /* 申请终端编号数据加密失败 */
#define NIST_APPLY_FOR_TERMINAL_NUMBER_DATA_ENCRYPTION_FAILURE_MSG                @"申请终端编号数据加密失败"

/**
 终端编号装载
 */
#define NIST_TERMINAL_NUMBER_LOADING_PARAMETER_ERROR                              100020                    /* 终端编号装载参数错误 */
#define NIST_TERMINAL_NUMBER_LOADING_PARAMETER_ERROR_MSG                          @"终端编号装载参数错误"

#define NIST_APPLY_FOR_TERMINAL_NUMBER_RESPONSE_DATA_ERROR                        100021                    /* 申请终端编号应答数据错误 */
#define NIST_APPLY_FOR_TERMINAL_NUMBER_RESPONSE_DATA_ERROR_MSG                    @"申请终端编号应答数据错误"

#define NIST_TERMINAL_NUMBER_LOADING_SUCCESS                                      @"终端编号装载成功"          /* 终端编号装载成功 */

/**
 双向认证申请
 */
#define NIST_TWOWAY_AUTHENTICATION_APPLICATION_PARAMETER_ERROR                    100022                    /* 双向认证申请参数错误 */
#define NIST_TWOWAY_AUTHENTICATION_APPLICATION_PARAMETER_ERROR_MSG                @"双向认证申请参数错误"

#define NIST_TWOWAY_AUTHENTICATION_APPLICATION_DATA_ENCRYPTION_FAILED             100023                    /* 双向认证申请数据加密失败 */
#define NIST_TWOWAY_AUTHENTICATION_APPLICATION_DATA_ENCRYPTION_FAILED_MSG         @"双向认证申请数据加密失败"

/**
 挑战码认证数据
 */
#define NIST_CHALLENGE_CODE_AUTHENTICATION_DATA_REQUEST_PARAMETER_ERROR           100024                    /* 挑战码认证数据请求参数错误 */
#define NIST_CHALLENGE_CODE_AUTHENTICATION_DATA_REQUEST_PARAMETER_ERROR_MSG       @"挑战码认证数据请求参数错误"

/**
 挑战码反向认证
 */
#define NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_PARAMETER_ERROR                100025                    /* 挑战码反向认证参数错误 */
#define NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_PARAMETER_ERROR_MSG            @"挑战码反向认证参数错误"

#define NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_TOKEN_DATA_ERROR               100026                    /* 挑战码反向认证的token数据错误 */
#define NIST_CHALLENGE_CODE_REVERSE_AUTHENTICATION_TOKEN_DATA_ERROR_MSG           @"挑战码反向认证的token数据错误"

#define NIST_CALCULATE_SESSIONID_FAILURE                                          100027                    /* 计算session_id失败 */
#define NIST_CALCULATE_SESSIONID_FAILURE_MSG                                      @"计算session_id失败"

#define NIST_CHALLEGNE_CODE_REVERSE_AUTHENTICATION_PASS                           @"挑战码反向认证通过"        /* 挑战码反向认证通过 */

/**
 用户绑定申请
 */
#define NIST_USER_BINDING_APPLICATION_PARAMETER_ERROR                             100028                     /* 用户绑定申请参数错误 */
#define NIST_USER_BINDING_APPLICATION_PARAMETER_ERROR_MSG                         @"用户绑定申请参数错误"

/**
 用户绑定认证数据
 */
#define NIST_USER_BINGDING_AUTHENTICATION_DATA_PARAMETER_ERROR                    100029                    /* 用户绑定认证数据参数错误 */
#define NIST_USER_BINGDING_AUTHENTICATION_DATA_PARAMETER_ERROR_MSG                @"用户绑定认证数据参数错误"

/**
 用户绑定反向认证
 */
#define NIST_USER_BINDING_REVERSE_AUTHENTICATION_PARAMETER_ERROR                  100030                    /* 用户绑定反向认证参数出错 */
#define NIST_USER_BINDING_REVERSE_AUTHENTICATION_PARAMETER_ERROR_MSG              @"用户绑定反向认证参数出错"

#define NIST_USER_BINDING_REVERSE_AUTHENTICATION_DATA_SMHASH_FAILED               100031                    /* 用户绑定反向认证数据SM3HASH失败 */
#define NIST_USER_BINDING_REVERSE_AUTHENTICATION_DATA_SMHASH_FAILED_MSG           @"用户绑定反向认证数据SM3HASH失败"

#define NIST_USER_BINDING_REVERSE_AUTHENTICATION_PASS                             @"用户绑定反向认证通过"      /* 用户绑定反向认证通过 */

/**
 用户登录认证数据
 */
#define NIST_USER_LOGIN_AUTHENTICATION_DATA_PARAMETER_ERROR                       100032                    /* 用户登录认证数据参数出错 */
#define NIST_USER_LOGIN_AUTHENTICATION_DATA_PARAMETER_ERROR_MSG                   @"用户登录认证数据参数出错"

/**
 用户登录认证结果
 */
#define NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_PARAMETER_ERROR                100033                    /* 用户登录认证结果数据参数错误 */
#define NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_PARAMETER_ERROR_MSG            @"用户登录认证结果数据参数错误"

#define NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_SM3HASH_FAILED                 100034                    /* 用户登录认证结果数据SM3HASH失败 */
#define NIST_USER_LOGIN_AUTHENTICATION_RESULT_DATA_SM3HASH_FAILED_MSG             @"用户登录认证结果数据SM3HASH失败"

#define NIST_USER_LOGIN_AUTHENTICATION_RESULT_PASS                                @"用户登录认证结果通过"      /* 用户登录认证结果通过 */

/**
 秘钥协商申请
 */
#define NIST_SECRET_KEY_NEGOTIATION_APPLICATION_REQUEST_PARAMETER_ERROR           100035                    /* 秘钥协商申请请求参数错误 */
#define NIST_SECRET_KEY_NEGOTIATION_APPLICATION_REQUEST_PARAMETER_ERROR_MSG       @"秘钥协商申请请求参数错误"

/**
 秘钥协商数据
 */
#define NIST_SECRET_KEY_NEGOTIATION_DATA_REQUEST_PARAMETER_ERROR                  100036                    /* 秘钥协商数据请求参数出错 */
#define NIST_SECRET_KEY_NEGOTIATION_DATA_REQUEST_PARAMETER_ERROR_MSG              @"秘钥协商数据请求参数出错"

#define NIST_SECRET_KEY_NEGOTIATION_DATA_TOKEN_ERROR                              100037                    /* 秘钥协商数据的token错误 */
#define NIST_SECRET_KEY_NEGOTIATION_DATA_TOKEN_ERROR_MSG                          @"秘钥协商数据的token错误"

#define NIST_SECRET_KEY_NEGOTIATION_DATA_BUSINESS_TYPE_DOES_NOT_MATCH             100038                    /* 秘钥协商数据业务类型不匹配 */
#define NIST_SECRET_KEY_NEGOTIATION_DATA_BUSINESS_TYPE_DOES_NOT_MATCH_MSG         @"秘钥协商数据业务类型不匹配"

/**
 秘钥协商认证
 */
#define NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_PARAMETER_ERROR         100039                    /* 秘钥协商认证请求参数错误 */
#define NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_PARAMETER_ERROR_MSG     @"秘钥协商认证请求参数错误"

#define NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKEN_ERROR             100040                    /* 秘钥协商认证请求的token错误 */
#define NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKEN_ERROR_MSG         @"秘钥协商认证请求的token错误"

#define NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKENS_ERROR            100041                    /* 秘钥协商认证请求的tokens错误 */
#define NIST_SECRET_KEY_NEGOTIATES_AUTHENTICATION_REQUEST_TOKENS_ERROR_MSG        @"秘钥协商认证请求的tokens错误"

/**
 秘钥协商确认
 */
#define NIST_SECRET_KEY_NEGOTIATION_CONFIRM_PARAMETER_ERROR                       100042                    /* 秘钥协商确认参数错误 */
#define NIST_SECRET_KEY_NEGOTIATION_CONFIRM_PARAMETER_ERROR_MSG                   @"秘钥协商确认参数错误"

#define NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNS_DATA_ERROR             100043                    /* 秘钥协商认证返回数据错误 */
#define NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNS_DATA_ERROR_MSG         @"秘钥协商认证返回数据错误"

#define NIST_SECRET_KEY_NEGOTIATION_SM4_DECRYPTION_FAILED                         100044                    /* 秘钥协商SM4解密失败 */
#define NIST_SECRET_KEY_NEGOTIATION_SM4_DECRYPTION_FAILED_MSG                     @"秘钥协商SM4解密失败"

#define NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNED_TOKEN_ERROR           100045                    /* 秘钥协商认证返回的token错误 */
#define NIST_SECRET_KEY_NEGOTIATION_AUTHENTICATION_RETURNED_TOKEN_ERROR_MSG       @"秘钥协商认证返回的token错误"

#define NIST_CALCULATE_ZW_ERROR                                                   100046                    /* zw计算出错 */
#define NIST_CALCULATE_ZW_ERROR_MSG                                               @"zw计算出错"

#define NIST_SECRET_KEY_NEGOTIATION_CONFIRM_PASS                                  @"秘钥协商确认通过"          /* 秘钥协商确认通过 */

/**
 设置安全模块PIN码
 */
#define NIST_PIN_NUMBER_IS_EMPTY                                                  100047                    /* PIN码为空 */
#define NIST_PIN_NUMBER_IS_EMPTY_MSG                                              @"pin码为空"

#define NIST_SET_PIN_SUCCESS                                                      @"pin码设置成功"            /* pin码设置成功 */

/**
 安装安全模块
 */
#define NIST_LOAD_SECURITY_MODULE_PARAMETER_ERROR                                 100048                    /* 装载安全模块的的参数错误 */
#define NIST_LOAD_SECURITY_MODULE_PARAMETER_ERROR_MSG                             @"装载安全模块参数错误"

#define NIST_SECURITY_MODULE_APPLICATION_RETURNS_DATA_ERROR                       100049                    /* 申请安全模块返回数据错误 */
#define NIST_SECURITY_MODULE_APPLICATION_RETURNS_DATA_ERROR_MSG                   @"申请安全模块返回数据错误"

#define NIST_SECURITY_MODULE_IS_LOADED_SUCCESS                                    @"安全模块装载成功"          /* 安全模块装载成功 */

@interface NIST_WB_SDK : NSObject
#pragma mark -
/**
 单例

 @return NIST_WB_SDK
 */
+ (NIST_WB_SDK *)shareInstance;

#pragma mark -
/**
 获取安全模块版本

 @param success 成功回调
 @param failure 失败回调
 */
- (void)getVersion:(success)success
           failure:(failure)failure;

#pragma mark -
/**
 安全模块自检

 @param success 成功回调
 @param failure 失败回调
 */
- (void)selfCheckZSec:(success)success
              failure:(failure)failure;

#pragma mark -
/**
 终端编号核验

 @param success 成功回调
 @param failure 失败回调
 */
- (void)checkTermId:(success)success
            failure:(failure)failure;

#pragma mark -
/**
 安全认证码核验

 @param success 成功回调
 @param failure 失败回调
 */
- (void)checkZcode:(success)success
           failure:(failure)failure;

#pragma mark -
/**
 生成随机数

 @param seed 时间
 @param len 随机数的长度
 @param success 成功回调
 @param failure 失败回调
 */
- (void)generateRands:(NSString *)seed
                  len:(NSInteger)len
              success:(success)success
              failure:(failure)failure;

#pragma mark -
/**
 硬件特征信息枚举

 @param success 成功回调
 @param failure 失败回调
 */
- (void)probeDeviceFeatures:(success)success
                    failure:(failure)failure;

#pragma mark -
/**
 计算含终端编号后的DFV

 @param deviceFeatures deviceFeatures
 @param success 成功回调
 @param failure 失败
 */
- (void)generateDFV2:(NSString *)deviceFeatures
             success:(success)success
             failure:(failure)failure;

#pragma mark -
/**
 生成终端编号申请请求数据

 @param devicefeature deviceFeatures
 @param success 成功回调
 @param failure 失败回调
 */
- (void)createTermIdRequestData:(NSString *)devicefeature
                        success:(success)success
                        failure:(failure)failure;

#pragma mark -
/**
 处理终端编号申请应答数据

 @param deviceFeatures deviceFeatures
 @param termIdData termidData
 @param success 成功回调
 @param failure 失败回调
 */
- (void)setupTermId:(NSString *)deviceFeatures
         termIdData:(NSString *)termIdData
            success:(success)success
            failure:(failure)failure;

#pragma mark -
/**
 生成双向认证申请数据

 @param success 成功回调
 @param failure 失败回调
 */
- (void)applyAuthentication:(success)success
                    failure:(failure)failure;

#pragma mark -
/**
 生成正向认证数据

 @param token token
 @param success 成功回调
 @param failure 失败回调
 */
- (void)tokenRequestData:(NSString *)token
                 success:(success)success
                 failure:(failure)failure;

#pragma mark -
/**
 验证反向认证数据

 @param token token
 @param success 成功回调
 @param failure 失败回调
 */
- (void)tokenResponseDataChecked:(NSString *)token
                         success:(success)success
                         failure:(failure)failure;

#pragma mark -
/**
 用户绑定申请

 @param userId userId
 @param success 成功回调
 @param failure 失败回调
 */
- (void)bandUserLoginDevice:(NSString *)userId
                    success:(success)success
                    failure:(failure)failure;

#pragma mark -
/**
 用户绑定认证数据

 @param mode mode
 @param userId userId
 @param inData inData
 @param success 成功回调
 @param failure 失败回调
 */
- (void)optRequestData:(NSString *)mode
                userId:(NSString *)userId
                inData:(NSString *)inData
               success:(success)success
               failure:(failure)failure;

#pragma mark -
/**
 用户绑定反向认证

 @param userId userId
 @param token token
 @param success 成功回调
 @param failure 失败回调
 */
- (void)optResponseDataChecked:(NSString *)userId
                         token:(NSString *)token
                       success:(success)success
                       failure:(failure)failure;

#pragma mark -
/**
 用户登录认证数据

 @param userId userId
 @param success 成功回调
 @param failure 失败回调
 */
- (void)loginRequestData:(NSString *)userId
                 success:(success)success
                 failure:(failure)failure;

#pragma mark -
/**
 用户登录认证结果

 @param userId userId
 @param token token
 @param success 成功回调
 @param failure 失败回调
 */
- (void)loginResponseDataChecked:(NSString *)userId
                           token:(NSString *)token
                         success:(success)success
                         failure:(failure)failure;

#pragma mark -
/**
 密钥协商申请

 @param userId userId
 @param bussType bussType
 @param success 成功回调
 @param failure 失败回调
 */
- (void)applykeyAgreement:(NSString *)userId
                 bussType:(NSString *)bussType
                  success:(success)success
                  failure:(failure)failure;

#pragma mark -
/**
 密钥协商数据

 @param userId userId
 @param bussType bussType
 @param token token
 @param success 成功回调
 @param failure 失败回调
 */
- (void)keyAgreementRequestData:(NSString *)userId
                       bussType:(NSString *)bussType
                          token:(NSString *)token
                        success:(success)success
                        failure:(failure)failure;

#pragma mark -
/**
 密钥协商认证

 @param userId userId
 @param bussType bussType
 @param token token
 @param success 成功回调
 @param failure 失败回调
 */
- (void)keyAgreementResponseData:(NSString *)userId
                        bussType:(NSString *)bussType
                           token:(NSString *)token
                         success:(success)success
                         failure:(failure)failure;

#pragma mark-
/**
 密钥协商-生成密钥或动态库

 @param userId userId
 @param bussType bussType
 @param token token
 @param success 成功回调
 @param failure 失败回调
 */
- (void)keyAgreementConfirm:(NSString *)userId
                   bussType:(NSString *)bussType
                      token:(NSString *)token
                    success:(success)success
                    failure:(failure)failure;

#pragma mark -
/**
 安全模块PIN码(设置或验证)

 @param mode mode
 @param pin pin
 @param success 成功回调
 @param failure 失败回调
 */
- (void)setSecPin:(NSInteger)mode
              pin:(NSString *)pin
          success:(success)success
          failure:(failure)failure;

#pragma mark -
/**
 申请安全模块

 @param success 成功回调
 @param failure 失败回调
 */
- (void)applySecModule:(success)success
               failure:(failure)failure;

#pragma mark -
/**
 安装安全模块

 @param data data
 @param success 成功回调
 @param failure 失败回调
 */
- (void)installSecModule:(NSString *)data
                 success:(success)success
                 failure:(failure)failure;

#pragma mark -
/**
 SM4算法加密
 
 @param plain 明文
 @param cipher 密文
 @return 0成功 !0失败
 */
- (int)sm4_encrypt:(NSString *)plain
            cipher:(NSString * __autoreleasing *)cipher;

/**
 SM4算法解密
 
 @param cipher 密文
 @param plain 明文
 @return 0成功 !0失败
 */
- (int)sm4_decrypt:(NSString *)cipher
             plain:(NSString * __autoreleasing *)plain;

@end
