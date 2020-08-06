local arrayUtils = require('lollo_street_tuning/lolloArrayUtils')
local fileUtils = require('lollo_street_tuning/lolloFileUtils')
local stringUtils = require('lollo_street_tuning/lolloStringUtils')
-- local debugger = require('debugger')
-- local inspect = require('lollo_street_tuning/inspect')

local _lolloStreetDataBuffer = {
    data = {},
    filterId = nil
}
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

local function _getStreetDataFiltered_Stock(streetDataTable)
    if type(streetDataTable) ~= 'table' then return {} end

    local results = {}
    for _, strDataRecord in pairs(streetDataTable) do
        if strDataRecord.upgrade == false and strDataRecord.yearTo == 0 then
            if arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().COUNTRY)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().HIGHWAY)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().ONE_WAY)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().URBAN) then
                table.insert(results, #results + 1, strDataRecord)
            end
        end
    end
    return results
end

local function _getStreetDataFiltered_StockAndReservedLanes(streetDataTable)
    if type(streetDataTable) ~= 'table' then return {} end

    local results = {}
    for _, strDataRecord in pairs(streetDataTable) do
        if strDataRecord.upgrade == false and strDataRecord.yearTo == 0 then
            if arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().COUNTRY)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().COUNTRY_BUS_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().COUNTRY_CARGO_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().COUNTRY_PERSON_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().COUNTRY_TRAM_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().COUNTRY_TYRES_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().HIGHWAY)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().HIGHWAY_BUS_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().HIGHWAY_CARGO_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().HIGHWAY_PERSON_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().HIGHWAY_TRAM_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().HIGHWAY_TYRES_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().ONE_WAY)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().ONE_WAY_BUS_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().ONE_WAY_CARGO_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().ONE_WAY_PERSON_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().ONE_WAY_TRAM_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().ONE_WAY_TYRES_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().URBAN)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().URBAN_BUS_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().URBAN_CARGO_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().URBAN_PERSON_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().URBAN_TRAM_RIGHT)
            or arrayUtils.arrayHasValue(strDataRecord.categories, helper.getStreetCategories().URBAN_TYRES_RIGHT)
            then
                table.insert(results, #results + 1, strDataRecord)
            end
        end
    end
    return results
end

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

local function _initLolloStreetDataWithApi(filter)
    if _lolloStreetDataBuffer.filterId ~= filter.id
    or type(_lolloStreetDataBuffer.data) ~= 'table'
    or #_lolloStreetDataBuffer.data < 1 then
        _lolloStreetDataBuffer.data = filter.func(_getStreetTypesWithApi())
        arrayUtils.sort(_lolloStreetDataBuffer.data, 'name')

        -- print('LOLLO street data initialised with api, it has', #(_lolloStreetData.data or {}), 'records and type = ', type(_lolloStreetData.data))
    end
end

local function _initLolloStreetDataWithFiles(filter)
    if _lolloStreetDataBuffer.filterId ~= filter.id
    or type(_lolloStreetDataBuffer.data) ~= 'table'
    or #_lolloStreetDataBuffer.data < 1 then
        _lolloStreetDataBuffer.data = filter.func(_getStreetFilesContents(_getMyStreetDirPath()))
        arrayUtils.sort(_lolloStreetDataBuffer.data, 'name')

        -- print('LOLLO street data initialised with files, it has', #(_lolloStreetData.data or {}), 'records and type = ', type(_lolloStreetData.data))
    end
end

helper.getStreetCategories = function()
    return {
        COUNTRY = 'country',
        COUNTRY_BUS_RIGHT = 'country-bus-right',
        COUNTRY_CARGO_RIGHT = 'country-cargo-right',
        COUNTRY_PERSON_RIGHT = 'country-person-right',
        COUNTRY_TRAM_RIGHT = 'country-tram-right',
        COUNTRY_TYRES_RIGHT = 'country-tyres-right',
        HIGHWAY = 'highway',
        HIGHWAY_BUS_RIGHT = 'highway-bus-right',
        HIGHWAY_CARGO_RIGHT = 'highway-cargo-right',
        HIGHWAY_PERSON_RIGHT = 'highway-person-right',
        HIGHWAY_TRAM_RIGHT = 'highway-tram-right',
        HIGHWAY_TYRES_RIGHT = 'highway-tyres-right',
        ONE_WAY = 'one-way',
        ONE_WAY_BUS_RIGHT = 'one-way-bus-right',
        ONE_WAY_CARGO_RIGHT = 'one-way-cargo-right',
        ONE_WAY_PERSON_RIGHT = 'one-way-person-right',
        ONE_WAY_TRAM_RIGHT = 'one-way-tram-right',
        ONE_WAY_TYRES_RIGHT = 'one-way-tyres-right',
        URBAN = 'urban',
        URBAN_BUS_RIGHT = 'urban-bus-right',
        URBAN_CARGO_RIGHT = 'urban-cargo-right',
        URBAN_PERSON_RIGHT = 'urban-person-right',
        URBAN_TRAM_RIGHT = 'urban-tram-right',
        URBAN_TYRES_RIGHT = 'urban-tyres-right',
    }
end

helper.getStreetCategorySuffixes = function()
    return {
        BUS_RIGHT = '-bus-right',
        CARGO_RIGHT = '-cargo-right',
        PERSON_RIGHT = '-person-right',
        TRAM_RIGHT = '-tram-right',
        TYRES_RIGHT = '-tyres-right',
    }
end

helper.getStreetDataFilters = function()
    return {
        STOCK = { id = 'stock', func = _getStreetDataFiltered_Stock },
        STOCK_AND_RESERVED_LANES = { id = 'stock-and-reserved-lanes', func = _getStreetDataFiltered_StockAndReservedLanes },
    }
end

helper.getGlobalStreetData = function(filter)
    if filter == nil then filter = helper.getStreetDataFilters().STOCK end
    _initLolloStreetDataWithApi(filter)
    -- _initLolloStreetDataWithFiles(filter)
    return _lolloStreetDataBuffer.data
end

return helper
