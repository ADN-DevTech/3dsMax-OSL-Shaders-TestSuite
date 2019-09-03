/*
    @param TestName: Rendering_OSL_scanline_oversampling.ms
    @param Author: Daniele Pollutro, from Zap Andersson's original work
    @param Created: 02/05/2018
    @param LastMod: -
    @param ModBy: -
    @param Description: The purpose of this script is to validate OSL rendering using Scanline with oversampling option enabled/disabled.
    @param Status: Online
*/
fileIn "utils.mxs"

struct Rendering_OSL_Scanline_Oversampling
(

    private
    testDataDir, testName, renderedImageFolder,

    public
    function setup =
    (
        format "Setup...\n"
        resetMaxFile #noPrompt

        local thisFile = getSourceFileName()
        local l_thisDir = pathConfig.removePathLeaf thisFile
        local l_suiteName = fileNameFromPath l_thisDir
        testDataDir = pathconfig.appendpath (pathConfig.removePathLeaf thisFile) "TestData"
        local l_testName = substituteString (fileNameFromPath thisFile) ".ms" ""
        local common_dest = pathconfig.appendpath (getDir #scripts) "rendered_images"
        local suite_dest = pathconfig.appendpath common_dest l_suiteName
        renderedImageFolder = pathconfig.appendpath suite_dest l_testName  -- all rendered test images go here
        if not (doesfileexist renderedImageFolder) then ( -- if the folder doesn't already exist, make it
            makeDir renderedImageFolder all:true
        )
        else ( -- if the folder does already exist, clean up files from previous run
            local files = getFiles (pathconfig.appendpath renderedImageFolder "*.*")
            for f in files do (
                deleteFile f
            )
        )
    ),

    function RenderScene oversampling_bool =
    (
        forcecompleteredraw()

        render_result = render outputwidth:320 outputheight:240

        -- Save the rendered image
        current_image_path = pathConfig.appendPath renderedImageFolder  (testName+"." + oversampling_bool + ".current.tiff")
        render_result.filename = current_image_path
        save render_result gamma:#auto

        -- Compare images
        baseline_image_path  = pathconfig.appendpath (pathconfig.appendpath testDataDir "Baselines") (testName + "."+ oversampling_bool + ".baseline.tiff")
        diff_image_path  = pathconfig.appendpath renderedImageFolder (testName + "." + oversampling_bool + ".diff.bmp")
        result_path  = pathconfig.appendpath renderedImageFolder (testName + "." + oversampling_bool + ".diff.txt")
        imageCompare baseline_image_path current_image_path diff_image_path result_path

        -- purging bitmap data
        freescenebitmaps()
        gc()
    ),

    function RenderWithScanline oversampling_bool =
    (
        format "Rendering with scanline, oversampling %: " oversampling_bool as string
        -- Scanline  render settings
        renderers.current = Default_Scanline_Renderer()
        renderers.current.globalSamplerEnabled = oversampling_bool
        r = renderers.current

        RenderScene(oversampling_bool as string)
    ),

    function LoadAndRender max_scene =
    (
        local scene_path = getFilenamePath max_scene
        local test_dir = pathConfig.removePathLeaf scene_path
        testName = getFilenameFile max_scene
        local scenes_dir = pathConfig.removePathLeaf test_dir

        texture_search_path = pathconfig.appendpath  test_dir "Textures"
        mapPaths.add texture_search_path

        format "Testing scene \"%\"\n" testName
        -- load the scene
        scene_loaded = loadMaxFile max_scene useFileUnits:true quiet:true

        if scene_loaded then
        (
            -- Render with Scanline, oversampling disabled
            RenderWithScanline false

            -- Render with Scanline, oversampling enabled
            RenderWithScanline true
        )
        else
            format "ERROR: Load max scene file \"%\" failed\n" testName

        format "===========================\n"
    ),

    function TestOversampling =
    (
        local scene_dir = pathconfig.appendpath testDataDir "Scenes"
        local max_scene = pathconfig.appendpath scene_dir "oversampling.max"

        LoadAndRender max_scene
    ),

    function teardown =
    (format "Teardown...\n"),

    Tests = #(TestOversampling)
)

if undefined == run_test_fixture then
(
    format "-- No fixture!\n"
    foo = Rendering_OSL_Scanline_Oversampling()
    foo.setup()
    foo.TestOversampling()
    foo.teardown()
)
else
(
    format "-- Fixture found!\n"
    run_test_fixture Rendering_OSL_Scanline_Oversampling script:(getThisScriptFilename())
)