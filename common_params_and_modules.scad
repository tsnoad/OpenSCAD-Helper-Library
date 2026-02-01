/*
 * OpenSCAD Common Parameters and Modules
 * Licenced under CC BY-SA 4.0
 * By: TSnoad
 * https://github.com/tsnoad/TBC
 * https://hackaday.io/project/TBC
 */


pi = 3.1415926535897932384626433;

/* Parameters for 3D printer */
// Nozzle diameter
noz_d = 0.4;

// Wall thicknesses
// Use these so that thin walls can be prevented
w1 = 1*noz_d;
w2 = 2*noz_d;
w3 = 3*noz_d;
w4 = 4*noz_d;
w6 = 6*noz_d;

// Layer height
layer_hgt = 0.2;

// Common bevel sizes
bev_m = 0.4;
bev_s = 0.2;

// Clearances
clr_loose = 0.4;
clr_free = 0.25;
clr_close = 0.15;
clr_tight = 0.05;

// Simple XOR function
// xor(true, true) => false
// xor(false, false) => false
// xor(true, false) => true
// Not sure why this isn't
function xor(a,b) = (a && !b) || (!a && b);

//add all of the elements of an array
//ignore the arguments, they're used by the recursive action of the function
//eg: list_sum([1,2,3])==6 => 1+2+3 == 6
function list_sum(v, i = 0, r = 0) = i < len(v) ? list_sum(v, i + 1, r + v[i]) : r;

//slice an array
//eg: list_partial([1,2,3,4],0,2)==[1,2,3]
//eg: list_partial([1,2,3,4],2,3)==[3,4]
//eg: list_partial([1,2,3,4],2)==undef
//eg: list_partial([1,2,3,4],2,len([1,2,3,4]))==[3,4]
function list_partial(list,start,end) = [for (i = [start:end]) list[i]];

//create an array/vector of ones
//eg: ones_array(3) = [1,1,1]
function ones_array(n) = [for(col=[0:n-1])col];

//create an identity matrix of size n
function identity_matrix(n) = [for(row=[0:n-1])[for(col=[0:n-1])(row==col?1:0)]];

// Create a 3x3 identity matrix, but set the (identity multiples?) based on the function arguments
// eg: ident_xyz(-1,1,1) => [[-1,0,0],[0,1,0],[0,0,1]] //can be used to flip an array of vectors in the X-axis
// eg: [10,10,62394]*ident_xyz_xy => [10,10,0] //can be used to filter dimensions out of an array of xyz vectors
// can also be called with a vector as an argument
// eg: ident_xyz([1,1,0]) <=> ident_xyz(1,0,1)
function ident_xyz(arg_x_mult_or_vector=1,arg_y_mult=1,arg_z_mult=1) =
    assert(is_num(arg_x_mult_or_vector) || is_list(arg_x_mult_or_vector), "Invalid argument")
    assert(is_num(arg_y_mult), "Invalid argument")
    assert(is_num(arg_z_mult), "Invalid argument")
      let(
        x_mult = (is_list(arg_x_mult_or_vector) ? arg_x_mult_or_vector[0] : arg_x_mult_or_vector),
        y_mult = (is_list(arg_x_mult_or_vector) ? arg_x_mult_or_vector[1] : arg_y_mult),
        z_mult = (is_list(arg_x_mult_or_vector) ? arg_x_mult_or_vector[2] : arg_z_mult),
      )
      [[1,0,0],[0,0,0],[0,0,0]] * x_mult
    + [[0,0,0],[0,1,0],[0,0,0]] * y_mult
    + [[0,0,0],[0,0,0],[0,0,1]] * z_mult;

// Backwards compatibility
ident2 = identity_matrix(2);
ident3 = identity_matrix(3);
ident4 = identity_matrix(4);
ident_xyz = identity_matrix(3);
ident_xyz_x = ident_xyz(1,0,0);
ident_xyz_y = ident_xyz(0,1,0);
ident_xyz_z = ident_xyz(0,0,1);
ident_xyz_xy = ident_xyz(1,1,0);
ident_xyz_xz = ident_xyz(1,0,1);
ident_xyz_yz = ident_xyz(0,1,1);

// Take a single xyz vector and turn it into an array of vectors
// This is useful for adding a single vector to every vector in another array
// eg: xyz_to_trans([50,50,0])+vec_to_array([50,0,0],4) //shift every point 50 units to the right in the x dimension
function vec_to_array(vector, num) = [for(i=[0:num-1])[1]]*[vector];


//rotate an array of xyz points around the z axis
function rotation_matrix_z(angle) = [[cos(angle),-sin(angle),0],[sin(angle),cos(angle),0],[0,0,1]];

// same, but rotate around the x axis
function rotation_matrix_x(angle) = [[1,0,0],[0,cos(angle),-sin(angle)],[0,sin(angle),cos(angle)]];

