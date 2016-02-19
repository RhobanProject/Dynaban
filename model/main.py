# -*- coding: utf-8 -*-
#Author : Rémi Fabre

import matplotlib.pyplot as plt
import math
import sys
import time
import numpy
import csv

def sign(value):
    if value >= 0 :
        return 1
    else :
        return -1
    
class ModelTester(object):
    def __init__(self) :
        self.voltage = 12.0
        self.i0 = 0.00353 #(actual value 0.00353) in kg.m**2 is the measured moment of inertia when empty (only gear box attached). Can't value the measure too much though. (datasheet from maxon gives 2.17g.cm^2 which, with the 200 gear ratio is 4.35*10⁻5, which is 10 times less than the measured value !)
        self.ke = 0.75 #V*s/rad
        self.kt = self.ke #N.m/A
        self.r = 5.86 #ohm
        self.rawKlin = 1/2.38 #command*s/step . Command in [0, 3000]. If command = 1000 => speed = 1000*(1/klinMeasured) + offset in steps/s
        self.rawKlinOffset = -120 # step/s
        self.rawStaticFriction = 80 #In command units
        self.rawLinearTransition = 200 #in step/s. Above this speed, the relationship between voltage and speed (in static) is considered to be almost linear
        
        #Conversion helpers :
        self.rawPositionToRad = 2*math.pi/4096.0 #rad/command
        self.rawCommandToVoltage = self.voltage/3000.0 #V/command
        self.rawCommandToSiTorque = self.rawCommandToVoltage*self.kt/self.r #If speed is 0, then electricalTorque = command * rawCommandToSiTorque N.m. If command = 3000, electricalTorque = 5.6 N.m = stallTorque
        
        #Converted values :
        self.klin = self.rawKlin * self.rawCommandToVoltage / self.rawPositionToRad  #in V.s/rad
        self.klinOffset = self.rawKlinOffset * self.rawPositionToRad
        #In static (when you wait long enough) the relationship between the input voltage and the rotational speed is very linear once the slow speeds are behind.
        # i.e if abs(speed) > self.linearTransition then speed = costant + klin*voltage.
        self.kvis = (self.klin - self.ke)*self.kt/self.r #In V*s/rad. The formula is : klin = ke + r*kvis/kt => kvis = -ke + klin*kt/r
        self.linearTransition = self.rawLinearTransition * self.rawPositionToRad # In rad/s
        self.staticFriction = self.rawStaticFriction * self.rawCommandToSiTorque #In N.m
        self.coulombFriction = self.staticFriction / 4.56 #In N.m. pifometric value.
        


    def main(self):
        dt = 0.001
        T = numpy.arange(0, 0.2, dt)
        u = 0.3333*12
        position = [0]
        speed = [0]
        electricalTorque = []
        frictionTorque = []
        outputTorque = []
        acceleration = []
        print "rawPositionToRad = ", self.rawPositionToRad
        print "rawCommandToVoltage = ", self.rawCommandToVoltage
        print "rawCommandToSiTorque = ", self.rawCommandToSiTorque

        print "ke = ", self.ke
        print "kvis = ", self.kvis
        print "klin = ", self.klin
        
        for i in range(len(T)) :
            #Getting the electrical torque
            electricalTorque.append(self.computeElectricalTorque(u, speed[i]))
            #Getting the friction torque
            frictionTorque.append(self.computeFrictionTorque(speed[i], 1))
            #Actual output torque
            outputTorque.append(electricalTorque[i] - frictionTorque[i])
            
            acceleration.append(outputTorque[i]/self.i0)
            speed.append(speed[i] + dt*acceleration[i])
            position.append(position[i] + speed[i]*dt)
           
        plt.subplot(221)
        plt.plot(T, position[:-1], "*")
        plt.legend(['Position']) 
        plt.subplot(222)
        plt.plot(T, speed[:-1], "*")
        plt.legend(['Speed'])
        plt.subplot(223)
        plt.plot(T, acceleration, "*")
        plt.legend(['acceleration'])
        plt.subplot(224)
        plt.plot(T, electricalTorque, "+", 
                 T, frictionTorque, "x", 
                 T, outputTorque, "--")
        plt.legend(['electricalTorque', 'frictionTorque', 'outputTorque'])

        plt.grid(True)
        plt.show()
    
    # Computes the torque in N.m that the motor would output if there was no friction
    # u is the command voltage in V. speed is the current speed in rad/s
    def computeElectricalTorque(self, u, speed):
        return (u - self.ke*speed)*self.kt/self.r
    
    # Computes the torque in N.m created by friction.
    # speed is the current speed in rad/s. signOfStaticFriction is always equal to sign(speed) unless speed is 0. 
    # Then signOfStaticFriction should be equal to the sign of the output torque applied to the motor.
    def computeFrictionTorque(self, speed, signOfStaticFriction):
        viscousFriction = self.kvis * speed
        if (speed != 0) :
            signOfStaticFriction = sign(speed)
        
        beta = math.exp(-abs(speed/self.linearTransition))
        friction = viscousFriction + signOfStaticFriction * (beta * self.staticFriction + (1 - beta) * self.coulombFriction)
        return friction

    def readMeasures(self, fileName) :
        with open(fileName, 'rb') as csvfile :
            spamreader = csv.DictReader(csvfile, delimiter=' ')
            for row in spamreader:
                print row["Time"], ", ", row["Command"], ", ", row["Position"]
                to do : differentiate different tests in order to assign diferent weight to them. Create a class measures for it
                then use cma-es with function sumOfErrors (sum of squared errors actually)

                
print("A new day dawns")
modelTest = ModelTester()
#modelTest.main()
modelTest.readMeasures("measures/test1")
print("Done !")
