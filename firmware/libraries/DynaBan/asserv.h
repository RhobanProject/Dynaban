#ifndef _ASSERV_H_
#define _ASSERV_H_
#include <wirish/wirish.h>
#include "motorManager.h"
#include "magneticEncoder.h"


const int P_COEF = 70;// 2 pour mémé //30 excellent // 200 coup sec que l'on sent être mauvais pour la méca // 1000 instabilité et endommagement matériel
const int I_COEF = 0;
const int I_PRESCALE = 1;
const int MAX_DELTA_SUM = 1000;
//Would be good to wait a few reads before calculating the derivate :
const int D_COEF = 50;

typedef enum _asservState_ {
    ARRIVED     = 0,
    IN_ACTION   = 1,
} asservState;

typedef struct _asserv_ {
    long deltaAngle;
    asservState state;
    int32 sumOfDeltas;
} asserv;

void asserv_init();
void asserv_tickP(motor * pMot);
void asserv_tickPI(motor * pMot);
void asserv_tickPID(motor * pMot);
void asserv_printAsserv();

#endif /* _ASSERV_H_ */
