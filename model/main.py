# -*- coding: utf-8 -*-
#Author : Rémi Fabre

import csv
import itertools
import math
import numpy
from numpy import asarray
import sys
import time

import cma
import matplotlib.pyplot as plt
from measure import Measure
import measure


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


##TODO 
# - include the 1.47 ratio observed in torque measures.
# - Add pure torque tests and weight them more than pure speed tests

class  ModelTester(object):
    def __init__(self) :
        self.voltage = 12.0
        self.i0 = 0.00353 #(actual value 0.00353) in kg.m**2 is the measured moment of inertia when empty (only gear box attached). Can't value the measure too much though. (datasheet from maxon gives 2.17g.cm^2 which, with the 200 gear ratio is 4.35*10⁻5, which is 10 times less than the measured value !)
        self.ke = 1.6 #V*s/rad
        self.kt = self.ke #N.m/A
        self.r = 4.1 #ohm
        self.rawKlin = 1/1.626 #command*s/step . Command in [0, 3000]. If command = 1000 => speed = 1000*(1/klinMeasured) + offset in steps/s
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
        self.kvis = (self.ke - self.klin)*self.kt/self.r #In N.m*s/rad. The formula is : klin = ke - r*kvis/kt => kvis = (ke - klin)*kt/r
        self.linearTransition = self.rawLinearTransition * self.rawPositionToRad # In rad/s
        self.staticFriction = self.rawStaticFriction * self.rawCommandToSiTorque #In N.m
        self.coulombFriction = self.staticFriction/2.0 #In N.m. pifometric value. When speed == linearTransition, abs(totalFriction) = coulombFriction
        #We want that when speed == linearTransition, total friction = -coulombFriction
        self.coulombContribution = (1/(1 - math.exp(-1)))*(self.kvis * self.linearTransition - math.exp(-1)*self.staticFriction + self.coulombFriction)
        self.addedInertia = 0.004

        
        #internal use :
        self.nbMeasures = 0
        self.noDisplay = False
    
    def __repr__(self):
        output = []
        for key in self.__dict__:
            output.append("{key}='{value}'\n".format(key=key, value=self.__dict__[key]))
 
        return ', '.join(output)

        
    def updateModelConstants(self, voltage, i0, ke, r, klin, linearTransition, staticFriction, coulombFriction, addedInertia):
        self.voltage = voltage
        self.io = i0
        self.ke = ke
        self.kt = self.ke
        self.r = r
        self.klin = klin
        self.linearTransition = linearTransition
        self.staticFriction = staticFriction
        self.coulombFriction = coulombFriction
        self.addedInertia = addedInertia
        print "klin = ", klin
        #Pure update
        self.kvis = (self.ke - self.klin)*self.kt/self.r #In V*s/rad. The formula is : klin = ke - r*kvis/kt => kvis = (ke - klin)*kt/r
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
        plt.legend(['eleprint "io = ", self.i0ctricalTorque', 'frictionTorque', 'outputTorque'])
        plt.grid(True)
        
        plt.show(block=True)
    

    #Takes an initial speed, and a list of [time, command]. Outputs [T, position, speed, acceleration, outputTorque, electricalTorque, frictionTorque]
    #where T, position, speed, etc are each an array whom size is the same than timedCommands
    def simulation(self, timedCommands, initialPosition,initialSpeed, isAddedInertia=False, printIt=False):
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
            fTorque = self.computeFrictionTorque(speed[i], sign(eTorque))
            frictionTorque.append(fTorque)
            
            if (speed[i] == 0 and (abs(eTorque) < abs(fTorque))) :
                #When still, trying to move the motor with an insuficient eTorque will create an oposed frictionTorque of eTorque and nothing more
                #Without this, it would be like if the static friction pushed you back harder than what you pushed in, creating an acceleration where 
                #nothing would have moved in the real world.
                outputTorque.append(0)
            else :
                outputTorque.append(eTorque + fTorque)
            
            if isAddedInertia :
                acceleration.append(outputTorque[i]/(self.i0+self.addedInertia))
            else :
                acceleration.append(outputTorque[i]/self.i0)
            
            speed.append(speed[i] + dt*acceleration[i])
            position.append(position[i] + speed[i]*dt)
            oldT = t
           
        position = position[:-1]
        speed = speed[:-1]
        if (printIt) :
            print "Size of T = ", len(T)
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
            plt.show(block=True)
        
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
#         print "friction = ", friction
#         raw_input()
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
            plt.show(block=True)
            
