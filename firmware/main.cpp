/*
Pour le codeur magnétique :
- Mettre en place les interruptions
- Trouver les limites de fonctionnement des tempos -> check mais décevant pour l'instant
- Voir s'il y a un intérêt a obtenir un angle à précision décimale -> check, la précision de la puce est impressionante,
par contre j'utilise une représentation en virgule fixe  (a voir s'il y a des conventions dessus dans l'équipe)
- Faire une machine d'états qui avance d'un cran à chaque interruption d'un timer, de sorte que la lecture ne bloque pas le reste.
   - Faire un codeur.c et codeur.h
   - Faire en sorte que l'utilisateur nous donne le numéro du timer et c'est tout (à voir si c'est sa responsabilité d'appeler la fonction codeur_tick)
   - Gérer le fait qu'il y ait plusieurs codeurs
   - Faire au mieux pour les attentes (je garde 1us pour les "grosses attentes" mais je peux accélérer la clock) => Utiliser le même timer pour des interruptions à pérdiode differentes
   
 */

// Sample main.cpp file. Blinks the built-in LED, sends a message out
// USART2, and turns on PWM on pin 2.

#include <wirish/wirish.h>
#include <libmaple/adc.h>
#include <libmaple/timer.h>
#include <DynaBan/magneticEncoder.h>
#include <DynaBan/motorManager.h>
#include <DynaBan/asserv.h>

int getAngle(bool pDebug);
bool isItSafeToPrintUSB();

typedef struct _hardware__ {
    encoder * enc;
    motor * mot;
} hardware;

int PWM_1_PIN = 27; // PA8
int PWM_2_PIN = 26; // PA9
int SHUT_DOWN_PIN = 23; // PA12 
int OVER_FLOW = 3000;
long counter = 0;
bool readyToUpdateHardware = false;
void setReadyToUpdateHardware();
hardware hardwareStruct;



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
   
    //Encoder init
    encoder_initSharingPinsMode(7, 8);
    encoder_addEncoderSharingPinsMode(6);
    
    //Motor init
    motor_init(encoder_getEncoder(0));
    asserv_init();
    
    hardwareStruct.enc = encoder_getEncoder(0);
    hardwareStruct.mot = motor_getMotor();
    
    HardwareTimer timer2(2);
    // The hardware will be read at 1Khz
    timer2.setPeriod(1000);
    timer2.setChannel1Mode(TIMER_OUTPUT_COMPARE);
    //Interrupt 1 count after each update
    timer2.setCompare(TIMER_CH1, 1);
    timer2.attachCompare1Interrupt(setReadyToUpdateHardware);
    
    delay(2000);
    motor_setTargetAngle(1800);
}

void setReadyToUpdateHardware() {
    readyToUpdateHardware = true;
}

void hardwareTick() {
    //Updating the encoder
    encoder_readAnglesSharingPinsMode();
        
    //Updating the motor
    motor_update(hardwareStruct.enc);
    
    //Updating asserv
    asserv_tickPropor(hardwareStruct.mot);
}

void loop() {
    delay(1);
    counter++;
    toggleLED();
    /*digitalWrite(BOARD_TX_ENABLE, HIGH);
    Serial1.println("Je fonctionne :)");
    Serial1.waitDataToBeSent();
    digitalWrite(BOARD_TX_ENABLE, LOW);

    if (counter < 16) {
        motor_setCommand(200 + 200 * counter);
    } else if (counter > 32) {
        counter = 0;
        motor_compliant();
        delay(15000);
        motor_restart();
    } else {
        motor_setCommand(-200 - 200 * (counter - 16));
    }
    
    delay(1000);
    return;*/

     if (counter == 1000) {  
         motor_setTargetAngle(900);
     } else if (counter == 2000) {
         motor_setTargetAngle(1800);
     } else if (counter == 3000) {
         motor_setTargetAngle(2700);
         counter = 0;
     }
    
    
    if (readyToUpdateHardware) {
        readyToUpdateHardware = false;
        
        hardwareTick();
        //Debug
        if (counter % 500 == 0) {
            #if BOARD_HAVE_SERIALUSB
            SerialUSB.println();
            SerialUSB.println("***Encoder");
            if (hardwareStruct.enc->isDataInvalid) {
                SerialUSB.println("Data invalid :/");        
            } else {
                SerialUSB.print("Anglex10 = ");
                SerialUSB.println(hardwareStruct.enc->angle);
            }
            motor_printMotor();
            asserv_printAsserv();
            #else
            digitalWrite(BOARD_TX_ENABLE, HIGH);
            Serial1.println();
            Serial1.println("***Encoder");
            if (hardwareStruct.enc->isDataInvalid) {
                Serial1.println("Data invalid :/");
            } else {
                Serial1.print("Anglex10 = ");
                Serial1.println(hardwareStruct.enc->angle);
            }
            motor_printMotor();
            asserv_printAsserv();
            Serial1.waitDataToBeSent();
         digitalWrite(BOARD_TX_ENABLE, LOW);
            #endif
        }
        }
        /*SerialUSB.print("Anglex10 = ");
          SerialUSB.println(readTenTimesAngleSequential(6, 7, 8));
        */

    //digitalWrite(BOARD_TX_ENABLE, HIGH);
}

#if BOARD_HAVE_SERIALUSB
bool isItSafeToPrintUSB() {
    return SerialUSB.isConnected() && (SerialUSB.getDTR() || SerialUSB.getRTS()); 
}
#endif
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
