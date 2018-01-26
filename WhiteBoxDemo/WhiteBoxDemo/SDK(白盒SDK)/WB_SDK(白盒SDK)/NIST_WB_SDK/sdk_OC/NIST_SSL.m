//
//  NIST_SSL.m
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/12/12.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_SSL.h"

@implementation NIST_SSL
#pragma mark - 单例
static NIST_SSL * nist_ssl = nil;
+ (NIST_SSL *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nist_ssl = [[NIST_SSL alloc]init];
    });
    return nist_ssl;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!nist_ssl)
    {
        nist_ssl = [super allocWithZone:zone];
    }
    return nist_ssl;
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
    
}

#pragma mark - sm3hash算法
+ (NSString *)sm3:(NSString *)msg
{
    if (msg == nil || msg.length == 0)
    {
        return 0;
    }
    NSData * data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    int len = (int)[data length];
    unsigned char msgData[len];
    unsigned char hashData[32];
    memcpy(msgData, [[msg dataUsingEncoding:NSUTF8StringEncoding] bytes], len);
    SM3(msgData, len, hashData);
    NSString * hash = [NIST_Tool stringFromByte:hashData len:32];
    if (hash == nil || hash.length == 0)
    {
        NSLog(@"计算hash错误");
        return 0;
    }
    return hash;
}

