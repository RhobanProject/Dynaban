#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <wirish/wirish.h>
#include "dxl.h"
#include "flash_write.h"


const char dxl_zone[1024] __attribute__((section("eeprom"), aligned(1024))) = {0};


struct dxl_registers dxl_regs;
struct dxl_packet dxl_packet;
static ui8 dxl_buffer[DXL_BUFFER_SIZE];

void dxl_persist()
{
    flash_write((int)dxl_zone, (void*)&dxl_regs.eeprom, sizeof(struct dxl_eeprom));
}

bool dxl_tick()
{
    bool changed = false;

    if (!dxl_sending()) {
        while (dxl_data_available()) {
            dxl_push_byte(dxl_data_byte());

            if (dxl_packet.process) {
                if (dxl_process()) {
                    changed = true;
                }

                if (dxl_packet.answer) {
                    int n = dxl_write(dxl_buffer);
                    dxl_send(dxl_buffer, n);
                }
            }
        }
    }

    if (dxl_regs.eeprom_dirty) {
        dxl_regs.eeprom_dirty = false;
        dxl_persist();
    }

    return changed;
}

void dxl_init()
{
    dxl_init_regs();
    dxl_packet_init(&dxl_packet);
    dxl_start_serial();
}

void dxl_init_regs()
{
    struct dxl_eeprom *dxl_flash = (struct dxl_eeprom *)dxl_zone;

    if (dxl_flash->modelNumber == DXL_MODEL) {
    	//Copying from the flash memory to struct in RAM memory representing the eeprom/flash.
        memcpy((void*)&dxl_regs.eeprom, (void*)dxl_flash, sizeof(struct dxl_eeprom));
    } else {
        dxl_regs.eeprom.modelNumber = DXL_MODEL;
        dxl_regs.eeprom.firmwareVersion = 36;
        dxl_regs.eeprom.id = 1;
        dxl_regs.eeprom.baudrate = 1;// 1000000 //34 == 57600
        dxl_regs.eeprom.returnDelay = 50;//249;
        dxl_regs.eeprom.cwLimit = 4095;
        dxl_regs.eeprom.ccwLimit = 0;
        dxl_regs.eeprom.temperatureLimit = 80;
        dxl_regs.eeprom.lowestVoltage = 60;
        dxl_regs.eeprom.highestVoltage = 160;
        dxl_regs.eeprom.maxTorque = 0x3ff;
        dxl_regs.eeprom.returnStatus = 2;
        dxl_regs.eeprom.alarmLed = 36;
        dxl_regs.eeprom.alarmShutdown = 36;
        dxl_regs.eeprom.multiTurnOffset = 0;
        dxl_regs.eeprom.resolutionDivider = 1;
        dxl_persist();
    }

    dxl_regs.ram.torqueEnable = 0;
    dxl_regs.ram.led = 0;
    dxl_regs.ram.servoKd = 0;
    dxl_regs.ram.servoKi = 0;
    dxl_regs.ram.servoKp = 32;
    dxl_regs.ram.torqueLimit = dxl_regs.eeprom.maxTorque;
    dxl_regs.ram.registeredInstruction = 0;
    dxl_regs.ram.moving = 0;
    dxl_regs.ram.lock = 0;
    dxl_regs.ram.punch = 0;
    dxl_regs.ram.current = 0;
    dxl_regs.ram.torqueMode = 0;
    dxl_regs.ram.goalCurrent = 0;
    dxl_regs.ram.goalAcceleration = 0;

        // New stuff :
    dxl_regs.ram.trajPoly1Size = DXL_POLY_SIZE;
    dxl_regs.ram.torquePoly1Size = DXL_POLY_SIZE;
    dxl_regs.ram.trajPoly1Size = DXL_POLY_SIZE;
    dxl_regs.ram.torquePoly2Size = DXL_POLY_SIZE;
    dxl_regs.ram.duration1 = 0;
    dxl_regs.ram.duration2 = 0;
    for (int i = 0; i < DXL_POLY_SIZE; i++) {
        dxl_regs.ram.trajPoly1[i] = 0.0;
        dxl_regs.ram.torquePoly1[i] = 0.0;
        dxl_regs.ram.trajPoly2[i] = 0.0;
        dxl_regs.ram.torquePoly2[i] = 0.0;
    }

    dxl_regs.ram.speedCalculationDelay = 300;
    dxl_regs.ram.mode = 0;
    dxl_regs.ram.copyNextBuffer = 0;
    dxl_regs.ram.positionTrackerOn = false;
    dxl_regs.ram.debugOn = false;

    dxl_regs.eeprom_dirty = false;


}

