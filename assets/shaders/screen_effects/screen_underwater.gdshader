shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec4 tint : source_color; // tint effect
uniform float wave_speed = 3.0; // wave loop speed
uniform float wave_freq = 10.0; // wave vertical freq
uniform float wave_width = 1; // wave width 
uniform float blur = 2.0; // Defines the blur strength. Increase for a larger blur radius.

void fragment(){
	vec2 wave_uv_offset;
	wave_uv_offset.y = 0.0;
	wave_uv_offset.x = cos((TIME*wave_speed)+UV.x+UV.y*wave_freq*2.0)*wave_width*0.01;
	
	float blur_strength = blur / 100.0;
	vec4 blurred_color = vec4(0.0);
    int sample_count = 0;
    for (float x = -blur_strength; x <= blur_strength; x += blur_strength / 10.0) {
        for (float y = -blur_strength; y <= blur_strength; y += blur_strength / 10.0) {
            blurred_color += texture(SCREEN_TEXTURE, SCREEN_UV + wave_uv_offset + vec2(x, y));
            sample_count++;
        }
    }
    blurred_color /= float(sample_count);
	
	COLOR = blurred_color * tint;
	//ALPHA = tint.a;
}