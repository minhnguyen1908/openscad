// --- Library Imports: These bring in external tools like 'skin' and 'transform' ---
use <scad-utils/morphology.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <sweep.scad>
use <skin.scad>

// --- Global Variables: Basic settings for the entire project ---
layers = 40; // Number of vertical slices used to build the 3D shape
fn = 32; // Resolution of the curves (higher = smoother)
step = 2; // Resolution of the ellipse curves for the dish
stepsize = 50; // Resolution of the trajectory path
keyID = 1; // The index used to select specific key parameters

wallthickness = 1.2; // Slightly thicker side walls for durability
topthickness = 2.2; // Ceiling thickness (Roof)

// --- Helper Functions for Shapes ---

function sign_x(i, n) =
  i < n / 4 || i > n - n / 4 ? 1
  : i > n / 4 && i < n - n / 4 ? -1
  : 0;

function sign_y(i, n) =
  i > 0 && i < n / 2 ? 1
  : i > n / 2 ? -1
  : 0;

function elliptical_rectangle(a = [1, 1], b = [1, 1], fn = 32) =
  [
    for (index = [0:fn - 1]) let (theta1 = -atan(a[1] / b[1]) + 2 * atan(a[1] / b[1]) * index / fn) [b[1] * cos(theta1), a[1] * sin(theta1)] + [a[0] * cos(atan(b[0] / a[0])), 0] - [b[1] * cos(atan(a[1] / b[1])), 0],
    for (index = [0:fn - 1]) let (theta2 = atan(b[0] / a[0]) + (180 - 2 * atan(b[0] / a[0])) * index / fn) [a[0] * cos(theta2), b[0] * sin(theta2)] - [0, b[0] * sin(atan(b[0] / a[0]))] + [0, a[1] * sin(atan(a[1] / b[1]))],
    for (index = [0:fn - 1]) let (theta2 = -atan(a[1] / b[1]) + 180 + 2 * atan(a[1] / b[1]) * index / fn) [b[1] * cos(theta2), a[1] * sin(theta2)] - [a[0] * cos(atan(b[0] / a[0])), 0] + [b[1] * cos(atan(a[1] / b[1])), 0],
    for (index = [0:fn - 1]) let (theta2 = atan(b[0] / a[0]) + 180 + (180 - 2 * atan(b[0] / a[0])) * index / fn) [a[0] * cos(theta2), b[0] * sin(theta2)] + [0, b[0] * sin(atan(b[0] / a[0]))] - [0, a[1] * sin(atan(a[1] / b[1]))],
  ] / 2;

function ellipse(a, b, d = 0, rot1 = 0, rot2 = 360) =
  [for (t = [rot1:step:rot2]) [a * cos(t) + a, b * sin(t) * (1 + d * cos(t))]];

function DishShape(a, b, c, d) =
  concat(ellipse(a, b, d=0, rot1=90, rot2=270));

// --- Keycap Profile Functions ---

function BottomWidth(keyID) = 17.20;
function BottomLength(keyID) = 16.00;
function TopWidthDiff(keyID) = 5.6;
function TopLenDiff(keyID) = 5;
function KeyHeight(keyID) = 4.5;

function TopWidShift(keyID) = 0;
function TopLenShift(keyID) = 0;

function XAngleSkew(keyID) = 5;
function YAngleSkew(keyID) = 0;
function ZAngleSkew(keyID) = 0;

function WidExponent(keyID) = 2;
function LenExponent(keyID) = 2;
function ChamExponent(keyID) = 2;

function CapRound0i(keyID) = 0.10;
function CapRound0f(keyID) = 3.0;
function CapRound1i(keyID) = 0.10;
function CapRound1f(keyID) = 3.0;

// --- Dish Parameters ---
function DishDepth(keyID) = 1.0;
function DishHeightDif(keyID) = 0.5;
function DishForward(keyID) = 10;
function DishPitch(keyID) = 2;
function DishInitArc(keyID) = 5.5;
function DishFinArc(keyID) = 1.5;
function DishArcExpo(keyID) = 2.5;

