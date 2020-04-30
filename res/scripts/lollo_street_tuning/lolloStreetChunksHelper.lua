local dump = require 'luadump'
local inspect = require('inspect')
local vec3 = require 'vec3'
local transf = require 'transf'
local arrayUtils = require('lollo_street_tuning/lolloArrayUtils')
local fileUtils = require('lollo_street_tuning/lolloFileUtils')
local pitchUtil = require('lollo_street_tuning/lolloPitchUtil')
local stringUtils = require('lollo_street_tuning/lolloStringUtils')

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
local function _getGameStreetDirPath()
    local gamePath = fileUtils.getGamePath()
    -- print('LOLLO gamePath is')
    -- dump(true)(gamePath)

    if stringUtils.isNullOrEmptyString(gamePath) then
        return ''
    end

    if stringUtils.stringEndsWith(gamePath, '/') then
        return gamePath .. 'res/config/street/standard'
    else
        return gamePath .. '/res/config/street/standard'
    end
end

local function _getMyStreetDirPath()
    local currPath = fileUtils.getCurrentPath()
    -- print('LOLLO currPath is')
    -- dump(true)(currPath)
    if stringUtils.isNullOrEmptyString(currPath) then
        return ''
    end

    local resDir = fileUtils.getResDirFromPath(currPath)
    -- print('LOLLO resDir is')
    -- dump(true)(resDir)
    if stringUtils.isNullOrEmptyString(resDir) then
        return ''
    end

    local streetDirPath = resDir .. '/config/street'
    -- print('LOLLO streetDirPath is')
    -- dump(true)(streetDirPath)

    return streetDirPath
end

local function _getStreetFilesContents(streetDirPath, fileNamePrefix)
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
    -- print('LOLLO streetDirPath = ', streetDirPath)
    local results = {}

    local streetFiles = fileUtils.getFilesInDirWithExtension(streetDirPath, 'lua')
    -- print('LOLLO streetfiles are')
    -- dump(true)(streetFiles)
    if type(streetFiles) ~= 'table' then
        return results
    end

    for i = 1, #streetFiles do
        local isOk, fileData = fileUtils.readGameDataFile(streetFiles[i])
        -- print('LOLLO streetFiles[i] = ')
        -- dump(true)(streetFiles[i])
        if isOk then
            table.insert(
                results,
                #results + 1,
                {
                    categories = fileData.categories or {},
                    fileName = fileNamePrefix .. fileUtils.getFileNameFromPath(streetFiles[i]),
                    name = fileData.name or '',
                    sidewalkWidth = fileData.sidewalkWidth or 0.2,
                    streetWidth = fileData.streetWidth or 0.2
                }
            )
        end
    end
    -- print('LOLLO _getStreetFilesContents is about to return: ')
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
    -- this fails coz game.interface is not on this thread, and it has probably nothing to do with file paths anyway
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

local function _getStreetDataFiltered(streetData) --, chunkedStreetTypes)
    local results = {}
    for _, val1 in pairs(streetData) do
        -- for _, val2 in pairs(chunkedStreetTypes) do
        --     if val1.type == val2 then
        --         table.insert(results, #results + 1, val1)
        --     end
        -- end
        -- print('LOLLO val1 = ')
        -- dump(true)(val1)
        if arrayUtils.arrayHasValue(val1.categories, 'one-way') or arrayUtils.arrayHasValue(val1.categories, 'highway') then
            table.insert(results, #results + 1, val1)
        end
    end
    return results
end

local function _getStreetDataWithDefaults(streetData) --, chunkedStreetTypes)
    -- print('LOLLO streetData has type = ', type(streetData))
    if type(streetData) == 'table' and #streetData > 0 then
        return streetData
    else
        print('LOLLO falling back to the default street data')
        -- provide a default value coz the game will dump if it finds no parameter values
        return {
            {
                categories = {'one-way'},
                fileName = 'lollo_medium_1_way_1_lane_street.lua',
                name = 'Narrow 1-way street with 1 lane',
                sidewalkWidth = 2,
                streetWidth = 4
            },
            {
                categories = {'one-way'},
                fileName = 'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua',
                name = 'Narrow 1-way street with 1 lane and .8 m pavement',
                sidewalkWidth = 0.8,
                streetWidth = 2.4
            }
        }
    end
end

helper.getGlobalStreetData = function(game)
    return game._lolloStreetData
end

helper.setGlobalStreetData = function(game) --, chunkedStreetTypes)
    if game._lolloStreetData == nil then
        -- print('LOLLO street chunks reading street data')
        game._lolloStreetData = arrayUtils.sort(_getStreetDataFiltered(_getStreetFilesContents(_getMyStreetDirPath(), '')), 'name') --, chunkedStreetTypes)
        -- print('LOLLO game._lolloStreetData has ', type(game._lolloStreetData) == 'table' and #(game._lolloStreetData) or 0, ' records before the concat')
        arrayUtils.concatValues(game._lolloStreetData, arrayUtils.sort(_getStreetDataFiltered(_getStreetFilesContents(_getGameStreetDirPath(), 'standard/')), 'name'))
        -- print('LOLLO game._lolloStreetData has ', type(game._lolloStreetData) == 'table' and #(game._lolloStreetData) or 0, ' records after the concat')
        game._lolloStreetData = _getStreetDataWithDefaults(game._lolloStreetData)
    -- print('LOLLO street chunks has read street data')
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
