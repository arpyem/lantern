extends Node

const REQUIRED_FILES: Array[String] = [
	"player/idle_down.png",
	"player/idle_up.png",
	"player/idle_left.png",
	"player/idle_right.png",
	"player/lantern.png",
	"fog/fog_blanket.png",
	"fog/fog_large.png",
	"fog/fog_medium.png",
	"fog/fog_small.png",
	"poes/common.png",
	"poes/ember.png",
	"poes/wisp.png",
	"installations/lantern_post_unlit.png",
	"installations/lantern_post_lit.png",
	"terrain/ground_tile.png",
	"ui/icons.png",
]

func _ready() -> void:
	if not _assets_exist():
		_generate_all()
	else:
		_generate_fog_assets()

func _assets_exist() -> bool:
	for file_path in REQUIRED_FILES:
		if not FileAccess.file_exists(AssetConfig.path(file_path)):
			return false
	return true

func _generate_all() -> void:
	var required_dirs: Array[String] = [
		"res://assets/placeholder/player",
		"res://assets/placeholder/fog",
		"res://assets/placeholder/poes",
		"res://assets/placeholder/installations",
		"res://assets/placeholder/terrain",
		"res://assets/placeholder/ui",
		"res://assets/final/player",
		"res://assets/final/fog",
		"res://assets/final/poes",
		"res://assets/final/installations",
		"res://assets/final/terrain",
		"res://assets/final/ui",
	]
	for dir_path in required_dirs:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))

	_save_image("player/idle_down.png", _make_player_sprite(Color(0.88, 0.85, 0.73), Vector2i(0, 0)))
	_save_image("player/idle_up.png", _make_player_sprite(Color(0.88, 0.85, 0.73), Vector2i(0, -1)))
	_save_image("player/idle_left.png", _make_player_sprite(Color(0.88, 0.85, 0.73), Vector2i(-1, 0)))
	_save_image("player/idle_right.png", _make_player_sprite(Color(0.88, 0.85, 0.73), Vector2i(1, 0)))
	_save_image("player/lantern.png", _make_lantern_sprite())
	_generate_fog_assets()
	_save_image("poes/common.png", _make_poe_sheet(Color(0.70, 0.85, 1.0)))
	_save_image("poes/ember.png", _make_poe_sheet(Color(1.0, 0.65, 0.2)))
	_save_image("poes/wisp.png", _make_poe_sheet(Color(0.6, 1.0, 0.7)))
	_save_image("installations/lantern_post_unlit.png", _make_post_sprite(Color(0.45, 0.32, 0.12), false))
	_save_image("installations/lantern_post_lit.png", _make_post_sprite(Color(0.95, 0.75, 0.3), true))
	_save_image("terrain/ground_tile.png", _make_ground_tile())
	_save_image("ui/icons.png", _make_icon_stub())

func _save_image(relative_path: String, image: Image) -> void:
	var error := image.save_png(ProjectSettings.globalize_path(AssetConfig.path(relative_path)))
	if error != OK:
		push_warning("Failed to generate placeholder asset: %s" % AssetConfig.path(relative_path))

func _generate_fog_assets() -> void:
	_save_image("fog/fog_blanket.png", _make_fog_sheet(Vector2i(224, 128), Vector2(78.0, 30.0), 0.26, 28))
	_save_image("fog/fog_large.png", _make_fog_sheet(Vector2i(160, 96), Vector2(54.0, 24.0), 0.30, 22))
	_save_image("fog/fog_medium.png", _make_fog_sheet(Vector2i(112, 72), Vector2(36.0, 18.0), 0.24, 16))
	_save_image("fog/fog_small.png", _make_fog_sheet(Vector2i(72, 52), Vector2(22.0, 11.0), 0.18, 12))

