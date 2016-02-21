class Measure(object) :
	def __init__(self, typeOfTest) :
		self.typeOfTest = typeOfTest
		self.values = []
	def __repr__(self):
		output = ""
		output += "Type of test = "
		output += str(self.typeOfTest)
		output += "\n" 
		output += "Time     Command     Position     Speed\n"
		for line in self.values :
			output += str(line)
			output += "\n"
		return output
	#Adds a row of values. Values must be a tuple containing [time, val1, val2, .., valn]
	def addValues(self, values):
		self.values.append(values)