// --- Build Logic ---

// Shared arc function for both halves
function local_DishArc(t, total) = pow((t) / (total), DishArcExpo(keyID)) * DishFinArc(keyID) + (1 - pow(t / (total), DishArcExpo(keyID))) * DishInitArc(keyID);

// Unified Trajectory Logic: We build one perfect half and use geometric symmetry
traj = [trajectory(forward=DishForward(keyID), pitch=DishPitch(keyID))];
path = quantize_trajectories(traj, steps=stepsize, loop=false);
DishCurve = [for (i = [0:len(path) - 1]) transform(path[i], DishShape(DishDepth(keyID), local_DishArc(i, len(path) - 1), 1, d=0))];

// --- Final Build ---

difference() {
  union() {
    difference() {
      // 1. THE OUTER SHELL
      skin([for (i = [0:layers - 1]) transform(translation(CapTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(CapTransform(i, keyID), b=CapRoundness(i, keyID), fn=fn))]);

      // 2. THE INNER VOID
      translate([0, 0, -0.001]) skin([for (i = [0:layers - 1]) transform(translation(InnerTranslation(i, keyID)) * rotation(CapRotation(i, keyID)), elliptical_rectangle(InnerTransform(i, keyID), b=CapRoundness(i, keyID), fn=fn))]);
    }
  }

  // --- FINAL STRUCTURAL SCOOP SYNC ---
  // We group both halves inside the same tilt transformation to prevent drifting.
  translate([-TopWidShift(keyID), -TopLenShift(keyID), KeyHeight(keyID) - DishHeightDif(keyID)])
    rotate([0, -YAngleSkew(keyID), 0])
      rotate([0, -90 + XAngleSkew(keyID), 90 - ZAngleSkew(keyID)]) {
        // Front scoop
        skin(DishCurve);

        // Back scoop: Geometric mirror avoids library direction bugs
        mirror([0, 1, 0]) skin(DishCurve);
      }

  // DEBUG CROSS-SECTION
  translate([0, -25, -.1]) cube([15, 50, 15]);
}

// Helper Functions for Transformations
function CapTranslation(t, k) = [( (1 - t) / layers * TopWidShift(k)), ( (1 - t) / layers * TopLenShift(k)), (t / layers * KeyHeight(k))];
function InnerTranslation(t, k) = [( (1 - t) / layers * TopWidShift(k)), ( (1 - t) / layers * TopLenShift(k)), (t / layers * (KeyHeight(k) - topthickness))];
function CapRotation(t, k) = [( (1 - t) / layers * XAngleSkew(k)), ( (1 - t) / layers * YAngleSkew(k)), ( (1 - t) / layers * ZAngleSkew(k))];
function CapTransform(t, k) = [pow(t / layers, WidExponent(k)) * (BottomWidth(k) - TopWidthDiff(k)) + (1 - pow(t / layers, WidExponent(k))) * BottomWidth(k), pow(t / layers, LenExponent(k)) * (BottomLength(k) - TopLenDiff(k)) + (1 - pow(t / layers, LenExponent(k))) * BottomLength(k)];
function InnerTransform(t, k) = [pow(t / layers, WidExponent(k)) * (BottomWidth(k) - TopWidthDiff(k) - wallthickness * 2) + (1 - pow(t / layers, WidExponent(k))) * (BottomWidth(k) - wallthickness * 2), pow(t / layers, LenExponent(k)) * (BottomLength(k) - TopLenDiff(k) - wallthickness * 2) + (1 - pow(t / layers, LenExponent(k))) * (BottomLength(k) - wallthickness * 2)];
function CapRoundness(t, k) = [pow(t / layers, ChamExponent(k)) * (CapRound0f(k)) + (1 - pow(t / layers, ChamExponent(k))) * CapRound0i(k), pow(t / layers, ChamExponent(k)) * (CapRound1f(k)) + (1 - pow(t / layers, ChamExponent(k))) * CapRound1i(k)];
