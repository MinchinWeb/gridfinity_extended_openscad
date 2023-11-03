// Dimentions as declared on https://gridfinity.xyz/specification/

//Gridfinity grid size
gf_pitch = 42;
// each bin is undersize by this much
gf_tolerance = 0.5;
//Gridfinity height size
gridfinity_zpitch = 7;
gf_taper_angle = 45;

// cup
gf_cup_corner_radius = 3.75;
gf_cup_floor_thickness = 0.7;  

// CupBase
gf_cupbase_lower_taper_height = 0.8;
gf_cupbase_riser_height = 1.8;
gf_cupbase_upper_taper_height = 2.15;
gf_cupbase_magnet_position = 4.8; 
gf_cupbase_screw_diameter = 3; 
gf_cupbase_screw_depth = 6;
gf_magnet_diameter = 6.5;
gf_magnet_thickness = 2.4;

//stacking lip
gf_lip_lower_taper_height = 0.7;
gf_lip_riser_height = 1.8;
gf_lip_upper_taper_height = 1.9;

// base plate
gf_baseplate_lower_taper_height = 0.7;
gf_baseplate_riser_height = 1.8;
gf_baseplate_upper_taper_height = 2.15;

// top lip height 4.4mm
function gfLipHeight() = gf_lip_lower_taper_height + gf_lip_riser_height + gf_lip_upper_taper_height;

// cupbase heighttop lip height 4.75mm
function gfBaseHeight() = gf_cupbase_lower_taper_height + gf_cupbase_riser_height + gf_cupbase_upper_taper_height;

// base heighttop lip height 4.4mm
function gfBasePlateHeight() = gf_baseplate_lower_taper_height + gf_baseplate_riser_height + gf_baseplate_upper_taper_height;

// old names, that will get replaced
gridfinity_lip_height = gfLipHeight(); 
gridfinity_corner_radius = gf_cup_corner_radius ; 
gridfinity_pitch = gf_pitch; 
gridfinity_clearance = gf_tolerance; 
minFloorThickness = gf_cup_floor_thickness;  
const_magnet_height = gf_magnet_thickness;
gf_min_base_height = gfBaseHeight()+0.25; 

//Small amount to add to prevent clipping in openSCAD
fudgeFactor = 0.01;

color_cup = "LightSlateGray";
color_divider = "LemonChiffon";
color_topcavity = "DodgerBlue";
color_label = "PaleGreen";
color_cupcavity = "IndianRed";
color_wallcutout = "SandyBrown";
color_basehole = "DarkSlateGray";
color_base = "DimGray";
color_extention = "lightpink";