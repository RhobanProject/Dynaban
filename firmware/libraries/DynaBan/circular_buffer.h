#ifndef _CIRCULAR_BUFFER_H_
#define _CIRCULAR_BUFFER_H_
#include <wirish/wirish.h>

//const int BUFF_SIZE = 128;

typedef struct _buffer_ {
    int size;
    long* buf;
    int start;
    int end;
    int nbElements;
} buffer;

void buffer_init(buffer * pBuf, int pSize);
void buffer_add(buffer * pBuf, long pValue);
long buffer_get(buffer * pBuf);
void buffer_print(buffer * pBuf);

#endif /* _CIRCULAR_BUFFER_H_*/