#pragma mark - sm2签名验签&&sm2加密解密
+ (void)sm2_init
{
    SM2_init();
}
+ (int)sm2_keypair_generation:(NSString *)rand
                          dic:(NSMutableDictionary *__autoreleasing *)dict
{
    if (rand == nil || rand.length == 0 || dict == NULL)
    {
        return -1;
    }
//    NSData * randNSData = [rand dataUsingEncoding:NSUTF8StringEncoding];
    NSData * randNSData = [NIST_Tool nsdataFromHexString:rand];
    unsigned char randData[[randNSData length]];
    unsigned char privkeyData[32];
    unsigned char pxData[32];
    unsigned char pyData[32];
    memcpy(randData, [randNSData bytes], (int)[randNSData length]);
    if (0 != SM2_keypair_generation(randData, privkeyData, pxData, pyData))
    {
        return -1;
    }
    
    NSString * privkeyStr = [NIST_Tool stringFromByte:privkeyData len:32];
    NSString * pxStr = [NIST_Tool stringFromByte:pxData len:32];
    NSString * pyStr = [NIST_Tool stringFromByte:pyData len:32];
    NSMutableDictionary * keypairDic = [[NSMutableDictionary alloc]init];
    [keypairDic setObject:privkeyStr?privkeyStr:@"" forKey:@"privkey"];
    [keypairDic setObject:pxStr?pxStr:@"" forKey:@"px"];
    [keypairDic setObject:pyStr?pyStr:@"" forKey:@"py"];
    *dict = keypairDic;
    return 0;
}
+ (int)sm2_sign_pre:(NSString *)px
                 py:(NSString *)py
                 za:(NSString *__autoreleasing *)za
{
    if (px == nil || py == nil || za == NULL)
    {
        return -1;
    }
    NSData * pxNSData = [NIST_Tool nsdataFromHexString:px];
    NSData * pyNSData = [NIST_Tool nsdataFromHexString:py];
    unsigned char pxData[[pxNSData length]];
    unsigned char pyData[[pyNSData length]];
    unsigned char zaData[32];
    memcpy(pxData, [pxNSData bytes], (int)[pxNSData length]);
    memcpy(pyData, [pyNSData bytes], (int)[pyNSData length]);
    SM2_sign_pre(pxData, pyData, zaData);
    NSString * zaStr = [NIST_Tool stringFromByte:zaData len:32];
    *za = zaStr;
    return 0;
}
+ (int)sm2_sign:(NSString *)privkey
             za:(NSString *)za
            msg:(NSString *)msg
           rand:(NSString *)rand
           dict:(NSMutableDictionary *__autoreleasing *)dict
{
    if (privkey == nil || privkey.length == 0 || za == nil || za.length == 0 || msg == nil || msg.length == 0 || rand == nil || rand.length == 0 || dict == NULL)
    {
        return -1;
    }
//    NSData * privkeyNSData = [privkey dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * zaNSData = [za dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * msgNSData = [msg dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * randNSData = [rand dataUsingEncoding:NSUTF8StringEncoding];
    NSData * privkeyNSData = [NIST_Tool nsdataFromHexString:privkey];
    NSData * zaNSData = [NIST_Tool nsdataFromHexString:za];
    NSData * msgNSData = [NIST_Tool nsdataFromHexString:msg];
    NSData * randNSData = [NIST_Tool nsdataFromHexString:rand];
    unsigned char privkeyData[[privkeyNSData length]];
    unsigned char zaData[[zaNSData length]];
    unsigned char msgData[[msgNSData length]];
    unsigned char randData[[msgNSData length]];
    unsigned char signRData[32];
    unsigned char signSData[32];
    memcpy(privkeyData, [privkeyNSData bytes], (int)[privkeyNSData length]);
    memcpy(zaData, [zaNSData bytes], (int)[zaNSData length]);
    memcpy(msgData, [msgNSData bytes], (int)[msgNSData length]);
    memcpy(randData, [randNSData bytes], (int)[randNSData length]);
    if (0 != SM2_sign(privkeyData, zaData, msgData, (int)sizeof(msgData), randData, signRData, signSData))
    {
        return -1;
    }
    NSString * signRStr = [NIST_Tool stringFromByte:signRData len:32];
    NSString * signSStr = [NIST_Tool stringFromByte:signSData len:32];
    NSMutableDictionary * signDic = [[NSMutableDictionary alloc]init];
    [signDic setObject:signRStr?signRStr:@"" forKey:@"signR"];
    [signDic setObject:signSStr?signSStr:@"" forKey:@"signS"];
    * dict = signDic;
    return 0;
}
+ (int)sm2_verify:(NSString *)px
               py:(NSString *)py
               za:(NSString *)za
              msg:(NSString *)msg
            signR:(NSString *)signR
            signS:(NSString *)signS
{
    if (px == nil || px.length == 0 || py == nil || py.length == 0 || za == nil || za.length == 0 || msg == nil || msg.length == 0 || signR == nil || signR.length == 0 || signS == nil || signS.length == 0)
    {
        return -1;
    }
    NSData * pxNSData    = [NIST_Tool nsdataFromHexString:px];
    NSData * pyNSData    = [NIST_Tool nsdataFromHexString:py];
    NSData * zaNSData    = [NIST_Tool nsdataFromHexString:za];
//    NSData * msgNSData   = [NIST_Tool nsdataFromHexString:msg];
    NSData * signRNSData = [NIST_Tool nsdataFromHexString:signR];
    NSData * signSNSData = [NIST_Tool nsdataFromHexString:signS];
//    NSData * pxNSData    = [px dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * pyNSData    = [py dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * zaNSData    = [za dataUsingEncoding:NSUTF8StringEncoding];
    NSData * msgNSData   = [msg dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * signRNSData = [signR dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * signSNSData = [signS dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char pxData[[pxNSData length]];
    unsigned char pyData[[pyNSData length]];
    unsigned char zaData[[za length]];
    unsigned char msgData[[msgNSData length]];
    unsigned char signRData[[signRNSData length]];
    unsigned char signSData[[signSNSData length]];
    memcpy(pxData, [pxNSData bytes], (int)[pxNSData length]);
    memcpy(pyData, [pyNSData bytes], (int)[pyNSData length]);
    memcpy(zaData, [zaNSData bytes], (int)[zaNSData length]);
    memcpy(msgData, [msgNSData bytes], (int)[msgNSData length]);
    memcpy(signRData, [signRNSData bytes], (int)[signRNSData length]);
    memcpy(signSData, [signSNSData bytes], (int)[signSNSData length]);
    if (0 != SM2_verify(pxData, pyData, zaData, msgData, (int)sizeof(msgData), signRData, signSData))
    {
        return -1;
    }
    return 0;
}
+ (int)sm2_encrypt:(NSString *)px
                py:(NSString *)py
             plain:(NSString *)plain
              rand:(NSString *)rand
            cipher:(NSString *__autoreleasing *)cipher
{
    if (px == nil || px.length == 0 || py == nil || py.length == 0 || plain == nil || plain.length == 0 || cipher == NULL)
    {
        return -1;
    }
    NSData * pxNSData = [NIST_Tool nsdataFromHexString:px];
    NSData * pyNSData = [NIST_Tool nsdataFromHexString:py];
//    NSData * plainNSData = [plain dataUsingEncoding:NSUTF8StringEncoding];
    NSData * plainNSData = [NIST_Tool nsdataFromHexString:plain];
//    NSData * randNSData = [rand dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char pxData[[pxNSData length]];
    unsigned char pyData[[pyNSData length]];
    unsigned char plainData[[plainNSData length]];
//    unsigned char randData[[randNSData length]];
    unsigned char cipherData[[plainNSData length] + 96];
    memcpy(pxData, [pxNSData bytes], (int)[pxNSData length]);
    memcpy(pyData, [pyNSData bytes], (int)[pyNSData length]);
    memcpy(plainData, [plainNSData bytes], (int)[plainNSData length]);
//    memcpy(randData, [randNSData bytes], (int)[randNSData length]);
    if (0 != SM2_encrypt(pxData, pyData, plainData, (int)sizeof(plainData), NULL, cipherData))
    {
        return -1;
    }
    NSString * cipherStr = [NIST_Tool stringFromByte:cipherData len:sizeof(cipherData)];
    *cipher = cipherStr;
    return 0;
}
+ (int)sm2_decrypt:(NSString *)privkey
            cipher:(NSString *)cipher
             plain:(NSString *__autoreleasing *)plain
{
    if (privkey == nil || privkey.length == 0 || cipher == nil || cipher.length == 0 || plain == NULL)
    {
        return -1;
    }
//    NSData * privkeyNSData = [privkey dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * cipherNSData = [cipher dataUsingEncoding:NSUTF8StringEncoding];
    NSData * privkeyNSData = [NIST_Tool nsdataFromHexString:privkey];
    NSData * cipherNSData = [NIST_Tool nsdataFromHexString:cipher];
    unsigned char privkeyData[[privkeyNSData length]];
    unsigned char cipherData[[cipherNSData length]];
    unsigned char plainData[[cipherNSData length] - 96];
    memcpy(privkeyData, [privkeyNSData bytes], (int)[privkeyNSData length]);
    memcpy(cipherData, [cipherNSData bytes], (int)[cipherNSData length]);
    if (0 != SM2_decrypt(privkeyData, cipherData, (int)sizeof(cipherNSData), plainData))
    {
        return -1;
    }
    NSString * plainStr = [NIST_Tool stringFromByte:plainData len:sizeof(plainData)];
    *plain = plainStr;
    return 0;
}

#pragma mark - sm4加解密
+ (int)sm4_encrypt:(NSString *)plain
            cipher:(NSString *__autoreleasing *)cipher
               key:(NSString *)key
{
    if (plain == nil || plain.length == 0 || cipher == NULL || key == nil || key.length == 0)
    {
        return -1;
    }
//    NSData * plainNSData = [plain dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * keyNSData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData * plainNSData = [NIST_Tool nsdataFromHexString:plain];
    NSData * keyNSData = [NIST_Tool nsdataFromHexString:key];
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
+ (int)sm4_decrypt:(NSString *)cipher
             plain:(NSString *__autoreleasing *)plain
               key:(NSString *)key
{
    if (cipher == nil || cipher.length == 0 || plain == NULL || key == nil || key.length == 0)
    {
        return -1;
    }
//    NSData * ciphertNSData = [cipher dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * keyNSData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData * ciphertNSData = [NIST_Tool nsdataFromHexString:cipher];
    NSData * keyNSData = [NIST_Tool nsdataFromHexString:key];
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

#pragma mark - 去盐算法
+ (int)daSalt:(NSString *)salt
         data:(NSString *)data
        ouput:(NSString *__autoreleasing *)ouput
{
    if (salt == nil || salt.length == 0 ||  data == nil || data.length == 0 || ouput == NULL)
    {
        return -1;
    }
//    NSData * saltNSData = [salt dataUsingEncoding:NSUTF8StringEncoding];
//    NSData * dataNSData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSData * saltNSData = [NIST_Tool nsdataFromHexString:salt];
    NSData * dataNSData = [NIST_Tool nsdataFromHexString:data];
    Byte * saltBytes = (Byte *)[saltNSData bytes];
    Byte * dataByte = (Byte *)[dataNSData bytes];
    for (int i = 0; i < [dataNSData length]; i++)
    {
        dataByte[i] = dataByte[i] ^ saltBytes[(i % [saltNSData length])];
    }
    NSString * outStr = [NIST_Tool stringFromByte:dataByte len:(int)[dataNSData length]];
    *ouput = outStr;
    return 0;
}

#pragma mark - ZTA加密&&ZTB解密
+ (int)encryptZTA:(NSString *)plaintxt
        ciphertxt:(NSString *__autoreleasing *)ciphertxt
{
    if (plaintxt == nil || plaintxt.length == 0 || ciphertxt == NULL)
    {
        return -1;
    }
//    NSData * plaintxtNSData = [plaintxt dataUsingEncoding:NSUTF8StringEncoding];
    NSData * plaintxtNSData = [NIST_Tool nsdataFromHexString:plaintxt];
    unsigned char plaintxtData[[plaintxtNSData length]];
    memcpy(plaintxtData, [plaintxtNSData bytes], (int)[plaintxtNSData length]);
    int plen = (int)[plaintxtNSData length];
//    int len = 0;
//    if (plen/8 == 0)
//    {
//        len = 1;
//    }
//    if (plen/8 >= 1 && (plen%8) == 0)
//    {
//        len = plen/8;
//    }
//    if (plen/8 >= 1 && (plen%8) != 0)
//    {
//        len = plen/8 + 1;
//    }
//    unsigned long long cipherData[len];
//    u64FromToU8(plaintxtData, plen, cipherData);
//    if (len != encryptZTA(cipherData, len, cipherData))
//    {
//        return -1;
//    }
//    u8FromToU64(cipherData, len, plaintxtData);
//    NSString * cipherStr = [NIST_Tool stringFromByte:plaintxtData len:plen];
//    *ciphertxt = cipherStr;
//    return 0;
    int rem = plen%8;
    int len = plen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char cipherData[plen];
    big_endian(plaintxtData, plen);
    if (len != encryptZTA((u64 *)plaintxtData, len, (u64 *)cipherData))
    {
        return -1;
    }
    big_endian(cipherData, plen);
    NSString * cipherStr = [NIST_Tool stringFromByte:cipherData len:plen];
    *ciphertxt = cipherStr;
    return 0;
}
+ (int)decryptZTB:(NSString *)ciphertxt
         plaintxt:(NSString *__autoreleasing *)plaintxt
{
    if (ciphertxt == nil || ciphertxt.length == 0 || plaintxt == NULL)
    {
        return -1;
    }
    NSData * ciphertxtNSData = [NIST_Tool nsdataFromHexString:ciphertxt];
//    NSData * ciphertxtNSData = [ciphertxt dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char ciphertxtData[[ciphertxtNSData length]];
    memcpy(ciphertxtData, [ciphertxtNSData bytes],[ciphertxtNSData length]);
    int clen = (int)[ciphertxtNSData length];
//    int len = 0;
//    if (clen/8 == 0)
//    {
//        len = 1;
//    }
//    if (clen/8 >= 1 && (clen%8) == 0)
//    {
//        len = clen/8;
//    }
//    if (clen/8 >= 1 && (clen%8) != 0)
//    {
//        len = clen/8 + 1;
//    }
//    unsigned long long plaintxtData[len];
//    u64FromToU8(ciphertxtData, clen, plaintxtData);
//    if (len != decryptZTB(plaintxtData, len, plaintxtData))
//    {
//        return  -1;
//    }
//    u8FromToU64(plaintxtData, len, ciphertxtData);
//    NSString * plaintxtStr = [NIST_Tool stringFromByte:ciphertxtData len:clen];
//    *plaintxt = plaintxtStr;
//    return 0;
   
    int rem = clen%8;
    int len = clen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char plaintxtData[clen];
    big_endian(ciphertxtData, clen);
    
    if (len != decryptZTB((u64 *)ciphertxtData, len, (u64 *)plaintxtData))
    {
        return -1;
    }
    big_endian(plaintxtData, clen);
    NSString * plaintxtStr = [NIST_Tool stringFromByte:plaintxtData len:clen];
    *plaintxt = plaintxtStr;
    return 0;
}

#pragma mark - ZUA加密&&ZUB解密
+ (int)encryptZUA:(NSString *)plaintxt
        ciphertxt:(NSString *__autoreleasing *)ciphertxt
{
    if (plaintxt == nil || plaintxt.length == 0 || ciphertxt == NULL)
    {
        return -1;
    }
//    NSData * plaintxtNSData = [plaintxt dataUsingEncoding:NSUTF8StringEncoding];
    NSData * plaintxtNSData = [NIST_Tool nsdataFromHexString:plaintxt];
    unsigned char plaintxtData[[plaintxtNSData length]];
    memcpy(plaintxtData, [plaintxtNSData bytes], (int)[plaintxtNSData length]);
    int plen = (int)[plaintxtNSData length];
//    int len = 0;
//    if (plen/8 == 0)
//    {
//        len = 1;
//    }
//    if (plen/8 >= 1 && (plen%8) == 0)
//    {
//        len = plen/8;
//    }
//    if (plen/8 >= 1 && (plen%8) != 0)
//    {
//        len = plen/8 + 1;
//    }
//    unsigned long long cipherData[len];
//    u64FromToU8(plaintxtData, plen, cipherData);
//    if (0 != encryptZUA(cipherData, len, cipherData))
//    {
//        return -1;
//    }
//    u8FromToU64(cipherData, len, plaintxtData);
//    NSString * cipherStr = [NIST_Tool stringFromByte:plaintxtData len:plen];
//    *ciphertxt = cipherStr;
//    return 0;
    int rem = plen%8;
    int len = plen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char cipherData[plen];
    big_endian(plaintxtData, plen);
    if (len != encryptZUA((u64 *)plaintxtData, len, (u64 *)cipherData))
    {
        return -1;
    }
    big_endian(cipherData, plen);
    NSString * cipherStr = [NIST_Tool stringFromByte:cipherData len:plen];
    *ciphertxt = cipherStr;
    return 0;
}
+ (int)decryptZUB:(NSString *)ciphertxt
         plaintxt:(NSString *__autoreleasing *)plaintxt
{
    if (ciphertxt == nil || ciphertxt.length == 0 || plaintxt == NULL)
    {
        return -1;
    }
//    NSData * ciphertxtNSData = [ciphertxt dataUsingEncoding:NSUTF8StringEncoding];
    NSData * ciphertxtNSData = [NIST_Tool nsdataFromHexString:ciphertxt];
    unsigned char ciphertxtData[[ciphertxtNSData length]];
    memcpy(ciphertxtData, [ciphertxtNSData bytes],[ciphertxtNSData length]);
    int clen = (int)[ciphertxtNSData length];
//    int len = 0;
//    if (clen/8 == 0)
//    {
//        len = 1;
//    }
//    if (clen/8 >= 1 && (clen%8) == 0)
//    {
//        len = clen/8;
//    }
//    if (clen/8 >= 1 && (clen%8) != 0)
//    {
//        len = clen/8 + 1;
//    }
//    unsigned long long plaintxtData[len];
//    u64FromToU8(ciphertxtData, clen, plaintxtData);
//    if (0 != decryptZUB(plaintxtData, len, plaintxtData))
//    {
//        return  -1;
//    }
//    u8FromToU64(plaintxtData, len, ciphertxtData);
//    NIST_u8FromToU64(plaintxtData, ciphertxtData, len);
//    NSString * plaintxtStr = [NIST_Tool stringFromByte:ciphertxtData len:clen];
//    *plaintxt = plaintxtStr;
//    return 0;
    int rem = clen%8;
    int len = clen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char plaintxtData[clen];
    big_endian(ciphertxtData, clen);
    
    if (len != decryptZUB((u64 *)ciphertxtData, len, (u64 *)plaintxtData))
    {
        return -1;
    }
    big_endian(plaintxtData, clen);
    NSString * plaintxtStr = [NIST_Tool stringFromByte:plaintxtData len:clen];
    *plaintxt = plaintxtStr;
    return 0;
}

#pragma mark - ZSA加密&&ZSB解密
+ (int)encryptZSA:(NSString *)plaintxt
        ciphertxt:(NSString *__autoreleasing *)ciphertxt
{
    if (plaintxt == nil || plaintxt.length == 0 || ciphertxt == NULL)
    {
        return -1;
    }
//    NSData * plaintxtNSData = [plaintxt dataUsingEncoding:NSUTF8StringEncoding];
    NSData * plaintxtNSData = [NIST_Tool nsdataFromHexString:plaintxt];
    unsigned char plaintxtData[[plaintxtNSData length]];
    memcpy(plaintxtData, [plaintxtNSData bytes], (int)[plaintxtNSData length]);
    int plen = (int)[plaintxtNSData length];
//    int len = 0;
//    if (plen/8 == 0)
//    {
//        len = 1;
//    }
//    if (plen/8 >= 1 && (plen%8) == 0)
//    {
//        len = plen/8;
//    }
//    if (plen/8 >= 1 && (plen%8) != 0)
//    {
//        len = plen/8 + 1;
//    }
//    unsigned long long cipherData[len];
//    u64FromToU8(plaintxtData, plen, cipherData);
//    if (0 != encryptZSA(cipherData, len, cipherData))
//    {
//        return -1;
//    }
//    u8FromToU64(cipherData, len, plaintxtData);
//    NSString * cipherStr = [NIST_Tool stringFromByte:plaintxtData len:plen];
//    *ciphertxt = cipherStr;
//    return 0;
    int rem = plen%8;
    int len = plen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char cipherData[plen];
    big_endian(plaintxtData, plen);
    if (len != encryptZSA((u64 *)plaintxtData, len, (u64 *)cipherData))
    {
        return -1;
    }
    big_endian(cipherData, plen);
    NSString * cipherStr = [NIST_Tool stringFromByte:cipherData len:plen];
    *ciphertxt = cipherStr;
    return 0;
}
+ (int)decryptZSB:(NSString *)ciphertxt
         plaintxt:(NSString *__autoreleasing *)plaintxt
{
    if (ciphertxt == nil || ciphertxt.length == 0 || plaintxt == NULL)
    {
        return -1;
    }
//    NSData * ciphertxtNSData = [ciphertxt dataUsingEncoding:NSUTF8StringEncoding];
    NSData * ciphertxtNSData = [NIST_Tool nsdataFromHexString:ciphertxt];
    unsigned char ciphertxtData[[ciphertxtNSData length]];
    memcpy(ciphertxtData, [ciphertxtNSData bytes],[ciphertxtNSData length]);
    int clen = (int)[ciphertxtNSData length];
//    int len = 0;
//    if (clen/8 == 0)
//    {
//        len = 1;
//    }
//    if (clen/8 >= 1 && (clen%8) == 0)
//    {
//        len = clen/8;
//    }
//    if (clen/8 >= 1 && (clen%8) != 0)
//    {
//        len = clen/8 + 1;
//    }
//    unsigned long long plaintxtData[len];
//    u64FromToU8(ciphertxtData, clen, plaintxtData);
//    if (0 != decryptZSB(plaintxtData, len, plaintxtData))
//    {
//        return  -1;
//    }
//    u8FromToU64(plaintxtData, len, ciphertxtData);
//    NSString * plaintxtStr = [NIST_Tool stringFromByte:ciphertxtData len:clen];
//    *plaintxt = plaintxtStr;
//    return 0;
    int rem = clen%8;
    int len = clen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char plaintxtData[clen];
    big_endian(ciphertxtData, clen);
    
    if (len != decryptZSB((u64 *)ciphertxtData, len, (u64 *)plaintxtData))
    {
        return -1;
    }
    big_endian(plaintxtData, clen);
    NSString * plaintxtStr = [NIST_Tool stringFromByte:plaintxtData len:clen];
    *plaintxt = plaintxtStr;
    return 0;
}

#pragma mark - ZWA加密&&ZWB解密
+ (int)encryptZWA:(NSString *)plaintxt
        ciphertxt:(NSString *__autoreleasing *)ciphertxt
{
    if (plaintxt == nil || plaintxt.length == 0 || ciphertxt == NULL)
    {
        return -1;
    }
//    NSData * plaintxtNSData = [plaintxt dataUsingEncoding:NSUTF8StringEncoding];
    NSData * plaintxtNSData = [NIST_Tool nsdataFromHexString:plaintxt];
    unsigned char plaintxtData[[plaintxtNSData length]];
    memcpy(plaintxtData, [plaintxtNSData bytes], (int)[plaintxtNSData length]);
    int plen = (int)[plaintxtNSData length];
//    int len = 0;
//    if (plen/8 == 0)
//    {
//        len = 1;
//    }
//    if (plen/8 >= 1 && (plen%8) == 0)
//    {
//        len = plen/8;
//    }
//    if (plen/8 >= 1 && (plen%8) != 0)
//    {
//        len = plen/8 + 1;
//    }
//    unsigned long long cipherData[len];
//    u64FromToU8(plaintxtData, plen, cipherData);
//    if (0 != encryptZWA(cipherData, len, cipherData))
//    {
//        return -1;
//    }
//    u8FromToU64(cipherData, len, plaintxtData);
//    NSString * cipherStr = [NIST_Tool stringFromByte:plaintxtData len:plen];
//    *ciphertxt = cipherStr;
//    return 0;
    int rem = plen%8;
    int len = plen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char cipherData[plen];
    big_endian(plaintxtData, plen);
    if (len != encryptZSA((u64 *)plaintxtData, len, (u64 *)cipherData))
    {
        return -1;
    }
    big_endian(cipherData, plen);
    NSString * cipherStr = [NIST_Tool stringFromByte:cipherData len:plen];
    *ciphertxt = cipherStr;
    return 0;
}
+ (int)decryptZWB:(NSString *)ciphertxt
         plaintxt:(NSString *__autoreleasing *)plaintxt
{
    if (ciphertxt == nil || ciphertxt.length == 0 || plaintxt == NULL)
    {
        return -1;
    }
//    NSData * ciphertxtNSData = [ciphertxt dataUsingEncoding:NSUTF8StringEncoding];
    NSData * ciphertxtNSData = [NIST_Tool nsdataFromHexString:ciphertxt];
    unsigned char ciphertxtData[[ciphertxtNSData length]];
    memcpy(ciphertxtData, [ciphertxtNSData bytes],[ciphertxtNSData length]);
    int clen = (int)[ciphertxtNSData length];
//    int len = 0;
//    if (clen/8 == 0)
//    {
//        len = 1;
//    }
//    if (clen/8 >= 1 && (clen%8) == 0)
//    {
//        len = clen/8;
//    }
//    if (clen/8 >= 1 && (clen%8) != 0)
//    {
//        len = clen/8 + 1;
//    }
//    unsigned long long plaintxtData[len];
//    u64FromToU8(ciphertxtData, clen, plaintxtData);
//    if (0 != decryptZWB(plaintxtData, len, plaintxtData))
//    {
//        return  -1;
//    }
//    u8FromToU64(plaintxtData, len, ciphertxtData);
//    NSString * plaintxtStr = [NIST_Tool stringFromByte:ciphertxtData len:clen];
//    *plaintxt = plaintxtStr;
//    return 0;
    int rem = clen%8;
    int len = clen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char plaintxtData[clen];
    big_endian(ciphertxtData, clen);
    
    if (len != decryptZWB((u64 *)ciphertxtData, len, (u64 *)plaintxtData))
    {
        return -1;
    }
    big_endian(plaintxtData, clen);
    NSString * plaintxtStr = [NIST_Tool stringFromByte:plaintxtData len:clen];
    *plaintxt = plaintxtStr;
    return 0;
}

#pragma mark - 计算ZCODE
+ (int)data:(NSString *)data
      zcode:(NSString * __autoreleasing *)zcode
{
    if (data == nil || data.length == 0 || zcode == NULL)
    {
        return -1;
    }
    NSData * dataNSData = [NIST_Tool nsdataFromHexString:data];
    unsigned char dataData[[dataNSData length]];
    memcpy(dataData, [dataNSData bytes], (int)[dataNSData length]);
    int plen = (int)[dataNSData length];
    int rem = plen%8;
    int len = plen/8;
    if (rem != 0)
    {
        return -1;
    }
    unsigned char cipherData[plen];
    big_endian(dataData, plen);
    if (len != encryptZSA((u64 *)dataData, len, (u64 *)cipherData))
    {
        return -1;
    }
    if (len != decryptZTB((u64 *)cipherData, len, (u64 *)cipherData))
    {
        return -1;
    }
    if (len != encryptZUA((u64 *)cipherData, len, (u64 *)cipherData))
    {
        return -1;
    }
    if (len != decryptZUB((u64 *)cipherData, len, (u64 *)cipherData))
    {
        return -1;
    }
    if (len != encryptZSA((u64 *)cipherData, len, (u64 *)cipherData))
    {
        return -1;
    }
    if (len != decryptZSB((u64 *)cipherData, len, (u64 *)cipherData))
    {
        return -1;
    }
    
    big_endian(cipherData, plen);
    NSString * cipherStr = [NIST_Tool stringFromByte:cipherData len:plen];
    *zcode = cipherStr;
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
