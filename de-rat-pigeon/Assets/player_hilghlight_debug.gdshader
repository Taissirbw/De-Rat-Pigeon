shader_type canvas_item;

uniform bool on_wall = false;
uniform bool coyote_pos = false ;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float r = on_wall ? 1. : 0. ;
	float g = coyote_pos ? 1. : 0.;
	if (r + g == 2.){
	 COLOR.rgb = vec3(0,0 ,1.);
	} else if (r > 0.){
		COLOR.rgb = vec3(1.,0., 0.);
	} else if(g > 0.){
		COLOR.rgb = vec3(0.,1., 0.);
	}

	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
