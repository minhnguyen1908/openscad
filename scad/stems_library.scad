// --- GLOBALS FROM MX_DES ---
StemBrimDep = 0.25;
Tol = 0.1;
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

function StemTrajectory() = [ trajectory(forward = 5.25) ];
function StemTrajectory2() = [ trajectory(forward = .5) ];

// --- MODULE 1: The 2-Prong (Dynamic Height) ---
module original_2_prong(keyID, draftAng = 5) {
    // We use the function to get the height for the specific key
    stemHeight = KeyHeight(keyID) - topthickness; 
    
    dia = .15;
    wids = 1.2/2;
    lens = 2.9/2; 
    module Stem() {
        difference(){
            translate([0,0,-stemHeight/2])linear_extrude(height = stemHeight)hull(){
                translate([wids-dia,-3/2])circle(d=dia);
                translate([-wids+dia,-3/2])circle(d=dia);
                translate([wids-dia, 3/2])circle(d=dia);
                translate([-wids+dia, 3/2])circle(d=dia);
            }
            translate([3.9,0])cylinder(d1=7+sin(draftAng)*stemHeight, d2=7,3.5, center = true, $fn = 64);
            translate([-3.9,0])cylinder(d1=7+sin(draftAng)*stemHeight,d2=7,3.5, center = true, $fn = 64);
        }
    }
    // We adjust the Z-translation to match the new dynamic height
    translate([5.7/2, 0, -stemHeight/2 + (KeyHeight(keyID) - stemHeight)]) Stem();
    translate([-5.7/2, 0, -stemHeight/2 + (KeyHeight(keyID) - stemHeight)]) Stem();
}

// --- MODULE 2: The Cross-Stem (Dynamic Height) ---
module original_cross_stem(keyID = 1) {
    // 1. Dependency Check
    // We use the EXACT variable name from our debug session
    total_h = KeyHeight(id);
    
    // 2. The Logic: 
    // We make the pillar taller than the keycap (+2.0)
    // Because this module is called inside the difference() block
    // the Dish logic will automatically trim the top perfectly.
    pillar_h = total_h - StemBrimDep + 2.0;
    
    // 3. Trajectory Calculations (Localized to prevent global warnings)
    path1 = quantize_trajectories([ trajectory(forward = 5.25) ], steps = 1);
    curve1 = [ for(i=[0:len(path1)-1]) transform(path1[i], stem_internal()) ];
    
    path2 = quantize_trajectories([ trajectory(forward = 0.5) ], steps = 10);
    curve2 = [ for(i=[0:len(path2)-1]) transform(path2[i]*scaling([(1.1-.1*i/(len(path2)-1)),(1.1-.1*i/(len(path2)-1)),1]), stem_internal()) ];

    // 5. Console Debugging
    echo("--- LOCAL STEM DEBUG ---");
    echo(ACTIVE_ID = id);
    echo(MATRIX_HEIGHT = total_h);
    echo(PILLAR_RENDER_HEIGHT = pillar_h);

    // 6. Execution
    translate([0, 0, StemBrimDep]) {
        difference() {
            // Build the solid pillar
            cylinder(d = 5.5, h = pillar_h, $fn = 32);
            
            // Carve the MX Cross
            translate([0,0,-0.1]) {
                skin(curve1);
                skin(curve2);
            }
        }
    }
}
