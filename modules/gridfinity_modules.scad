include <modules_utility.scad>
include <gridfinity_constants.scad>

// set this to produce sharp corners on baseplates and bins
// not for general use (breaks compatibility) but may be useful for special cases
sharp_corners = 0;

function calcualteCavityFloorRadius(cavity_floor_radius, wall_thickness) = let(
  q = 1.65 - wall_thickness + 0.95 // default 1.65 corresponds to wall thickness of 0.95
) cavity_floor_radius >= 0 ? min((2.3+2*q)/2, cavity_floor_radius) : (2.3+2*q)/2;

constTopHeight = 5.7+fudgeFactor*5; //Need to confirm this

//Height of base, not including the floor
function calculateCupBaseHeight(magnet_diameter, screw_depth) = let (
    mag_ht = magnet_diameter > 0 ? const_magnet_height : 0)
    max(mag_ht, screw_depth, const_base_part_ht);

function calculateFloorDepth(filledin, floor_thickness, num_z) = 
  filledin == "on" ? (num_z-1) * gridfinity_zpitch + 2.0
  : filledin == "notstackable" ?  (num_z-1) * gridfinity_zpitch + constTopHeight
  : floor_thickness;
  
//Height of base including the floor.
function calculateFloorHeight(magnet_diameter,screw_depth, floor_thickness) = 
    calculateCupBaseHeight(magnet_diameter,screw_depth) + floor_thickness;
    
// calculate the position of separators from the size
function calcualteSeparators(num_separators, num_x) = num_separators < 1 
      ? [] 
      : [ for (i=[1:num_separators]) i*(num_x/(num_separators+1))];

function LookupKnownShapes(name="round") = 
  name == "square" ? 4 :
  name == "hex" ? 6 : 64;
  
function caluclatePosition(position, num_x, num_y) = position == "center" 
    ? [-(num_x-1)*gridfinity_pitch/2, -(num_y-1)*gridfinity_pitch/2, 0] 
    : position == "zero" ? [gridfinity_pitch/2, gridfinity_pitch/2, 0] 
    : [0, 0, 0]; 
    
