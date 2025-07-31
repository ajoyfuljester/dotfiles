
uniform float rotation;

void windowShader(inout vec4 color) {
	float clampedRotation = mod(rotation, 360.0);
	vec3 target = vec3(0);



	if (clampedRotation >= 120.0) {
		color.rgb = color.brg;
	}
	if (clampedRotation >= 240.0) {
		color.rgb = color.brg;
	}

	float progress = mod(clampedRotation, 120.0) / 120.0;
	vec3 difference = vec3(color.r - color.b, color.g - color.r, color.b - color.g);

	vec3 result = color.rgb - (progress * difference);



    color.rgb = result;
}

