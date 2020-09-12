local arrayUtils = require('lollo_street_tuning.arrayUtils')
local matrixUtils = require('lollo_street_tuning.matrix')
local streetUtils = require('lollo_street_tuning.streetUtils')
local stringUtils = require('lollo_street_tuning.stringUtils')
local transfUtils = require('lollo_street_tuning.transfUtils')
-- local debugger = require('debugger')
-- local luadump = require('lollo_street_tuning/luadump')

if math.atan2 == nil then
	math.atan2 = function(dy, dx)
		local result = 0
		if dx == 0 then
			result = math.pi * 0.5
		else
			result = math.atan(dy / dx)
		end

		if dx > 0 then
			return result
		elseif dx < 0 and dy >= 0 then
			return result + math.pi
		elseif dx < 0 and dy < 0 then
			return result - math.pi
		elseif dy > 0 then
			return result
		elseif dy < 0 then
			return - result
		else return false
		end
	end
end

local helper = {}

helper.getVectorLength = function(xyz)
    if type(xyz) ~= 'table' then return nil end
    local x = xyz.x or xyz[1] or 0.0
    local y = xyz.y or xyz[2] or 0.0
    local z = xyz.z or xyz[3] or 0.0
    return math.sqrt(x * x + y * y + z * z)
end

helper.getNearbyEntities = function(transf)
    if type(transf) ~= 'table' then return {} end

    -- debugger()
    local edgeSearchRadius = 0.0
    local squareCentrePosition = transfUtils.getVec123Transformed({0, 0, 0}, transf)
    local results = game.interface.getEntities(
        {pos = squareCentrePosition, radius = edgeSearchRadius},
        {includeData = true}
        -- {includeData = true}
    )

    return results
end

local function swap(num1, num2)
    local swapTemp = num1
    num1 = num2
    num2 = swapTemp
end

local function _getVerticesSorted(unsorted)
    local maxY2 = 1
    for i = 2, 4 do
        if unsorted[i].y > unsorted[maxY2].y then
            maxY2 = i
        elseif unsorted[i].y == unsorted[maxY2].y then
            if unsorted[i].x < unsorted[maxY2].x then
                maxY2 = i
            end
        end
    end

    local maxY1 = maxY2 == 1 and 2 or 1
    for i = 1, 4 do
        if i ~= maxY2 then
            if unsorted[i].y > unsorted[maxY1].y then
                maxY1 = i
            elseif unsorted[i].y == unsorted[maxY1].y then
                if unsorted[i].x < unsorted[maxY1].x then
                    maxY1 = i
                end
            end
        end
    end

    local minY1 = 0
    for i = 1, 4 do
        if i ~= maxY2 and i ~= maxY1 then minY1 = i end
    end
    for i = 1, 4 do
        if i ~= maxY2 and i ~= maxY1 then
            if unsorted[i].y > unsorted[minY1].y then
                minY1 = i
            elseif unsorted[i].y == unsorted[minY1].y then
                if unsorted[i].x < unsorted[minY1].x then
                    minY1 = i
                end
            end
        end
    end

    local minY2 = 0
    for i = 1, 4 do
        if i ~= maxY2 and i ~= maxY1 and i ~= minY1 then minY2 = i end
    end
    -- what if maxY2 and (minY1 or minY2) have the same y? maxY2 will be left of them.

    -- print('unsorted with new indexes =')
    -- debugPrint(unsorted[maxY2])
    -- debugPrint(unsorted[maxY1])
    -- debugPrint(unsorted[minY1])
    -- debugPrint(unsorted[minY2])
    local result = {
        topLeft = unsorted[maxY2].x < unsorted[maxY1].x and unsorted[maxY2] or unsorted[maxY1],
        topRight = unsorted[maxY2].x >= unsorted[maxY1].x and unsorted[maxY2] or unsorted[maxY1],
        bottomLeft = unsorted[minY1].x < unsorted[minY2].x and unsorted[minY1] or unsorted[minY2],
        bottomRight = unsorted[minY1].x >= unsorted[minY2].x and unsorted[minY1] or unsorted[minY2],
    }
    return result
end

