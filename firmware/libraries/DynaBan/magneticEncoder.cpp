#include "magneticEncoder.h"

/**
   Example code using this interface with 1 encoder :
   
   //In setup()
   initSharingPinsMode(1, 7, 8);
   addEncoderSharingPinsMode(6);
   start();

   //In loop()
   while(isReadyToRead() == false);
    //toggleLED();
    readAnglesSharingPinsMode();
    encoder0 = getEncoder(0);
    if (encoder0->isDataInvalid) {
        SerialUSB.println("Data invalid :(");
    } else {
        SerialUSB.print("Angle = ");
        SerialUSB.println(encoder0->tenTimesAngle);
        SerialUSB.print("Questionnable? : ");
        SerialUSB.println(encoder0->isDataQuestionable);
    }
 */

static int DO_PIN;
static int CLK_PIN;
static int CS_PIN;

// 0x111111111111000000: mask to obtain first 12 digits with position info
static long ANGLE_MASK = 262080;
// 0x000000000000111111; mask to obtain last 6 digits containing status info
static long STATUS_MASK = 63;
// one bit read from pin
static int inputBit = 0;
// holds status/error information
static long statusbits;
// bit holding decreasing magnet field error data
//static int DECn; 
// bit holding increasing magnet field error data
//static int INCn;
// bit holding startup-valid bit
//static int OCF;
// bit holding cordic DSP processing error data
static int COF; 
// bit holding magnet field displacement error data
static int LIN; 

static bool debug = 0;
static int nbEncoders = 0;
//static int state = 0;
static bool readyToRead = true;

static long arrayOfTimeStamps[30];

HardwareTimer * timer;
const int NB_ENCODERS_MAX = 10;
static encoder arrayOfEncoders[10];

void setReadyToRead();
long * getArrayOfTimeStamps();
void printEncoder(encoder * pEncoder);

long * getArrayOfTimeStamps() {
    return arrayOfTimeStamps;
}

/*bool encoder_isReadyToRead() {
    return readyToRead;
    }*/


void setReadyToRead() {
    if (nbEncoders) {
        readyToRead = true;
    } else {
        readyToRead = false;
    }
}

encoder * encoder_getEncoder(uint8 pEncoderId) {
    return &arrayOfEncoders[pEncoderId];
}

/**
   /!\ Using this functions implies that all of the encoder you'll connect will share the same CLK pin and the same CS pin.
 */
void encoder_initSharingPinsMode(uint8 pClkPin, uint8 pCsPin) {
    //timer = new HardwareTimer(pTimerIndex);
    nbEncoders = 0;
    CLK_PIN = pClkPin;
    CS_PIN = pCsPin;

    pinMode(CLK_PIN, OUTPUT);
    pinMode(CS_PIN, OUTPUT);

    // Initial state
    digitalWrite(CS_PIN, LOW);
    digitalWrite(CLK_PIN, HIGH);

    // Pause the timer while we're configuring it
    //timer->pause();
    // Set up period
    //timer->setPeriod(1); // in microseconds
    //timer->setPrescaleFactor(1); //prescale = 1 => freq = 72MHz, prescale = 65535 => freq = 1099 Hz
    //timer->setOverflow(10); // 1 to 65535
    
    //Set up an interrupt on channel 1
    //timer->setChannel1Mode(TIMER_OUTPUT_COMPARE);
    //Interrupt 1 count after each update
    //timer->setCompare(TIMER_CH1, 1);
    //timer->attachCompare1Interrupt(setReadyToRead);
    
    // The timer shall be restarted  through the "start()" function after all the encoders have been added
    
    // Init of the array of encoders
    for (int i = 0; i < NB_ENCODERS_MAX; i++) {
        arrayOfEncoders[i].DOPin = 0;
        arrayOfEncoders[i].CLKPin = 0;
        arrayOfEncoders[i].CSPin = 0;
        arrayOfEncoders[i].angle = 0;
        arrayOfEncoders[i].inputLong = 0;
        arrayOfEncoders[i].isDataQuestionable = 0;
        arrayOfEncoders[i].isDataInvalid = 0;
    }
}

/**
   Activates the timer so the read cycle can start
 */
void encoder_start() {
    // Refresh the timer's count, prescale, and overflow
    //timer->refresh();
    // Start the timer counting
    //timer->resume();
}

