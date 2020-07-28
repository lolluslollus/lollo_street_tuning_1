local arrayUtils = require('lollo_street_tuning.lolloArrayUtils')
local matrixUtils = require('lollo_street_tuning.matrix')
local streetUtils = require('lollo_street_tuning.lolloStreetUtils')
local transfUtils = require('lollo_street_tuning.transfUtils')
local debugger = require('debugger')
local luadump = require('lollo_street_tuning/luadump')

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
-- helper.getNearbyStreetEdges = function(position, edgeSearchRadius)
--     -- if you want to use this, you may have to account for the transformation
--     if type(position) ~= 'table' then return {} end

--     local nearbyEdges = game.interface.getEntities(
--         {pos = position, radius = edgeSearchRadius},
--         -- {type = "BASE_EDGE", includeData = true}
--         {includeData = true}
--     )

--     local results = {}
--     for i, v in pairs(nearbyEdges) do
--         if not v.track and v.streetType then
--             table.insert(results, v)
--         end
--     end

--     return results
-- end

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

helper.getNearbyStreetEdges = function(transf)
    -- LOLLO TODO only return edges that are long enough
    -- if you want to use this, you may have to account for the transformation
    if type(transf) ~= 'table' then return {} end

    -- debugger()
    -- local edgeSearchRadius = _constants.xMax * _constants.xTransfFactor -- * 0.7071
    local edgeSearchRadius = 0.0
    local squareCentrePosition = transfUtils.getVec123Transformed({0, 0, 0}, transf)
    local nearbyEdges = game.interface.getEntities(
        {pos = squareCentrePosition, radius = edgeSearchRadius},
        {type = "BASE_EDGE", includeData = true}
        -- {includeData = true}
    )
    local sampleNearbyEdges = {
        [27346] = {
            ["node0pos"] = {503.47393798828, -3262.2072753906, 15.127754211426},
            ["node0tangent"] = {11.807357788086, -53.536338806152, -1.3161367177963},
            ["node1tangent"] = {39.382007598877, -39.382049560547, -1.2736799716949},
            ["type"] = "BASE_EDGE",
            ["hasTram"] = false,
            ["id"] = 27346,
            ["node1"] = 25371,
            ["track"] = false,
            ["streetType"] = "standard/country_small_new.lua",
            ["node0"] = 27343,
            ["hasBus"] = false,
            ["node1pos"] = {529.49230957031, -3309.6865234375, 13.174621582031}
        },
        [27350] = {
            ["node0pos"] = {529.49230957031, -3309.6865234375, 13.174621582031},
            ["node0tangent"] = {55.327167510986, -55.327224731445, -1.7893730401993},
            ["node1tangent"] = {15.339179992676, -76.696083068848, 2.7962200641632},
            ["type"] = "BASE_EDGE",
            ["hasTram"] = false,
            ["id"] = 27350,
            ["node1"] = 25826,
            ["track"] = false,
            ["streetType"] = "standard/country_small_new.lua",
            ["node0"] = 25371,
            ["hasBus"] = false,
            ["node1pos"] = {565.62121582031, -3377.1943359375, 13.753684997559}
        }
    }


    local results = {}
    local streetTypes = streetUtils.getGlobalStreetData()
    for _, edgeData in pairs(nearbyEdges) do
        -- discard paths and other unsuitable street types
        if not edgeData.track and edgeData.streetType then
            if arrayUtils.findIndex(streetTypes, 'fileName', edgeData.streetType) > -1 then
                table.insert(results, edgeData)
            end
        end
    end

    return results
end

helper.getXKey = function(x)
    return tostring(x)
end

helper.getYKey = function(y)
    return tostring(y)
end

