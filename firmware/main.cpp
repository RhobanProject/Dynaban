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

int getAngle(bool pDebug);
bool isItSafeToPrintUSB();

int PWM_1_PIN = 27; // PA8
int PWM_2_PIN = 26; // PA9
int SHUT_DOWN_PIN = 23; // PA12 
int OVER_FLOW = 3000;
encoder * encoder0;
int counter = 0;

void setup() {   
    disableDebugPorts();

    afio_remap(AFIO_REMAP_USART1);
    gpio_set_mode(GPIOB, 6, GPIO_AF_OUTPUT_PP);
    gpio_set_mode(GPIOB, 7, GPIO_INPUT_FLOATING);    

    Serial1.begin(57600);

    //Ensuring the shut down is active (inversed logic on this one)
    digitalWrite(SHUT_DOWN_PIN, LOW);
    pinMode(SHUT_DOWN_PIN, OUTPUT);
    digitalWrite(SHUT_DOWN_PIN, LOW);

    //Procedure to safely prepare the first PWM signal
    digitalWrite(PWM_1_PIN, LOW);
    pinMode(PWM_1_PIN, PWM);
    pwmWrite(PWM_1_PIN, 0x0000);

    //Procedure to safely prepare the second PWM signal
    digitalWrite(PWM_2_PIN, LOW);
    pinMode(PWM_2_PIN, PWM);
    pwmWrite(PWM_2_PIN, 0x0000);
    
    //Setting the timer's prescale to get roughly a 25KHz PWM. THe 2 pins share the same timer, channel 1 and 2.
    HardwareTimer timer1(1);
    timer1.setPrescaleFactor(1);
    timer1.setOverflow(OVER_FLOW);

    pinMode(BOARD_LED_PIN, OUTPUT);
       
    // Initialization of USART
    digitalWrite(BOARD_TX_ENABLE, LOW);
    pinMode(BOARD_TX_ENABLE, OUTPUT);
    digitalWrite(BOARD_TX_ENABLE, LOW);

       
    //Encoder management
    encoder_initSharingPinsMode(7, 8);
    encoder_addEncoderSharingPinsMode(6);
    
    delay(2000);
    digitalWrite(SHUT_DOWN_PIN, HIGH);
    pwmWrite(PWM_1_PIN, 1500);
}

void loop() {
    counter++;
    toggleLED();

    encoder_readAnglesSharingPinsMode();
    encoder0 = encoder_getEncoder(0);
#if BOARD_HAVE_SERIALUSB
    if (encoder0->isDataInvalid) {
        digitalWrite(BOARD_TX_ENABLE, HIGH);
        SerialUSB.println("Data invalid :/");
        Serial1.waitDataToBeSent();
        digitalWrite(BOARD_TX_ENABLE, LOW);
        
    } else {
        SerialUSB.print("Anglex10 = ");
        SerialUSB.println(encoder0->angle);
    }
#else
    if (encoder0->isDataInvalid) {
        digitalWrite(BOARD_TX_ENABLE, HIGH);
        Serial1.println("Data invalid :/");
        Serial1.waitDataToBeSent();
        digitalWrite(BOARD_TX_ENABLE, LOW);
    } else {
        digitalWrite(BOARD_TX_ENABLE, HIGH);
        Serial1.print("Anglex10 = ");
        Serial1.println(encoder0->angle);
        Serial1.waitDataToBeSent();
        digitalWrite(BOARD_TX_ENABLE, LOW);
    }
#endif
    /*SerialUSB.print("Anglex10 = ");
    SerialUSB.println(readTenTimesAngleSequential(6, 7, 8));
    */

    delay(100);
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
