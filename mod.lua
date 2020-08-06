local arrayUtils = require('lollo_street_tuning.lolloArrayUtils')
local streetChunksHelper = require('lollo_street_tuning/lolloStreetChunksHelper')
local streetUtils = require('lollo_street_tuning/lolloStreetUtils')
local stringUtils = require('lollo_street_tuning/lolloStringUtils')
-- local debugger = require('debugger')

-- LOLLO TODO
--[[
    Build 29596

    In the street menu, select the "urban - cargo in right lane" filter.
    Select any street type.
    In the properties, select bus lane = yes
    Lay the street.
    Watch the dump:
    Error message: Assertion `StreetGeometry::IsBusLane(result)' failed.
    Minidump: C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/crash_dump/859092d2-2fcd-491f-bb0e-556bda04d9b2.dmp
    In file: c:\build\tpf2_steam\src\game\transport\street\streetshapefactory.cpp:133
    In function: class std::bitset<16> __cdecl `anonymous-namespace'::CreateVehicleTransportModes(const class std::bitset<16> &,bool,bool,bool)

    Another way to produce a similar dump:
    Make a street of any sort, with a bus lane.
    In the street menu, select street upgrade.
    In the street menu, select the urban - cargo right filter.
    Hover on the piece of street you created.
    Watch the dump.

    Workaround: in the following, add the bus
    local function _getTargetTransportModes4Cargo()
        return {0, 0, 0,
        1, -- add bus
        1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    Apparently, replacing a piece of bus-laned road with a similar one, which only allows lorries, is not expected.

    --------------------------
    There is a twin error: make a street with only trams allowed in the right lane.
    In the street menu, select the "urban - tram in right lane" filter.
    Build a piece of road.
    Watch the dump.

    The workaround is to allow buses, like above.

    ---------------------------
    There seems to be confusion between allowed transport modes (why are buses so important?),
    the presence of a bus lane and the variable busAndTramRight (which seems useless).
    Why do I need to allow buses if I want the bus lane, which is in fact a magical lane?
    Besides, with buses allowed, the bus lane is drawn (wrong) but is in fact not active (check the upgrade tool).
    In the same way, with trams allowed, the tracks are drawn (correct) but they are not active (check the upgrade tool)
 ]]

-- LOLLO NOTE
--[[
    We could lay tram tracks more individually, with a parametric construction.
    Unfortunately, the game always draws the tram track on the right lane,
    even if it is meant to be in the centre lane only.
    The game draws the bus lane in the 2, 4, 5 and 7 lane (large street) in a test branch.
    The error with the tram tracks being drawn but the tram being disabled also persists.
    A road with a tram track in the middle followed by a road with the track on the side does not join the pieces of track.
    Given these issues, there is no real benefit versus using our predefined streets with many tram tracks.
    The only plus would be, fewer objects in the street menu.
]]

function data()
    local function _getUiTypeNumber(uiTypeStr)
        if uiTypeStr == 'BUTTON' then return 0
        elseif uiTypeStr == 'SLIDER' then return 1
        elseif uiTypeStr == 'COMBOBOX' then return 2
        elseif uiTypeStr == 'ICON_BUTTON' then return 3 -- double-check this
        elseif uiTypeStr == 'CHECKBOX' then return 4 -- double-check this
        else return 0
        end
    end

    local function _addAvailableConstruction(oldFileName, newFileName, scriptFileName, availability, params)
        local staticConIdId = api.res.constructionRep.find(oldFileName)
        local staticCon = api.res.constructionRep.get(staticConIdId)
        local newCon = api.type.ConstructionDesc.new()
        newCon.fileName = newFileName
        newCon.type = staticCon.type
        newCon.description = staticCon.description
        -- newCon.availability = { yearFrom = 1925, yearTo = 0 } -- this dumps, the api wants it different
        newCon.availability.yearFrom = availability.yearFrom
        newCon.availability.yearTo = availability.yearTo
        newCon.buildMode = staticCon.buildMode
        newCon.categories = staticCon.categories
        newCon.order = staticCon.order
        newCon.skipCollision = staticCon.skipCollision
        newCon.autoRemovable = staticCon.autoRemovable
        for _, par in pairs(params) do
            local newConParam = api.type.ScriptParam.new()
            newConParam.key = par.key
            newConParam.name = par.name
            newConParam.tooltip = par.tooltip or ''
            newConParam.values = par.values
            newConParam.defaultIndex = par.defaultIndex or 0
            newConParam.uiType = _getUiTypeNumber(par.uiType)
            if par.yearFrom ~= nil then newConParam.yearFrom = par.yearFrom end
            if par.yearTo ~= nil then newConParam.yearTo = par.yearTo end
            newCon.params[#newCon.params + 1] = newConParam -- the api wants it this way, all the table at once dumps
        end

        newCon.updateScript.fileName = scriptFileName .. '.updateFn'
        newCon.updateScript.params = {
            globalStreetData = streetUtils.getGlobalStreetData()
        }
        newCon.preProcessScript.fileName = scriptFileName .. '.preProcessFn'
        newCon.upgradeScript.fileName = scriptFileName .. '.upgradeFn'
        newCon.createTemplateScript.fileName = scriptFileName .. '.createTemplateFn'

        -- print('LOLLO newCon = ')
        -- debugPrint(newCon)

        api.res.constructionRep.add(newCon.fileName, newCon, true) -- fileName, resource, visible
    end

    local function _getLaneConfigToString(config)
        local result = ''
        for _, value in pairs(config) do
            result = result .. tostring(value)
        end
        return result
    end

    --[[
            Transport modes:
            "PERSON", 1
            "CARGO", 2
            "CAR", 3 -- if set to 0, the bus lane will appear and attempt to prevent cars, never mind the upgrade state
            "BUS", 4
            "TRUCK", 5
            "TRAM", 6 -- if set to 1, the tram track will appear and work, never mind the upgrade state
            "ELECTRIC_TRAM", 7 -- like above
            "TRAIN", 8
            "ELECTRIC_TRAIN", 9
            "AIRCRAFT", 10
            "SHIP", 11
            "SMALL_AIRCRAFT", 12
            "SMALL_SHIP", 12
     ]]
    local function _getTargetTransportModes4Bus()
        return {0, 0, 0, 1,  0, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    local function _getTargetTransportModes4Cargo()
        return {0, 0, 0, 0,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    local function _getTargetTransportModes4Person()
        return {0, 0, 0, 1,  0, 1, 1, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    local function _getTargetTransportModes4Tram()
        return {0, 0, 0, 0,  0, 1, 1, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    local function _getTargetTransportModes4Tyres()
        return {0, 0, 0, 1,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    local function _getIsOneWay(laneConfigs)
        if #laneConfigs < 2 then return false end

        local lastForward = laneConfigs[2].forward
        for index, laneConfig in pairs(laneConfigs) do
            if index > 2 and index < #laneConfigs then
                if laneConfig.forward ~= lastForward then
                    return false
                end
            end
        end

        return true
    end

    local function _replaceOuterLanes(newStreet, targetTransportModes)
        -- print('LOLLO newStreet before change =')
        -- debugPrint(newStreet)
        local success = false
        local isOneWay = _getIsOneWay(newStreet.laneConfigs)
        -- print('LOLLO isOneWay =', isOneWay)
        for index, oldLaneConfig in pairs(newStreet.laneConfigs) do
            local newLaneConfig = api.type.LaneConfig.new()
            newLaneConfig.speed = oldLaneConfig.speed
            newLaneConfig.width = oldLaneConfig.width
            newLaneConfig.height = oldLaneConfig.height
            if isOneWay and index > 1 and index < #newStreet.laneConfigs then
                -- invert one-way lanes so the bus lane and the tram track appear on the right
                newLaneConfig.forward = true --false --not(oldLaneConfig.forward)
            else
                newLaneConfig.forward = oldLaneConfig.forward
            end

            -- change the transport modes of the rightmost lane
            if (index == 2 and index < #newStreet.laneConfigs and not(isOneWay)) -- rightmost lane in 2-way roads, leftmost in 1-way
            or (index > 1 and index == #newStreet.laneConfigs - 1) then -- leftmost lane in 2-way roads, rightmost in 1-way
                local newTransportModes = arrayUtils.cloneOmittingFields(targetTransportModes)
                -- do not allow a transport mode that is disallowed in the original street type
                -- if oldLaneConfig.transportModes[api.type.enum.TransportMode.BUS + 1] == 0 then
                --     newTransportModes[api.type.enum.TransportMode.BUS + 1] = 0
                -- end
                -- if oldLaneConfig.transportModes[api.type.enum.TransportMode.CAR + 1] == 0 then
                --     newTransportModes[api.type.enum.TransportMode.CAR + 1] = 0
                -- end
                -- if oldLaneConfig.transportModes[api.type.enum.TransportMode.ELECTRIC_TRAM + 1] == 0 then
                --     newTransportModes[api.type.enum.TransportMode.ELECTRIC_TRAM + 1] = 0
                -- end
                -- if oldLaneConfig.transportModes[api.type.enum.TransportMode.TRAM + 1] == 0 then
                --     newTransportModes[api.type.enum.TransportMode.TRAM + 1] = 0
                -- end
                -- if oldLaneConfig.transportModes[api.type.enum.TransportMode.TRUCK + 1] == 0 then
                --     newTransportModes[api.type.enum.TransportMode.TRUCK + 1] = 0
                -- end

                newLaneConfig.transportModes = newTransportModes
                success = true
            else
                newLaneConfig.transportModes = oldLaneConfig.transportModes
            end

            newStreet.laneConfigs[index] = newLaneConfig
        end
        -- print('LOLLO newStreet after change =')
        -- debugPrint(newStreet)
        return success
    end

    local function _addOneStreetWithOuterReservedLanes(oldStreet, fileName, targetTransportModes, descSuffix, categorySuffix)
        local newStreet = api.type.StreetType.new()

        -- for key, value in pairs(streetData) do -- dumps
        newStreet.name = oldStreet.name .. ' - ' .. descSuffix -- 'LOLLO test'
        newStreet.desc = oldStreet.desc .. ' - ' .. descSuffix
        -- newStreet.fileName = 'lollo_large_4_lane_4_tram_tracks_street_2.lua' -- dumps
        newStreet.type = string.sub(fileName, 1, string.len(fileName) - string.len('.lua')) .. '-' .. _getLaneConfigToString(targetTransportModes) .. '.lua'
        newStreet.categories = oldStreet.categories
        local newCategories = {}
        for _, value in pairs(newStreet.categories) do
            if value == streetUtils.getStreetCategories().COUNTRY
            or value == streetUtils.getStreetCategories().HIGHWAY
            or value == streetUtils.getStreetCategories().ONE_WAY
            or value == streetUtils.getStreetCategories().URBAN then
                newCategories[#newCategories+1] = value .. categorySuffix
            else
                newCategories[#newCategories+1] = value
            end
        end
        newStreet.categories = newCategories

        newStreet.streetWidth = oldStreet.streetWidth
        newStreet.sidewalkWidth = oldStreet.sidewalkWidth
        newStreet.sidewalkHeight = oldStreet.sidewalkHeight
        newStreet.transportModesStreet = oldStreet.transportModesStreet
        newStreet.transportModesSidewalk = oldStreet.transportModesSidewalk
        newStreet.speed = oldStreet.speed

        newStreet.yearFrom = oldStreet.yearFrom or 0
        newStreet.yearTo = oldStreet.yearTo or 0
        newStreet.priority = oldStreet.priority
        newStreet.upgrade = false -- false makes it visible in the construction menu
        newStreet.country = oldStreet.country or false
        -- LOLLO NOTE this has no effect if cars are not allowed
        -- the upgrade status may show false, but the lane is blocked for cars,
        -- as long as they have an alternative route, as usual
        -- newStreet.busAndTramRight = oldStreet.busAndTramRight or false
        newStreet.busAndTramRight = false
        newStreet.materials = oldStreet.materials -- LOLLO TODO this is not accessible, so we must displkay the different lanes with some other system
        -- print('LOLLO materials = ')
        -- debugPrint(newStreet.materials)
        -- print('LOLLO materials.streetBorder = ')
        -- debugPrint(newStreet.materials.streetBorder) -- dumps
        newStreet.assets = oldStreet.assets
        newStreet.signalAssetName = oldStreet.signalAssetName
        newStreet.cost = oldStreet.cost or 0
        newStreet.catenary = oldStreet.catenary
        newStreet.lodDistFrom = oldStreet.lodDistFrom
        newStreet.lodDistTo = oldStreet.lodDistTo
        newStreet.sidewalkFillGroundTex = oldStreet.sidewalkFillGroundTex
        newStreet.streetFillGroundTex = oldStreet.streetFillGroundTex
        newStreet.borderGroundTex = oldStreet.borderGroundTex
        newStreet.icon = oldStreet.icon
        newStreet.embankmentSlopeLow = oldStreet.embankmentSlopeLow
        newStreet.embankmentSlopeHigh = oldStreet.embankmentSlopeHigh
        newStreet.maintenanceCost = oldStreet.maintenanceCost

        newStreet.laneConfigs = oldStreet.laneConfigs
        -- print('LOLLO fileName=', fileName)
        if _replaceOuterLanes(newStreet, targetTransportModes) == true then
            api.res.streetTypeRep.add(newStreet.type, newStreet, true)
            -- print('LOLLO added', newStreet.type)
            -- debugPrint(newStreet)
        end
    end

    local function _addStreetsWithReservedLanes()
        local streetDataTable = streetUtils.getGlobalStreetData()
        for _, streetDataRecordSmall in pairs(streetDataTable) do
            -- print('LOLLO fileName =', streetDataRecordSmall.fileName or '')
            local streetId = api.res.streetTypeRep.find(streetDataRecordSmall.fileName)
            if type(streetId) == 'number' and streetId > 0 then
                local streetDataRecordFull = api.res.streetTypeRep.get(streetId)
                if streetDataRecordFull ~= nil
                and streetDataRecordFull.laneConfigs ~= nil
                -- and #streetDataRecordFull.laneConfigs > 4
                and #streetDataRecordFull.laneConfigs > 2 then
                    _addOneStreetWithOuterReservedLanes(
                        streetDataRecordFull,
                        streetDataRecordSmall.fileName,
                        _getTargetTransportModes4Bus(),
                        'bus right lane',
                        streetUtils.getStreetCategorySuffixes().BUS_RIGHT
                    )
                    -- _addOneStreetWithOuterReservedLanes( -- dumps
                    --     streetDataRecordFull,
                    --     streetDataRecordSmall.fileName,
                    --     _getTargetTransportModes4Cargo(),
                    --     'cargo right lane',
                    --     streetUtils.getStreetCategorySuffixes().CARGO_RIGHT
                    -- )
                    _addOneStreetWithOuterReservedLanes(
                        streetDataRecordFull,
                        streetDataRecordSmall.fileName,
                        _getTargetTransportModes4Person(),
                        'passengers right lane',
                        streetUtils.getStreetCategorySuffixes().PERSON_RIGHT
                    )
                    -- _addOneStreetWithOuterReservedLanes( -- dumps
                    --     streetDataRecordFull,
                    --     streetDataRecordSmall.fileName,
                    --     _getTargetTransportModes4Tram(),
                    --     'tram right lane',
                    --     streetUtils.getStreetCategorySuffixes().TRAM_RIGHT
                    -- )
                    _addOneStreetWithOuterReservedLanes(
                        streetDataRecordFull,
                        streetDataRecordSmall.fileName,
                        _getTargetTransportModes4Tyres(),
                        'tyres right lane',
                        streetUtils.getStreetCategorySuffixes().TYRES_RIGHT
                    )
                end
            end
        end
    end

    return {
        info = {
            minorVersion = 18,
            severityAdd = 'NONE',
            severityRemove = 'WARNING',
            name = _('_NAME'),
            description = _('_DESC'),
            tags = {
                'Street',
                'Street Construction'
            },
            authors = {
                {
                    name = 'Lollus',
                    role = 'CREATOR'
                }
            }
        },
        -- Unlike runFn, postRunFn runs after all resources have been loaded.
        -- It is the only place where we can define a dynamic construction,
        -- which is the only way we can define dynamic parameters.
        -- Here, the dynamic parameters are the street types.
        postRunFn = function(settings, params)
            -- if true then return end
            _addAvailableConstruction(
                'lollo_street_chunks.con',
                'lollo_street_chunks_2.con',
                'construction/lollo_street_chunks',
                {yearFrom = 1925, yearTo = 0},
                streetChunksHelper.getStreetChunksParams()
            )
            _addAvailableConstruction(
                'lollo_street_hairpin.con',
                'lollo_street_hairpin_2.con',
                'construction/lollo_street_hairpin',
                {yearFrom = 1925, yearTo = 0},
                streetChunksHelper.getStreetHairpinParams()
            )
            _addStreetsWithReservedLanes()
        end
    }
end
