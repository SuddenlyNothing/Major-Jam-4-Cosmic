extends Area2D

onready var sprite := $Sprite
onready var collision_shape := $CollisionShape2D
onready var label := $Label
onready var t := $Tween

export(String, FILE, "*.png") var texture setget set_texture
var tres : Texture
export(String) var group setget set_group
export(String) var label_name setget set_label_name

func set_texture(val):
	texture = val
	tres = load(texture)
	sprite.texture = tres
	print(sprite.texture.get_height()/2)
	sprite.position.y = -sprite.texture.get_height()/2
	collision_shape.position.y = -sprite.texture.get_height()/2
	collision_shape.shape.extents = sprite.texture.get_size()/2


func set_group(val):
	group = val


func set_label_name(val):
	label_name = val
	print(val)
	label.text = val


func get_info() -> Dictionary:
	return {"texture": tres, "group" : group}


func _on_ToolBase_body_entered(body):
	pass # Replace with function body.


func _on_ToolBase_body_exited(body):
	pass # Replace with function body.
