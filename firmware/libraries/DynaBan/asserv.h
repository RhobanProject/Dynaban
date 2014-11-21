#ifndef _ASSERV_H_
#define _ASSERV_H_
#include <wirish/wirish.h>
#include "motorManager.h"
#include "magneticEncoder.h"


const int P_COEF = 30;// 2 pour mémé //30 excellent // 200 coup sec que l'on sent être mauvais pour la méca // 1000 instabilité et endommagement matériel
const int I_COEF = 5;
const int D_COEF = 0;
const int NB_MAX_DELTAS = 20;

typedef enum _asservState_ {
    ARRIVED     = 0,
    IN_ACTION   = 1,
} asservState;

typedef struct _asserv_ {
    long deltaAngle;
    asservState state;
    uint32 sumOfDeltas;
    long listOfPreviousDeltaAngles[20];
    int indexOfLastInput;
    int indexOfFirstInput;
} asserv;

void asserv_init();
void asserv_tickP(motor * pMot);
void asserv_tickPI(motor * pMot);
void asserv_printAsserv();

#endif /* _ASSERV_H_ */
