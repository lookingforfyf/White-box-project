//
//  NIST_Tool.m
//  WhiteBoxSDKText(白盒SDK)
//
//  Created by 范云飞 on 2017/11/1.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "NIST_Tool.h"

@implementation NIST_Tool
#pragma mark - 十六进制字符串和普通字符串的相互转化
+ (NSString *)stringFromHexString:(NSString *)hexString
{
    if (hexString == nil || hexString.length == 0)
    {
        return 0;
    }
    char * myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2)
    {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString * unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    return unicodeString;
}

+ (NSString *)hexStringFromString:(NSString *)string
{
    if (string == nil || string.length == 0)
    {
        return 0;
    }
    NSData * myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte * bytes = (Byte *)[myD bytes];
    /* 下面是Byte 转换为16进制 */
    NSString * hexStr=@"";
    for(int i = 0; i < [myD length]; i++)
    {
        NSString * newHexStr = [NSString stringWithFormat:@"%X",bytes[i]&0xFF];/* 16进制数 */
        if([newHexStr length]==1)
        {
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        }
        else
        {
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    }
    return hexStr;
}

#pragma mark - NSString和NSData的相互转化
+ (NSData *)nsdataFromString:(NSString *)string
{
    if (string == nil || string.length == 0)
    {
        return 0;
    }
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)stringFromNSData:(NSData *)data
{
    if (data == nil || data.length == 0)
    {
        return 0;
    }
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - NSString和Byte数组的相互转化
+ (Byte *)byteFromString:(NSString *)string
{
    if (string == nil || string.length == 0)
    {
        return 0;
    }
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte * byte = (Byte *)[data bytes];
    return byte;
}

+ (NSString *)stringFromByte:(Byte *)byte
                         len:(NSInteger)len
{
    if (byte == NULL)
    {
        return 0;
    }
    NSData * data = [NSData dataWithBytes:byte length:len];
    NSString * string = [NIST_Tool hexStringFromNSData:data];
    return string;
}

#pragma mark - 十六进制字符串和十进制的相互转化
- (NSInteger)decimalFromHexStr:(NSString *)hexStr
{
    if (hexStr == nil || hexStr.length == 0)
    {
        return 0;
    }
    int decimal = 0;
    UniChar hexChar = ' ';
    NSInteger hexLength = [hexStr length];
    
    for (NSInteger i = 0; i < hexLength; i++)
    {
        int base;
        hexChar = [hexStr characterAtIndex:i];
        
        if (hexChar >= '0' && hexChar <= '9')
        {
            /* 0 的Ascll - 48 */
            base = (hexChar - 48);
        }
        else if (hexChar >= 'A' && hexChar <= 'F')
        {
            /* A 的Ascll - 65 */
            base = (hexChar - 55);
        }
        else
        {
            /* a 的Ascll - 97 */
            base = (hexChar - 87);
        }
        decimal = decimal + base * pow(16, hexLength - i - 1);
    }
    return decimal;
}

- (NSString *)hexStrFromDecimal:(NSInteger)decimal
{
    NSMutableString * HexStr = [NSMutableString string];
    NSString * currentStr = [NSString string];
    /* 余数 */
    NSInteger remainder = 0;
    /* 商 */
    NSInteger quotient = 0;
    do
    {
        /* 余数 */
        remainder = decimal % 16;
        quotient = decimal / 16;
        switch (remainder)
        {
            case 10:
                currentStr = @"a";
                break;
            case 11:
                currentStr = @"b";
                break;
            case 12:
                currentStr = @"c";
                break;
            case 13:
                currentStr = @"d";
                break;
            case 14:
                currentStr = @"e";
                break;
            case 15:
                currentStr = @"f";
                break;
            default:
                currentStr = [NSString stringWithFormat:@"%zd",remainder];
                break;
        }
        /* 将获得的字符串插入第一个位置 */
        [HexStr insertString:currentStr atIndex:0];
        /* 将商作为新的计算值 */
        decimal = quotient;
    } while (quotient != 0);
    
    return HexStr;
}

#pragma mark - int ->NSData && NSData -> int
+ (NSData *)sndataFromInt:(int)d
{
    /* 用4个字节接收 */
    Byte bytes[4];
    bytes[0] = (Byte)(d>>24);
    bytes[1] = (Byte)(d>>16);
    bytes[2] = (Byte)(d>>8);
    bytes[3] = (Byte)(d);
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

+ (int)intFromNSData:(NSData *)intData
{
    if (intData == nil || intData.length == 0)
    {
        return 0;
    }
    int value = CFSwapInt32BigToHost(*(int*)([intData bytes]));
    return value;
}

#pragma mark - int ->Hexstring
+ (NSString *)hexFromInt:(NSInteger)val
{
    return [NSString stringWithFormat:@"%lX", (long)val];
}

#pragma mark - hexString和NSData之间的相互转化
+ (NSData *)nsdataFromHexString:(NSString *)hexString
{
    if (hexString == nil || hexString.length == 0)
    {
        return 0;
    }
    NSAssert((hexString.length > 0) && (hexString.length % 2 == 0), @"hexString.length mod 2 != 0");
    NSMutableData * data = [[NSMutableData alloc] init];
    for (NSUInteger i = 0; i < hexString.length; i += 2)
    {
        NSRange tempRange = NSMakeRange(i, 2);
        NSString * tempStr = [hexString substringWithRange:tempRange];
        NSScanner * scanner = [NSScanner scannerWithString:tempStr];
        unsigned int tempIntValue;
        [scanner scanHexInt:&tempIntValue];
        [data appendBytes:&tempIntValue length:1];
    }
    return data;
}

+ (NSString *)hexStringFromNSData:(NSData *)data
{
    if (data == nil || data.length == 0)
    {
        return 0;
    }
    NSAssert(data.length > 0, @"data.length <= 0");
    NSMutableString * hexString = [[NSMutableString alloc] init];
    const Byte * bytes = (Byte *)[data bytes];
    for (NSUInteger i = 0; i < data.length; i++)
    {
        Byte value = bytes[i];
        Byte high = (value & 0xF0) >> 4;
        Byte low = value & 0xF;
        [hexString appendFormat:@"%X%X", high, low];
    }//for
    return hexString;
}

#pragma mark - Unit8 和NSData之间的相互转化
+ (NSData *)nsdataFromUInt8:(uint8_t)val
{
    NSMutableData * valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[1];
    valChar[0] = 0xff & val;
    [valData appendBytes:valChar length:1];
    
    return [self dataWithReverse:valData];
}

+ (uint8_t)uint8FromNSData:(NSData *)fdata
{
    if (fdata == nil || fdata.length == 0)
    {
        return 0;
    }
    NSAssert(fdata.length == 1, @"uint8FromBytes: (data length != 1)");
    NSData * data = fdata;
    uint8_t val = 0;
    [data getBytes:&val length:1];
    return val;
}

#pragma mark - Uint16 和NSData之间的转化
+ (NSData *)nsdataFromUInt16:(uint16_t)val
{
    NSMutableData * valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[2];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    [valData appendBytes:valChar length:2];
    
    return [self dataWithReverse:valData];
}

+ (uint16_t)uint16FromNSData:(NSData *)fData
{
    if (fData == nil || fData.length == 0)
    {
        return 0;
    }
    NSAssert(fData.length == 2, @"uint16FromBytes: (data length != 2)");
    NSData * data = [self dataWithReverse:fData];;
    uint16_t val0 = 0;
    uint16_t val1 = 0;
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    
    uint16_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00);
    return dstVal;
}

#pragma mark - Uint32 和NSData 之间的相互转化
+ (NSData *)nsdataFromUInt32:(uint32_t)val
{
    NSMutableData * valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[4];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    valChar[2] = (0xff0000 & val) >> 16;
    valChar[3] = (0xff000000 & val) >> 24;
    [valData appendBytes:valChar length:4];
    
    return [self dataWithReverse:valData];
}

+ (uint32_t)uint32FromNSData:(NSData *)fData
{
    if (fData == nil || fData.length == 0)
    {
        return 0;
    }
    NSAssert(fData.length == 4, @"uint32FromBytes: (data length != 4)");
    NSData * data = [self dataWithReverse:fData];
    
    uint32_t val0 = 0;
    uint32_t val1 = 0;
    uint32_t val2 = 0;
    uint32_t val3 = 0;
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    [data getBytes:&val2 range:NSMakeRange(2, 1)];
    [data getBytes:&val3 range:NSMakeRange(3, 1)];
    
    uint32_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00) + ((val2 << 16) & 0xff0000) + ((val3 << 24) & 0xff000000);
    return dstVal;
}

#pragma mark - Uint64 和NSData 直线的相互转化
+ (NSData *)nsdataFromUInt64:(uint64_t)val
{
    NSMutableData * valData = [[NSMutableData alloc] init];
    
    unsigned char valChar[8];
    valChar[0] = 0xff & val;
    valChar[1] = (0xff00 & val) >> 8;
    valChar[2] = (0xff0000 & val) >> 16;
    valChar[3] = (0xff000000 & val) >> 24;
    valChar[4] = (0xff00000000 & val) >> 32;
    valChar[5] = (0xff0000000000 & val) >> 40;
    valChar[6] = (0xff000000000000 & val) >> 48;
    valChar[7] = (0xff00000000000000& val) >> 56;
    [valData appendBytes:valChar length:8];
    
    return [self dataWithReverse:valData];
}

+ (uint64_t)uint64FromNSData:(NSData *)fData
{
    if (fData == nil || fData.length == 0)
    {
        return 0;
    }
    NSAssert(fData.length == 8, @"uint64FromBytes: (data length != 8)");
    NSData * data = [self dataWithReverse:fData];
    
    uint64_t val0 = 0;
    uint64_t val1 = 0;
    uint64_t val2 = 0;
    uint64_t val3 = 0;
    uint64_t val4 = 0;
    uint64_t val5 = 0;
    uint64_t val6 = 0;
    uint64_t val7 = 0;
    
    [data getBytes:&val0 range:NSMakeRange(0, 1)];
    [data getBytes:&val1 range:NSMakeRange(1, 1)];
    [data getBytes:&val2 range:NSMakeRange(2, 1)];
    [data getBytes:&val3 range:NSMakeRange(3, 1)];
    [data getBytes:&val4 range:NSMakeRange(4, 1)];
    [data getBytes:&val5 range:NSMakeRange(5, 1)];
    [data getBytes:&val6 range:NSMakeRange(6, 1)];
    [data getBytes:&val7 range:NSMakeRange(7, 1)];
    
    uint64_t dstVal = (val0 & 0xff) + ((val1 << 8) & 0xff00) + ((val2 << 16) & 0xff0000) + ((val3 << 24) & 0xff000000) + ((val4 << 32) & 0xff00000000) + ((val5 << 40) & 0xff0000000000) + ((val6 << 48) & 0xff000000000000) + ((val7 << 56) & 0xff00000000000000);
    return dstVal;
}

#pragma mark - private
+ (NSData *)dataWithReverse:(NSData *)srcData
{
    if (srcData == nil || srcData.length == 0)
    {
        return 0;
    }
    NSUInteger byteCount = srcData.length;
    NSMutableData * dstData = [[NSMutableData alloc] initWithData:srcData];
    NSUInteger halfLength = byteCount / 2;
    for (NSUInteger i = 0; i < halfLength; i++)
    {
        NSRange begin = NSMakeRange(i, 1);
        NSRange end = NSMakeRange(byteCount - i - 1, 1);
        NSData * beginData = [srcData subdataWithRange:begin];
        NSData * endData = [srcData subdataWithRange:end];
        [dstData replaceBytesInRange:begin withBytes:endData.bytes];
        [dstData replaceBytesInRange:end withBytes:beginData.bytes];
    }
    return dstData;
}

#pragma mark - unsigned char <==> unsigned long long
void NIST_u64FromToU8(unsigned char * input,
                      unsigned long long * output,
                      int len)
{
    if (input == NULL)
    {
        return;
    }
    /* 小于8的数 */
    if (len/8 == 0)
    {
        unsigned char tempput[8];
        /* 在此需要补充 8 - total 个字节的0x00 */
        unsigned char chong[1] = {0x00};
        unsigned char buchong[8 - len];
        for (int i = 0; i < 8 - len; i++)
        {
            memcpy(buchong + i, chong, 1);
        }
        memcpy(tempput, input, len);
        memcpy(input + len, buchong, 8 - len);
        memcpy(output, tempput, 8);
    }
    /* 8的整数倍 */
    if (len/8 >= 1 && (len%8) == 0)
    {
        memcpy(output, input, len);
    }
    /* 大于8的数 */
    if (len/8 >= 1 && (len%8) != 0)
    {
        unsigned char temp[8 * (len/8 + 1)];
        /* 在此需要补充 8 - total%8 个字节 */
        unsigned char chong[1] = {0x00};
        unsigned char buchong[8 - len%8];
        for (int i = 0; i < 8 - len%8; i++)
        {
            memcpy(buchong + i, chong, 1);
        }
        memcpy(temp, input, len);
        memcpy(temp + len, buchong, 8- len%8);
        memcpy(output, temp, 8 * (len/8 + 1));
    }
}

void NIST_u8FromToU64(unsigned long long * input,
                      unsigned char * output,
                      int len)
{
    if (input == NULL)
    {
        return;
    }
    memcpy(output, input, len);
}

void u64FromToU8(const unsigned char * input,
                 int ilen,
                 unsigned long long * output)
{
    if (input == NULL)
    {
        return;
    }
    int n = 0, m = 0;
    
    while(ilen >= 8)
    {
        output[n] =  (unsigned long long)input[m++];
        output[n] |= (unsigned long long)input[m++]<<8;
        output[n] |= (unsigned long long)input[m++]<<16;
        output[n] |= (unsigned long long)input[m++]<<24;
        output[n] |= (unsigned long long)input[m++]<<32;
        output[n] |= (unsigned long long)input[m++]<<40;
        output[n] |= (unsigned long long)input[m++]<<48;
        output[n] |= (unsigned long long)input[m++]<<56;
        n++;
        ilen -= 8;
    }
}

void u8FromToU64(const unsigned long long * input,
                 int ilen,
                 unsigned char * output)
{
    if (input == NULL)
    {
        return;
    }
    int n = 0, m = 0;
    
    for (m = 0; m < ilen; m++)
    {
        output[n++] = (unsigned char)(input[m]&0xff);
        output[n++] = (unsigned char)(input[m]>>8)&0xff;
        output[n++] = (unsigned char)(input[m]>>16)&0xff;
        output[n++] = (unsigned char)(input[m]>>24)&0xff;
        output[n++] = (unsigned char)(input[m]>>32)&0xff;
        output[n++] = (unsigned char)(input[m]>>40)&0xff;
        output[n++] = (unsigned char)(input[m]>>48)&0xff;
        output[n++] = (unsigned char)(input[m]>>56)&0xff;
    }
}

void big_endian(unsigned char* data, int dlen)
{
    unsigned long long* pu64 = (unsigned long long*)data;
    unsigned char* pu8 = data;
    unsigned long long u64;
    int i,cnt = dlen / 8;
    
    for(i = 0; i < cnt; i++)
    {
        u64 = *pu64++;
        *pu8++ = (unsigned char)((u64>>56)&0xff);
        *pu8++ = (unsigned char)((u64>>48)&0xff);
        *pu8++ = (unsigned char)((u64>>40)&0xff);
        *pu8++ = (unsigned char)((u64>>32)&0xff);
        *pu8++ = (unsigned char)((u64>>24)&0xff);
        *pu8++ = (unsigned char)((u64>>16)&0xff);
        *pu8++ = (unsigned char)((u64>>8)&0xff);
        *pu8++ = (unsigned char)(u64&0xff);
    }
}

#pragma mark - 将字符串左侧的padding全部剔除
+ (NSString *)leftTrimString:(NSString *)str
                     padding:(NSString *)padding
{
    if (str == nil || str.length == 0 || padding == nil || padding.length == 0)
    {
        return 0;
    }
    
    NSString * hexstring = [NIST_Tool stringFromHexString:str];
    NSString * tmp = [hexstring substringWithRange:NSMakeRange(0, padding.length)];
    while ([padding isEqualToString:tmp])
    {
        hexstring = [hexstring substringFromIndex:padding.length];
        tmp = [hexstring substringWithRange:NSMakeRange(0, padding.length)];
    }
    return hexstring;
}

#pragma mark - 将字符串填充为CNT的整数倍(CNT可以为任何整数)
+ (NSMutableString *)stringPadding:(NSMutableString *)strBuffer
                               cnt:(int)cnt
                           padding:(NSString *)padding
{
    if (strBuffer == nil || strBuffer.length == 0)
    {
        return 0;
    }
    if (strBuffer.length % cnt == 0)
    {
        return strBuffer;
    }
    if (padding == nil || padding.length == 0)
    {
        padding = @"\n";
    }
    int len = (int)padding.length;
    int n   = cnt - (strBuffer.length % cnt);
    
    while (n >= len)
    {
        [strBuffer appendString:padding];
        n -= len;
    }
    
    if (n > 0)
    {
        NSString * subPadding = [padding substringWithRange:NSMakeRange(0, n - 1)];
        [strBuffer appendString:subPadding];
    }
    return strBuffer;
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
