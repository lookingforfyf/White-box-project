#include <stdio.h>
#include <string.h>

# ifndef U64
typedef unsigned long long    U64;
# endif

# ifndef U32
typedef unsigned int          U32;
# endif

# ifndef U16
typedef unsigned short        U16;
# endif

# ifndef U8
typedef unsigned char          U8;
# endif


void ZSVR_debug(char* msg)
{
	printf("%s", msg);
}


//hex字符串转字节流
int hex2bytes(const char* hex, int hlen, unsigned char* bytes, int* blen)
{
	int i,n;
	unsigned char H4,L4;

	if (NULL == bytes || NULL == hex) return 1;
	if (0 != (hlen % 2)) return 2;

	n = 0;
	for (i=0; i<hlen; i++)
    {
		if (hex[i] >= '0' && hex[i] <= '9')	H4 = (unsigned char)((hex[i]-'0')<<4)&0xf0;
		else if (hex[i] >= 'a' && hex[i] <= 'f') H4 = (unsigned char)((hex[i]-'a'+10)<<4)&0xf0;
		else if (hex[i] >= 'A' && hex[i] <= 'F') H4 = (unsigned char)((hex[i]-'A'+10)<<4)&0xf0;
		else return 3;

		i++;
		if (hex[i] >= '0' && hex[i] <= '9')	L4 = (unsigned char)(hex[i]-'0')&0x0f;
		else if (hex[i] >= 'a' && hex[i] <= 'f') L4 = (unsigned char)(hex[i]-'a'+10)&0x0f;
		else if (hex[i] >= 'A' && hex[i] <= 'F') L4 = (unsigned char)(hex[i]-'A'+10)&0x0f;
		else return 4;

		bytes[n++] = H4 | L4;
	}

	*blen = n;
	
	return 0;
}

//字节流转hex字符串
int bytes2hex(const unsigned char* bytes, int blen, char* hex, int* hlen)
{
	int i,n;
	char hexMap[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};

	if (NULL == bytes || NULL == hex) return 1;
	
	n = 0;
	for (i=0,n=0; i<blen; i++)
    {
		hex[n++] = hexMap[(bytes[i]>>4)&0x0f];
		hex[n++] = hexMap[bytes[i]&0x0f];
	}

	*hlen = n;

	return 0;
}

//8位字节流转64位长字流（小端模式）
int U8TU64L(const U8* in, int ilen, U64* out, int* olen)
{
	int i=0,n=0;
	
# if 0
	U64* p;

	if (NULL == in || NULL == out) return 1;
	if (0!= (ilen % 8)) return 2;

	p = (U64*)in;
	for (i=0; i<(ilen/8); i++) out[n++] = *p++;
# else

	if (NULL == in || NULL == out) return 1;
	if (0!= (ilen % 8)) return 2;

	for (n=0; n<(ilen/8); n++)
    {
		out[n] =  (U64)in[i++];
		out[n] |= (U64)in[i++]<<8;
		out[n] |= (U64)in[i++]<<16;
		out[n] |= (U64)in[i++]<<24;
		out[n] |= (U64)in[i++]<<32;
		out[n] |= (U64)in[i++]<<40;
		out[n] |= (U64)in[i++]<<48;
		out[n] |= (U64)in[i++]<<56;
	}
# endif
	
	*olen = n;

	return 0;
}

//64位长字流转8位字节流（小端模式）
int U64TU8L(const U64* in, int ilen, U8* out, int* olen)
{
	int i,n=0;
	
# if 0
	U8* p = (U8*)in;

	for (i=0; i<(ilen*8); i++)
    {
		out[n++] = *p++;
	}
# else

	for (i=0; i<ilen; i++)
    {
		out[n++] = (U8)in[i]&0xff;
		out[n++] = (U8)(in[i]>>8)&0xff;
		out[n++] = (U8)(in[i]>>16)&0xff;
		out[n++] = (U8)(in[i]>>24)&0xff;
		out[n++] = (U8)(in[i]>>32)&0xff;
		out[n++] = (U8)(in[i]>>40)&0xff;
		out[n++] = (U8)(in[i]>>48)&0xff;
		out[n++] = (U8)(in[i]>>56)&0xff;
	}
# endif

	*olen = n;

	return 0;
}

