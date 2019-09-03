/*

    @param TestName :OSL_viewportComparison
    @param Status   : Online
    @param Author: carlos.carpintero@autodesk.com
    @param Modby: carlos.carpintero@autodesk.com
    @param Created : 09-21-2018
    @param LastMod : 01-29-2019
    @param Description: Compare a viewport capture vs render result of OSL maps
    @param notes:  This suites runs the render part in Scanline, could be altered to include Arnold.

 */

 Struct OSL_viewportComparison
 (

    maxSceneName = "", viewportImageName, renderedImageFolder, renderedImageName, dataFolder, defaultViewCubeVisibility, defaultViewportButtonVisibility, defaultWorldAxisVisibility, defaultPreviewHighlightEnabled, ssi, testDataDir, testName,

    --setup function
    public
    function setup =
    (
         clearListener()
         format "Setting up...\n"
         resetMaxFile #noprompt

         -- back up the default workspace so we can restore it later
         defaultWorkspace = workspaceManager.GetCurrentWorkspaceIdentifier()

         thisFile = getSourceFileName()
         thisDir = pathConfig.removePathLeaf thisFile
         l_suiteName = fileNameFromPath thisDir
         l_testName = substituteString (fileNameFromPath thisFile) ".ms" ""
         common_dest = pathconfig.appendpath (getDir #scripts) "rendered_images" -- all rendered test images no go here
         suite_dest = pathconfig.appendpath common_dest l_suiteName  -- sub-folder for suite
         renderedImageFolder = pathconfig.appendpath suite_dest l_testName  -- sub-folder for this test
         dataFolder = pathconfig.appendpath thisDir "TestData/Viewport_Comparison"
         sceneFolder = pathconfig.appendpath datafolder "Scenes"

         if not (doesfileexist renderedImageFolder) then
         ( -- if the folder doesn't already exist, make it
             makeDir renderedImageFolder all:true
         )
         else
         ( -- if the folder does already exist, clean up files from previous run
             local files = getFiles (pathconfig.appendpath renderedImageFolder "*.*")
             for f in files do (
                 deleteFile f
             )
         )
     ),

     --function to render with Scanline
     function RenderWithScanline max_scene=
     (
         maxSceneName = substituteString(filenamefrompath maxFileName) ".max" ""
         format "Rendering with scanline...\n"
         -- Scanline  render settings
         renderers.current = Default_Scanline_Renderer()
         renderers.current.antiAliasing = false
         renderers.current.filterMaps = true
         renderers.current.globalSamplerEnabled = true
         --Trun off Raytrace Message Window
         a= raytraceGlobalSettings()
         a.showmessages = false
        renderedImageName = pathconfig.appendpath renderedImageFolder (maxSceneName + ".renderResult.tiff")
        render outputfile:renderedImageName outputwidth:400 outputheight:400

    ),

    --function to capture the viewport
    function captureViewport max_scene=
    (
        -- viewcube doesn't seem to be DPI-aware, but turn it off in case
        defaultViewCubeVisibility = ViewCubeOps.Visibility
        if defaultViewCubeVisibility do (ViewCubeOps.Visibility = false)

        -- viewport buttons are DPI-aware, turn them off so text size doesn't cause comparison failure
        defaultViewportButtonVisibility = ViewportButtonMgr.EnableButtons
        if defaultViewportButtonVisibility do (ViewportButtonMgr.EnableButtons = false)

        -- viewport World Axis tripod labels are DPI-aware, turn them off so text size doesn't cause comparison failure
        defaultWorldAxisVisibility = maxOps.showWorldAxis
        if defaultWorldAxisVisibility do (maxOps.showWorldAxis = false)

        -- make sure our result images are always the same size, regardless of screen resolution and Max app frame size
        NitrousGraphicsManager.PinViewPanelSize 404 404

        -- turn off Selection/Preview Highlights in the viewport
        ssi= NitrousGraphicsManager.GetSelectionSetting()
        defaultPreviewHighlightEnabled = ssi.PreviewOutlineEnabled
        ssi.PreviewOutlineEnabled = false

        currScreenWidth = systemTools.GetScreenWidth()
        currScreenHeight = systemTools.GetScreenHeight()
        if ((currScreenHeight < 404) or (currScreenWidth < 404)) then
        (
            format "ERROR: Script requires minimum screen resolution 400x400; instead have %x%." currScreenWidth currScreenHeight
        )
        else
        (
             maxSceneName = substituteString(filenamefrompath maxFileName) ".max" ""
             windows.processPostedMessages()
             --set viewport background to black
             viewport.enablesolidbackgroundcolormode 1
             SetUIColor 41 (color 0 0 0)
             colorMan.repaintUI #repaintAll
             -- capture a screenshot of the active viewport
             format "Capturing viewport...\n"
             viewportCapture = gw.getViewportDib()
             -- save it to file for comparing purposes
             viewportSavePath = pathconfig.appendpath renderedImageFolder (maxSceneName + ".viewportResult.tiff")
             viewportCapture.filename = viewportSavePath
             save viewportCapture

        )
    ),

    --compare viewport capture to render result
    function compareRenderVsViewport max_scene=
    (
        viewportImageName = pathConfig.appendPath renderedImageFolder (maxSceneName + ".viewportResult.tiff")
        renderedImageName = pathConfig.appendPath renderedImageFolder (maxSceneName + ".renderResult.tiff")

        if not doesFileExist renderedImageName then
        (
            format "Error: test image % not found.\n" renderedImageName
        )
        else
       (
            if not doesFileExist viewportImageName then
            (
                format "ERROR: Baseline file % not found.\n" viewportImageName
            )
            else
           (
                strComparisonResultsMsg = ""
                boolComparisonResult = CompareBitmaps viewportImageName renderedImageName 1750 50 useAlpha:false errorMsg:&strComparisonResultsMsg
                format "Comparing render to viewport % %\n" max_scene strComparisonResultsMsg
                assert_true boolComparisonResult message:("ERROR: image comparison failed, render differs from viewport:\n\t" + renderedImageName + "\n\t" + viewportImageName + "\n")
            )
        )
    ),

    --function to move time slider for 2 max scenes that require a frame number other than zero
    function movetime f =
    (
        sliderTime += f
    ),

    --now define function to loop through max files and run through the functions to render, capture viewport and compare images
    function TestAllScenes =
    (
        scene_dir = pathconfig.appendpath datafolder "Scenes"
        function GetMaxScenes base_dir =
        (
            result_file_list = #()
            pattern = "OSL_*.max"
            dir_array = GetDirectories (base_dir + "/*")

            for dir in dir_array do
                join dir_array (GetDirectories (dir+"/*"))
                join dir_array (GetDirectories(base_dir))

            for file in dir_array do
                join result_file_list (getFiles (file + pattern))

            result_file_list -- return value
        )

        --search for max files each max files in each subfolders
        max_scenes = #()
        max_scenes = GetMaxScenes(scene_dir)

        print max_scenes --this gives correct list of max files i want to test
        --loop through max files and run a test with them
        max_scene = ""

        for max_scene in max_scenes do (
            loadMaxFile max_scene useFileUnits:true quiet:true
            forceCompleteRedraw()
            sleep 2 --this sleep is to give the viewport a chance to finish drawing before capture
            if maxFileName == "OSL_WavelengthAnimated.max" then
            (
                movetime 6 -- this will show the color purple in viewport and render result as a texture
                captureViewport max_scene
                RenderWithScanline max_scene
                compareRenderVsViewport max_scene
            )
            else if maxFileName == "OSL_FrameNumber.max" then
            (
                movetime 60 -- this will show the number 60 in viewport and render result as a texture
                captureViewport max_scene
                RenderWithScanline max_scene
                compareRenderVsViewport max_scene
            )
            else if maxFileName == "OSL_TimeSeconds.max" then
            (
                movetime 90 --this will show the number 3 in the viewport and render as a texture
                captureViewport max_scene
                RenderWithScanline max_scene
                compareRenderVsViewport max_scene
            )
            else
            (
                captureViewport max_scene
                RenderWithScanline max_scene
                compareRenderVsViewport max_scene
            )
        )
    ),


     function teardown = (
        --reset viewport background color to default
        defaultUIColor = getDefaultUIColor 41
        SetUIColor 41 (defaultUIColor)

        --rest viewport
        viewport.enablesolidbackgroundcolormode 0
        NitrousGraphicsManager.UnpinViewPanelSize()

        -- turn Selection/Preview Highlights in the viewport back on
        ssi= NitrousGraphicsManager.GetSelectionSetting()
        defaultPreviewHighlightEnabled = ssi.PreviewOutlineEnabled
        ssi.PreviewOutlineEnabled = true

        --turn back on ui buttons and cube
        ViewCubeOPS.Visibility = true
        ViewportButtonMgr.EnableButtons = true
        maxOps.showWorldAxis = true
     ),


     Tests = #(TestAllScenes)
 )

 if undefined == run_test_fixture then
 (
     format "-- No fixture!\n"

     foo = OSL_viewportComparison ()
     foo.setup()
     foo.TestAllScenes ()
     foo.teardown()
 )
 else
 (
     format "-- Fixture found!\n"
     run_test_fixture OSL_viewportComparison  script:(getThisScriptFilename())
 )