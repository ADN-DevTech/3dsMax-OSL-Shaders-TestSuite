# 3dsMax-OSL-Shaders-TestSuite

## 3ds Max OSL Shaders tests and Resources

These files are an exact copy of the main OSL test suite run internally at
Autodesk. No modifications has been made to them compared to what is used
in the internal test suite.

The purpouse of these files is for renderer developers to be able to make
sure their particular OSL implementation can support all the features used
by the 3ds Max OSL shaders.

This means that the test files may potentially need modifications to be
useful outside of the internal Autodesk test framework.

## What these files are

The main useful files:

- Rendering_OSL/Rendering_OSL_all_scenes.mxs

Script that runs all tests, for all renderers

- Rendering_OSL/Rendering_OSL_all_scenes_Arnold.ms
- Rendering_OSL/Rendering_OSL_all_scenes_Scanline.ms
- Rendering_OSL/Rendering_OSL_all_scenes_Quicksilver.ms

Launchers for the tests for a particular renderer. Note these simply call
the .mxs file with certain parameters.

## How to use them

### To run:

- Modify the .mxs file to add code to render with the renderer you want to test
- Copy one of the .ms files and rename for your renderer
- Modify the **renderedImageFolder** variable to point to a valid location. The 
  internal tests point this to a subfolder of the 3ds Max installation, which is not
  a writable location on an end user machine, so it needs to be modified.

### The result:

The result is a Report.html file that will look something like the example 
[Rendering_OSL_all_scenes.pdf](Rendering_OSL_all_scenes.pdf) in this repository.

