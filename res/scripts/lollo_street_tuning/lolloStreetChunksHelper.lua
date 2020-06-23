-- local dump = require('lollo_street_tuning/luadump')
-- local inspect = require('inspect')
-- local vec3 = require 'vec3'
-- local transf = require 'transf'
local arrayUtils = require('lollo_street_tuning/lolloArrayUtils')
local edgeUtils = require('lollo_street_tuning/edgeHelpers')
local fileUtils = require('lollo_street_tuning/lolloFileUtils')
local pitchUtil = require('lollo_street_tuning/lolloPitchUtil')
local stringUtils = require('lollo_street_tuning/lolloStringUtils')
local debugger = require('debugger')
local helper = {}

-- --------------- parameters ------------------------
local _distances = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_distances, i)
end

helper.getDistances = function()
    return _distances
end

local _lengthMultiplier = 10
local _lengths = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_lengths, i * _lengthMultiplier)
end

helper.getLengthMultiplier = function()
    return _lengthMultiplier
end

helper.getLengths = function()
    return _lengths
end

-- --------------- global street data ------------------------
local function _getGameStreetDirPath()
    local gamePath = fileUtils.getGamePath()
    -- print('LOLLO gamePath is')
    -- dump(true)(gamePath)

    if stringUtils.isNullOrEmptyString(gamePath) then
        return '', ''
    end

    if stringUtils.stringEndsWith(gamePath, '/') then
        return gamePath .. 'res/config/street/standard', 'standard/'
    else
        return gamePath .. '/res/config/street/standard', 'standard/'
    end
end

local function _getMyStreetDirPath()
    local currPath = fileUtils.getCurrentPath()
    -- print('LOLLO currPath is')
    -- dump(true)(currPath)
    if stringUtils.isNullOrEmptyString(currPath) then
        return '', ''
    end

    local resDir = fileUtils.getResDirFromPath(currPath)
    -- print('LOLLO resDir is')
    -- dump(true)(resDir)
    if stringUtils.isNullOrEmptyString(resDir) then
        return '', ''
    end

    local streetDirPath = resDir .. '/config/street'
    -- print('LOLLO streetDirPath is')
    -- dump(true)(streetDirPath)

    return streetDirPath, ''
end

local function _getStreetFilesContents(streetDirPath, fileNamePrefix)
    -- print('LOLLO current path = ')
    -- dump(true)(fileUtils.getCurrentPath())
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

local function _getStandardStreetData(streetData) --, chunkedStreetTypes)
    -- I could read this from the files, but Linux won't allow it.
    -- This is also more efficient, even if less interesting.
    return {
        {
            categories = {'urban'},
            fileName = 'standard/town_small_new.lua',
            name = 'Small street',
            sidewalkWidth = 3,
            streetWidth = 6
        },
        {
            categories = {'urban'},
            fileName = 'standard/town_medium_new.lua',
            name = 'Medium street',
            sidewalkWidth = 4,
            streetWidth = 8
        },
        {
            categories = {'urban'},
            fileName = 'standard/town_large_new.lua',
            name = 'Large street',
            sidewalkWidth = 4,
            streetWidth = 16
        },
        {
            categories = {'urban'},
            fileName = 'standard/town_x_large_new.lua',
            name = 'Extra-large street',
            sidewalkWidth = 4,
            streetWidth = 24
        },
        {
            categories = {'country'},
            fileName = 'standard/country_small_new.lua',
            name = 'Small country road',
            sidewalkWidth = 3,
            streetWidth = 6
        },
        {
            categories = {'country'},
            fileName = 'standard/country_medium_new.lua',
            name = 'Medium country road',
            sidewalkWidth = 4,
            streetWidth = 8
        },
        {
            categories = {'country'},
            fileName = 'standard/country_large_new.lua',
            name = 'Large country road',
            sidewalkWidth = 4,
            streetWidth = 16
        },
        {
            categories = {'country'},
            fileName = 'standard/country_x_large_new.lua',
            name = 'Extra-large country road',
            sidewalkWidth = 4,
            streetWidth = 24
        },
        {
            categories = {'one-way'},
            fileName = 'standard/town_large_one_way_new.lua',
            name = 'Large one-way street',
            sidewalkWidth = 4,
            streetWidth = 12
        },
        {
            categories = {'one-way'},
            fileName = 'standard/town_medium_one_way_new.lua',
            name = 'Medium one-way street',
            sidewalkWidth = 4,
            streetWidth = 8
        },
        {
            categories = {'one-way'},
            fileName = 'standard/town_small_one_way_new.lua',
            name = 'Small one-way street',
            sidewalkWidth = 3,
            streetWidth = 3
        },
        {
            categories = {'highway'},
            fileName = 'standard/country_large_one_way_new.lua',
            name = 'Large highway',
            sidewalkWidth = 4,
            streetWidth = 12
        },
        {
            categories = {'highway'},
            fileName = 'standard/country_medium_one_way_new.lua',
            name = 'Medium highway',
            sidewalkWidth = 4,
            streetWidth = 8
        },
        {
            categories = {'highway'},
            fileName = 'standard/country_small_one_way_new.lua',
            name = 'Highway ramp',
            sidewalkWidth = 4,
            streetWidth = 8
        },
    }
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
        if arrayUtils.arrayHasValue(val1.categories, 'country') or arrayUtils.arrayHasValue(val1.categories, 'highway')
        or arrayUtils.arrayHasValue(val1.categories, 'one-way') or arrayUtils.arrayHasValue(val1.categories, 'urban') then
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

