local 助战系统 = class()
local floor = math.floor
local ceil = math.ceil
local jnzb = require("script/角色处理类/技能类")

function 助战系统:初始化()
	self.数据 = {}
end

function 助战系统:更新辅助技能(编号)
	if #self.数据[编号].辅助技能 == 0 or #self.数据[编号].辅助技能 ~= #助战辅助技能 then
		local aa = {}

		for i = 1, #self.数据[编号].辅助技能 do
			aa[self.数据[编号].辅助技能[i].名称] = self.数据[编号].辅助技能[i].等级 + 0
		end

		self.数据[编号].辅助技能 = {}

		for n = 1, #助战辅助技能 do
			self.数据[编号].辅助技能[n] = {
				名称 = 助战辅助技能[n],
				等级 = aa[助战辅助技能[n]] or 0
			}
		end
	end
end

function 助战系统:加载数据(账号, 玩家id)
	self.id = 玩家id

	if f函数.文件是否存在("data/" .. 账号 .. "/" .. self.id .. "/助战.txt") == false then
		写出文件("data/" .. 账号 .. "/" .. self.id .. "/助战.txt", table.tostring({}))
	end

	self.数据 = table.loadstring(读入文件("data/" .. 账号 .. "/" .. self.id .. "/助战.txt"))

	for i = 1, #self.数据 do
		更新助战技能(self.id, self.数据[i])

		if self.数据[i].玩家id == nil then
			self.数据[i].玩家id = self.id + 0

			print(self.数据[i].玩家id)
		end

		if self.数据[i].辅助技能 == nil then
			self.数据[i].辅助技能 = {}

			self:添加辅助等级(i, 10)
		end

		玩家强化技能顺序调整(self.数据[i])
		self:更新辅助技能(i)

		if self.数据[i].当前修炼 == nil then
			self.数据[i].当前修炼 = {
				当前 = "攻击修炼",
				攻击修炼 = {
					0,
					0,
					0
				},
				法术修炼 = {
					0,
					0,
					0
				},
				防御修炼 = {
					0,
					0,
					0
				},
				抗法修炼 = {
					0,
					0,
					0
				}
			}
			self.数据[i].当前修炼.攻击修炼[1] = self.数据[i].修炼.攻击修炼 + 0
			self.数据[i].当前修炼.法术修炼[1] = self.数据[i].修炼.法术修炼 + 0
			self.数据[i].当前修炼.防御修炼[1] = self.数据[i].修炼.防御修炼 + 0
			self.数据[i].当前修炼.抗法修炼[1] = self.数据[i].修炼.抗法修炼 + 0
		end

		self:刷新修炼等级(i)

		if self.数据[i].气血 == nil or self.数据[i].魔法 == nil then
			self.数据[i].气血 = 1
			self.数据[i].魔法 = 1
			self.数据[i].名称 = "出错助战请遗弃"
		end

		if self.数据[i].认证码 == nil or string.find(self.数据[i].认证码, "_") then
			玩家数据[self.id].角色.数据.助战认证 = (玩家数据[self.id].角色.数据.助战认证 or 0) + 1
			self.数据[i].认证码 = "z" .. self.id .. "z" .. 玩家数据[self.id].角色.数据.助战认证
		end

		if 判断是否为空表(self.数据[i].装备属性) then
			self.数据[i].装备属性 = {
				伤害 = 0,
				体质 = 0,
				格挡值 = 0,
				乾元丹 = 0,
				法术伤害结果 = 0,
				物理暴击伤害 = 0,
				气血 = 0,
				气血回复效果 = 0,
				附加乾元丹 = 0,
				剩余乾元丹 = 0,
				力量 = 0,
				可换乾元丹 = 21,
				穿刺等级 = 0,
				魔力 = 0,
				敏捷 = 0,
				耐力 = 0,
				法防 = 0,
				躲避 = 0,
				法伤 = 0,
				物理暴击等级 = 0,
				命中 = 0,
				抗法术暴击等级 = 0,
				固定伤害 = 0,
				抵抗封印等级 = 0,
				魔法 = 0,
				灵力 = 0,
				速度 = 0,
				法术暴击伤害 = 0,
				防御 = 0,
				抗物理暴击等级 = 0,
				月饼 = 0,
				法术暴击等级 = 0,
				封印命中等级 = 0,
				治疗能力 = 0,
				狂暴等级 = 0
			}
		end

		local aa = {
			附加乾元丹 = 0,
			剩余乾元丹 = 0,
			乾元丹 = 0,
			月饼 = 0,
			可换乾元丹 = 0
		}

		for n, v in pairs(aa) do
			if self.数据[i].装备属性[n] == nil then
				self.数据[i].装备属性[n] = v
			end
		end

		self.数据[i].装备属性.可换乾元丹 = 取可换乾元丹(self.数据[i].等级)

		if self.数据[i].蚩尤元神 == nil then
			self.数据[i].蚩尤元神 = 玩家数据[self.id].角色.数据.蚩尤元神
		end

		local rw列表 = 玩家数据[self.id].角色:取任务1(777)
		local 变身卡 = false

		if rw列表 ~= false then
			for n = 1, #rw列表 do
				if 任务数据[rw列表[n]].编号 == i then
					变身卡 = true

					break
				end
			end
		end

		if not 变身卡 then
			玩家数据[self.id].助战.数据[i].变身数据 = nil
			玩家数据[self.id].助战.数据[i].变异 = nil
			玩家数据[self.id].助战.数据[i].变身卡技能 = nil
		end

		self.数据[i].飞升 = 玩家数据[玩家id].角色.数据.飞升
		self.数据[i].渡劫 = 玩家数据[玩家id].角色.数据.渡劫

		if self.数据[i].飞升 == true and self.数据[i].师门技能 ~= nil and #self.数据[i].师门技能 > 0 then
			for n = 1, #self.数据[i].师门技能 do
				角色升级门派技能(self.数据[i], self.数据[i].师门技能[n])
			end
		end
	end
end

function 助战系统:染色处理(编号, 染色组)
	local 彩果数量 = 10

	for n = 1, #染色组 do
		彩果数量 = 彩果数量 + 染色组[n]
	end

	local id = self.id
	local 扣除数据 = {}
	local 已扣除 = 0

	for n = 1, 100 do
		if 玩家数据[id].角色.数据.道具[n] ~= nil and 玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[n]] ~= nil and 玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[n]].名称 == "彩果" and 已扣除 < 彩果数量 then
			if 玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[n]].数量 >= 彩果数量 - 已扣除 then
				扣除数据[#扣除数据 + 1] = {
					格子 = n,
					id = 玩家数据[id].角色.数据.道具[n],
					数量 = 彩果数量 - 已扣除
				}
				已扣除 = 已扣除 + 彩果数量 - 已扣除
			else
				已扣除 = 已扣除 + 玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[n]].数量
				扣除数据[#扣除数据 + 1] = {
					格子 = n,
					id = 玩家数据[id].角色.数据.道具[n],
					数量 = 玩家数据[id].道具.数据[玩家数据[id].角色.数据.道具[n]].数量
				}
			end
		end
	end

	if 已扣除 < 彩果数量 then
		常规提示(id, "需要#P" .. 彩果数量 .. "#Y个彩果、你没有那么多的彩果")

		return
	else
		for n = 1, #扣除数据 do
			玩家数据[id].道具.数据[扣除数据[n].id].数量 = 玩家数据[id].道具.数据[扣除数据[n].id].数量 - 扣除数据[n].数量

			if 玩家数据[id].道具.数据[扣除数据[n].id].数量 < 1 then
				玩家数据[id].道具.数据[扣除数据[n].id] = nil
				玩家数据[id].角色.数据.道具[扣除数据[n].格子] = nil
			end
		end

		常规提示(id, "染色成功！")

		self.数据[编号].染色组 = 染色组

		发送数据(玩家数据[self.id].连接id, 102.2, {
			编号 = 编号,
			染色组 = 染色组
		})
	end
end

