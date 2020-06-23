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
        -- postRunFn = function(_)
        --     local streetUtils = require('lollo_street_tuning/lolloStreetUtils')
        --     streetUtils.setGlobalStreetData()
        -- end
    }
end