#         print "sumOfErrors = ", sumOfSquaredErrors
        return sumOfSquaredErrors


    def readMeasures(self, fileName, timeLimit=None, typeOffset=0) :
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
                    typeOfTest = int(row[1].strip()) + typeOffset
                    print "New test"
                elif (row[0].strip() == "Time") :
                    #New measure adding the previous one and creating a new one
                    if (measure != None) :
                        listOfMeasures.append(measure)
                        
                    measure = Measure(typeOfTest)
                elif (isNumber(row[0].strip())) :
                    if (timeLimit != None) :
                        if float(row[0])/10000.0 > timeLimit :
                            #We're done for this measure
                            continue
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
            
    def evaluateModelForMeasures(self, listOfMeasures, voltage, i0, ke, r, klin, linearTransition, staticFriction, coulombFriction, addedInertia=0):
        #Updating the model
        self.updateModelConstants(voltage, i0, ke, r, klin, linearTransition, staticFriction, coulombFriction, addedInertia)
        sumOfErrors = 0
        #Simulate what the motor should have done with the given time commands of each measure
        for measure in listOfMeasures :
            #Getting list of timmed commands [t, command] and initial speed
            initialSpeed = measure.values[1][3] #/!\ Attention ! Should be measure.values[0][3] but the first speed value is wrong. TODO
            initialPosition = measure.values[0][2]
            timedCommands = []
            for t, command, position, speed in measure.values :
                timedCommands.append([t, command])
            if self.nbMeasures < (30+112) or self.noDisplay :
                printIt = False
            else :
                printIt = True
                print self
            #We use the type field to differentiate measures that were done with an empty motor from measures done with an added inertia
            if measure.typeOfTest >= 10 :
                addInertia = True
            else :
                addInertia = False
            #Doing the simulation
            simulationResults = self.simulation(timedCommands, initialPosition, initialSpeed, isAddedInertia=addInertia, printIt=printIt)
            #Comparing the simulation and the measure
            sumOfErrors = sumOfErrors + self.compareSimulationAndMeasure(simulationResults, measure, printIt=printIt)
            self.nbMeasures = self.nbMeasures + 1
        print "\n***Score = ", sumOfErrors
        return sumOfErrors
        
    #Same function but all the args are in x
    def evaluateModelForMeasures1D(self, x, *args):
        x = asarray(x)
        listOfMeasures = args[0]

        #Unzippid the parameters
        voltage = 12
        i0 = x[0]
        ke = x[1]
        r = x[2]
        klin = x[3]
        linearTransition = x[4]
        staticFriction = x[5]
        coulombFriction = x[6]
        addedInertia = x[7]
        
        if (i0 < 0 or klin < ke or ke < 0 or r < 0 or linearTransition < 0 or coulombFriction < 0 or staticFriction < 0 or addedInertia < 0 
            or ke > 5 or r > 20 or coulombFriction > staticFriction or staticFriction > 0.6 or addedInertia > 0.009 or addedInertia < 0.002) :
            #Impossible values are discarded through a very bad score
            return 100000
        
        #Torque measures say that the ratio kt/r should be ~0.394. We'll make sure this is respected.
        tolerance = 0.05
        idealValue = 0.394
        value = ke/r
        sanction = 0
        if (abs(value - idealValue) < tolerance) :
            sanction = 0
        elif (abs(value - idealValue) < 4*tolerance) :
            sanction = abs(value - idealValue)*150
        else :
            return 100000
        
        print "sanction = ", sanction
        return self.evaluateModelForMeasures(listOfMeasures, voltage, i0, ke, r, klin, linearTransition, staticFriction, coulombFriction, addedInertia) + sanction
        
    def main(self):