local function _getIsPointWithin(sortedVertices, position)
    if position[1] < sortedVertices.topLeft.x and position[1] < sortedVertices.bottomLeft.x then return false end
    if position[1] > sortedVertices.topRight.x and position[1] > sortedVertices.bottomRight.x then return false end
    if position[2] > sortedVertices.topLeft.y and position[2] > sortedVertices.topRight.y then return false end
    if position[2] < sortedVertices.bottomLeft.y and position[2] < sortedVertices.bottomRight.y then return false end

    print('thinking')
    -- y = a + bx
    -- y0 = a + b * x0
    -- y1 = a + b * x1
    -- y0 - y1 = b * (x0 - x1)  =>  b = (y0 - y1) / (x0 - x1)
    -- a = y0 - b * x0
    if sortedVertices.topLeft.x == sortedVertices.topRight.x then
        print('infinite') -- LOLLO TODO check the sign of all 4 infinites
        if position[1] < sortedVertices.topLeft.x then return false end
    else
        local b = (sortedVertices.topLeft.y - sortedVertices.topRight.y) / (sortedVertices.topLeft.x - sortedVertices.topRight.x)
        local a = sortedVertices.topLeft.y - b * sortedVertices.topLeft.x
        if position[2] > a + b * position[1] then return false end
    end

    if sortedVertices.topRight.x == sortedVertices.bottomRight.x then
        print('infinite')
        if position[1] > sortedVertices.topRight.x then return false end
    else
        local b = (sortedVertices.topRight.y - sortedVertices.bottomRight.y) / (sortedVertices.topRight.x - sortedVertices.bottomRight.x)
        local a = sortedVertices.topRight.y - b * sortedVertices.topRight.x
        if position[2] < a + b * position[1] then return false end
    end

    if sortedVertices.bottomRight.x == sortedVertices.bottomLeft.x then
        print('infinite')
        if position[1] > sortedVertices.bottomRight.x then return false end
    else
        local b = (sortedVertices.bottomRight.y - sortedVertices.bottomLeft.y) / (sortedVertices.bottomRight.x - sortedVertices.bottomLeft.x)
        local a = sortedVertices.bottomRight.y - b * sortedVertices.bottomRight.x
        if position[2] < a + b * position[1] then return false end
    end

    if sortedVertices.bottomLeft.x == sortedVertices.topLeft.x then
        print('infinite')
        if position[1] < sortedVertices.bottomLeft.x then return false end
    else
        local b = (sortedVertices.bottomLeft.y - sortedVertices.topLeft.y) / (sortedVertices.bottomLeft.x - sortedVertices.topLeft.x)
        local a = sortedVertices.bottomLeft.y - b * sortedVertices.bottomLeft.x
        if position[2] > a + b * position[1] then return false end
    end
-- LOLLO TODO this estimator is not so good yet
    print('point is within. position =')
    debugPrint(position)
    print('sortedVertices =')
    debugPrint(sortedVertices)
    return true
end

helper.getNearestEdgeId = function(transf)
    if type(transf) ~= 'table' then return nil end

    local result = nil
    local position = transfUtils.getVec123Transformed({0, 0, 0}, transf)
    local _searchRadius = 0.5
    -- local box0 = api.type.Box3.new(api.type.Vec3f.new(-1136, -1580, 0), api.type.Vec3f.new(-1134, -1578, 100))
    local box0 = api.type.Box3.new(
        api.type.Vec3f.new(position[1] - _searchRadius, position[2] - _searchRadius, -9999),
        api.type.Vec3f.new(position[1] + _searchRadius, position[2] + _searchRadius, 9999)
    )
    -- local callback0 = function(entity, buondingVolume) return entity end
    local callback0 = function(entity, boundingVolume)
        -- debugPrint(entity)
        -- debugPrint(boundingVolume)
        print('callback0 found entity', entity)
        if not(entity) or result then return end

        print('going on')
        if not(api.engine.getComponent(entity, api.type.ComponentType.BASE_EDGE)) then return end
        -- this returns the usual edge data, like:
--[[         local sample = {
            node0 = 27290,
            node1 = 27291,
            tangent0 = {
              x = -85.331359863281,
              y = -40.367069244385,
              z = 5.1617665290833,
            },
            tangent1 = {
              x = -85.331359863281,
              y = -40.367069244385,
              z = 5.1617660522461,
            },
            type = 0,
            typeIndex = -1,
            objects = { },
          } ]]
        -- api.engine.getComponent(entity, api.type.ComponentType.TRANSPORT_NETWORK)
        -- this returns all the lanes as separate edges, the result looks like
