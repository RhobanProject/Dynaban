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
#import matplotlib
#matplotlib.use('TKAgg')

CLOSED = False

def handle_close(event) :
    CLOSED = True
    raw_input("Hop")

def main(dxl_io) :
    t0 = time.time()

    graphSize = 100
    setBack = 30
    plt.ion()
    #Set up plot
    figure, ax = plt.subplots(3)
    x = []
    y = []
    y2 = []
    y3 = []
    lines,  = ax[0].plot(x, y, '--')
    lines2, = ax[1].plot(x, y2, '--')
    lines3, = ax[2].plot(x, y3, '--')
    ax[0].set_title("Position (deg)")
    ax[1].set_title("PWM (V)")
    ax[2].set_title("Alim (V)")
    #Autoscale on unknown axis and known lims on the other
    ax[0].set_autoscaley_on(True)
    ax[0].set_xlim(0, 30)
    ax[0].set_autoscalex_on(True)
    ax[1].set_autoscaley_on(True)
    ax[1].set_xlim(0, 30)
    ax[1].set_autoscalex_on(True)
    ax[2].set_autoscaley_on(True)
    ax[2].set_xlim(0, 30)
    ax[2].set_autoscalex_on(True)
    #Other stuff
    ax[0].grid()
    ax[1].grid()
    ax[2].grid()
    figure.canvas.draw()
    t = 0
    pwm = 0
    position = 0
    counter = -1
    plot_modulo = 1
    figure.canvas.mpl_connect('close_event', handle_close)
    
    while CLOSED == False :
        counter = counter + 1
        d0 = time.time()
        id_counter = 0
        list_of_pos = []
        try :
            #goal_pos = int(50*math.sin(2*math.pi*0.5*(d0-t0)))
            #dxl_io.set_goal_position({1:goal_pos})
            position = dxl_io.get_present_position([1])
            pwm = dxl_io.get_present_PWM_voltage([1])
            voltage = dxl_io.get_present_voltage([1])

        except Exception as e:
            print("Exception : ", e)
            print("Com error")
        time.sleep(0.001)
        t = time.time() - t0
        x.append(t)
        y.append(position)
        y2.append(pwm)
        y3.append(voltage)
        if (len(x) > graphSize) :
            x = x[setBack:graphSize]
            y = y[setBack:graphSize]
            y2 = y2[setBack:graphSize]
            y3 = y3[setBack:graphSize]
        #Update data (with the new _and_ the old points)
        lines.set_xdata(x)
        lines.set_ydata(y)
        lines2.set_xdata(x)
        lines2.set_ydata(y2)
        lines3.set_xdata(x)
        lines3.set_ydata(y3)
        if (counter%plot_modulo==0) :
            #Need both of these in order to rescale
            ax[0].relim()
            ax[0].autoscale_view()
            ax[1].relim()
            ax[1].autoscale_view()
            ax[2].relim()
            ax[2].autoscale_view()
            #We need to draw *and* flush (but flushing is extremely long, the freq becomes ~ 20Hz...)
            # maptlotlib is not made for online applications, not flushing solves the issue but we can't close the figure...
            figure.canvas.blit()
            #figure.canvas.flush_events()
        print("f = " + str(1.0/(time.time() - d0)))

if __name__ == '__main__' :
        ports = pypot.dynamixel.get_available_ports()
        if not ports:
            raise IOError('No port found!')
        print("Ports found", ports)
        print("Connecting on the first available port:", ports[0])
        dxl_io = pypot.dynamixel.DxlIO(ports[0], baudrate=1000000)
        dxl_io.enable_torque([1])
        dxl_io.set_goal_position({1:0})
        time.sleep(1)
        main(dxl_io)
