import random, math
import json
import pypot.robot
import time
import sys
import pypot.dynamixel
from contextlib import closing
import logging
import logging.config
import matplotlib.pyplot as plt


def main(dxl_io) :
    t0 = time.time()

    graphSize = 100
    setBack = 30
    plt.ion()
    #Set up plot
    figure, ax = plt.subplots(2)
    x = []
    y = []
    y2 = []
    lines,  = ax[0].plot(x, y, '--')
    lines2, = ax[1].plot(x, y, '--')
    #Autoscale on unknown axis and known lims on the other
    ax[0].set_autoscaley_on(True)
    ax[0].set_xlim(0, 30)
    ax[0].set_autoscalex_on(True)
    ax[1].set_autoscaley_on(True)
    ax[1].set_xlim(0, 30)
    ax[1].set_autoscalex_on(True)
    #Other stuff
    ax[0].grid()
    ax[1].grid()
    figure.canvas.draw()
    t = 0
    pwm = 0
    position = 0
    counter = -1
    plot_modulo = 1
    while True :
        counter = counter + 1
        d0 = time.time()
        id_counter = 0
        list_of_pos = []
        try :
            #goal_pos = int(50*math.sin(2*math.pi*0.5*(d0-t0)))
            #dxl_io.set_goal_position({1:goal_pos})
            position = dxl_io.get_present_position([1])
            pwm = dxl_io.get_present_PWM_voltage([1])
            #print pwm

        except Exception as e:
            print("Exception : ", e)
            print("Com error")
        time.sleep(0.001)
        t = time.time() - t0
        x.append(t)
        y2.append(pwm)
        y.append(position)
        if (len(x) > graphSize) :
            x = x[setBack:graphSize]
            y = y[setBack:graphSize]
            y2 = y2[setBack:graphSize]
        #Update data (with the new _and_ the old points)
        lines.set_xdata(x)
        lines.set_ydata(y)
        lines2.set_xdata(x)
        lines2.set_ydata(y2)
        if (counter%plot_modulo==0) :
            #Need both of these in order to rescale
            ax[0].relim()
            ax[0].autoscale_view()
            ax[1].relim()
            ax[1].autoscale_view()
            #We need to draw *and* flush
            figure.canvas.blit()
            #figure.canvas.flush_events()
        print("f = " + str(1.0/(time.time() - d0)))

def feedforward(dxl_io):
    print "Setting dt"
    # Please...
    dxl_io.set_dt({1:10000})
    dxl_io.set_dt({1:10000})
    dxl_io.set_dt({1:10000})
    dxl_io.set_dt({1:10000})
    print "Setting states"
    dxl_io.set_future_states({1:[20, 0, 0, 30, 0, 0, 40, 0, 0]})
    raw_input("Start cu")
    dxl_io.set_timestamp({1:0})
    time.sleep(0.1)
    print "Setting mode"
    dxl_io.set_mode_dynaban({1:3})
    print "Setting debug on"
    dxl_io.set_debug_mode_on({1:1})
    t0 = time.time()
    D0 = t0
    t = t0 + 1000
    while (time.time() - D0) < 3.3 :
        t = time.time() - t0
        if (t > 0.1) :
            #Fake call to get debug
            dxl_io.set_debug_mode_on({1:1})
            t0 = time.time()
        

if __name__ == '__main__' :
        ports = pypot.dynamixel.get_available_ports()
        if not ports:
            raise IOError('No port found!')
        print("Ports found", ports)
        print("Connecting on the first available port:", ports[0])
        dxl_io = pypot.dynamixel.DxlIO(ports[0], baudrate=1000000)
        dxl_io.enable_torque([1])
        #dxl_io.set_goal_position({1:10})
        #main(dxl_io)
        feedforward(dxl_io)
