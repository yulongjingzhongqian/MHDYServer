local 技能类 = class()
local ski = 取法术技能
local typ = type

function 技能类:初始化()
end

function 技能类:置对象(名称, f)
	if 名称 == nil then
		return
	end

	if typ(名称) == "table" then
		名称 = 名称.名称
	end

	local n = ski(名称)

	if n == nil then
		return
	end

	self.名称 = 名称

	if f ~= nil and f ~= 1 and f ~= 2 then
		return
	end

	self.介绍 = n[1]
	self.介绍 = nil

	if self.种类 == 0 then
		self.包含技能 = {}
	end

	if self.种类 ~= 8 and self.种类 ~= 7 then
		self.学会 = false
	end

	if self.种类 ~= nil then
	end

	if self.种类 ~= nil then
	end
end

function 技能类:更新(dt)
end

function 技能类:显示(x, y)
end

return 技能类
