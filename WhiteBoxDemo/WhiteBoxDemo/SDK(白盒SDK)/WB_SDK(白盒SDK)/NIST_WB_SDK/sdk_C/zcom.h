#ifndef Z_COM_H
#define Z_COM_H

#define ZBUFF_MODE_BYTE_U64	   0    //64位大端（0x1234567890abcdef === 12 34 56 78 90 ab cd ef）
#define ZBUFF_MODE_BYTE_U32	   1    //32位大端（0x12345678 === 12 34 56 78）
#define ZBUFF_MODE_BYTE_U16	   2    //16位大端（0x1234 ===     13 34）
#define ZBUFF_MODE_BYTE	       3    //8位字节（0xAB）
#define ZBUFF_MODE_HEX	       4    //十六进制字符（AB）
#define ZBUFF_MODE_CHAR	       5    //ASCII码字符（test）

#define Z_ENCRYPT              0
#define Z_DECRYPT              1

#define Z_INIT	               0
#define Z_READY	               1


# ifdef  __cplusplus
extern "C" {
# endif

void ZSVR_debug(char* msg);

//hex字符串转字节流
int hex2bytes(const char* hex, int hlen, unsigned char* bytes, int* blen);
//字节流转hex字符串
int bytes2hex(const unsigned char* bytes, int blen, char* hex, int* hlen);

//8位字节流转64位长字流（小端模式）
int U8TU64L(const unsigned char* in, int ilen, unsigned long long* out, int* olen);
//64位长字流转8位字节流（小端模式）
int U64TU8L(const unsigned long long* in, int ilen, unsigned char* out, int* olen);

//8位字节流转64位长字流（大端模式）
int U8TU64B(const unsigned char* in, int ilen, unsigned long long* out, int* olen);
//64位长字流转8位字节流（大端模式）
int U64TU8B(const unsigned long long* in, int ilen, unsigned char* out, int* olen);

# ifdef  __cplusplus
}
# endif


#endif