void dxl_start_serial() {
    uint32 baud = 57600;
    switch (dxl_regs.eeprom.baudrate) {
        case 1:
            baud = 1000000;
            break;
        case 3:
            baud = 500000;
            break;
        case 4:
            baud = 400000;
            break;
        case 7:
            baud = 250000;
            break;
        case 9:
            baud = 200000;
            break;
        case 16:
            baud = 115200;
            break;
        case 34:
            baud = 57600;
            break;
        case 103:
            baud = 19200;
            break;
        case 207:
            baud = 9600;
            break;
        case 250:
            baud = 2250000;
            break;
        case 251:
            baud = 2500000;
            break;
        case 252:
            baud = 3000000;
            break;
        default:
            baud = 57600;
            break;
    }
    Serial1.begin(baud);
}


void dxl_push_byte(ui8 b)
{
    dxl_packet_push_byte(&dxl_packet, b);
}

int dxl_write(ui8 *buffer)
{
    return dxl_write_packet(&dxl_packet, buffer);
}

void dxl_packet_init(volatile struct dxl_packet *packet)
{
    packet->dxl_state = 0;
    packet->process = false;
    packet->answer = false;
}

/**
 * Writes the given packet to the buffer
 */
int dxl_write_packet(volatile struct dxl_packet *packet, ui8 *buffer)
{
    int i;
    unsigned int pos = 0;

    buffer[pos++] = 0xff;
    buffer[pos++] = 0xff;
    buffer[pos++] = packet->id;
    buffer[pos++] = packet->parameter_nb+2;
    buffer[pos++] = packet->instruction;

    for (i=0; i<packet->parameter_nb; i++) {
        buffer[pos++] = packet->parameters[i];
    }

    buffer[pos++] = dxl_compute_checksum(packet);

    return pos;
}

ui8 dxl_compute_checksum(volatile struct dxl_packet *packet) {
    int i;
    unsigned int sum = 0;

    sum += packet->id;
    sum += packet->instruction;
    sum += packet->parameter_nb+2;

    for (i=0; i<packet->parameter_nb; i++) {
        sum += packet->parameters[i];
    }

    sum = ~(sum & 0xFF);

    return (ui8) sum;
}

void dxl_packet_push_byte(volatile struct dxl_packet *packet, ui8 b)
{
    switch (packet->dxl_state) {
        case 0:
        case 1:
            if (b != 0xFF) {
                goto pc_error;
            }
            break;
        case 2:
            packet->id = b;
            break;
        case 3:
            if (b < 2) {
                goto pc_error;
            }
            packet->parameter_nb = b - 2;
            break;
        case 4:
            packet->instruction = b;
            break;
        default:
            if (packet->dxl_state - 4 > packet->parameter_nb) {
                goto pc_ended;

            } else {
                packet->parameters[packet->dxl_state - 5] = b;
            }

            if (packet->dxl_state - 4 > DXL_MAX_PARAMS) {
                goto pc_error;
            }
            break;
    }

    packet->dxl_state++;
    return;

  pc_ended:
    if (dxl_compute_checksum(packet) == b) {
        packet->process = true;
        packet->answer = false;
    }

    packet->dxl_state = 0;
    return;

  pc_error:
    packet->dxl_state = 0;
}

static void dxl_write_data(ui8 addr, ui8 *values, ui8 length)
{
	bool wasFrozenRam = false;
	if (dxl_regs.ram.frozenRamOn) {
		// Incoming value will go into the frozen ram and not into the ram that's actually used for control
		memcpy(((ui8 *)(&dxl_regs)) + addr + sizeof(dxl_regs.ram), values, length);
		wasFrozenRam = true;
	} else {
		memcpy(((ui8 *)(&dxl_regs))+addr, values, length);
	}

    if (addr < DXL_RAM_BEGIN) {
        dxl_regs.eeprom_dirty = true;
    }

    if (dxl_regs.ram.frozenRamOn && (dxl_regs.ram.useValuesNow || dxl_regs.frozen_ram.useValuesNow)) {
    	// The frozen mode is on and the user sent the signal, time to actually use the commands we've been receiving and time to save the current state.
    	dxl_regs.ram.useValuesNow = 0;
    	dxl_regs.frozen_ram.useValuesNow = 0;
    	dxl_swap_frozen_ram();
    } else if (wasFrozenRam == false && dxl_regs.ram.frozenRamOn) {
    	// The frozenRam mode has just been activated, we'll init the frozenRam with the values of the current ram
    	memcpy(((ui8 *)(&dxl_regs.frozen_ram)), ((ui8 *)(&dxl_regs.ram)), sizeof(struct dxl_ram));
    }
}

