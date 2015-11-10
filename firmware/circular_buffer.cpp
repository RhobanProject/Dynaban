#include <stdlib.h>
#include "circular_buffer.h"

buffer * buffer_creation(int pSize, long pInit) {
	// Allocating space for the struct (the buf field will still be only a pointer)
	buffer *  result = (buffer *) malloc (sizeof(buffer));
	if (result == NULL) {
		return NULL;
	}

	// Allocating space for the buf field
	result->buf = (long *) malloc (pSize * sizeof(long));
	if (result->buf == NULL) {
		return NULL;
	}

    result->start = 0;
    result->end = 0;
    result->size = pSize;
    result->nbElements = 0;

    for (int i = 0; i < pSize; i++) {
        result->buf[i] = pInit;
    }

    return result;
}

void buffer_delete(buffer * pBuffer) {
	if (pBuffer != NULL) {
		free (pBuffer->buf);
		free (pBuffer);
	}
}


void buffer_add(buffer * pBuf, long pValue) {
    pBuf->buf[pBuf->end] = pValue;

    pBuf->end = (pBuf->end + 1)%(pBuf->size);

    if (pBuf->nbElements < (pBuf->size)) {
        (pBuf->nbElements)++;
    } else {
        pBuf->start = (pBuf->start + 1)%(pBuf->size);
    }

}

long buffer_get(buffer * pBuf) {
    if (pBuf->nbElements < (pBuf->size)) {
        return 0;
    } else {
        return pBuf->buf[pBuf->start];
    }

}

void buffer_reset_values(buffer * pBuf, long pValue) {
    for (int i = 0; i < pBuf->size; i++) {
        pBuf->buf[i] = pValue;
    }

}

void buffer_print_buffer(buffer * pBuf) {
	Serial1.print("Size : ");
	Serial1.println(pBuf->size);
	Serial1.print("Nb elements : ");
	Serial1.println(pBuf->nbElements);
    Serial1.print("Start : ");
    Serial1.println(pBuf->start);
    Serial1.print("End : ");
    Serial1.println(pBuf->end);
    for (int i = 0; i < (pBuf->size); i++) {
        Serial1.print(pBuf->buf[i]);
        Serial1.print(", ");
    }
    Serial1.println();

}