#         print self
#         T = numpy.arange(0, 1, 0.0001)
#         timedCommands = zip(T, itertools.repeat(8))
#         self.updateModelConstants(12, self.i0, self.ke, self.r, self.klin, self.linearTransition, self.staticFriction, self.coulombFriction)
#         self.simulation(timedCommands, 0, 0, printIt=True)
#         
#         return

        print "Initial model values :"
        print "voltage = ", self.voltage #12
        print "io = ", self.i0 #0.00353
        print "ke = ", self.ke #1.6
        print "r = ", self.r #5.86
        print "klin = ", self.klin #-1.60368670825
        print "linearTransition = ", self.linearTransition #0.306796157577
        print "staticFriction = ", self.staticFriction #0.150170648464
        print "coulombFriction = ", self.coulombFriction #0.0750853242321
        print "addedInertia = ", self.addedInertia#0.004

        listOfMeasures = self.readMeasures("measures/completeTest", timeLimit=0.150, typeOffset=0)
        listOfMeasuresheavyLoad = self.readMeasures("measures/completeTestHeavyLoad", timeLimit=0.150, typeOffset=10)
        #Adding the heavy load measures
        listOfMeasures.extend(listOfMeasuresheavyLoad)
        #Max speed is 4PI/s = 120 rpm
        self.fixGaps(listOfMeasures, 4*math.pi)
        self.noDisplay = False

        #self.noDisplay = True
        #value = self.evaluateModelForMeasures(listOfMeasures, 12, self.i0, self.ke, self.r, self.klin, self.linearTransition, self.staticFriction, self.coulombFriction)
        #print value
        
        #tolfun 100
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, -0.0017217180565952648, 3.9265053688586535, 4.4190475060541337, -1.642030980764918, -0.19456964024780998, 0.19221036872483038, 0.60201284035701119)
        #tolfun 100 with limits on values
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.00905955, 3.29605672, 1.63030819, -1.6484249, 0.04996982, 0.19198735, 0.21656958)

        #tolfun 100 with limits on values
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.00794687, 1.49117495, 0.85706012, 1.64383661, -0.04078583, 0.07417589, 0.30257492)
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.0034689028202296171, 1.555666164824836, 1.1287356922053267, 1.6444843194436245, 0.41284770773063401, 0.1294117709539814, 0.29580470901307804)
#tolfun 80 :
# [0.0021731366250028568, 1.355067751766774, 0.94623234209939366, 1.6460100334124927, 0.027949448057014062, 0.12011789072794421, 0.27722890096104058]

#Score of 5.27
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 4.66664605e-04, 1.21498291e+00, 5.13895843e-01, 1.80236842e+00, 3.23283556e-01, 1.31244462e-01, 1.36619002e-01)
       
       #Score of 23
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.32711334, 5.0, 11.26126126, 12.46876941, 37.99361901, 0.50304455, 0.50304455)

        #Score of 5 (only on the first 150 ms though)
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.00589097, 1.4666091, 4.10039631, 1.55765625, 0.25689851, 0.12147452, 0.08027712)
        
        #Score of 0.91 (only on the first 150 ms though)
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.00459395, 1.39735606, 3.26399923, 1.7137901, 0.59109595, 0.14349084, 0.11449425)
        
        #Score of 0.127 (only on the first 150 ms though)
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.00250709722, 1.57426512, 4.57635209, 1.62426655, 0.149425682, 0.0985980367, 0.0915512434)
        
        #Score of 10 (full length)
#         3.83787890e-03   1.47894946e+00   4.25865142e+00   1.63136824e+00 9.17768154e-02   1.26099628e-01   9.98887909e-02

        #Adding the "addedInertia" attribute from here
#         value = self.evaluateModelForMeasures(listOfMeasures, 12, 0.00250709722, 1.57426512, 4.57635209, 1.62426655, 0.149425682, 0.0985980367, 0.0915512434, 0.004)
    
    #Score of 0.94 with addedInertia, on the first 150ms
#     1.07728666e-03   1.36831818e+00   3.91813279e+00   1.65976880e+00 1.75653773e-01   1.26764092e-01   9.03878047e-02   3.11286186e-03
    
    #Score of 0.39 with addedInertia, on the first 150ms
# 4.91495976e-04   1.62594599e+00   4.72658717e+00   1.63540545e+00 1.95274189e-01   1.21803765e-01   8.79444393e-02   4.07977291e-03
    #Score of 0.39 with addedInertia, on the first 150ms
# 0.00537005  1.39865656  4.06586179  1.63538543  0.19542816  0.12123053 0.1030164   0.00408195

        #Score of 0.386 with addedInertia, on the first 150ms
# 6.74933458e-03   1.50816125e+00   4.38408117e+00   1.63554751e+00 1.38872124e-01   1.45544129e-01   1.01677621e-01   4.09684545e-03

