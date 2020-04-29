local dump = require 'luadump'
local inspect = require('inspect')
local vec3 = require 'vec3'
local transf = require 'transf'
local arrayUtils = require('arrayUtils')
local fileUtils = require('fileUtils')
local pitchUtil = require('pitchUtil')
local stringUtils = require('stringUtils')

local helper = {}

-- --------------- parameters ------------------------
local _distances = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_distances, i)
end

helper.getDistances = function()
    return _distances
end

-- --------------- global street data ------------------------
local function _getStreetFilesContents()
    -- print('LOLLO current path = ')
    -- dump(true)(fileUtils.getCurrentPath())
    -- print('LOLLO package paths = ')
    -- dump(true)(fileUtils.getPackagePaths())
    -- print('LOLLO package cpaths = ')
    -- dump(true)(fileUtils.getPackageCpaths())
    -- print('LOLLO package.loaded = ')
    -- --dump(true)(package.loaded) huge
    -- for key, value in pairs(package.loaded) do
    --     print(key, value)
    -- end

    local results = {}
    local currPath = fileUtils.getCurrentPath()
    -- print('LOLLO currPath is')
    -- dump(true)(currPath)
    if stringUtils.isNullOrEmptyString(currPath) then
        return results
    end

    local resDir = fileUtils.getResDirFromPath(currPath)
    -- print('LOLLO resDir is')
    -- dump(true)(resDir)
    if stringUtils.isNullOrEmptyString(resDir) then
        return results
    end

    local streetDir = resDir .. '/config/street'
    -- print('LOLLO streetDir is')
    -- dump(true)(streetDir)
    if stringUtils.isNullOrEmptyString(streetDir) then
        return results
    end

    local streetFiles = fileUtils.getFilesInDirWithExtension(streetDir, 'lua')
    -- print('LOLLO streetfiles are')
    -- dump(true)(streetFiles)
    if type(streetFiles) ~= 'table' then
        return results
    end

    for i = 1, #streetFiles do
        local isOk, fileData = fileUtils.readGameDataFile(streetFiles[i])
        if isOk then
            table.insert(
                results,
                #results + 1,
                {
                    categories = fileData.categories or {},
                    name = fileData.name or '',
                    streetWidth = fileData.streetWidth or 0.2,
                    sidewalkWidth = fileData.sidewalkWidth or 0.2,
                    type = fileData.type or ''
                }
            )
        end
    end
    -- for i = 1, #results do
    --     dump(true)(results[i])
    -- end

    return results

    -- LOLLO NOTE very useful to see what is going on
    -- print('LOLLO debug.getregistry() = ')
    -- print(inspect(debug.getregistry()))

    -- LOLLO NOTE you can save the global var in game or in _G
    -- print('LOLLO game.config = ')
    -- -- dump(true)(game)
    -- for key, value in pairs(game.config) do
    --     print(key, value)
    -- end
    -- print('LOLLO game.res = ')
    -- for key, value in pairs(game.res) do
    --     print(key, value)
    -- end
    -- this fails coz game.interface is not on this thread
    -- local func = function()
    --     return game.interface.findPath('lollo_medium_4_lane_street')
    -- end
    -- local ok, fc = pcall(func)
    -- if ok then
    --     print('LOLLO test 4 findPath succeeded')
    --     dump(true)(fc)
    --     dump(true)(fc())
    -- else
    --     print('Execution error:', fc)
    -- end

    -- You can change package.path (not with ?.lua but with the whole file name) and then require a street file,
    -- but the required file does not return anything,
    -- because this is how street files are designed. So I need to read the file and parse it somehow.
    -- local modPath
    -- if string.ends(info.source, 'mod.lua') then
    --     modPath = string.gsub(info.source, "@(.*/)mod[.]lua", "%1")
    -- elseif string.ends(info.source, '.mdl') then
    --     modPath = string.gsub(info.source, "@(.*/)res/models/model/.+[.]mdl", "%1")
    -- elseif string.ends(info.source, '.lua') then
    --     modPath = string.gsub(info.source, "@(.*/)res/config/street/.+[.]lua", "%1")
    -- end
end

local function _getStreetData(streetData) --, parallelisedStreetTypes)
    local results = {}
    for _, val1 in pairs(streetData) do
        -- for _, val2 in pairs(parallelisedStreetTypes) do
        --     if val1.type == val2 then
        --         table.insert(results, #results + 1, val1)
        --     end
        -- end
        if arrayUtils.arrayHasValue(val1.categories, 'one-way') then
            table.insert(results, #results + 1, val1)
        end
    end

    if #results > 0 then
        return results
    else
        print('LOLLO falling back to the default street data')
        -- provide a default value coz the game will dump if it finds no parameter values
        return {
            {
                name = 'Medium 1-way street with 1 lane',
                sidewalkWidth = 2,
                streetWidth = 4,
                type = 'lollo_medium_1_way_1_lane_street.lua'
            },
            {
                name = 'Medium 1-way street with 1 lane and extra narrow pavement',
                sidewalkWidth = 0.8,
                streetWidth = 2.4,
                type = 'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua'
            }
        }
    end
end

helper.getGlobalStreetData = function(game)
    return game._lolloStreetData
end

helper.setGlobalStreetData = function(game) --, parallelisedStreetTypes)
    if game._lolloStreetData == nil then
        print('LOLLO parallel streets reading street data')
        game._lolloStreetData = _getStreetData(_getStreetFilesContents()) --, parallelisedStreetTypes)
        print('LOLLO parallel streets has read street data')
    -- print('LOLLO street data = ')
    -- dump(true)(game._lolloStreetData)
    end
end

-- --------------- utils ------------------------
helper.makeEdges = function(direction, pitch, node0, node1, tan0, tan1)
    -- return params.direction == 0 and
    --     {
    --         -- one entry refers to a position and a tangent
    --         {pitchUtil.getXYZPitched(pitch, {-6, -3, .0}), {1, .0, .0}}, -- node 0
    --         {pitchUtil.getXYZPitched(pitch, {-2, -3, .0}), {1, .0, .0}} -- node 1
    --     } or
    --     {
    --         {pitchUtil.getXYZPitched(pitch, {-2, -3, .0}), {-1, .0, .0}}, -- node 0
    --         {pitchUtil.getXYZPitched(pitch, {-6, -3, .0}), {-1, .0, .0}} -- node 1
    --     }
    return direction == 0 and
        {
            -- one entry refers to a position and a tangent
            {pitchUtil.getXYZPitched(pitch, node0), tan0}, -- node 0
            {pitchUtil.getXYZPitched(pitch, node1), tan1} -- node 1
        } or
        {
            {pitchUtil.getXYZPitched(pitch, node1), {-tan1[1], -tan1[2], -tan1[3]}}, -- node 0
            {pitchUtil.getXYZPitched(pitch, node0), {-tan0[1], -tan0[2], -tan0[3]}} -- node 1
        }
end

return helper