void encoder_addEncoderSharingPinsMode(uint8 pDOPin) {
    encoder newEncoder;

    newEncoder.DOPin = pDOPin;
    // CLK pin is shared with the other encoders
    newEncoder.CLKPin = CLK_PIN;
    // CS pin is shared with the other encoders
    newEncoder.CSPin = CS_PIN;
    newEncoder.angle = 0;
    newEncoder.inputLong = 0;
    newEncoder.isDataQuestionable = false;
    newEncoder.isDataInvalid = false;
    newEncoder.DOPin = pDOPin;

    //Setting the pins
    pinMode(DO_PIN, INPUT);
    //pinMode(CLK_PIN, OUTPUT);
    //pinMode(CS_PIN, OUTPUT);     
    
    arrayOfEncoders[nbEncoders] = newEncoder;
    //printEncoder(&arrayOfEncoders[nbEncoders]);
    nbEncoders++;
}

void encoder_readAnglesSharingPinsMode() {    
    //arrayOfTimeStamps[0] = timer->getCount();
    int halfClkPeriodUs = 1; // DataSheet says >= 500 ns
    encoder * enc;
    for (int i = 0; i < nbEncoders; i++) {
        enc = &arrayOfEncoders[i];
        enc->inputLong = 0;
        enc->angle = 0;
    }
    
    // Toggling CSn twice to start the communication
    digitalWrite(CS_PIN, HIGH);
    delayMicroseconds(halfClkPeriodUs);
    
    // Start of transfer
    digitalWrite(CS_PIN, LOW); 
    delayMicroseconds(halfClkPeriodUs);
     
    digitalWrite(CLK_PIN, LOW);    
    delayMicroseconds(halfClkPeriodUs);
    
    for (int i = 0; i < 18; i++) { 
        //18 clock cycles
        digitalWrite(CLK_PIN, HIGH);
        delayMicroseconds(halfClkPeriodUs);
        
        // read one bit of data from pin
        for (int j = 0; j < nbEncoders; j++) {
            enc = &arrayOfEncoders[j];
            inputBit = digitalRead(enc->DOPin);
            
            //Stacking and shifting the bits to get the int value
            enc->inputLong = ((enc->inputLong << 1) + inputBit);
        }
        
        if (i != 17) {
            // Lets de clock up at the end of the communication
            digitalWrite(CLK_PIN, LOW);
            delayMicroseconds(halfClkPeriodUs);
        }
    }

    for (int i = 0; i < nbEncoders; i++) {
        enc = &arrayOfEncoders[i];
        enc->angle = enc->inputLong & ANGLE_MASK;
        // shifting 18-digit angle right 6 digits to form 12-digit value
        enc->angle = (enc->angle >> 6); 
        
        enc->angle = enc->angle; //0.08789 == angle * (360/4096) == actual degrees
        
        if (debug) {
            statusbits = enc->inputLong & STATUS_MASK;
            //DECn = statusbits & 2; // goes high if magnet moved away from IC
            //INCn = statusbits & 4; // goes high if magnet moved towards IC
            LIN = statusbits & 8; // goes high for linearity alarm
            COF = statusbits & 16; // goes high for cordic overflow: data invalid
            //OCF = statusbits & 32; // this is 1 when the chip startup is finished.
            /*if (DECn && INCn) { 
                SerialUSB.println("magnet moved out of range"); 
            } else {
                    if (DECn) { 
                        SerialUSB.println("magnet moved away from chip"); 
                    }
                    if (INCn) { 
                        SerialUSB.println("magnet moved towards chip"); 
                    }
                    }*/
            
            if (LIN) { 
                enc->isDataQuestionable = true; 
                //SerialUSB.println("linearity alarm: magnet misaligned? Data questionable."); 
            } else if (COF) { 
                enc->isDataInvalid = true; 
                //SerialUSB.println("cordic overflow: magnet misaligned? Data invalid."); 
            } else {
                enc->isDataQuestionable = false; 
                enc->isDataInvalid = false; 
            }
        }
        //printEncoder(enc);
    }
    
    
    //arrayOfTimeStamps[1] = timer->getCount();    
}