function 助战系统:数据处理(序号, 内容)
	local 编号 = 内容.编号

	if 序号 ~= 87.1 and 序号 ~= 87.2 and 序号 ~= 87.6 and 序号 ~= 87.7 then
		if self.数据[编号] == nil then
			return
		elseif 玩家数据[self.id].战斗 ~= 0 then
			return
		end
	end

	local 是否刷新 = 0

	if 序号 == 87.1 then
		if 玩家数据[self.id].召唤兽.数据[内容.宠物编号] ~= nil then
			玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 = nil
			self.数据[内容.助战编号].宠物认证码 = nil
		end

		常规提示(self.id, "#Y/助战召唤兽已休息")
		发送数据(玩家数据[self.id].连接id, 120, {
			召唤兽数据 = 玩家数据[self.id].召唤兽.数据,
			助战数据 = self.数据
		})
	elseif 序号 == 87.2 then
		local 高于等级 = 召唤兽参战高于等级 + 0

		if 玩家数据[self.id].角色.数据.飞升 == true then
			高于等级 = 高于等级 + 飞升高于等级
		end

		if 玩家数据[self.id].角色.数据.等级 + 高于等级 < 玩家数据[self.id].召唤兽.数据[内容.宠物编号].等级 then
			常规提示(self.id, "你目前的等级小于该召唤兽" .. 高于等级 .. "级以上,不允许参战")

			return
		elseif 玩家数据[self.id].召唤兽.数据[内容.宠物编号].参战信息 then
			常规提示(self.id, "角色已经参战了该宝宝")

			return
		elseif 玩家数据[self.id].召唤兽.数据[内容.宠物编号].寿命 <= 50 then
			常规提示(self.id, "该召唤兽的寿命低于50无法参战")

			return
		end

		if 玩家数据[self.id].召唤兽.数据[内容.宠物编号] ~= nil and 玩家数据[self.id].召唤兽.数据[内容.宠物编号].参战信息 == nil then
			if self.数据[内容.助战编号].宠物认证码 == nil then
				if 玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 == nil then
					self.数据[内容.助战编号].宠物认证码 = 玩家数据[self.id].召唤兽.数据[内容.宠物编号].认证码
					玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 = 内容.助战编号
				else
					if self.数据[玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战] ~= nil and self.数据[玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战].宠物认证码 ~= nil then
						self.数据[玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战].宠物认证码 = nil
					end

					玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 = nil
					self.数据[内容.助战编号].宠物认证码 = 玩家数据[self.id].召唤兽.数据[内容.宠物编号].认证码
					玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 = 内容.助战编号
				end
			else
				local 编号 = 玩家数据[self.id].召唤兽:取编号(self.数据[内容.助战编号].宠物认证码)

				if 编号 ~= 0 then
					玩家数据[self.id].召唤兽.数据[编号].助战参战 = nil
				end

				if 玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 == nil then
					self.数据[内容.助战编号].宠物认证码 = 玩家数据[self.id].召唤兽.数据[内容.宠物编号].认证码
					玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 = 内容.助战编号
				else
					self.数据[玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战].宠物认证码 = nil
					玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 = nil
					self.数据[内容.助战编号].宠物认证码 = 玩家数据[self.id].召唤兽.数据[内容.宠物编号].认证码
					玩家数据[self.id].召唤兽.数据[内容.宠物编号].助战参战 = 内容.助战编号
				end
			end
		end

		常规提示(self.id, "#Y/参战成功!")
		发送数据(玩家数据[self.id].连接id, 120, {
			召唤兽数据 = 玩家数据[self.id].召唤兽.数据,
			助战数据 = self.数据
		})
	elseif 序号 == 87.6 then
		local 坐骑数据 = 玩家数据[self.id].角色.数据.坐骑列表

		if 坐骑数据[内容.坐骑编号] ~= nil then
			坐骑数据[内容.坐骑编号].助战参战 = nil
			self.数据[内容.助战编号].坐骑认证码 = nil
		end

		常规提示(self.id, "#Y/助战坐骑已下骑")
		角色刷新信息(self.id, self.数据[内容.助战编号])
		发送数据(玩家数据[self.id].连接id, 120.1, {
			坐骑数据 = 坐骑数据,
			助战数据 = self.数据
		})
	elseif 序号 == 87.7 then
		print(87.7)

		local 坐骑数据 = 玩家数据[self.id].角色.数据.坐骑列表

		if 坐骑数据[内容.坐骑编号].参战信息 then
			常规提示(self.id, "角色已经骑乘了该坐骑！")

			return
		end

		if 坐骑数据[内容.坐骑编号] ~= nil then
			if self.数据[内容.助战编号].坐骑认证码 == nil then
				if 坐骑数据[内容.坐骑编号].助战参战 == nil then
					self.数据[内容.助战编号].坐骑认证码 = 坐骑数据[内容.坐骑编号].认证码
					坐骑数据[内容.坐骑编号].助战参战 = 内容.助战编号
				else
					if self.数据[坐骑数据[内容.坐骑编号].助战参战] ~= nil and self.数据[坐骑数据[内容.坐骑编号].助战参战].坐骑认证码 ~= nil then
						self.数据[坐骑数据[内容.坐骑编号].助战参战].坐骑认证码 = nil
					end

					坐骑数据[内容.坐骑编号].助战参战 = nil
					self.数据[内容.助战编号].坐骑认证码 = 坐骑数据[内容.坐骑编号].认证码
					坐骑数据[内容.坐骑编号].助战参战 = 内容.助战编号
				end
			else
				local 编号 = 0

				for i = 1, #坐骑数据 do
					if 坐骑数据[i].认证码 == self.数据[内容.助战编号].坐骑认证码 then
						编号 = i

						break
					end
				end

				if 编号 ~= 0 then
					坐骑数据[编号].助战参战 = nil
				end

				if 坐骑数据[内容.坐骑编号].助战参战 == nil then
					self.数据[内容.助战编号].坐骑认证码 = 坐骑数据[内容.坐骑编号].认证码
					坐骑数据[内容.坐骑编号].助战参战 = 内容.助战编号
				else
					self.数据[坐骑数据[内容.坐骑编号].助战参战].坐骑认证码 = nil
					坐骑数据[内容.坐骑编号].助战参战 = nil
					self.数据[内容.助战编号].坐骑认证码 = 坐骑数据[内容.坐骑编号].认证码
					坐骑数据[内容.坐骑编号].助战参战 = 内容.助战编号
				end
			end
		end

		常规提示(self.id, "#Y/助战骑乘成功!")
		角色刷新信息(self.id, self.数据[内容.助战编号])
		发送数据(玩家数据[self.id].连接id, 120.1, {
			坐骑数据 = 坐骑数据,
			助战数据 = self.数据
		})
	elseif 序号 == 87.3 then
		self:保存加点方案(内容)
	elseif 序号 == 87.4 then
		local bh = 内容.编号

		if self.数据[bh] ~= nil then
			self.数据[bh].自动加点 = 内容.开关

			if self.数据[bh].自动加点 then
				常规提示(self.id, "#Y/你的助战#R" .. self.数据[bh].名称 .. "#P开启了#S自动加点#Y、升级后将按保存的加点方案分配潜力点")
			else
				常规提示(self.id, "#Y/你的助战#R" .. self.数据[bh].名称 .. "#P关闭了#S自动加点")
			end
		end
	elseif 序号 == 87.5 then
		local bh = 内容.编号

		if self.数据[bh] ~= nil then
			self.数据[bh].自动升级 = 内容.开关

			if self.数据[bh].自动升级 then
				常规提示(self.id, "#Y/你的助战#R" .. self.数据[bh].名称 .. "#P开启了#S自动升级#Y、获得经验后将自动升级！")
			else
				常规提示(self.id, "#Y/你的助战#R" .. self.数据[bh].名称 .. "#P关闭了#S自动升级")
			end
		end
	elseif 序号 == 87 then
		是否刷新 = 1
		self.数据[编号].名称 = 内容.名称

		常规提示(self.id, "#Y/改名成功!")
	elseif 序号 == 86 then
		if 玩家数据[self.id].角色.数据.助战 == nil then
			玩家数据[self.id].角色.数据.助战 = {}
		end

		if self.数据[编号].参战 then
			self.数据[编号].参战 = false

			for i = 1, #玩家数据[self.id].角色.数据.助战 do
				if 玩家数据[self.id].角色.数据.助战[i] == 编号 then
					table.remove(玩家数据[self.id].角色.数据.助战, i)
				end
			end

			是否刷新 = 1
		elseif #玩家数据[self.id].角色.数据.助战 >= 4 then
			常规提示(self.id, "#Y/你当前已经有4位助战帮手参战了!")

			return
		elseif 玩家数据[self.id].队伍 ~= 0 and 玩家数据[self.id].队长 and #队伍数据[玩家数据[self.id].队伍].成员数据 + 1 > 5 then
			常规提示(self.id, "#Y/你当前队伍内人数已经达到5人!")

			return
		else
			self.数据[编号].参战 = true
			玩家数据[self.id].角色.数据.助战[#玩家数据[self.id].角色.数据.助战 + 1] = 编号

			常规提示(self.id, "#Y/助战帮手参战成功!\n需要#GALT+T#Y创建队伍#后方可生效")
		end

		if 玩家数据[self.id].队伍 ~= 0 and 玩家数据[self.id].队长 then
			队伍处理类:重置助战(self.id, 1)
		end

		是否刷新 = 1
	elseif 序号 == 85 then
		if 玩家数据[self.id].角色.数据.等级 <= self.数据[编号].等级 then
			常规提示(self.id, "#P助战等级#Y无法超过人物等级!")

			return
		elseif self.数据[编号].当前经验 < self.数据[编号].最大经验 then
			常规提示(self.id, "#P" .. self.数据[编号].名称 .. "#Y/当前经验不足、无法升级!")

			return
		else
			if self.数据[编号].自动升级 == true then
				self:连续升级(编号, 1)
			else
				self:升级(编号, 1)
			end

			是否刷新 = 1
		end
	elseif 序号 == 84 then
		self:遗弃助战(编号)
	elseif 序号 == 83 then
		if self.数据[编号].门派 == "无门派" or self.数据[编号].师门技能 == nil then
			常规提示(self.id, "#Y/你没有门派或没有学习过任意师门技能、无法退出!")

			return
		elseif 取银子(self.id) < 退出门派消耗银两 * 10000 then
			常规提示(self.id, "#Y/你当前的银子好像不够" .. 退出门派消耗银两 .. "W两哟!")

			return
		elseif not 判断是否为空表(self.数据[编号].装备) or not 判断是否为空表(self.数据[编号].法宝佩戴) then
			常规提示(self.id, "#Y/请卸下助战的装备和法宝!")

			return
		end

		if 助战升级技能是否消耗 ~= 1 then
			local 返还 = 退出门派返还计算(self.数据[编号])

			self:添加经验(编号, 返还.经验)

			玩家数据[self.id].角色.数据.储备 = 玩家数据[self.id].角色.数据.储备 + 返还.金钱

			常规提示(self.id, "#Y/你获得了" .. 返还.金钱 .. "点退出门派返还储备")
			常规提示(self.id, "#Y/助战" .. self.数据[编号].名称 .. "获得了" .. 返还.经验 .. "点退出门派返还经验")
		end

		系统处理类:清空奇经八脉(self.id, 编号)
		玩家数据[self.id].角色:扣除银子(退出门派消耗银两 * 10000, 0, 0, "助战退出门派", 1)

		self.数据[编号].门派 = "无门派"
		self.数据[编号].技能 = {}
		self.数据[编号].经脉流派 = nil
		self.数据[编号].师门技能 = nil
		self.数据[编号].技能属性 = {
			魔力 = 0,
			体质 = 0,
			力量 = 0,
			气血 = 0,
			敏捷 = 0,
			耐力 = 0,
			魔法 = 0,
			躲避 = 0,
			灵力 = 0,
			伤害 = 0,
			速度 = 0,
			命中 = 0,
			防御 = 0
		}

		常规提示(self.id, "#Y/退出门派成功!")
		发送数据(玩家数据[self.id].连接id, 107.4, {
			门派 = self.数据[编号].门派,
			编号 = 编号
		})

		是否刷新 = 1
	elseif 序号 == 82 then
		self.数据[编号].门派 = 分割文本(内容.门派, "(")[1]
		是否刷新 = 1

		常规提示(self.id, "#Y/加入门派成功!")
		发送数据(玩家数据[self.id].连接id, 107.4, {
			门派 = self.数据[编号].门派,
			编号 = 编号
		})
	elseif 序号 == 81 then
		self:加点处理(编号, 内容.加点)

		是否刷新 = 1
	elseif 序号 == 80 then
		if 玩家数据[self.id].角色.数据.道具行囊打开.道具 == nil then
			玩家数据[self.id].角色.数据.道具行囊打开.道具 = 1

			发送数据(玩家数据[self.id].连接id, 103, {
				编号 = 编号,
				门派 = self.数据[编号].门派,
				模型 = self.数据[编号].模型,
				装备 = self:取装备数据(编号),
				道具 = 玩家数据[self.id].道具:索要道具2(self.id),
				灵饰 = self:取灵饰数据(编号),
				技能 = self:取技能数据(编号),
				法宝 = self:取法宝数据(id, self.id, 编号),
				锦衣 = self:取锦衣数据(id, self.id, 编号),
				灵饰 = self:取灵饰数据(编号),
				助战修炼 = self.数据[编号].修炼,
				助战修炼经验 = self.数据[编号].助战修炼经验
			})
		else
			发送数据(玩家数据[self.id].连接id, 103, {
				编号 = 编号,
				门派 = self.数据[编号].门派,
				模型 = self.数据[编号].模型,
				装备 = self:取装备数据(编号),
				灵饰 = self:取灵饰数据(编号),
				技能 = self:取技能数据(编号),
				法宝 = self:取法宝数据(id, self.id, 编号),
				锦衣 = self:取锦衣数据(id, self.id, 编号),
				灵饰 = self:取灵饰数据(编号),
				助战修炼 = self.数据[编号].修炼,
				助战修炼经验 = self.数据[编号].助战修炼经验
			})
		end
	elseif 序号 == 79 then
		self:使用道具(编号, 内容)
	elseif 序号 == 78 then
		self:添加装备(编号, 内容)
	elseif 序号 == 78.2 then
		self:佩戴锦衣(编号, 内容)
	elseif 序号 == 78.3 then
		self:卸下锦衣(编号, 内容)
	elseif 序号 == 77 then
		self:去除装备(编号, 内容)
	elseif 序号 == 76 then
		self:洗点处理(编号)
	elseif 序号 == 75 then
		self.数据[编号].技能 = 内容.技能

		常规提示(self.id, "#Y/修改助战技能成功!")

		是否刷新 = 1
	elseif 序号 == 75.1 then
		self:修炼提升(编号, 内容)
	end

	if 是否刷新 == 1 then
		发送数据(玩家数据[self.id].连接id, 100, {
			编号 = 编号,
			数据 = self:取指定数据(编号)
		})
	end

	if 是否刷新 == 2 then
		发送数据(玩家数据[self.id].连接id, 100, {
			编号 = 编号,
			数据 = self:取指定数据(编号)
		})
	end
end

function 助战系统:添加辅助等级(编号, 等级, 智能)
	if self.数据[编号].辅助技能 == nil then
		self.数据[编号].辅助技能 = {}
	end

	for i = 1, 助战辅助技能数量 do
		if 智能 ~= nil and self.数据[编号].辅助技能[i] ~= nil and self.数据[编号].辅助技能[i].等级 ~= nil then
			self.数据[编号].辅助技能[i] = {
				学会 = true,
				名称 = 助战辅助技能[i],
				等级 = math.max(等级, self.数据[编号].辅助技能[i].等级 or 0)
			}
		else
			self.数据[编号].辅助技能[i] = {
				学会 = true,
				名称 = 助战辅助技能[i],
				等级 = 等级
			}
		end
	end
end

function 助战系统:使用道具(编号, 内容)
	local 道具格子 = 内容.物品编号
	local 道具id = 玩家数据[self.id].角色.数据.道具[道具格子]
	local id = self.id + 0

	if 道具id == nil or 玩家数据[self.id].道具.数据[道具id] == nil then
		玩家数据[self.id].角色.数据.道具[道具格子] = nil

		刷新道具行囊单格(self.id, "道具", 道具格子, nil)

		return
	end

	local item = 玩家数据[self.id].道具.数据[道具id]
	local 名称 = item.名称
	local 使用成功 = false

	if string.find(名称, "级装备礼包") then
		if self.数据[编号] ~= nil and self.数据[编号].模型 ~= nil then
			local 礼包等级 = string.gsub(名称, "级装备礼包", "")

			print(礼包等级)
			礼包奖励类:全套装备礼包(self.id, tonumber(礼包等级), "无级别限制", "专用", self.数据[编号])
			常规提示(self.id, "你成功获得了一套" .. 礼包等级 .. "级装备")

			使用成功 = true
		end
	elseif string.find(名称, "级高级装备礼包") then
		if self.数据[编号] ~= nil and self.数据[编号].模型 ~= nil then
			local 礼包等级 = tonumber(string.gsub(名称, "级高级装备礼包", ""))

			礼包奖励类:全套高级装备礼包(self.id, tonumber(礼包等级), "无级别限制", "专用", self.数据[编号])
			常规提示(self.id, "你成功获得了一套" .. 礼包等级 .. "级装备")

			使用成功 = true
		end
	elseif 定制装备礼包[名称] ~= nil then
		local id = self.id
		local 道具格子 = 玩家数据[id].角色:取道具格子2()

		if 道具格子 <= 1 then
			常规提示(id, "您的道具栏物品已经满啦")

			return 0
		end

		玩家数据[id].角色.数据.对话类型 = "自选定制装备"
		玩家数据[id].角色.数据.自选装备 = 定制装备礼包[名称]
		玩家数据[id].角色.数据.自选装备流程 = 0
		玩家数据[id].角色.数据.定制装备参数 = {}
		玩家数据[id].角色.数据.定制装备助战 = 编号 + 0

		添加最后对话(id, "请选择" .. 玩家数据[id].角色.数据.自选装备 .. "特技：", 通用特技)

		return
	elseif 名称 == "月华露" then
		使用成功 = true

		self:添加经验(编号, item.阶品 * 100 * math.max(self.数据[编号].等级, 1))
	elseif 名称 == "九转金丹" then
		使用成功 = self:添加修炼经验(编号, math.floor(item.阶品 * 0.5))
	elseif 名称 == "储灵袋" then
		local id = self.id

		if self.数据[编号].法宝佩戴 ~= nil and not 判断是否为空表(self.数据[编号].法宝佩戴) then
			上交物品位置[id] = {}
			local 法宝佩戴数据 = self.数据[编号].法宝佩戴
			local fbxx = {}

			for k, v in pairs(法宝佩戴数据) do
				fbxx[#fbxx + 1] = format("[%s]%s,级别:%s,灵气:%s", k, 玩家数据[id].道具.数据[v].名称, 玩家数据[id].道具.数据[v].分类, 玩家数据[id].道具.数据[v].魔法)
				上交物品位置[id][#上交物品位置[id] + 1] = {
					储灵袋位置 = 道具格子,
					道具位置 = v,
					背包位置 = v,
					名称 = 玩家数据[id].道具.数据[v].名称,
					对话内容 = fbxx[#fbxx]
				}
			end

			添加最后对话(id, "请选择要补充灵气的助战法宝：", fbxx)

			玩家数据[id].最后操作 = "通用上交物品"
			玩家数据[id].储灵袋助战编号 = 编号
			上交物品位置[id].事件 = "助战储灵袋补充灵气"
			玩家数据[id].储灵袋位置 = 道具格子

			return
		else
			常规提示(id, "使用失败、#P" .. self.数据[编号].名称 .. "#Y当前未佩戴法宝")

			return
		end
	elseif 名称 == "怪物卡片" then
		self.数据[编号].变身数据 = item.造型
		self.数据[编号].变身卡技能 = nil

		if item.技能 ~= nil and item.技能 ~= "" then
			self.数据[编号].变身卡技能 = item.技能
		end

		self.数据[编号].变异 = false

		if 取随机数() <= 5 and 染色信息[item.造型] then
			self.数据[编号].变异 = true

			常规提示(id, "恭喜你！卡片产生了变异效果")
		end

		使用成功 = true

		发送数据(玩家数据[id].连接id, 102.1, {
			编号 = 编号,
			变身 = self.数据[编号].变身数据,
			变异 = self.数据[编号].变异
		})
		任务处理类:添加助战变身(id, 编号)
		常规提示(id, "你使用了怪物卡片")
		self:刷新信息(编号)
	else
		常规提示(self.id, "#Y/该物品暂时无法使用!")
	end

	if 使用成功 then
		if 删除数量 == nil then
			删除数量 = 1
		end

		if 玩家数据[self.id].道具.数据[道具id].数量 == nil and 玩家数据[self.id].道具.数据[道具id].名称 ~= "怪物卡片" then
			玩家数据[self.id].道具.数据[道具id] = nil
			玩家数据[self.id].角色.数据.道具[道具格子] = nil
		elseif 玩家数据[self.id].道具.数据[道具id].名称 == "怪物卡片" then
			玩家数据[self.id].道具.数据[道具id].次数 = 玩家数据[self.id].道具.数据[道具id].次数 - 1

			if 玩家数据[self.id].道具.数据[道具id].次数 <= 0 then
				玩家数据[self.id].道具.数据[道具id] = nil
				玩家数据[self.id].角色.数据.道具[道具格子] = nil
			end
		else
			玩家数据[self.id].道具.数据[道具id].数量 = 玩家数据[self.id].道具.数据[道具id].数量 - 删除数量

			if 玩家数据[self.id].道具.数据[道具id].数量 < 1 then
				玩家数据[self.id].道具.数据[道具id] = nil
				玩家数据[self.id].角色.数据.道具[道具格子] = nil
			end
		end

		刷新道具行囊单格(self.id, "道具", 道具格子, 道具id)
		self:刷新信息(编号, 1)
		发送数据(玩家数据[self.id].连接id, 100, {
			编号 = 编号,
			数据 = self:取指定数据(编号)
		})
	end
end

function 助战系统:取队伍数据(编号)
	local 发送数据 = {
		模型 = self.数据[编号].模型,
		等级 = self.数据[编号].等级,
		名称 = self.数据[编号].名称,
		门派 = self.数据[编号].门派,
		染色组 = self.数据[编号].染色组,
		染色方案 = self.数据[编号].染色方案,
		当前称谓 = self.数据[编号].当前称谓,
		id = self.id,
		装备 = {},
		锦衣 = self.数据[编号].锦衣名称 or {}
	}

	if self.数据[编号].装备[3] ~= nil then
		发送数据.装备[3] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].装备[3]]))
	end

	if self.数据[编号].模型 == "影精灵" and self.数据[编号].装备[4] ~= nil and 玩家数据[self.id].道具.数据[self.数据[编号].装备[4]].子类 == 911 then
		发送数据.装备[4] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].装备[4]]))
	end

	return 发送数据
