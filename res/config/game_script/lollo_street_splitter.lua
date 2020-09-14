local edgeUtils = require('lollo_street_tuning.edgeHelper')
local streetUtils = require('lollo_street_tuning.streetUtils')
local stringUtils = require('lollo_street_tuning/stringUtils')
local transfUtilUG = require('transf')

local function _isBuildingOneOfMine(param, fileName)
    local toAdd =
        type(param) == 'table' and type(param.proposal) == 'userdata' and type(param.proposal.toAdd) == 'userdata' and
        param.proposal.toAdd

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == fileName then
                return true
            end
        end
    end

    return false
end

local function _isBuildingStreetChanger(param)
    return _isBuildingOneOfMine(param, 'lollo_street_changer.con')
end

local function _isBuildingStreetGetInfo(param)
    return _isBuildingOneOfMine(param, 'lollo_street_get_info.con')
end

local function _isBuildingStreetSplitter(param)
    return _isBuildingOneOfMine(param, 'lollo_street_splitter.con')
end

local function _isBuildingStreetSplitterWithApi(param)
    return _isBuildingOneOfMine(param, 'lollo_street_splitter_w_api.con')
end

local function _isBuildingToggleAllTracks(param)
    return _isBuildingOneOfMine(param, 'lollo_toggle_all_tram_tracks.con')
end

local function _myErrorHandler(err)
    print('lollo street splitter ERROR: ', err)
end

