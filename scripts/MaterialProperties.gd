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

@export_group("Spatial Audio")
@export_range(0.0, 1.0, 0.01) var REVERB_CONTRIBUTION : float = 1.0 ##How much spatial audio the material reflects
@export_range(0.0, 1.0, 0.01) var DAMPING : float = 0.5 ##How much spatial audio the material reflects
@export_range(0.0, 1.0, 0.01) var OCCLUSION : float = 1.0 ##How much spatial audio the material occludes

@export_group("Visuals")
@export var IMPACT : Resource
