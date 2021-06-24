shader_type canvas_item;

uniform float scale : hint_range(1.0, 100.0) = 6.0;

uniform float base : hint_range(0.0, 0.2) = 0.07;

uniform float amplitude : hint_range(0.0, 0.1) = 0.02;

uniform float pulsation : hint_range(1.0, 10.0) = 5.0;

mat2 rotation(float a) {
	float s = sin(a);
	float c = cos(a);
	
	return mat2(vec2(c, -s), vec2(s, c));
}

float star(vec2 uv, float flare, float strenght) {
	float d = distance(uv, vec2(0.0));
	float m = strenght / d;
	
	float cross_shape = max(0, 1.0 - abs(uv.x * uv.y * 1000.0));
	
	m += cross_shape * flare;
	
	vec2 uv_scaled_rotated = uv * rotation(3.141592 / 4.0);
	
	float cross_shape_rotated = max(0, 1.0 - abs(uv_scaled_rotated.x * uv_scaled_rotated.y * 1000.0));
	
	m += cross_shape_rotated * 0.5 * flare;
	
	m *= smoothstep(1.0, 0.2, d);
	
	return m;
}

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	
	return fract(p.x * p.y);
}

void fragment() {
	vec2 uv_scaled = (2.0 * UV - 1.0) * scale;
	
	vec3 color = vec3(0.0);
	vec2 gv = fract(uv_scaled) - 0.5;
	vec2 id = floor(uv_scaled);
	
	for (int y = -1 ; y <= 1 ; y++) {
		for (int x = -1 ; x <= 1 ; x++) {
			vec2 offs = vec2(float(x), float(y));
			
			float n = hash21(id + offs);
			
			float size = fract(n * 345.32);
			
			float star = star(gv - offs - vec2(n, fract(n * 34.0)) + 0.5, smoothstep(0.8, 0.9, size), base + amplitude * sin(fract(n * 1234.1) * 6.28 + TIME * pulsation)) / 9.0;
			
			color += star * size;
		}
	}
	
	COLOR = vec4(color, 1.0);
}