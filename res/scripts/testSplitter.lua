package.path = package.path .. ';res/scripts/?.lua'
local arrayUtils = require('lollo_street_tuning.arrayUtils')
local matrixUtils = require('lollo_street_tuning.matrix')
local transfUtils = require('lollo_street_tuning.transfUtils')
local edgeUtils = require('lollo_street_tuning.edgeHelper')
if debugPrint == nil then 
    debugPrint = function(sth)
    end
end
-- actboy lua debugger
-- actboy extension path
-- sumneko lua assist

-- this one makes trouble (it produces a betweenPosition with infinite x)
edgeUtils.getNodeBetween(
    {
        x = 1345.5754394531,
        y = -334.72787475586,
        z = 3.4936218261719,
    },
    {
        x = 23.458374023438,
        y = 0,
        z = 0,
    },
    {
        x = 1345.5754394531,
        y = -324.16787719727,
        z = 3.4936218261719,
    },
    {
        x = -23.458374023438,
        y = 0,
        z = 0,
    },
    { 
        x = 1350.5802001953,
        y = -330.65850830078,
        z = 3.500004529953,
    }
)

-- this one makes trouble (it produces a betweenPosition with infinite x)
edgeUtils.getNodeBetween(
    {
        x = 1449.9561767578,
        y = -301.21887207031,
        z = 8.3892440795898,
    },
    {
        x = -16.587575912476,
        y = -16.587575912476,
        z = 0,
    },
    {
        x = 1457.4232177734,
        y = -308.68591308594,
        z = 8.3892440795898,
    },
    {
        x = 16.587575912476,
        y = 16.587575912476,
        z = 0,
    },
    { 
        x = 1449.9409179688,
        y = -309.80444335938,
        z = 8.3499984741211,
    }
)

-- this one does nothing
edgeUtils.getNodeBetween(
    {
        x = 1382.4722900391,
        y = -301.20556640625,
        z = 3.1255645751953,
    },
    {
        x = 23.007627487183,
        y = -4.5765018463135,
        z = 0,
    },
    {
        x = 1384.5323486328,
        y = -290.84844970703,
        z = 3.1255645751953,
    },
    {
        x = -23.007627487183,
        y = 4.5765018463135,
        z = 0,
    },
    { 
        x = 1390.1535644531,
        y = -298.57189941406,
        z = 3.0999984741211,
    }
)

-- this one hangs indefinitely (it produces a betweenPosition with infinite y)
edgeUtils.getNodeBetween(
    {
        x = 1374.9682617188,
        y = -291.40237426758,
        z = 3.1875915527344,
    },
    {
        x = 1.7710580095809e-06,
        y = -23.458374023438,
        z = 0,
    },
    {
        x = 1385.5283203125,
        y = -291.40237426758,
        z = 3.1875915527344,
    },
    {
        x = -1.7710580095809e-06,
        y = 23.458374023438,
        z = 0,
    },
    { 
        x = 1380.4030761719,
        y = -298.28973388672,
        z = 3.2000014781952,
    }
)
local dummy = 'AAA'
