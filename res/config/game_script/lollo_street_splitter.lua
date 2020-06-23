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
                debugger()

                if #nearbyEdges > 0 then
                    local edgeMid = edgeUtils.getEdgeBetween(
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
                    debugPrint(edgeMid)
                    print('LOLLO nearbyEdges[1] = ')
                    debugPrint(nearbyEdges[1])
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