local function _getStreetTypes()
    local results = {}
    local streetTypes = api.res.streetTypeRep.getAll()
    for ii, fileName in ipairs(streetTypes) do
        local streetParams = api.res.streetTypeRep.get(ii)
        results[#results+1] = {
            categories = streetParams.categories,
            fileName = fileName,
            icon = streetParams.icon,
            name = streetParams.name,
            sidewalkWidth = streetParams.sidewalkWidth,
            streetWidth = streetParams.streetWidth
        }
    end
    return results
end

helper.getGlobalStreetData = function(game)
    return game._lolloStreetData
end

helper.setGlobalStreetData = function(game) --, chunkedStreetTypes)
    if game._lolloStreetData ~= nil then return end
debugger()
    -- print('LOLLO street chunks reading street data')
    -- game._lolloStreetData = _getStreetDataWithDefaults(
    --     _getStreetDataFiltered(
    --         _getStreetFilesContents(
    --             _getMyStreetDirPath()
    --         )
    --     )
    -- ) --, chunkedStreetTypes)

    game._lolloStreetData = _getStreetDataFiltered(_getStreetTypes())
    -- print('LOLLO game._lolloStreetData has ', type(game._lolloStreetData) == 'table' and #(game._lolloStreetData) or 0, ' records before the concat')
    arrayUtils.concatValues(game._lolloStreetData, _getStandardStreetData())
    arrayUtils.sort(game._lolloStreetData, 'name')
    -- print('LOLLO street chunks has read street data')
    -- print('LOLLO street data = ')
    -- dump(true)(game._lolloStreetData)
end

-- --------------- utils ------------------------
helper.makeEdges = function(direction, pitch, node0, node1, isRightOfIsland, tan0, tan1)
    -- return params.direction == 0 and
    --     {
    --         {pitchUtil.getXYZPitched(pitch, {-6, -3, .0}), {1, .0, .0}}, -- node 0
    --         {pitchUtil.getXYZPitched(pitch, {-2, -3, .0}), {1, .0, .0}} -- node 1
    --     } or
    --     {
    --         {pitchUtil.getXYZPitched(pitch, {-2, -3, .0}), {-1, .0, .0}}, -- node 0
    --         {pitchUtil.getXYZPitched(pitch, {-6, -3, .0}), {-1, .0, .0}} -- node 1
    --     }
    if tan0 == nil or tan1 == nil then
        local edgeLength = edgeUtils.getVectorLength({node1[1] - node0[1], node1[2] - node0[2], node1[3] - node0[3]})
        if tan0 == nil then tan0 = {edgeLength, 0, 0} end
        if tan1 == nil then tan1 = {edgeLength, 0, 0} end
    end

    if direction == 0 or (direction == 2 and isRightOfIsland) then return
        {
            {pitchUtil.getXYZPitched(pitch, node0), tan0}, -- node 0
            {pitchUtil.getXYZPitched(pitch, node1), tan1} -- node 1
        }
    else return
        {
            {pitchUtil.getXYZPitched(pitch, node1), {-tan1[1], -tan1[2], -tan1[3]}}, -- node 0
            {pitchUtil.getXYZPitched(pitch, node0), {-tan0[1], -tan0[2], -tan0[3]}} -- node 1
        }
    end
end

helper.getFreeNodesLowX = function(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {1} or {0}
        else
            return params.direction == 0 and {0} or {1}
        end
    else
        return {0, 1}
    end
end

helper.getFreeNodesCentre = function(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        return {}
    else
        return {0, 1}
    end
end

helper.getFreeNodesHighX = function(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {0} or {1}
        else
            return params.direction == 0 and {1} or {0}
        end
    else
        return {0, 1}
    end
end

helper.getSnapNodesLowX = function(params, isRightOfIsland)
    if params.snapNodes == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {1} or {0}
        else
            return params.direction == 0 and {0} or {1}
        end
    else
        return {}
    end
end

helper.getSnapNodesCentre = function(params, isRightOfIsland)
    return {}
end

helper.getSnapNodesHighX = function(params, isRightOfIsland)
    if params.snapNodes == 1 then
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {0} or {1}
        else
            return params.direction == 0 and {1} or {0}
        end
    else
        return {}
    end
end

return helper
