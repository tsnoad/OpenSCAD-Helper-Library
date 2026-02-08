/*
 * OpenSCAD Common Parameters and Modules
 * Licenced under CC BY-SA 4.0
 * By: TSnoad
 * https://github.com/tsnoad/TBC
 * https://hackaday.io/project/TBC
 */

include <../common_params_and_modules.scad>;
$fn = 36;

cylinders_oh();

module cylinders_oh() rotate([90,0,0]) {
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