// Backwards compatability (also, this is probably the most commonly used)
function rotation_matrix(angle) = rotation_matrix_z(angle);


// For an circular segment of a given chord length and segment width, give us the radius of the circle
function segment_wid_to_radius(chord_len_half,seg_wid) = (pow(seg_wid,2) + pow(chord_len_half,2)) / (2*seg_wid);

// Backwards compatibility - names used in older versions
function arc_radius(chord_len_half,seg_wid) = segment_wid_to_radius(chord_len_half,seg_wid);

// Same as above, but for a circle segment of a given chord length and arc angle
function segment_angle_to_radius(chord_len_half,arc_angle_half) = chord_len_half/sin(arc_angle_half);

// Same as above, but for a circle segment of a given arc angle and segment width
function segment_angle_wid_to_radius(arc_angle_half,seg_wid) = seg_wid / (1 - cos(arc_angle_half));

// The inverse of segment_wid_to_radius - If we know the radius, but want to find the segment width
function segment_radius_to_wid(chord_len_half,radius) = [for(pm=[-1,1]) (2*radius + pm*sqrt(4*pow(radius,2)-4*pow(chord_len_half,2)))/2];


/* Regular polygon arrays */
// These functions can be used to create an array of X-Y vectors in the shape of an n-sided polygon

//create an array of xyz points around the circumference of a regular polygon
//eg points_reg_polygon(6,10) will create an array in the shape of a hexagon where the radius of the points is 10mm
function points_reg_polygon(points,radius=1) = [for(ia=[0:360/points:360-360/points])[sin(ia),cos(ia),0]];

//as above but explicit that the distance/radius is the the points
function points_reg_polygon_point(points,point_dist=1) = points_reg_polygon(points,point_dist);
//as above but explicit that the distance/radius is the the flat sides of the polygon
//eg points_reg_polygon_flat(6,5.5/2) is suitable for an M3 hex nut where the diameter accross the flats is 5.5mm
function points_reg_polygon_flat(points,flat_dist=1) = points_reg_polygon(points,flat_dist)/cos(360/2/points);

// Backwards compatibility - names used in older versions
trans_hex_point = points_reg_polygon_point(6)*rotation_matrix(30);
trans_hex_flat = points_reg_polygon_flat(6)*rotation_matrix(30);
trans_hex = trans_hex_flat;
trans_tri_point = points_reg_polygon_point(3);
trans_tri_flat = points_reg_polygon_flat(3);
trans_sept_point = points_reg_polygon_point(7)*rotation_matrix(360/7/2);
trans_oct_flat = points_reg_polygon_flat(8)*rotation_matrix(360/8/2);


trans_oct_id_x_abs = [[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,0,0]];
trans_oct_id_y_abs = [[0,1,0],[0,1,0],[0,1,0],[0,1,0],[0,1,0],[0,1,0],[0,1,0],[0,1,0]];

function xyz_to_id(xyz=[1,1,1]) = [[xyz[0],0,0],[0,xyz[1],0],[xyz[2],0,0]];

//trans_id = [[1,1,0],[1,-1,0],[-1,-1,0],[-1,1,0]]; //ru,dr,ld,lu
trans_id = [[1,1,0],[-1,1,0],[-1,-1,0],[1,-1,0]]; //ru,lu,ld,rd
trans_id_0 = [[0,0,0],[0,1,0],[1,1,0],[1,0,0]];
trans_id_1 = [[1,1,0],[1,0,0],[0,0,0],[0,1,0]];
outset_id = ident3;

trans_id_x = [[1,0,0],[-1,0,0],[-1,0,0],[1,0,0]];
trans_id_y = [[0,1,0],[0,1,0],[0,-1,0],[0,-1,0]];

trans_id_x_abs = [[1,0,0],[1,0,0],[1,0,0],[1,0,0]];
trans_id_y_abs = [[0,1,0],[0,1,0],[0,1,0],[0,1,0]];

trans_id_xl = [[0,0,0],[1,0,0],[1,0,0],[0,0,0]];
trans_id_xr = [[1,0,0],[0,0,0],[0,0,0],[1,0,0]];
trans_id_yd = [[0,0,0],[0,0,0],[0,1,0],[0,1,0]];
trans_id_yu = [[0,1,0],[0,1,0],[0,0,0],[0,0,0]];


gravity_center      = ident_xyz(  0,  0, 0);
gravity_topright    = ident_xyz(  1,  1, 0);
gravity_top         = ident_xyz(  0,  1, 0);
gravity_topleft     = ident_xyz( -1,  1, 0);
gravity_left        = ident_xyz( -1,  0, 0);
gravity_bottomleft  = ident_xyz( -1, -1, 0);
gravity_bottom      = ident_xyz(  0, -1, 0);
gravity_bottomright = ident_xyz(  1, -1, 0);
gravity_right       = ident_xyz(  1,  0, 0);

