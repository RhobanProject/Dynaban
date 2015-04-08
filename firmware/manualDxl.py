#!/usr/bin/python
# -*- coding: utf-8 -*-
import serial
import time

def open_serial(port, baud, timeout=0.1):
    ser = serial.Serial(port=port, baudrate=baud, timeout=timeout)
    if ser.isOpen():
        return ser
    else:
        print 'SERIAL ERROR'

def close(ser):
    ser.close()

def write_data(ser, data):
    ser.write(data)

def read_data(ser, size=1):
    return ser.read(size)

def to_hex(val):
    return chr(val)

def decode_data(data):
    res = ''
    for d in data :
        res += hex(ord(d)) + ' '
    return res

def check_sum(packet) :
    sum = 0
    for d in packet :
        sum = sum + ord(d)

    return (~(sum) & 0xff)


def write(serial, id, params) :
    data_start = to_hex(0xff)
    data_lenght = to_hex(2 + len(params))
    data_instruction = to_hex(0x03)

    packet = id + data_lenght + data_instruction
    for p in params :
        packet = packet + p

    data_checksum = to_hex(check_sum(packet))
    packet = data_start + data_start + packet + data_checksum
    print "Writing : " + decode_data(packet)
    write_data(serial, packet)


if __name__ == '__main__':
    # we open the port
    serial_port = open_serial('/dev/ttyACM0', 57600, timeout= 0.1)
    if True :
        # we create the packet for a LED ON command
        # two start bytes
        data_start = to_hex(0xff)
        # id of the motor (here 1), you need to change
        data_id = to_hex(1)
        # lenght of the packet
        data_lenght = to_hex(0x04)
        # instruction write= 0x03
        data_instruction = to_hex(0x03)
        # instruction parameters
        data_param1 = to_hex(0x4A) # LED address=0x19
        data_param2 = to_hex(0x07) # write 0x01

        data = data_id + data_lenght + data_instruction + data_param1 + data_param2
        # checksum (read the doc)
        data_checksum = to_hex(check_sum(data))
        # we concatenate everything
        data = data_start + data_start + data + data_checksum
        print decode_data(data)
        write_data(serial_port, data)
        while (True) :
            time.sleep(100)
        # read the status packet (size 6)
        # d = read_data(serial_port, 16)
        # print decode_data(d)
    else :
        params = [to_hex(0x19), to_hex(1)]
        while True :
            if (params[1] == to_hex(0)) :
                params[1] = to_hex(1)
            else :
                params[1] = to_hex(0)

            write(serial_port, to_hex(42), params)
            d = read_data(serial_port, 6)
            print "Read : " + decode_data(d)
            time.sleep(0.3)