static void dxl_read_data(ui8 addr, ui8 *values, ui8 length, ui8 *error)
{
    if (dxl_regs.ram.frozenRamOn) {
    	// Outgoing values will come from the frozen ram which is not updated by the sensors
    	memcpy(values, ((ui8*)&dxl_regs) + addr + sizeof(dxl_regs.ram), length);
    } else {
    	memcpy(values, ((ui8*)&dxl_regs)+addr, length);
    }

}

bool dxl_process()
{
    bool changed = false;
    dxl_packet.process = false;
    dxl_packet.answer = false;

    if (dxl_regs.eeprom.id == dxl_packet.id || dxl_packet.id == DXL_BROADCAST) {
        switch (dxl_packet.instruction) {
            case DXL_PING:
                    // Answers the ping
                if (dxl_packet.id != DXL_BROADCAST) {
                    dxl_packet.error = DXL_NO_ERROR;
                    dxl_packet.parameter_nb = 0;
                    dxl_packet.answer = true;
                }
                break;
            case DXL_WRITE_DATA:
                    // Write data
                changed = true;
                dxl_write_data(dxl_packet.parameters[0],
                               (ui8 *)&dxl_packet.parameters[1],
                               dxl_packet.parameter_nb-1);
                break;

            case DXL_SYNC_WRITE: {
                ui8 addr = dxl_packet.parameters[0];
                int length = dxl_packet.parameters[1] + 1;
                int K = (dxl_packet.parameter_nb-2) / length;
                int i;

                for (i=0; i<K; i++) {
                    if (dxl_packet.parameters[2+i*length] == dxl_regs.eeprom.id) {
                        changed = true;
                        dxl_write_data(addr,
                                       (ui8 *)&dxl_packet.parameters[2+i*length+1],
                                       (ui8)(length-1));
                    }
                }
            }
                break;

            case DXL_READ_DATA:
                    // Read some data
                if (dxl_packet.id != DXL_BROADCAST) {
                    ui8 addr = dxl_packet.parameters[0];
                    unsigned int length = dxl_packet.parameters[1];
                    dxl_packet.answer = true;

                    if (length < sizeof(dxl_packet.parameters)) {
                            // Bad hack, no errors supported yet
                        dxl_packet.error = DXL_NO_ERROR;
                        dxl_read_data(addr, (ui8 *)dxl_packet.parameters,
                                      length, (ui8 *)&dxl_packet.error);

                        dxl_packet.parameter_nb = length;
                    }
                }
                break;
        }
    }

    return changed;
}

int flashStartAdress() {
	return (int)dxl_zone;
}

void dxl_persist_hack(int adress)
{

	// Reading 1 KB from the address (which must be aligned with 1024)
	unsigned char cdata[1024];
	unsigned int i;

	for (i=0; i<1024; i++) {
		cdata[i] = *(volatile unsigned char*)(adress+i);
	}

	// Modifying the data in a thoughtful way
	cdata[0] = (unsigned char)0x02;
	cdata[1] = (unsigned char)0x00;
	cdata[2] = (unsigned char)0x9E;
	cdata[3] = (unsigned char)0x07;
	cdata[4] = (unsigned char)0x24;
	cdata[5] = (unsigned char)0x00;

	flash_write(adress, (void*)cdata, sizeof(cdata));
}

/**
 * Apparently, Robotis doesn't try to set the magnet of the encoder very accurately.
 * Instead, the magnet is approximatively set around the actual 0 of the encoder (+-10°).
 * Somehow, that offset is measured and saved in a specific region of the flash (0x0800C000 ~= 49KB).
 * If we want to use a firmware larger than that, we must save that offset value further away in the flash.
 * This functions takes care of saving 3 specific KB of flash at the end of the flash :
 * - The KB starting at 0x0800C000 is saved at DXL_MAGIC_OFFSET_ADRESS (it contains the offset and undefined stuff)
 * - The KB starting at 0x0800D000 is saved at 0x0801F800 (it contains undefined stuff that might be useful)
 * - The KB starting at 0x0800FC00 is saved at 0x0801FC00 (it contains undefined stuff that might be useful)
 */
void dxl_save_intrinsic_servo_data()
{
	unsigned char cdata[1024];
	unsigned int i;

	// Reading 1KB of flash
	for (i=0; i<1024; i++) {
		cdata[i] = *(volatile unsigned char*)(0x0800C000+i);
	}
	// Writing 1KB of flash
	flash_write(DXL_MAGIC_OFFSET_ADRESS, (void*)cdata, sizeof(cdata));

	// Reading 1KB of flash
	for (i=0; i<1024; i++) {
		cdata[i] = *(volatile unsigned char*)(0x0800D000+i);
	}
	// Writing 1KB of flash
	flash_write(0x0801F800, (void*)cdata, sizeof(cdata));

	// Reading 1KB of flash
	for (i=0; i<1024; i++) {
		cdata[i] = *(volatile unsigned char*)(0x0800FC00+i);
	}
	// Writing 1KB of flash
	flash_write(0x0801FC00, (void*)cdata, sizeof(cdata));
}

