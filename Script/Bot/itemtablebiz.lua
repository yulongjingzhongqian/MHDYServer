local ItemTableBiz = class()

function ItemTableBiz:初始化(source)
	self.item = source
	self.refreshTime = os.time()
end

function ItemTableBiz:isNew(time)
	if time <= self.refreshTime then
		return false
	end

	return true
end

function ItemTableBiz:refresh()
	self.refreshTime = os.time()
end

return ItemTableBiz