#if BOARD_HAVE_SERIALUSB
void printEncoder(encoder * pEncoder) {
    SerialUSB.print("DOPin : ");
    SerialUSB.println(pEncoder->DOPin);
    SerialUSB.print("CLKPin : ");
    SerialUSB.println(pEncoder->CLKPin);
    SerialUSB.print("CSPin : ");
    SerialUSB.println(pEncoder->CSPin);
    SerialUSB.print("tenTimesAngle : ");
    SerialUSB.println(pEncoder->angle);
    SerialUSB.print("inputLong : ");
    SerialUSB.println(pEncoder->inputLong);
    SerialUSB.print("isDataQuestionable : ");
    SerialUSB.println(pEncoder->isDataQuestionable);
    SerialUSB.print("isDataInvalid : ");
    SerialUSB.println(pEncoder->isDataInvalid);
}
#endif
long encoder_readAngleSequential(uint8 pDOPin, uint8 pCLKPin, uint8 pCSPin) {    
    //arrayOfTimeStamps[0] = timer->getCount();
    int halfClkPeriodUs = 1; // DataSheet says >= 500 ns
    long inputLong = 0;
    long angle = 0;
    
    // Toggling CSn twice to start the communication
    digitalWrite(pCSPin, HIGH);
    delayMicroseconds(halfClkPeriodUs);
    
    // Start of transfer
    digitalWrite(pCSPin, LOW); 
    delayMicroseconds(halfClkPeriodUs);
     
    digitalWrite(pCLKPin, LOW);
    
    delayMicroseconds(halfClkPeriodUs);
    
    for (int i = 0; i < 18; i++) { 
        //18 clock cycles
        digitalWrite(pCLKPin, HIGH);
        delayMicroseconds(halfClkPeriodUs);
        // read one bit of data from pin
        inputBit = digitalRead(pDOPin);
        //Stacking and shifting the bits to get the int value
        inputLong = ((inputLong << 1) + inputBit);
        if (i != 17) {
            // Lets de clock up at the end of the communication
            digitalWrite(pCLKPin, LOW);
            delayMicroseconds(halfClkPeriodUs);
        }
    }

    angle = inputLong & ANGLE_MASK;
    angle = (angle >> 6); // shift 18-digit angle right 6 digits to form 12-digit value
    
    // /!\ warning, x10 :
    angle = angle;// * 0.8789; //0.08789 == angle * (360/4096) == actual degrees
    if (debug) {
            statusbits = inputLong & STATUS_MASK;
            //DECn = statusbits & 2; // goes high if magnet moved away from IC
            //INCn = statusbits & 4; // goes high if magnet moved towards IC
            LIN = statusbits & 8; // goes high for linearity alarm
            COF = statusbits & 16; // goes high for cordic overflow: data invalid
            //OCF = statusbits & 32; // this is 1 when the chip startup is finished.
            /*if (DECn && INCn) { 
                SerialUSB.println("magnet moved out of range"); 
            } else {
                    if (DECn) { 
                        SerialUSB.println("magnet moved away from chip"); 
                    }
                    if (INCn) { 
                        SerialUSB.println("magnet moved towards chip"); 
                    }
                    }*/
            
          if (LIN) {  
              //SerialUSB.println("linearity alarm: magnet misaligned? Data questionable."); 
          } else if (COF) { 
              angle = -1;
              //SerialUSB.println("cordic overflow: magnet misaligned? Data invalid."); 
          }
    }
    return angle;
    //arrayOfTimeStamps[1] = timer->getCount();    
}


/**
   The following code uses a state machine approach to get de encoder's value. 
   A timer was used to schedule interruptions every 1us which is the delay between every step of the 
   reading procedure (thus freeing the Uc during the waiting moments).
   Unfortunately, this approach was not viable because the treatment of an interruption procedure every 1us was 
   overwhelming for the Uc (whose clock was 72Mhz, thus allowing only 72 cycles before the next 
   interruption).
   
   This approach would still be viable in a context where it is important to optimize the Uc load and
   where it is acceptable to wait longer to get the encoder's value (set the interruption period 
   at 10 us and you'll be fine).
 */
