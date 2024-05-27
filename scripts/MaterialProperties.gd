extends PhysicsMaterial
class_name MaterialProperties

@export_group("Collision")
@export var DISABLE_COLLISIONS = false

@export_group("Sound")
@export_subgroup("General Sounds")
@export var SFX_STEP : AudioStream
@export var SFX_JUMP : AudioStream
@export_subgroup("Physics Sounds")
@export var SFX_IMPACT_SOFT: AudioStream
@export var SFX_IMPACT_HARD: AudioStream
@export var SFX_SCRAPE: AudioStream

@export_group("Visuals")
@export var IMPACT : Resource