/* Rectangle functions */
// Functions that can be used to generate an array of 4 vectors in the shape of a rectangle

function xyz_to_trans(xyz=[1,1,0],gravity=gravity_center) = trans_id*ident_xyz(xyz)+vec_to_array(xyz*gravity,4);

function outset_to_trans(outset=0,gravity=gravity_center) = trans_id*outset_id*outset;

//echo([[-1,0,0],[1,0,0]]);
//echo([[-1],[1]]*[[0,1,0]]);
function list_dim_to_vec(dim_id,list_dim) = [for(i=[0:len(list_dim)-1])[for(dim=[0,1,2])dim_id[dim]*list_dim[i]]];
function list_x_to_vec(list_x) = list_dim_to_vec([1,0,0],list_x);
function list_y_to_vec(list_y) = list_dim_to_vec([0,1,0],list_y);
//echo(list_x_to_vec([-1,1]));
//echo(list_dim_to_vec([1,0,0],[-1,1]));

function xy1xy2_to_trans(xy1xy2=[[1,1,0],[1,1,0]]) = trans_id_xr*max(xy1xy2[0][0],xy1xy2[1][0]) + trans_id_xl*min(xy1xy2[0][0],xy1xy2[1][0]) + trans_id_yu*max(xy1xy2[0][1],xy1xy2[1][1]) + trans_id_yd*min(xy1xy2[0][1],xy1xy2[1][1]);

function outset_xxyy_to_trans(xl=0,xr=0,yd=0,yu=0) = [[xr,yu,0],[-xl,yu,0],[-xl,-yd,0],[xr,-yd,0]];




//create a cylinder with optional (convex) bevels on the top and bottom
module cylinder_bev(rad,hgt,bev_btm=0,bev_top=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,0],
        [rad-bev_btm,0],
        [rad,bev_btm],
        [rad,hgt-bev_top],
        [rad-bev_top,hgt],
        [0,hgt],
    ]);
}


module cylinder_bev_stud(rad,hgt,bev_btm=0,bev_top=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,-0.01],
        [rad+bev_btm,-0.01],
        [rad,bev_btm],
        [0,bev_btm],
    ]);
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,0],
        [rad,0],
        [rad,hgt-bev_top],
        [rad-bev_top,hgt],
        [0,hgt],
    ]);
}

module cylinder_bev_co_through(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,-0.01],
        [rad+clr+bev_btm,-0.01],
        [rad+clr,bev_btm],
        [0,bev_btm],
    ]);
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,0],
        [rad+clr,0],
        [rad+clr,hgt],
        [0,hgt],
    ]);
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,hgt-bev_top],
        [rad+clr,hgt-bev_top],
        [rad+clr+bev_top,hgt+0.01],
        [0,hgt+0.01],
    ]);
}

module cylinder_bev_co_blind(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,0],
        [rad+clr-bev_btm,0],
        [rad+clr,bev_btm],
        [rad+clr,hgt],
        [0,hgt],
    ]);
    hull() for(it=trans_arr) translate(it) rotate_extrude() polygon([
        [0,hgt-bev_top],
        [rad+clr,hgt-bev_top],
        [rad+clr+bev_top,hgt+0.01],
        [0,hgt+0.01],
    ]);
}


module cylinder_bev_co_blind_upwards(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]]) {
    mirror([0,0,1]) translate([0,0,-hgt]) cylinder_bev_co_blind(rad,hgt,bev_top,bev_btm,clr,trans_arr*[[1,0,0],[0,1,0],[0,0,-1]]);
}

module cylinder_bev_co_blind_downwards(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]]) {
    translate([0,0,-hgt]) cylinder_bev_co_blind(rad,hgt,bev_btm,bev_top,clr,trans_arr);
}

module cylinder_bev_rad(rad,hgt,bev_rad_btm=0,bev_rad_top=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            [0,bev_rad_btm],
            [rad,bev_rad_btm],
            [rad,hgt-bev_rad_top],
            [0,hgt-bev_rad_top],
        ]);
        if(bev_rad_btm>0) polygon([for(ia=[0:1/($fn/4):1])[rad-bev_rad_btm,bev_rad_btm]+[sin(ia*90),-cos(ia*90)]*bev_rad_btm]);
        if(bev_rad_top>0) polygon([for(ia=[0:1/($fn/4):1])[rad-bev_rad_top,hgt-bev_rad_top]+[sin(ia*90),cos(ia*90)]*bev_rad_top]);
    }
}

