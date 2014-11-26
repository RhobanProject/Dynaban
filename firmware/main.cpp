/*
To do update 21/12/2014
- Mettre en place un PID. Bien qu'un asservissement en P donne, de manière très frustrante, d'excellents résultats.
- Lire la capteur de température
- Lire la mesure de courant
- Essayer d'asservir le moteur en utilisant la mesure de courant comme mesure de rétro-action
- Reproduire toutes les fonctionnalités dynamixel
 */

// Sample main.cpp file. Blinks the built-in LED, sends a message out
// USART2, and turns on PWM on pin 2.

#include <wirish/wirish.h>
#include <libmaple/adc.h>
#include <libmaple/timer.h>
#include <DynaBan/magneticEncoder.h>
#include <DynaBan/motorManager.h>
#include <DynaBan/asserv.h>
#include <DynaBan/dxl.h>

unsigned short terribleSignConvention(long pInput, long pIamZeroISwear);

typedef struct _hardware__ {
    encoder * enc;
    motor * mot;
} hardware;

const int OVER_FLOW = 3000;

long counter = 0;
int hardwareCounter = 0;
long debugCounter = 0;
bool readyToUpdateHardware = false;
void setReadyToUpdateHardware();
hardware hardwareStruct;

int16 current;

unsigned int dxl_data_available() {
    return Serial1.available();
}

ui8 dxl_data_byte() {
    return Serial1.read();
}

void dxl_send(ui8 *buffer, int n) {
    digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.write(buffer, n);
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);
}

bool dxl_sending() {
    return false;
}

void setup() {   
    disableDebugPorts();

    afio_remap(AFIO_REMAP_USART1);
    gpio_set_mode(GPIOB, 6, GPIO_AF_OUTPUT_PP);
    gpio_set_mode(GPIOB, 7, GPIO_INPUT_FLOATING);    

    Serial1.begin(57600);
    
    //Setting the timer's prescale to get a 24KHz PWM. The 2 pins share the same timer, channel 1 and 2.
    HardwareTimer timer1(1);
    timer1.setPrescaleFactor(1);
    timer1.setOverflow(OVER_FLOW);

    pinMode(BOARD_LED_PIN, OUTPUT);
    
    // Initialization of USART
    digitalWrite(BOARD_TX_ENABLE, LOW);
    pinMode(BOARD_TX_ENABLE, OUTPUT);
    digitalWrite(BOARD_TX_ENABLE, LOW);
   
    // ADC pin init
    pinMode(CURRENT_ADC_PIN, INPUT_ANALOG);

    //Encoder init
    encoder_initSharingPinsMode(7, 8);
    encoder_addEncoderSharingPinsMode(6);
    
    //Motor init
    motor_init(encoder_getEncoder(0));
    asserv_init();
    
    //dxl
    dxl_init();
    
    hardwareStruct.enc = encoder_getEncoder(0);
    hardwareStruct.mot = motor_getMotor();
    
    HardwareTimer timer2(2);
    // The hardware will be read at ~~48Khz
    timer2.setPeriod(21);
    timer2.setChannel1Mode(TIMER_OUTPUT_COMPARE);
    //Interrupt 1 count after each update
    timer2.setCompare(TIMER_CH1, 1);
    timer2.attachCompare1Interrupt(setReadyToUpdateHardware);
    
    delay(2000);
    //motor_setCommand(-2700);
    //motor_setTargetAngle(1800);
    //motor_setTargetCurrent(20);
    //motor_compliant();

    /* Recherche d'une série de bits en mémoire
    unsigned int *ptr = (unsigned int*)0x08000000;
    unsigned int *end = (unsigned int*)0x08020000;
    unsigned int value = 0x36012401;
    for (; ptr<end; ptr++) {
        if (*ptr == value) {
            digitalWrite(BOARD_TX_ENABLE, HIGH);
            Serial1.println("Found");
            Serial1.println((unsigned int)ptr);
            Serial1.waitDataToBeSent();
            digitalWrite(BOARD_TX_ENABLE, LOW);
	}
                                                  }*/
}

void setReadyToUpdateHardware() {
    readyToUpdateHardware = true;
}

void hardwareTick() {
    //The current must be read as often as possible because it's so noisy that it requires averaging for it to be usable
    motor_readCurrent();
    
    if (hardwareCounter > 47) {
        hardwareCounter = 0;
        //These actions are performed at a rate of 1KHz if the hardware tick is at 48KHz  
        //Updating the encoder
        encoder_readAnglesSharingPinsMode();
        
        //Updating the motor
        motor_update(hardwareStruct.enc);
         
        //Updating asserv
        //asserv_tickPID(hardwareStruct.mot);
        //asserv_tickPIDOnTorque(hardwareStruct.mot);
        
        /*
        digitalWrite(BOARD_TX_ENABLE, HIGH);
        Serial1.println();
        Serial1.print(debugCounter++);
        Serial1.print(" ");
        Serial1.print(hardwareStruct.mot->superAverageCurrent);
        
        Serial1.waitDataToBeSent();
        digitalWrite(BOARD_TX_ENABLE, LOW);
        */
    }

    hardwareCounter++;
}

void updateDxlRam() {
    dxl_regs.ram.presentPosition = hardwareStruct.mot->angle;
    dxl_regs.ram.presentSpeed = terribleSignConvention(hardwareStruct.mot->speed, 1024);
    
    dxl_regs.ram.presentLoad = terribleSignConvention(hardwareStruct.mot->superAverageCurrent, 1024);
    //dxl_regs.ram.presentVoltage = 0;
    //dxl_regs.ram.presentTemperature = -1;
    //dxl_regs.ram.registeredInstruction = ;
    if (hardwareStruct.mot->speed != 0) {
        dxl_regs.ram.moving = 1;
    } else {
        dxl_regs.ram.moving = 0;
    }
    
    dxl_regs.ram.current = terribleSignConvention(hardwareStruct.mot->superAverageCurrent, 2048);
}

/**
   From a signed convention to a weird unsigned convention
 */
unsigned short terribleSignConvention(long pInput, long pIamZeroISwear) {
    if (pInput > 0) {
        return (unsigned short) pInput;
    } else {
        return (unsigned short) (pIamZeroISwear - pInput);
    }
}

void loop() {
    //delay(1);
    //delay(10);
    //delayMicroseconds(10);
    counter++;
    //toggleLED();
    int fastCounter = 0;
    
    if (dxl_tick()) {
        digitalWrite(BOARD_LED_PIN, (dxl_regs.ram.led!=0) ? HIGH : LOW);
    }

    if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        hardwareTick();
    }

    //Debug
    // if (counter % (100*200) == 0) {
    //    toggleLED();
    // }
    /*if (counter % (100*200) == 0) {
        toggleLED();
            
        digitalWrite(BOARD_TX_ENABLE, HIGH);
        Serial1.println();
        Serial1.print("-----------------------:");
        motor_printMotor();
        asserv_printAsserv();
        Serial1.waitDataToBeSent();
        digitalWrite(BOARD_TX_ENABLE, LOW);       
        }*/
    
}


// Force init to be called *first*, i.e. before static object allocation.
// Otherwise, statically allocated objects that need libmaple may fail.
__attribute__((constructor)) void premain() {
    init();
}

int main(void) {
    setup();

    while (true) {
        loop();
    }

    return 0;
}
