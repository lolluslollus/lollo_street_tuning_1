local arrayUtils = require('lollo_street_tuning.arrayUtils')
local edgeUtils = require('lollo_street_tuning.edgeUtils')
local pitchHelper = require('lollo_street_tuning.pitchHelper')
local streetUtils = require('lollo_street_tuning.streetUtils')

-- --------------- parameters ------------------------
local _distances = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_distances, i)
end

local _getDistances = function()
    return _distances
end

local _lengthMultiplier = 10
local _lengths = {}
for i = 0, 12 do -- watch out, the parameters have base 0
    table.insert(_lengths, i * _lengthMultiplier)
end

local _getLengthMultiplier = function()
    return _lengthMultiplier
end

local _getLengths = function()
    return _lengths
end

-- --------------- utils -----------------------------------
local function _getStreetHalfWidth(streetData)
    return streetData.sidewalkWidth + streetData.streetWidth * 0.5
end
local function _getStreetFullWidth(streetData)
    return streetData.sidewalkWidth + streetData.sidewalkWidth + streetData.streetWidth
end

local function _makeEdgesWithPitch(direction, pitchAngle, node0, node1, isRightOfIsland, tan0, tan1)
    if tan0 == nil or tan1 == nil then
        local edgeLength = edgeUtils.getVectorLength({node1[1] - node0[1], node1[2] - node0[2], node1[3] - node0[3]})
        if tan0 == nil then tan0 = {edgeLength, 0, 0} end
        if tan1 == nil then tan1 = {edgeLength, 0, 0} end
    end
    if direction == 0 or (direction == 2 and isRightOfIsland) then return
        {
            pitchHelper.getPosTanPitched(pitchAngle, node0, tan0), -- node 0
            pitchHelper.getPosTanPitched(pitchAngle, node1, tan1) -- node 1
        }
    else return
        {
            pitchHelper.getPosTanPitched(pitchAngle, node1, {-tan1[1], -tan1[2], -tan1[3]}), -- node 0
            pitchHelper.getPosTanPitched(pitchAngle, node0, {-tan0[1], -tan0[2], -tan0[3]}) -- node 1
        }
    end
end