end

function 助战系统:附魔装备刷新(编号, 装备id)
	local 刷新判定 = 附魔刷新(self.id, 装备id, self.数据[编号])

	if 刷新判定 then
		self:刷新信息(编号, 1)
	end
end

function 助战系统:取技能数据(编号)
	local 发送信息 = {
		技能 = self.数据[编号].技能,
		特殊技能 = self.数据[编号].特殊技能
	}

	return 发送信息
end

function 助战系统:洗点处理(编号)
	local 银子 = 0

	if 取银子(self.id) < 银子 then
		常规提示(self.id, "#Y/你当前的银子好像不够哟!")

		return
	else
		角色洗点(self.数据[编号])
		常规提示(self.id, "#Y/助战帮手洗点成功!")
		self:刷新信息(编号, 1)
		发送数据(玩家数据[self.id].连接id, 100, {
			编号 = 编号,
			数据 = self:取指定数据(编号)
		})
	end
end

function 助战系统:去除装备(编号, 内容)
	local 临时格子 = 玩家数据[self.id].角色:取道具格子1("道具")

	if 临时格子 == 0 then
		常规提示(self.id, "您的道具栏物品已经满啦")

		return 0
	end

	local 道具格子 = 内容.物品编号
	local 道具id = 0

	if 内容.灵饰 ~= nil then
		道具id = self.数据[编号].灵饰[道具格子] + 0
	else
		道具id = self.数据[编号].装备[道具格子] + 0
	end

	if 玩家数据[self.id].道具.数据[道具id] == nil or 玩家数据[self.id].道具.数据[道具id].分类 == nil then
		return
	elseif 玩家数据[self.id].道具.数据[道具id] ~= nil and 玩家数据[self.id].道具.数据[道具id].灵饰 ~= nil and 玩家数据[self.id].道具.数据[道具id].灵饰 then
		self:卸下灵饰(编号, 道具格子, 道具id)

		return
	elseif 玩家数据[self.id].道具.数据[道具id] ~= nil and 玩家数据[self.id].道具.数据[道具id].类型 ~= nil and 玩家数据[self.id].道具.数据[道具id].类型 == "魂环" then
		self:卸下灵饰(编号, 道具格子, 道具id)

		return
	end

	self:卸下装备(编号, 玩家数据[self.id].道具.数据[道具id], 玩家数据[self.id].道具.数据[道具id].分类, "不刷新")

	玩家数据[self.id].角色.数据.道具[临时格子] = 道具id
	self.数据[编号].装备[道具格子] = nil

	刷新道具行囊单格(self.id, "道具", 临时格子, 道具id)
	self:刷新信息(编号, 1)
	发送数据(玩家数据[self.id].连接id, 104, {
		编号 = 编号,
		装备 = self:取装备数据(编号)
	})
	发送数据(玩家数据[self.id].连接id, 100, {
		编号 = 编号,
		数据 = self:取指定数据(编号)
	})

	if 玩家数据[self.id].道具.数据[道具id].分类 == 3 or self.数据[编号].模型 == "影精灵" and 玩家数据[self.id].道具.数据[道具id].分类 == 4 and 玩家数据[self.id].道具.数据[道具id].子类 == 911 then
		if 玩家数据[self.id].道具.数据[道具id].分类 == 3 then
			self.数据[编号].武器数据 = {
				染色方案 = 0,
				名称 = "",
				等级 = 0,
				子类 = "",
				染色组 = {}
			}
		else
			self.数据[编号].副武器数据 = {
				染色方案 = 0,
				名称 = "",
				等级 = 0,
				子类 = "",
				染色组 = {}
			}
		end

		发送数据(玩家数据[self.id].连接id, 106, {
			编号 = 编号,
			数据 = self.数据[编号].武器数据,
			副武器数据 = self.数据[编号].副武器数据
		})
	end
