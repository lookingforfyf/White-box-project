#ifndef Z_ALG_LIB_H
#define Z_ALG_LIB_H

#include "ztype.h"

# ifdef  __cplusplus
extern "C" {
# endif

//返回输出数据长度
int encryptZTA(u64* plaintxt, int plen, u64* ciphertxt);
int decryptZTB(u64* ciphertxt, int clen, u64* plaintxt);
int encryptZUA(u64* plaintxt, int plen, u64* ciphertxt);
int decryptZUB(u64* ciphertxt, int clen, u64* plaintxt);
int encryptZSA(u64* plaintxt, int plen, u64* ciphertxt);
int decryptZSB(u64* ciphertxt, int clen, u64* plaintxt);
int encryptZWA(u64* plaintxt, int plen, u64* ciphertxt);
int decryptZWB(u64* ciphertxt, int clen, u64* plaintxt);

//返回0成功 -1失败
int selfCheckSDK(void);
void getVersion(char *buff);

# ifdef  __cplusplus
}
# endif


#endif
