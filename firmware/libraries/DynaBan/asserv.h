#ifndef _ASSERV_H_
#define _ASSERV_H_
#include <wirish/wirish.h>
#include "motorManager.h"
#include "magneticEncoder.h"

void asserv_init();
void asserv_tickPropor(motor * pMot);
void asserv_printAsserv();

#endif /* _ASSERV_H_ */
