#include <stdlib.h>
#include "circular_buffer.h"

void buffer_init(buffer * pBuf, int pSize, long pInit) {
    pBuf->start = 0;
    pBuf->end = 0;
    pBuf->size = pSize;
    pBuf->buf = (long*)malloc(sizeof(long) * pSize);

    for (int i = 0; i < pSize; i++) {
        pBuf->buf[i] = pInit;
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

void buffer_print(buffer * pBuf) {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.print("Start : ");
    Serial1.println(pBuf->start);
    Serial1.print("End : ");
    Serial1.println(pBuf->end);
    for (int i = 0; i < (pBuf->size); i++) {
        Serial1.print(pBuf->buf[i]);
        Serial1.print(", ");
    }
    Serial1.println();
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);

}