end

function 助战系统:添加装备(编号, 内容)
	local 道具格子 = 内容.物品编号
	local 道具id = 玩家数据[self.id].角色.数据.道具[道具格子]

	if 道具id == nil or 道具id == 0 then
		if 道具id == 0 then
			玩家数据[self.id].角色.数据.道具[道具格子] = nil
			玩家数据[self.id].道具.数据[道具id] = nil
		end

		发送数据(玩家数据[self.id].连接id, 103, {
			编号 = 编号,
			装备 = self:取装备数据(编号),
			道具 = 玩家数据[self.id].道具:索要道具2(self.id),
			技能 = self:取技能数据(编号)
		})

		return
	end

	if 玩家数据[self.id].道具.数据[道具id] ~= nil and 玩家数据[self.id].道具.数据[道具id].灵饰 ~= nil and 玩家数据[self.id].道具.数据[道具id].灵饰 then
		self:佩戴灵饰(编号, 道具格子, 道具id)

		return
	end

	if 玩家数据[self.id].道具.数据[道具id] ~= nil and 玩家数据[self.id].道具.数据[道具id].分类 == 14 then
		self:佩戴灵饰(编号, 道具格子, 道具id)

		return
	end

	local 装备条件 = nil

	if 玩家数据[self.id].道具.数据[道具id] == nil or 玩家数据[self.id].道具.数据[道具id].分类 == nil then
		装备条件 = false
	else
		装备条件 = 判断可装备(玩家数据[self.id].道具.数据[道具id], 玩家数据[self.id].道具.数据[道具id].分类, "主角", self.id, self.数据[编号])
	end

	if 装备条件 ~= true then
		return 0
	elseif self.数据[编号].装备[玩家数据[self.id].道具.数据[道具id].分类] ~= nil then
		local 道具id1 = self.数据[编号].装备[玩家数据[self.id].道具.数据[道具id].分类]

		self:卸下装备(编号, 玩家数据[self.id].道具.数据[道具id1], 玩家数据[self.id].道具.数据[道具id1].分类, "不刷新")

		self.数据[编号].装备[玩家数据[self.id].道具.数据[道具id].分类] = 道具id

		self:穿戴装备(编号, 玩家数据[self.id].道具.数据[道具id], 玩家数据[self.id].道具.数据[道具id].分类)

		玩家数据[self.id].角色.数据.道具[道具格子] = 道具id1

		刷新道具行囊单格(self.id, "道具", 道具格子, 道具id1)
	else
		self.数据[编号].装备[玩家数据[self.id].道具.数据[道具id].分类] = 道具id

		self:穿戴装备(编号, 玩家数据[self.id].道具.数据[道具id], 玩家数据[self.id].道具.数据[道具id].分类)

		玩家数据[self.id].角色.数据.道具[道具格子] = nil

		刷新道具行囊单格(self.id, "道具", 道具格子, nil)
	end

	发送数据(玩家数据[self.id].连接id, 104, {
		编号 = 编号,
		装备 = self:取装备数据(编号)
	})
	发送数据(玩家数据[self.id].连接id, 100, {
		编号 = 编号,
		数据 = self:取指定数据(编号)
	})

	if 玩家数据[self.id].道具.数据[道具id].分类 == 3 or self.数据[编号].模型 == "影精灵" and 玩家数据[self.id].道具.数据[道具id].分类 == 4 and 玩家数据[self.id].道具.数据[道具id].子类 == 911 then
		if 玩家数据[self.id].道具.数据[道具id].分类 == 3 then
			self.数据[编号].武器数据.子类 = 玩家数据[self.id].道具.数据[道具id].子类
			self.数据[编号].武器数据.名称 = 玩家数据[self.id].道具.数据[道具id].名称
			self.数据[编号].武器数据.等级 = 玩家数据[self.id].道具.数据[道具id].级别限制
			self.数据[编号].武器数据.光武拓印 = 玩家数据[self.id].道具.数据[道具id].光武拓印

			if 玩家数据[self.id].道具.数据[道具id].染色组 ~= nil then
				self.数据[编号].武器数据.染色组 = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[道具id].染色组))
				self.数据[编号].武器数据.染色方案 = 玩家数据[self.id].道具.数据[道具id].染色方案
			else
				self.数据[编号].武器数据.染色组 = nil
				self.数据[编号].武器数据.染色方案 = nil
			end
		else
			if self.数据[编号].副武器数据 == nil then
				self.数据[编号].副武器数据 = {
					染色方案 = 0,
					名称 = "",
					等级 = 50,
					子类 = "",
					染色组 = {}
				}
			end

			self.数据[编号].副武器数据.子类 = 玩家数据[self.id].道具.数据[道具id].子类
			self.数据[编号].副武器数据.名称 = 玩家数据[self.id].道具.数据[道具id].名称
			self.数据[编号].副武器数据.等级 = 玩家数据[self.id].道具.数据[道具id].级别限制
			self.数据[编号].副武器数据.光武拓印 = 玩家数据[self.id].道具.数据[道具id].光武拓印

			if 玩家数据[self.id].道具.数据[道具id].染色组 ~= nil then
				self.数据[编号].副武器数据.染色组 = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[道具id].染色组))
				self.数据[编号].副武器数据.染色方案 = 玩家数据[self.id].道具.数据[道具id].染色方案
			else
				self.数据[编号].副武器数据.染色组 = nil
				self.数据[编号].副武器数据.染色方案 = nil
			end
		end

		发送数据(玩家数据[self.id].连接id, 106, {
			编号 = 编号,
			数据 = self.数据[编号].武器数据,
			副武器数据 = self.数据[编号].副武器数据
		})
	end
end

function 助战系统:佩戴灵饰(编号, 道具格子, 道具id)
	local 物品 = 取物品数据(玩家数据[self.id].道具.数据[道具id].名称)
	local 级别 = 玩家数据[self.id].道具.数据[道具id].级别限制
	local i1 = 玩家数据[self.id].道具.数据[道具id]
	local 可穿戴 = false
	local 装备条件 = 判断可装备(玩家数据[self.id].道具.数据[道具id], 玩家数据[self.id].道具.数据[道具id].分类, "主角", self.id, self.数据[编号])

	if 装备条件 ~= true then
		return
	end

	if self.数据[编号].灵饰[玩家数据[self.id].道具.数据[道具id].子类] == nil then
		self.数据[编号].灵饰[玩家数据[self.id].道具.数据[道具id].子类] = 道具id

		self:灵饰佩戴(编号, 玩家数据[self.id].道具.数据[道具id])

		玩家数据[self.id].角色.数据.道具[道具格子] = nil
	else
		local 道具id1 = self.数据[编号].灵饰[玩家数据[self.id].道具.数据[道具id].子类]

		self:灵饰卸下(编号, 玩家数据[self.id].道具.数据[道具id1])

		self.数据[编号].灵饰[玩家数据[self.id].道具.数据[道具id].子类] = 道具id

		self:灵饰佩戴(编号, 玩家数据[self.id].道具.数据[道具id])

		玩家数据[self.id].角色.数据.道具[道具格子] = 道具id1
	end

	刷新道具行囊单格(self.id, "道具", 道具格子, 玩家数据[self.id].角色.数据.道具[道具格子])

	发送数据(玩家数据[self.id].连接id, 104.3, 玩家数据[self.id].道具:索要道具2(self.id))
	发送数据(玩家数据[self.id].连接id, 104.4, {
		编号 = 编号,
		灵饰 = self:取灵饰数据(编号)
	})
	发送数据(玩家数据[self.id].连接id, 100, {
		编号 = 编号,
		数据 = self:取指定数据(编号)
	})
