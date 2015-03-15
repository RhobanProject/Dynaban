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
}

void dxl_init_regs()
{
    struct dxl_eeprom *dxl_flash = (struct dxl_eeprom *)dxl_zone;

    if (dxl_flash->modelNumber == DXL_MODEL) {
        memcpy((void*)&dxl_regs.eeprom, (void*)dxl_flash, sizeof(struct dxl_eeprom));
    } else {
        dxl_regs.eeprom.modelNumber = DXL_MODEL;
        dxl_regs.eeprom.firmwareVersion = 36;
        dxl_regs.eeprom.id = 1;
        dxl_regs.eeprom.baudrate = 34;
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
    dxl_regs.ram.goalTorque = 0;
    dxl_regs.ram.goalAcceleration = 0;

    dxl_regs.eeprom_dirty = false;
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
    memcpy(((ui8 *)(&dxl_regs))+addr, values, length);

    if (addr < DXL_RAM_BEGIN) {
        dxl_regs.eeprom_dirty = true;
    }
}

static void dxl_read_data(ui8 addr, ui8 *values, ui8 length, ui8 *error)
{
    memcpy(values, ((ui8*)&dxl_regs)+addr, length);
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