module cylinder_bev_rad_stud(rad,hgt,bev_rad_btm=0,bev_rad_top=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            [0,bev_rad_btm],
            [rad,bev_rad_btm],
            [rad,hgt-bev_rad_top],
            [0,hgt-bev_rad_top],
        ]);
        // if(bev_rad_btm>0) polygon([for(ia=[0:1/($fn/4):1])[rad-bev_rad_btm,bev_rad_btm]+[sin(ia*90),-cos(ia*90)]*bev_rad_btm]);
        if(bev_rad_top>0) polygon([for(ia=[0:1/($fn/4):1])[rad-bev_rad_top,hgt-bev_rad_top]+[sin(ia*90),cos(ia*90)]*bev_rad_top]);
    }

    if(bev_rad_btm>0) for(ia_ext=[0:1/($fn/4):1-1/($fn/4)]) hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            for(ia_int=[ia_ext])[0,bev_rad_btm-0.01]+[0,-cos(ia_int*90)]*bev_rad_btm,
            for(ia_int=[ia_ext])[rad+bev_rad_btm,bev_rad_btm-0.01]+[-sin(ia_int*90),-cos(ia_int*90)]*bev_rad_btm,
            for(ia_int=[ia_ext,ia_ext+1/($fn/4)])[rad+bev_rad_btm,bev_rad_btm]+[-sin(ia_int*90),-cos(ia_int*90)]*bev_rad_btm,
            for(ia_int=[ia_ext+1/($fn/4)])[0,bev_rad_btm]+[0,-cos(ia_int*90)]*bev_rad_btm,
        ]);
    }
}

module cylinder_bev_rad_co_through(rad,hgt,bev_rad_btm=0,bev_rad_top=0,clr=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            [0,bev_rad_btm*0-0.01],
            [rad+clr,bev_rad_btm*0-0.01],
            [rad+clr,hgt-bev_rad_top*0+0.01],
            [0,hgt-bev_rad_top*0+0.01],
        ]);
    }
    if(bev_rad_btm>0) for(ia_ext=[0:1/($fn/4):1-1/($fn/4)]) hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            for(ia_int=[ia_ext])[0,bev_rad_btm-0.01]+[0,-cos(ia_int*90)]*bev_rad_btm,
            for(ia_int=[ia_ext])[rad+clr+bev_rad_btm,bev_rad_btm-0.01]+[-sin(ia_int*90),-cos(ia_int*90)]*bev_rad_btm,
            for(ia_int=[ia_ext,ia_ext+1/($fn/4)])[rad+clr+bev_rad_btm,bev_rad_btm]+[-sin(ia_int*90),-cos(ia_int*90)]*bev_rad_btm,
            for(ia_int=[ia_ext+1/($fn/4)])[0,bev_rad_btm]+[0,-cos(ia_int*90)]*bev_rad_btm,
        ]);
    }
    if(bev_rad_top>0) for(ia_ext=[0:1/($fn/4):1-1/($fn/4)]) hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            for(ia_int=[ia_ext+1/($fn/4)])[0,hgt-bev_rad_top]+[0,cos(ia_int*90)]*bev_rad_top,
            for(ia_int=[ia_ext,ia_ext+1/($fn/4)])[rad+clr+bev_rad_top,hgt-bev_rad_top]+[-sin(ia_int*90),cos(ia_int*90)]*bev_rad_top,
            for(ia_int=[ia_ext])[rad+clr+bev_rad_top,hgt-bev_rad_top+0.01]+[-sin(ia_int*90),cos(ia_int*90)]*bev_rad_top,
            for(ia_int=[ia_ext])[0,hgt-bev_rad_top+0.01]+[0,cos(ia_int*90)]*bev_rad_top,
        ]);
    }
}

module cylinder_bev_rad_co_blind(rad,hgt,bev_rad_btm=0,bev_rad_top=0,clr=0,trans_arr=[[0,0,0]]) {
    hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            [0,bev_rad_btm],
            [rad+clr,bev_rad_btm],
            [rad+clr,hgt-bev_rad_top*0+0.01],
            [0,hgt-bev_rad_top*0+0.01],
        ]);
        if(bev_rad_btm>0) polygon([for(ia=[0:1/($fn/4):1])[rad+clr-bev_rad_btm,bev_rad_btm]+[sin(ia*90),-cos(ia*90)]*bev_rad_btm]);
    }
    
    if(bev_rad_top>0) for(ia_ext=[0:1/($fn/4):1-1/($fn/4)]) hull() for(it=trans_arr) translate(it) rotate_extrude() {
        polygon([
            for(ia_int=[ia_ext+1/($fn/4)])[0,hgt-bev_rad_top]+[0,cos(ia_int*90)]*bev_rad_top,
            for(ia_int=[ia_ext,ia_ext+1/($fn/4)])[rad+clr+bev_rad_top,hgt-bev_rad_top]+[-sin(ia_int*90),cos(ia_int*90)]*bev_rad_top,
            for(ia_int=[ia_ext])[rad+clr+bev_rad_top,hgt-bev_rad_top+0.01]+[-sin(ia_int*90),cos(ia_int*90)]*bev_rad_top,
            for(ia_int=[ia_ext])[0,hgt-bev_rad_top+0.01]+[0,cos(ia_int*90)]*bev_rad_top,
        ]);
    }
}