local function _getToggledAllTramTracksStreetTypeFileName(streetFileName)
    if type(streetFileName) ~= 'string' or streetFileName == '' then return nil end

    -- print('KKKKKKKKKKKKKKKK')
    -- debugPrint(streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK))
    -- print('KKKKKKKKKKKKKKKK')
    local allStreetData = streetUtils.getGlobalStreetData(streetUtils.getStreetDataFilters().STOCK_AND_RESERVED_LANES)
    -- print('allStreetData has', #allStreetData, 'records')
    local oldStreetProperties = nil
    for _, value in pairs(allStreetData) do
        if stringUtils.stringEndsWith(streetFileName, value.fileName) then
            oldStreetProperties = value
            break
        end
    end
    if not(oldStreetProperties) then return nil end

    local sameSizeStreetsProperties = {}
    for _, value in pairs(allStreetData) do
        if value.fileName ~= streetFileName
        and value.isAllTramTracks ~= oldStreetProperties.isAllTramTracks
        and value.laneCount == oldStreetProperties.laneCount
        and value.sidewalkWidth == oldStreetProperties.sidewalkWidth
        and value.streetWidth == oldStreetProperties.streetWidth then
            sameSizeStreetsProperties[#sameSizeStreetsProperties+1] = value
        end
    end
    if #sameSizeStreetsProperties == 0 then return nil end

    -- print('sameSizeStreetsProperties =')
    -- debugPrint(sameSizeStreetsProperties)

    local getConcatCategories = function(arr)
        local result = ''
        for i = 1, #arr do
            result = result .. tostring(arr[i]):lower()
        end
        return result
    end

    local oldStreetCategoriesStr = getConcatCategories(oldStreetProperties.categories)

    for i = 1, #sameSizeStreetsProperties do
        -- LOLLO TODO this estimator may be a little weak.
        -- we need a new property in streetUtils._getStreetTypesWithApi
        -- to identify similar streets with different tarmac.
        -- For the moment, we can probably toggle multiple times.
        if getConcatCategories(sameSizeStreetsProperties[i].categories) == oldStreetCategoriesStr then
            return sameSizeStreetsProperties[i].fileName
        end
    end

    return nil
end

local function _replaceEdge(oldEdgeId)
    -- this replaces the street without destroying the buildings
    if type(oldEdgeId) ~= 'number' or oldEdgeId < 0 then return end

	local baseEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
    local playerOwned = api.engine.getComponent(oldEdgeId, api.type.ComponentType.PLAYER_OWNED)

	local newEdge = api.type.SegmentAndEntity.new()
	newEdge.entity = -1
	newEdge.type = 0
    newEdge.comp = baseEdge
    -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
    newEdge.playerOwned = playerOwned
	newEdge.streetEdge = baseEdgeStreet
	-- eo.streetEdge.streetType = api.res.streetTypeRep.find(streetEdgeEntity.streetType)

    local proposal = api.type.SimpleProposal.new()
	proposal.streetProposal.edgesToRemove[1] = oldEdgeId
    proposal.streetProposal.edgesToAdd[1] = newEdge
    --[[ local sampleNewEdge =
    {
      entity = -1,
      comp = {
        node0 = 13010,
        node1 = 18753,
        tangent0 = {
          x = -32.318000793457,
          y = 81.757850646973,
          z = 3.0953373908997,
        },
        tangent1 = {
          x = -34.457527160645,
          y = 80.931526184082,
          z = -1.0708819627762,
        },
        type = 0,
        typeIndex = -1,
        objects = { },
      },
      type = 0,
      params = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      playerOwned = nil,
      streetEdge = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      trackEdge = {
        trackType = -1,
        catenary = false,
      },
    } ]]

    local callback = function(res, success)
        -- print('LOLLO res = ')
		-- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        -- print('LOLLO success = ')
		-- debugPrint(success)
	end

	local cmd = api.cmd.make.buildProposal(proposal, nil, false)
	api.cmd.sendCommand(cmd, callback)
end

local function _replaceEdgeWithStreetType(oldEdgeId, newStreetTypeId)
    -- this replaces the street without destroying the buildings
    if type(oldEdgeId) ~= 'number' or oldEdgeId < 0
    or type(newStreetTypeId) ~= 'number' or newStreetTypeId < 0 then return end

	local baseEdge = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE)
	local baseEdgeStreet = api.engine.getComponent(oldEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
    local playerOwned = api.engine.getComponent(oldEdgeId, api.type.ComponentType.PLAYER_OWNED)

	local newEdge = api.type.SegmentAndEntity.new()
	newEdge.entity = -1
	newEdge.type = 0
    newEdge.comp = baseEdge
    -- newEdge.playerOwned = {player = api.engine.util.getPlayer()}
    newEdge.playerOwned = playerOwned
    newEdge.streetEdge = baseEdgeStreet
    newEdge.streetEdge.streetType = newStreetTypeId
    -- add tram tracks upgrade if the new street type wants so
    local _newStreetProperties = api.res.streetTypeRep.get(newStreetTypeId)
    if not(_newStreetProperties) or not(_newStreetProperties.laneConfigs) then return end

    if streetUtils.getIsStreetAllTramTracks(_newStreetProperties.laneConfigs) then
        newEdge.streetEdge.tramTrackType = 2
    end
	-- eo.streetEdge.streetType = api.res.streetTypeRep.find(streetEdgeEntity.streetType)

    local proposal = api.type.SimpleProposal.new()
	proposal.streetProposal.edgesToRemove[1] = oldEdgeId
    proposal.streetProposal.edgesToAdd[1] = newEdge
    --[[ local sampleNewEdge =
    {
      entity = -1,
      comp = {
        node0 = 13010,
        node1 = 18753,
        tangent0 = {
          x = -32.318000793457,
          y = 81.757850646973,
          z = 3.0953373908997,
        },
        tangent1 = {
          x = -34.457527160645,
          y = 80.931526184082,
          z = -1.0708819627762,
        },
        type = 0,
        typeIndex = -1,
        objects = { },
      },
      type = 0,
      params = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      playerOwned = nil,
      streetEdge = {
        streetType = 23,
        hasBus = false,
        tramTrackType = 0,
        precedenceNode0 = 2,
        precedenceNode1 = 2,
      },
      trackEdge = {
        trackType = -1,
        catenary = false,
      },
    } ]]

    local callback = function(res, success)
        -- print('LOLLO res = ')
		-- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        -- print('LOLLO success = ')
		-- debugPrint(success)
	end

	local cmd = api.cmd.make.buildProposal(proposal, nil, false)
	api.cmd.sendCommand(cmd, callback)
end

local function _getWhichEdgeGetsEdgeObjectAfterSplit(edgeObjPosition, node0pos, node1pos, nodeBetween)
    local result = {
        -- assignToFirstEstimate = nil,
        assignToSecondEstimate = nil,
    }
    -- print('LOLLO attempting to place edge object with position =')
    -- debugPrint(edgeObjPosition)
    -- print('wholeEdge.node0pos =')
    -- debugPrint(node0pos)
    -- print('nodeBetween.position =')
    -- debugPrint(nodeBetween.position)
    -- print('nodeBetween.tangent =')
    -- debugPrint(nodeBetween.tangent)
    -- print('wholeEdge.node1pos =')
    -- debugPrint(node1pos)
    -- first estimator
    -- local nodeBetween_Node0_Distance = edgeUtils.getVectorLength({
    --     nodeBetween.position[1] - node0pos[1],
    --     nodeBetween.position[2] - node0pos[2]
    -- })
    -- local nodeBetween_Node1_Distance = edgeUtils.getVectorLength({
    --     nodeBetween.position[1] - node1pos[1],
    --     nodeBetween.position[2] - node1pos[2]
    -- })
    -- local edgeObj_Node0_Distance = edgeUtils.getVectorLength({
    --     edgeObjPosition[1] - node0pos[1],
    --     edgeObjPosition[2] - node0pos[2]
    -- })
    -- local edgeObj_Node1_Distance = edgeUtils.getVectorLength({
    --     edgeObjPosition[1] - node1pos[1],
    --     edgeObjPosition[2] - node1pos[2]
    -- })
    -- if edgeObj_Node0_Distance < nodeBetween_Node0_Distance then
    --     result.assignToFirstEstimate = 0
    -- elseif edgeObj_Node1_Distance < nodeBetween_Node1_Distance then
    --     result.assignToFirstEstimate = 1
    -- end

    -- second estimator
    local edgeObjPosition_assignTo = nil
    local node0_assignTo = nil
    local node1_assignTo = nil
    -- at nodeBetween, I can draw the normal to the road:
    -- y = a + bx
    -- the angle is alpha = atan2(nodeBetween.tangent[2], nodeBetween.tangent[1]) + PI / 2
    -- so b = math.tan(alpha)
    -- a = y - bx
    -- so a = nodeBetween.position[2] - b * nodeBetween.position[1]
    -- points under this line will go one way, the others the other way
    local alpha = math.atan2(nodeBetween.tangent[2], nodeBetween.tangent[1]) + math.pi * 0.5
    local b = math.tan(alpha)
    if math.abs(b) < 1e+06 then
        local a = nodeBetween.position[2] - b * nodeBetween.position[1]
        if a + b * edgeObjPosition[1] > edgeObjPosition[2] then -- edgeObj is below the line
            edgeObjPosition_assignTo = 0
        else
            edgeObjPosition_assignTo = 1
        end
        if a + b * node0pos[1] > node0pos[2] then -- wholeEdge.node0pos is below the line
            node0_assignTo = 0
        else
            node0_assignTo = 1
        end
        if a + b * node1pos[1] > node1pos[2] then -- wholeEdge.node1pos is below the line
            node1_assignTo = 0
        else
            node1_assignTo = 1
        end
    -- if b grows too much, I lose precision, so I approximate it with the y axis
    else
        -- print('alpha =', alpha, 'b =', b)
        if edgeObjPosition[1] > nodeBetween.position[1] then
            edgeObjPosition_assignTo = 0
        else
            edgeObjPosition_assignTo = 1
        end
        if node0pos[1] > nodeBetween.position[1] then
            node0_assignTo = 0
        else
            node0_assignTo = 1
        end
        if node1pos[1] > nodeBetween.position[1] then
            node1_assignTo = 0
        else
            node1_assignTo = 1
        end
    end

    if edgeObjPosition_assignTo == node0_assignTo then
        result.assignToSecondEstimate = 0
    elseif edgeObjPosition_assignTo == node1_assignTo then
        result.assignToSecondEstimate = 1
    end

    -- print('LOLLO assignment =')
    -- debugPrint(result)
    return result
end

local function _splitEdge(wholeEdgeId, position0, tangent0, position1, tangent1, nodeBetween)
    if type(wholeEdgeId) ~= 'number' or wholeEdgeId < 0 or type(nodeBetween) ~= 'table' then return end

    local node0TangentLength = edgeUtils.getVectorLength({
        tangent0.x,
        tangent0.y,
        tangent0.z
    })
    local node1TangentLength = edgeUtils.getVectorLength({
        tangent1.x,
        tangent1.y,
        tangent1.z
    })
    local edge0Length = edgeUtils.getVectorLength({
        nodeBetween.position[1] - position0.x,
        nodeBetween.position[2] - position0.y,
        nodeBetween.position[3] - position0.z
    })
    local edge1Length = edgeUtils.getVectorLength({
        nodeBetween.position[1] - position1.x,
        nodeBetween.position[2] - position1.y,
        nodeBetween.position[3] - position1.z
    })

    local proposal = api.type.SimpleProposal.new()

    local baseEdge = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(wholeEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
    local playerOwned = api.type.PlayerOwned.new()
    playerOwned.player = api.engine.util.getPlayer()

    local newNodeBetween = api.type.NodeAndEntity.new()
    newNodeBetween.entity = -3
    newNodeBetween.comp.position = api.type.Vec3f.new(nodeBetween.position[1], nodeBetween.position[2], nodeBetween.position[3])

    local newEdge0 = api.type.SegmentAndEntity.new()
    newEdge0.entity = -1
    newEdge0.type = 0
    newEdge0.comp.node0 = baseEdge.node0
    newEdge0.comp.node1 = -3
    newEdge0.comp.tangent0 = api.type.Vec3f.new(
        tangent0.x * edge0Length / node0TangentLength,
        tangent0.y * edge0Length / node0TangentLength,
        tangent0.z * edge0Length / node0TangentLength
    )
    newEdge0.comp.tangent1 = api.type.Vec3f.new(
        nodeBetween.tangent[1] * edge0Length,
        nodeBetween.tangent[2] * edge0Length,
        nodeBetween.tangent[3] * edge0Length
    )
    newEdge0.comp.type = baseEdge.type -- 0 -- respect bridge or tunnel
    newEdge0.comp.typeIndex = baseEdge.typeIndex -- -1 -- respect bridge or tunnel
    newEdge0.playerOwned = playerOwned
    newEdge0.streetEdge = baseEdgeStreet

    local newEdge1 = api.type.SegmentAndEntity.new()
    newEdge1.entity = -2
    newEdge1.type = 0
    newEdge1.comp.node0 = -3
    newEdge1.comp.node1 = baseEdge.node1
    newEdge1.comp.tangent0 = api.type.Vec3f.new(
        nodeBetween.tangent[1] * edge1Length,
        nodeBetween.tangent[2] * edge1Length,
        nodeBetween.tangent[3] * edge1Length
    )
    newEdge1.comp.tangent1 = api.type.Vec3f.new(
        tangent1.x * edge1Length / node1TangentLength,
        tangent1.y * edge1Length / node1TangentLength,
        tangent1.z * edge1Length / node1TangentLength
    )
    newEdge1.comp.type = baseEdge.type -- 0
    newEdge1.comp.typeIndex = baseEdge.typeIndex -- -1
    newEdge1.playerOwned = playerOwned
    newEdge1.streetEdge = baseEdgeStreet

    if type(baseEdge.objects) == 'table' then
        local edge0Objects = {}
        local edge1Objects = {}
        for _, edgeObj in pairs(baseEdge.objects) do
            -- api.engine.getComponent(edgeObj[1], api.type.ComponentType.BOUNDING_VOLUME) returns a bounding volume without transf
            -- api.engine.getComponent(edgeObj[1], api.type.ComponentType.MODEL_INSTANCE_LIST) returns a transf that I cannot use
            local edgeObjEntity = game.interface.getEntity(edgeObj[1])
            if type(edgeObjEntity) == 'table' and type(edgeObjEntity.position) == 'table' then
                local assignment = _getWhichEdgeGetsEdgeObjectAfterSplit(
                    edgeObjEntity.position,
                    {position0.x, position0.y, position0.z},
                    {position1.x, position1.y, position1.z},
                    nodeBetween
                )
                -- if assignment.assignToFirstEstimate == 0 then
                if assignment.assignToSecondEstimate == 0 then
                    table.insert(edge0Objects, { edgeObj[1], edgeObj[2] })
                -- elseif assignment.assignToFirstEstimate == 1 then
                elseif assignment.assignToSecondEstimate == 1 then
                    table.insert(edge1Objects, { edgeObj[1], edgeObj[2] })
                else
                    print('dont change anything and leave')
                    -- don't change anything and leave
                    -- print('LOLLO error, assignment.assignToFirstEstimate =', assignment.assignToFirstEstimate)
                    -- print('LOLLO error, assignment.assignToSecondEstimate =', assignment.assignToSecondEstimate)
                    return
                end
            end
        end
        newEdge0.comp.objects = edge0Objects -- LOLLO NOTE cannot insert directly into edge0.comp.objects
        newEdge1.comp.objects = edge1Objects
    end

    proposal.streetProposal.edgesToAdd[1] = newEdge0
    proposal.streetProposal.edgesToAdd[2] = newEdge1
    proposal.streetProposal.edgesToRemove[1] = wholeEdgeId
    proposal.streetProposal.nodesToAdd[1] = newNodeBetween

    local context = api.type.Context:new()
    context.checkTerrainAlignment = true -- default is false, true gives smoother Z
    -- context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    -- context.gatherBuildings = true  -- default is false
    -- context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer() -- default is -1

    local callback = function(res, success)
        -- print('LOLLO street splitter callback returned res = ')
        -- debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO street splitter callback returned success = ')
        print(success)
    end
    -- the third param means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    local cmd = api.cmd.make.buildProposal(proposal, context, false)
    api.cmd.sendCommand(cmd, callback)
end

function data()
    return {
        ini = function()
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= '__lolloStreetSplitterEvent__') then return end
            if type(param) ~= 'table' or type(param.constructionEntityId) ~= 'number' then return end
            if name == 'streetSplitterBuilt' then
                -- do nothing
            elseif name == 'streetSplitterWithApiBuilt' then
                print('param.constructionEntityId =', param.constructionEntityId or 'NIL')

                if type(param.constructionEntityId) == 'number' and param.constructionEntityId >= 0 then
                    local constructionTransf = api.engine.getComponent(param.constructionEntityId, api.type.ComponentType.CONSTRUCTION).transf
                    constructionTransf = transfUtilUG.new(constructionTransf:cols(0), constructionTransf:cols(1), constructionTransf:cols(2), constructionTransf:cols(3))
                    print('type(constructionTransf) =', type(constructionTransf))
                    debugPrint(constructionTransf)

                    local nearestEdgeId = edgeUtils.getNearestEdgeId(constructionTransf)
                    -- print('street splitter got nearestEdge =', nearestEdgeId or 'NIL')
                    if type(nearestEdgeId) == 'number' and nearestEdgeId >= 0 then
                        local baseEdge = api.engine.getComponent(nearestEdgeId, api.type.ComponentType.BASE_EDGE)
                        if baseEdge then
                            local node0 = api.engine.getComponent(baseEdge.node0, api.type.ComponentType.BASE_NODE)
                            local node1 = api.engine.getComponent(baseEdge.node1, api.type.ComponentType.BASE_NODE)
                            if node0 and node1 then
                                local nodeBetween = edgeUtils.getNodeBetween(
                                    node0.position,
                                    baseEdge.tangent0,
                                    node1.position,
                                    baseEdge.tangent1,
                                    -- LOLLO NOTE position and transf are always very similar
                                    -- {
                                    --     splitterConstruction.transf[13],
                                    --     splitterConstruction.transf[14],
                                    --     splitterConstruction.transf[15],
                                    -- },
                                    {
                                        x = constructionTransf[13],
                                        y = constructionTransf[14],
                                        z = constructionTransf[15],
                                    }
                                )
                                
                                print('node0 =')
                                debugPrint(node0)
                                print('baseEdge.tangent0 =')
                                debugPrint(baseEdge.tangent0)
                                print('node1 =')
                                debugPrint(node1)
                                print('baseEdge.tangent1 =')
                                debugPrint(baseEdge.tangent1)
                                print('splitterConstruction.transf =')
                                debugPrint(constructionTransf)
                                print('nodeBetween =')
                                debugPrint(nodeBetween)

                                _splitEdge(
                                    nearestEdgeId,
                                    node0.position,
                                    baseEdge.tangent0,
                                    node1.position,
                                    baseEdge.tangent1,
                                    nodeBetween
                                )
                            end
                        end
                    end
                end
            elseif name == 'streetChangerBuilt' then
                local changerConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(changerConstruction) == 'table' and type(changerConstruction.transf) == 'table' then
                    local nearestEdgeId = edgeUtils.getNearestEdgeId(
                        changerConstruction.transf
                    )
                    -- print('nearestEdge =', nearestEdgeId or 'NIL')
                    if nearestEdgeId then
                        print('LOLLO nearestEdgeId = ', nearestEdgeId or 'NIL')
                        _replaceEdge(nearestEdgeId)
                    end
                end
            elseif name == 'toggleAllTracksBuilt' then
                local myConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(myConstruction) == 'table' and type(myConstruction.transf) == 'table' then
                    local nearestEdgeId = edgeUtils.getNearestEdgeId(
                        myConstruction.transf
                    )
                    -- print('nearestEdgeId =', nearestEdgeId or 'NIL')
                    if type(nearestEdgeId) == 'number' and nearestEdgeId >= 0 then
                        local baseEdgeStreet = api.engine.getComponent(nearestEdgeId, api.type.ComponentType.BASE_EDGE_STREET)
                        if baseEdgeStreet and baseEdgeStreet.streetType then
                            local newStreetTypeFileName = _getToggledAllTramTracksStreetTypeFileName(
                                api.res.streetTypeRep.getFileName(baseEdgeStreet.streetType)
                            )
                            -- print('newStreetTypeFileName =', newStreetTypeFileName or 'NIL')
                            if newStreetTypeFileName then
                                _replaceEdgeWithStreetType(
                                    nearestEdgeId,
                                    api.res.streetTypeRep.find(newStreetTypeFileName)
                                )
                            end
                        end
                    end
                end
            elseif name == 'streetGetInfoBuilt' then
                local getInfoConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(getInfoConstruction) == 'table' and type(getInfoConstruction.transf) == 'table' then
                    local nearbyEntities = edgeUtils.getNearbyEntities(getInfoConstruction.transf)
                    if type(nearbyEntities) == 'table' then
                        print('LOLLO GET INFO found nearby entities = ')
                        for _, entity in pairs(nearbyEntities) do
                            debugPrint(entity)
                            if entity.type == 'BASE_EDGE' and not(stringUtils.isNullOrEmptyString(entity.streetType)) then
                                print('base edge component =')
                                debugPrint(api.engine.getComponent(entity.id, api.type.ComponentType.BASE_EDGE))
                                print('base edge street component =')
                                debugPrint(api.engine.getComponent(entity.id, api.type.ComponentType.BASE_EDGE_STREET))
                                print('street properties =')
                                debugPrint(api.res.streetTypeRep.get(api.res.streetTypeRep.find(entity.streetType)))
                            end
                            debugPrint('--------')
                        end
                    end
                end
            end

            game.interface.bulldoze(param.constructionEntityId)
        end,
        guiHandleEvent = function(id, name, param)
            -- LOLLO NOTE param can have different types, even boolean, depending on the event id and name
            if id ~= 'constructionBuilder' then return end
            if name ~= 'builder.apply' then return end
            -- if name == "builder.proposalCreate" then return end

            xpcall(
                function()
                    if not param.result or not param.result[1] then
                        return
                    end

                    -- game.interface.bulldoze(constructionEntity.id) -- cannot call it from this thread, so I raise and call it in the worker thread
                    if _isBuildingStreetSplitter(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetSplitterBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingStreetSplitterWithApi(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetSplitterWithApiBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingStreetGetInfo(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetGetInfoBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingStreetChanger(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'streetChangerBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    elseif _isBuildingToggleAllTracks(param) then
                        game.interface.sendScriptEvent(
                            '__lolloStreetSplitterEvent__',
                            'toggleAllTracksBuilt',
                            {
                                constructionEntityId = param.result[1]
                            }
                        )
                    end
                end,
                _myErrorHandler
            )
        end,
        update = function()
        end,
        guiUpdate = function()
        end,
        -- save = function()
        --     return allState
        -- end,
        -- load = function(allState)
        -- end
    }
end