helper.getNodeBetween = function(node0, node1, betweenPosition)
    if type(node0) ~= 'table' or type(node1) ~= 'table' or type(betweenPosition) ~= 'table' then return nil end

    print('LOLLO node0[1] =')
    debugPrint(node0[1])
    print('LOLLO midPosition =')
    debugPrint(betweenPosition)
    print('LOLLO node1[1] =')
    debugPrint(node1[1])
    local node01Distance = helper.getVectorLength({
        node1[1][1] - node0[1][1],
        node1[1][2] - node0[1][2],
        node1[1][3] - node0[1][3]
    })
    local x20Shift = node01Distance == 0
        and
            0.5
        or
            helper.getVectorLength({
                betweenPosition[1] - node0[1][1],
                betweenPosition[2] - node0[1][2],
                betweenPosition[3] - node0[1][3]
            })
            /
            node01Distance
    print('LOLLO x20Shift =')
    debugPrint(x20Shift)
    -- correct but useless
    -- local node0NormalisationFactor = helper.getVectorLength(node0[1])
    -- if node0NormalisationFactor == 0 then node0NormalisationFactor = math.huge else node0NormalisationFactor = 1.0 / node0NormalisationFactor end
    -- local node1NormalisationFactor = helper.getVectorLength(node1[1])
    -- if node1NormalisationFactor == 0 then node1NormalisationFactor = math.huge else node1NormalisationFactor = 1.0 / node1NormalisationFactor end
    local x0 = node0[1][1]
    local x1 = node1[1][1]
    local cos0 = node0[2][1]-- * node0NormalisationFactor -- correct but useless
    local cos1 = node1[2][1]-- * node1NormalisationFactor -- correct but useless
    local y0 = node0[1][2]
    local y1 = node1[1][2]
    local sin0 = node0[2][2]-- * node0NormalisationFactor -- correct but useless
    local sin1 = node1[2][2]-- * node1NormalisationFactor -- correct but useless
    local theta0 = math.atan2(sin0, cos0)
    local theta1 = math.atan2(sin1, cos1)
    local z0 = node0[1][3]
    local z1 = node1[1][3]
    -- rotate the edges around the Z axis so that y0 = y1
    local zRotation = -math.atan2(y1 - y0, x1 - x0)
    local x0I = x0
    local x1I = x0 + helper.getVectorLength({x1 - x0, y1 - y0, 0})
    -- local cos0I = math.cos(theta0 + zRotation)
    -- local cos1I = math.cos(theta1 + zRotation)
    local y0I = y0
    -- local y1I = y0
    -- local sin0I = math.sin(theta0 + zRotation)
    -- local sin1I = math.sin(theta1 + zRotation)
    -- local theta0I = math.atan2(sin0I, cos0I)
    -- local theta1I = math.atan2(sin1I, cos1I)

    -- Now I can solve the system:
    -- a + b x0' + c x0'^2 + d x0'^3 = y0'
    -- a + b x1' + c x1'^2 + d x1'^3 = y0'
    -- b + 2 c x0' + 3 d x0'^2 = sin0' / cos0'
    -- b + 2 c x1' + 3 d x1'^2 = sin1' / cos1'
    local abcdY = matrixUtils.mul(
        matrixUtils.invert(
            {
                {1, x0I, x0I * x0I, x0I * x0I * x0I},
                {1, x1I, x1I * x1I, x1I * x1I * x1I},
                {0, 1, 2 * x0I, 3 * x0I * x0I},
                {0, 1, 2 * x1I, 3 * x1I * x1I}
            }
        ),
        {
            {y0I},
            {y0I},
            {math.tan(theta0 + zRotation)}, -- {sin0I / cos0I}, -- LOLLO TODO risk of division by zero
            {math.tan(theta1 + zRotation)}, -- {sin1I / cos1I}
        }
    )

    local aY = abcdY[1][1]
    local bY = abcdY[2][1]
    local cY = abcdY[3][1]
    local dY = abcdY[4][1]
    -- Now I take x2' between x0' and x1',
    local x2I = x0I + (x1I - x0I) * x20Shift
    local y2I = aY + bY * x2I + cY * x2I * x2I + dY * x2I * x2I * x2I
    -- calculate its y derivative:
    local tan2I = bY + 2 * cY * x2I + 3 * dY * x2I * x2I
    -- Now I undo the rotation I did at the beginning
    local ro2 = helper.getVectorLength({x2I - x0I, y2I - y0I, 0})
    local alpha2I = math.atan2(y2I - y0I, x2I - x0I)
    local theta2I = math.atan(tan2I)

    local nodeBetween = {
        position = {
            x0I + ro2 * math.cos(alpha2I - zRotation),
            y0I + ro2 * math.sin(alpha2I - zRotation),
            0
        },
        tangent = {
            math.cos(theta2I - zRotation), -- * ro2,
            math.sin(theta2I - zRotation), -- * ro2,
            0
        }
    }
    -- add Z
    nodeBetween.position[3] = betweenPosition[3]
    -- add Z tan -- LOLLO TODO this is a linear interpolation, the game uses a 3rd degree polynom: use one for smoother gradients if needed
    nodeBetween.tangent[3] = node01Distance ~= 0
    and
        (node0[2][3] + (node1[2][3] - node0[2][3]) * x20Shift) / node01Distance
    or
        0

    local tangentLength = helper.getVectorLength(nodeBetween.tangent)
    if tangentLength ~= 0 and tangentLength ~= 1 then
        nodeBetween.tangent[1] = nodeBetween.tangent[1] / tangentLength
        nodeBetween.tangent[2] = nodeBetween.tangent[2] / tangentLength
        nodeBetween.tangent[3] = nodeBetween.tangent[3] / tangentLength
    end

    return nodeBetween
end

return helper