//8位字节流转64位长字流（大端模式）
int U8TU64B(const U8* in, int ilen, U64* out, int* olen)
{
	int i=0,n=0;
	
	if (NULL == in || NULL == out) return 1;
	if (0!= (ilen % 8)) return 2;

	for (n=0; n<(ilen/8); n++)
    {
		out[n] = in[i++];
		out[n] = (out[n]<<8) | in[i++];
		out[n] = (out[n]<<8) | in[i++];
		out[n] = (out[n]<<8) | in[i++];
		out[n] = (out[n]<<8) | in[i++];
		out[n] = (out[n]<<8) | in[i++];
		out[n] = (out[n]<<8) | in[i++];
		out[n] = (out[n]<<8) | in[i++];
	}
	
	*olen = n;

	return 0;
}

//64位长字流转8位字节流（大端模式）
int U64TU8B(const U64* in, int ilen, U8* out, int* olen)
{
	int i,n=0;
	
	for (i=0; i<ilen; i++)
    {
		out[n++] = (U8)(in[i]>>56)&0xff;
		out[n++] = (U8)(in[i]>>48)&0xff;
		out[n++] = (U8)(in[i]>>40)&0xff;
		out[n++] = (U8)(in[i]>>32)&0xff;
		out[n++] = (U8)(in[i]>>24)&0xff;
		out[n++] = (U8)(in[i]>>16)&0xff;
		out[n++] = (U8)(in[i]>>8)&0xff;
		out[n++] = (U8)in[i]&0xff;
	}

	*olen = n;

	return 0;
}

# if 0
void test1(void)
{
	int i,ret;
	int hlen = 0,blen = 0;
	char* hex = (char*)"0123456789abcdef";
	unsigned char bytes[8] = {0};
	char hex2[17] = {0};

	ret = hex2bytes(hex, strlen(hex), bytes, &blen);
	printf("hex2bytes() ret=%d blen=%d\n", ret,blen);
	for (i=0; i<blen; i++) printf("%02x ", bytes[i]);printf("\n");

	ret = bytes2hex(bytes, blen, hex2, &hlen);
	printf("bytes2hex() ret=%d hlen=%d\n", ret,hlen);
	printf("%s\n", hex2);
}

void test2(void)
{
	int i;
	unsigned long long u64[2] = {0x1234567890abcdef, 0xaabbccddeeff1122};
	unsigned char* u8 = (unsigned char*)u64;
	unsigned char bytes[16] = {0};
	int ret,len;

	for(i=0; i<16; i++) printf("%02x ", *(u8+i));printf("\n");

	ret = U64TU8L(u64, 2, bytes, &len);
	printf("U64TU8L() ret=%d len=%d\n", ret,len);
	for(i=0; i<16; i++) printf("%02x ", bytes[i]);printf("\n");
	ret = U8TU64L(bytes, len, u64, &len);
	printf("U8TU64L() ret=%d len=%d\n", ret,len);
	for(i=0; i<2; i++) printf("%016llx ", u64[i]);printf("\n");
	
	ret = U64TU8B(u64, 2, bytes, &len);
	printf("U64TU8B() ret=%d len=%d\n", ret,len);
	for(i=0; i<16; i++) printf("%02x ", bytes[i]);printf("\n");
	ret = U8TU64B(bytes, len, u64, &len);
	printf("U8TU64B() ret=%d len=%d\n", ret,len);
	for(i=0; i<2; i++) printf("%016llx ", u64[i]);printf("\n");
}

int main(int argc, char* argv[])
{
	test1();
	test2();
	
	return 0;
}
# endif