/*
void addEncoder(uint8 pTimerIndex, 
                 uint8 pDOPin, 
                 uint8 pCLKPin, 
                 uint8 pCSPin, 
                 uint16 pDelayBetweenReadsUs, uint16 pDelayBetweenReadsMs) {
    
    timer = new HardwareTimer(pTimerIndex);
    DO_PIN = pDOPin;
    CLK_PIN = pCLKPin;
    CS_PIN = pCSPin;
    
    //Setting the pins
    pinMode(DO_PIN, INPUT);
    pinMode(CLK_PIN, OUTPUT);
    pinMode(CS_PIN, OUTPUT);     
    
    // Initial state
    digitalWrite(CS_PIN, LOW);
    digitalWrite(CLK_PIN, HIGH);
    
    // Pause the timer while we're configuring it
    timer->pause();
    // Set up period
    timer->setPeriod(10); // in microseconds
    //timer->setPrescaleFactor(1); //prescale = 1 => freq = 72MHz, prescale = 65535 => freq = 1099 Hz
    //timer->setOverflow(10); // 1 to 65535
    // Set up an interrupt on channel 1
    timer->setChannel1Mode(TIMER_OUTPUT_COMPARE);
    // Interrupt 1 count after each update
    timer->setCompare(TIMER_CH1, 1);
    timer->attachCompare1Interrupt(encoderTick);
    // Refresh the timer's count, prescale, and overflow
    timer->refresh();
    // Start the timer counting
    timer->resume();
}

void encoderTick() {
    temp++;
    if (temp == 50000) {
        toggleLED();
        temp = 0;
    }
    //return;
    switch ( state ) {
    case 0:
        // Waiting for the next read
        inputLong = 0;
        inputBit = 0;
        nbReads = 0;
        state++;
        arrayOfTimeStamps[0] = timer->getCount();
        break;
    case 1:
        //Asking for a new Read (CS HIGH)
        digitalWrite(CS_PIN, HIGH);
        state++;
        arrayOfTimeStamps[1] = timer->getCount();
        break;
    case 2:
        //Asking for a new Read (CS LOW)
        digitalWrite(CS_PIN, LOW);
        state++;
        arrayOfTimeStamps[2] = timer->getCount();
        break;
    case 3:
        //Starting transmission
        digitalWrite(CLK_PIN, LOW);
        state++;
        arrayOfTimeStamps[3] = timer->getCount();
        break;
    case 4:
        // Clock HIGH
        digitalWrite(CLK_PIN, HIGH);
        if (nbReads != 17) {
            state = 5;
        } else {
            state = 6;
        }
        arrayOfTimeStamps[4] = timer->getCount();
        break;
    case 5:
        // Clock LOW => reading 1 bit
        digitalWrite(CLK_PIN, LOW);
        // Read one bit of data from pin
        inputBit = digitalRead(DO_PIN);
        // Stacking and shifting the bits to get the int value
        inputLong = ((inputLong << 1) + inputBit);
        
        nbReads ++;
        state = 4;
        arrayOfTimeStamps[5] = timer->getCount();
        break;
    case 6:
        // Reading last bit and calculating angle (CLK stays HIGH)

        // Read one bit of data from pin
        inputBit = digitalRead(DO_PIN);
        // Stacking and shifting the bits to get the int value
        inputLong = ((inputLong << 1) + inputBit);
        
        binAngle = inputLong;
        angle = inputLong & anglemask;
        // shift 18-digit angle right 6 digits to form 12-digit value
        angle = (angle >> 6); 
        // Attention, x10 :
        // 0.08780 == (360/4096)
        angle = angle * 0.8789; //0.08789 * angle == actual degrees
    
        if (debug) {
            statusbits = inputLong & statusmask;
            //DECn = statusbits & 2; // goes high if magnet moved away from IC
            //INCn = statusbits & 4; // goes high if magnet moved towards IC
            LIN = statusbits & 8; // goes high for linearity alarm
            COF = statusbits & 16; // goes high for cordic overflow: data invalid
            //OCF = statusbits & 32; // this is 1 when the chip startup is finished.
            
            if (LIN) { 
                isDataQuestionable = true; 
                //SerialUSB.println("linearity alarm: magnet misaligned? Data questionable."); 
            } else if (COF) { 
                isDataInvalid = true; 
                //SerialUSB.println("cordic overflow: magnet misaligned? Data invalid."); 
            } else {
                isDataQuestionable = false; 
                isDataInvalid = false; 
            }
        }

        state = 0;
        arrayOfTimeStamps[6] = timer->getCount();
        break;
    default:
        break;
    }
}
*/



