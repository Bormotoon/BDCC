extends Node2D

@export var var supportsVerticalFlip = true
@export var var supportsHorizontalFlip = true

func canFlipV():
	return supportsVerticalFlip

func canFlipH():
	return supportsHorizontalFlip

