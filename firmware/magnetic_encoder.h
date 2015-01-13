#ifndef _MAGNETIC_ENCODER_H_
#define _MAGNETIC_ENCODER_H_

#include <wirish/wirish.h>

struct encoder {
    int DOPin;
    int CLKPin;
    int CSPin;
    long angle;
    long inputLong;
    bool isDataQuestionable;
    bool isDataInvalid;
};

encoder * encoder_get_encoder(uint8 pEncoderId);

/**
   /!\ Using this function implies that all of the encoder you'll connect will share the same CLK pin and the same CS pin.
 */
void encoder_init_sharing_pins_mode(uint8 pClkPin, uint8 pCsPin);

/**
 * Adds an encoder to the array of encoders when you're in the sharing pins mode.
 * You need to call encoder_init_sharing_pins_mode(uint8 pClkPin, uint8 pCsPin) before this one.
 */
void encoder_add_encoder_sharing_pins_mode(uint8 pDOPin);

/**
   Reads all the encoders when you're in sharing pins mode.
   This functions optimizes the read time if you have more than 1 encoder since
   the waiting times are shared and not stacked.
 */
void encoder_read_angles_sharing_pins_mode();

/**
 * Returns the angle value (between 0 and 4095) from the specified encoder.
 * The function encoder_read_angles_sharing_pins_mode() needs to be called first though.
 */
long encoder_get_angle(uint8 pEncoderId);

/**
 * Returns the encoder angle in an one shot fashion (no need to call init or addEncoder).
 * Sub-optimal choice if you have more than 1 encoder.
 */
long encoder_read_angle_sequential(uint8 pDOPin, uint8 pCLKPin, uint8 pCSPin);

/**
 * Debug print.
 */
void printEncoder(encoder * pEncoder);

#endif  /* _MAGNETIC_ENCODER_H_ */
