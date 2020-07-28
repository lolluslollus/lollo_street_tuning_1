-- local stringUtils = require('lollo_street_tuning/lolloStringUtils')
local debugger = require('debugger')
local edgeUtils = require('lollo_street_tuning.edgeHelper')

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

local function _myErrorHandler(err)
    print('lollo street splitter ERROR: ', err)
end

local function _replaceEdgeDestroyingBuildings(oldEdge)
    -- LOLLO NOTE this thing destroys all buildings along the edges that it replaces.
    local proposal = api.type.SimpleProposal.new()

    local newEdge = api.type.SegmentAndEntity.new()
    newEdge.entity = -1
    newEdge.comp.node0 = oldEdge.node0
    newEdge.comp.node1 = oldEdge.node1
    newEdge.comp.tangent0 = api.type.Vec3f.new(oldEdge.node0tangent[1], oldEdge.node0tangent[2], oldEdge.node0tangent[3])
    newEdge.comp.tangent1 = api.type.Vec3f.new(oldEdge.node1tangent[1], oldEdge.node1tangent[2], oldEdge.node1tangent[3])
    newEdge.comp.type = 0
    newEdge.comp.typeIndex = 0
    -- edge0.comp.objects = {{ -1, 1 }} --
    newEdge.type = 0
    newEdge.streetEdge = api.type.BaseEdgeStreet.new()
    newEdge.streetEdge.streetType = api.res.streetTypeRep.find(oldEdge.streetType)

    proposal.streetProposal.edgesToAdd[1] = newEdge
    proposal.streetProposal.edgesToRemove[1] = oldEdge.id

    local context = api.type.Context:new()
    context.checkTerrainAlignment = false
    context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    context.gatherBuildings = false -- buildings are destroyed anyway
    context.gatherFields = true
    context.player = api.engine.util.getPlayer() -- buildings are destroyed anyway

    local callback = function(res, success)
        print('LOLLO street changer callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, true) -- true means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

local function _replaceEdge(oldEdge)
    -- LOLLO NOTE this replaces the street without destroying the buildings
    if type(oldEdge) ~= 'table' then return end

	local proposal = api.type.SimpleProposal.new()
	proposal.streetProposal.edgesToRemove[1] = oldEdge.id

	local baseEdge = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE)
	local baseEdgeStreet = api.engine.getComponent(oldEdge.id, api.type.ComponentType.BASE_EDGE_STREET)

	local newEdge = api.type.SegmentAndEntity.new()
	newEdge.entity = -1
	newEdge.type = 0
    newEdge.comp = baseEdge
    newEdge.playerOwned = {player = api.engine.util.getPlayer()}
	newEdge.streetEdge = baseEdgeStreet
	-- eo.streetEdge.streetType = api.res.streetTypeRep.find(streetEdgeEntity.streetType)

    proposal.streetProposal.edgesToAdd[1] = newEdge
    print('LOLLO eo = ')
    debugPrint(newEdge)
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
        print('LOLLO res = ')
		debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO success = ')
		debugPrint(success)
	end

	local cmd = api.cmd.make.buildProposal(proposal, nil, false)
	api.cmd.sendCommand(cmd, callback)
end

