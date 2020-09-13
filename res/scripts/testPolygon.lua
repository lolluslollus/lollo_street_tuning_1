package.path = package.path .. ';res/scripts/?.lua'
local luadump = require('lollo_street_tuning.luadump')
local edgeUtils = require('lollo_street_tuning.edgeHelper')
if debugPrint == nil then 
    debugPrint = function(sth)
        luadump(true)(sth)
    end
end
-- actboy lua debugger
-- actboy extension path
-- sumneko lua assist

-- local vertices = {
--     [1] = {
--         x = -100,
--         y = -100
--     },
--     [2] = {
--         x = 100,
--         y = -100
--     },
--     [3] = {
--         x = 100,
--         y = 100
--     },
--     [4] = {
--         x = -100,
--         y = 100
--     },
-- }
-- local positionToCheck = {10, 10, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == true)
-- local positionToCheck = {-99, -99, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == true)
-- local positionToCheck = {-101, -99, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == false)
-- local positionToCheck = {99, -99, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == true)
-- local positionToCheck = {99, -101, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == false)
-- local positionToCheck = {99, 99, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == true)
-- local positionToCheck = {-99, 99, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == true)
-- local positionToCheck = {-99, 0, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == true)
-- local positionToCheck = {-101, 0, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == false)
-- local positionToCheck = {199, 0, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == false)

local vertices = {
    [1] = {
        x = -100,
        y = -100
    },
    [2] = {
        x = 100,
        y = -100
    },
    [3] = {
        x = 0,
        y = 100
    },
    [4] = {
        x = 0,
        y = 100
    },
}
-- local positionToCheck = {10, 10, 10}
-- local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
-- assert(testResult == true)
local positionToCheck = {-99, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {99, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {99, -101, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {99, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-99, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-101, -101, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-100, 0, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {0, 0, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)

local vertices = {
    [1] = {
        x = 0,
        y = -100
    },
    [2] = {
        x = 0,
        y = -100
    },
    [3] = {
        x = 100,
        y = 100
    },
    [4] = {
        x = -100,
        y = 100
    },
}
local positionToCheck = {10, 10, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {-100, -100, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {100, -100, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {99, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {101, 101, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-99, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {-101, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {0, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)

local vertices = {
    [1] = {
        x = -100,
        y = -10
    },
    [2] = {
        x = -100,
        y = -10
    },
    [3] = {
        x = 100,
        y = 100
    },
    [4] = {
        x = 100,
        y = -100
    },
}
local positionToCheck = {-90, 10, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {10, 10, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {10, -10, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {-100, -100, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {99, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {99, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {101, 101, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-99, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-101, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {0, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)

local vertices = {
    [1] = {
        x = -101,
        y = -10
    },
    [2] = {
        x = -100,
        y = 10
    },
    [3] = {
        x = 100,
        y = 100
    },
    [4] = {
        x = 101,
        y = 80
    },
}
local positionToCheck = {-95, 15, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-95, 10, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {-95, -10, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-90, 25, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {10, 45, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {10, 30, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-100, -100, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {99, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {99, 99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == true)
local positionToCheck = {101, 101, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-99, 11, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {-101, -1, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)
local positionToCheck = {0, -99, 10}
local testResult = edgeUtils.testGetIsPointWithin(vertices, positionToCheck)
assert(testResult == false)

local dummy = 'AAA'