#Score of 0.382214837376 with addedInertia, on the first 150ms
# [  1.55818308e-02   1.51294795e+00   4.39798614e+00   1.63553529e+00 8.09641650e-02   2.03719639e-01   1.20403543e-01   4.07587229e-03]
#         print "value = ", value
#         return
        self.noDisplay = True
        params = [self.i0, self.ke, self.r, self.klin, self.linearTransition, self.staticFriction, self.coulombFriction, self.addedInertia]
        options = cma.CMAOptions()
        #Rescaling the sigmas for each variable
        options['scaling_of_variables'] = [params[0], params[1], params[2]/5.0, params[3]/5.0, params[4], params[5]/10.0, params[6]*2, params[7]/2.5]
        options['tolfun'] = 0.5
        options['ftarget'] = 0.2
        
        res = cma.fmin(self.evaluateModelForMeasures1D, params, 0.5, options, args=[listOfMeasures], restarts=6, bipop=True)

        print "Best solution = ", res[0]
        print "Best score = ", res[1]
        print "Function evals = ", res[2]
        print "Function evals? = ", res[3]
        print "Nb iterations = ", res[4]
        print "mean of final sample distribution", res[5]
        cma.plot()
        cma.show()
        while(True) :
            temp = 22
        
        
         
print("A new day dawns")
modelTest = ModelTester()
modelTest.main()
print("Done !")


