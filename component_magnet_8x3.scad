/*
 * 8mm x 3mm disc magnet
 */

magnet_r = 8/2;
magnet_dep = 3;

magnet_hole_r = magnet_r+clr_loose;

module magnet_neg(extra_dep=0) {
    cylinder_bev_co_blind_downwards(magnet_r+clr_tight,magnet_dep+extra_dep,bev_s,bev_m);
    
    if(extra_dep>0) cylinder_bev_co_blind_downwards(magnet_r+clr_loose,extra_dep+clr_loose-clr_tight,clr_loose-clr_tight,bev_m);
}

module magnet_pos(extra_dep=0) {
    //protrusions to retain magnets with interference fit
    translate([0,0,-extra_dep-magnet_dep]) intersection() {
        for(it=points_reg_polygon_point(3)*(magnet_r-clr_tight-clr_close+2)) cylinder_bev_stud(2,magnet_dep+min(0,extra_dep),bev_s,bev_m,[it]);
        
        cylinder_bev_stud(magnet_r+clr_loose+bev_m,magnet_dep+min(0,extra_dep),0,bev_m);
    }
}