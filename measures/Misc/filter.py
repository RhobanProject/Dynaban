import time, math, sys, csv

print 'Arg[1]', str(sys.argv[1])

csvWriter = csv.writer(open("./output.csv", "wb"))
csvReader = csv.reader(open(str(sys.argv[1]), "rb"))

i = 0
for row in csvReader:
        #print row
        if (len(row) < 1) :
                pass
        else :
                if (abs(float(row[0])) > 200) :
                        #Data deleted
                        pass
                else :
                        csvWriter.writerow([row[0]])
                        i = i + 1
                        
