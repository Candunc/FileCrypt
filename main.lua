function exec(input)
	local handle = io.popen(input)
	local data = handle:read("*a")
	handle:close()

	return data
end

function writeDB(input)
	local output = exec("echo '"..json.encode(input).."' | lz4 -f -9 - candunc.db 2>&1")
	local value = 0
	for token in string.gmatch(string.gsub(output,"\n",""),"[^ ]+") do
		value = (value+1)
		if value == 3 then
			start = token
		elseif value == 6 then
			stop = token
		elseif value == 9 then
			ratio = token
		end
	end
	print("Compression Ratio: "..ratio.." ("..start.." -> "..stop..")")
end

function readDB()
	local file = io.open("candunc.db","r")
	if file == nil then
		return {files={}}
	else
		file:close()

		return json.decode(exec("lz4cat candunc.db"))
	end
end

function IndexDir(path) -- Input = database
	local input = {}
	for file in lfs.dir(path) do -- Local directory for now
		if string.sub(file,1,1) ~= "." then -- Ignore hidden directories and files
			local point = (path.."/"..file)
			local attr = lfs.attributes(point)
			if attr.mode == "directory" then
				count.folders = (count.folders+1)
				input[file] = IndexDir(point)
			else
				if db["files"][point] == nil then
					count.files = (count.files+1)
					hash = string.sub(exec("shasum -a 256 '"..point.."'"),1,64)
					db["files"][point] = hash
					input[file] = point
				end
			end
		end
	end

	return input
end
lfs  = require("lfs")
json = require("json")

-- Todo: parse arguments here

count = {folders = 0, files = 0, time = os.time()}
db = readDB()
db["folders"] = IndexDir("/Users/candunc/Dropbox/Projects")

writeDB(db)

print("Took "..(os.time() - count.time).." seconds to index "..count.folders.." folders and hash "..count.files.." new files.")