// basic block with cutout in top to be stackable, optional holes in bottom
// start with this and begin 'carving'
module grid_block(
  num_x=1, 
  num_y=1, 
  num_z=2, 
  magnet_diameter=6.5, 
  screw_depth=6, 
  position = "default",
  hole_overhang_remedy=0, 
  half_pitch=false, 
  box_corner_attachments_only = false, 
  flat_base=false, 
  stackable = true,
  center_magnet_diameter = 0,
  center_magnet_thickness = 0,
  fn = 32,
  help)
{
  corner_radius = 3.75;
  outer_size = gridfinity_pitch - gridfinity_clearance;  // typically 41.5
  block_corner_position = outer_size/2 - corner_radius;  // need not match center of pad corners
  magnet_thickness = 2.4;
  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_diameter/2);
  screw_hole_diam = 3;
  gp = gridfinity_pitch;
  
  suppress_holes = num_x < 1 || num_y < 1;
  
  emd = suppress_holes ? 0 : magnet_diameter; // effective magnet diameter after override
  esd = suppress_holes ? 0 : screw_depth;     // effective screw depth after override
  
  overhang_fix = hole_overhang_remedy > 0 && emd > 0 && esd > 0 ? hole_overhang_remedy : 0;
  overhang_fix_depth = 0.3;  // assume this is enough
  
  totalht=gridfinity_zpitch*num_z+3.75;
  translate(caluclatePosition(position,num_x,num_y))
  difference() {
    intersection() {
      union() {
        // logic for constructing odd-size grids of possibly half-pitch pads
        color(color_base)
        pad_grid(num_x, num_y, half_pitch, flat_base);
        // main body will be cut down afterward
        translate([-gridfinity_pitch/2, -gridfinity_pitch/2, 5]) 
        cube([gridfinity_pitch*num_x, gridfinity_pitch*num_y, totalht-5]);
      }
      
      color(color_cup)
      translate([0, 0, -fudgeFactor])
      hull() 
      cornercopy(block_corner_position, num_x, num_y) 
      cylinder(r=corner_radius, h=totalht+fudgeFactor*2, $fn=fn);
    }
    
    if(center_magnet_diameter> 0 && center_magnet_thickness>0){
      //Center Magnet
      for(x =[0:1:num_x-1])
      {
        for(y =[0:1:num_y-1])
        {
          color(color_basehole)
          translate([x*gridfinity_pitch,y*gridfinity_pitch,-fudgeFactor])
            cylinder(h=center_magnet_thickness-fudgeFactor, d=center_magnet_diameter);
        }
      }
    }
    
    if(stackable)
    {
      // remove top so XxY can fit on top
      color(color_topcavity) 
      translate([0, 0, gridfinity_zpitch*num_z]) 
      pad_oversize(num_x, num_y, 1);
    }
    
    color(color_basehole)
    translate([0,0,-0.1])
    gridcopycorners(ceil(num_x), ceil(num_y), magnet_position, box_corner_attachments_only)
      SequentialBridgingDoubleHole(
        outerHoleRadius = emd/2,
        outerHoleDepth = magnet_thickness+0.1,
        innerHoleRadius = screw_hole_diam/2,
        innerHoleDepth = esd+0.1,
        overhangBridgeCount = overhang_fix,
        overhangBridgeThickness = overhang_fix_depth
      );
  }

  HelpTxt("grid_block",[
    "num_x",num_x
    ,"num_y",num_y
    ,"num_z",num_z
    ,"magnet_diameter",magnet_diameter
    ,"screw_depth",screw_depth
    ,"position",position
    ,"hole_overhang_remedy",hole_overhang_remedy
    ,"half_pitch",half_pitch
    ,"box_corner_attachments_only",box_corner_attachments_only
    ,"flat_base",flat_base
    ,"stackable",stackable]
    ,help);
}


module pad_grid(num_x, num_y, half_pitch=false, flat_base=false) {
  // if num_x (or num_y) is less than 1 (or less than 0.5 if half_pitch is enabled) then round over the far side
  cut_far_x = (num_x < 1 && !half_pitch) || (num_x < 0.5);
  cut_far_y = (num_y < 1 && !half_pitch) || (num_y < 0.5);

  intersection() {
    union(){
      if (flat_base) {
        pad_oversize(ceil(num_x), ceil(num_y));
      }
      else if (half_pitch) {
        gridcopy(ceil(num_x)*2, ceil(num_y)*2, gridfinity_pitch)// intersection() {
          pad_halfsize();
      }
      else {
        gridcopy(ceil(num_x), ceil(num_y)) 
          pad_oversize();
      }
    }
    if (cut_far_x) {
      translate([gridfinity_pitch*(-1+num_x), 0, 0]) pad_oversize();
    }
    if (cut_far_y) {
      translate([0, gridfinity_pitch*(-1+num_y), 0]) pad_oversize();
    }
    if (cut_far_x && cut_far_y) {
      // without this the far corner would be rectangular
      translate([gridfinity_pitch*(-1+num_x), gridfinity_pitch*(-1+num_y), 0]) pad_oversize();
    }
  }
}

module pad_halfsize() {
  //render()  // render here to keep tree from blowing up
  for (xi=[0:1]) for (yi=[0:1]) 
  translate([xi*gridfinity_pitch/2, yi*gridfinity_pitch/2, 0])
  pad_oversize(0.5,0.5);
}

// like a cylinder but produces a square solid instead of a round one
// specified 'diameter' is the side length of the square, not the diagonal diameter
module cylsq(d, h) {
  translate([-d/2, -d/2, 0]) cube([d, d, h]);
}

// like a tapered cylinder with two diameters, but square instead of round
module cylsq2(d1, d2, h) {
  linear_extrude(height=h, scale=d2/d1)
  square([d1, d1], center=true);
}

