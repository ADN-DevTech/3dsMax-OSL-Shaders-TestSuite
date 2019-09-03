/*
    @param TestName:    Rendering_OSL_all_scenes_QuickSilver.ms
    @param Author:      Zap Andersson, Crazy Swedish Guy
    @param Created:     01/26/2018
    @param LastMod:     12/07/2018
    @param ModBy:       Amy Goldenberg
    @param Description: The purpose of this script is to validate OSL rendering using QuickSilver
    @param Status:      Online
*/

do_not_run_the_fixture_stuff = true

fileIn "Rendering_OSL_all_scenes.mxs"

doScanline = false
doQuicksilver = true
doArnold = false
reportName = "QuickSilver.html"

thisFile = getSourceFileName()
l_thisDir = pathConfig.removePathLeaf thisFile
l_suiteName = fileNameFromPath l_thisDir
l_testName = substituteString (fileNameFromPath thisFile) ".ms" ""
common_dest = pathconfig.appendpath (getDir #scripts) "rendered_images"
suite_dest = pathconfig.appendpath common_dest l_suiteName
renderedImageFolder = pathconfig.appendpath suite_dest l_testName  -- all rendered test images go here
if not (doesfileexist renderedImageFolder) then ( -- if the folder doesn't already exist, make it
    makeDir renderedImageFolder all:true
)
else ( -- if the folder does already exist, clean up files from previous run
    files = getFiles (pathconfig.appendpath renderedImageFolder "*.*")
    for f in files do (
        deleteFile f
    )
)

if undefined == run_test_fixture then
(
    format "-- No fixture!\n"
    foo = Rendering_OSL_All_Scenes()
    foo.setup()
    foo.TestAllScenes()
    foo.teardown()
)
else
(
    format "-- Fixture found!\n"
    run_test_fixture Rendering_OSL_All_Scenes script:(getThisScriptFilename())
)
