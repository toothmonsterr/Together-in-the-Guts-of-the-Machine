//based on https://godotshaders.com/shader/crt-shader-2/
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float fisheye_strength = 1.0; // Adjust this to control the fisheye effect strength
uniform float speed = 1.0;
uniform float disortion = 0.7;
uniform float redStrength = 0.8;
uniform float RedSeperationX = 1;
uniform float RedSeperationY = 1.5;
uniform float greenStrength = 0.5;
uniform float GreenSeperationX = 0;
uniform float GreenSeperationY = 2;
uniform float blueStrength = 0.8;
uniform float BlueSeperationX = 2;
uniform float BlueSeperationY = 0;

vec2 fisheye(vec2 uv) {
    vec2 d = uv - 0.5;
    float r = length(d);
    float theta = atan(d.y, d.x);
    float rf = pow(r, fisheye_strength) / pow(0.5, fisheye_strength - 1.0);
    return vec2(0.5) + rf * normalize(d);
}

vec2 curve(vec2 uv)
{
	//Fisheye effect applied here
	//uv = (uv - 0.5) * 2.0;
	//uv *= 1.1;
	//uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	//uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	//uv  = (uv / 2.0) + 0.5;
	//uv =  uv *0.92 + 0.04;
	return uv;
}

void fragment() {
    vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 q = FRAGCOORD.xy / iResolution.xy;

    // Apply fisheye distortion
    q = fisheye(q);

    vec2 uv = curve(q);
    uv = curve( uv );
    vec3 oricol = texture( screen_texture, vec2(q.x,q.y) ).xyz;
    vec3 col;
	float x =  sin((0.3*speed)*TIME+uv.y*21.0)*sin((0.7*speed)*TIME+uv.y*29.0)*sin((0.3*speed)+0.33*TIME+uv.y*31.0)*(disortion*0.001);

    col.r = texture(screen_texture,vec2(x+uv.x+(RedSeperationX * 0.001),uv.y+(RedSeperationY * 0.001))).x+0.05;
    col.g = texture(screen_texture,vec2(x+uv.x+(GreenSeperationX*0.001),uv.y-(GreenSeperationY*0.001))).y+0.05;
    col.b = texture(screen_texture,vec2(x+uv.x-(BlueSeperationX*0.001),uv.y+(BlueSeperationY*0.001))).z+0.05;
    col.r += (redStrength*0.1)*texture(screen_texture,0.75*vec2(x+0.025, -0.027)+vec2(uv.x+0.001,uv.y+0.001)).x;
    col.g += (greenStrength*0.1)*texture(screen_texture,0.75*vec2(x+-0.022, -0.02)+vec2(uv.x+0.000,uv.y-0.002)).y;
    col.b += (blueStrength*0.1)*texture(screen_texture,0.75*vec2(x+-0.02, -0.018)+vec2(uv.x-0.002,uv.y+0.000)).z;

    col = clamp(col*0.6+0.4*col*col*1.0,0.0,1.0);

    float vig = (0.0 + 1.0*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y));
	col *= vec3(pow(vig,0.3));

    col *= vec3(0.95,1.05,0.95);
	col *= 2.8;

	float scans = clamp( 0.35+0.35*sin((3.5*speed)*TIME+uv.y*iResolution.y*1.5), 0.0, 1.0);

	float s = pow(scans,1.7);
	col = col*vec3( 0.4+0.7*s) ;

    col *= 1.0+0.01*sin(110.0*TIME);
	if (uv.x < 0.0 || uv.x > 1.0)
		col *= 0.0;
	if (uv.y < 0.0 || uv.y > 1.0)
		col *= 0.0;

	col*=1.0-0.65*vec3(clamp((mod(FRAGCOORD.x, 2.0)-1.0)*2.0,0.0,1.0));

    float comp = smoothstep( 0.1, 0.9, sin(TIME) );


    COLOR = vec4(col,1.0);
}