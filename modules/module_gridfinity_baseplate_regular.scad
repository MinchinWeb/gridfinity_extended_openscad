// include instead of use, so we get the pitch
include <gridfinity_constants.scad>
use <module_gridfinity.scad>
use <module_gridfinity_baseplate_common.scad>

module baseplate_regular(
  num_x, 
  num_y,  
  center_fill_grid_x = true,
  center_fill_grid_y = false,
  magnetSize = [gf_baseplate_magnet_od,gf_baseplate_magnet_thickness],
  reducedWallHeight=0,
  centerScrewEnabled = true,
  cornerScrewEnabled = true,
  weightHolder = true,
  cornerRadius = gf_cup_corner_radius,
  roundedCorners = 15) {

  //These should be base constants
  minFloorThickness = 1;
  counterSinkDepth = 2.5;
  screwDepth = counterSinkDepth+3.9;
  weightDepth = 4;
  
  frameBaseHeight = max(
    centerScrewEnabled ? screwDepth : 0, 
    centerScrewEnabled ? counterSinkDepth + weightDepth + minFloorThickness : 0, 
    cornerScrewEnabled ? screwDepth : 0,
    cornerScrewEnabled ? magnetSize[1] + counterSinkDepth + minFloorThickness : 0,
    weightHolder ? weightDepth+minFloorThickness : 0,
    magnetSize[1]);
    
    translate([0,0,frameBaseHeight])
    frame_plain(num_x, num_y, 
      extra_down=frameBaseHeight,
      center_fill_grid_x = center_fill_grid_x,
      center_fill_grid_y = center_fill_grid_y,
      cornerRadius = cornerRadius,
      reducedWallHeight=reducedWallHeight,
      roundedCorners = roundedCorners)
        difference(){
          translate([fudgeFactor,fudgeFactor,0])
            cube([gf_pitch-fudgeFactor*2,gf_pitch-fudgeFactor*2,frameBaseHeight-fudgeFactor*2]);
            
          baseplate_cavities(
            num_x = $gc_size.x,
            num_y = $gc_size.y,
            baseCavityHeight=frameBaseHeight,
            magnetSize = magnetSize,
            centerScrewEnabled = centerScrewEnabled,
            cornerScrewEnabled = cornerScrewEnabled,
            weightHolder = weightHolder,
            cornerRadius = cornerRadius,
            roundedCorners = roundedCorners);
        }
}
