// NOTE: Shader automatically converted from Godot Engine 4.2.2.stable's ORMMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap_anisotropic,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_orm : hint_roughness_g,filter_nearest_mipmap_anisotropic,repeat_enable;
uniform sampler2D texture_normal : hint_roughness_normal,filter_nearest_mipmap_anisotropic,repeat_enable;
uniform float normal_scale : hint_range(-16,16);

uniform float fov : hint_range(10.0, 170.0) = 80.0;

void vertex() {
	float scale = 1.0 / tan(fov * 0.5 * PI / 180.0);
	PROJECTION_MATRIX[0][0] = scale / (VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);
	PROJECTION_MATRIX[1][1] = -scale;
	
	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.xyz, 1.0);
	POSITION.z = mix(POSITION.z, 0, 0.99);
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	vec4 orm_tex = texture(texture_orm,base_uv);
	ROUGHNESS = orm_tex.g;
	METALLIC = orm_tex.b;
	NORMAL_MAP = texture(texture_normal,base_uv).rgb;
}