module cylinder_bev_rad_co_blind_upwards(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]]) {
    mirror([0,0,1]) translate([0,0,-hgt]) cylinder_bev_rad_co_blind(rad,hgt,bev_top,bev_btm,clr,trans_arr*[[1,0,0],[0,1,0],[0,0,-1]]);
}

module cylinder_bev_rad_co_blind_downwards(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]]) {
    translate([0,0,-hgt]) cylinder_bev_rad_co_blind(rad,hgt,bev_btm,bev_top,clr,trans_arr);
}


module cylinder_oh_bev(rad,hgt,bev_btm=0,bev_top=0,trans_arr=[[0,0,0]],oh_rot=0,half_oh=false,oh_angle=45) {
    hull() for(it=trans_arr) translate(it) {
        translate([0,0,bev_btm]) cylinder_oh(rad,hgt-bev_btm-bev_top,oh_rot,half_oh,oh_angle);
        if(bev_btm>0) cylinder_oh(rad-bev_btm,hgt-bev_top,oh_rot,half_oh,oh_angle);
        if(bev_top>0) translate([0,0,bev_btm]) cylinder_oh(rad-bev_top,hgt-bev_btm,oh_rot,half_oh,oh_angle);
    }
    cylinder_bev(rad,hgt,bev_btm,bev_top,trans_arr);
}

module cylinder_oh_bev_co_through(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]],oh_rot=0,half_oh=false,oh_angle=45) {
    hull() for(it=trans_arr) translate(it) cylinder_oh(rad+clr,hgt,oh_rot,half_oh,oh_angle);
    cylinder_bev_co_through(rad,hgt,bev_btm,bev_top,clr,trans_arr);
}

module cylinder_oh_bev_co_blind(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]],oh_rot=0,half_oh=false,oh_angle=45) {
    hull() for(it=trans_arr) translate(it) {
        translate([0,0,bev_btm]) cylinder_oh(rad+clr,hgt-bev_btm,oh_rot,half_oh,oh_angle);
        if(bev_btm>0) cylinder_oh(rad+clr-bev_btm,hgt,oh_rot,half_oh,oh_angle);
    }
    cylinder_bev_co_blind(rad,hgt,bev_btm,bev_top,clr,trans_arr);
}


module cylinder_oh_bev_co_blind_upwards(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]],oh_rot=0,half_oh=false,oh_angle=45) {
    mirror([0,0,1]) translate([0,0,-hgt]) cylinder_oh_bev_co_blind(rad,hgt,bev_top,bev_btm,clr,trans_arr*[[1,0,0],[0,1,0],[0,0,-1]],oh_rot,half_oh,oh_angle);
}

module cylinder_oh_bev_co_blind_downwards(rad,hgt,bev_btm=0,bev_top=0,clr=0,trans_arr=[[0,0,0]],oh_rot=0,half_oh=false,oh_angle=45) {
    translate([0,0,-hgt]) cylinder_oh_bev_co_blind(rad,hgt,bev_btm,bev_top,clr,trans_arr,oh_rot,half_oh,oh_angle);
}

module circle_oh(radius,oh_rot=0,half_oh=false,oh_angle=45) rotate([0,0,oh_rot]) {
    circle(r=radius);
    translate([-radius*tan((90-oh_angle)/2),-radius]) square([2*radius*tan((90-oh_angle)/2),(half_oh?1:2)*radius]);
}

module cylinder_oh(radius,height,oh_rot=0,half_oh=false,oh_angle=45) rotate([0,0,oh_rot]) {
    cylinder(r=radius,h=height);
    translate([-radius*tan((90-oh_angle)/2),-radius,0]) cube([2*radius*tan((90-oh_angle)/2),(half_oh?1:2)*radius,height]);
}


module cylinder_oh_bev_rad(rad,hgt,bev_rad_btm=0,bev_rad_top=0,trans_arr=[[0,0,0]]) {
    cylinder_bev_rad(rad,hgt,bev_rad_btm,bev_rad_top,trans_arr);

    hull() for(it=trans_arr) translate(it) rotate_extrude() {
        if(bev_rad_btm>0) polygon([
            [0,0],
            [rad,0]+[-1+tan(22.5),0]*bev_rad_btm,
            [rad,0]+[-1+sin(45),1-cos(45)]*bev_rad_btm,
            [0,0]+[0,1-cos(45)]*bev_rad_btm,
        ]);
    }
}

