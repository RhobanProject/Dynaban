** TODO list
(check)- Invert rotation convention (invert read + action)
(nope, our convention is better) - Change the torque_enable convention? (auto on if a command is given)

- The half-bridge driver has a ~500ns dead time for ON and for OFF. Depending on the PWM duty cycle, this can have an impact of more than 10% on the actual PWM felt by the motor. --> Very simple and important to account for !

- When measuring the speed, we have a configurable delay that tunes the precision/delay trade-off. But we can do better, during that delay we know what orders were sent, hence we can use the model to enhance the speed measure.

(could not reproduce the bug) - The Servo does not answer reads if torque_enable = 0. This is quite confusing if you test it for the first time.


(check, it was a bug actually)- Change the default CW and CCW position limits so it can't make more than 360 out of the box

- bootloader?

- Implement the bulk read
- Adding an ID in the dark flash (date and version of the firmware too), like a\
 serial number. And stats : how long has the servo been used, how many degress \
 has it rotated?
- Dynaban 106 (MX28?)

- check Endianness?
"
It Looks that you mixed up the error codes. The Notation of the Robotis Error Code in the Doku is Little endian

Bit 8 - Bit 7 - Bit 6 - Bit 5 - Bit 4 - Bit 3 - Bit 2 - Bit 1  - Bit 0
Or:

00000000 - No Error
00000001 - Input Voltage Error
00000010 - Angle Limit Error
etc..

From your code:

#define DXL_INSTRUCTION_ERROR   1
#define DXL_OVERLOAD_ERROR 2
"

From Quentin :
"
Oui, c'est ça. Surtout pour l'identification dynamique, j'ai besoin :
- de la position
- de la tension d'alimentation du moteur
- du ratio de la PWM (entre 0 et 1) envoié au mont en H.

Pour le contrôle, je préfèrerait contrôler non pas la PWP mais directement la tension envoyée au pont en H pour ne pas avoir à lire moi même la tension d'alimentation qui peut variée.

Pour le feed-forward, ça peut être en effet : envoyer un nombre fixe d'ensembles: (offset de temps, position, vitesse, accélération, torque) désirés dans le future.
Et oui, faire une linéarisation simple, ça peut tout à fait le faire. Par exemple, si tu connais vel(t0), acc(t0), vel(t1), acc(t1) tu peut localement fitter un polynome de degré 3 et l'évaluer en t0+delta.

Tu a besoin d'interpoler, la position, la vitesse. Et l'accélération ?
"

- Sanity check. Redo the weight test ? And the anti-gravity finger. And the writing arm :D


- Idée bootloader : copier en ram le bootloader à chaud, gaffe au référencement absolu des adresses (utiliser flag PIC?).
