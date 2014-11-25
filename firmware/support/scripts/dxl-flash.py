#!/usr/bin/python

import serial, time, sys

# Writing data slowly
def slow_write(port, data, ts=0.02):
    for i in range(0, len(data)):
        port.write(data[i])
        time.sleep(ts)

# Progress bar util
def progressBar(percent, precision=65):
    threshold=precision*percent/100.0
    sys.stdout.write('[ ')
    for x in xrange(0, precision):
        if x < threshold: sys.stdout.write('#')
        else: sys.stdout.write(' ')
    sys.stdout.write(' ] ')
    sys.stdout.flush()

# Waiting for a string to appear
def wait_for_string(port, rcv, send=''):
    total = ''
    while True:
        if send != '':
            slow_write(port, send)
        time.sleep(0.02)
        b = ''
        while port.inWaiting():
            b += port.read(port.inWaiting())
        # print(b)
        total += b
        if total.find(rcv)>=0:
            return

arg = sys.argv
if len(arg) != 3:
    print('Usage: python dxl.py <ttyUSB> <firmware.bin>')
    exit()

x, device, binary = arg
port = serial.Serial(device, 57600)
data = open(binary).read()

print('* Trying to enter bootloader...')
wait_for_string(port, 'SYSTEM', "#")

print('* Entering firmware loading mode...')
time.sleep(0.1);
slow_write(port, "L\r")
wait_for_string(port, 'Ready')

print('* Sending firmware data')
n = len(data)
cs = 0
K = 0
for i in range(0, n):
    port.write(data[i])
    K -= 1
    if K <= 0:
        K = 256
        sys.stdout.write("\r")
        progressBar(i*100.0/n)
    cs += ord(data[i])
cs = cs&0xff
port.write(chr(cs))
print(' Checksum = %02x' % cs)

wait_for_string(port, 'Success')

print('* Success!')
print('* Running...')
wait_for_string(port, 'Go', "g\r")
