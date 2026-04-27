// --- GLOBAL SOURCE OF TRUTH ---
StemBrimDep = 0.25;
topthickness = 2.5;
Tol          = 0.1;

// MX Geometry (for the Cross-Stem)
MXWid = 4.03/2+Tol;
MXLen = 4.23/2+Tol;
MXWidT = 1.15/2+Tol;
MXLenT = 1.25/2+Tol;

function stem_internal(sc=1) = sc*[
    [MXLenT, MXLen],[MXLenT, MXWidT],[MXWid, MXWidT],
    [MXWid, -MXWidT],[MXLenT, -MXWidT],[MXLenT, -MXLen],
    [-MXLenT, -MXLen],[-MXLenT, -MXWidT],[-MXWid, -MXWidT],
    [-MXWid,MXWidT],[-MXLenT, MXWidT],[-MXLenT, MXLen]
];

// --- UNIFIED STEM BUILDER ---
// This uses ONE mechanism (the pillar) for BOTH types.
module choc_stem_selector(id, type="cross", draftAng=0) {
    total_h = KeyHeight(id);
    // We make the pillar taller than the keycap (+2.0)
    // The Dish in the main file will cut the top off.
    pillar_h = total_h - StemBrimDep + 2.0;

    translate([0, 0, StemBrimDep]) {
        difference() {
            // The Unified Solid Pillar
            cylinder(d = 5.5, h = pillar_h, $fn = 32);
            
            // The "Cutter" based on your old code
            translate([0, 0, -0.1]) { 
                if (type == "cross") {
                    render_cross_math();
                } else {
                    render_prong_math(draftAng);
                }
            }
        }
    }
}

module render_cross_math() {
    path1 = quantize_trajectories([ trajectory(forward = 5.25) ], steps = 1);
    curve1 = [ for(i=[0:len(path1)-1]) transform(path1[i], stem_internal()) ];
    path2 = quantize_trajectories([ trajectory(forward = 0.5) ], steps = 10);
    curve2 = [ for(i=[0:len(path2)-1]) transform(path2[i]*scaling([(1.1-.1*i/(len(path2)-1)),(1.1-.1*i/(len(path2)-1)),1]), stem_internal()) ];
    skin(curve1);
    skin(curve2);
}

module render_prong_math(draftAng) {
    // This is your OLD code's dimensions used as a "cutter"
    wids = 1.2/2;
    lens = 2.9/2;
    translate([5.7/4, 0, 0]) cube([wids*2, lens*2, 10], center=true);
    translate([-5.7/4, 0, 0]) cube([wids*2, lens*2, 10], center=true);
}