--[[         local sample = {
            nodes = {
            },
            edges = {
              [1] = {
                conns = {
                  [1] = {
                    new = nil,
                    entity = 27290,
                    index = 0,
                  },
                  [2] = {
                    new = nil,
                    entity = 27291,
                    index = 0,
                  },
                },
                geometry = {
                  params = {
                    pos = {
                      x = -1131.1846923828,
                      y = -1550.6062011719,
                    },
                    tangent = {
                      x = -85.331359863281,
                      y = -40.367069244385,
                    },
                    offset = 7,
                  },
                  tangent = {
                    x = 5.1617665290833,
                    y = 5.1617660522461,
                  },
                  height = {
                    x = 19.267086029053,
                    y = 24.428852081299,
                  },
                  length = 94.538864135742,
                  width = 2,
                },
                transportModes = {
                  [1] = 1,
                  [2] = 1,
                  [3] = 0,
                  [4] = 0,
                  [5] = 0,
                  [6] = 0,
                  [7] = 0,
                  [8] = 0,
                  [9] = 0,
                  [10] = 0,
                  [11] = 0,
                  [12] = 0,
                  [13] = 0,
                  [14] = 0,
                  [15] = 0,
                  [16] = 0,
                },
                speedLimit = 0,
                curveSpeedLimit = 0,
                curSpeed = 0,
                precedence = false,
              },
              [2] = {
                conns = {
                  [1] = {
                    new = nil,
                    entity = 27290,
                    index = 2,
                  },
                  [2] = {
                    new = nil,
                    entity = 27291,
                    index = 2,
                  },
                },
                geometry = {
                  params = {
                    pos = {
                      x = -1131.1846923828,
                      y = -1550.6062011719,
                    },
                    tangent = {
                      x = -85.331359863281,
                      y = -40.367069244385,
                    },
                    offset = 3,
                  },
                  tangent = {
                    x = 5.1617665290833,
                    y = 5.1617660522461,
                  },
                  height = {
                    x = 18.967086791992,
                    y = 24.128852844238,
                  },
                  length = 94.538864135742,
                  width = 6,
                },
                transportModes = {
                  [1] = 0,
                  [2] = 0,
                  [3] = 1,
                  [4] = 1,
                  [5] = 1,
                  [6] = 0,
                  [7] = 0,
                  [8] = 0,
                  [9] = 0,
                  [10] = 0,
                  [11] = 0,
                  [12] = 0,
                  [13] = 0,
                  [14] = 0,
                  [15] = 0,
                  [16] = 0,
                },
                speedLimit = 13.888889312744,
                curveSpeedLimit = 160.00799560547,
                curSpeed = 9.1666669845581,
                precedence = false,
              },
              [3] = {
                conns = {
                  [1] = {
                    new = nil,
                    entity = 27290,
                    index = 3,
                  },
                  [2] = {
                    new = nil,
                    entity = 27291,
                    index = 3,
                  },
                },
                geometry = {
                  params = {
                    pos = {
                      x = -1131.1846923828,
                      y = -1550.6062011719,
                    },
                    tangent = {
                      x = -85.331359863281,
                      y = -40.367069244385,
                    },
                    offset = -3,
                  },
                  tangent = {
                    x = 5.1617665290833,
                    y = 5.1617660522461,
                  },
                  height = {
                    x = 18.967086791992,
                    y = 24.128852844238,
                  },
                  length = 94.538856506348,
                  width = 6,
                },
                transportModes = {
                  [1] = 0,
                  [2] = 0,
                  [3] = 0,
                  [4] = 1,
                  [5] = 1,
                  [6] = 1,
                  [7] = 1,
                  [8] = 0,
                  [9] = 0,
                  [10] = 0,
                  [11] = 0,
                  [12] = 0,
                  [13] = 0,
                  [14] = 0,
                  [15] = 0,
                  [16] = 0,
                },
                speedLimit = 13.888889312744,
                curveSpeedLimit = 160.00799560547,
                curSpeed = 9.1666669845581,
                precedence = false,
              },
              [4] = {
                conns = {
                  [1] = {
                    new = nil,
                    entity = 27290,
                    index = 1,
                  },
                  [2] = {
                    new = nil,
                    entity = 27291,
                    index = 1,
                  },
                },
                geometry = {
                  params = {
                    pos = {
                      x = -1131.1846923828,
                      y = -1550.6062011719,
                    },
                    tangent = {
                      x = -85.331359863281,
                      y = -40.367069244385,
                    },
                    offset = -7,
                  },
                  tangent = {
                    x = 5.1617665290833,
                    y = 5.1617660522461,
                  },
                  height = {
                    x = 19.267086029053,
                    y = 24.428852081299,
                  },
                  length = 94.538864135742,
                  width = 2,
                },
                transportModes = {
                  [1] = 1,
                  [2] = 1,
                  [3] = 0,
                  [4] = 0,
                  [5] = 0,
                  [6] = 0,
                  [7] = 0,
                  [8] = 0,
                  [9] = 0,
                  [10] = 0,
                  [11] = 0,
                  [12] = 0,
                  [13] = 0,
                  [14] = 0,
                  [15] = 0,
                  [16] = 0,
                },
                speedLimit = 0,
                curveSpeedLimit = 0,
                curSpeed = 0,
                precedence = false,
              },
            },
          } ]]
        print('about to get the lots')
        local lotList = api.engine.getComponent(entity, api.type.ComponentType.LOT_LIST)
        if not(lotList) or not(lotList.lots) then return end

        print('got the lots')
        for _, value in pairs(lotList.lots) do
            print('trying')
            if _getIsPointWithin(_getVerticesSorted(value.vertices), position) then
                result = entity
                return
            end
        end
        -- this returns the rectangles drawn over by the edge:
--[[         local sample = {
        lots = {
            [1] = {
            vertices = {
                [1] = {
                x = -1133.7504882812,
                y = -1545.1824951172,
                },
                [2] = {
                x = -1128.6188964844,
                y = -1556.0299072266,
                },
                [3] = {
                x = -1219.0819091797,
                y = -1585.5495605469,
                },
                [4] = {
                x = -1213.9503173828,
                y = -1596.3969726562,
                },
            },
            texCoords = {
                [1] = {
                x = -1133.7504882812,
                y = -1545.1824951172,
                },
                [2] = {
                x = -1128.6188964844,
                y = -1556.0299072266,
                },
                [3] = {
                x = -1219.0819091797,
                y = -1585.5495605469,
                },
                [4] = {
                x = -1213.9503173828,
                y = -1596.3969726562,
                },
            },
            triangles = {
                [1] = 0,
                [2] = 2,
                [3] = 1,
                [4] = 3,
                [5] = 1,
                [6] = 2,
            },
            texKey = "street_fill.lua",
            solid = false,
            },
            [2] = {
            vertices = {
                [1] = {
                x = -1127.763671875,
                y = -1557.837890625,
                },
                [2] = {
                x = -1127.1223144531,
                y = -1559.1938476562,
                },
                [3] = {
                x = -1213.0950927734,
                y = -1598.2049560547,
                },
                [4] = {
                x = -1212.4537353516,
                y = -1599.5609130859,
                },
            },
            texCoords = {
                [1] = {
                x = 0,
                y = 0,
                },
                [2] = {
                x = 0,
                y = 1,
                },
                [3] = {
                x = 2.9543392658234,
                y = 0,
                },
                [4] = {
                x = 2.9543392658234,
                y = 1,
                },
            },
            triangles = {
                [1] = 0,
                [2] = 2,
                [3] = 1,
                [4] = 3,
                [5] = 1,
                [6] = 2,
            },
            texKey = "street_border.lua",
            solid = false,
            },
            [3] = {
            vertices = {
                [1] = {
                x = -1128.6188964844,
                y = -1556.0299072266,
                },
                [2] = {
                x = -1127.763671875,
                y = -1557.837890625,
                },
                [3] = {
                x = -1213.9503173828,
                y = -1596.3969726562,
                },
                [4] = {
                x = -1213.0950927734,
                y = -1598.2049560547,
                },
            },
            texCoords = {
                [1] = {
                x = 0,
                y = 0,
                },
                [2] = {
                x = 0,
                y = 1,
                },
                [3] = {
                x = 94.538856506348,
                y = 0,
                },
                [4] = {
                x = 94.538856506348,
                y = 1,
                },
            },
            triangles = {
                [1] = 0,
                [2] = 2,
                [3] = 1,
                [4] = 3,
                [5] = 1,
                [6] = 2,
            },
            texKey = "street_sidewalk_fill.lua",
            solid = false,
            },
            [4] = {
            vertices = {
                [1] = {
                x = -1219.9371337891,
                y = -1583.7415771484,
                },
                [2] = {
                x = -1220.5784912109,
                y = -1582.3856201172,
                },
                [3] = {
                x = -1134.6057128906,
                y = -1543.3745117188,
                },
                [4] = {
                x = -1135.2470703125,
                y = -1542.0185546875,
                },
            },
            texCoords = {
                [1] = {
                x = 0,
                y = 0,
                },
                [2] = {
                x = 0,
                y = 1,
                },
                [3] = {
                x = 2.9543392658234,
                y = 0,
                },
                [4] = {
                x = 2.9543392658234,
                y = 1,
                },
            },
            triangles = {
                [1] = 0,
                [2] = 2,
                [3] = 1,
                [4] = 3,
                [5] = 1,
                [6] = 2,
            },
            texKey = "street_border.lua",
            solid = false,
            },
            [5] = {
            vertices = {
                [1] = {
                x = -1219.0819091797,
                y = -1585.5495605469,
                },
                [2] = {
                x = -1219.9371337891,
                y = -1583.7415771484,
                },
                [3] = {
                x = -1133.7504882812,
                y = -1545.1824951172,
                },
                [4] = {
                x = -1134.6057128906,
                y = -1543.3745117188,
                },
            },
            texCoords = {
                [1] = {
                x = 0,
                y = 0,
                },
                [2] = {
                x = 0,
                y = 1,
                },
                [3] = {
                x = 94.538856506348,
                y = 0,
                },
                [4] = {
                x = 94.538856506348,
                y = 1,
                },
            },
            triangles = {
                [1] = 0,
                [2] = 2,
                [3] = 1,
                [4] = 3,
                [5] = 1,
                [6] = 2,
            },
            texKey = "street_sidewalk_fill.lua",
            solid = false,
            },
            [6] = {
            vertices = {
                [1] = {
                x = -1127.763671875,
                y = -1557.837890625,
                },
                [2] = {
                x = -1127.1221923828,
                y = -1559.1938476562,
                },
                [3] = {
                x = -1126.4077148438,
                y = -1557.1964111328,
                },
                [4] = {
                x = -1133.2497558594,
                y = -1542.7330322266,
                },
                [5] = {
                x = -1135.2471923828,
                y = -1542.0185546875,
                },
                [6] = {
                x = -1134.6057128906,
                y = -1543.3745117188,
                },
            },
            texCoords = {
                [1] = {
                x = 0,
                y = 0,
                },
                [2] = {
                x = -2.1213202476501,
                y = 1,
                },
                [3] = {
                x = 0,
                y = 1,
                },
                [4] = {
                x = 16.000089645386,
                y = 1,
                },
                [5] = {
                x = 18.121410369873,
                y = 1,
                },
                [6] = {
                x = 16.000089645386,
                y = 0,
                },
            },
            triangles = {
                [1] = 0,
                [2] = 1,
                [3] = 2,
                [4] = 0,
                [5] = 2,
                [6] = 3,
                [7] = 0,
                [8] = 3,
                [9] = 5,
                [10] = 5,
                [11] = 3,
                [12] = 4,
            },
            texKey = "street_border.lua",
            solid = false,
            },
        },
        } ]]
    end
    api.engine.system.octreeSystem.findIntersectingEntities(box0, callback0)
    -- 27360
    -- 27289

    return result
