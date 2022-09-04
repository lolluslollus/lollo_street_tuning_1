local arrayUtils = require('lollo_street_tuning.arrayUtils')
local pitchHelper = require('lollo_street_tuning.pitchHelper')
local streetUtils = require('lollo_street_tuning.streetUtils')

local helper = {
    getParams = function()
        -- print('globalBridgeData at getParams =') debugPrint(
        --     arrayUtils.map(
        --             streetUtils.getGlobalBridgeDataPlusNoBridge(),
        --             function(str)
        --                 return str
        --             end
        --     )
        -- )
        return {
            {
                key = 'mergingType',
                name = _('Street merge type'),
                values = {
                    '↑  ↑   -   ↑↑', -- 0
                    '↑    ↑   -   ↑↑', -- 1
                    '↓  ↑   -   ↓↑', -- 2
                    '↓    ↑   -   ↓↑', -- 3
                    '↑  ↑  ↑   -   ↑↑↑', -- 4
                    -- '↑    ↑    ↑   -   ↑↑↑', -- 5
                    '↑  ↑  ↑  ↑   -   ↑↑↑↑', -- 5
                    '↓  ↓  ↑  ↑   -   ↓↓↑↑', -- 6
                    '↓  ↓  ↑  ↑   -   ↓ ↓ ↑ ↑', -- 7
                    '↓↓   ↑↑   -   ↓ ↓ ↓ ↑ ↑ ↑', -- 8
                    '↓↓↓   ↑↑↑   -   ↓ ↓ ↓ ↑ ↑ ↑', -- 9
                    'M ↓↓↓   ↑↑↑   -   ↓ ↓ ↓ ↑ ↑ ↑', -- 10
                    'M ↓↓   ↑↑   -   ↓ ↓ ↓ ↑ ↑ ↑', -- 11
                    'M ↓  ↓  ↑  ↑   -   ↓ ↓ ↑ ↑', -- 12
                    'M ↑  ↑  ↑   -   ↑↑↑', -- 13
                    'M ↑  ↑   -   ↑↑', -- 14
                    'M ↓  ↑   -   ↓↑', -- 15
                },
                defaultIndex = 0
            },
            {
                key = 'direction4Merge',
                name = _('Direction (only one-way roads)'),
                values = {
                    _('↑'),
                    _('↓')
                },
                defaultIndex = 0
            },
            {
                key = 'bridgeType4Merge',
                name = _('BridgeType'),
                values = arrayUtils.map(
                    streetUtils.getGlobalBridgeDataPlusNoBridge(),
                    function(str)
                        return str.name
                        -- return str.icon
                    end
                ),
                uiType = 'COMBOBOX',
                -- uiType = 'ICON_BUTTON',
            },
            {
                key = 'snapNodes_', -- do not rename this param or chenga its values
                name = _('snapNodesName'),
                tooltip = _('snapNodesDesc'),
                values = {
                    _('No'),
                    _('Left'),
                    _('Right'),
                    _('Both')
                },
                defaultIndex = 3
            },
            {
                key = 'tramTrack_',
                name = _('Tram track type'),
                values = {
                    -- must be in this sequence
                    _('NO'),
                    _('YES'),
                    _('ELECTRIC')
                },
                defaultIndex = 2
            },
            {
                key = 'tramTrackInEveryLane_',
                name = _('Tram track in every lane (only applicable roads)'),
                values = {
                    _('No'),
                    _('Yes'),
                },
                defaultIndex = 1
            },
            -- {
            --     key = 'hasBus',
            --     name = _('Bus lane'),
            --     values = {
            --         _('No'),
            --         _('Yes')
            --     },
            --     defaultIndex = 0
            -- },
            {
                key = 'pitch4Merge',
                name = _('Pitch (adjust it with O and P while building)'),
                values = pitchHelper.getPitchParamValues(),
                defaultIndex = pitchHelper.getDefaultPitchParamValue(),
                uiType = 'SLIDER'
            }
        }
    end,
}

return helper