module cylinder_oh_bev_rad_co_through(rad,hgt,bev_rad_btm=0,bev_rad_top=0,clr=0,trans_arr=[[0,0,0]]) {
    intersection() {
        cylinder_bev_rad_co_through(rad,hgt,bev_rad_btm,bev_rad_top,clr,trans_arr);
        translate([0,0,(1-cos(45))*bev_rad_btm]) cylinder(r=1000,h=100);
        
        *hull() for(it=trans_arr) translate(it) rotate_extrude() {
            if(bev_rad_btm>0) polygon([
                [0,0],
                [rad,0]+[1-tan(22.5),0]*bev_rad_btm,
                [rad,0]+[1-sin(45),1-cos(45)]*bev_rad_btm,
                [0,0]+[0,1-cos(45)]*bev_rad_btm,
            ]);
        }
    }
    
    hull() for(it=trans_arr) translate(it) rotate_extrude() {
        if(bev_rad_btm>0) polygon([
            [0,0],
            [rad,0]+[1-tan(22.5),0]*bev_rad_btm,
            [rad,0]+[1-sin(45),1-cos(45)]*bev_rad_btm,
            [0,0]+[0,1-cos(45)]*bev_rad_btm,
        ]);
    }
}


function counterbore_points(rad1,rad2) = floor(360/(acos(rad2/rad1)*2));

module counterbore_bev_co(rad1,rad2,hgt1,hgt2,bev_btm=0,bev_top=0,clr=0) {
    oh_polygon_points = counterbore_points(rad1,rad2);
    intersection() {
        union() {
            cylinder_bev_co_blind_upwards(0,hgt1+0.2,bev_btm,0,max(clr,0.01),points_reg_polygon_flat(oh_polygon_points)*rad2);
            cylinder_bev_co_blind_upwards(0,hgt1+0.2+0.2,bev_btm,0,max(clr,0.01),points_reg_polygon_flat(oh_polygon_points*2)*rad2*rotation_matrix(180/(oh_polygon_points*2)));
        }
        cylinder_bev_co_blind_upwards(rad1,hgt1+0.2+0.2,bev_btm,0,max(clr,0.01));
    }
}

module counterbore_bev_co_through(rad1,rad2,hgt1,hgt2,bev_btm=0,bev_top=0,clr=0) {
    cylinder_bev_co_blind_upwards(rad1,hgt1,bev_btm,0,clr);
    cylinder_bev_co_through(rad2,hgt2,bev_btm,bev_top,clr);
    counterbore_bev_co(rad1,rad2,hgt1,hgt2,bev_btm,bev_top,clr);
}

module counterbore_bev_co_blind_upwards(rad1,rad2,hgt1,hgt2,bev_btm=0,bev_top=0,clr=0) {
    cylinder_bev_co_blind_upwards(rad1,hgt1,bev_btm,bev_top,clr);
    counterbore_bev_co(rad1,rad2,hgt1,hgt2,bev_btm,bev_top,clr);
}


/*
 * Round step: create a 2d shape of step with rounded corners
 *
 * step_h0: height (distance from the x axis) of the start of the step
 * step_h1: height (distance from the x axis) of the end of the step (this needs to be greater than step_h0)
 * step_l: length (in the y axis) of the step
 * 
 */
//rotate_extrude() round_step(10,20,25,5,2,$fn=36);
module round_step(step_h0,step_h1,step_l,round_r0,round_r1) {
    t1_hyp = sqrt(pow(step_h1-step_h0-round_r0-round_r1,2)+pow(step_l,2));
    
    if(t1_hyp < (round_r0+round_r1)) {
        echo(str("Error: step length is too short"));
        echo(str("Minimum step length is ", sqrt(pow(round_r0+round_r1,2)-pow(step_h1-step_h0-round_r0-round_r1,2))));
    }
    
    t1_theta = atan2(step_l,(step_h1-step_h0-round_r0-round_r1));
    
    t2_theta = acos((round_r0+round_r1)/t1_hyp);
    
    theta = 180 - (t1_theta + t2_theta);
    
    
    difference() {
        polygon([
            [0,0],
            [step_h0+round_r0,0],
        
            [step_h0+round_r0-round_r0*cos(theta),round_r0*sin(theta)],
    
            [step_h1-round_r1+round_r1*cos(theta),step_l-round_r1*sin(theta)],
        
            [step_h1-round_r1,step_l],
            [0,step_l],
        ]);
        translate([step_h0+round_r0,0]) circle(r=round_r0);
    }
    translate([step_h1-round_r1,step_l]) circle(r=round_r1);
}



module round_step_center_h1(step_h0,step_h1,step_l_in,round_r0,round_r1) {
    step_l = round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1);

    translate([0,-step_l]) round_step(step_h0,step_h1,step_l_in,round_r0,round_r1);
}

