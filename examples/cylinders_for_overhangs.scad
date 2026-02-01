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
$vpt = [100+5,-10,0]/2;
$vpr = [90+7.5,0,7.5];
$vpd = 300;

//This line will be recognised by the makefile, and will let us render automatically
*/* make 'example_cylinders_for_overhangs' */ example();

example();

module example() {
	cylinders();
}

module cylinders() rotate([90,0,0]) {
	//cylinder with flat walls
	cylinder_oh_bev(5,10,bev_m,bev_m);

	//flat spots are rotated
	translate([20,0,0]) cylinder_oh_bev(5,10,bev_m,bev_m,[[0,0,0]],90);

	//flat spots are only on one side
	translate([40,0,0]) cylinder_oh_bev(5,10,bev_m,bev_m,[[0,0,0]],0,true);

	difference() {
		cylinder_oh_bev(5+5,10,bev_m,bev_m,list_x_to_vec([60,100]),0,true);

		translate([60,0,0]) cylinder_oh_bev_co_through(5,10,bev_m,bev_m);

		translate([80,0,0]) cylinder_oh_bev_co_through(5,10,bev_m,bev_m,0,[[0,0,0]],180,true);

		// Blind hole with bevelled edges
		translate([100,0,10]) cylinder_oh_bev_co_blind_downwards(5,5,bev_m,bev_m);
	}
}