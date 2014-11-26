#ifndef DXL_H
#define DXL_H

// Protocol definition
#define DXL_BROADCAST   0xFE

// Size limit for a buffer containing a dynamixel packet
#define DXL_BUFFER_SIZE 300

// Maximum parameters in a packet
#define DXL_MAX_PARAMS 140

typedef unsigned char ui8;

/**
 * A dynamixel packet
 */
struct dxl_packet {
    ui8 id; 
    union {
        ui8 instruction;
        ui8 error;
    };  
    ui8 parameter_nb;
    ui8 parameters[DXL_MAX_PARAMS];
    bool process;
    ui8 dxl_state;
};

void dxl_packet_init(volatile struct dxl_packet *packet);
void dxl_packet_push_byte(volatile struct dxl_packet *packet, ui8 b);
int dxl_write_packet(volatile struct dxl_packet *packet, ui8 *buffer);
ui8 dxl_compute_checksum(volatile struct dxl_packet *packet);

struct dxl_registers
{
    volatile struct dxl_eeprom {
        unsigned short  modelNumber;
        unsigned char firmwareVersion;
        unsigned char id;
        unsigned char baudrate;
        unsigned char returnDelay;
        unsigned short cwLimit;
        unsigned short ccwLimit;
        unsigned char _dummy;
        unsigned char temperatureLimit;
        unsigned char lowestVoltage;
        unsigned char highestVoltage;
        unsigned short maxTorque;
        unsigned char returnStatus;
        unsigned char alarmLed;
        unsigned char alarmShutdown;
    } eeprom __attribute((packed));

    volatile unsigned char _dummy2[4]; 

    volatile struct dxl_ram {
        unsigned char torqueEnable;
        unsigned char led;
        unsigned char cwComplianceMargin;
        unsigned char ccwComplianceMargin;
        unsigned char cwComplianceSlope;
        unsigned char ccwComplianceSlope;
        unsigned short goalPosition;
        unsigned short movingSpeed;
        unsigned short torqueLimit;
        unsigned short presentPosition;
        unsigned short presentSpeed;
        unsigned short presentLoad;
        unsigned char presentVoltage;
        unsigned char presentTemperature;
        unsigned char registeredInstruction;
        unsigned char _dummy3;
        unsigned char moving;
        unsigned char lock;
        unsigned short punch;
    } ram __attribute__((packed));

    volatile char eeprom_dirty;
} __attribute__((packed));

extern struct dxl_registers dxl_regs;
extern struct dxl_packet    dxl_rxpacket;

#endif // DXL_H
