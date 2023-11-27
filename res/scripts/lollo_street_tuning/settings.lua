local results = {}

local function _getModSettingsFromGameConfig()
    if type(game) ~= 'table' or type(game.config) ~= 'table' then return nil end
    return game.config._lolloStreetTuning
end

local function _getModSettingsFromApi()
    if type(api) ~= 'table' or type(api.res) ~= 'table' or type(api.res.getBaseConfig) ~= 'table' then return end

    local baseConfig = api.res.getBaseConfig()
    if not(baseConfig) then return end

    return baseConfig._lolloStreetTuning
end

results.getModParams = function(fieldName)
    -- LOLLO NOTE try game.config first!
    local modSettings = _getModSettingsFromGameConfig() or _getModSettingsFromApi()
    if not(modSettings) then
        print('LOLLO street tuning cannot read modSettings')
        return nil
    end

    return modSettings[fieldName]
end

results.setModParamsFromRunFn = function(thisModParams)
    -- LOLLO NOTE if default values are set, modParams in runFn will be an empty table,
    -- so thisModParams here will be nil
    if type(game) ~= 'table' or type(game.config) ~= 'table' then return end

    if type(game.config._lolloStreetTuning) ~= 'table' then
        game.config._lolloStreetTuning = {}
    end

    if type(thisModParams) == 'table' and thisModParams.lolloStreetTuning_YellowBusLaneStripes == 0 then
        game.config._lolloStreetTuning.lolloStreetTuning_YellowBusLaneStripes = 0
    else
        game.config._lolloStreetTuning.lolloStreetTuning_YellowBusLaneStripes = 1
    end

    if type(thisModParams) == 'table' and thisModParams.lolloStreetTuning_IsMakeReservedLanes == 0 then
        game.config._lolloStreetTuning.lolloStreetTuning_IsMakeReservedLanes = 0
    else
        game.config._lolloStreetTuning.lolloStreetTuning_IsMakeReservedLanes = 1
    end
end

return results