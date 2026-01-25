/*
 * OpenSCAD Common Parameters and Modules
 * Licenced under CC BY-SA 4.0
 * By: TSnoad
 * https://github.com/tsnoad/TBC
 * https://hackaday.io/project/TBC
 */

/*
 * TBC
 */
 
heatset_hgt = 5;
heatset_r = 5/2;
heatset_tip_r = 4.2/2;

heatset_hole_r = heatset_tip_r+0.1/2;
heatset_hole_hgt = heatset_hgt+1;

module heatset_hole_upwards() rotate_extrude() polygon([
    [0,-0.01],
    [heatset_hole_r+bev_m,-0.01],
    [heatset_hole_r,bev_m],
    [heatset_hole_r-(0.1/4),heatset_hole_hgt/2],
    [heatset_hole_r-(0.1/4),heatset_hole_hgt],
    [heatset_hole_r-(0.1/4)-1.5,heatset_hole_hgt+1.5],
    [0,heatset_hole_hgt+1.5],
]);