// unit pad slightly oversize at the top to be trimmed or joined with other feet or the rest of the model
// also useful as cutouts for stacking
module pad_oversize(num_x=1, num_y=1, margins=0) {
  pad_corner_position = gridfinity_pitch/2 - 4; // must be 17 to be compatible
  bevel1_top = 0.8;     // z of top of bottom-most bevel (bottom of bevel is at z=0)
  bevel2_bottom = 2.6;  // z of bottom of second bevel
  bevel2_top = 5;       // z of top of second bevel
  bonus_ht = 0.2;       // extra height (and radius) on second bevel
  
  // female parts are a bit oversize for a nicer fit
  radialgap = margins ? 0.25 : 0;  // oversize cylinders for a bit of clearance
  axialdown = margins ? 0.1 : 0;   // a tiny bit of axial clearance present in Zack's design
  
  translate([0, 0, -axialdown])
  difference() {
    union() {
      hull() cornercopy(pad_corner_position, num_x, num_y) {
        if (sharp_corners) {
          cylsq(d=1.6+2*radialgap, h=0.1);
          translate([0, 0, bevel1_top]) cylsq(d=3.2+2*radialgap, h=1.9);
        }
        else {
          cylinder(d=1.6+2*radialgap, h=0.1, $fn=24);
          translate([0, 0, bevel1_top]) cylinder(d=3.2+2*radialgap, h=1.9, $fn=32);
        }
      }
      
      hull() cornercopy(pad_corner_position, num_x, num_y) {
        if (sharp_corners) {
          translate([0, 0, bevel2_bottom]) 
          cylsq2(d1=3.2+2*radialgap, d2=7.5+0.5+2*radialgap+2*bonus_ht, h=bevel2_top-bevel2_bottom+bonus_ht);
        }
        else {
          translate([0, 0, bevel2_bottom]) 
          cylinder(d1=3.2+2*radialgap, d2=7.5+0.5+2*radialgap+2*bonus_ht, h=bevel2_top-bevel2_bottom+bonus_ht, $fn=32);
        }
      }
    }
    
    // cut off bottom if we're going to go negative
    if (margins) {
      translate([-gridfinity_pitch/2, -gridfinity_pitch/2, 0])
      cube([gridfinity_pitch*num_x, gridfinity_pitch*num_y, axialdown]);
    }
  }
}

// similar to cornercopy, can only copy to box corners
module gridcopycorners(num_x, num_y, r, onlyBoxCorners = false, pitch=gridfinity_pitch) {
  for (xi=[1:num_x]) for (yi=[1:num_y]) 
    for (xx=[-1, 1]) for (yy=[-1, 1]) 
      if(!onlyBoxCorners || 
        (xi == 1 && yi == 1 && xx == -1 && yy == -1) ||
        (xi == num_x && yi == num_y && xx == 1 && yy == 1) ||
        (xi == 1 && yi == num_y && xx == -1 && yy == 1) ||
        (xi == num_x && yi == 1 && xx == 1 && yy == -1))  
        translate([pitch*(xi-1), pitch*(yi-1), 0]) 
        translate([xx*r, yy*r, 0]) children();
}

// similar to quadtranslate but expands to extremities of a block
module cornercopy(r, num_x=1, num_y=1,pitch=gridfinity_pitch) {
  for (xx=[0, 1]) 
    for (yy=[0, 1]) 
    {
      $idx=[xx,yy,0];
      xpos = xx == 0 ? -r : pitch*(num_x-1)+r;
      ypos = yy == 0 ? -r : pitch*(num_y-1)+r;
      translate([xpos, ypos, 0]) 
        children();
    }
}


// make repeated copies of something(s) at the gridfinity spacing of 42mm
module gridcopy(num_x, num_y, pitch=gridfinity_pitch) {
  for (xi=[1:num_x]) 
    for (yi=[1:num_y]) 
      translate([pitch*(xi-1), 
        pitch*(yi-1), 0]) 
        children();
}