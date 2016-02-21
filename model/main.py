# -*- coding: utf-8 -*-
#Author : Rémi Fabre

import matplotlib.pyplot as plt
import math
import sys
import time
import numpy
import csv
import measure
import itertools
from measure import Measure

def sign(x) :
    if (x > 0) :
        return 1
    if (x < 0) :
        return -1
    return 1

def isNumber(value):
    try:
        float(value)
        return True
    except:
        return False
    
class  ModelTester(object):
    def __init__(self) :
        self.voltage = 12.0
        self.i0 = 0.00353 #(actual value 0.00353) in kg.m**2 is the measured moment of inertia when empty (only gear box attached). Can't value the measure too much though. (datasheet from maxon gives 2.17g.cm^2 which, with the 200 gear ratio is 4.35*10⁻5, which is 10 times less than the measured value !)
        self.ke = 2.75 #V*s/rad
        self.kt = self.ke #N.m/A
        self.r = 5.86 #ohm
        self.rawKlin = -1/1.626 #command*s/step . Command in [0, 3000]. If command = 1000 => speed = 1000*(1/klinMeasured) + offset in steps/s
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
        #In static (when you wait long enough) the relationship between the input voltage and the rotational speed is very linear once the speed is high enough.
        # i.e if abs(speed) > self.linearTransition then speed = costant + klin*voltage.
        self.kvis = (self.klin + self.ke)*self.kt/self.r #In V*s/rad. The formula is : klin = -ke + r*kvis/kt => kvis = (ke + klin)*kt/r
        self.linearTransition = self.rawLinearTransition * self.rawPositionToRad # In rad/s
        self.staticFriction = self.rawStaticFriction * self.rawCommandToSiTorque #In N.m
        self.coulombFriction = self.staticFriction/2.0 #In N.m. pifometric value. When speed == linearTransition, abs(totalFriction) = coulombFriction
        #We want that when speed == linearTransition, total friction = -coulombFriction
        self.coulombContribution = (1/(1 - math.exp(-1)))*(self.kvis * self.linearTransition - math.exp(-1)*self.staticFriction + self.coulombFriction)
        
    def updateModelConstants(self, voltage, i0, ke, r, klin, linearTransition, staticFriction, coulombFriction):
        self.voltage = voltage
        self.io = i0
        self.ke = ke
        self.kt = self.ke
        self.r = r
        self.klin = klin
        self.linearTransition = linearTransition
        self.staticFriction = staticFriction
        self.coulombFriction = coulombFriction
        print "klin = ", klin
        #Pure update
        self.kvis = (self.klin + self.ke)*self.kt/self.r #In V*s/rad. The formula is : klin = -ke + r*kvis/kt => kvis = (ke + klin)*kt/r
        self.coulombContribution = (1/(1 - math.exp(-1)))*(self.kvis * self.linearTransition - math.exp(-1)*self.staticFriction + self.coulombFriction)

        print "ke = ", self.ke
        print "kvis = ", self.kvis
        print "coulombContribution = ", self.coulombContribution

        #Conversion helpers :
        self.rawCommandToVoltage = self.voltage/3000.0 #V/command
        self.rawCommandToSiTorque = self.rawCommandToVoltage*self.kt/self.r #If speed is 0, then electricalTorque = command * rawCommandToSiTorque N.m. If command = 3000, electricalTorque = 5.6 N.m = stallTorque


    def simulationTest(self):
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
        plt.grid(True)
        plt.subplot(222)
        plt.plot(T, speed[:-1], "*")
        plt.legend(['Speed'])
        plt.grid(True)
        plt.subplot(223)
        plt.plot(T, acceleration, "*")
        plt.legend(['acceleration'])
        plt.grid(True)
        plt.subplot(224)
        plt.plot(T, electricalTorque, "+", 
                 T, frictionTorque, "x", 
                 T, outputTorque, "--")
        plt.legend(['electricalTorque', 'frictionTorque', 'outputTorque'])
        plt.grid(True)
        
        plt.show()
    

    #Takes an initial speed, and a list of [time, command]. Outputs [T, position, speed, acceleration, outputTorque, electricalTorque, frictionTorque]
    #where T, position, speed, etc are each an array whom size is the same than timedCommands
    def simulation(self, timedCommands, initialPosition,initialSpeed, printIt=False):
        position = [initialPosition]
        speed = [initialSpeed]
        electricalTorque = []
        frictionTorque = []
        outputTorque = []
        acceleration = []
        #Getting a list with all the time values
        T, commands = zip(*timedCommands)
        
        oldT = T[0]
        for i, [t, command] in enumerate(timedCommands) :
            dt = t - oldT
            #Getting the electrical torque
            eTorque = self.computeElectricalTorque(command, speed[i])
            electricalTorque.append(eTorque)
            #Getting the friction torque
            fTorque = self.computeFrictionTorque(speed[i], 1)
            frictionTorque.append(fTorque)
            #Actual output torque
            outputTorque.append(eTorque + fTorque)
            
            acceleration.append(outputTorque[i]/self.i0)
            speed.append(speed[i] + dt*acceleration[i])
            position.append(position[i] + speed[i]*dt)
            oldT = t
           
        position = position[:-1]
        speed = speed[:-1]
        if (printIt) :
            plt.subplot(231)
            plt.plot(T, position, "-")
            plt.legend(['Position (rad)']) 
            plt.grid(True)
            plt.subplot(232)
            plt.plot(T, speed, "--")
            plt.legend(['Speed (rad/s)'])
            plt.grid(True)
            plt.subplot(233)
            plt.plot(T, acceleration, "--")
            plt.legend(['acceleration (rad/s^2)'])
            plt.grid(True)
            plt.subplot(234)
            plt.plot(T, electricalTorque, "--", 
                     T, frictionTorque, "--", 
                     T, outputTorque, "--")
            plt.legend(['electricalTorque (N.m)', 'frictionTorque (N.m)', 'outputTorque (N.m)'])
            plt.grid(True)
            plt.subplot(235)
            plt.plot(T, commands, "-")
            plt.legend(['Command (V)'])
            plt.grid(True)
    
            plt.grid(True)
            plt.show()
        
        return [T, position, speed, acceleration, outputTorque, electricalTorque, frictionTorque]
    
        
    
    # Computes the torque in N.m that the motor would output if there was no friction
    # u is the command voltage in V. speed is the current speed in rad/s
    def computeElectricalTorque(self, u, speed):
        torque = (u - self.ke*speed)*self.kt/self.r
