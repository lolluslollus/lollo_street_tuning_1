local streetChunksHelper = require('lollo_street_tuning/lolloStreetChunksHelper')
local streetUtils = require('lollo_street_tuning/lolloStreetUtils')
local stringUtils = require('lollo_street_tuning.lolloStringUtils')
local debugger = require('debugger')

function data()
    return {
        info = {
            minorVersion = 16,
            severityAdd = 'NONE',
            severityRemove = 'WARNING',
            name = _('_NAME'),
            description = _('_DESC'),
            tags = {
                'Street',
                'Street Construction'
            },
            authors = {
                {
                    name = 'Lollus',
                    role = 'CREATOR'
                }
            }
        },
        -- unlike runFn, postRunFn runs after resources have been loaded
        postRunFn = function(settings, params)
            if true then return end

            print('LOLLO postRunFn starting')
            debugger()
            local streetTypes = streetUtils.getGlobalStreetData()
            local staticConIdId = api.res.constructionRep.find('lollo_street_chunks.con')
            local staticCon = api.res.constructionRep.get(staticConIdId)
            local newCon = api.type.ConstructionDesc.new()
            newCon.fileName = 'lollo_street_chunks_2.con' -- staticCon.fileName -- 'lollo_street_chunks_2.con'
            newCon.type = staticCon.type
            newCon.description = staticCon.description
            newCon.availability = staticCon.availability
            newCon.buildMode = staticCon.buildMode
            newCon.categories = staticCon.categories
            newCon.order = staticCon.order
            newCon.skipCollision = staticCon.skipCollision
            newCon.autoRemovable = staticCon.autoRemovable
            -- newCon.updateScript = staticCon.updateScript
            -- LOLLO TODO dump: expected userdata, got table
            -- newCon.params = streetChunksHelper.getParams()
            -- newCon.params = {
            --     {
            --         key = "numTracksIndex",
            --         name = ("Number of tracks"),
            --         values = {('1'), ('2'), ('3')},
            --     },
            --     {
            --         key = "sizeIndex",
            --         name = ("Platform length"),
            --         values = {('1'), ('2')},
            --         defaultIndex = 1
            --     }
            -- }
            newCon.params = staticCon.params
            newCon.updateScript.fileName = 'construction/lollo_street_chunks.updateFn'
            -- newCon.updateScript.params = streetChunksHelper.getParams()
            newCon.preProcessScript.fileName = 'construction/lollo_street_chunks.preProcessFn'
            newCon.upgradeScript.fileName = 'construction/lollo_street_chunks.upgradeFn'
            newCon.createTemplateScript.fileName = 'construction/lollo_street_chunks.createTemplateFn'

            print('LOLLO newCon = ')
            debugPrint(newCon)

            -- api.res.moduleRep.add(mod.fileName, mod, true)
            api.res.constructionRep.add(newCon.fileName, newCon, true)
        end
    }
end