end

helper.getXKey = function(x)
    return tostring(x)
end

helper.getYKey = function(y)
    return tostring(y)
end

helper.getNodeBetween = function(position0, tangent0, position1, tangent1, betweenPosition)
    if not(position0) or not(position1) or not(tangent0) or not(tangent1) then return nil end

    -- print('AAAAAAAAAAAAAAAAAAA')
    local node01Distance = helper.getVectorLength({
        position1.x - position0.x,
        position1.y - position0.y,
        position1.z - position0.z
    })
    if node01Distance == 0 then return nil end

    local x20Shift = type(betweenPosition) ~= 'table'
        and
            0.5
        or
            helper.getVectorLength({
                betweenPosition[1] - position0.x,
                betweenPosition[2] - position0.y,
                -- betweenPosition[3] - position0.z
                -- 0.0
            })
            /
            node01Distance
    local x0 = position0.x
    local x1 = position1.x
    local y0 = position0.y
    local y1 = position1.y
    local ypsilon0 = math.atan2(tangent0.y, tangent0.x)
    local ypsilon1 = math.atan2(tangent1.y, tangent1.x)
    local z0 = position0.z
    local z1 = position1.z
    -- rotate the edges around the Z axis so that y0 = y1
    local zRotation = -math.atan2(y1 - y0, x1 - x0)
    local x0I = x0
    local x1I = x0 + helper.getVectorLength({x1 - x0, y1 - y0, 0.0})
    local y0I = y0
    local z0I = z0
    local z1I = z1

    local invertedXMatrix = matrixUtils.invert(
        {
            {1, x0I, x0I * x0I, x0I * x0I * x0I},
            {1, x1I, x1I * x1I, x1I * x1I * x1I},
            {0, 1, 2 * x0I, 3 * x0I * x0I},
            {0, 1, 2 * x1I, 3 * x1I * x1I}
        }
    )

    -- Now I solve the system for y:
    -- a + b x0' + c x0'^2 + d x0'^3 = y0'
    -- a + b x1' + c x1'^2 + d x1'^3 = y0' .. y0' == y1' by construction
    -- b + 2 c x0' + 3 d x0'^2 = sin0' / cos0'
    -- b + 2 c x1' + 3 d x1'^2 = sin1' / cos1'
    local abcdY = matrixUtils.mul(
        invertedXMatrix,
        {
            {y0I},
            {y0I},
            {math.tan(ypsilon0 + zRotation)}, -- {sin0I / cos0I}, -- risk of division by zero
            {math.tan(ypsilon1 + zRotation)}, -- {sin1I / cos1I}, -- risk of division by zero
        }
    )
    local aY = abcdY[1][1]
    local bY = abcdY[2][1]
    local cY = abcdY[3][1]
    local dY = abcdY[4][1]

    -- Now I solve the system for z:
    -- a + b x0' + c x0'^2 + d x0'^3 = z0'
    -- a + b x1' + c x1'^2 + d x1'^3 = z1'
    -- b + 2 c x0' + 3 d x0'^2 = sin0' / cos0'
    -- b + 2 c x1' + 3 d x1'^2 = sin1' / cos1'
    local abcdZ = matrixUtils.mul(
        invertedXMatrix,
        {
            {z0I},
            {z1I},
            {tangent0.z / helper.getVectorLength({tangent0.x, tangent0.y, 0.0})},
            {tangent1.z / helper.getVectorLength({tangent1.x, tangent1.y, 0.0})},
        }
    )
    local aZ = abcdZ[1][1]
    local bZ = abcdZ[2][1]
    local cZ = abcdZ[3][1]
    local dZ = abcdZ[4][1]

    -- Now I take x2' between x0' and x1',
    local x2I = x0I + (x1I - x0I) * x20Shift
    local y2I = aY + bY * x2I + cY * x2I * x2I + dY * x2I * x2I * x2I
    local z2I = aZ + bZ * x2I + cZ * x2I * x2I + dZ * x2I * x2I * x2I
    -- calculate its y derivative:
    local DYOnDX2I = bY + 2 * cY * x2I + 3 * dY * x2I * x2I
    local ypsilon2I = math.atan(DYOnDX2I)
    -- calculate its z derivative:
    local DZOnDX2I = bZ + 2 * cZ * x2I + 3 * dZ * x2I * x2I
    local zeta2I = math.atan(DZOnDX2I)

    -- Now I undo the rotation I did at the beginning
    local ro2 = helper.getVectorLength({x2I - x0I, y2I - y0I, 0.0})
    local alpha2I = math.atan2(y2I - y0I, x2I - x0I)

    local nodeBetween = {
        position = {
            x0I + ro2 * math.cos(alpha2I - zRotation),
            y0I + ro2 * math.sin(alpha2I - zRotation),
            z2I
        },
        tangent = {
            math.cos(ypsilon2I - zRotation), -- * ro2,
            math.sin(ypsilon2I - zRotation), -- * ro2,
            -- math.sin(zeta2I) * math.cos(ypsilon2I - zRotation) / math.cos(zeta2I)
            math.sin(zeta2I)
            -- math.sin(zeta2I) * math.cos(ypsilon2I - zRotation)
            -- math.sin(zeta2I) * math.cos(- zRotation)
        }
    }

    -- normalise tangent
    local tangentLength = helper.getVectorLength(nodeBetween.tangent)
    if tangentLength ~= 0 and tangentLength ~= 1 then
        nodeBetween.tangent[1] = nodeBetween.tangent[1] / tangentLength
        nodeBetween.tangent[2] = nodeBetween.tangent[2] / tangentLength
        nodeBetween.tangent[3] = nodeBetween.tangent[3] / tangentLength
    end

    return nodeBetween
end

return helper