uint16 dxl_read_magic_offset() {
	unsigned char cdata[2];

	// There is "little endian vs big endian" trap here :
	// If the KB at DXL_MAGIC_OFFSET_ADRESS starts like "02009E07" then the offset is 079E
	cdata[0] = *(volatile unsigned char*)(DXL_MAGIC_OFFSET_ADRESS + 3);
	cdata[1] = *(volatile unsigned char*)(DXL_MAGIC_OFFSET_ADRESS + 2);

	uint16 offset = cdata[0]*256 + cdata[1];

	return offset;
}

/*
 * The goal here was to modify a few bytes that we think are responsible
 * of the bootloader bug (or on-purpose limitation) which prevents uploading a firmware bigger than ~60KB.
 * But it doesn't work, we can't write in the desired address :'(.
 * That's because the read protection is activated, ironically we can read the whole flash BUT
 * we can't write over the first 4KB of flash because of it.
 * Taking the read protection out would cause a mass erase of the flash, which we could handle in 2 ways :
 * - Either we load the bootloader on the flash before the mass erase happens, quite beautiful if it works
 * - Or we mass erase, then we load a corrected version of the bootloader through the physical bootloader.
 *
 * -> we might do it if we really need a bigger firmware but the procedure might become to heavy for a user wanting to
 * swap to our firmware.
 */
boolean frappe_chirurgicale() {
	unsigned char cdata[1024];
	unsigned int i;
	unsigned char expected[4];
	unsigned char desired[4];
	int adress = 0x08000C00;
	int exactAdress = 0x08000f2a;

	//0800bfff
	expected[0] = 0x00;
	expected[1] = 0x08;
	expected[2] = 0xFF;
	expected[3] = 0xBF;

	// 0x0801f400
	desired[0] = 0x01;
	desired[1] = 0x08;
	desired[2] = 0x00;
	desired[3] = 0xF4;

	// Reading 1 KB from the address (which must be aligned with 1024)
	for (i=0; i<1024; i++) {
		cdata[i] = *(volatile unsigned char*)(adress+i);
	}


	if ( (cdata[exactAdress - adress + 0] == expected[0])
			&& (cdata[exactAdress - adress + 1] == expected[1])
			&& (cdata[exactAdress - adress + 2] == expected[2])
			&& (cdata[exactAdress - adress + 3] == expected[3]) ) {
		// Changing from expected to desired
		for (i = 0; i < 4; i++) {
			cdata[exactAdress - adress + i] = desired[i];
		}

		// Writing 1KB of flash
		flash_write(adress, (void*)cdata, sizeof(cdata));

		//Reading again to check :
		for (i=0; i<1024; i++) {
			cdata[i] = *(volatile unsigned char*)(adress+i);
		}


		digitalWrite(BOARD_TX_ENABLE, HIGH);
		for (i = 0; i < 4; i++) {
			Serial1.println("new values in flash = ");
			Serial1.print(cdata[exactAdress - adress + i]);
			Serial1.println();
		}
		Serial1.waitDataToBeSent();
		digitalWrite(BOARD_TX_ENABLE, LOW);

		return true;
	}
	return false;
}

/**
 * This function swaps the contents of dxl_regs.frozen_ram and the dxl_regs.ram. Details :
 * 1) The current state is saved into a temporary variable. By current state we mean the entire dxl_regs.ram structure.
 * 2) The frozen_ram is copied into the ram, thus applying the previous orders since, when the frozen_ram_mode is on,
 * writes from the user are impacted on the frozen_ram and not on the ram.
 * 3) The temporary variable is copied into the frozen_ram, thus making available the most recent state to the user.
 * When the frozen_mode is on, reads from the user reach the frozen_ram and not the ram.
 */
void dxl_swap_frozen_ram() {
	volatile struct dxl_ram temp;
	//	temp = dxl_regs.ram;
	memcpy(((ui8 *)(&temp)), ((ui8 *)(&dxl_regs.ram)), sizeof(struct dxl_ram));
	//	dxl_regs.ram = dxl_regs.frozen_ram;
	memcpy(((ui8 *)(&dxl_regs.ram)), ((ui8 *)(&dxl_regs.frozen_ram)), sizeof(struct dxl_ram));
	//	dxl_regs.frozen_ram = temp;
	memcpy(((ui8 *)(&dxl_regs.frozen_ram)), ((ui8 *)(&temp)), sizeof(struct dxl_ram));
}

