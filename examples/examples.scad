/*
 * OpenSCAD Common Parameters and Modules
 * Licenced under CC BY-SA 4.0
 * By: TSnoad
 * https://github.com/tsnoad/TBC
 * https://hackaday.io/project/TBC
 */

$fn = 36;

// Set the camera - so we can automatically render some screenshots
$vpt = [0,0,0];
$vpr = [60,0,-15];
$vpd = 300;

use <cylinders.scad>;
use <cylinders_for_overhangs.scad>;

//This line will be recognised by the makefile, and will let us render automatically
*/* make image 'example_cylinders' */ translate(-[100+5,40,10]/2) {
	cylinders();
	translate([0,40,0]) cylinders_cross_section();
}

*/* make image 'example_cylinders_for_overhangs' */ translate(-[100+5,-10,10]/2) {

// $vpt = [100+5,-10,0]/2;
// $vpr = [90+7.5,0,7.5];

	cylinders_oh();
}