local function _getFreeNodesCentre(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        return {}
    else
        return {0, 1}
    end
end

local function _getFreeNodesHighX(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        if params.direction4Chunks == 2 and isRightOfIsland then
            return params.direction4Chunks == 0 and {0} or {1}
        else
            return params.direction4Chunks == 0 and {1} or {0}
        end
    else
        return {0, 1}
    end
end

local function _getFreeNodesLowX(params, isRightOfIsland)
    if params.lockLayoutCentre == 1 then
        if params.direction4Chunks == 2 and isRightOfIsland then
            return params.direction4Chunks == 0 and {1} or {0}
        else
            return params.direction4Chunks == 0 and {0} or {1}
        end
    else
        return {0, 1}
    end
end

local function _getSnapNodesCentre(params, isRightOfIsland)
    return {}
end

local function _getSnapNodesHighX(params, isRightOfIsland)
    if params.snapNodes_ == 2 or params.snapNodes_ == 3 then
        if params.direction4Chunks == 2 and isRightOfIsland then
            return params.direction4Chunks == 0 and {0} or {1}
        else
            return params.direction4Chunks == 0 and {1} or {0}
        end
    else
        return {}
    end
end

local function _getSnapNodesLowX(params, isRightOfIsland)
    if params.snapNodes_ == 1 or params.snapNodes_ == 3 then
        if params.direction4Chunks == 2 and isRightOfIsland then
            return params.direction4Chunks == 0 and {1} or {0}
        else
            return params.direction4Chunks == 0 and {0} or {1}
        end
    else
        return {}
    end
end

local function _getEdgeType(params, bridgeData)
    if params.bridgeType4Chunks and params.bridgeType4Chunks ~= 0 and bridgeData and bridgeData.fileName then
        return 'BRIDGE'
    end
    return nil
end

local function _getEdgeTypeName(params, bridgeData)
    if params.bridgeType4Chunks and params.bridgeType4Chunks ~= 0 and bridgeData and bridgeData.fileName then
        return bridgeData.fileName
    end -- eg "cement.lua",
    return nil
end

return {
    getStreetChunksParams = function()
        local defaultStreetTypeIndex = arrayUtils.findIndex(
            streetUtils.getGlobalStreetData({
                streetUtils.getStreetDataFilters().PATHS,
                streetUtils.getStreetDataFilters().STOCK,
            }),
            'fileName',
            'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua'
        ) - 1
        if defaultStreetTypeIndex < 0 then defaultStreetTypeIndex = 0 end
    -- print('LOLLO getting params for street chunk')
        return {
            {
                key = 'streetType4Chunks',
                name = _('StreetType'),
                values = arrayUtils.map(
                    streetUtils.getGlobalStreetData({
                        streetUtils.getStreetDataFilters().PATHS,
                        streetUtils.getStreetDataFilters().STOCK,
                    }),
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
                key = 'bridgeType4Chunks',
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
                key = 'howManyStreetsBase0',
                name = _('Number of roads'),
                values = {_('1'), _('2'), _('3'), _('4'), _('5'), _('6')},
                defaultIndex = 0
                -- yearFrom = 1925,
                -- yearTo = 0
            },
            {
                key = 'direction4Chunks',
                name = _('Direction'),
                values = {
                    _('↑'),
                    _('↓'),
                    _('↓↑'),
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
                key = 'lockLayoutCentre',
                name = _('Lock chunks'),
                tooltip = _('Lock chunks to keep their shape pretty and prevent other roads merging in. Unlock them to treat them like ordinary roads. You cannot relock an unlocked chunk.'),
                values = {
                    _('No'),
                    _('Yes')
                },
                defaultIndex = 1
            },
            {
                key = 'distance',
                name = _('Distance'),
                -- values = {_('0m'), _('1m'), _('2m'), _('3m'), _('4m')},
                values = arrayUtils.map(
                    _getDistances(),
                    function(dis)
                        return tostring(dis) .. 'm'
                    end
                ),
                defaultIndex = 0
            },
            {
                key = 'islandWidth',
                name = _('Island Width'),
                values = arrayUtils.map(
                    _getDistances(),
                    function(dis)
                        return tostring(dis) .. 'm'
                    end
                ),
                defaultIndex = 0
            },
            {
                key = 'extraLength',
                name = _('Extra Length'),
                -- values = {_('0m'), _('1m'), _('2m'), _('3m'), _('4m')},
                values = arrayUtils.map(
                    _getLengths(),
                    function(length)
                        return tostring(length) .. 'm'
                    end
                ),
                defaultIndex = 0
            },
            -- {
            --     key = "terrainAlignment",
            --     name = _("Terrain alignment"),
            --     values = { _("Yes"), _("No") },
            --     defaultIndex = 1
            -- },
            {
                key = 'pitch4Chunks',
                name = _('Pitch (adjust it with O and P while building)'),
                values = pitchHelper.getPitchParamValues(),
                defaultIndex = pitchHelper.getDefaultPitchParamValue(),
                uiType = 'SLIDER'
            }
        }
    end,
    getStreetChunksSnapEdgeLists = function(params, pitchAngle, streetData, bridgeData, tramTrackType)
        local streetHalfWidth = _getStreetHalfWidth(streetData)
        local streetFullWidth = _getStreetFullWidth(streetData)

        local distance = params.distance or 0.0
        local halfDistance = distance * 0.5
        local halfExtraLength = (params.extraLength or 0.0) * 0.5 * _getLengthMultiplier()
        local halfIslandWidth = (params.islandWidth or 0.0) * 0.5

        -- LOLLO TODO check this, it might need extending
        -- local x0 = - math.max(7.0, streetHalfWidth + 1.0) - streetHalfWidth - halfExtraLength -- this dumps
        -- local x0 = - math.max(9.0, streetHalfWidth + 1.0) - streetHalfWidth - halfExtraLength

        -- old
        -- local x0 = - math.max(8.0, streetHalfWidth + 1.0) - streetHalfWidth - halfExtraLength -- this is the fruit of trial and error: if x1 - x0 is too little, snapping will dump
        -- local x1 = - streetHalfWidth - halfExtraLength

        -- new
        local x0 = - math.max(8.0, streetHalfWidth + 1.0) - 1 - halfExtraLength -- this is the fruit of trial and error: if x1 - x0 is too little, snapping will dump
        local x1 = - 1 - halfExtraLength
        local x2 = - x1
        local x3 = - x0
        local edgeParams = {
            skipCollision = true,
            type = streetData.fileName,
            tramTrackType = tramTrackType
        }
        local edgeLists
        if params.howManyStreetsBase0 == 0 then -- 1 street
            edgeLists = {
                -- low x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, 0, 0},
                        {x1, 0, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                    --					snapNodes = { 0, 1 },  -- node 0 and 1 are allowed to snap to other edges of the same type --crashes
                },
                -- centre x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, 0, 0},
                        {x2, 0, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                -- high x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, 0, 0},
                        {x3, 0, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                }
            }
        elseif params.howManyStreetsBase0 == 1 then -- 2 streets
            edgeLists = {
                -- low x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                -- centre x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                -- high x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                }
            }
        elseif params.howManyStreetsBase0 == 2 then -- 3 streets
            edgeLists = {
                -- low x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, -streetFullWidth - distance - halfIslandWidth, 0},
                        {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, halfIslandWidth, 0},
                        {x1, halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, streetFullWidth + distance + halfIslandWidth, 0},
                        {x1, streetFullWidth + distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                -- centre x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                        {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, halfIslandWidth, 0},
                        {x2, halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, streetFullWidth + distance + halfIslandWidth, 0},
                        {x2, streetFullWidth + distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                -- high x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                        {x3, -streetFullWidth - distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, halfIslandWidth, 0},
                        {x3, halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, streetFullWidth + distance + halfIslandWidth, 0},
                        {x3, streetFullWidth + distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                }
            }
        elseif params.howManyStreetsBase0 == 3 then -- 4 streets
            edgeLists = {
                -- low x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        {x1, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                        {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                -- centre x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        {x2, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                        {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                -- high x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        {x3, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                        {x3, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                }
            }
        elseif params.howManyStreetsBase0 == 4 then -- 5 streets
            edgeLists = {
                -- low x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                        {x1, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, -streetFullWidth - distance - halfIslandWidth, 0},
                        {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, halfIslandWidth, 0},
                        {x1, halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, streetFullWidth + distance + halfIslandWidth, 0},
                        {x1, streetFullWidth + distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                        {x1, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                -- centre x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                        {x2, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                        {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, halfIslandWidth, 0},
                        {x2, halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, streetFullWidth + distance + halfIslandWidth, 0},
                        {x2, streetFullWidth + distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                        {x2, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                -- high x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                        {x3, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                        {x3, -streetFullWidth - distance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, halfIslandWidth, 0},
                        {x3, halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, streetFullWidth + distance + halfIslandWidth, 0},
                        {x3, streetFullWidth + distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                        {x3, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                }
            }
        else -- if params.howManyStreetsBase0 == 5 then -- 6 streets -- fallback
            edgeLists = {
                -- low x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                        {x1, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        {x1, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params, true),
                    snapNodes = _getSnapNodesLowX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                        {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x0, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                        {x1, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesLowX(params),
                    snapNodes = _getSnapNodesLowX(params)
                },
                -- centre x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                        {x2, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        {x2, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params, true),
                    snapNodes = _getSnapNodesCentre(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                        {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x1, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                        {x2, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesCentre(params),
                    snapNodes = _getSnapNodesCentre(params)
                },
                -- high x
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                        {x3, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        {x3, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                        true
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params, true),
                    snapNodes = _getSnapNodesHighX(params, true)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                        {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                        {x3, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                },
                {
                    type = 'STREET',
                    params = edgeParams,
                    edges = _makeEdgesWithPitch(
                        params.direction4Chunks,
                        pitchAngle,
                        {x2, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                        {x3, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                    ),
                    edgeType = _getEdgeType(params, bridgeData),
                    edgeTypeName = _getEdgeTypeName(params, bridgeData),
                    freeNodes = _getFreeNodesHighX(params),
                    snapNodes = _getSnapNodesHighX(params)
                }
            }
        end
        return edgeLists
    end,
}
