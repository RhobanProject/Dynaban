#ifndef _MAGNETIC_ENCODER_H_
#define _MAGNETIC_ENCODER_H_

#include <wirish/wirish.h>

typedef struct _encoder_ {
    int DOPin;
    int CLKPin;
    int CSPin;
    long angle;
    long inputLong;
    bool isDataQuestionable;
    bool isDataInvalid;
} encoder;

encoder * encoder_getEncoder(uint8 pEncoderId);

/**
   /!\ Using this function implies that all of the encoder you'll connect will share the same CLK pin and the same CS pin.
   The encoder's angle value will be updated every pDelayBetweenReadsUs us +
   pDelayBetweenReadsUs ms. 
   pTimerIndex is the id of the timer that shall be used for handling the encoder 
   (eg. 1 to 4 on the maple mini).
 */
void encoder_initSharingPinsMode(uint8 pTimerIndex, uint8 pClkPin, uint8 pCsPin);


void encoder_addEncoderSharingPinsMode(uint8 pDOPin);

/**
   Reads all the encoders
 */
void encoder_readAnglesSharingPinsMode();


long encoder_getAngle(uint8 pEncoderId);
bool encoder_isReadyToRead();
void encoder_start();

/**
   Return 10x an encoder angle in an one shot fashion (no need to call init, addEncoder or start). 
 */
long encoder_readAngleSequential(uint8 pDOPin, uint8 pCLKPin, uint8 pCSPin);


/** TO DO :
   Adds a magnetic encoder specifying its DO, CLK and CS pin.
 */
void encoder_addEncoder(uint8 pDOPin, 
                 uint8 pCLKPin, 
                 uint8 pCSPin);

#endif  /* _MAGNETIC_ENCODER_H_ */
