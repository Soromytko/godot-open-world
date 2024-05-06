extends Resource

@export var lod_distance : float = 1.0
@export var shadow_casting : GeometryInstance3D.ShadowCastingSetting = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
@export var mesh : ArrayMesh
##This scene will spawn when the LOD is set. The scene must be of the Destroyable type.
@export var destroyable_scene : PackedScene
