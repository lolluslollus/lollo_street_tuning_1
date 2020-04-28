--local dump = require 'luadump'
--local inspect = require('inspect')
local stringUtils = require('stringUtils')

local fileUtils = {}
fileUtils.fileExists = function(fileName)
    local file = io.open(fileName, 'r')
    if file then
        file:close()
        return true
    end
    return false
end

fileUtils.readGameDataFile = function(fileName)
    local file = io.open(fileName, 'r')
    if file == nil then
        print('LOLLO file not found')
        return false
    end

    -- file has type userdata
    print('LOLLO start reading the file')
    local fileContents = file:read('*a') -- this works! it reads the file contents! However, it adds a funny character at the beginning.
    print('LOLLO closing the file')
    file:close()

    -- We need to remove the funny character at the beginning
    -- and the function name, or load() will fail. Consider the following:
    --    local ee = return function(a,b) return a+b end -- works
    --    local ee = return function data(a,b) return a+b end -- fails
    local searchStr = '[%W]*function[%s]+data[%s]*%('
    local howManyMatches = 0
    fileContents, howManyMatches = string.gsub(fileContents, searchStr, 'return function(', 1)

    -- print('LOLLO adjusted file contents = ')
    -- dump(true)(fileContents)
    -- print('LOLLO howManyMatches = ')
    -- dump(true)(howManyMatches)

    if howManyMatches == 0 then
        return false
    end

    --local myFileFunc = loadstring(fileContents) -- it fails coz loadstring is not available anymore
    -- local func, err = load('return function(a,b) return a+b end')
    -- if func then
    --     local ok, add = pcall(func)
    --     if ok then
    --         print('LOLLO test 4 load', add(2, 3))
    --     else
    --         print('Execution error:', add)
    --     end
    -- else
    --     print('Compilation error:', err)
    -- end

    local func, err = load(fileContents)
    if func then
        local ok, fc = pcall(func)
        if ok then
            -- print('LOLLO test 4 load -----------------------------------')
            -- dump(true)(fc()) -- fc now contains my street data!
            return true, fc()
        else
            print('Execution error:', fc)
        end
    else
        print('Compilation error:', err)
    end

    return false
end

fileUtils.getCurrentPath = function()
    return string.sub(debug.getinfo(1, 'S').source, 2)
    -- returns something like
    -- "@C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/fileUtils.lua"
    -- so we take out the first character, which is no control character by the way, so we cannot use gsub with %c


    -- local info
    -- local i = 1
    -- repeat
    --     info = debug.getinfo(i, 'S')
    --     i = i + 1
    --     print('LOLLO info = ')
    --     require('luadump')(true)(info)
    -- until info == nil
    -- info = debug.getinfo(i - 2, 'S')

    -- return info

    -- it will find stuff like
    -- {
    --     lastlinedefined = 91,
    --     linedefined = 75,
    --     short_src = "...ing_area/lollo_street_tuning_1/res/scripts/fileUtils.lua",
    --     source = "@C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/fileUtils.lua",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 75,
    --     linedefined = 9,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = "C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/construction/lollo_parallel_streets.con",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 235,
    --     linedefined = 7,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = "C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/construction/lollo_parallel_streets.con",
    --     what = "Lua"
    -- }
    -- and then
    -- {
    --     lastlinedefined = 235,
    --     linedefined = 7,
    --     short_src = "[string "C:/Program Files (x86)/Steam/userdata/7159018..."]",
    --     source = "C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/construction/lollo_parallel_streets.con",
    --     what = "Lua"
    -- }
end

fileUtils.getFilesInDir = function(dir, filterFn)
	filterFn = filterFn or function(fileName) return true end
	local result = {}
    local f = io.popen(string.format([[dir "%s" /b /a-d]], dir))
    --local f = io.popen(string.format([[dir "%s" /b /ad]], dir))
	if f then
		for s in f:lines() do
			if ((string.len(s) > 0) and filterFn(s))then
                result[#result + 1] = string.format([[%s%s]], dir, s)
                --result[#result + 1] = string.format([[%s%s/]], dir, s)
			end
		end
		f:close()
	end
	
	return result
end

fileUtils.getFilesInDirWithExtension = function(dir, ext)
    return fileUtils.getFilesInDir(dir, function(fname) return stringUtils.stringEndsWith(fname, '.' .. ext) end)
end

fileUtils.getPackagePaths = function()
    -- returns something like
    -- {
    --     "C:/Program Files (x86)/Steam/userdata/71590188/1066780/local/staging_area/lollo_street_tuning_1/res/scripts/?.lua",
    --     "res/scripts/?.lua"
    -- }
    
    return stringUtils.stringSplit(package.path, ';')
end

return fileUtils