end

function 助战系统:佩戴锦衣(编号, 内容)
	local 道具格子 = 内容.物品编号
	local 道具id = 玩家数据[self.id].角色.数据.道具[道具格子]
	local 物品 = 取物品数据(玩家数据[self.id].道具.数据[道具id].名称)
	local 级别 = 玩家数据[self.id].道具.数据[道具id].级别限制

	if 玩家数据[self.id].道具.数据[道具id].分类 == 15 and self.数据[编号].模型 == "影精灵" then
		常规提示(self.id, "#Y该助战角色无法装备锦衣")

		return
	end

	if self.数据[编号].锦衣[玩家数据[self.id].道具.数据[道具id].子类] == nil then
		if 玩家数据[self.id].道具.数据[道具id].分类 == 18 then
			self:灵饰佩戴(编号, 玩家数据[self.id].道具.数据[道具id])
		end

		self.数据[编号].锦衣[玩家数据[self.id].道具.数据[道具id].子类] = 道具id
		玩家数据[self.id].角色.数据.道具[道具格子] = nil
	else
		local 道具id1 = self.数据[编号].锦衣[玩家数据[self.id].道具.数据[道具id].子类]

		if 玩家数据[self.id].道具.数据[道具id].分类 == 18 and 玩家数据[self.id].道具.数据[道具id].名称 == "神·魂骨" then
			self:灵饰卸下(编号, 玩家数据[self.id].道具.数据[道具id1], "不刷新")
		end

		self.数据[编号].锦衣[玩家数据[self.id].道具.数据[道具id].子类] = 道具id

		if 玩家数据[self.id].道具.数据[道具id].分类 == 18 then
			self:灵饰佩戴(编号, 玩家数据[self.id].道具.数据[道具id])
		end

		玩家数据[self.id].角色.数据.道具[道具格子] = 道具id1
	end

	刷新道具行囊单格(self.id, "道具", 道具格子, 玩家数据[self.id].角色.数据.道具[道具格子])
	self:刷新信息(编号, 1)

	发送数据(玩家数据[self.id].连接id, 104.3, 玩家数据[self.id].道具:索要道具2(self.id))
	系统处理类:刷新助战灵饰(self.id, 编号)
	self:刷新锦衣数据(编号)
	发送数据(玩家数据[self.id].连接id, 104.1, self:取锦衣数据(id, self.id, 编号))
	发送数据(玩家数据[self.id].连接id, 100, {
		编号 = 编号,
		数据 = self:取指定数据(编号)
	})
	发送数据(玩家数据[self.id].连接id, 106, {
		编号 = 编号,
		数据 = self.数据[编号].武器数据,
		锦衣 = self.数据[编号].锦衣名称,
		副武器数据 = self.数据[编号].副武器数据
	})
end

function 助战系统:卸下锦衣(编号, 内容)
	local 临时格子 = 玩家数据[self.id].角色:取道具格子1("道具")

	if 临时格子 == 0 then
		常规提示(self.id, "您的道具栏物品已经满啦")

		return 0
	end

	local 道具格子 = 内容.物品编号
	local 道具id = self.数据[编号].锦衣[道具格子]

	if 玩家数据[self.id].道具.数据[道具id].分类 == 18 and 玩家数据[self.id].道具.数据[道具id].名称 == "神·魂骨" then
		self:灵饰卸下(编号, 玩家数据[self.id].道具.数据[self.数据[编号].锦衣[道具格子]], "不刷新")
	end

	玩家数据[self.id].角色.数据.道具[临时格子] = self.数据[编号].锦衣[道具格子]
	self.数据[编号].锦衣[道具格子] = nil

	刷新道具行囊单格(self.id, "道具", 临时格子, 玩家数据[self.id].角色.数据.道具[临时格子])
	self:刷新信息(编号, 1)

	发送数据(玩家数据[self.id].连接id, 104.3, 玩家数据[self.id].道具:索要道具2(self.id))
	系统处理类:刷新助战灵饰(self.id, 编号)
	self:刷新锦衣数据(编号)
	发送数据(玩家数据[self.id].连接id, 104.1, self:取锦衣数据(id, self.id, 编号))
	发送数据(玩家数据[self.id].连接id, 100, {
		编号 = 编号,
		数据 = self:取指定数据(编号)
	})
	发送数据(玩家数据[self.id].连接id, 106, {
		编号 = 编号,
		数据 = self.数据[编号].武器数据,
		锦衣 = self.数据[编号].锦衣名称,
		副武器数据 = self.数据[编号].副武器数据
	})
end

function 助战系统:灵饰佩戴(编号, 道具)
	角色佩戴灵饰(self.id, self.数据[编号], 道具)
	self:刷新信息(编号, 1)
end

function 助战系统:灵饰卸下(编号, 道具, 不刷新)
	if 角色卸下灵饰(self.id, self.数据[编号], 道具) ~= false and 不刷新 == nil then
		self:刷新信息(编号, 1)
	end
end

function 助战系统:卸下灵饰(编号, 道具格子, 道具id)
	local 临时格子 = 玩家数据[self.id].角色:取道具格子1("道具")

	if 临时格子 == 0 then
		常规提示(self.id, "您的道具栏物品已经满啦")

		return 0
	end

	self:灵饰卸下(编号, 玩家数据[self.id].道具.数据[self.数据[编号].灵饰[道具格子]], "不刷新")

	玩家数据[self.id].角色.数据.道具[临时格子] = self.数据[编号].灵饰[道具格子]

	刷新道具行囊单格(self.id, "道具", 临时格子, self.数据[编号].灵饰[道具格子])

	self.数据[编号].灵饰[道具格子] = nil

	self:刷新信息(编号, 1)
	发送数据(玩家数据[self.id].连接id, 104.4, {
		编号 = 编号,
		灵饰 = self:取灵饰数据(编号)
	})
	发送数据(玩家数据[self.id].连接id, 100, {
		编号 = 编号,
		数据 = self:取指定数据(编号)
	})
end

function 助战系统:卸下装备(编号, 装备, 分类, 不刷新)
	分类 = 装备.分类 + 0

	角色卸下装备(self.id, self.数据[编号], 装备, 分类)

	if 分类 < 7 and 装备.特技 ~= nil then
		self.数据[编号].特殊技能[分类] = nil
	end

	if 不刷新 == nil then
		self:刷新信息(编号, 1)
	end
end

function 助战系统:穿戴装备(编号, 装备, 分类)
	角色穿戴装备(self.id, self.数据[编号], 装备, 分类)

	if 分类 < 7 and 装备.特技 ~= nil then
		self.数据[编号].特殊技能[分类] = jnzb()

		self.数据[编号].特殊技能[分类]:置对象(装备.特技)
	end

	self:刷新信息(编号, 1)
end

function 助战系统:遗弃助战(编号)
	if self:检测装备(编号) then
		常规提示(self.id, "#Y/请先卸下该助战身上的装备以及灵饰!")

		return
	elseif self:检测单独参战(编号) == false then
		常规提示(self.id, "#Y/请取消助战宠物、坐骑并将该助战设置为非参战状态!!")

		return
	else
		local 遗弃认证码 = self.数据[编号].认证码 .. ""

		if 玩家数据[self.id].角色.数据.助战好友度 ~= nil then
			玩家数据[self.id].角色.数据.助战好友度[遗弃认证码] = nil
		end

		for i = 1, #self.数据 do
			if self.数据[i].助战好友度 ~= nil then
				self.数据[i].助战好友度[遗弃认证码] = nil
			end
		end

		table.remove(self.数据, 编号)

		local 队伍id = 玩家数据[self.id].队伍

		if 队伍id ~= nil and 队伍数据[队伍id] ~= nil then
			for n = 1, #队伍数据[队伍id].成员数据 do
				if n >= 2 and 队伍数据[队伍id].成员数据[n] == 队伍数据[队伍id].成员数据[1] then
					local 编号1 = 队伍处理类:取助战编号(队伍id, n)

					if 编号 < 编号1 then
						for i = 1, #队伍数据[队伍id].助战 do
							if 队伍数据[队伍id].助战[i].位置 == n then
								队伍数据[队伍id].助战[i].编号 = 编号1 - 1

								break
							end
						end

						for i = 1, #玩家数据[self.id].角色.数据.助战 do
							if 玩家数据[self.id].角色.数据.助战[i] == 编号1 then
								玩家数据[self.id].角色.数据.助战[i] = 编号1 - 1

								break
							end
						end
					end
				end
			end
		end

		local 坐骑数据 = 玩家数据[self.id].角色.数据.坐骑列表

		for i = 1, #坐骑数据 do
			if 坐骑数据[i].助战参战 ~= nil and 编号 < 坐骑数据[i].助战参战 then
				坐骑数据[i].助战参战 = 坐骑数据[i].助战参战 - 1
			end
		end

		发送数据(玩家数据[self.id].连接id, 102, self:取数据())
		常规提示(self.id, "#Y/万水千山总是情,离开了我你行不行!")
	end
end

function 助战系统:检测单独参战(编号)
	if self.数据[编号] ~= nil then
		if self.数据[编号].参战 == true or self.数据[编号].宠物认证码 ~= nil or self.数据[编号].坐骑认证码 ~= nil then
			return false
		end
	else
		return false
	end

	return true
end

function 助战系统:检测参战()
	for t = 1, #self.数据 do
		if self.数据[t].参战 == true or self.数据[t].宠物认证码 ~= nil then
			return false
		end
	end

	return true
end

function 助战系统:取装备数据(编号)
	local 返回数据 = {}

	for n, v in pairs(self.数据[编号].装备) do
		返回数据[n] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].装备[n]]))
	end

	return 返回数据
end

function 助战系统:取灵饰数据(编号)
	local 返回数据 = {}

	for n, v in pairs(self.数据[编号].灵饰) do
		返回数据[n] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].灵饰[n]]))
	end

	return 返回数据
end

function 助战系统:检测装备(编号)
	for i = 1, 6 do
		if self.数据[编号].装备[i] ~= nil then
			return true
		end
	end

	for i = 1, 4 do
		if self.数据[编号].灵饰[i] ~= nil then
			return true
		end
	end

	return false
