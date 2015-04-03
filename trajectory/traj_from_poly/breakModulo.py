import time, math, sys, csv

print 'Arg[1]', str(sys.argv[1])

csvWriter = csv.writer(open("./output.csv", "wb"))
csvReader = csv.reader(open(str(sys.argv[1]), "rb"), delimiter=' ')

i = 0
oldValue = 0
value = 0
maxDelta = 1000
firstRow = True
toAdd = 0
for row in csvReader:
        i = i + 1
        #print row
        if (len(row) < 1) :
                pass
        else :
                print i, "th row[0]  = ", row[0]
                if (firstRow) :
                        value = int(row[1])
                        oldValue = value
                        firstRow = False
                else :
                        oldValue = value
                        value = int(row[1])

                if (abs(value - oldValue) > maxDelta) :
                        if (value > oldValue) :
                                toAdd = toAdd - 4096
                        else :
                                toAdd = toAdd + 4096

                csvWriter.writerow([int(row[0]), int(row[1]) + toAdd])