function round_step_angle(step_h0,step_h1,step_l_in,round_r0,round_r1) = let(
    step_l = round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1),
    t1_hyp = sqrt(pow(step_h1-step_h0-round_r0-round_r1,2)+pow(step_l,2)),
    t1_theta = atan2(step_l,(step_h1-step_h0-round_r0-round_r1)),
    t2_theta = acos((round_r0+round_r1)/t1_hyp),
    theta = 180 - (t1_theta + t2_theta),
) theta;

function round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1) = (step_l_in==0?max(round_r0+round_r1,sqrt(pow(round_r0+round_r1,2)-pow(step_h1-step_h0-round_r0-round_r1,2))):step_l_in);

module round_step_3d(step_h0,step_h1,step_l_in,round_r0,round_r1,hgt,bev_btm=0,bev_top=0) {
    step_l = round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1);

    t1_hyp = sqrt(pow(step_h1-step_h0-round_r0-round_r1,2)+pow(step_l,2));
    
    if(t1_hyp < (round_r0+round_r1)) {
        echo(str("Error: step length is too short"));
        echo(str("Minimum step length is ", sqrt(pow(round_r0+round_r1,2)-pow(step_h1-step_h0-round_r0-round_r1,2))));
    }
    
    t1_theta = atan2(step_l,(step_h1-step_h0-round_r0-round_r1));
    
    t2_theta = acos((round_r0+round_r1)/t1_hyp);
    
    theta = 180 - (t1_theta + t2_theta);
    
    difference() {
        linear_extrude(height=hgt) polygon([
            [0,0],
            [step_h0+round_r0,0],
        
            [step_h0+round_r0-2*round_r0*cos(theta),2*round_r0*sin(theta)],
            
            [0,2*round_r0*sin(theta)],
        ]);
        translate([step_h0+round_r0,0,0]) cylinder_bev_co_through(round_r0,hgt,bev_btm,bev_top);
    }
    translate([step_h1-round_r1,step_l,0]) cylinder_bev(round_r1,hgt,bev_btm,bev_top,[[0,0,0],-[sin(theta),cos(theta),0]*t1_hyp,-[sin(theta),0,0]*t1_hyp]);
}

module round_step_3d_co_through(step_h0,step_h1,step_l_in,round_r0,round_r1,hgt,bev_btm=0,bev_top=0) {
    step_l = round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1);

    t1_hyp = sqrt(pow(step_h1-step_h0-round_r0-round_r1,2)+pow(step_l,2));
    
    if(t1_hyp < (round_r0+round_r1)) {
        echo(str("Error: step length is too short"));
        echo(str("Minimum step length is ", sqrt(pow(round_r0+round_r1,2)-pow(step_h1-step_h0-round_r0-round_r1,2))));
    }
    
    t1_theta = atan2(step_l,(step_h1-step_h0-round_r0-round_r1));
    
    t2_theta = acos((round_r0+round_r1)/t1_hyp);
    
    theta = 180 - (t1_theta + t2_theta);
    
    difference() {
        linear_extrude(height=hgt) polygon([
            [0,0],
            [step_h0+round_r0,0],
        
            [step_h0+round_r0-2*round_r0*cos(theta),2*round_r0*sin(theta)],
            
            [0,2*round_r0*sin(theta)],
        ]);
        translate([step_h0+round_r0,0,0]) cylinder_bev(round_r0,hgt,bev_btm,bev_top);
    }
    translate([step_h1-round_r1,step_l,0]) cylinder_bev_co_through(round_r1,hgt,bev_btm,bev_top,0,[[0,0,0],-[sin(theta),cos(theta),0]*t1_hyp,-[sin(theta),0,0]*t1_hyp]);
}

module round_step_3d_co_blind_downwards(step_h0,step_h1,step_l_in,round_r0,round_r1,hgt,bev_btm=0,bev_top=0) {
    step_l = round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1);

    t1_hyp = sqrt(pow(step_h1-step_h0-round_r0-round_r1,2)+pow(step_l,2));
    
    if(t1_hyp < (round_r0+round_r1)) {
        echo(str("Error: step length is too short"));
        echo(str("Minimum step length is ", sqrt(pow(round_r0+round_r1,2)-pow(step_h1-step_h0-round_r0-round_r1,2))));
    }
    
    t1_theta = atan2(step_l,(step_h1-step_h0-round_r0-round_r1));
    
    t2_theta = acos((round_r0+round_r1)/t1_hyp);
    
    theta = 180 - (t1_theta + t2_theta);
    
    translate([0,0,-hgt]) difference() {
        linear_extrude(height=hgt) polygon([
            [0,0],
            [step_h0+round_r0,0],
        
            [step_h0+round_r0-2*round_r0*cos(theta),2*round_r0*sin(theta)],
            
            [0,2*round_r0*sin(theta)],
        ]);
        translate([step_h0+round_r0,0,0]) cylinder_bev_co_blind_upwards(round_r0,hgt,bev_btm,bev_top);
    }
    translate([step_h1-round_r1,step_l,0]) cylinder_bev_co_blind_downwards(round_r1,hgt,bev_btm,bev_top,0,[[0,0,0],-[sin(theta),cos(theta),0]*t1_hyp,-[sin(theta),0,0]*t1_hyp]);
}

