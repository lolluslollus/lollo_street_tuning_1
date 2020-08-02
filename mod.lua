local arrayUtils = require('lollo_street_tuning.lolloArrayUtils')
local streetChunksHelper = require('lollo_street_tuning/lolloStreetChunksHelper')
local streetUtils = require('lollo_street_tuning/lolloStreetUtils')
local stringUtils = require('lollo_street_tuning.lolloStringUtils')
-- local debugger = require('debugger')

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
    local function _getTransportModes()
        -- api.type.enum.TransportMode.PERSON
        return {
            "PERSON",
            "CARGO",
            "CAR",
            "BUS",
            "TRUCK",
            "TRAM",
            "ELECTRIC_TRAM",
            "TRAIN",
            "ELECTRIC_TRAIN",
            "AIRCRAFT",
            "SHIP",
            "SMALL_AIRCRAFT",
            "SMALL_SHIP"
        }
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

    local function _getConfigToString(config)
        local result = ''
        for _, value in pairs(config) do
            result = result .. tostring(value)
        end
        return result
    end

    local function _getIsStreetToBeExtended(street)
        return street ~= nil
        and street.laneConfigs ~= nil
        -- and #street.laneConfigs > 4
        and #street.laneConfigs > 2
        and not(street.upgrade)
        and (stringUtils.arrayHasValue(street.categories, 'urban')
            or stringUtils.arrayHasValue(street.categories, 'one-way')
            or stringUtils.arrayHasValue(street.categories, 'country')
            or stringUtils.arrayHasValue(street.categories, 'highway'))
    end

    local function _getTargetTransportModes4Cargo()
        return {0, 0, 0, 0,  1, 0, 0, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    local function _getTargetTransportModes4Person()
        return {0, 0, 0, 1,  0, 1, 1, 0,  0, 0, 0, 0,  0, 0, 0, 0}
    end

    local function _replaceRightLanes(newStreet, targetTransportModes)
        -- print('LOLLO newStreet before change =')
        -- debugPrint(newStreet)
        for key1, oldLaneConfig in pairs(newStreet.laneConfigs) do
            if key1 == 2 or key1 == #newStreet.laneConfigs - 1 then
                local newLaneConfig = api.type.LaneConfig.new()
                newLaneConfig.speed = oldLaneConfig.speed
                newLaneConfig.width = oldLaneConfig.width
                newLaneConfig.height = oldLaneConfig.height
                newLaneConfig.forward = oldLaneConfig.forward

                local newTransportModes = arrayUtils.cloneOmittingFields(targetTransportModes)
                -- do not allow a transport mode that is disallowed in the original street type
                if oldLaneConfig.transportModes[api.type.enum.TransportMode.BUS + 1] == 0 then
                    newTransportModes[api.type.enum.TransportMode.BUS + 1] = 0
                end
                if oldLaneConfig.transportModes[api.type.enum.TransportMode.CAR + 1] == 0 then
                    newTransportModes[api.type.enum.TransportMode.CAR + 1] = 0
                end
                if oldLaneConfig.transportModes[api.type.enum.TransportMode.ELECTRIC_TRAM + 1] == 0 then
                    newTransportModes[api.type.enum.TransportMode.ELECTRIC_TRAM + 1] = 0
                end
                if oldLaneConfig.transportModes[api.type.enum.TransportMode.TRAM + 1] == 0 then
                    newTransportModes[api.type.enum.TransportMode.TRAM + 1] = 0
                end
                if oldLaneConfig.transportModes[api.type.enum.TransportMode.TRUCK + 1] == 0 then
                    newTransportModes[api.type.enum.TransportMode.TRUCK + 1] = 0
                end

                newLaneConfig.transportModes = newTransportModes
                newStreet.laneConfigs[key1] = newLaneConfig
            end
        end
        -- print('LOLLO newStreet after change =')
        -- debugPrint(newStreet)
    end

    local function _addOneStreetWithReservedLanes(oldStreet, fileName, targetTransportModes, descSuffix, categorySuffix)
        local newStreet = api.type.StreetType.new()

        -- for key, value in pairs(streetData) do -- dumps
        newStreet.name = oldStreet.name .. ' - ' .. descSuffix -- 'LOLLO test'
        newStreet.desc = oldStreet.desc .. ' - ' .. descSuffix
        -- newStreet.fileName = 'lollo_large_4_lane_4_tram_tracks_street_2.lua' -- dumps
        newStreet.type = string.sub(fileName, 1, string.len(fileName) - string.len('.lua')) .. '-' .. _getConfigToString(targetTransportModes) .. '.lua'
        newStreet.categories = oldStreet.categories
        local newCategories = {}
        for _, value in pairs(newStreet.categories) do
            if value == 'urban' then
                newCategories[#newCategories+1] = 'urban-' .. categorySuffix
            elseif value == 'one-way' then
                newCategories[#newCategories+1] = 'one-way-' .. categorySuffix
            elseif value == 'country' then
                newCategories[#newCategories+1] = 'country-' .. categorySuffix
            elseif value == 'highway' then
                newCategories[#newCategories+1] = 'highway-' .. categorySuffix
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

        newStreet.yearFrom = oldStreet.yearFrom
        newStreet.yearTo = oldStreet.yearTo
        newStreet.priority = oldStreet.priority
        newStreet.upgrade = false -- false makes it visible in the construction menu
        newStreet.country = oldStreet.country
        newStreet.busAndTramRight = oldStreet.busAndTramRight
        newStreet.materials = oldStreet.materials -- LOLLO TODO this is not accessible, so we must displkay the different lanes with some other system
        -- print('LOLLO materials = ')
        -- debugPrint(newStreet.materials)
        -- print('LOLLO materials.streetBorder = ')
        -- debugPrint(newStreet.materials.streetBorder) -- dumps
        newStreet.assets = oldStreet.assets
        newStreet.signalAssetName = oldStreet.signalAssetName
        newStreet.cost = oldStreet.cost
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
        _replaceRightLanes(newStreet, targetTransportModes)

        api.res.streetTypeRep.add(newStreet.type, newStreet, true)
    end

    local function _addStreetsWithReservedLanes()
        local streetFilenames = api.res.streetTypeRep.getAll()
        for key, fileName in pairs(streetFilenames) do
            local oldStreet = api.res.streetTypeRep.get(key)
            if _getIsStreetToBeExtended(oldStreet) then
                if fileName == 'lollo_large_6_lane_street.lua' then -- LOLLO TODO remove after testing
                _addOneStreetWithReservedLanes(oldStreet, fileName, _getTargetTransportModes4Cargo(), 'cargo right lane', 'cargo-right')
                _addOneStreetWithReservedLanes(oldStreet, fileName, _getTargetTransportModes4Person(), 'passengers right lane', 'person-right')
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
