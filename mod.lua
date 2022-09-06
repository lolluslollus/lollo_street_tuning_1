local modSettings = require('lollo_street_tuning.settings')
local postRunFnUtils = require('lollo_street_tuning.postRunFnUtils')
local streetChunksHelper = require('lollo_street_tuning.lolloStreetChunksHelper')
local streetHairpinHelper = require('lollo_street_tuning.lolloStreetHairpinHelper')
local streetMergeHelper = require('lollo_street_tuning.lolloStreetMergeHelper')
local streetUtils = require('lollo_street_tuning.streetUtils')
-- local debugger = require('debugger')

function data()
    return {
        info = {
            minorVersion = 60,
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
            },
            params = {
                {
                    key = "lolloStreetTuning_YellowBusLaneStripes",
                    name = _("YellowBusLanes"),
                    values = { _("No"), _("Yes"), },
                    defaultIndex = 1,
                },
                {
                    key = "lolloStreetTuning_IsMakeReservedLanes",
                    name = _("MakeReservedLanes"),
                    values = { _("No"), _("Yes"), },
                    defaultIndex = 1,
                },
            },
        },
        runFn = function(settings, modParams)
            modSettings.setModParamsFromRunFn(modParams[getCurrentModId()])
            -- LOLLO TODO try setting g_allowApplyWithErrorsHack
            -- in a proper lua state, to see if you can avoid some pointless game crashes
            -- when bad luck strikes
            -- LOLLO NOTE I could set aiLock = true for small streets,
            -- to prevent the town automatically using them,
            -- but the game will crash when creating a new town.
        end,
        -- Unlike runFn, postRunFn runs after all resources have been loaded.
        -- It is the only place where we can define a dynamic construction,
        -- which is the only way we can define dynamic parameters.
        -- Here, the dynamic parameters are the street types.
        postRunFn = function(settings, params)
            postRunFnUtils.addAvailableConstruction(
                'lollo_street_chunks.con',
                'lollo_street_chunks_2.con',
                'construction/lollo_street_chunks',
                {yearFrom = 1925, yearTo = 0},
                streetChunksHelper.getStreetChunksParams(),
                streetUtils.getGlobalBridgeDataPlusNoBridge(),
                streetUtils.getGlobalStreetData({
                    streetUtils.getStreetDataFilters().PATHS,
                    streetUtils.getStreetDataFilters().STOCK,
                })
            )
            postRunFnUtils.addAvailableConstruction(
                'lollo_street_hairpin.con',
                'lollo_street_hairpin_2.con',
                'construction/lollo_street_hairpin',
                {yearFrom = 1925, yearTo = 0},
                streetHairpinHelper.getStreetHairpinParams(),
                streetUtils.getGlobalBridgeDataPlusNoBridge(),
                streetUtils.getGlobalStreetData({
                    streetUtils.getStreetDataFilters().PATHS,
                    streetUtils.getStreetDataFilters().STOCK,
                })
            )
            postRunFnUtils.addAvailableConstruction(
                'lollo_street_merge.con',
                'lollo_street_merge_2.con',
                'construction/lollo_street_merge',
                {yearFrom = 1925, yearTo = 0},
                streetMergeHelper.getParams(),
                streetUtils.getGlobalBridgeDataPlusNoBridge(),
                streetUtils.getGlobalStreetData()
            )
            if modSettings.getModParams('lolloStreetTuning_IsMakeReservedLanes') == 1 then
                postRunFnUtils.addStreetsWithReservedLanes()
            end
            postRunFnUtils.hideAllTramTracksStreets()
        end
    }
end
