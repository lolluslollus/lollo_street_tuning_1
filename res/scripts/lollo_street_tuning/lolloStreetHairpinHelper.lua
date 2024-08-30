local arrayUtils = require('lollo_street_tuning.arrayUtils')
local extraRadiusHelper = require('lollo_street_tuning.extraRadiusHelper')
local pitchHelper = require('lollo_street_tuning.pitchHelper')
local streetUtilUG = require('streetutil')
local transfUtils = require('lollo_street_tuning.transfUtils')
local vec3 = require('vec3')

-- --------------- utils -----------------------------------
local function _getStreetHalfWidth(streetData)
    return streetData.sidewalkWidth + streetData.streetWidth * 0.5
end

local function _getWidthFactor(streetHalfWidth)
    -- this is the fruit of trial and error. On 2020-06-25, the game does not allow really sharp curves.
    local result = 0.0
    -- print('streetHalfWidth =', streetHalfWidth)
    if streetHalfWidth <= 2.01 then
        -- print('LOLLO very narrow')
        result = 1.60
    elseif streetHalfWidth <= 4.01 then
        -- print('LOLLO narrow')
        result = 1.32
    elseif streetHalfWidth <= 6.01 then
        -- print('LOLLO medium')
        result = 1.30
    else
        -- print('LOLLO wide')
        result = 1.20
    end
    return result
end

local function _makeHairpinEdges(direction, pitchAngle, nodeIndexToBePitchedBase1, node0, node1, tan0, tan1)
    if tan0 == nil or tan1 == nil then
        local edgeLength = transfUtils.getVectorLength({node1[1] - node0[1], node1[2] - node0[2], node1[3] - node0[3]})
        if tan0 == nil then tan0 = {edgeLength, 0, 0} end
        if tan1 == nil then tan1 = {edgeLength, 0, 0} end
    end

    if direction == 0 then
        if nodeIndexToBePitchedBase1 == 1 then
            return {
                pitchHelper.getPosTanPitched(pitchAngle, node0, tan0), -- node 0
                {node1, tan1} -- node 1
            }
        else
            return {
                {node0, tan0}, -- node 0
                pitchHelper.getPosTanPitched(pitchAngle, node1, tan1), -- node 1
            }
        end
    else
        if nodeIndexToBePitchedBase1 == 1 then
            return {
                {node1, {-tan1[1], -tan1[2], -tan1[3]}}, -- node 0
                pitchHelper.getPosTanPitched(pitchAngle, node0, {-tan0[1], -tan0[2], -tan0[3]}), -- node 1
            }
        else
            return {
                pitchHelper.getPosTanPitched(pitchAngle, node1, {-tan1[1], -tan1[2], -tan1[3]}), -- node 0
                {node0, {-tan0[1], -tan0[2], -tan0[3]}} -- node 1
            }
        end
    end
end

local function _getFreeNodesCentre(params)
    if params.lockLayoutCentre == 1 then
        return {}
    else
        return {0, 1}
    end
end

local function _getFreeNodesHighX(params)
    if params.lockLayoutCentre == 1 then
        return params.direction4Hairpin == 0 and {1} or {0}
    else
        return {0, 1}
    end
end

local function _getFreeNodesLowX(params)
    if params.lockLayoutCentre == 1 then
        return params.direction4Hairpin == 0 and {0} or {1}
    else
        return {0, 1}
    end
end

local function _getSnapNodesCentre(params)
    return {}
end

local function _getSnapNodesHighX(params)
    if params.snapNodes_ == 2 or params.snapNodes_ == 3 then
        return params.direction4Hairpin == 0 and {1} or {0}
    else
        return {}
    end
end

local function _getSnapNodesLowX(params)
    if params.snapNodes_ == 1 or params.snapNodes_ == 3 then
        return params.direction4Hairpin == 0 and {0} or {1}
    else
        return {}
    end
end

local function _getEdgeType(params, bridgeData)
    if params.bridgeType4Hairpin and params.bridgeType4Hairpin ~= 0 and bridgeData and bridgeData.fileName then
        return 'BRIDGE'
    end
    return nil
end

local function _getEdgeTypeName(params, bridgeData)
    if params.bridgeType4Hairpin and params.bridgeType4Hairpin ~= 0 and bridgeData and bridgeData.fileName then
        return bridgeData.fileName
    end -- eg "cement.lua",
    return nil
end

