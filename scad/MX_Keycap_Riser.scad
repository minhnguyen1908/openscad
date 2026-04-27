$fn = 100;
only_Spacer = false;
Socket_Diameter_mm = 5.5;
Socket_Height_mm = 3.0;
Socket_Clearance_mm = 0.08;
Riser_Height_mm = 0;
Angle_Degrees = 15;
Tilt_Rotation_Degrees = 0;
Pin_Height_mm = 3.0;
Pin_Clearance_mm = 0.02;
Pin_Rotation_Degrees = 0;

module female_cross(clearance) {
  difference() {
    union() {
      // Horizontal arm
      translate([-4 / 2 - clearance, -1.1 / 2 - clearance])
        square([4 + 2 * clearance, 1.1 + 2 * clearance]);
      // Vertical arm
      translate([-1.3 / 2 - clearance, -4 / 2 - clearance])
        square([1.3 + 2 * clearance, 4 + 2 * clearance]);
      // add rounded corners
      translate(
        [
          1.3 / 2 + clearance,
          1.1 / 2 + clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          1.3 / 2 + clearance,
          -1.1 / 2 - clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          -1.3 / 2 - clearance,
          1.1 / 2 + clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          -1.3 / 2 - clearance,
          -1.1 / 2 - clearance,
        ]
      ) circle(r=0.3);
    }
    ;
    // remove rounded corners
    translate(
      [
        1.3 / 2 + 0.3 + clearance,
        1.1 / 2 + 0.3 + clearance,
      ]
    ) circle(r=0.3);
    translate(
      [
        1.3 / 2 + 0.3 + clearance,
        -1.1 / 2 - 0.3 - clearance,
      ]
    ) circle(r=0.3);
    translate(
      [
        -1.3 / 2 - 0.3 - clearance,
        1.1 / 2 + 0.3 + clearance,
      ]
    ) circle(r=0.3);
    translate(
      [
        -1.3 / 2 - 0.3 - clearance,
        -1.1 / 2 - 0.3 - clearance,
      ]
    ) circle(r=0.3);
  }
  ;
}

module male_cross(clearance) {
  difference() {
    union() {
      // Horizontal arm
      translate(
        [
          -4 / 2 + clearance + 0.3,
          -1.1 / 2 + clearance,
        ]
      ) square(
          [
            4 - 2 * clearance - 2 * 0.3,
            1.1 - 2 * clearance,
          ]
        );
      translate(
        [
          -4 / 2 + clearance,
          -1.1 / 2 + clearance + 0.3,
        ]
      ) square(
          [
            4 - 2 * clearance,
            1.1 - 2 * clearance - 2 * 0.3,
          ]
        );
      // Vertical arm
      translate(
        [
          -1.3 / 2 + clearance,
          -4 / 2 + clearance + 0.3,
        ]
      ) square(
          [
            1.3 - 2 * clearance,
            4 - 2 * clearance - 2 * 0.3,
          ]
        );
      translate(
        [
          -1.3 / 2 + clearance + 0.3,
          -4 / 2 + clearance,
        ]
      ) square(
          [
            1.3 - 2 * clearance - 2 * 0.3,
            4 - 2 * clearance,
          ]
        );
      // rounded corners
      translate(
        [
          1.3 / 2 - 0.3 - clearance,
          4 / 2 - 0.3 - clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          -1.3 / 2 + 0.3 + clearance,
          4 / 2 - 0.3 - clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          1.3 / 2 - 0.3 - clearance,
          -4 / 2 + 0.3 + clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          -1.3 / 2 + 0.3 + clearance,
          -4 / 2 + 0.3 + clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          4 / 2 - 0.3 - clearance,
          1.1 / 2 - 0.3 - clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          4 / 2 - 0.3 - clearance,
          -1.1 / 2 + 0.3 + clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          -4 / 2 + 0.3 + clearance,
          1.1 / 2 - 0.3 - clearance,
        ]
      ) circle(r=0.3);
      translate(
        [
          -4 / 2 + 0.3 + clearance,
          -1.1 / 2 + 0.3 + clearance,
        ]
      ) circle(r=0.3);
    }
    ;
  }
  ;
}

module female_connector() {
  linear_extrude(height=Socket_Height_mm) {
    difference() {
      circle(r=Socket_Diameter_mm / 2);
      female_cross(Socket_Clearance_mm);
    }
    ;
  }
  ;
}

module male_connector() {
  linear_extrude(height=Pin_Height_mm) {
    male_cross(Pin_Clearance_mm);
  }
  ;
}

module tilt(degrees) {
  translate([-Socket_Diameter_mm / 2, 0, 0]) {
    rotate([90, 0, 0]) {
      rotate_extrude(angle=degrees) {
        translate([Socket_Diameter_mm / 2, 0])
          circle(d=Socket_Diameter_mm);
      }
      ;
    }
    ;
  }
  ;
}

module riser() {
  translate([0, 0, Socket_Height_mm]) {
    linear_extrude(height=Riser_Height_mm) {
      circle(d=Socket_Diameter_mm);
    }
    ;
  }
  ;
}

female_connector();
if (!only_Spacer) {
  rotate([0, 0, Tilt_Rotation_Degrees]) {
    riser();
    translate([0, 0, Socket_Height_mm + Riser_Height_mm]) {
      tilt(Angle_Degrees);
    }
    ;
    translate([-Socket_Diameter_mm / 2, 0, Socket_Height_mm + Riser_Height_mm]) {
      rotate([0, -Angle_Degrees, 0]) {
        translate([Socket_Diameter_mm / 2, 0, 0]) {
          rotate([0, 0, Pin_Rotation_Degrees]) {
            male_connector();
          }
          ;
        }
        ;
      }
      ;
    }
    ;
  }
  ;
}
