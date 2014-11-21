#include "asserv.h"


typedef enum _asservState_ {
    ARRIVED     = 0,
    IN_ACTION   = 1,
} asservState;

typedef struct _asserv_ {
    long deltaAngle;
    asservState state;
} asserv;

const int pCoef = 30;
const int iCoef = 5;
const int dCoef = 0;
static asserv asservStruct;

void asserv_init() {
    asservStruct.deltaAngle = 0;
    asservStruct.state = ARRIVED;
}

void asserv_tickPropor(motor * pMot) {
    asservStruct.deltaAngle = pMot->targetAngle - pMot->currentAngle;
    
    motor_setCommand(asservStruct.deltaAngle * pCoef);
}

#if BOARD_HAVE_SERIALUSB
void asserv_printAsserv() {
    SerialUSB.println("***Asserv :");
    SerialUSB.print("deltaAngle : ");
    SerialUSB.println(asservStruct.deltaAngle);
    SerialUSB.print("state : ");
    SerialUSB.println(asservStruct.state);
}
#else 
void asserv_printAsserv() {
    Serial1.println("***Asserv :");
    Serial1.print("deltaAngle : ");
    Serial1.println(asservStruct.deltaAngle);
    Serial1.print("state : ");
    Serial1.println(asservStruct.state);
}
#endif