#cma option :
# {'AdaptSigma': 'CMAAdaptSigmaCSA  # or any other CMAAdaptSigmaBase class e.g. CMAAdaptSigmaTPA',
#  'CMA_active': 'True  # negative update, conducted after the original update',
#  'CMA_cmean': '1  # learning rate for the mean value',
#  'CMA_const_trace': 'False  # normalize trace, value CMA_const_trace=2 normalizes sum log eigenvalues to zero',
#  'CMA_dampsvec_fac': 'np.Inf  # tentative and subject to changes, 0.5 would be a "default" damping for sigma vector update',
#  'CMA_dampsvec_fade': '0.1  # tentative fading out parameter for sigma vector update',
#  'CMA_diagonal': '0*100*N/sqrt(popsize)  # nb of iterations with diagonal covariance matrix, True for always',
#  'CMA_eigenmethod': 'np.linalg.eigh  # 0=numpy-s eigh, -1=pygsl, otherwise cma.Misc.eig (slower)',
#  'CMA_elitist': 'False  #v or "initial" or True, elitism likely impairs global search performance',
#  'CMA_mirrormethod': '1  # 0=unconditional, 1=selective, 2==experimental',
#  'CMA_mirrors': 'popsize < 6  # values <0.5 are interpreted as fraction, values >1 as numbers (rounded), otherwise about 0.16 is used',
#  'CMA_mu': 'None  # parents selection parameter, default is popsize // 2',
#  'CMA_on': 'True  # False or 0 for no adaptation of the covariance matrix',
#  'CMA_rankmu': 'True  # False or 0 for omitting rank-mu update of covariance matrix',
#  'CMA_rankmualpha': '0.3  # factor of rank-mu update if mu=1, subject to removal, default might change to 0.0',
#  'CMA_sample_on_sphere_surface': 'False  #v all mutation vectors have the same length',
#  'CMA_stds': 'None  # multipliers for sigma0 in each coordinate, not represented in C, makes scaling_of_variables obsolete',
#  'CMA_teststds': 'None  # factors for non-isotropic initial distr. of C, mainly for test purpose, see CMA_stds for production',
#  'CSA_clip_length_value': 'None  #v untested, [0, 0] means disregarding length completely',
#  'CSA_damp_mueff_exponent': '0.5  # zero would mean no dependency of damping on mueff, useful with CSA_disregard_length option',
#  'CSA_dampfac': '1  #v positive multiplier for step-size damping, 0.3 is close to optimal on the sphere',
#  'CSA_disregard_length': 'False  #v True is untested',
#  'CSA_squared': 'False  #v use squared length for sigma-adaptation ',
#  'boundary_handling': 'BoundTransform  # or BoundPenalty, unused when ``bounds in (None, [None, None])``',
#  'bounds': '[None, None]  # lower (=bounds[0]) and upper domain boundaries, each a scalar or a list/vector',
#  'fixed_variables': 'None  # dictionary with index-value pairs like {0:1.1, 2:0.1} that are not optimized',
#  'ftarget': '-inf  #v target function value, minimization',
#  'is_feasible': 'is_feasible  #v a function that computes feasibility, by default lambda x, f: f not in (None, np.NaN)',
#  'maxfevals': 'inf  #v maximum number of function evaluations',
#  'maxiter': '100 + 50 * (N+3)**2 // popsize**0.5  #v maximum number of iterations',
#  'maxstd': 'inf  #v maximal std in any coordinate direction',
#  'mean_shift_line_samples': 'False #v sample two new solutions colinear to previous mean shift',
#  'mindx': '0  #v minimal std in any direction, cave interference with tol*',
#  'minstd': '0  #v minimal std in any coordinate direction, cave interference with tol*',
#  'pc_line_samples': 'False #v two line samples along the evolution path pc',
#  'popsize': '4+int(3*log(N))  # population size, AKA lambda, number of new solution per iteration',
#  'randn': 'np.random.standard_normal  #v randn((lam, N)) must return an np.array of shape (lam, N)',
#  'scaling_of_variables': 'None  # (rather use CMA_stds) scale for each variable, sigma0 is interpreted w.r.t. this scale, in that effective_sigma0 = sigma0*scaling. Internally the variables are divided by scaling_of_variables and sigma is unchanged, default is np.ones(N)',
#  'seed': 'None  # random number seed',
#  'signals_filename': 'cmaes_signals.par  # read from this file, e.g. "stop now"',
#  'termination_callback': 'None  #v a function returning True for termination, called after each iteration step and could be abused for side effects',
#  'tolfacupx': '1e3  #v termination when step-size increases by tolfacupx (diverges). That is, the initial step-size was chosen far too small and better solutions were found far away from the initial solution x0',
#  'tolfun': '1e-11  #v termination criterion: tolerance in function value, quite useful',
#  'tolfunhist': '1e-12  #v termination criterion: tolerance in function value history',
#  'tolstagnation': 'int(100 + 100 * N**1.5 / popsize)  #v termination if no improvement over tolstagnation iterations',
#  'tolupsigma': '1e20  #v sigma/sigma0 > tolupsigma * max(sqrt(eivenvals(C))) indicates "creeping behavior" with usually minor improvements',
#  'tolx': '1e-11  #v termination criterion: tolerance in x-changes',
#  'transformation': 'None  # [t0, t1] are two mappings, t0 transforms solutions from CMA-representation to f-representation (tf_pheno), t1 is the (optional) back transformation, see class GenoPheno',
#  'typical_x': 'None  # used with scaling_of_variables',
#  'updatecovwait': 'None  #v number of iterations without distribution update, name is subject to future changes',
#  'verb_append': '0  # initial evaluation counter, if append, do not overwrite output files',
#  'verb_disp': '100  #v verbosity: display console output every verb_disp iteration',
#  'verb_filenameprefix': 'outcmaes  # output filenames prefix',
#  'verb_log': '1  #v verbosity: write data to files every verb_log iteration, writing can be time critical on fast to evaluate functions',
#  'verb_plot': '0  #v in fmin(): plot() is called every verb_plot iteration',
#  'verb_time': 'True  #v output timings on console',
#  'verbose': '1  #v verbosity e.v. of initial/final message, -1 is very quiet, -9 maximally quiet, not yet fully implemented',
#  'vv': '0  #? versatile variable for hacking purposes, value found in self.opts["vv"]'}


# ***Score =  82.6573334278
# termination on tolfun=100 (Sun Feb 21 22:07:33 2016)
# final/bestever f-value = 8.265733e+01 8.231888e+01
# incumbent solution: [-0.0017217180565952648, 3.9265053688586535, 4.4190475060541337, -1.642030980764918, -0.19456964024780998, 0.19221036872483038, 0.60201284035701119]
# std deviation: [0.00055379648103389171, 0.077314286714511474, 0.094724754479649939, -0.0086956368845549116, 0.017795164256924369, 0.0023336334505513344, 0.026667821922443047]
# Best solution =  [ -2.38785070e-03   3.93444317e+00   4.41924366e+00  -1.64136228e+00
#   -1.96736930e-01   1.92058401e-01   6.10832699e-01]
# Best score =  82.3188751598
# Function evals =  658
# Nb iterations =  73
# mean of final sample distribution [ -1.72171806e-03   3.92650537e+00   4.41904751e+00  -1.64203098e+00
#   -1.94569640e-01   1.92210369e-01   6.02012840e-01]


