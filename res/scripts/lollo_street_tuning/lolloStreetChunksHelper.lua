local arrayUtils = require('lollo_street_tuning/arrayUtils')
local edgeUtils = require('lollo_street_tuning.edgeUtils')
local pitchHelper = require('lollo_street_tuning/pitchHelper')
local streetUtil = require('streetutil')
local streetUtils = require('lollo_street_tuning/streetUtils')
local vec3 = require('vec3')
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

-- --------------- utils -----------------------------------
local function _getStreetHalfWidth(streetData)
    return streetData.sidewalkWidth + streetData.streetWidth * 0.5
end
local function _getStreetFullWidth(streetData)
    return streetData.sidewalkWidth + streetData.sidewalkWidth + streetData.streetWidth
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

local function _makeEdges(direction, node0, node1, isRightOfIsland, tan0, tan1)
    if tan0 == nil or tan1 == nil then
        local edgeLength = edgeUtils.getVectorLength({node1[1] - node0[1], node1[2] - node0[2], node1[3] - node0[3]})
        if tan0 == nil then tan0 = {edgeLength, 0, 0} end
        if tan1 == nil then tan1 = {edgeLength, 0, 0} end
    end

    if direction == 0 or (direction == 2 and isRightOfIsland) then return
        {
            {node0, tan0}, -- node 0
            {node1, tan1} -- node 1
        }
    else return
        {
            {node1, {-tan1[1], -tan1[2], -tan1[3]}}, -- node 0
            {node0, {-tan0[1], -tan0[2], -tan0[3]}} -- node 1
        }
    end
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
        if params.direction == 2 and isRightOfIsland then
            return params.direction == 0 and {0} or {1}
        else
            return params.direction == 0 and {1} or {0}
        end
    else
        return {0, 1}
    end
end

local function _getFreeNodesLowX(params, isRightOfIsland)
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

local function _getSnapNodesCentre(params, isRightOfIsland)
    return {}
end

local function _getSnapNodesHighX(params, isRightOfIsland)
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

local function _getSnapNodesLowX(params, isRightOfIsland)
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

helper.getStreetChunksParams = function()
    local defaultStreetTypeIndex = arrayUtils.findIndex(streetUtils.getGlobalStreetData(), 'fileName', 'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua') - 1
    if defaultStreetTypeIndex < 0 then defaultStreetTypeIndex = 0 end