end

function 助战系统:加点处理(编号, 加点内容)
	local 总点数 = 0

	for i, v in pairs(加点内容) do
		总点数 = 总点数 + v
	end

	if 总点数 <= 0 then
		return
	elseif self.数据[编号].潜力 < 总点数 then
		return
	else
		self.数据[编号].体质 = self.数据[编号].体质 + 加点内容.体质
		self.数据[编号].魔力 = self.数据[编号].魔力 + 加点内容.魔力
		self.数据[编号].力量 = self.数据[编号].力量 + 加点内容.力量
		self.数据[编号].耐力 = self.数据[编号].耐力 + 加点内容.耐力
		self.数据[编号].敏捷 = self.数据[编号].敏捷 + 加点内容.敏捷
		self.数据[编号].潜力 = self.数据[编号].潜力 - 总点数

		self:刷新信息(编号, "1")
	end
end

function 助战系统:扣除经验(编号, 数额)
	if 数额 <= self.数据[编号].当前经验 then
		self.数据[编号].当前经验 = self.数据[编号].当前经验 - 数额

		发送数据(玩家数据[self.id].连接id, 27, {
			频道 = "xt",
			文本 = "#Y/你的助战#R[" .. 编号 .. "]" .. self.数据[编号].名称 .. "#Y扣除了#R" .. 数字转简(qz(数额)) .. "#Y点经验"
		})

		return true
	end

	return false
end

function 助战系统:添加经验(编号, 数额, 倍率, 通灵宝玉生效)
	local 基础倍率 = 服务端参数.经验获得率
	local 倍率 = 倍率 or 1
	local 通灵宝玉加成 = 0

	if 通灵宝玉生效 == true and self.数据[编号].通灵宝玉 ~= nil and self.数据[编号].通灵宝玉 > 0 then
		通灵宝玉加成 = qz1(self.数据[编号].通灵宝玉 * 数额 * 基础倍率 * 倍率)
		基础倍率 = 基础倍率 * (1 + self.数据[编号].通灵宝玉)
	end

	数额 = 数额 * 基础倍率 * 倍率
	self.数据[编号].当前经验 = self.数据[编号].当前经验 + qz(数额)

	if qz(数额) > 0 then
		if 通灵宝玉加成 > 0 then
			发送数据(玩家数据[self.id].连接id, 27, {
				频道 = "xt",
				文本 = "#Y/你的助战#R[" .. 编号 .. "]" .. self.数据[编号].名称 .. "#Y获得了#R" .. 数字转简(qz(数额)) .. "#Y点经验(其中通灵宝玉额外加成#R" .. 数字转简(通灵宝玉加成) .. "#Y点)"
			})
		else
			发送数据(玩家数据[self.id].连接id, 27, {
				频道 = "xt",
				文本 = "#Y/你的助战#R[" .. 编号 .. "]" .. self.数据[编号].名称 .. "#Y获得了#R" .. 数字转简(qz(数额)) .. "#Y点经验"
			})
		end
	end

	local 升级 = false

	while self.数据[编号].自动升级 == true and self.数据[编号].最大经验 <= self.数据[编号].当前经验 do
		if 玩家数据[self.id].角色.数据.等级 <= self.数据[编号].等级 then
			break
		end

		升级 = true

		self:升级(编号)
	end

	if 升级 then
		发送数据(玩家数据[self.id].连接id, 27, {
			频道 = "xt",
			文本 = "#Y/你的助战#R[" .. 编号 .. "]" .. self.数据[编号].名称 .. "#Y等级提升到了#R/" .. self.数据[编号].等级 .. "#Y/级"
		})
	end
end

function 助战系统:保存加点方案(内容)
	local 编号 = 内容.编号
	local 方案 = 内容.方案

	if self.数据[编号] ~= nil and not 判断是否为空表(方案) then
		self.数据[编号].加点方案 = {}
		local sx3 = {
			体质 = 1,
			力量 = 3,
			敏捷 = 5,
			耐力 = 4,
			魔力 = 2
		}

		for k, v in pairs(方案) do
			for i = 1, v do
				self.数据[编号].加点方案[#self.数据[编号].加点方案 + 1] = sx3[k]
			end
		end

		self.数据[编号].加点方案.当前 = 1
		self.数据[编号].加点文本 = 内容.文本
	end
end

function 助战系统:连续升级(编号, 提示)
	while self.数据[编号].自动升级 == true and self.数据[编号].最大经验 <= self.数据[编号].当前经验 do
		if 玩家数据[self.id].角色.数据.等级 <= self.数据[编号].等级 then
			break
		end

		self:升级(编号, 提示)
	end
end

function 助战系统:升级(编号, 提示)
	self.数据[编号].等级 = self.数据[编号].等级 + 1
	self.数据[编号].体质 = self.数据[编号].体质 + 1
	self.数据[编号].魔力 = self.数据[编号].魔力 + 1
	self.数据[编号].力量 = self.数据[编号].力量 + 1
	self.数据[编号].耐力 = self.数据[编号].耐力 + 1
	self.数据[编号].敏捷 = self.数据[编号].敏捷 + 1
	self.数据[编号].潜力 = self.数据[编号].潜力 + 服务端参数.助战升级潜能点
	self.数据[编号].当前经验 = self.数据[编号].当前经验 - self.数据[编号].最大经验
	self.数据[编号].装备属性.可换乾元丹 = 取可换乾元丹(self.数据[编号].等级)

	if self.数据[编号].自动加点 == true and self.数据[编号].加点方案 ~= nil and not 判断是否为空表(self.数据[编号].加点方案) and self.数据[编号].潜力 > 0 then
		local sx = {
			"体质",
			"魔力",
			"力量",
			"耐力",
			"敏捷"
		}
		local aa = 0

		for i = 1, self.数据[编号].潜力 do
			aa = self.数据[编号].加点方案[self.数据[编号].加点方案.当前]
			self.数据[编号][sx[aa]] = self.数据[编号][sx[aa]] + 1
			self.数据[编号].加点方案.当前 = self.数据[编号].加点方案.当前 + 1

			if self.数据[编号].加点方案.当前 > 5 then
				self.数据[编号].加点方案.当前 = 1
			end
		end

		self.数据[编号].潜力 = 0
	end

	self:刷新信息(编号, "1")

	if 提示 ~= nil then
		常规提示(self.id, "#Y/你的助战[#P" .. self.数据[编号].名称 .. "#Y]等级已提升至#R" .. self.数据[编号].等级 .. "#Y级")
	end
end

function 助战系统:新增助战(id, 模型)
	for n = 1, #self.数据 do
		if 玩家数据[self.id].角色.数据.助战携带数量 <= #self.数据 then
			常规提示(self.id, "#Y/最多携带" .. 玩家数据[self.id].角色.数据.助战携带数量 .. "个助战")

			return
		end
	end

	local ls = self:助战信息(模型)
	local cs = self:取初始属性(ls.种族)
	玩家数据[self.id].角色.数据.助战认证 = (玩家数据[self.id].角色.数据.助战认证 or 0) + 1
	self.数据[#self.数据 + 1] = {
		当前经验 = 500000,
		蚩尤元神 = 0,
		变身套 = 0,
		参战 = false,
		愤怒 = 0,
		最大经验 = 0,
		当前称谓 = "梦幻新秀",
		助战等级 = "伙伴",
		门派 = "无门派",
		潜力 = 250,
		等级 = 50,
		名称 = ls.模型,
		性别 = ls.性别,
		模型 = ls.模型,
		种族 = ls.种族,
		编号 = #self.数据,
		称谓 = {
			"梦幻新秀"
		},
		认证码 = "z" .. self.id .. "z" .. 玩家数据[self.id].角色.数据.助战认证,
		体质 = cs[1],
		魔力 = cs[2],
		力量 = cs[3],
		耐力 = cs[4],
		敏捷 = cs[5],
		装备 = {},
		灵饰 = {},
		修炼 = {
			攻击修炼 = 0,
			防御修炼 = 0,
			法术修炼 = 0,
			抗法修炼 = 0
		},
		当前修炼 = {
			当前 = "攻击修炼",
			攻击修炼 = {
				0,
				0,
				0
			},
			法术修炼 = {
				0,
				0,
				0
			},
			防御修炼 = {
				0,
				0,
				0
			},
			抗法修炼 = {
				0,
				0,
				0
			}
		},
		技能 = {},
		特殊技能 = {},
		染色方案 = ls.染色方案,
		染色组 = {
			0,
			0,
			0
		},
		奇经八脉 = {},
		锦衣 = {},
		法宝 = {},
		法宝佩戴 = {},
		辅助技能 = {},
		技能属性 = {
			魔力 = 0,
			体质 = 0,
			力量 = 0,
			气血 = 0,
			敏捷 = 0,
			耐力 = 0,
			魔法 = 0,
			躲避 = 0,
			灵力 = 0,
			伤害 = 0,
			速度 = 0,
			命中 = 0,
			防御 = 0
		},
		强化技能 = {
			{
				等级 = 50,
				名称 = "强化气血上限"
			},
			{
				等级 = 50,
				名称 = "强化魔法上限"
			},
			{
				等级 = 50,
				名称 = "强化伤害"
			},
			{
				等级 = 50,
				名称 = "强化法伤"
			},
			{
				等级 = 50,
				名称 = "强化物理防御"
			},
			{
				等级 = 0,
				名称 = "强化法防"
			},
			{
				等级 = 50,
				名称 = "强化固定伤害"
			},
			{
				等级 = 50,
				名称 = "强化封印命中等级"
			},
			{
				等级 = 50,
				名称 = "强化抵抗封印等级"
			},
			{
				等级 = 50,
				名称 = "强化治疗能力"
			}
		},
		装备属性 = {
			伤害 = 0,
			体质 = 0,
			格挡值 = 0,
			乾元丹 = 0,
			法术伤害结果 = 0,
			物理暴击伤害 = 0,
			气血 = 0,
			气血回复效果 = 0,
			附加乾元丹 = 0,
			剩余乾元丹 = 0,
			力量 = 0,
			可换乾元丹 = 0,
			穿刺等级 = 0,
			魔力 = 0,
			敏捷 = 0,
			耐力 = 0,
			法防 = 0,
			躲避 = 0,
			法伤 = 0,
			物理暴击等级 = 0,
			命中 = 0,
			抗法术暴击等级 = 0,
			固定伤害 = 0,
			抵抗封印等级 = 0,
			魔法 = 0,
			灵力 = 0,
			速度 = 0,
			法术暴击伤害 = 0,
			防御 = 0,
			抗物理暴击等级 = 0,
			月饼 = 0,
			法术暴击等级 = 0,
			封印命中等级 = 0,
			治疗能力 = 0,
			狂暴等级 = 0
		},
		武器数据 = {
			染色方案 = 0,
			名称 = "",
			等级 = 0,
			子类 = "",
			染色组 = {}
		},
		副武器数据 = {
			染色方案 = 0,
			名称 = "",
			等级 = 0,
			子类 = "",
			染色组 = {}
		}
	}

	self:更新辅助技能(#self.数据)
	self:刷新修炼等级(#self.数据)

	for n = 1, #灵饰战斗属性 do
		self.数据[#self.数据][灵饰战斗属性[n]] = 0
	end

	self:刷新信息(#self.数据, 1)
end

助战修炼列表 = {
	"攻击修炼",
	"法术修炼",
	"防御修炼",
	"抗法修炼"
}
助战修炼列表1 = {
	攻击修炼 = 1,
	防御修炼 = 1,
	法术修炼 = 1,
	抗法修炼 = 1
}

function 助战系统:刷新修炼等级(编号)
	for i = 1, #助战修炼列表 do
		self.数据[编号].当前修炼[助战修炼列表[i]][3] = 玩家数据[self.id].角色.数据.修炼[助战修炼列表[i]][3] or 0
	end
end

function 助战系统:添加修炼经验(编号, 数额, 修炼类型)
	if self.数据[编号].当前修炼.当前 == nil or 助战修炼列表1[self.数据[编号].当前修炼.当前] == nil then
		self.数据[编号].当前修炼.当前 = "攻击修炼"
	end

	local dq = 修炼类型 or self.数据[编号].当前修炼.当前

	if self.数据[编号].当前修炼[dq][3] <= self.数据[编号].当前修炼[dq][1] then
		常规提示(self.id, format("#P%s#Y的#S%s#Y已达到上限！", self.数据[编号].名称, dq))

		return false
	end

	self.数据[编号].当前修炼[dq][2] = self.数据[编号].当前修炼[dq][2] + 数额

	常规提示(self.id, format("#P%s#W的#S%s经验#W增加了#R%s#W点", self.数据[编号].名称, dq, 数额))

	while 计算修炼等级经验(self.数据[编号].当前修炼[dq][1], self.数据[编号].当前修炼[dq][3]) <= self.数据[编号].当前修炼[dq][2] and self.数据[编号].当前修炼[dq][1] < self.数据[编号].当前修炼[dq][3] do
		self.数据[编号].当前修炼[dq][2] = self.数据[编号].当前修炼[dq][2] - 计算修炼等级经验(self.数据[编号].当前修炼[dq][1], self.数据[编号].当前修炼[dq][3])
		self.数据[编号].当前修炼[dq][1] = self.数据[编号].当前修炼[dq][1] + 1
		self.数据[编号].修炼[dq] = self.数据[编号].当前修炼[dq][1] + 0

		常规提示(self.id, format("#P%s#W的#S%s#W等级提升至#R%s#W级", self.数据[编号].名称, dq, self.数据[编号].当前修炼[dq][1]))
	end

	发送数据(玩家数据[self.id].连接id, 7002, {
		编号 = 编号,
		助战修炼 = self.数据[编号].当前修炼
	})

	return true
end

function 助战系统:索要法宝(连接id, id, 助战编号)
	self.发送数据 = {
		法宝 = {}
	}

	for n = 1, 4 do
		if self.数据[助战编号].法宝佩戴[n] ~= nil then
			self.发送数据.法宝[n] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[助战编号].法宝佩戴[n]]))
		end
	end

	发送数据(玩家数据[self.id].连接id, 107.2, {
		法宝 = self.发送数据.法宝,
		编号 = 助战编号
	})
end

function 助战系统:取法宝数据(连接id, id, 助战编号)
	self.发送数据 = {
		法宝 = {}
	}

	for n = 1, 4 do
		if self.数据[助战编号].法宝佩戴[n] ~= nil then
			self.发送数据.法宝[n] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[助战编号].法宝佩戴[n]]))
		end
	end

	return {
		编号 = 助战编号,
		法宝 = self.发送数据.法宝
	}
