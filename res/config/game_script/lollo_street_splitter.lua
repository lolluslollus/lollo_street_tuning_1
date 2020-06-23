local luadump = require('lollo_street_tuning/luadump')
-- local stringUtils = require('lollo_street_tuning/lolloStringUtils')
local debugger = require('debugger')
local edgeUtils = require('lollo_street_tuning.edgeHelpers')

local function _isBuildingStreetSplitter(param)
    local toAdd =
        type(param) == 'table' and type(param.proposal) == 'userdata' and type(param.proposal.toAdd) == 'userdata' and
        param.proposal.toAdd

    if toAdd and #toAdd > 0 then
        for i = 1, #toAdd do
            if toAdd[i].fileName == [[lollo_street_splitter.con]]
            or toAdd[i].fileName == [[lollo_street_splitter_2.con]] then
                return true
            end
        end
    end

    return false
end

local function _myErrorHandler(err)
    print('ERROR: ', err)
end

local function _splitEdge(wholeEdge, nodeMid)
    -- LOLLO TODO with the test tangents, this works somehow, However, the lanes do not intersect => the whole thing was useless?
    -- NO! They do intersect when the road is straight, so we need to work on those tangents.
    -- BUT: this thing destroys all buildings along the edges, which are replaced. This defies the very purpose of this mod!
    local proposal = api.type.SimpleProposal.new() -- api.type.SimpleProposal

    local edge0 = api.type.SegmentAndEntity.new()
    edge0.entity = -1
    edge0.comp.node0 = wholeEdge.node0
    edge0.comp.node1 = -3
    edge0.comp.tangent0 = api.type.Vec3f.new(wholeEdge.node0tangent[1], wholeEdge.node0tangent[2], wholeEdge.node0tangent[3])
    edge0.comp.tangent1 = api.type.Vec3f.new(nodeMid.tangent[1], nodeMid.tangent[2], nodeMid.tangent[3])
    edge0.comp.tangent1 = api.type.Vec3f.new(wholeEdge.node0tangent[1], wholeEdge.node0tangent[2], wholeEdge.node0tangent[3]) -- LOLLO test
    edge0.comp.tangent1 = api.type.Vec3f.new(
        (wholeEdge.node0tangent[1] + wholeEdge.node1tangent[1]) * 0.5,
        (wholeEdge.node0tangent[2] + wholeEdge.node1tangent[2]) * 0.5,
        (wholeEdge.node0tangent[3] + wholeEdge.node1tangent[3]) * 0.5
    ) -- LOLLO test
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
    edge1.comp.tangent0 = api.type.Vec3f.new(wholeEdge.node1tangent[1], wholeEdge.node1tangent[2], wholeEdge.node1tangent[3]) -- LOLLO test
    edge0.comp.tangent0 = api.type.Vec3f.new(
        (wholeEdge.node0tangent[1] + wholeEdge.node1tangent[1]) * 0.5,
        (wholeEdge.node0tangent[2] + wholeEdge.node1tangent[2]) * 0.5,
        (wholeEdge.node0tangent[3] + wholeEdge.node1tangent[3]) * 0.5
    ) -- LOLLO test
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
        print('LOLLO callback returned res = ')
        debugPrint(res)
        --for _, v in pairs(res.entities) do print(v) end
        print(success)
    end

    local cmd = api.cmd.make.buildProposal(proposal, context, true) -- true means, ignore errors. Errors are not ignored tho: wrong proposals will be discarded
    api.cmd.sendCommand(cmd, callback)
end

function data()
    return {
        ini = function()
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= '__lolloStreetSplitterEvent__') then return end
            if name ~= 'built' then return end
            if type(param) ~= 'table' or type(param.constructionEntityId) ~= 'number' then return end

            local splitterConstruction = game.interface.getEntity(param.constructionEntityId)
            if type(splitterConstruction) == 'table' and type(splitterConstruction.transf) == 'table' then
                local nearbyEdges = edgeUtils.getNearbyStreetEdges(splitterConstruction.transf)
                if #nearbyEdges > 0 then
                    local nodeMid = edgeUtils.getNodeBetween(
                        {
                            nearbyEdges[1]['node0pos'],
                            nearbyEdges[1]['node0tangent'],
                        },
                        {
                            nearbyEdges[1]['node1pos'],
                            nearbyEdges[1]['node1tangent'],
                        }
                    )
                    print('LOLLO edgeMid = ')
                    debugPrint(nodeMid)
                    print('LOLLO nearbyEdges[1] = ')
                    debugPrint(nearbyEdges[1])

                    _splitEdge(nearbyEdges[1], nodeMid)
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
                    if not (_isBuildingStreetSplitter(param)) then
                        return
                    end

                    if not param.result or not param.result[1] then
                        return
                    end

                    -- if
                    --     not (type(param) == 'table' and type(param.data) == 'userdata' and
                    --         type(param.data.entity2tn) == 'userdata')
                    -- then
                    --     return
                    -- end

                    -- -- print('-- start working out entities near construction')
                    -- local constructionEntity = nil
                    -- for k, _ in pairs(param.data.entity2tn) do
                    --     local entity = game.interface.getEntity(k)
                    --     if type(entity) == 'table' and type(entity.type) == 'string' and entity.type == 'CONSTRUCTION' then
                    --         -- print('construction found')
                    --         constructionEntity = entity
                    --         break
                    --     end
                    -- end

                    -- if type(constructionEntity) ~= 'table' or not (constructionEntity.position) or not (constructionEntity.id) then
                    --     return
                    -- end

                    -- print('LOLLO constructionBuilder.builder.apply caught, param =')
                    -- debugPrint(param)
                    -- _G.lollo = true
                    --[[ print('nearby entities within 99= ')
                            local baseEdges =
                                game.interface.getEntities(
                                {pos = constructionEntity.position, radius = 99},
                                {type = 'BASE_EDGE', includeData = true}
                            )
                            local baseNodes =
                                game.interface.getEntities(
                                {pos = constructionEntity.position, radius = 99},
                                {type = 'BASE_NODE', includeData = true}
                            )
                            luadump(true)(baseEdges)
                            luadump(true)(baseNodes)
                            print('nearby entities within 9= ')
                            luadump(true)(
                                game.interface.getEntities(
                                    {pos = constructionEntity.position, radius = 9},
                                    {type = 'BASE_EDGE', includeData = true}
                                )
                            )
                            luadump(true)(
                                game.interface.getEntities(
                                    {pos = constructionEntity.position, radius = 9},
                                    {type = 'BASE_NODE', includeData = true}
                                )
                            ) ]]
                    --[[             print('nearby entities within 1= ') -- within 0 only returns the base node of the construction itself
                    local baseEdges =
                        game.interface.getEntities(
                        {pos = constructionEntity.position, radius = 1},
                        {type = 'BASE_EDGE', includeData = true}
                    )
                    luadump(true)(baseEdges)
                    local baseNodes =
                        game.interface.getEntities(
                        {pos = constructionEntity.position, radius = 1},
                        {type = 'BASE_NODE', includeData = true}
                    )
                    luadump(true)(baseNodes)
        ]]
                    -- game.interface.bulldoze(constructionEntity.id) -- cannot call it from this thread, so I raise and call it in the worker thread
                    game.interface.sendScriptEvent(
                        '__lolloStreetSplitterEvent__',
                        'built',
                        {
                            constructionEntityId = param.result[1] --constructionEntity.id
                            -- constructionEntity = constructionEntity,
                            -- baseEdges = baseEdges,
                            -- baseNodes = baseNodes
                        }
                    )
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
