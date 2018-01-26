#ifndef Z_TYPE_H
#define Z_TYPE_H

#ifndef L
#define                       L(x,n) ((x)<<(n)|(x)>>(64-(n)))
#endif

#ifndef L32
#define                       L32(x,n) ((x)<<(n)|(x)>>(32-(n)))
#endif

#ifndef P
#define P(X)                  (L32(X,8)^L32(X,16)^L32(X,24))
#endif

#ifndef TRUE
#define TRUE                  1
#endif

#ifndef FALSE
#define FALSE                 0
#endif

//#ifndef NULL
//#define NULL                  0
//#endif

#ifndef VOID
typedef void                  VOID;
#endif

#ifndef INT8
typedef char                  INT8;
#endif

#ifndef UINT8
typedef unsigned char         UINT8;
#endif

#ifndef u8
typedef unsigned char         u8;
#endif

#ifndef INT16
typedef short                 INT16;
#endif

#ifndef UINT16
typedef unsigned short        UINT16;
#endif

#ifndef u16
typedef unsigned short        u16;
#endif

#ifndef INT32
typedef int                   INT32;
#endif

#ifndef UINT32
typedef unsigned int          UINT32;
#endif

#ifndef u32
typedef unsigned int          u32;
#endif

#ifndef INT64
typedef signed long long      INT64;
#endif

#ifndef u64
typedef unsigned long long    u64;
#endif

#ifndef LONG
typedef long                  LONG;
#endif

#ifndef ULONG
#define ULONG                 unsigned long
#endif

#ifndef CHAR
typedef INT8                  CHAR;
#endif

#ifndef BYTE
typedef UINT8                 BYTE;
#endif

#ifndef SHORT
typedef INT16                 SHORT;
#endif

#ifndef USHORT
typedef UINT16                USHORT;
#endif

#ifndef INT
typedef INT32                 INT;
#endif

#ifndef UINT
typedef UINT32                UINT;
#endif

#ifndef WORD
typedef UINT16                WORD;
#endif

#ifndef DWORD
typedef ULONG                 DWORD;
#endif

#ifndef FLAGS
typedef UINT32                FLAGS;
#endif

#ifndef LPSTR
typedef CHAR *                LPSTR;
#endif

#ifndef HANDLE
typedef void *                HANDLE;
#endif

#ifndef HCONTAINER
typedef HANDLE                HCONTAINER;
#endif

#ifndef DEVHANDLE
typedef HANDLE                DEVHANDLE;
#endif

#ifndef HAPPLICATION
typedef HANDLE                HAPPLICATION;
#endif

#endif
