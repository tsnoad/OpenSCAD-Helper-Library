/*
 * OpenSCAD Common Parameters and Modules
 * Licenced under CC BY-SA 4.0
 * By: TSnoad
 * https://github.com/tsnoad/TBC
 * https://hackaday.io/project/TBC
 */

include <../common_params_and_modules.scad>;
$fn = 36;

// Set the camera - so we can automatically render some screenshots
$vpt = [100+5,40,10]/2;
$vpr = [60,0,-15];
$vpd = 300;

//This line will be recognised by the makefile, and will let us render automatically
*/* make 'example_cylinders' */ example();

example();

module example() {
	cylinders();
	translate([0,40,0]) cylinders_cross_section();
}

module cylinders() {
	// Simple cylinder with beveled edges
	cylinder_bev(5,20,bev_m,bev_m);

	difference() {
		cylinder_bev(5+5,10,bev_m,bev_m,list_x_to_vec([20,100]));

		// Through hole with bevelled edges
		translate([20,0,0]) cylinder_bev_co_through(5,10,bev_m,bev_m);

		// Blind hole with bevelled edges
		translate([40,0,10]) cylinder_bev_co_blind_downwards(5,5,bev_m,bev_m);

		// Blind hole - but upwards this time
		translate([60,0,0]) cylinder_bev_co_blind_upwards(5,5,bev_m,bev_m);

		// Through hole with clearance
		translate([80,0,0]) cylinder_bev_co_through(5,10,bev_m,bev_m,clr_close);
	}

	translate([80,0,0]) cylinder_bev(5,10,bev_m,bev_m);

	translate([100,0,10]) cylinder_bev_stud(5,10,bev_m,bev_m);
}


module cylinders_cross_section() {
	intersection() {
		cylinders();
		// intersect with a cube to show a cross section
		color("blue") translate(-[1,0,1]*100) cube([2,2,2]*200);
	}
}