end

function 助战系统:取锦衣数据(连接id, id, 助战编号)
	local id = self.id
	local 编号 = 助战编号
	锦衣数据 = {}

	if self.数据[编号].锦衣[1] ~= nil then
		锦衣数据[1] = table.loadstring(table.tostring(玩家数据[id].道具.数据[self.数据[编号].锦衣[1]]))
	end

	if self.数据[编号].锦衣[2] ~= nil then
		锦衣数据[2] = table.loadstring(table.tostring(玩家数据[id].道具.数据[self.数据[编号].锦衣[2]]))
	end

	if self.数据[编号].锦衣[3] ~= nil then
		锦衣数据[3] = table.loadstring(table.tostring(玩家数据[id].道具.数据[self.数据[编号].锦衣[3]]))
	end

	if self.数据[编号].锦衣[4] ~= nil then
		锦衣数据[4] = table.loadstring(table.tostring(玩家数据[id].道具.数据[self.数据[编号].锦衣[4]]))
	end

	return {
		编号 = 助战编号,
		锦衣 = 锦衣数据
	}
end

function 助战系统:卸下法宝(连接id, id, 编号, 助战编号)
	角色卸下法宝(连接id, id, self.数据[助战编号], 编号, 助战编号)
end

function 助战系统:佩戴法宝(连接id, id, 类型, 编号, 助战编号)
	角色佩戴法宝(连接id, id, self.数据[助战编号], 编号, 助战编号)
end

function 助战系统:取强化技能等级(编号, 名称)
	return 取角色强化技能等级(self.数据[编号], 名称)
end

function 助战系统:刷新信息(编号, 是否)
	角色刷新信息(self.id, self.数据[编号])

	if 是否 ~= nil then
		self.数据[编号].气血 = self.数据[编号].最大气血
		self.数据[编号].魔法 = self.数据[编号].最大魔法
	end

	if self.数据[编号].最大气血 < self.数据[编号].气血 then
		self.数据[编号].气血 = self.数据[编号].最大气血
	end

	if self.数据[编号].最大魔法 < self.数据[编号].魔法 then
		self.数据[编号].魔法 = self.数据[编号].最大魔法
	end

	if self.数据[编号].愤怒 > 150 then
		self.数据[编号].愤怒 = 150
	end

	if self.数据[编号].等级 <= 174 then
		self.数据[编号].最大经验 = 统一取经验(1, self.数据[编号].等级)
	end

	self.数据[编号].当前修炼.攻击修炼[3] = 玩家数据[self.id].角色.数据.修炼.攻击修炼[3]
	self.数据[编号].当前修炼.防御修炼[3] = 玩家数据[self.id].角色.数据.修炼.防御修炼[3]
	self.数据[编号].当前修炼.法术修炼[3] = 玩家数据[self.id].角色.数据.修炼.法术修炼[3]
	self.数据[编号].当前修炼.抗法修炼[3] = 玩家数据[self.id].角色.数据.修炼.抗法修炼[3]
end

function 助战系统:取经验(id, lv)
	local exp = {}

	if id == 1 then
		exp = {
			40,
			110,
			237,
			450,
			779,
			1252,
			1898,
			2745,
			3822,
			5159,
			6784,
			8726,
			11013,
			13674,
			16739,
			20236,
			24194,
			28641,
			33606,
			39119,
			45208,
			51902,
			55229,
			67218,
			75899,
			85300,
			95450,
			106377,
			118110,
			130679,
			144112,
			158438,
			173685,
			189882,
			207059,
			225244,
			244466,
			264753,
			286134,
			308639,
			332296,
			357134,
			383181,
			410466,
			439019,
			468868,
			500042,
			532569,
			566478,
			601799,
			638560,
			676790,
			716517,
			757770,
			800579,
			844972,
			890978,
			938625,
			987942,
			1038959,
			1091704,
			1146206,
			1202493,
			1260594,
			1320539,
			1382356,
			1446074,
			1511721,
			1579326,
			1648919,
			1720528,
			1794182,
			1869909,
			1947738,
			2027699,
			2109820,
			2194130,
			2280657,
			2369431,
			2460479,
			2553832,
			2649518,
			2747565,
			2848003,
			2950859,
			3056164,
			3163946,
			3274233,
			3387055,
			3502439,
			3620416,
			3741014,
			3864261,
			3990187,
			4118819,
			4250188,
			4384322,
			4521249,
			4660999,
			4803599,
			4998571,
			5199419,
			5406260,
			5619213,
			5838397,
			6063933,
			6295941,
			6534544,
			6779867,
			7032035,
			7291172,
			7557407,
			7830869,
			8111686,
			8399990,
			8695912,
			8999586,
			9311145,
			9630726,
			9958463,
			10294496,
			10638964,
			10992005,
			11353761,
			11724374,
			12103988,
			12492748,
			12890799,
			13298287,
			13715362,
			14142172,
			14578867,
			15025600,
			15482522,
			15949788,
			16427552,
			16915970,
			17415202,
			17925402,
			18446732,
			18979354,
			19523428,
			20079116,
			20646584,
			21225998,
			43635044,
			44842648,
			46075148,
			47332886,
			48616200,
			74888148,
			76891401,
			78934581,
			81018219,
			83142835,
			85308969,
			87977421,
			89767944,
			92061870,
			146148764,
			150094780,
			154147340,
			158309318,
			162583669,
			166973428,
			171481711,
			176111717,
			180866734,
			185780135,
			240602904,
			533679362,
			819407100,
			1118169947,
			1430306664,
			1756161225,
			2096082853
		}
	else
		exp = {
			50,
			200,
			450,
			800,
			1250,
			1800,
			2450,
			3250,
			4050,
			5000,
			6050,
			7200,
			8450,
			9800,
			11250,
			12800,
			14450,
			16200,
			18050,
			20000,
			22050,
			24200,
			26450,
			28800,
			31250,
			33800,
			36450,
			39200,
			42050,
			45000,
			48050,
			51200,
			54450,
			57800,
			61250,
			64800,
			68450,
			72200,
			76050,
			80000,
			84050,
			88200,
			92450,
			96800,
			101250,
			105800,
			110450,
			115200,
			120050,
			125000,
			130050,
			135200,
			140450,
			145800,
			151250,
			156800,
			162450,
			168200,
			174050,
			180000,
			186050,
			192200,
			198450,
			204800,
			211250,
			217800,
			224450,
			231200,
			238050,
			245000,
			252050,
			259200,
			266450,
			273800,
			281250,
			288800,
			296450,
			304200,
			312050,
			320000,
			328050,
			336200,
			344450,
			352800,
			361250,
			369800,
			378450,
			387200,
			396050,
			405000,
			414050,
			423200,
			432450,
			441800,
			451250,
			460800,
			470450,
			480200,
			490050,
			500000,
			510050,
			520200,
			530450,
			540800,
			551250,
			561800,
			572450,
			583200,
			594050,
			605000,
			616050,
			627200,
			638450,
			649800,
			661250,
			672800,
			684450,
			696200,
			708050,
			720000,
			732050,
			744200,
			756450,
			768800,
			781250,
			793800,
			806450,
			819200,
			832050,
			845000,
			858050,
			871200,
			884450,
			897800,
			911250,
			924800,
			938450,
			952200,
			966050,
			980000,
			994050,
			1008200,
			1022450,
			1036800,
			1051250,
			1065800,
			1080450,
			1095200,
			1110050,
			1125000,
			1140050,
			1155200,
			1170450,
			1185800,
			1201250,
			1216800,
			1232450,
			1248200,
			1264050,
			1280000,
			1300000,
			1340000,
			1380000,
			1420000,
			1460000,
			1500000,
			1540000,
			1580000,
			1700000,
			1780000,
			1820000,
			1940000,
			2400000,
			2880000,
			3220000,
			4020000,
			4220000,
			4420000,
			4620000,
			5220000,
			5820000,
			6220000,
			7020000,
			8020000,
			9020000
		}
	end

	return exp[lv + 1]