# ***Score =  39.9388355031
# termination on tolfun=100 after 8 restarts (Mon Feb 22 01:04:47 2016)
# final/bestever f-value = 3.993884e+01 3.944455e+01
# incumbent solution: [-0.0047154929449730607, 2.3826533417305322, 1.2325217670464923, -1.6454207779372354, 0.14760157592189133, 0.37819736797757914, 0.24556223362528634]
# std deviation: [0.01941350450540855, 0.16913843554953334, 0.20742926597232328, -0.0038810330929717344, 0.062033643623685374, 0.093771929263302703, 0.10799067022761322]
# Best solution =  [-0.02219176  2.30620918  1.06682887 -1.64271848  0.07599858  0.41265634
#   0.40887769]
# Best score =  39.4445482804
# Function evals =  12237
# Nb iterations =  22
# mean of final sample distribution [-0.00471549  2.38265334  1.23252177 -1.64542078  0.14760158  0.37819737
#   0.24556223]

#With value limits :
# ***Score =  40.6193897137
# termination on tolfun=100 after 8 restarts (Mon Feb 22 04:10:08 2016)
# final/bestever f-value = 4.061939e+01 3.970903e+01
# incumbent solution: [0.0106290346879357, 2.6684604518034858, 1.4422727293245914, -1.6467784852543292, 0.053670597954943153, 0.13920275617757583, 0.24140111239626097]
# std deviation: [0.0036314483532348487, 0.16015661989299235, 0.21279614527693674, -0.0040019495177220209, 0.026229363476716127, 0.024343989274730714, 0.038494925128667083]
# Best solution =  [ 0.00905955  3.29605672  1.63030819 -1.6484249   0.04996982  0.19198735
#   0.21656958]
# Best score =  39.7090283217
# Function evals =  10643
# Nb iterations =  18
# mean of final sample distribution [ 0.01062903  2.66846045  1.44227273 -1.64677849  0.0536706   0.13920276
#   0.24140111]

# ***Score =  6.03397620719
# termination on tolfun=80 (Mon Feb 22 16:34:54 2016)
# final/bestever f-value = 6.033976e+00 5.276688e+00
# incumbent solution: [0.0014297490178335976, 1.3457305710862624, 0.80927539256604819, 1.8189906576209687, 0.40241634456138559, 0.13190249091726952, 0.14333801164304466]
# std deviation: [0.001364867260570068, 0.4334119765805502, 0.50251585356779727, 0.11493465062539569, 0.11576092129457048, 0.005343894871609199, 0.048279800325742209]
# Best solution =  [  4.66664605e-04   1.21498291e+00   5.13895843e-01   1.80236842e+00
#    3.23283556e-01   1.31244462e-01   1.36619002e-01]
# Best score =  5.2766884464
# Function evals =  158
# Function evals? =  163
# Nb iterations =  18
# mean of final sample distribution [  1.42974902e-03   1.34573057e+00   8.09275393e-01   1.81899066e+00
#    4.02416345e-01   1.31902491e-01   1.43338012e-01]

#With heavy load, 150 first ms, huge optimization
# ***Score =  0.382640793297
# termination on tolfun=0.5 after 29 restarts (Wed Feb 24 03:43:22 2016)
# final/bestever f-value = 3.826408e-01 3.822148e-01
# incumbent solution: [0.02187866876518179, 1.4872191332301929, 4.3231756716801444, 1.6356048263419882, 0.082684326186345219, 0.20239706218499762, 0.12064301985268057, 0.004077934340198981]
# std deviation: [0.0055461469558969025, 0.0078863043575942999, 0.022926140720153653, 0.00010897796987987618, 0.00016057374339036463, 0.00013620453383811495, 0.000242429100347206, 1.2155364228655447e-06]
# Best solution =  [  1.55818308e-02   1.51294795e+00   4.39798614e+00   1.63553529e+00
#    8.09641650e-02   2.03719639e-01   1.20403543e-01   4.07587229e-03]
# Best score =  0.382214837376
# Function evals =  99086
# Function evals? =  175544
# Nb iterations =  75
# mean of final sample distribution [  2.18786688e-02   1.48721913e+00   4.32317567e+00   1.63560483e+00
#    8.26843262e-02   2.02397062e-01   1.20643020e-01   4.07793434e-03]
