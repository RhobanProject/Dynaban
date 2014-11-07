// Sample main.cpp file. Blinks the built-in LED, sends a message out
// USART2, and turns on PWM on pin 2.

#include <wirish/wirish.h>

void setup() {
    disableDebugPorts();
    pinMode(BOARD_LED_PIN, OUTPUT);

    // Initialization of USART
    digitalWrite(BOARD_TX_ENABLE, LOW);
    pinMode(BOARD_TX_ENABLE, OUTPUT);
    digitalWrite(BOARD_TX_ENABLE, LOW);

    afio_remap(AFIO_REMAP_USART1);
    gpio_set_mode(GPIOB, 6, GPIO_AF_OUTPUT_PP);
    gpio_set_mode(GPIOB, 7, GPIO_INPUT_FLOATING);
    Serial1.begin(57600);

/*
    HardwareTimer timer(1);
    timer.pause();
    timer.setPrescaleFactor(3);
    timer.setOverflow(1000);
    timer.refresh();
    timer.resume();

    // Setting to low before setting lines as output
    digitalWrite(BOARD_HBRIDGE_SD, LOW);
    digitalWrite(BOARD_HBRIDGE_A, LOW);
    digitalWrite(BOARD_HBRIDGE_B, LOW);

    pinMode(BOARD_HBRIDGE_SD, OUTPUT);
    digitalWrite(BOARD_HBRIDGE_SD, LOW);

    pinMode(BOARD_HBRIDGE_A, PWM);
    pwmWrite(BOARD_HBRIDGE_A, 0);

    pinMode(BOARD_HBRIDGE_B, PWM);
    pwmWrite(BOARD_HBRIDGE_B, 0);

    digitalWrite(BOARD_HBRIDGE_SD, HIGH);
    */
}

void loop() {
    static int sorry = 1;

    digitalWrite(BOARD_TX_ENABLE, HIGH);
    delay(2);
    Serial1.print("Sorry ...");
    Serial1.println(sorry++);
    delay(2);
    digitalWrite(BOARD_TX_ENABLE, LOW);

    digitalWrite(BOARD_LED_PIN, HIGH);
    delay(200);
    
    digitalWrite(BOARD_LED_PIN, LOW);
    delay(500);
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
