package.path = package.path .. ';res/scripts/?.lua'

local dump = require('res/scripts/luadump')
local fileUtils = require('res/scripts/fileUtils')
local stringUtils = require('res/scripts/stringUtils')

local str0 = 'C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/'
local str1 = ''
local howManyMatches = 0
            
local files = fileUtils.getFilesInDir(str0)
local files = fileUtils.getFilesInDirWithExtension(str0, 'lua')
local aaa = 'LOLLO'