-- print('LOLLO getting params for street chunk')
    return {
        {
            key = 'streetType_',
            name = _('Street type'),
            values = arrayUtils.map(
                streetUtils.getGlobalStreetData(),
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
            key = 'howManyStreetsBase0',
            name = _('Number of roads'),
            values = {_('1'), _('2'), _('3'), _('4'), _('5'), _('6')},
            defaultIndex = 1
            -- yearFrom = 1925,
            -- yearTo = 0
        },
        {
            key = 'direction',
            name = _('Direction'),
            values = {
                _('↑'),
                _('↓'),
                _('↓↑'),
            },
            defaultIndex = 0
        },
        {
            key = 'snapNodes',
            name = _('Snap to neighbours'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 0
        },
        {
            key = 'tramTrack',
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
                helper.getDistances(),
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
                helper.getDistances(),
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
                helper.getLengths(),
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
            key = 'pitch',
            name = _('Pitch (adjust it with O and P while building)'),
            values = pitchHelper.getPitchParamValues(),
            defaultIndex = pitchHelper.getDefaultPitchParamValue(),
            uiType = 'SLIDER'
        }
    }
end

helper.getStreetHairpinParams = function()
    local defaultStreetTypeIndex = arrayUtils.findIndex(streetUtils.getGlobalStreetData(), 'fileName', 'lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua') - 1
    if defaultStreetTypeIndex < 0 then defaultStreetTypeIndex = 0 end
-- print('LOLLO getting params for street hairpin')
    return {
        {
            key = 'streetType_',
            name = _('Street type'),
            values = arrayUtils.map(
                streetUtils.getGlobalStreetData(),
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
            key = 'direction',
            name = _('Direction'),
            values = {
                _('↑'),
                _('↓')
            },
            defaultIndex = 0
        },
        {
            key = 'snapNodes',
            name = _('Snap to neighbours'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 0
        },
        {
            key = 'tramTrack',
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
            name = _('Lock curve'),
            tooltip = _('Lock a curve to keep its shape pretty and prevent other roads merging in. Unlock it to treat it like ordinary roads. You cannot relock an unlocked curve.'),
            values = {
                _('No'),
                _('Yes')
            },
            defaultIndex = 1
        },
        -- {
        --     key = 'pitch',
        --     name = _('Pitch (adjust it with O and P while building)'),
        --     values = pitchUtil.getPitchParamValues(),
        --     defaultIndex = pitchUtil.getDefaultPitchParamValue(),
        --     uiType = 'SLIDER'
        -- }
    }
end

helper.getStreetChunksSnapEdgeLists = function(params, pitchAngle, streetData, tramTrackType)
    local streetHalfWidth = _getStreetHalfWidth(streetData)
    local streetFullWidth = _getStreetFullWidth(streetData)

    local distance = params.distance or 0.0
    local halfDistance = distance * 0.5
    local halfExtraLength = (params.extraLength or 0.0) * 0.5 * helper.getLengthMultiplier()
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
                    params.direction,
                    pitchAngle,
                    {x0, 0, 0},
                    {x1, 0, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
                --					snapNodes = { 0, 1 },  -- node 0 and 1 are allowed to snap to other edges of the same type --crashes
                --					tag2nodes = {},
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, 0, 0},
                    {x2, 0, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, 0, 0},
                    {x3, 0, 0}
                ),
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
                    params.direction,
                    pitchAngle,
                    {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
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
                    params.direction,
                    pitchAngle,
                    {x0, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, halfIslandWidth, 0},
                    {x1, halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, streetFullWidth + distance + halfIslandWidth, 0},
                    {x1, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, halfIslandWidth, 0},
                    {x2, halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, streetFullWidth + distance + halfIslandWidth, 0},
                    {x2, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x3, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, halfIslandWidth, 0},
                    {x3, halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, streetFullWidth + distance + halfIslandWidth, 0},
                    {x3, streetFullWidth + distance + halfIslandWidth, 0}
                ),
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
                    params.direction,
                    pitchAngle,
                    {x0, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x1, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x2, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x3, -3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x3, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
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
                    params.direction,
                    pitchAngle,
                    {x0, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    {x1, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, halfIslandWidth, 0},
                    {x1, halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, streetFullWidth + distance + halfIslandWidth, 0},
                    {x1, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                    {x1, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    {x2, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, halfIslandWidth, 0},
                    {x2, halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, streetFullWidth + distance + halfIslandWidth, 0},
                    {x2, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                    {x2, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    {x3, - 2.0 * streetFullWidth - 2.0 * distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, -streetFullWidth - distance - halfIslandWidth, 0},
                    {x3, -streetFullWidth - distance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, halfIslandWidth, 0},
                    {x3, halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, streetFullWidth + distance + halfIslandWidth, 0},
                    {x3, streetFullWidth + distance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0},
                    {x3, 2.0 * streetFullWidth + 2.0 * distance + halfIslandWidth, 0}
                ),
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
                    params.direction,
                    pitchAngle,
                    {x0, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    {x1, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x1, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesLowX(params, true),
                snapNodes = _getSnapNodesLowX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x0, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                    {x1, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesLowX(params),
                snapNodes = _getSnapNodesLowX(params)
            },
            -- centre x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    {x2, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x2, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesCentre(params, true),
                snapNodes = _getSnapNodesCentre(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x1, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                    {x2, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesCentre(params),
                snapNodes = _getSnapNodesCentre(params)
            },
            -- high x
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    {x3, - 5.0 * streetHalfWidth - 5.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    {x3, - 3.0 * streetHalfWidth - 3.0 * halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    {x3, -streetHalfWidth - halfDistance - halfIslandWidth, 0},
                    true
                ),
                freeNodes = _getFreeNodesHighX(params, true),
                snapNodes = _getSnapNodesHighX(params, true)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, streetHalfWidth + halfDistance + halfIslandWidth, 0},
                    {x3, streetHalfWidth + halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0},
                    {x3, 3.0 * streetHalfWidth + 3.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            },
            {
                type = 'STREET',
                params = edgeParams,
                edges = _makeEdgesWithPitch(
                    params.direction,
                    pitchAngle,
                    {x2, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0},
                    {x3, 5.0 * streetHalfWidth + 5.0 * halfDistance + halfIslandWidth, 0}
                ),
                freeNodes = _getFreeNodesHighX(params),
                snapNodes = _getSnapNodesHighX(params)
            }
        }
    end
    return edgeLists
end

helper.getStreetHairpinSnapEdgeLists = function(params, streetData, tramTrackType)
    local streetHalfWidth = _getStreetHalfWidth(streetData)
    local widthFactorBend = _getWidthFactor(streetHalfWidth)
    -- this is the fruit of trial and error, see the notes
    local xMax = math.max(9.0, streetHalfWidth + 1.0)
    -- local xMax = streetHalfWidth + 1.0 -- LOLLO TODO check this, it might need extending
    local edgeParams = {
        skipCollision = true,
        type = streetData.fileName,
        tramTrackType = tramTrackType
    }
    local edgeLists = {
        {
            type = 'STREET',
            params = edgeParams,
            edges = _makeEdges(
                params.direction,
                {-xMax, -widthFactorBend * streetHalfWidth, 0},
                {0, -widthFactorBend * streetHalfWidth, 0},
                false,
                {xMax, 0, 0},
                {xMax, 0, 0}
            ),
            freeNodes = _getFreeNodesLowX(params),
            snapNodes = _getSnapNodesLowX(params)
        },
        {
            type = 'STREET',
            params = edgeParams,
            edges = {},
            freeNodes = _getFreeNodesCentre(params),
            snapNodes = _getSnapNodesCentre(params),
        },
        {
            type = 'STREET',
            params = edgeParams,
            edges = _makeEdges(
                params.direction,
                {0, widthFactorBend * streetHalfWidth, 0},
                {-xMax, widthFactorBend * streetHalfWidth, 0},
                false,
                {-xMax, 0, 0},
                {-xMax, 0, 0}
            ),
            freeNodes = _getFreeNodesHighX(params),
            snapNodes = _getSnapNodesHighX(params)
        }
    }

    if params.direction == 0 then
        streetUtil.addEdgeAutoTangents(
            edgeLists[2].edges,
            vec3.new(0, -widthFactorBend * streetHalfWidth, 0),
            vec3.new(0, widthFactorBend * streetHalfWidth, 0),
            vec3.new(1, 0, 0),
            vec3.new(-1, 0, 0)
        )
    else
        streetUtil.addEdgeAutoTangents(
            edgeLists[2].edges,
            vec3.new(0, widthFactorBend * streetHalfWidth, 0),
            vec3.new(0, -widthFactorBend * streetHalfWidth, 0),
            vec3.new(1, 0, 0),
            vec3.new(-1, 0, 0)
        )
    end
    return edgeLists
end

return helper