math.randomseed(os.time())
local charset = "abcdefghijklmnopqrstuvwxyz"


function randomString(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

request = function()
  value = math.random(1, 99)
  key = randomString(3)
  wrk.method = "POST"
  wrk.body = '{"key": "' .. key .. '", "value":' .. value .. '}'
  wrk.headers["Content-Type"] = "application/json"
  return wrk.format("POST", "/increment")
end