module round_step_3d_center_h1(step_h0,step_h1,step_l_in,round_r0,round_r1,hgt,bev_btm=0,bev_top=0) {

    step_l = round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1);

    translate([0,-step_l,0]) round_step_3d(step_h0,step_h1,step_l_in,round_r0,round_r1,hgt,bev_btm,bev_top);
}


module round_step_area(step_h0,step_h1,step_l0,step_l_in,round_r0,round_r1,trans_arr=[[0,0,0]]) {
    step_l = round_step_len(step_h0,step_h1,step_l_in,round_r0,round_r1);

    t1_hyp = sqrt(pow(step_h1-step_h0-round_r0-round_r1,2)+pow(step_l,2));
    
    if(t1_hyp < (round_r0+round_r1)) {
        echo(str("Error: step length is too short"));
        echo(str("Minimum step length is ", sqrt(pow(round_r0+round_r1,2)-pow(step_h1-step_h0-round_r0-round_r1,2))));
    }
    
    /*t1_theta = atan2(step_l,(step_h1-step_h0-round_r0-round_r1));
    
    t2_theta = acos((round_r0+round_r1)/t1_hyp);
    
    theta = 180 - (t1_theta + t2_theta);*/
    theta = round_step_angle(step_h0,step_h1,step_l_in,round_r0,round_r1);
    
    //echo(theta);
    
    for(ia_ext=[0:1/($fn/4):1-1/($fn/4)]) {
        hull() for(it=trans_arr) translate(it) for(ia_int=[ia_ext,ia_ext+1/($fn/4)]) {
            cylinder(r=step_l0+step_l-round_r0*(sin(ia_int*theta)),h=step_h0+round_r0*(1-cos(ia_int*theta)));
        }
        hull() for(it=trans_arr) translate(it) {
            cylinder(r=step_l0+step_l-round_r0*(sin(theta)),h=step_h0+round_r0*(1-cos(theta)));
            cylinder(r=step_l0+round_r1*(sin(theta)),h=step_h1-round_r1*(1-cos(theta)));
        }
        hull() for(it=trans_arr) translate(it) for(ia_int=[ia_ext,ia_ext+1/($fn/4)]) {
            cylinder(r=step_l0+round_r1*(sin(ia_int*theta)),h=step_h1-round_r1*(1-cos(ia_int*theta)));
        }
    }
}

module trigrid_co_through(trigrid_r=1,trigrid_hh=10,extent=100,trigrid_co_h=10,bev_btm=0,bev_top=0) {
    trigrid_wh = trigrid_hh*tan(30);
    trigrid_ext = round(extent*1.5/(2*trigrid_wh));
    
    for(ix=[-trigrid_ext:trigrid_ext]) for(iy=[-trigrid_ext:trigrid_ext]) translate([ix*2*trigrid_wh,iy*2*trigrid_hh,0]) {
        mirror([0,(floor(abs(ix)/2)*2==abs(ix)?0:1),0]) mirror([0,(floor(abs(iy)/2)*2==abs(iy)?0:1),0]) {
            //cutout each triangle in the grid
            translate([0,2*trigrid_wh/tan(60)-trigrid_hh,0]) {
                cylinder_bev_co_through(trigrid_r,trigrid_co_h,bev_btm,bev_top,0,points_reg_polygon_point(3)*(2*trigrid_wh/cos(30)-(w6/2+trigrid_r)/sin(30)));
            }
        }
    }
}

module hexgrid_co_through(hexgrid_r=1,hexgrid_flat_r=10,extent=100,hexgrid_co_h=10,bev_btm=0,bev_top=0) {
    hexgrid_point_r = hexgrid_flat_r*cos(180/6);
    hexgrid_ext = round(extent*1.5/(2*hexgrid_flat_r));

    for(ix=[-hexgrid_ext:hexgrid_ext]) for(iy=[-hexgrid_ext:hexgrid_ext]) translate([ix*2*hexgrid_flat_r + (iy % 2 == 0 ? 0 : hexgrid_flat_r),iy*2*hexgrid_point_r,0]) {
        cylinder_bev_co_through(hexgrid_r,hexgrid_co_h,bev_btm,bev_top,0,points_reg_polygon_flat(6)*(hexgrid_flat_r-hexgrid_r-w6/2));
    }
}