#         print "u = ", u, ", speed = ", speed, ", eTorque = ", torque
        return torque
    
    # Computes the torque in N.m created by friction.
    # speed is the current speed in rad/s. signOfStaticFriction is always equal to sign(speed) unless speed is 0. 
    # Then signOfStaticFriction should be equal to the sign of the sum of all the torques applied on the rotor.
    #Thoughts about the static friction management :
    #The current model as an obvious problem related to the static friction. Let's say the speed of the motor is very low, 
    #and the electrical torque (ie created by the motor) is 0. This function would output a non zero torque because of the static friction.
    #When adding the friction torque and the elec torque, we have a non zero torque creating a non zero acceleration, which is absurd. 
    #If you push a heavy furniture, it won't push you back stronger than what you pushed it.
    #Actually, the static torque should be min(staticFriction, abs(outputTorque)) when the speed is 0. But I don't like this "when 0" discontinuity in the model.
    #Then chosen friction model handles this issue with the coulomb friction transition. The sharpest the transition, the closest we get to that "when 0" discontinuity.
    def computeFrictionTorque(self, speed, signOfStaticFriction):
        viscousFriction = self.kvis * speed
        if (speed != 0) :
            signOfStaticFriction = sign(speed)
#         print "speed = ", speed
#         print "viscoutFriction = ", viscousFriction
        
        beta = math.exp(-abs(speed/self.linearTransition))
        friction = viscousFriction - signOfStaticFriction * (beta * self.staticFriction + (1 - beta) * self.coulombContribution)
#         print "staticFriction = ", - signOfStaticFriction * (beta * self.staticFriction + (1 - beta) * self.coulombContribution)
        
        return friction
    
    #Each measured point is compared to each simulated point. The delta between the 2 is squared and summed for every point.
    #This function returns that sum, the lesser that value is, the better the simulation fits the measure
    def compareSimulationAndMeasure(self, simulationResults, measure, printIt=False) :
        sumOfSquaredErrors = 0
        
        [simuT, simuPosition, simuSpeed, simuAcceleration, simuOutputTorque, simuElectricalTorque, simuFrictionTorque] = simulationResults
        measureT, measureCommand, measurePosition, measureSpeed = zip(*measure.values)
        deltaArray = []
        
        for i, t in enumerate(measureT) :
            if (simuT[i] != t) :
                print "Times don't match !"
                raise RuntimeError("Times don't match !")
            delta = simuPosition[i] - measurePosition[i]
            deltaArray.append(delta)
            sumOfSquaredErrors = sumOfSquaredErrors + pow(delta, 2)