func _make_player_sprite(base_color: Color, eye_offset: Vector2i) -> Image:
	var image := Image.create(16, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for x in range(5, 11):
		for y in range(6, 19):
			image.set_pixel(x, y, base_color)
	for x in range(4, 12):
		for y in range(18, 31):
			image.set_pixel(x, y, Color(0.22, 0.35, 0.24))
	for x in range(5, 11):
		image.set_pixel(x, 5, Color(0.17, 0.16, 0.12))
	var eye := Vector2i(8, 11) + eye_offset
	if image.get_used_rect().has_point(eye):
		image.set_pixelv(eye, Color(0.1, 0.08, 0.05))
	return image

func _make_lantern_sprite() -> Image:
	var image := Image.create(8, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for x in range(2, 6):
		for y in range(3, 9):
			image.set_pixel(x, y, Color(0.95, 0.72, 0.25))
	for x in range(3, 5):
		image.set_pixel(x, 2, Color(0.35, 0.24, 0.08))
	for y in range(9, 12):
		image.set_pixel(3, y, Color(0.35, 0.24, 0.08))
		image.set_pixel(4, y, Color(0.35, 0.24, 0.08))
	return image

func _make_fog_sheet(frame_size: Vector2i, base_radius: Vector2, max_alpha: float, padding: int) -> Image:
	var sheet := Image.create(frame_size.x * 4, frame_size.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))
	var breathe_scales := [1.0, 1.03, 1.05, 1.03]
	var edge_color := Color(0.62, 0.71, 0.84, 0.0)
	var core_color := Color(0.78, 0.85, 0.95, 1.0)
	var center := Vector2((frame_size.x - 1) * 0.5, (frame_size.y - 1) * 0.5)

	for frame in range(4):
		var radius := base_radius * float(breathe_scales[frame])
		for x in range(frame_size.x):
			for y in range(frame_size.y):
				if x < padding or x >= frame_size.x - padding or y < padding or y >= frame_size.y - padding:
					continue
				var pixel_position := Vector2(x, y)
				var local := pixel_position - center
				var ellipse := Vector2(local.x / max(radius.x, 0.001), local.y / max(radius.y, 0.001))
				var dist := ellipse.length()
				if dist >= 1.0:
					continue
				var alpha := exp(-pow(dist, 2.0) * 3.2) * max_alpha
				var edge_fade_x := clampf(min(float(x - padding), float(frame_size.x - padding - 1 - x)) / max(float(padding), 1.0), 0.0, 1.0)
				var edge_fade_y := clampf(min(float(y - padding), float(frame_size.y - padding - 1 - y)) / max(float(padding), 1.0), 0.0, 1.0)
				alpha *= edge_fade_x * edge_fade_y
				alpha = clampf(alpha, 0.0, 1.0)
				var color := edge_color.lerp(core_color, alpha / max(max_alpha, 0.001))
				color.a = alpha
				sheet.set_pixel(x + frame * frame_size.x, y, color)
	return sheet

func _make_poe_sheet(color: Color) -> Image:
	var image := Image.create(42, 14, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var frame_offsets: Array[int] = [1, 0, 1]
	for frame in range(3):
		var y_offset: int = frame_offsets[frame]
		var center := Vector2i(7 + frame * 14, 7 - y_offset)
		for x in range(frame * 14, frame * 14 + 14):
			for y in range(0, 14):
				var distance := Vector2(x - center.x, y - center.y).length()
				if distance <= 5.5:
					var alpha := clampf(1.0 - (distance / 5.5), 0.0, 1.0)
					image.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
	return image

func _make_post_sprite(color: Color, lit: bool) -> Image:
	var image := Image.create(12, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for x in range(5, 7):
		for y in range(8, 24):
			image.set_pixel(x, y, color.darkened(0.15 if lit else 0.0))
	for x in range(3, 9):
		for y in range(2, 10):
			var dist := Vector2(x - 5.5, y - 5.5).length()
			if dist <= 3.8:
				image.set_pixel(x, y, color)
	if lit:
		for x in range(1, 11):
			for y in range(0, 14):
				var halo := Vector2(x - 5.5, y - 5.5).length()
				if halo <= 5.5:
					var alpha := clampf((5.5 - halo) / 12.0, 0.0, 0.25)
					var current := image.get_pixel(x, y)
					image.set_pixel(x, y, current.blend(Color(color.r, color.g, color.b, alpha)))
	return image

func _make_ground_tile() -> Image:
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.14, 0.18, 0.17))
	for x in range(16):
		for y in range(16):
			if (x + y) % 5 == 0:
				image.set_pixel(x, y, Color(0.16, 0.21, 0.19))
			elif (x * 3 + y) % 7 == 0:
				image.set_pixel(x, y, Color(0.11, 0.15, 0.14))
	return image

func _make_icon_stub() -> Image:
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for x in range(2, 14):
		for y in range(2, 14):
			if x == 2 or x == 13 or y == 2 or y == 13:
				image.set_pixel(x, y, Color(0.9, 0.8, 0.35))
	return image
