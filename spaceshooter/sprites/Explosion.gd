extends Sprite

export var frame_width = 128
export var frame_height = 128
export var total_frames = 20
export var frame_duration = 0.05

var current_frame = 0
var elapsed = 0.0


func _ready():
	region_enabled = true
	centered = true
	region_rect = Rect2(0, 0, frame_width, frame_height)


func _process(delta):
	elapsed += delta
	if elapsed >= frame_duration:
		elapsed -= frame_duration
		current_frame += 1
		if current_frame >= total_frames:
			queue_free()
		else:
			region_rect.position.x = current_frame * frame_width
