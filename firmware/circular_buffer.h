#ifndef _CIRCULAR_BUFFER_H_
#define _CIRCULAR_BUFFER_H_
#include <wirish/wirish.h>

struct buffer {
    int size;
    long* buf;
    int start;
    int end;
    int nbElements;
};

buffer * buffer_creation(int pSize, long pInit);
void buffer_delete(buffer * pBuffer);
void buffer_add(buffer * pBuf, long pValue);
long buffer_get(buffer * pBuf);
void buffer_reset_values(buffer * pBuf, long pValue);
void buffer_print(buffer * pBuf);

#endif /* _CIRCULAR_BUFFER_H_*/
