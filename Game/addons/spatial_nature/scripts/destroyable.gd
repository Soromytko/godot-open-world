@tool
extends StaticBody3D

signal destroyed()


func destroy():
	destroyed.emit()

