shader_type canvas_item;

uniform sampler2D tex;

void fragment() {
	vec2 UV_m = UV;
	UV_m.x += 0.25 * cos(TIME);
	UV_m.y += 0.25 * sin(TIME);
	COLOR = texture(tex, UV_m);
	//COLOR = vec4(0.5*(sin(10.0*cos(UV.x) + 10.0*sin(TIME))+1.0), 0.5*(sin(10.0*sin(UV.y) + 10.0*cos(TIME))+1.0), 0.5*(sin(10.0*TIME)+1.0), 1.0);
	
	if (false) {
		int steps = 8;
		float dist = 200.0 / float(steps);
		float even_corr = dist * (0.5 - 0.5 * float(steps % 2));
		float step_corr = dist - even_corr + 2.0;
		int modx = int(step_corr + 200.0 * UV.x) % int(dist);
		int mody = int(step_corr + 200.0 * UV.y) % int(dist);
		
		if (modx < 4 && mody < 4)
			COLOR = vec4(1.0, 1.0, 1.0, 1.0);
		else
			COLOR = vec4(1.0, 1.0, 1.0, 0.0);
	}
}