return {
    getStreetHairpinParams = function(globalBridgeData, globalStreetData)
        local defaultStreetTypeIndex = arrayUtils.findIndex(
            globalStreetData,
            'fileName',
            'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua'
        ) - 1
        if defaultStreetTypeIndex < 0 then defaultStreetTypeIndex = 0 end
    -- print('LOLLO getting params for street hairpin')
        return {
            {
                key = 'streetType4Hairpin',
                name = _('StreetType'),
                values = arrayUtils.map(
                    globalStreetData,
                    function(str)
                        return str.name
                    end
                ),
                uiType = 'COMBOBOX',
                defaultIndex = defaultStreetTypeIndex
                -- yearFrom = 1925,
                -- yearTo = 0
            },
            {
                key = 'bridgeType4Hairpin',
                name = _('BridgeType'),
                values = arrayUtils.map(
                    globalBridgeData,
                    function(str)
                        return str.name
                        -- return str.icon
                    end
                ),
                uiType = 'COMBOBOX',
                -- uiType = 'ICON_BUTTON',
            },
            {
                key = 'direction4Hairpin',
                name = _('Direction'),
                values = {
                    _('↑'),
                    _('↓')
                },
                defaultIndex = 0
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
                key = 'hasBus_',
                name = _('HasBus'),
                values = {
                    -- must be in this sequence
                    _('NO'),
                    _('YES'),
                },
                defaultIndex = 0
            },
            {
                key = 'lockLayoutCentre',
                name = _('Lock curve'),
                tooltip = _('Lock a curve to keep its shape pretty and prevent other roads merging in. Unlock it to treat it like ordinary roads. You cannot relock an unlocked curve.'),
                values = {
                    _('No'),
                    _('Yes')
                },
                defaultIndex = 1
            },
            {
                key = 'extraRadius4Hairpin',
                name = _('Extra radius (adjust it with Ü and + or [ and ] while building)'),
                values = extraRadiusHelper.getParamValues(),
                defaultIndex = extraRadiusHelper.getDefaultParamValue(),
                uiType = 'SLIDER'
            },
            {
                key = 'pitch4Hairpin',
                name = _('Pitch (adjust it with O and P while building)'),
                values = pitchHelper.getPitchParamValues(),
                defaultIndex = pitchHelper.getDefaultPitchParamValue(),
                uiType = 'SLIDER'
            }
        }
    end,
    getStreetHairpinSnapEdgeLists = function(params, extraRadius, pitchAngle, streetData, bridgeData, tramTrackType, hasBus)
        local streetHalfWidth = _getStreetHalfWidth(streetData)
        local widthFactorBend = _getWidthFactor(streetHalfWidth)
        -- this is the fruit of trial and error, see the notes
        local xMax = math.max(9.0, streetHalfWidth + 1.0)
        -- local xMax = streetHalfWidth + 1.0 -- LOLLO TODO check this, it might need extending
        local edgeParams = {
            hasBus = hasBus,
            skipCollision = true,
            type = streetData.fileName,
            tramTrackType = tramTrackType
        }
        local edgeLists = {
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeHairpinEdges(
                    params.direction4Hairpin,
                    pitchAngle,
                    1,
                    {-xMax, -widthFactorBend * streetHalfWidth -extraRadius, 0},
                    {0, -widthFactorBend * streetHalfWidth -extraRadius, 0},
                    {xMax, 0, 0},
                    {xMax, 0, 0}
                ),
                edgeType = _getEdgeType(params, bridgeData),
                edgeTypeName = _getEdgeTypeName(params, bridgeData),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = {},
                edgeType = _getEdgeType(params, bridgeData),
                edgeTypeName = _getEdgeTypeName(params, bridgeData),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params),
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeHairpinEdges(
                    params.direction4Hairpin,
                    -pitchAngle,
                    2,
                    {0, widthFactorBend * streetHalfWidth + extraRadius, 0},
                    {-xMax, widthFactorBend * streetHalfWidth + extraRadius, 0},
                    {-xMax, 0, 0},
                    {-xMax, 0, 0}
                ),
                edgeType = _getEdgeType(params, bridgeData),
                edgeTypeName = _getEdgeTypeName(params, bridgeData),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            }
        }

        if params.direction4Hairpin == 0 then
            streetUtilUG.addEdgeAutoTangents(
                edgeLists[2].edges,
                vec3.new(0, -widthFactorBend * streetHalfWidth -extraRadius, 0),
                vec3.new(0, widthFactorBend * streetHalfWidth + extraRadius, 0),
                vec3.new(1, 0, 0),
                vec3.new(-1, 0, 0)
            )
        else
            streetUtilUG.addEdgeAutoTangents(
                edgeLists[2].edges,
                vec3.new(0, widthFactorBend * streetHalfWidth + extraRadius, 0),
                vec3.new(0, -widthFactorBend * streetHalfWidth -extraRadius, 0),
                vec3.new(1, 0, 0),
                vec3.new(-1, 0, 0)
            )
        end
        return edgeLists
    end,
}