#             print "i = ", i, ", t = ", t, ", delta = ", delta

            
        if (printIt) :
            plt.subplot(221)
            plt.plot(simuT, simuPosition, "--",
                     simuT, measurePosition, "-.")
            plt.legend(['simuPosition', 'measurePosition']) 
            
            plt.subplot(223)
            plt.plot(simuT, deltaArray, "--")
            plt.legend(['DeltaPosition'])
            
            plt.subplot(222)
            plt.plot(simuT, simuSpeed, "--",
            simuT, measureSpeed, "-.")
            plt.legend(['simuSpeed', 'measureSpeed']) 

            plt.grid(True)
            plt.show()
            
        print "sumOfErrors = ", sumOfSquaredErrors
        return sumOfSquaredErrors


    def readMeasures(self, fileName) :
        with open(fileName, 'rb') as csvfile :
            reader = csv.reader(csvfile, delimiter=' ')
            typeOfTest = 0
            measure = None
            listOfMeasures = []
            nbRows = 0;
            for row in reader:
                if (len(row) < 2) :
                    continue
                if (row[0].startswith("StartOfNewTest") ) :
                    #Getting the type of test
                    typeOfTest = int(row[1].strip())
                    print "New test"
                elif (row[0].strip() == "Time") :
                    #New measure adding the previous one and creating a new one
                    if (measure != None) :
                        listOfMeasures.append(measure)
                        
                    measure = Measure(typeOfTest)
                elif (isNumber(row[0].strip())) :
                    #Adding a row of measures : [time, command, position, speed]
                    measure.addValues([float(row[0])/10000.0, float(row[1])*self.rawCommandToVoltage, 
                                       float(row[2])*self.rawPositionToRad, float(row[3])*self.rawPositionToRad])
                    nbRows = nbRows + 1
                else :
                    print "Weird line : ", row
            print "Added ", nbRows, " rows and ", len(listOfMeasures), " measures"
            return listOfMeasures

    #The angle goes from 0 to 2*PI, so when the motor goes over the limit a gap appears in the measures.
    #This functions fixes thats, the outputed angles will have to limit though. A gap is detected if the local speed > maxSpeed (units in rad/s)
    def fixGaps(self, listOfMeasures, maxSpeed):
        nbGaps = 0
        for measure in listOfMeasures :
            oldT = measure.values[0][0]
            oldPos = measure.values[0][1]
            offset = 0
            for i, row in enumerate(measure.values) :
                t = row[0]
                pos = row[2]
                if (t == oldT) :
                    speed = 0
                else :
                    speed = (pos - oldPos) / (t - oldT)
                oldT = t
                oldPos = pos
                
                if (abs(speed) > maxSpeed) :
                    #Gap detected
                    nbGaps = nbGaps + 1
                    tail = pos%(2*math.pi)
                    if (tail < math.pi) :
                        #Went from near 2PI to near 0, adding 2PI to offset
                        offset = offset + 2*math.pi
                    else :
                        #Went from near 0 to near 2PI, substracting 2PI to offset
                        offset = offset - 2*math.pi
                #Adding offset to the position
                measure.values[i][2] = measure.values[i][2] + offset
        print "Fixed ", nbGaps, " gaps."
            
    def evaluateModelForMeasures(self, listOfMeasures, voltage, i0, ke, r, klin, linearTransition, staticFriction, coulombFriction):
        #Max speed is 4PI/s = 120 rpm
        self.fixGaps(listOfMeasures, 4*math.pi)
        #Updating the model
        self.updateModelConstants(voltage, i0, ke, r, klin, linearTransition, staticFriction, coulombFriction)
        sumOfErrors = 0
        #Simulate what the motor should have done with the given time commands of each measure
        for measure in listOfMeasures :
            #Getting list of timmed commands [t, command] and initial speed
            initialSpeed = measure.values[1][3] #/!\ Attention ! Should be measure.values[0][3] but the first speed value is wrong. TODO
            initialPosition = measure.values[0][2]
            timedCommands = []
            for t, command, position, speed in measure.values :
                timedCommands.append([t, command])
            #Doing the simulation
            simulationResults = self.simulation(timedCommands, initialPosition, initialSpeed, printIt=False)
            #Comparing the simulation and the measure
            sumOfErrors = sumOfErrors + self.compareSimulationAndMeasure(simulationResults, measure, printIt=True)
        return sumOfErrors
        
    def main(self):
#         T = numpy.arange(0, 1, 0.0001)
#         timedCommands = zip(T, itertools.repeat(4))
#         self.updateModelConstants(12, self.i0, self.ke, self.r, self.klin, self.linearTransition, self.staticFriction, self.coulombFriction)
#         self.simulation(timedCommands, 0, 0, printIt=True)
        
        listOfMeasures = self.readMeasures("measures/completeTest")
        value = self.evaluateModelForMeasures(listOfMeasures, 12, self.i0, self.ke, self.r, self.klin, self.linearTransition, self.staticFriction, self.coulombFriction)
#         print "listOfMeasures = \n", listOfMeasures
        #Takes a measure and the values of the parameters and returns a score.
#         qualityFunction = lambda x : amplitude*numpy.sin(x)
        
         
print("A new day dawns")
modelTest = ModelTester()
modelTest.main()
print("Done !")
