// --- Chicago Steno Keycap: Library-Free Rebuild with MX Stem ---
// Rebuilt for stability, correct geometric orientation, and home-row indicators.
// Optimized with original Chicago Steno "heritage" dimensions.

// --- Global Settings ---
fn = 64; // Smoothness of curves
keyID = 1;

// HOMING INDICATOR TOGGLE:
has_homing_line = true;

// --- Row Profile Selection ---
// R1: Top | R2: Num | R3: Home | R4: Bottom | R5: Thumb
profile_row = 3;

// ADJUSTED HEIGHTS BASED ON REPOSITORY DNA:
function get_row_height(row) =
  row == 1 ? 9.0
  : row == 2 ? 7.5
  : row == 3 ? 5.0
  : // Balanced for 3mm stem + 2mm roof
  row == 4 ? 4.5
  : 4.5;

function get_row_skew(row) =
  row == 1 ? -10
  : row == 2 ? -5
  : row == 3 ? 0
  : row == 4 ? 5
  : 10;

// --- Profile Dimensions (Chicago Steno Standards) ---
bottom_w = 17.20;
bottom_l = 16.00;
top_w_diff = 5.6; // Original steeper taper
top_l_diff = 5.0; // Original steeper taper
key_h = get_row_height(profile_row);

wall_thickness = 1.2;
top_thickness = 2.0; // Increased for original "thick roof" feel

// --- Interaction Parameters ---
x_skew = get_row_skew(profile_row);
y_skew = 0;

// --- Dish (Scoop) Parameters ---
// Focused dimensions to match original finger-well feel
dish_depth = 1.1;
dish_width = 11.5;
dish_length = 10.5;

// --- Homing Indicator Parameters ---
homing_line_w = 3.5;
homing_line_h = 0.4;
homing_line_l = 0.8;

// --- MX Stem Dimensions (Choc V2 Compatible) ---
stem_h = 3.0; // FIXED at 3.0mm
cross_depth = 2.8;
v_bar_w = 1.1;
h_bar_w = 1.3;
cross_l = 4.0;

// --- Helper Modules ---
module rounded_rect(w, l, r) {
  offset(r=r) square([w - 2 * r, l - 2 * r], center=true);
}

module mx_stem_cutout() {
  union() {
    translate([0, 0, cross_depth / 2 - 0.1])
      cube([cross_l + 0.1, v_bar_w, cross_depth + 0.2], center=true);
    translate([0, 0, cross_depth / 2 - 0.1])
      cube([h_bar_w, cross_l + 0.1, cross_depth + 0.2], center=true);
  }
}

module homing_line() {
  translate([0, -2.5, -0.15])
    hull() {
      translate([-homing_line_w / 2, 0, 0]) sphere(d=homing_line_l, $fn=12);
      translate([homing_line_w / 2, 0, 0]) sphere(d=homing_line_l, $fn=12);
    }
}

module dish_cutter() {
  hull() {
    translate([-dish_width / 2 + 2, -dish_length / 2 + 2, 0]) sphere(r=10, $fn=fn);
    translate([dish_width / 2 - 2, -dish_length / 2 + 2, 0]) sphere(r=10, $fn=fn);
    translate([-dish_width / 2 + 2, dish_length / 2 - 2, 0]) sphere(r=10, $fn=fn);
    translate([dish_width / 2 - 2, dish_length / 2 - 2, 0]) sphere(r=10, $fn=fn);
  }
}

// --- Main Build ---
difference() {
  union() {
    // 1. THE KEYCAP BODY
    color("Gold")
      difference() {
        hull() {
          translate([0, 0, 0.1]) linear_extrude(height=0.1) rounded_rect(bottom_w, bottom_l, 3);
          translate([0, 0, key_h]) rotate([x_skew, y_skew, 0]) linear_extrude(height=0.1) rounded_rect(bottom_w - top_w_diff, bottom_l - top_l_diff, 2);
        }

        translate([0, 0, -0.1])
          hull() {
            translate([0, 0, 0.1]) linear_extrude(height=0.1) rounded_rect(bottom_w - wall_thickness * 2, bottom_l - wall_thickness * 2, 2.5);
            translate([0, 0, stem_h]) rotate([x_skew, y_skew, 0]) linear_extrude(height=0.1) rounded_rect(bottom_w - top_w_diff - wall_thickness * 2, bottom_l - top_l_diff - wall_thickness * 2, 1.5);
          }

        translate([0, 0, key_h + 10 - dish_depth])
          rotate([x_skew, y_skew, 0])
            dish_cutter();
      }

    if (has_homing_line) {
      color("Red")
        translate([0, 0, key_h - dish_depth])
          rotate([x_skew, y_skew, 0])
            homing_line();
    }

    color("Silver")
      difference() {
        intersection() {
          hull() {
            translate([0, 0, 0.1]) linear_extrude(height=0.1) rounded_rect(bottom_w, bottom_l, 3);
            translate([0, 0, stem_h]) rotate([x_skew, y_skew, 0]) linear_extrude(height=0.1) rounded_rect(bottom_w - top_w_diff, bottom_l - top_l_diff, 2);
          }
          cylinder(d=5.5, h=stem_h + 0.1, center=false, $fn=fn);
        }
        mx_stem_cutout();
      }
  }

  // --- DEBUG: HAFT CUT ---
  // translate([0, -25, -1]) cube([20, 50, 20]);
}
