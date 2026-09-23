local BBTableBiz = class()

function BBTableBiz:初始化(source)
	self.bb = source
	self.refreshTime = os.time()
end

function BBTableBiz:isNew(time)
	if time <= self.refreshTime then
		return false
	end

	return true
end

function BBTableBiz:refresh()
	self.refreshTime = os.time()
end

return BBTableBiz