local function _splitEdgeBak(wholeEdge, nodeMid)
    -- LOLLO NOTE this thing destroys all buildings along the edges that it replaces. This defies the very purpose of this mod!
    local proposal = api.type.SimpleProposal.new()

    local edge0 = api.type.SegmentAndEntity.new()
    edge0.entity = -1
    edge0.comp.node0 = wholeEdge.node0
    edge0.comp.node1 = -3
    edge0.comp.tangent0 = api.type.Vec3f.new(wholeEdge.node0tangent[1], wholeEdge.node0tangent[2], wholeEdge.node0tangent[3])
    edge0.comp.tangent1 = api.type.Vec3f.new(nodeMid.tangent[1], nodeMid.tangent[2], nodeMid.tangent[3])
    edge0.comp.type = 0
    edge0.comp.typeIndex = 0
    -- edge0.comp.objects = {{ -1, 1 }} --
    edge0.type = 0
    edge0.streetEdge = api.type.BaseEdgeStreet.new()
    edge0.streetEdge.streetType = api.res.streetTypeRep.find(wholeEdge.streetType)

    local edge1 = api.type.SegmentAndEntity.new()
    edge1.entity = -2
    edge1.comp.node0 = -3
    edge1.comp.node1 = wholeEdge.node1
    edge1.comp.tangent0 = api.type.Vec3f.new(nodeMid.tangent[1], nodeMid.tangent[2], nodeMid.tangent[3])
    edge1.comp.tangent1 = api.type.Vec3f.new(wholeEdge.node1tangent[1], wholeEdge.node1tangent[2], wholeEdge.node1tangent[3])
    edge1.comp.type = 0
    edge1.comp.typeIndex = 0
    --edge1.comp.objects = {{ -1, 1 }}
    edge1.type = 0
    edge1.streetEdge = api.type.BaseEdgeStreet.new()
    edge1.streetEdge.streetType = api.res.streetTypeRep.find(wholeEdge.streetType)

    proposal.streetProposal.edgesToAdd[1] = edge0
    proposal.streetProposal.edgesToAdd[2] = edge1
    proposal.streetProposal.edgesToRemove[1] = wholeEdge.id

    -- eo = api.type.SimpleStreetProposal.EdgeObject.new()
    -- eo.left = true
    -- eo.model = "street/signal_waypoint.mdl"
    -- eo.playerEntity = game.interface.getPlayer()
    -- eo.oneWay = false
    -- eo.param = 0.5
    -- eo.edgeEntity = -1
    -- eo.name = "MY Beautiful Signal"

    -- proposal.streetProposal.edgeObjectsToAdd[1] = eo

    local node1 = api.type.NodeAndEntity.new()
    node1.entity = -3
    node1.comp.position = api.type.Vec3f.new(nodeMid.position[1], nodeMid.position[2], nodeMid.position[3]) --api.type.Vec3f.new(40.0, 0.0, 0.0)

    proposal.streetProposal.nodesToAdd[1] = node1


    local context = api.type.Context:new()
    context.checkTerrainAlignment = false
    context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    context.gatherBuildings = false -- buildings are destroyed anyway
    context.gatherFields = true
    context.player = api.engine.util.getPlayer() -- buildings are destroyed anyway

    local callback = function(res, success)
        print('LOLLO street splitter callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, true) -- true means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

local function _spliceEdge(edge0, edge1)
    -- LOLLO NOTE untested function, difficult to use coz it requires two selected objects
    local proposal = api.type.SimpleProposal.new()

    local baseEdge0 = api.engine.getComponent(edge0.id, api.type.ComponentType.BASE_EDGE)
    local baseEdge1 = api.engine.getComponent(edge1.id, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(edge0.id, api.type.ComponentType.BASE_EDGE_STREET)

    local splicedEdge = api.type.SegmentAndEntity.new()
    splicedEdge.entity = -1
    splicedEdge.type = 0
    splicedEdge.comp.node0 = edge0.node0
    splicedEdge.comp.node1 = edge1.node1
    splicedEdge.comp.tangent0 = api.type.Vec3f.new(edge0.node0tangent[1], edge0.node0tangent[2], edge0.node0tangent[3])
    splicedEdge.comp.tangent1 = api.type.Vec3f.new(edge1.node1tangent[1], edge1.node1tangent[2], edge1.node1tangent[3])
    splicedEdge.comp.type = 0
    splicedEdge.comp.typeIndex = -1
    splicedEdge.playerOwned = {player = api.engine.util.getPlayer()}
    splicedEdge.streetEdge = baseEdgeStreet

    local splicedEdgeObjects = {}
    if type(baseEdge0.objects) == 'table' then
        for _, vv in pairs(baseEdge0.objects) do
            local entity = game.interface.getEntity(vv[1])
            if type(entity) == 'table' and type(entity.position) == 'table' then
                table.insert(splicedEdgeObjects, { vv[1], vv[2] })
            end
        end
    end
    if type(baseEdge1.objects) == 'table' then
        for _, vv in pairs(baseEdge1.objects) do
            local entity = game.interface.getEntity(vv[1])
            if type(entity) == 'table' and type(entity.position) == 'table' then
                table.insert(splicedEdgeObjects, { vv[1], vv[2] })
            end
        end
    end
    splicedEdge.comp.objects = splicedEdgeObjects -- LOLLO NOTE cannot insert directly into edge0.comp.objects

    proposal.streetProposal.edgesToAdd[1] = splicedEdge
    proposal.streetProposal.edgesToRemove[1] = edge0.id
    proposal.streetProposal.edgesToRemove[2] = edge1.id
    proposal.streetProposal.nodesToRemove[1] = edge1.node0.id

    local context = api.type.Context:new()
    -- context.checkTerrainAlignment = true -- default is false
    -- context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    -- context.gatherBuildings = true  -- default is false
    -- context.gatherFields = true -- default is true
    context.player = api.engine.util.getPlayer() -- default is -1

    local callback = function(res, success)
        print('LOLLO street splicer callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO street splicer callback returned success = ')
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, false) -- the third param means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

local function _splitEdge(wholeEdge, nodeBetween)
    if type(wholeEdge) ~= 'table' or type(nodeBetween) ~= 'table' then return end

    local node0TangentLength = edgeUtils.getVectorLength({
        wholeEdge.node0tangent[1],
        wholeEdge.node0tangent[2],
        wholeEdge.node0tangent[3]
        -- 0
    })
    local node1TangentLength = edgeUtils.getVectorLength({
        wholeEdge.node1tangent[1],
        wholeEdge.node1tangent[2],
        wholeEdge.node1tangent[3]
        -- 0
    })
    local edge0Length = edgeUtils.getVectorLength({
        nodeBetween.position[1] - wholeEdge.node0pos[1],
        nodeBetween.position[2] - wholeEdge.node0pos[2],
        -- 0
        nodeBetween.position[3] - wholeEdge.node0pos[3]
    })
    local edge1Length = edgeUtils.getVectorLength({
        nodeBetween.position[1] - wholeEdge.node1pos[1],
        nodeBetween.position[2] - wholeEdge.node1pos[2],
        -- 0
        nodeBetween.position[3] - wholeEdge.node1pos[3]
    })

    local proposal = api.type.SimpleProposal.new()

    local baseEdge = api.engine.getComponent(wholeEdge.id, api.type.ComponentType.BASE_EDGE)
    local baseEdgeStreet = api.engine.getComponent(wholeEdge.id, api.type.ComponentType.BASE_EDGE_STREET)

    local newNodeBetween = api.type.NodeAndEntity.new()
    newNodeBetween.entity = -3
    newNodeBetween.comp.position = api.type.Vec3f.new(nodeBetween.position[1], nodeBetween.position[2], nodeBetween.position[3]) --api.type.Vec3f.new(40.0, 0.0, 0.0)

    local newEdge0 = api.type.SegmentAndEntity.new()
    newEdge0.entity = -1
    newEdge0.type = 0
    newEdge0.comp.node0 = wholeEdge.node0
    newEdge0.comp.node1 = -3
    newEdge0.comp.tangent0 = api.type.Vec3f.new(
        wholeEdge.node0tangent[1] * edge0Length / node0TangentLength,
        wholeEdge.node0tangent[2] * edge0Length / node0TangentLength,
        wholeEdge.node0tangent[3] * edge0Length / node0TangentLength
    )
    newEdge0.comp.tangent1 = api.type.Vec3f.new(
        nodeBetween.tangent[1] * edge0Length,
        nodeBetween.tangent[2] * edge0Length,
        nodeBetween.tangent[3] * edge0Length
    )
    newEdge0.comp.type = 0
    newEdge0.comp.typeIndex = -1
    newEdge0.playerOwned = {player = api.engine.util.getPlayer()}
    newEdge0.streetEdge = baseEdgeStreet

    local newEdge1 = api.type.SegmentAndEntity.new()
    newEdge1.entity = -2
    newEdge1.type = 0
    newEdge1.comp.node0 = -3
    newEdge1.comp.node1 = wholeEdge.node1
    newEdge1.comp.tangent0 = api.type.Vec3f.new(
        nodeBetween.tangent[1] * edge1Length,
        nodeBetween.tangent[2] * edge1Length,
        nodeBetween.tangent[3] * edge1Length
    )
    newEdge1.comp.tangent1 = api.type.Vec3f.new(
        wholeEdge.node1tangent[1] * edge1Length / node1TangentLength,
        wholeEdge.node1tangent[2] * edge1Length / node1TangentLength,
        wholeEdge.node1tangent[3] * edge1Length / node1TangentLength
    )
    newEdge1.comp.type = 0
    newEdge1.comp.typeIndex = -1
    newEdge1.playerOwned = {player = api.engine.util.getPlayer()}
    newEdge1.streetEdge = baseEdgeStreet

    if type(baseEdge.objects) == 'table' then
        local edge0Objects = {}
        local edge1Objects = {}
        for _, vv in pairs(baseEdge.objects) do
            local entity = game.interface.getEntity(vv[1])
            if type(entity) == 'table' and type(entity.position) == 'table' then
                local position = entity.position
                -- LOLLO NOTE this is a rough estimator to find out which edge gets which objects
                local node0Distance = edgeUtils.getVectorLength({
                    position[1] - wholeEdge.node0pos[1],
                    position[2] - wholeEdge.node0pos[2]
                })
                local node1Distance = edgeUtils.getVectorLength({
                    position[1] - wholeEdge.node1pos[1],
                    position[2] - wholeEdge.node1pos[2]
                })
                if node0Distance < node1Distance then
                    table.insert(edge0Objects, { vv[1], vv[2] })
                else
                    table.insert(edge1Objects, { vv[1], vv[2] })
                end
            end
        end
        newEdge0.comp.objects = edge0Objects -- LOLLO NOTE cannot insert directly into edge0.comp.objects
        newEdge1.comp.objects = edge1Objects
    end

    proposal.streetProposal.edgesToAdd[1] = newEdge0
    proposal.streetProposal.edgesToAdd[2] = newEdge1
    proposal.streetProposal.edgesToRemove[1] = wholeEdge.id
    proposal.streetProposal.nodesToAdd[1] = newNodeBetween

    local context = api.type.Context:new()
    -- LOLLO TODO the bridge is replaced with a terrapin, the following does not matter
    -- context.checkTerrainAlignment = true -- default is false, true gives smoother Z
    -- context.cleanupStreetGraph = true -- default is false, it seems to do nothing
    -- context.gatherBuildings = true  -- default is false
    -- context.gatherFields = true -- default is true
    -- LOLLO TODO I cannot make the user own the new edges
    context.player = api.engine.util.getPlayer() -- default is -1

    local callback = function(res, success)
        -- print('LOLLO street splitter callback returned res = ')
        -- debugPrint(res)
        if success == true
        and res
        and res.resultProposalData
        and res.resultProposalData.tpNetLinkProposal
        and res.resultProposalData.tpNetLinkProposal.toAdd
        and #res.resultProposalData.tpNetLinkProposal.toAdd > 0 then
            print('LOLLO new tpNetLinkProposals', #res.resultProposalData.tpNetLinkProposal.toAdd)
            -- LOLLO TODO MAYBE undo
            -- _spliceEdge(edge0, edge1)
        end
        --for _, v in pairs(res.entities) do print(v) end
        print('LOLLO street splitter callback returned success = ')
        print(success)
        -- debugger()
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, false) -- the third param means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
    -- debugger()
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
                local splitterConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(splitterConstruction) == 'table' and type(splitterConstruction.transf) == 'table' then
                    print('LOLLO splitterConstruction =')
                    debugPrint(splitterConstruction)
                    local nearbyEdges = edgeUtils.getNearbyStreetEdges(splitterConstruction.transf)
                    if #nearbyEdges > 0 then
                        local nodeBetween = edgeUtils.getNodeBetween(
                            {
                                nearbyEdges[1]['node0pos'],
                                nearbyEdges[1]['node0tangent'],
                            },
                            {
                                nearbyEdges[1]['node1pos'],
                                nearbyEdges[1]['node1tangent'],
                            },
                            -- LOLLO NOTE position and transf are always very similar
                            -- {
                            --     splitterConstruction.transf[13],
                            --     splitterConstruction.transf[14],
                            --     splitterConstruction.transf[15],
                            -- },
                            splitterConstruction.position
                        )
                        print('LOLLO nodeBetween = ')
                        debugPrint(nodeBetween)
                        -- print('LOLLO nearbyEdges[1] = ')
                        -- debugPrint(nearbyEdges[1])

                        _splitEdge(nearbyEdges[1], nodeBetween)
                    end
                end
            elseif name == 'streetChangerBuilt' then
                local changerConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(changerConstruction) == 'table' and type(changerConstruction.transf) == 'table' then
                    local nearbyEdges = edgeUtils.getNearbyStreetEdges(changerConstruction.transf)
                    if #nearbyEdges > 0 then
                        print('LOLLO nearbyEdges[1] = ')
                        debugPrint(nearbyEdges[1])

                        _replaceEdge(nearbyEdges[1])
                    end
                end
            elseif name == 'streetGetInfoBuilt' then
                local getInfoConstruction = game.interface.getEntity(param.constructionEntityId)
                if type(getInfoConstruction) == 'table' and type(getInfoConstruction.transf) == 'table' then
                    local nearbyEntities = edgeUtils.getNearbyEntities(getInfoConstruction.transf)
                    print('LOLLO nearbyEntities = ')
                    debugPrint(nearbyEntities)
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
