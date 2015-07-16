function stderr(input) --Wrapper for writing to stderr, so code looks cleaner
	io.stderr:write(input.."\n")
	os.exit()
end

function exec(input)
	local handle = io.popen(input)
	local data = handle:read("*a")
	handle:close()

	return data
end

function strip(input) -- Remove special characters from a line, so it is safe to use in bash.
	local output = string.gsub(input,"&","\\&")
	local output = string.gsub(input,"(","\\(")
	local output = string.gsub(input,"%)","\\)")
	local output = string.gsub(input,"{","\\{")
	local output = string.gsub(input,"}","\\}")
	return output
end

function readConfig()
	local file = io.open("config.json","r")
	local output = json.decode(file:read("*a"))
	file:close()

	return output
end

function writeDB(input)
	local output = exec("echo '"..json.encode(input).."' | lz4 -f -9 - "..config["db_path"].."/"..config["db_file"].." 2>&1")
	local value = 0 --This following code is to grab the results from lz4, so we can figure out how efficient the compression is. 
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
	local file = io.open(config["db_path"].."/"..config["db_file"],"r")
	if file == nil then
		return {files={};}
	else
		file:close()

		return json.decode(exec("lz4cat '"..config["db_path"].."/"..config["db_file"].."'"))
	end
end

function IndexDir(path)
	local input = {}
	for file in lfs.dir(path) do
		if string.sub(file,1,1) ~= "." then -- Ignore hidden directories and files
			local point = (path.."/"..file)
			local attr = lfs.attributes(point)
			if attr.mode == "directory" then
				count.folders = (count.folders+1)
				input[file] = IndexDir(point)
			else
				if db["files"][point] == nil then
					count.files = (count.files+1)
					hash = string.sub(exec(config["hash_cmd"].." '"..strip(point).."'"),1,config["hash_len"])
					db["files"][point] = hash
					input[file] = point
				end
			end
		end
	end

	return input
end

function help()
	print("Not implemented.")
	os.exit()
end

lfs  = require("lfs")
json = require("json")

config = readConfig()

for key,value in ipairs(arg) do
	if value == "-i" or value == "--index" then
		if action == nil then
			action = "index"
		else
			stderr("Error, multiple program types entered!")
		end

	elseif value == "-r" or value == "--restore" then
		if action == nil then
			action = "restore"
		else
			stderr("Error, multiple program types entered! Use the argument '--help' for more instructions.")
		end

	elseif value == "-f" or value == "--file" then --Which database file it is stored in. If not given, assume the default in config.json
		config["db_file"] = arg[(key+1)]

	elseif value == "-d" or value == "--directory" then --Path to the directory we are indexing / storing, depending on mode.
		config["directory"] = arg[(key+1)]

	elseif value == "-h" or value == "--help" then 
		help()
	end
end

if action == nil then
	stderr("Error, action not specified. Please include either '--index' or '--restore', or use the argument '--help' for more instructions.")
end

if config["directory"] == nil or config["directory"] == "" then
	stderr("Error, directory not specified, please specify one using '--directory' or use the argument '--help' for more instructions.")
end

count = {folders = 0, files = 0, time = os.time()} -- For statistics purposes

db = readDB()
db["folders"] = IndexDir(config["directory"])

writeDB(db)

print("Took "..(os.time() - count.time).." seconds to index "..count.folders.." folders and hash "..count.files.." new files.")