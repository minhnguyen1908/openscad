// --- UNIFIED GLOBAL CONSTANTS ---
StemBrimDep  = 0.25;
topthickness = 2.5;
Tol          = 0.1;

// MX Geometry Constants
MXWid = 4.03/2 + Tol;
MXLen = 4.23/2 + Tol;
MXWidT = 1.15/2 + Tol;
MXLenT = 1.25/2 + Tol;

function stem_internal(sc=1) = sc*[ [MXLenT, MXLen],[MXLenT, MXWidT],[MXWid, MXWidT], [MXWid, -MXWidT],[MXLenT, -MXWidT],[MXLenT, -MXLen], [-MXLenT, -MXLen],[-MXLenT, -MXWidT],[-MXWid, -MXWidT], [-MXWid,MXWidT],[-MXLenT, MXWidT],[-MXLenT, MXLen] ];

// --- MASTER STEM DISPATCHER ---
module choc_stem_dispatcher(id, type="cross", draftAng=0) {
    total_h = KeyHeight(id);
    // The Unified Rule: Make it 2mm taller so the dish trims it perfectly
    pillar_h = total_h - StemBrimDep + 2.0; 

    translate([0, 0, StemBrimDep]) {
        difference() {
            // The Unified Solid Pillar
            cylinder(d = 5.5, h = pillar_h, $fn = 32); 
            
            // The Choice of Cutter
            translate([0, 0, -0.1]) { 
                if (type == "cross") {
                    render_cross_cutter();
                } else {
                    render_prong_cutter(draftAng);
                }
            }
        }
    }
}

module render_cross_cutter() {
    path1 = quantize_trajectories([ trajectory(forward = 5.25) ], steps = 1);
    curve1 = [ for(i=[0:len(path1)-1]) transform(path1[i], stem_internal()) ];
    path2 = quantize_trajectories([ trajectory(forward = 0.5) ], steps = 10);
    curve2 = [ for(i=[0:len(path2)-1]) transform(path2[i]*scaling([(1.1-.1*i/(len(path2)-1)),(1.1-.1*i/(len(path2)-1)),1]), stem_internal()) ];
    skin(curve1);
    skin(curve2);
}

module render_prong_cutter(draftAng) {
    // Using your original code's logic for the prong cutouts
    wids = 1.25;
    lens = 3.0;
    translate([5.7/2, 0, 1.7]) cube([wids, lens, 3.4], center=true);
    translate([-5.7/2, 0, 1.7]) cube([wids, lens, 3.4], center=true);
}
