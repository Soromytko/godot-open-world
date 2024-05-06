class_name Plant extends "res://addons/spatial_nature/scripts/plant.gd"

@export var name : String
@export_group("Generation")
@export var noise_map : Image
@export_range(0, 1) var frequency : float = 0.8
@export var frequency_degree : int = 1
@export_range(0, 1) var min_noise_value : float = 0.2
@export var min_size : float = 0.8
@export var max_size : float = 1.8
