package.path = package.path .. ';res/scripts/?.lua'

local dump = require('res/scripts/luadump')
local arrayUtils = require('res/scripts/lollo_street_tuning/lolloArrayUtils')
local fileUtils = require('res/scripts/lollo_street_tuning/lolloFileUtils')
local stringUtils = require('res/scripts/lollo_street_tuning/lolloStringUtils')

local path = "C:/Program Files (x86)/Steam/steamapps/common/Transport Fever 2/?.dll/"

-- local fd = 0
local sd = fd or 5

local table1 = {
    {
        name = 'aaa',
        address = 'alalalal'
    },
    {
        name = 'ccc',
        address = 'rorororro'
    },
    {
        name = 'bbb',
        address = 'zazazaza'
    }
}

local one = arrayUtils.sort(table1, 'ddd')
local two = arrayUtils.sort(table1, 'name')
local aaa = 'AAA'