end

function 助战系统:取初始属性(种族)
	local 属性 = {
		人 = {
			10,
			10,
			10,
			10,
			10
		},
		魔 = {
			10,
			10,
			10,
			10,
			10
		},
		仙 = {
			10,
			10,
			10,
			10,
			10
		}
	}

	return 属性[种族]
end

function 助战系统:助战信息(模型)
	local 门派列表 = {
		"大唐官府",
		"女儿村",
		"方寸山",
		"神木林",
		"化生寺",
		"盘丝洞",
		"阴曹地府",
		"魔王寨",
		"无底洞",
		"狮驼岭",
		"天宫",
		"普陀山",
		"龙宫",
		"凌波城",
		"五庄观",
		"九黎城",
		"花果山"
	}
	local 角色信息 = {
		飞燕女 = {
			染色方案 = 3,
			性别 = "女",
			模型 = "飞燕女",
			ID = 1,
			种族 = "人",
			门派 = 门派列表,
			武器 = {
				"双剑",
				"环圈"
			}
		},
		英女侠 = {
			染色方案 = 4,
			性别 = "女",
			模型 = "英女侠",
			ID = 2,
			种族 = "人",
			门派 = 门派列表,
			武器 = {
				"双剑",
				"鞭"
			}
		},
		巫蛮儿 = {
			染色方案 = 13,
			性别 = "女",
			模型 = "巫蛮儿",
			ID = 3,
			种族 = "人",
			门派 = 门派列表,
			武器 = {
				"宝珠",
				"法杖"
			}
		},
		逍遥生 = {
			染色方案 = 1,
			性别 = "男",
			模型 = "逍遥生",
			ID = 4,
			种族 = "人",
			门派 = 门派列表,
			武器 = {
				"扇",
				"剑"
			}
		},
		剑侠客 = {
			染色方案 = 2,
			性别 = "男",
			模型 = "剑侠客",
			ID = 5,
			种族 = "人",
			门派 = 门派列表,
			武器 = {
				"刀",
				"剑"
			}
		},
		狐美人 = {
			染色方案 = 7,
			性别 = "女",
			模型 = "狐美人",
			ID = 6,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"爪刺",
				"鞭"
			}
		},
		骨精灵 = {
			染色方案 = 8,
			性别 = "女",
			模型 = "骨精灵",
			ID = 7,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"魔棒",
				"爪刺"
			}
		},
		杀破狼 = {
			染色方案 = 15,
			性别 = "男",
			模型 = "杀破狼",
			ID = 8,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"宝珠",
				"弓弩"
			}
		},
		巨魔王 = {
			染色方案 = 5,
			性别 = "男",
			模型 = "巨魔王",
			ID = 9,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"刀",
				"斧钺"
			}
		},
		虎头怪 = {
			染色方案 = 6,
			性别 = "男",
			模型 = "虎头怪",
			ID = 10,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"斧钺",
				"锤子"
			}
		},
		舞天姬 = {
			染色方案 = 11,
			性别 = "女",
			模型 = "舞天姬",
			ID = 11,
			种族 = "仙",
			门派 = 门派列表,
			武器 = {
				"飘带",
				"环圈"
			}
		},
		玄彩娥 = {
			染色方案 = 12,
			性别 = "女",
			模型 = "玄彩娥",
			ID = 12,
			种族 = "仙",
			门派 = 门派列表,
			武器 = {
				"飘带",
				"魔棒"
			}
		},
		羽灵神 = {
			染色方案 = 17,
			性别 = "男",
			模型 = "羽灵神",
			ID = 13,
			种族 = "仙",
			门派 = 门派列表,
			武器 = {
				"法杖",
				"弓弩"
			}
		},
		神天兵 = {
			染色方案 = 9,
			性别 = "男",
			模型 = "神天兵",
			ID = 14,
			种族 = "仙",
			门派 = 门派列表,
			武器 = {
				"锤",
				"枪矛"
			}
		},
		龙太子 = {
			染色方案 = 10,
			性别 = "男",
			模型 = "龙太子",
			ID = 15,
			种族 = "仙",
			门派 = 门派列表,
			武器 = {
				"扇",
				"枪矛"
			}
		},
		桃夭夭 = {
			染色方案 = 18,
			性别 = "女",
			模型 = "桃夭夭",
			ID = 16,
			种族 = "仙",
			门派 = 门派列表,
			武器 = {
				"灯笼"
			}
		},
		偃无师 = {
			染色方案 = 14,
			性别 = "男",
			模型 = "偃无师",
			ID = 17,
			种族 = "人",
			门派 = 门派列表,
			武器 = {
				"剑",
				"巨剑"
			}
		},
		鬼潇潇 = {
			染色方案 = 16,
			性别 = "女",
			模型 = "鬼潇潇",
			ID = 18,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"爪刺",
				"伞"
			}
		},
		鬼潇潇 = {
			染色方案 = 16,
			性别 = "女",
			模型 = "鬼潇潇",
			ID = 18,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"爪刺",
				"伞"
			}
		},
		影精灵 = {
			染色方案 = 8,
			性别 = "女",
			模型 = "影精灵",
			ID = 19,
			种族 = "魔",
			门派 = 门派列表,
			武器 = {
				"爪刺",
				"魔棒"
			}
		}
	}

	return 角色信息[模型]
end

function 助战系统:取数据()
	for n = 1, #self.数据 do
		if self.数据[n].助战修炼经验 == nil then
			self.数据[n].助战修炼经验 = {
				防御经验 = 0,
				法术经验 = 0,
				抗法经验 = 0,
				攻击经验 = 0
			}
		end

		if self.数据[n].锦衣名称 == nil then
			self.数据[n].锦衣名称 = {}
		end

		self.数据[n].锦衣名称 = {}

		if self.数据[n].锦衣[1] ~= nil then
			self.数据[n].锦衣名称[1] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[n].锦衣[1]]))
		end

		if self.数据[n].锦衣[2] ~= nil then
			self.数据[n].锦衣名称[2] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[n].锦衣[2]]))
		end

		if self.数据[n].锦衣[3] ~= nil then
			self.数据[n].锦衣名称[3] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[n].锦衣[3]]))
		end

		if self.数据[n].锦衣[4] ~= nil then
			self.数据[n].锦衣名称[4] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[n].锦衣[4]]))
		end
	end

	for n = 1, #self.数据 do
		self.数据[n].法宝名称 = {}

		if self.数据[n].法宝佩戴[1] ~= nil then
			self.数据[n].法宝名称[1] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[n].法宝佩戴[1]]))
		end

		if self.数据[n].法宝佩戴[2] ~= nil then
			self.数据[n].法宝名称[2] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[n].法宝佩戴[2]]))
		end

		if self.数据[n].法宝佩戴[3] ~= nil then
			self.数据[n].法宝名称[3] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[n].法宝佩戴[3]]))
		end
	end

	return self.数据
end

function 助战系统:取指定数据(编号)
	return self.数据[编号]
end

function 助战系统:刷新锦衣数据(编号)
	if self.数据[编号].锦衣[1] ~= nil then
		self.数据[编号].锦衣名称[1] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[1]]))
	else
		self.数据[编号].锦衣名称[1] = nil
	end

	if self.数据[编号].锦衣[2] ~= nil then
		self.数据[编号].锦衣名称[2] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[2]]))
	else
		self.数据[编号].锦衣名称[2] = nil
	end

	if self.数据[编号].锦衣[3] ~= nil then
		self.数据[编号].锦衣名称[3] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[3]]))
	else
		self.数据[编号].锦衣名称[3] = nil
	end

	if self.数据[编号].锦衣[4] ~= nil then
		self.数据[编号].锦衣名称[4] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[4]]))
	else
		self.数据[编号].锦衣名称[4] = nil
	end
end

function 助战系统:取总数据(编号)
	local 存档数据 = {}

	if self.数据[编号].最大气血 < self.数据[编号].气血 then
		self.数据[编号].气血 = self.数据[编号].最大气血
	end

	for i, v in pairs(self.数据[编号]) do
		存档数据[i] = self.数据[编号][i]
	end

	存档数据.装备 = self:取装备数据(编号)
	存档数据.灵饰 = {}
	存档数据.锦衣 = {}
	存档数据.锦衣名称 = {}

	if self.数据[编号].锦衣[1] ~= nil then
		存档数据.锦衣名称[1] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[1]]))
	end

	if self.数据[编号].锦衣[2] ~= nil then
		存档数据.锦衣名称[2] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[2]]))
	end

	if self.数据[编号].锦衣[3] ~= nil then
		存档数据.锦衣名称[3] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[3]]))
	end

	if self.数据[编号].锦衣[4] ~= nil then
		存档数据.锦衣名称[4] = table.loadstring(table.tostring(玩家数据[self.id].道具.数据[self.数据[编号].锦衣[4]]))
	end

	return 存档数据
end

function 助战系统:更新(dt)
end

function 助战系统:显示()
end

return 助战系统
