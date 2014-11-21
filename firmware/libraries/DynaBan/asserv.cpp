#include "asserv.h"
 
static asserv asservStruct;

void asserv_init() {
    asservStruct.deltaAngle = 0;
    asservStruct.sumOfDeltas = 0;
    asservStruct.state = ARRIVED;
    asservStruct.indexOfLastInput = 0;
    asservStruct.indexOfFirstInput = 0;
}

void asserv_tickP(motor * pMot) {
    asservStruct.deltaAngle = pMot->targetAngle - pMot->currentAngle;
    if (asservStruct.deltaAngle > 1800) {
        // There is a shorter way, engine bro
        asservStruct.deltaAngle = pMot->currentAngle - pMot->targetAngle;
    }
    
    motor_setCommand(asservStruct.deltaAngle * P_COEF);
}

// This is not working at all bro
void asserv_tickPI(motor * pMot) {
    asservStruct.deltaAngle = pMot->targetAngle - pMot->currentAngle;

    if (asservStruct.deltaAngle > 1800) {
        // There is a shorter way, engine bro
        asservStruct.deltaAngle = pMot->currentAngle - pMot->targetAngle;
    }
    
    if(asservStruct.indexOfLastInput == (NB_MAX_DELTAS - 1)) {
        // The list is full, we'll remove the first input and replace it by the new
        //Substracting the first input and adding the new input
        asservStruct.sumOfDeltas = asservStruct.sumOfDeltas - asservStruct.listOfPreviousDeltaAngles[asservStruct.indexOfFirstInput] + asservStruct.deltaAngle;  
        
        //Replacing
        asservStruct.listOfPreviousDeltaAngles[asservStruct.indexOfFirstInput] = asservStruct.deltaAngle;

        if (asservStruct.indexOfFirstInput == (NB_MAX_DELTAS - 1)) {
            asservStruct.indexOfFirstInput = 0;
        } else {
            (asservStruct.indexOfFirstInput)++;
        }
    } else {
        // The list is not full yet
        asservStruct.sumOfDeltas = asservStruct.sumOfDeltas + asservStruct.deltaAngle;
        asservStruct.listOfPreviousDeltaAngles[asservStruct.indexOfLastInput];
        (asservStruct.indexOfLastInput)++;
    }

    asservStruct.sumOfDeltas = asservStruct.sumOfDeltas + asservStruct.deltaAngle;
    motor_setCommand(asservStruct.deltaAngle * P_COEF + asservStruct.sumOfDeltas * I_COEF);
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
    Serial1.print("sumOfDeltas : ");
    Serial1.println(asservStruct.sumOfDeltas);
}
#endif
