# 3dsMax-OSL-Shaders-TestSuite

##3ds Max OSL Shaders tests and Resources

These files are an exact copy of the man OSL test suite run internally at
Autodesk. No modifications has been made to them compared to what is used
in the internal test suite.

The purpouse of these files is for renderer developers to be able to make
sure their particular OSL implementation can support all the features used
by the 3ds max OSL shaders.

This means that the test files may potentially need modifications to be
useful outside of the internal Autodesk test framework.

## What these files are

The main useful files:

- Rendering_OSL/Rendering_OSL_all_scenes.mxs

Script that runs all tests, for all renderers

- Rendering_OSL/Rendering_OSL_all_scenes_Arnold.ms
- Rendering_OSL/Rendering_OSL_all_scenes_Scanline.ms
- Rendering_OSL/Rendering_OSL_all_scenes_Quicksilver.ms

Launchers for the tests for a particular renderer. Note this simply calls
the .mxs file with certain parameters.

## How to use them

- Modify the .mxs file to add code to render with the renderer you want to test
- Copy one of the .ms files and rename for Your renderer
- Modify the **renderedImageFolder** variable to point to a valid location. The 
  internal tests point this to a subfolder of the max installation, which is not
  a writable location on an end user machine, so it needs to be modified.

  