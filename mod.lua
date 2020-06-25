local arrayUtils = require('lollo_street_tuning/lolloArrayUtils')
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
            print('LOLLO staticCon.params = ')
            debugPrint(staticCon.params)
            local function _getUiTypeNumber(uiTypeStr)
                if uiTypeStr == 'BUTTON' then return 0
                elseif uiTypeStr == 'SLIDER' then return 1
                elseif uiTypeStr == 'COMBOBOX' then return 2
                elseif uiTypeStr == 'ICON_BUTTON' then return 3 -- double-check this
                elseif uiTypeStr == 'CHECKBOX' then return 4 -- double-check this
                else return 0
                end
            end
            local newConParams = {} --arrayUtils.map(
            for _, par in pairs(streetChunksHelper.getParams()) do
                local apiPar = api.type.ScriptParam.new()
                apiPar.key = par.key
                apiPar.name = par.name
                apiPar.tooltip = par.tooltip or ''
                apiPar.values = par.values
                apiPar.defaultIndex = par.defaultIndex or 0
                apiPar.uiType = _getUiTypeNumber(par.uiType)
                if par.yearFrom ~= nil then apiPar.yearFrom = par.yearFrom end
                if par.yearTo ~= nil then apiPar.yearTo = par.yearTo end
                newConParams[#newConParams + 1] = apiPar
            end

            print('LOLLO dynamicCon.params = ')
            debugPrint(newConParams)
            debugger()
            newCon.params = newConParams -- LOLLO TODO check this once UG fixes or explains it, it dumps atm with
            -- expected userdata, received sol.ScriptParam: value at this index does not properly reflect the desired type

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
