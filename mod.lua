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
        runFn = function(_)
            local streetChunksHelper = require('lollo_street_tuning/lolloStreetChunksHelper')
            streetChunksHelper.setGlobalStreetData(game)
        end
    }
end
