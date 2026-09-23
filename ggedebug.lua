local errored = nil
local _print = print

__gge.traceback = function(msg)
	if not errored then
		print(tostring(msg))

		if #错误日志 <= 100 then
			错误日志[#错误日志 + 1] = {
				时间 = os.time(),
				记录 = tostring(msg)
			}
		end
	end
end
