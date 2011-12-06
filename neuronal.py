#!/usr/bin/python

# Filename: neuronal.py
# Author:   Aaron Karper
# Created:  2011-12-06
# Description:
#          Neuronal network in a language that less of a pain in the arse. 
import scipy
import numpy as np

class Neuron(object):
	def __init__(self, initalValue = 0.0, initialConnections=dict()):
		self._value = initialValue
		self._connections = initialConnections
		self._out = set()
	def activationFunction(self, val):
		return val
	@property
	def value(self):
		return self._value
	def update(self):
		tempValue = 0.0
		for neuron, weight in self._connections.items():
			tempValue += neuron.value * weight
		self._value = self.activationFunction(tempValue)
		for output in self._out:
			output.update() #this assumes acyclic graph
	@property
	def connections(self):
		return list(self._connections)
	@connections.setter
	def connections(self, cons):
		try:
			for neuron in cons:
				self._connections[neuron] = cons[neuron]
				neuron.addOutput(self)
		except IndexError:
			for neuron in cons:
				self._connections[neuron] = 1.0
				neuron.addOutput(self)
	def addOutput(self, out):
		self._out.add(out)
class InputNeuron(Neuron):
	def __init__(self, value=0):
		Neuron.__init__(self, value, [])
	value = Neuron.value
	@value.setter
	def value(self,v):
		assert isinstance(v+1.0,float) # Python, please get interfaces already
		self._value = v

OutputNeuron = Neuron

class Layer(object):
	def __init__(self, neurons):
		self._neurons = neurons
		self._below = None
	@property
	def value(self):
		return [neuron.value for neuron in self._neurons]
	@property
	def neurons(self):
		return list(self._neurons)
	@property
	def layerBelow(self):
		return self._below
class UpperLayer(Layer):
	layerBelow = Layer.layerBelow
	@layerBelow.setter
	def layerBelow(self, below):
		self._below = below
		for neuron in self._neurons:
			neuron.connections = below.neurons
	def update(self):
		for neuron in self._neurons:
			neuron.update()
class InputLayer(Layer):
	value = Layer.value
	@value.setter
	def value(self,arr):
		for neuron,val in zip(self._neurons,arr):
			neuron.value = val

OutputLayer = UpperLayer

def neuronalNetwork(input = 2, hidden = [], output = 1):
	"""Creates a random neuronal Network with `input` input neurons, `output`
output neurons and `len(hidden)` hidden layers with `hidden[i]` neurons each"""
	inputLayer = InputLayer(InputNeuron() for i in range(input))
	layers = [inputLayers]
	for n in hidden:
		layers.append(UpperLayer(Neuron(initialConnections = layers[-1]) for i in range(n)))
	outputLayer = OutputLayer(OutputNeuron(initialConnections = layers[-1]) for i in range(output))
	return Network(inputLayer, outputLayer)

class Network(object):
	def __init__(self, inputlayer, outputlayer):
		self._inputlayer = inputlayer
		self._outputlayer = outputlayer
	def train(self, input, expected):
		pass
	def massTrain(self, inputs, outputs):
		for input,output in zip(inputs,outputs):
			self.train(input,output)

def arguments():
	import argparse
	parser = argparse.ArgumentParser()
	parser.add_argument('-I','--input', type = int, default = 2)
	parser.add_argument('-O','--output', type = int, default = 1)
	parser.add_argument('-H', '--hidden', type = int, default = 0)
	parser.add_argument('-P', '--printout', action = 'store_true')
	return parser.parse_args()

if __name__ == '__main__':
	args = arguments()
	network = neuronalNetwork(
			input = args.input, 
			output = args.output,
			hidden = args.hidden)
	
	if args.printout:
		pass #TODO
