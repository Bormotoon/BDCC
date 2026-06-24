extends Node2D

@export var supportsVerticalFlip = true
@export var supportsHorizontalFlip = true

func canFlipV():
	return supportsVerticalFlip

func canFlipH():
	return supportsHorizontalFlip

