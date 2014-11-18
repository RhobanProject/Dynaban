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
encoder * encoder0;

void setup() {   
    disableDebugPorts();
    pinMode(BOARD_LED_PIN, OUTPUT);

    // Initialization of USART
    digitalWrite(BOARD_TX_ENABLE, LOW);
    pinMode(BOARD_TX_ENABLE, OUTPUT);
    digitalWrite(BOARD_TX_ENABLE, LOW);

    /*afio_remap(AFIO_REMAP_USART1);
    gpio_set_mode(GPIOB, 6, GPIO_AF_OUTPUT_PP);
    gpio_set_mode(GPIOB, 7, GPIO_INPUT_FLOATING);*/

    delay(3000);
    SerialUSB.println("C'est parti !");
    
    //Encoder management
    encoder_initSharingPinsMode(1, 7, 8);
    encoder_addEncoderSharingPinsMode(6);
    encoder_start();
}

void loop() {    
    while(encoder_isReadyToRead() == false);
    toggleLED();
    encoder_readAnglesSharingPinsMode();
    encoder0 = encoder_getEncoder(0);
    if (encoder0->isDataInvalid) {
        SerialUSB.println("Data invalid :/");
    } else {
        SerialUSB.print("Anglex10 = ");
        SerialUSB.println(encoder0->angle);
        SerialUSB.print("Questionnable? : ");
        SerialUSB.println(encoder0->isDataQuestionable);
    }

    /*SerialUSB.print("Anglex10 = ");
    SerialUSB.println(readTenTimesAngleSequential(6, 7, 8));
    */
    delay(100);
    //digitalWrite(BOARD_TX_ENABLE, HIGH);
}

bool isItSafeToPrintUSB() {
    return SerialUSB.isConnected() && (SerialUSB.getDTR() || SerialUSB.getRTS()); 
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
