local arrayUtils = require('lollo_street_tuning/lolloArrayUtils')
local fileUtils = require('lollo_street_tuning/lolloFileUtils')
local stringUtils = require('lollo_street_tuning/lolloStringUtils')
-- local debugger = require('debugger')
-- local inspect = require('lollo_street_tuning/inspect')
local helper = {}


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


local function _getStandardStreetData()
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
            local newRecord = {
                categories = fileData.categories or {},
                fileName = (fileNamePrefix or '') .. fileUtils.getFileNameFromPath(streetFiles[i]),
                name = fileData.name or '',
                sidewalkWidth = fileData.sidewalkWidth or 0.2,
                streetWidth = fileData.streetWidth or 0.2,
                upgrade = fileData.upgrade or true, -- true means, do not show this street in the menu
                yearTo = fileData.yearTo or 1925
            }
            if type(newRecord.fileName) == 'string' and newRecord.fileName:len() > 0
            and type(newRecord.name) == 'string' and newRecord.name:len() > 0 then
                table.insert(
                    results,
                    #results + 1,
                    newRecord
                )
            end
        end
    end
    -- print('LOLLO _getStreetFilesContents is about to return: ')
    -- for i = 1, #results do
    --     dump(true)(results[i])
    -- end

    if #results > 0 then
        arrayUtils.concatValues(results, _getStandardStreetData())
    end

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

local function _getStreetDataFiltered(streetDataTable)
    if type(streetDataTable) ~= 'table' then return {} end

    local results = {}
    for _, strDataRecord in pairs(streetDataTable) do
        if strDataRecord.upgrade == false and strDataRecord.yearTo == 0 then
            if arrayUtils.arrayHasValue(strDataRecord.categories, 'country') or arrayUtils.arrayHasValue(strDataRecord.categories, 'highway')
            or arrayUtils.arrayHasValue(strDataRecord.categories, 'one-way') or arrayUtils.arrayHasValue(strDataRecord.categories, 'urban') then
                table.insert(results, #results + 1, strDataRecord)
            end
        end
    end
    return results
end

-- local function _getStreetDataWithDefaults(streetData)
--     -- print('LOLLO streetData has type = ', type(streetData))
--     if type(streetData) == 'table' and #streetData > 0 then
--         return streetData
--     else
--         print('LOLLO falling back to the default street data')
--         -- provide a default value coz the game will dump if it finds no parameter values
--         return {
--             {
--                 categories = {'one-way'},
--                 fileName = 'lollo_medium_1_way_1_lane_street.lua',
--                 name = 'Narrow 1-way street with 1 lane',
--                 sidewalkWidth = 2,
--                 streetWidth = 4
--             },
--             {
--                 categories = {'one-way'},
--                 fileName = 'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua',
--                 name = 'Narrow 1-way street with 1 lane and .8 m pavement',
--                 sidewalkWidth = 0.8,
--                 streetWidth = 2.4
--             }
--         }
--     end
-- end
local function _cloneCategories(tab)
    local results = {}
    for i, v in pairs(tab) do
        results[i] = v
    end
    return results
end

local function _getStreetTypesWithApi()
    if not api or not api.res or not api.res.streetTypeRep then return {} end

    local results = {}
    local streetTypes = api.res.streetTypeRep.getAll()
    for ii, fileName in pairs(streetTypes) do
        local streetParams = api.res.streetTypeRep.get(ii)
        results[#results+1] = {
            categories = _cloneCategories(streetParams.categories),
            fileName = fileName,
            icon = streetParams.icon,
            name = streetParams.name,
            sidewalkWidth = streetParams.sidewalkWidth,
            streetWidth = streetParams.streetWidth,
            upgrade = streetParams.upgrade,
            yearTo = streetParams.yearTo
        }
    end
    return results
end

local function _initLolloStreetDataWithApi()
    if game._lolloStreetData == nil or (type(game._lolloStreetData) == 'table' and #game._lolloStreetData < 1) then
        game._lolloStreetData = _getStreetDataFiltered(_getStreetTypesWithApi())
        arrayUtils.sort(game._lolloStreetData, 'name')

        -- print('LOLLO street data initialised with api, it has', #(game._lolloStreetData or {}), 'records and type = ', type(game._lolloStreetData))
    end
end

local function _initLolloStreetDataWithFiles()
    if game._lolloStreetData == nil or (type(game._lolloStreetData) == 'table' and #game._lolloStreetData < 1) then
        game._lolloStreetData = _getStreetDataFiltered(_getStreetFilesContents(_getMyStreetDirPath()))
        arrayUtils.sort(game._lolloStreetData, 'name')

        -- print('LOLLO street data initialised with files, it has', #(game._lolloStreetData or {}), 'records and type = ', type(game._lolloStreetData))
    end
end

helper.getGlobalStreetData = function()
    _initLolloStreetDataWithApi() -- don't use it for now
    -- _initLolloStreetDataWithFiles()
    return game._lolloStreetData
end

return helper
