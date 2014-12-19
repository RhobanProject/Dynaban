#include "circularBuffer.h"

void buffer_init(buffer * pBuf) {
    pBuf->start = 0;
    pBuf->end = 0;
    
    for (int i = 0; i < BUFF_SIZE; i++) {
        pBuf->buf[i] = 0;
    }
}

void buffer_add(buffer * pBuf, long pValue) {
    pBuf->buf[pBuf->end] = pValue;
    
    pBuf->end = (pBuf->end + 1)%BUFF_SIZE;
    
    if (pBuf->nbElements < BUFF_SIZE) {
        (pBuf->nbElements)++;
    } else {
        pBuf->start = (pBuf->start + 1)%BUFF_SIZE;
    }

}

long buffer_get(buffer * pBuf) {
    if (pBuf->nbElements < BUFF_SIZE) {
        return 0;
    } else {
        return pBuf->buf[pBuf->start];
    }
    
}

void buffer_printBuffer(buffer * pBuf) {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.print("Start : ");
    Serial1.println(pBuf->start);
    Serial1.print("End : ");
    Serial1.println(pBuf->end);
    for (int i = 0; i < BUFF_SIZE; i++) {
        Serial1.print(pBuf->buf[i]);
        Serial1.print(", ");
    }
    Serial1.println();
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
    
}

