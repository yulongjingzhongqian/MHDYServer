local 角色处理类 = class()
local jnzb = require("script/角色处理类/技能类")
local floor = math.floor
local ceil = math.ceil
local insert = table.insert
local remove = table.remove
local tp = nil
local 属性类型 = {
	"体质",
	"魔力",
	"力量",
	"耐力",
	"敏捷"
}
local 可入门派 = {
	仙 = {
		凌波城 = 1,
		花果山 = 1,
		龙宫 = 1,
		九黎城 = 1,
		天宫 = 1,
		女 = {
			普陀山 = 1
		},
		男 = {
			五庄观 = 1
		}
	},
	魔 = {
		魔王寨 = 1,
		无底洞 = 1,
		女魃墓 = 1,
		九黎城 = 1,
		阴曹地府 = 1,
		女 = {
			盘丝洞 = 1
		},
		男 = {
			狮驼岭 = 1
		}
	},
	人 = {
		大唐官府 = 1,
		方寸山 = 1,
		天机城 = 1,
		九黎城 = 1,
		神木林 = 1,
		女 = {
			女儿村 = 1
		},
		男 = {
			化生寺 = 1
		}
	}
}

function 角色处理类:初始化(id, ip)
	self.连接id = id
	self.连接ip = ip
	self.数据 = {}
end

function 角色处理类:GM添加经验(数额, 类型, 提示)
	local 倍率 = 1
	local 之前银子 = self.数据.当前经验
	local 经验 = math.floor(数额 * 倍率)
	self.数据.当前经验 = self.数据.当前经验 + 经验

	发送数据(玩家数据[self.数据.数字id].连接id, 33, 玩家数据[self.数据.数字id].角色:取总数据(1))

	if 提示 ~= nil then
		常规提示(self.数据.数字id, "#Y/GM给你添加了" .. 数字转简(经验) .. "点经验")
	end

	self:日志记录(format("事件:获得经验,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 类型, 数额, 倍率, 之前银子, self.数据.当前经验))

	if 经验数据.排行[self.数据.数字id] == nil then
		经验数据.排行[self.数据.数字id] = {
			id = self.数据.数字id,
			名称 = self.数据.名称,
			经验 = 经验,
			门派 = self.数据.门派,
			等级 = self.数据.等级
		}
	else
		经验数据.排行[self.数据.数字id].经验 = 经验数据.排行[self.数据.数字id].经验 + 经验
		经验数据.排行[self.数据.数字id].等级 = self.数据.等级
		经验数据.排行[self.数据.数字id].门派 = self.数据.门派
	end
end

function 角色处理类:添加称谓(id, 称谓)
	if self.数据.称谓 == nil then
		self.数据.称谓 = {}
	end

	for i = 1, #self.数据.称谓 do
		if self.数据.称谓[i] == 称谓 then
			return
		end
	end

	self.数据.称谓[#self.数据.称谓 + 1] = 称谓

	if 特殊官职称谓要求[称谓] ~= nil then
		self.数据.特殊官职级别 = (self.数据.特殊官职级别 or 0) + 特殊官职称谓要求[称谓].级别

		角色刷新信息(id, self.数据)
	end

	发送数据(玩家数据[id].连接id, 69, {
		项目 = "2",
		称谓 = self.数据.称谓
	})
	发送数据(玩家数据[id].连接id, 7, "#Y恭喜你获得了一个新的称谓【#S" .. 称谓 .. "#Y】")
end

function 角色处理类:删除称谓(id, 称谓)
	local 成功 = false

	for i = 1, #self.数据.称谓 do
		if self.数据.称谓[i] == 称谓 then
			if self.数据.当前称谓 == 称谓 then
				地图处理类:更新称谓(id)
			end

			table.remove(self.数据.称谓, i)

			成功 = true

			break
		end
	end

	if 成功 == true then
		if 特殊官职称谓要求[称谓] ~= nil then
			self.数据.特殊官职级别 = math.max((self.数据.特殊官职级别 or 0) - 特殊官职称谓要求[称谓].级别, 0)

			角色刷新信息(id, self.数据)
		end

		发送数据(玩家数据[id].连接id, 69, {
			项目 = "2",
			称谓 = self.数据.称谓,
			当前称谓 = self.数据.当前称谓
		})
		发送数据(玩家数据[id].连接id, 7, "#Y/你的#S" .. 称谓 .. "#Y称谓已经被系统删除。")
	end
end

function 角色处理类:更新称谓(id, 称谓)
	for i = 1, #self.数据.称谓 do
		if self.数据.称谓[i] == 称谓 then
			self.数据.当前称谓 = 称谓

			地图处理类:更新称谓(id, i)
		end
	end

	发送数据(玩家数据[id].连接id, 69, {
		项目 = "2",
		称谓 = self.数据.称谓,
		当前称谓 = self.数据.当前称谓
	})
end

function 角色处理类:创建角色(id, 账号, 模型, 名称, ip, 染色ID)
	local 管理 = 0

	if f函数.文件是否存在("data/" .. 账号 .. "/账号信息.txt") == true then
		管理 = f函数.读配置("data/" .. 账号 .. "/账号信息.txt", "账号配置", "管理") + 0
	end

	if f函数.文件是否存在("data/" .. 账号 .. "/信息.txt") == true then
		local 角色数量 = table.loadstring(读入文件("data/" .. 账号 .. "/信息.txt"))

		if 创建角色限制 <= #角色数量 and 管理账号列表[账号] == nil and 管理 == 0 then
			发送数据(id, 7, "#Y此账号创建角色过多，无法创建更多角色！")

			return
		end
	end

	local ms = 模型
	local ls = self:队伍角色(ms)
	local cs = self:取初始属性(ls.种族)
	服务端参数.角色id = 服务端参数.角色id + 1

	f函数.写配置(程序目录 .. "配置文件.ini", "主要配置", "id", 服务端参数.角色id)

	名称数据[#名称数据 + 1] = {
		名称 = 名称,
		id = 服务端参数.角色id,
		账号 = 账号
	}
	self.数据 = {
		最大活力 = 100,
		帮派 = "无帮派",
		活力 = 10,
		人气 = 600,
		当前经验 = 0,
		最大体力 = 100,
		愤怒 = 0,
		帮贡 = 0,
		洗点次数 = 0,
		今天月卡 = false,
		体力 = 10,
		官职次数 = 0,
		打造熟练度 = 0,
		银子 = 0,
		一键师门 = 0,
		门派 = "无门派",
		门贡 = 0,
		最大经验 = 0,
		月卡领取 = 0,
		剧情点 = 0,
		一键抓鬼 = 0,
		一键封妖 = 0,
		江湖次数 = 0,
		一键官职 = 0,
		转换角色次数 = 1,
		今天周卡 = false,
		传音纸鹤 = 0,
		等级 = 50,
		存银 = 0,
		官职点 = 0,
		转换门派次数 = 1,
		节日活动次数 = 0,
		当前称谓 = "防官西游",
		师门次数 = 0,
		储备 = 0,
		月卡激活 = 0,
		点化 = false,
		自动遇怪 = false,
		名称 = 名称,
		性别 = ls.性别,
		模型 = ls.模型,
		种族 = ls.种族,
		ID = 服务端参数.角色id,
		数字id = 服务端参数.角色id,
		称谓 = {
			"防官西游"
		},
		体质 = cs[1],
		魔力 = cs[2],
		力量 = cs[3],
		耐力 = cs[4],
		敏捷 = cs[5],
		潜力 = 250,
		修炼 = {
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
			},
			猎术修炼 = {
				0,
				0,
				0
			}
		},
		bb修炼 = {
			当前 = "攻击控制力",
			攻击控制力 = {
				0,
				0,
				0
			},
			法术控制力 = {
				0,
				0,
				0
			},
			防御控制力 = {
				0,
				0,
				0
			},
			抗法控制力 = {
				0,
				0,
				0
			}
		},
		参战宝宝 = {},
		召唤兽携带数量 = 初始召唤兽携带数量,
		坐骑携带数量 = 初始坐骑携带数量,
		助战携带数量 = 初始助战携带数量,
		可选门派 = ls.门派,
		装备 = {},
		灵饰 = {},
		锦衣 = {},
		法宝 = {},
		师门技能 = {},
		人物技能 = {},
		特殊技能 = {},
		辅助技能 = {},
		快捷技能 = {},
		技能等级 = {
			0,
			0,
			0,
			0
		},
		染色方案 = ls.染色方案,
		染色组 = {
			math.ceil(染色ID),
			math.ceil(染色ID),
			math.ceil(染色ID)
		} or {
			0,
			0,
			0
		},
		装备属性 = {
			伤害 = 0,
			体质 = 0,
			气血 = 0,
			乾元丹 = 0,
			力量 = 0,
			敏捷 = 0,
			魔法 = 0,
			魔力 = 0,
			灵力 = 0,
			剩余乾元丹 = 0,
			速度 = 0,
			可换乾元丹 = 20,
			防御 = 0,
			月饼 = 0,
			耐力 = 0,
			躲避 = 0,
			附加乾元丹 = 0,
			命中 = 0
		},
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
		奇经八脉 = {},
		变身 = {},
		在线时间 = {
			小时 = 0,
			计算分 = 0,
			活力 = 0,
			秒 = 0,
			累积 = 0,
			体力 = 0,
			分 = 0
		},
		剧情 = {},
		当前剧情 = {},
		五宝数据 = {
			夜光珠 = 0,
			金刚石 = 0,
			龙鳞 = 0,
			避水珠 = 0,
			定魂珠 = 0
		},
		法宝佩戴 = {},
		新手奖励 = {},
		好友数据 = {
			好友 = {},
			临时 = {},
			最近 = {},
			黑名单 = {}
		},
		新手银子 = {},
		新手礼包 = {},
		新手宝宝礼包 = {},
		坐骑列表 = {},
		账号 = 账号,
		ip = ip,
		道具 = {},
		行囊 = {},
		超级行囊 = {
			装备 = {},
			杂货 = {},
			宝石 = {},
			打造 = {},
			特兽决 = {},
			高兽决 = {},
			兽决 = {},
			法宝 = {}
		},
		阵法 = {
			普通 = 1
		},
		出生日期 = os.time(),
		造型 = ls.模型,
		地图数据 = {
			编号 = 1003,
			x = 400,
			y = 500
		},
		武器数据 = {
			名称 = "",
			等级 = 0,
			子类 = ""
		},
		任务 = {},
		道具仓库 = {
			{},
			{},
			{}
		},
		召唤兽仓库 = {
			{}
		},
		宠物 = {
			经验 = 1,
			最大经验 = 10,
			名称 = "生肖猪",
			最大耐力 = 5,
			领养次数 = 0,
			耐力 = 5,
			模型 = "生肖猪",
			最大等级 = 120,
			等级 = 1
		},
		剧情技能 = {
			{
				名称 = "仙灵店铺",
				等级 = 5
			},
			{
				名称 = "奇门遁甲",
				等级 = 4
			},
			{
				等级 = 5,
				名称 = "调息 "
			},
			{
				等级 = 5,
				名称 = "打坐"
			},
			[5] = {
				等级 = 10,
				名称 = "变化之术"
			},
			[7] = {
				等级 = 10,
				名称 = "妙手空空"
			},
			[8] = {
				等级 = 7,
				名称 = "宝石工艺"
			},
			[6] = {
				等级 = 5,
				名称 = "建筑之术"
			},
			[9] = {
				等级 = 5,
				名称 = "火眼金睛"
			},
			[10] = {
				等级 = 1,
				名称 = "飞行 "
			}
		},
		比武积分 = {
			总积分 = 0,
			当前积分 = 0
		},
		剧情 = {
			初入桃源村 = 1
		}
	}

	if f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "银子") ~= nil and tonumber(f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "银子")) ~= nil then
		self.数据.银子 = tonumber(f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "银子"))
	end

	if f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "经验") ~= nil and tonumber(f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "经验")) ~= nil then
		self.数据.当前经验 = tonumber(f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "经验"))
	end

	if f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "储备") ~= nil and tonumber(f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "储备")) ~= nil then
		self.数据.储备 = tonumber(f函数.读配置(程序目录 .. "自定义配置.ini", "出生自带", "储备"))
	end

	for n = 1, #灵饰战斗属性 do
		self.数据[灵饰战斗属性[n]] = 0
	end

	for i = 1, #角色辅助技能列表 do
		local 辅助技能 = jnzb()

		辅助技能:置对象(角色辅助技能列表[i])

		辅助技能.等级 = 60

		insert(self.数据.辅助技能, 辅助技能)
	end

	self:刷新信息("1")
	lfs.mkdir("data/" .. 账号 .. "/" .. self.数据.数字id)
	lfs.mkdir("data/" .. 账号 .. "/" .. self.数据.数字id .. "/日志记录")

	self.数据.日志编号 = 1
	self.数据.日志内容 = "日志创建"

	写出文件("data/" .. 账号 .. "/" .. self.数据.数字id .. "/日志记录" .. "/1.txt", "日志创建\n")
	写出文件("data/" .. 账号 .. "/" .. self.数据.数字id .. "/道具.txt", "do local ret={} return ret end")
	写出文件("data/" .. 账号 .. "/" .. self.数据.数字id .. "/召唤兽.txt", "do local ret={} return ret end")
	写出文件("data/" .. 账号 .. "/" .. self.数据.数字id .. "/助战.txt", "do local ret={} return ret end")

	if f函数.文件是否存在("data/" .. 账号 .. "/信息.txt") == false then
		self.写入信息 = {
			self.数据.数字id
		}

		写出文件("data/" .. 账号 .. "/信息.txt", table.tostring(self.写入信息))
	else
		self.写入信息 = table.loadstring(读入文件("data/" .. 账号 .. "/信息.txt"))
		self.写入信息[#self.写入信息 + 1] = self.数据.数字id

		写出文件("data/" .. 账号 .. "/信息.txt", table.tostring(self.写入信息))

		self.角色信息 = nil
	end

	local 任务id = self.数据.数字id .. "_999_" .. os.time() .. "_" .. 随机序列 .. "_" .. 取随机数(88, 99999999) .. "_" .. self.数据.数字id
	self.数据.任务[#self.数据.任务 + 1] = 任务id
	任务数据[任务id] = {
		名称 = "",
		等级 = 0,
		x = 0,
		y = 0,
		地图编号 = 0,
		结束 = 0,
		进程 = 1,
		地图名称 = "无",
		类型 = 999,
		模型 = "",
		id = 任务id,
		起始 = os.time(),
		玩家id = self.数据.数字id,
		队伍组 = {}
	}
	self.写入信息 = nil

	self:存档()
end

function 角色处理类:增加在线时间()
	self.数据.在线时间.累积 = self.数据.在线时间.累积 + 1
	self.数据.在线时间.秒 = self.数据.在线时间.秒 + 1

	if self.数据.在线时间.秒 >= 60 then
		self.数据.在线时间.秒 = 0
		self.数据.在线时间.分 = self.数据.在线时间.分 + 1

		if self.数据.在线时间.计算分 == nil then
			self.数据.在线时间.计算分 = 0
		end

		self.数据.在线时间.计算分 = self.数据.在线时间.计算分 + 1

		if self.数据.在线时间.计算分 >= 5 then
			self.数据.活力 = self.数据.活力 + math.floor(self.数据.最大活力 * 0.02)
			self.数据.体力 = self.数据.体力 + math.floor(self.数据.最大体力 * 0.02)

			if self.数据.最大活力 < self.数据.活力 then
				self.数据.活力 = self.数据.最大活力
			end

			if self.数据.最大体力 < self.数据.体力 then
				self.数据.体力 = self.数据.最大体力
			end

			if self.数据.在线时间.活力 == nil then
				self.数据.在线时间.活力 = self.数据.活力
			end

			if self.数据.在线时间.体力 == nil then
				self.数据.在线时间.体力 = self.数据.体力
			end

			if self.数据.在线时间.活力 ~= self.数据.最大活力 or self.数据.在线时间.体力 ~= self.数据.最大体力 then
				体活刷新(self.数据.数字id)
			end

			self.数据.在线时间.活力 = self.数据.活力
			self.数据.在线时间.体力 = self.数据.体力
			self.数据.在线时间.计算分 = 0
		end

		if self.数据.在线时间.分 >= 60 then
			self.数据.在线时间.分 = 0
			self.数据.在线时间.小时 = self.数据.在线时间.小时 + 1
			self.数据.人气 = self.数据.人气 + 1

			if self.数据.人气 > 800 then
				self.数据.人气 = 800
			end
		end
	end
end

function 角色处理类:刷新月卡()
	self.数据.当天月卡 = false
end

function 角色处理类:经脉处理(id)
	return {
		流派 = self.数据.经脉流派,
		模型 = self.数据.模型,
		门派 = self.数据.门派,
		奇经八脉 = self.数据.奇经八脉,
		装备属性 = self.数据.装备属性
	}
end

function 角色处理类:清空奇经八脉(id)
	local 清空奇经八脉费用 = 1000000

	if 取银子(id) < 清空奇经八脉费用 then
		常规提示(id, "#Y/你当前的银两不够清空奇经八脉哦,清空奇经八脉需要" .. 清空奇经八脉费用 .. "两银子！")

		return
	end

	if self.数据.装备属性.乾元丹 ~= nil and self.数据.装备属性.乾元丹 == 0 then
		常规提示(id, "#Y/你当前没有可清空的奇经八脉！")

		return
	end

	self:扣除银子(清空奇经八脉费用, 0, 0, "清空奇经八脉费用", 1)

	if self.数据.奇经八脉.经脉流派 ~= nil then
		self:删除称谓(id, self.数据.奇经八脉.经脉流派)
	end

	self.数据.奇经八脉 = {}
	self.数据.开启奇经八脉 = nil
	self.数据.技能树 = nil
	self.数据.装备属性.剩余乾元丹 = self.数据.装备属性.剩余乾元丹 + self.数据.装备属性.乾元丹
	self.数据.装备属性.乾元丹 = 0

	常规提示(id, "#Y/恭喜你,经脉重置成功！")
	发送数据(玩家数据[id].连接id, 77, self:经脉处理(id))
end

function 角色处理类:兑换乾元丹(id)
	local 附加乾元丹 = self.数据.装备属性.附加乾元丹
	local 乾元丹消耗 = 取乾元丹消耗(附加乾元丹 + 1)

	if 取银子(id) < 乾元丹消耗.金钱 then
		常规提示(id, "#Y/你当前的银两不够兑换乾元丹！兑换所需#P" .. 数字转简(乾元丹消耗.金钱) .. "两")

		return
	end

	if self.数据.当前经验 < 乾元丹消耗.经验 then
		常规提示(id, "#Y/你当前的经验不够兑换乾元丹！兑换所需#P" .. 数字转简(乾元丹消耗.经验) .. "点经验")

		return
	end

	if self.数据.装备属性.可换乾元丹 <= self.数据.装备属性.附加乾元丹 then
		if 吊游定制 then
			添加最后对话(id, "你当前不满足兑换乾元丹的条件哦！当前可以选择消耗#R10E经验、10E#Y银两继续兑换！", {
				"土豪兑换乾元丹",
				"我只是看看"
			})

			return
		else
			常规提示(id, "#Y/你当前不满足兑换乾元丹的条件哦！")

			return
		end
	end

	self:扣除银子(乾元丹消耗.金钱, 0, 0, "乾元丹消耗", 1)

	self.数据.当前经验 = self.数据.当前经验 - 乾元丹消耗.经验

	常规提示(id, "#Y/你失去了#R" .. 数字转简(乾元丹消耗.经验) .. "#Y点经验！")

	self.数据.装备属性.附加乾元丹 = self.数据.装备属性.附加乾元丹 + 1
	self.数据.装备属性.剩余乾元丹 = self.数据.装备属性.剩余乾元丹 + 1

	发送数据(玩家数据[id].连接id, 7008, self:经脉处理(id))
	添加最后对话(id, "兑换乾元丹成功！")
end

function 角色处理类:土豪兑换乾元丹(id)
	if 取银子(id) < 1000000000 then
		常规提示(id, "#Y/你当前的银两不够兑换乾元丹哦！")

		return
	end

	if self.数据.当前经验 < 100000000 then
		常规提示(id, "#Y/你当前的经验不够兑换乾元丹哦！")

		return
	end

	self:扣除银子(1000000000, 0, 0, "乾元丹消耗", 1)

	self.数据.当前经验 = self.数据.当前经验 - 1000000000
	self.数据.装备属性.附加乾元丹 = self.数据.装备属性.附加乾元丹 + 1
	self.数据.装备属性.剩余乾元丹 = self.数据.装备属性.剩余乾元丹 + 1

	添加最后对话(id, "兑换乾元丹成功！")
end

增加奇经八脉 = function(id, 位置, 角色数据, 助战编号)
	if 角色数据.门派 ~= nil and 角色数据.门派 ~= "无门派" then
		local x读取 = nil

		if 三经脉开关 then
			x读取 = 提取三经脉奇经八脉(角色数据.门派, 角色数据.经脉流派)
		else
			x读取 = 提取奇经八脉(角色数据.门派)
		end

		if x读取 ~= nil and x读取[位置] ~= nil and x读取[位置] ~= 1 then
			if 角色数据.装备属性.剩余乾元丹 ~= nil and 角色数据.装备属性.剩余乾元丹 > 0 then
				if 角色数据.奇经八脉 == nil then
					角色数据.奇经八脉 = {}
				end

				if 位置 > 3 then
					local aa = qz((位置 - 1) / 3) * 3
					local bb = false

					for i = aa - 2, aa do
						if 角色数据.奇经八脉[x读取[i]] == 1 then
							bb = true

							break
						end
					end

					if not bb then
						常规提示(id, "#Y/请按顺序学习经脉！")

						return
					end
				end

				角色数据.装备属性.剩余乾元丹 = 角色数据.装备属性.剩余乾元丹 - 1
				角色数据.装备属性.乾元丹 = 角色数据.装备属性.乾元丹 + 1
				角色数据.奇经八脉[x读取[位置]] = 1

				if 角色数据.奇经八脉.经脉流派 == nil then
					角色数据.奇经八脉.经脉流派 = 经脉流派(角色数据.门派)[角色数据.经脉流派 or 1]
				end

				if not 三经脉开关 then
					if 位置 >= 19 then
						角色数据.奇经八脉[x读取[20]] = 1
					end
				elseif 位置 == 21 and 助战编号 == nil then
					玩家数据[id].角色:添加称谓(id, 角色数据.奇经八脉.经脉流派)
				end

				角色数据.奇经八脉.开启奇经八脉 = true
				角色数据.奇经八脉.技能树 = 技能树(位置, x读取, 角色数据) or 1

				常规提示(id, "#Y/恭喜你又学会了一种经脉!")
			else
				常规提示(id, "#Y/奇经八脉学习失败!剩余乾元丹不够本次学习")
			end

			发送数据(玩家数据[id].连接id, 7008, {
				编号 = 助战编号,
				流派 = 角色数据.经脉流派,
				门派 = 角色数据.门派,
				奇经八脉 = 角色数据.奇经八脉,
				装备属性 = 角色数据.装备属性
			})

			return
		end
	end

	常规提示(id, "#Y/对不起!奇经八脉学习失败")
	发送数据(玩家数据[id].连接id, 7008, {
		编号 = 助战编号,
		流派 = 角色数据.经脉流派,
		门派 = 角色数据.门派,
		奇经八脉 = 角色数据.奇经八脉,
		装备属性 = 角色数据.装备属性
	})
end

技能树 = function(a, x读取, 角色数据)
	local n1 = 0
	local b = {}

	for i = 1, 21 do
		if (i ~= 20 or 三经脉开关) and 角色数据.奇经八脉[x读取[i]] ~= nil and 角色数据.奇经八脉[x读取[i]] == 1 then
			n1 = i
		end
	end

	local aa = 1

	if n1 > 15 then
		if 经脉限制开关 then
			aa = 19
		end

		for i = aa, 21 do
			if i ~= 20 or 三经脉开关 then
				b[#b + 1] = i
			end
		end

		return b
	elseif n1 > 12 then
		if 经脉限制开关 then
			aa = 16
		end

		for i = aa, 18 do
			b[#b + 1] = i
		end

		return b
	elseif n1 > 9 then
		if 经脉限制开关 then
			aa = 13
		end

		for i = aa, 15 do
			b[#b + 1] = i
		end

		return b
	elseif n1 > 6 then
		if 经脉限制开关 then
			aa = 10
		end

		for i = aa, 12 do
			b[#b + 1] = i
		end

		return b
	elseif n1 > 3 then
		if 经脉限制开关 then
			aa = 7
		end

		for i = aa, 9 do
			b[#b + 1] = i
		end

		return b
	elseif n1 > 0 then
		if 经脉限制开关 then
			aa = 4
		end

		for i = aa, 6 do
			b[#b + 1] = i
		end

		return b
	else
		if 经脉限制开关 then
			aa = 1
		end

		for i = aa, 3 do
			b[#b + 1] = i
		end

		return b
	end
end

function 角色处理类:GM添加坐骑技能(id, 技能组, 模式)
	local 参战坐骑 = 0

	for i = 1, #玩家数据[id].角色.数据.坐骑列表 do
		if 玩家数据[id].角色.数据.坐骑列表[i].参战信息 ~= nil then
			参战坐骑 = i

			break
		end
	end

	if 参战坐骑 == 0 then
		常规提示(id, "请先将要添加技能的坐骑骑乘！")

		return
	end

	local 原有技能 = {}
	原有技能 = 列表模式转换(列表2加入到列表1(玩家数据[id].角色.数据.坐骑列表[参战坐骑].技能, 原有技能))
	删除技能 = {}
	技能总数 = #玩家数据[id].角色.数据.坐骑列表[参战坐骑].技能 + 0

	for i = 1, #技能组 do
		if 模式 == 1 then
			local aa = 技能组[i] .. ""

			if 坐骑特殊技能1[技能组[i]] ~= nil then
				aa = 技能组[i] .. "【伪】"
			end

			if 原有技能[技能组[i]] == nil and 原有技能[aa] == nil then
				玩家数据[id].角色.数据.坐骑列表[参战坐骑].技能[#玩家数据[id].角色.数据.坐骑列表[参战坐骑].技能 + 1] = aa
				原有技能[aa] = 1

				常规提示(id, "#Y恭喜你的#R" .. 玩家数据[id].角色.数据.坐骑列表[参战坐骑].名称 .. "#Y获得新技能：#R" .. aa .. "#Y！")
			else
				常规提示(id, "#Y你的#R" .. 玩家数据[id].角色.数据.坐骑列表[参战坐骑].名称 .. "#Y已有#R" .. 技能组[i] .. "#Y技能！")
			end
		elseif 模式 == 2 then
			local aa = 技能组[i] .. ""

			if 坐骑特殊技能1[技能组[i]] ~= nil then
				aa = 技能组[i] .. "【伪】"
			end

			if 原有技能[技能组[i]] ~= nil or 原有技能[aa] ~= nil then
				if 原有技能[技能组[i]] ~= nil then
					删除技能[#删除技能 + 1] = 原有技能[技能组[i]] + 0
					原有技能[技能组[i]] = nil
				end

				if 原有技能[aa] ~= nil then
					删除技能[#删除技能 + 1] = 原有技能[aa] + 0
					原有技能[aa] = nil
				end

				常规提示(id, "#R" .. 玩家数据[id].角色.数据.坐骑列表[参战坐骑].名称 .. "#Y删除技能#R" .. 技能组[i] .. "#Y成功！")
			else
				常规提示(id, "#R" .. 玩家数据[id].角色.数据.坐骑列表[参战坐骑].名称 .. "#Y没有#R" .. 技能组[i] .. "#Y技能，删除失败！")
			end
		end
	end

	if #删除技能 > 0 then
		table.sort(删除技能, function(a, b)
			return a < b
		end)

		local 已删 = 0

		for i = 1, #删除技能 do
			table.remove(玩家数据[id].角色.数据.坐骑列表[参战坐骑].技能, 删除技能[i] - 已删)

			已删 = 已删 + 1
		end
	end

	发送数据(玩家数据[id].连接id, 61.1, {
		编号 = 参战坐骑,
		数据 = 玩家数据[id].角色.数据.坐骑列表[参战坐骑]
	})
end

function 角色处理类:增加坐骑(id)
	local zqsQ = 全局坐骑资料:取坐骑库(玩家数据[id].角色.数据)
	local zqsQ2 = true

	if 玩家数据[id].角色.数据.坐骑列表 ~= nil then
		for i = 1, #玩家数据[id].角色.数据.坐骑列表 do
			if 玩家数据[id].角色.数据.坐骑列表[i].名称 == zqsQ then
				zqsQ2 = false
			end
		end
	end

	if zqsQ2 == false then
		常规提示(id, "#Y/使用失败!你已经换取过[" .. zqsQ .. "]坐骑!")
	elseif 玩家数据[id].角色.数据.坐骑列表 ~= nil and 玩家数据[id].角色.数据.坐骑携带数量 <= #玩家数据[id].角色.数据.坐骑列表 then
		常规提示(id, "#Y/对不起你换取的[" .. zqsQ .. "]坐骑失败!携带坐骑数量已上限.")

		return false
	else
		常规提示(id, "#Y/恭喜你换取了[" .. zqsQ .. "]坐骑!")
		广播消息({
			频道 = "xt",
			内容 = format("#S(坐骑任务)#R/%s#Y挑战成功周猎户完成了坐骑任务,悄悄#R%s#Y,因此获得了百兽王奖励的#G/%s#Y" .. "#" .. 取随机数(1, 110),
				玩家数据[id].角色.数据.名称, "打开后", zqsQ)
		})
		全局坐骑资料:获取坐骑(id, zqsQ)
		发送数据(玩家数据[id].连接id, 61, 玩家数据[id].角色.数据.坐骑列表)
	end
end

function 角色处理类:增加坐骑1(id, 坐骑任务)
	local zqsQ = 全局坐骑资料:取坐骑库(玩家数据[id].角色.数据)

	if 坐骑任务 ~= nil and ygsj() <= 40 then
		zqsQ = 全局坐骑资料:取坐骑库1(玩家数据[id].角色.数据)
	end

	if 玩家数据[id].角色.数据.坐骑列表 ~= nil and 玩家数据[id].角色.数据.坐骑携带数量 <= #玩家数据[id].角色.数据.坐骑列表 then
		常规提示(id, "#Y/对不起你换取的[" .. zqsQ .. "]坐骑失败!携带坐骑数量已上限.")

		return false
	else
		常规提示(id, "#Y/恭喜你换取了[" .. zqsQ .. "]坐骑!")

		if 坐骑任务 ~= nil then
			广播消息({
				频道 = "xt",
				内容 = format("#S(坐骑任务)#R/%s#Y挑战成功周猎户完成了坐骑任务,悄悄#R%s#Y,因此获得了百兽王奖励的#G/%s#Y" .. "#" .. 取随机数(1, 110),
					玩家数据[id].角色.数据.名称, "打开后", zqsQ)
			})
		else
			广播消息({
				频道 = "xt",
				内容 = format("#S(种族坐骑礼包)#R/%s#Y悄悄打开#S种族坐骑礼包#Y,里面竟然是一只#G/%s#Y" .. "#" .. 取随机数(1, 110), 玩家数据[id].角色.数据.名称,
					zqsQ)
			})
		end

		全局坐骑资料:获取坐骑(id, zqsQ)
		发送数据(玩家数据[id].连接id, 61, 玩家数据[id].角色.数据.坐骑列表)

		return true
	end
end

function 角色处理类:增加坐骑2(id)
	local zqsQ = 全局坐骑资料:取坐骑库1(玩家数据[id].角色.数据)

	if 玩家数据[id].角色.数据.坐骑列表 ~= nil and 玩家数据[id].角色.数据.坐骑携带数量 <= #玩家数据[id].角色.数据.坐骑列表 then
		常规提示(id, "#Y/对不起你换取的[" .. zqsQ .. "]坐骑失败!携带坐骑数量已上限.")

		return false
	else
		常规提示(id, "#Y/恭喜你换取了[" .. zqsQ .. "]坐骑!")
		广播消息({
			频道 = "xt",
			内容 = format("#S(祥瑞坐骑礼包)#R/%s#Y悄悄打开#S祥瑞坐骑礼包#Y,里面竟然是一只#G/%s#Y" .. "#" .. 取随机数(1, 110), 玩家数据[id].角色.数据.名称, zqsQ)
		})
		全局坐骑资料:获取坐骑(id, zqsQ)
		发送数据(玩家数据[id].连接id, 61, 玩家数据[id].角色.数据.坐骑列表)

		return true
	end
end

function 角色处理类:增加指定坐骑(id, 坐骑)
	local zqsQ = 坐骑

	if 玩家数据[id].角色.数据.坐骑列表 ~= nil and 玩家数据[id].角色.数据.坐骑携带数量 <= #玩家数据[id].角色.数据.坐骑列表 then
		常规提示(id, "#Y/对不起你换取的[" .. zqsQ .. "]坐骑失败!携带坐骑数量已上限.")

		return false
	else
		常规提示(id, "#Y/恭喜你获得了[" .. zqsQ .. "]坐骑!")
		广播消息({
			频道 = "xt",
			内容 = format("#S(指定坐骑)#R/%s#Y悄悄打开了#S指定坐骑礼包#Y、获得了一只【#G/%s#Y" .. "】#" .. 取随机数(1, 110), 玩家数据[id].角色.数据.名称, zqsQ)
		})
		全局坐骑资料:获取坐骑(id, zqsQ)
		发送数据(玩家数据[id].连接id, 61, 玩家数据[id].角色.数据.坐骑列表)

		return true
	end
end

function 角色处理类:门派任务(id, 门派)
	任务处理类:添加门派任务(id, 门派)
end

function 角色处理类:取门派传送选项()
	local xx = {}

	if self.数据.种族 == "仙" then
		xx = {
			"天宫",
			"龙宫",
			"凌波城",
			"花果山"
		}

		if self.数据.性别 == "男" then
			xx[#xx + 1] = "五庄观"
		else
			xx[#xx + 1] = "普陀山"
		end
	elseif self.数据.种族 == "魔" then
		xx = {
			"魔王寨",
			"阴曹地府",
			"无底洞",
			"女魃墓"
		}

		if self.数据.性别 == "男" then
			xx[#xx + 1] = "狮驼岭"
		else
			xx[#xx + 1] = "盘丝洞"
		end
	elseif self.数据.种族 == "人" then
		xx = {
			"神木林",
			"大唐官府",
			"方寸山",
			"天机城"
		}

		if self.数据.性别 == "男" then
			xx[#xx + 1] = "化生寺"
		else
			xx[#xx + 1] = "女儿村"
		end
	end

	return xx
end

function 角色处理类:更改角色名字(id, 数据)
	if 玩家数据[id].改名时间 ~= nil and os.time() - 玩家数据[id].改名时间 <= 86400 then
		常规提示(id, "#Y/改名间隔至少需要#P24小时#Y、请#S" .. 时间转换(玩家数据[id].改名时间 + 86400) .. "#Y后再行尝试。")

		return
	end

	local 改名费用 = 100000000
	local 已存在 = false

	if 取银子(id) < 改名费用 then
		常规提示(id, "#Y/更名需要消耗银子,你好像没有那么多的银子。")

		return
	elseif #数据.文本 < 2 then
		常规提示(id, "#Y/名字过短、请重新输入。")

		return
	elseif #数据.文本 > 16 then
		常规提示(id, "#Y/名字过长、请重新输入。")

		return
	end

	if string.find(数据.文本, "#") ~= nil or string.find(数据.文本, "/") ~= nil or string.find(数据.文本, "@") ~= nil or string.find(数据.文本, "*") ~= nil or string.find(数据.文本, " ") ~= nil or string.find(数据.文本, "~") ~= nil or string.find(数据.文本, "GM") ~= nil or string.find(数据.文本, "gm") ~= nil or string.find(数据.文本, "  ") ~= nil or string.find(数据.文本, "充值") ~= nil or string.find(数据.文本, "管理") ~= nil or string.find(数据.文本, "·") ~= nil or string.find(数据.文本, "q") ~= nil or string.find(数据.文本, "群") ~= nil or string.find(数据.文本, "裙") ~= nil or string.find(数据.文本, "打造") ~= nil or string.find(数据.文本, "月明星稀") ~= nil or 数据.文本 == "" then
		常规提示(id, "#Y/名字不能含有敏感字符")

		return
	end

	for i = 1, #名称数据 do
		if 名称数据[i].名称 == 数据.文本 then
			已存在 = true
		end
	end

	if 已存在 then
		常规提示(id, "#Y/该名字已存在,请少侠换一个名称。")

		return
	end

	self:扣除银子(改名费用, 0, 0, "人物改名", 1)
	发送公告("#R(角色改名提示)#G/" .. self.数据.名称 .. "#Y少侠将行走三界的名号更改为了#P" .. 数据.文本 .. "#Y，特此通告三界！")

	self.数据.名称 = 数据.文本

	常规提示(id, "#Y/恭喜你,改名成功！")

	玩家数据[id].改名时间 = os.time()

	发送数据(玩家数据[self.数据.数字id].连接id, 33, 玩家数据[self.数据.数字id].角色:取总数据(1))

	if self.数据.帮派数据 == nil then
		self.数据.帮派数据 = {
			权限 = 0
		}
	end

	if self.数据.帮派数据.编号 ~= nil then
		local 帮派编号 = self.数据.帮派数据.编号
		local id2 = self.数据.ID
		帮派数据[帮派编号].成员数据[id2].名称 = self.数据.名称
	end
end

function 角色处理类:扣除经验1(数额, 类型, 提示)
	self.数据.当前经验 = self.数据.当前经验 - 数额
	发送数据(玩家数据[self.数据.数字id].连接id, 33, 玩家数据[self.数据.数字id].角色:取总数据(1))
	发送数据(玩家数据[self.数据.数字id].连接id, 38, {
		频道 = "xt",
		内容 = "你消耗了" .. 数额 .. "点经验"
	})
end

function 角色处理类:安全码验证(id, 数据)
	if 数据.文本 ~= f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码") then
		常规提示(id, "#Y/安全码输入错误,请重新输入！")

		return
	else
		玩家数据[id].安全码验证 = true

		常规提示(id, "#Y/安全码验证成功！")

		return
	end
end

function 角色处理类:安全码修炼验证(id, 数据)
	if 数据.文本 ~= f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码") then
		常规提示(id, "#Y/安全码输入错误,请重新输入！")

		return
	else
		发送数据(玩家数据[self.数据.数字id].连接id, 142.2)
	end
end

function 角色处理类:更改帐号密码(id, 数据)
	local 新密码 = 数据.文本

	f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "密码", 新密码)
	常规提示(id, "#Y/恭喜你,密码修改成功,请下线重新登录")
	发送数据(玩家数据[id].连接id, 998, "修改密码成功,请重新登陆！")

	玩家数据[id].连接id = id

	系统处理类:断开游戏(id)

	__N连接数 = __N连接数 - 1

	__gge.print(false, 10, "玩家账号  " .. self.数据.账号 .. "名称  " .. self.数据.名称 .. "修改密码为  " .. 新密码 .. "  修改成功\n")
end

function 角色处理类:添加经验(数额, 类型, 提示)
	local 基础倍率 = 服务端参数.经验获得率
	local 倍率 = 1
	local 通灵宝玉加成 = 0

	if 类型 == "神秘宝箱" or 类型 == "天蝎座" or 类型 == "射手座" or 类型 == "摩羯座" or 类型 == "水瓶座" or 类型 == "白羊座" or 类型 == "金牛座" or 类型 == "新服福利BOSS" or 类型 == "狮子座" or 类型 == "处女座" or 类型 == "天秤座" or 类型 == "不加倍" then
		倍率 = 1
	end

	local 通灵宝玉生效 = false
	local 之前银子 = self.数据.当前经验

	if 类型 == "野外" or 类型 == "捉鬼" or 类型 == "官职" or 类型 == "封妖战斗" or 类型 == "种族" or 类型 == "门派闯关" or 类型 == "初出江湖" or 类型 == "悬赏任务" then
		if self:取任务(2) ~= 0 then
			倍率 = 倍率 + 1
		end

		if self:取任务(3) ~= 0 then
			倍率 = 倍率 + 1
		end

		if self.数据.通灵宝玉 ~= nil and self.数据.通灵宝玉 > 0 then
			if 通灵宝玉上限 < self.数据.通灵宝玉 then
				self.数据.通灵宝玉 = 通灵宝玉上限 + 0
			end

			通灵宝玉加成 = self.数据.通灵宝玉 * 数额 * 基础倍率
			基础倍率 = 基础倍率 * (1 + self.数据.通灵宝玉)
		end

		通灵宝玉生效 = true
	end

	if 服务端参数.倍率模式 == 1 then
		if self:取任务(7756) ~= 0 then
			倍率 = 倍率 * 2
		end

		if self:取任务(7755) ~= 0 then
			倍率 = 倍率 * 3
		end

		if self:取任务(7757) ~= 0 then
			倍率 = 倍率 * 10
		end
	else
		if self:取任务(7756) ~= 0 then
			倍率 = 倍率 + 1
		end

		if self:取任务(7755) ~= 0 then
			倍率 = 倍率 + 2
		end

		if self:取任务(7757) ~= 0 then
			倍率 = 倍率 + 9
		end
	end

	if 队伍数据[玩家数据[self.数据.数字id].队伍] ~= nil and 队伍数据[玩家数据[self.数据.数字id].队伍].成员数据[1] == self.数据.数字id then
		local id = self.数据.数字id

		for i = 2, 5 do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, i) ~= 0 then
				local 助战编号 = 队伍处理类:取助战编号(玩家数据[id].队伍, i)

				玩家数据[id].助战:添加经验(助战编号, 数额, 倍率, 通灵宝玉生效)
			end
		end
	end

	local 经验 = qz(数额 * 倍率 * 基础倍率)
	local 称谓加成 = 0

	if self.数据.当前称谓 == "西游小萌新" then
		称谓加成 = math.floor(经验 * 0.1)
	elseif self.数据.当前称谓 == "笑看西游" then
		称谓加成 = math.floor(经验 * 0.15)
	elseif self.数据.当前称谓 == "西游任我行" then
		称谓加成 = math.floor(经验 * 0.18)
	elseif self.数据.当前称谓 == "梦幻任逍遥" then
		称谓加成 = math.floor(经验 * 0.2)
	elseif self.数据.当前称谓 == "天人开造化" then
		称谓加成 = math.floor(经验 * 0.25)
	end

	if self:取任务(410) ~= 0 then
		local 储备金 = 0
		local 任务id = self:取任务(410)

		if 任务数据[任务id].离线储备 - 经验 < 0 then
			储备金 = 任务数据[任务id].离线储备
			任务数据[任务id].离线储备 = 0
		else
			任务数据[任务id].离线储备 = 任务数据[任务id].离线储备 - 经验
			储备金 = 经验
		end

		if 任务数据[任务id].离线储备 <= 0 then
			self:取消任务(任务id)

			任务数据[任务id] = nil
		end

		self:添加储备(储备金, "离线储备获取", 1)
		self:刷新任务跟踪()
	end

	if self:取任务(409) ~= 0 then
		local 任务id = self:取任务(409)

		if 任务数据[任务id].离线经验 - 经验 < 0 then
			经验 = 经验 * 2 - (经验 - 任务数据[任务id].离线经验)
			任务数据[任务id].离线经验 = 0
		else
			任务数据[任务id].离线经验 = 任务数据[任务id].离线经验 - 经验
			经验 = 经验 * 2
		end

		if 任务数据[任务id].离线经验 <= 0 then
			self:取消任务(任务id)

			任务数据[任务id] = nil
		end

		self:刷新任务跟踪()
	end

	self.数据.当前经验 = self.数据.当前经验 + 经验 + 称谓加成

	if 玩家数据[self.数据.数字id].战斗 == 0 then
		发送数据(玩家数据[self.数据.数字id].连接id, 33, 玩家数据[self.数据.数字id].角色:取总数据(1))
	end

	if 称谓加成 == 0 then
		if 通灵宝玉加成 > 0 then
			通灵宝玉加成 = qz1(通灵宝玉加成 * 倍率)

			发送数据(玩家数据[self.数据.数字id].连接id, 38, {
				频道 = "xt",
				内容 = "#Y你获得了#R" .. 数字转简(经验) .. "#Y点经验(其中通灵宝玉额外加成#R" .. 数字转简(通灵宝玉加成) .. "#Y点)"
			})
		else
			发送数据(玩家数据[self.数据.数字id].连接id, 38, {
				频道 = "xt",
				内容 = "#Y你获得了#R" .. 数字转简(经验) .. "#Y点经验啊"
			})
		end
	else
		发送数据(玩家数据[self.数据.数字id].连接id, 38, {
			频道 = "xt",
			内容 = "#Y你获得了#R" .. 数字转简(经验) .. "#Y点经验,佩戴VIP称谓额外获得#R" .. 数字转简(称谓加成) .. "#Y点经验。"
		})
	end

	if 提示 ~= nil then
		if 称谓加成 == 0 then
			常规提示(self.数据.数字id, "#Y你获得了#R" .. 数字转简(经验) .. "#Y点经验")
		else
			常规提示(self.数据.数字id, "#Y你获得了#R" .. 数字转简(经验) .. "#Y点经验,佩戴VIP称谓额外获得#R" .. 数字转简(称谓加成) .. "#Y点经验。")
		end
	end

	self:日志记录(format("事件:获得经验,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 类型, 数额, 倍率, 之前银子, self.数据.当前经验))

	if 经验数据.排行[self.数据.数字id] == nil then
		经验数据.排行[self.数据.数字id] = {
			id = self.数据.数字id,
			名称 = self.数据.名称,
			经验 = 经验,
			门派 = self.数据.门派,
			等级 = self.数据.等级,
			账号 = self.数据.账号
		}
	else
		经验数据.排行[self.数据.数字id].经验 = 经验数据.排行[self.数据.数字id].经验 + 经验
		经验数据.排行[self.数据.数字id].等级 = self.数据.等级
	end
end

function 角色处理类:取剧情技能等级(名称)
	local 等级 = 0

	for n = 1, #self.数据.剧情技能 do
		if self.数据.剧情技能[n].名称 == 名称 then
			等级 = self.数据.剧情技能[n].等级
		end
	end

	return 等级
end

function 角色处理类:添加剧情点(数额)
	self.数据.剧情点 = self.数据.剧情点 + 数额

	常规提示(self.数据.数字id, "#Y你获得了#R" .. 数额 .. "#Y点剧情点")
end

function 角色处理类:添加剧情点1()
	self.数据.剧情点 = self.数据.剧情点 + 1
end

function 角色处理类:添加剧情点5()
	self.数据.剧情点 = self.数据.剧情点 + 5
end

function 角色处理类:添加剧情点3()
	self.数据.剧情点 = self.数据.剧情点 + 3
end

function 角色处理类:添加剧情点20()
	self.数据.剧情点 = self.数据.剧情点 + 20
end

function 角色处理类:使用快捷技能(序列)
	if self.数据.快捷技能[序列] == nil then
		return
	end

	local 名称 = self.数据.快捷技能[序列].名称
	local 类型 = self.数据.快捷技能[序列].类型
	local 等级 = 0
	local id = self.数据.数字id

	if 类型 == 1 then
		for n = 1, #self.数据.师门技能 do
			for i = 1, #self.数据.师门技能[n].包含技能 do
				if self.数据.师门技能[n].包含技能[i].名称 == 名称 and self.数据.师门技能[n].包含技能[i].学会 then
					等级 = self.数据.师门技能[n].等级
				end
			end
		end
	elseif 类型 == 3 then
		for n = 1, #self.数据.剧情技能 do
			if self.数据.剧情技能[n].名称 == 名称 then
				等级 = self.数据.剧情技能[n].等级
			end
		end
	end

	if 等级 == 0 then
		return
	end

	local jns = 取法术技能(名称)

	if 类型 == 1 and 玩家数据[id].战斗 == 0 then
		if jns ~= nil and type(jns) == "table" and jns[3] == 0 then
			if 玩家数据[id].角色.数据.气血 < 10 or 玩家数据[id].角色.数据.魔法 < 10 then
				常规提示(id, "您的气血魔法不足！")

				return
			elseif 玩家数据[id].队伍 ~= 0 then
				常规提示(id, "组队状态下无法使用此功能！")

				return
			elseif 玩家数据[id].角色:取任务(300) ~= 0 then
				常规提示(id, "押镖任务中你飞个毛#24不怕天蓬元帅一耙子给你拍下来?#113")

				return
			elseif 玩家数据[id].角色.数据.地图数据.编号 >= 6010 and 玩家数据[id].角色.数据.地图数据.编号 <= 6019 then
				常规提示(id, "该地图无法传送")

				return
			end

			玩家数据[id].角色.数据.气血 = 玩家数据[id].角色.数据.气血 - 10
			玩家数据[id].角色.数据.魔法 = 玩家数据[id].角色.数据.魔法 - 10

			发送数据(玩家数据[id].连接id, 5506, {
				玩家数据[id].角色:取气血数据()
			})

			if 等级 >= 玩家数据[id].角色.数据.等级 - 5 then
				地图处理类:门派传送(id, 玩家数据[id].角色.数据.门派)
			elseif 取随机数(1, 玩家数据[id].角色.数据.等级 - 5) <= 等级 then
				地图处理类:门派传送(id, 玩家数据[id].角色.数据.门派)
			else
				常规提示(id, "使用技能失败！")

				return
			end
		elseif 名称 == "兵器谱" or 名称 == "堪察令" then
			道具刷新(id, 1)

			local 是否专用 = false

			if ygsj() <= 服务端参数.专用概率 then
				是否专用 = true
			end

			发送数据(玩家数据[id].连接id, 64, {
				类型 = "道具",
				等级 = 等级,
				名称 = 名称,
				道具 = 玩家数据[id].道具:索要道具1(id),
				专用 = 是否专用
			})
		elseif 名称 == "元阳护体" or 名称 == "穿云破空" or 名称 == "神木呓语" or 名称 == "嗜血" or 名称 == "莲华妙法" or 名称 == "轻如鸿毛" or 名称 == "拈花妙指" or 名称 == "盘丝舞" or 名称 == "一气化三清" or 名称 == "浩然正气" or 名称 == "龙附" or 名称 == "神兵护法" or 名称 == "魔王护持" or 名称 == "神力无穷" or 名称 == "尸气漫天" or 名称 == "担山赶月" then
			道具刷新(id, 1)
			发送数据(玩家数据[id].连接id, 65, {
				等级 = 等级,
				名称 = 名称,
				道具 = 玩家数据[id].道具:索要道具1(id)
			})
		end
	elseif 类型 == 3 and 玩家数据[id].战斗 == 0 then
		if 名称 == "仙灵店铺" then
			local 发送商品 = {}

			if 等级 == 1 then
				发送商品 = {
					"宠物口粮*500",
					"高级宠物口粮*2500",
					"包子*100",
					"飞行符*250",
					"摄妖香*250",
					"洞冥草*50",
					"天眼通符*8000"
				}
			elseif 等级 == 2 then
				发送商品 = {
					"宠物口粮*500",
					"高级宠物口粮*2500",
					"包子*100",
					"飞行符*250",
					"摄妖香*250",
					"洞冥草*50",
					"天眼通符*8000",
					"蓝色导标旗*5000",
					"黄色导标旗*5000",
					"红色导标旗*5000",
					"绿色导标旗*5000",
					"白色导标旗*5000"
				}
			elseif 等级 == 3 then
				发送商品 = {
					"宠物口粮*500",
					"高级宠物口粮*2500",
					"包子*100",
					"飞行符*250",
					"摄妖香*250",
					"洞冥草*50",
					"天眼通符*8000",
					"蓝色导标旗*5000",
					"黄色导标旗*5000",
					"红色导标旗*5000",
					"绿色导标旗*5000",
					"白色导标旗*5000",
					"金创药*4000",
					"佛光舍利子*30000"
				}
			elseif 等级 == 4 then
				发送商品 = {
					"宠物口粮*500",
					"高级宠物口粮*2500",
					"包子*100",
					"飞行符*250",
					"摄妖香*250",
					"洞冥草*50",
					"天眼通符*8000",
					"蓝色导标旗*5000",
					"黄色导标旗*5000",
					"红色导标旗*5000",
					"绿色导标旗*5000",
					"白色导标旗*5000",
					"金创药*4000",
					"佛光舍利子*30000",
					"秘制红罗羹*10000",
					"秘制绿罗羹*10000"
				}
			elseif 等级 == 5 then
				发送商品 = {
					"宠物口粮*500",
					"高级宠物口粮*2500",
					"包子*100",
					"飞行符*250",
					"摄妖香*250",
					"洞冥草*50",
					"天眼通符*8000",
					"蓝色导标旗*5000",
					"黄色导标旗*5000",
					"红色导标旗*5000",
					"绿色导标旗*5000",
					"白色导标旗*5000",
					"金创药*4000",
					"佛光舍利子*30000",
					"秘制红罗羹*10000",
					"秘制绿罗羹*10000",
					"空白强化符*5000",
					"乾坤袋*5000"
				}
			end

			玩家数据[id].商品列表 = 发送商品

			发送数据(玩家数据[id].连接id, 9, {
				名称 = "仙灵店铺",
				商品 = 发送商品,
				银子 = 玩家数据[id].角色.数据.银子
			})
		elseif 名称 == "调息 " then
			if 玩家数据[id].角色.数据.调息间隔 ~= nil and os.time() - 玩家数据[id].角色.数据.调息间隔 <= 180 then
				常规提示(id, "#Y/此技能使用的间隔时间为3分钟")

				return
			else
				玩家数据[id].角色.数据.调息间隔 = os.time()

				玩家数据[id].道具:加血处理(玩家数据[id].连接id, id, 等级 * 60, 0, "推拿")
			end
		elseif 名称 == "打坐" then
			if 玩家数据[id].角色.数据.打坐间隔 ~= nil and os.time() - 玩家数据[id].角色.数据.打坐间隔 <= 180 then
				常规提示(id, "#Y/此技能使用的间隔时间为3分钟")

				return
			else
				玩家数据[id].角色.数据.打坐间隔 = os.time()

				玩家数据[id].道具:加魔处理(玩家数据[id].连接id, id, 等级 * 30, 0, "推拿")
			end
		elseif 名称 == "飞行 " then
			if 玩家数据[id].角色.数据.坐骑 ~= nil and 玩家数据[id].角色.数据.坐骑.认证码 ~= nil then
				for i = 1, #玩家数据[id].角色.数据.坐骑列表 do
					if 玩家数据[id].角色.数据.坐骑列表[i].认证码 == 玩家数据[id].角色.数据.坐骑.认证码 then
						if 玩家数据[id].角色.数据.飞行中 == true then
							系统处理类:数据处理(id, 26.2, {
								序列 = i,
								数字id = id
							})

							break
						end

						系统处理类:数据处理(id, 26.1, {
							序列 = i,
							数字id = id
						})

						break
					end
				end
			else
				常规提示(id, "#Y/请先骑乘可以飞行的坐骑。")

				return
			end
		end
	end
end

function 角色处理类:设置快捷技能(数据)
	local 名称 = 数据.名称
	local 类型 = 数据.类型
	local 找到 = false

	if 类型 == 1 then
		for n = 1, #self.数据.师门技能 do
			for i = 1, #self.数据.师门技能[n].包含技能 do
				if self.数据.师门技能[n].包含技能[i].名称 == 名称 and self.数据.师门技能[n].包含技能[i].学会 then
					找到 = true
				end
			end
		end

		if 找到 == false then
			return
		end
	elseif 类型 == 3 then
		for n = 1, #self.数据.剧情技能 do
			if self.数据.剧情技能[n].名称 == 名称 then
				找到 = true
			end
		end

		if 找到 == false then
			return
		end
	end

	for n, v in pairs(self.数据.快捷技能) do
		if self.数据.快捷技能[n].名称 == 数据.名称 then
			self.数据.快捷技能[n] = nil
		end
	end

	self.数据.快捷技能[数据.位置] = {
		名称 = 数据.名称,
		类型 = 数据.类型
	}

	发送数据(玩家数据[self.数据.数字id].连接id, 42, self.数据.快捷技能)
end

function 角色处理类:取快捷技能(id)
	local x数据 = {}

	for n, v in pairs(self.数据.快捷技能) do
		if self.数据.快捷技能[n].名称 ~= nil then
			x数据[n] = {
				名称 = self.数据.快捷技能[n].名称,
				类型 = self.数据.快捷技能[n].类型
			}
		end
	end

	发送数据(玩家数据[id].连接id, 42, x数据)
end

function 角色处理类:添加属性点(数据, id)
	local 属性总和 = 0
	local 监控开关 = false

	for n = 1, #属性类型 do
		if 数据[属性类型[n]] < 0 or self.数据.潜力 < 数据[属性类型[n]] then
			监控开关 = true
		end

		属性总和 = 属性总和 + 数据[属性类型[n]]
	end

	if 监控开关 then
		return 0
	end

	if 属性总和 == 0 then
		常规提示(self.数据.数字id, "您到底是要添加哪种属性点呢？")

		return 0
	elseif self.数据.潜力 < 属性总和 then
		常规提示(self.数据.数字id, "你没有那么多可分配的属性点！")

		return 0
	else
		for n = 1, #属性类型 do
			self.数据[属性类型[n]] = self.数据[属性类型[n]] + 数据[属性类型[n]]
		end

		self.数据.潜力 = self.数据.潜力 - 属性总和

		self:刷新信息()
	end
end

function 角色处理类:快捷门派传送(id)
	local 临时数据 = {
		模型 = "男人_镖头",
		名称 = "新手门派传送人",
		对话 = "独自一人行走江湖可谓是凶多吉少,请少侠先加入一个门派吧。我可以帮你快速地传送到你想要去的门派哟。请选择你要进行传送的门派：",
		选项 = {
			"方寸山",
			"女儿村",
			"神木林",
			"化生寺",
			"大唐官府",
			"盘丝洞",
			"阴曹地府",
			"无底洞",
			"魔王寨",
			"狮驼岭",
			"天宫",
			"普陀山",
			"凌波城",
			"五庄观",
			"龙宫",
			"花果山",
			"九黎城"
		}
	}

	发送数据(id, 1501, 临时数据)
end

取可换乾元丹 = function(等级)
	if 等级 >= 171 then
		if 经脉限制开关 then
			return 9
		else
			return 21
		end
	elseif 等级 >= 168 then
		if 经脉限制开关 then
			return 9
		else
			return 20
		end
	elseif 等级 >= 164 then
		if 经脉限制开关 then
			return 9
		else
			return 18
		end
	elseif 等级 >= 159 then
		if 经脉限制开关 then
			return 8
		else
			return 16
		end
	elseif 等级 >= 155 then
		if 经脉限制开关 then
			return 7
		else
			return 14
		end
	elseif 等级 >= 129 then
		if 经脉限制开关 then
			return 6
		else
			return 12
		end
	elseif 等级 >= 109 then
		if 经脉限制开关 then
			return 5
		else
			return 10
		end
	elseif 等级 >= 89 then
		if 经脉限制开关 then
			return 4
		else
			return 8
		end
	elseif 等级 >= 69 then
		if 经脉限制开关 then
			return 3
		else
			return 6
		end
	elseif 等级 >= 59 then
		if 经脉限制开关 then
			return 2
		else
			return 4
		end
	elseif 等级 >= 49 then
		if 经脉限制开关 then
			return 1
		else
			return 2
		end
	else
		return 0
	end
end

function 角色处理类:保存加点方案(内容, id)
	local 编号 = 内容.编号
	local 方案 = 内容.方案

	if not 判断是否为空表(方案) then
		self.数据.加点方案 = {}
		local sx3 = {
			体质 = 1,
			力量 = 3,
			敏捷 = 5,
			耐力 = 4,
			魔力 = 2
		}

		for k, v in pairs(方案) do
			for i = 1, v do
				self.数据.加点方案[#self.数据.加点方案 + 1] = sx3[k]
			end
		end

		self.数据.加点方案.当前 = 1
		self.数据.加点文本 = 内容.文本
	end
end

function 角色处理类:升级处理(id, 系统, 内容)
	玩家数据[self.数据.数字id].角色.数据.对话类型 = nil

	if self.数据.帮派限时属性开关 == true then
		local 临时数据 = {
			模型 = "GM",
			名称 = "刻晴",
			对话 = "您现在有帮派福利加成,不可升级,是否取消帮派加成进行升级?",
			选项 = {
				"是的,我要取消帮派加成",
				"暂时还不想取消"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	end

	if self.数据.等级 == 10 and self.数据.门派 == "无门派" then
		local 内容 = self.数据.造型
		local 临时数据 = {
			模型 = "男人_镖头",
			名称 = "新手门派传送人",
			对话 = "独自一人行走江湖可谓是凶多吉少,请少侠先加入一个门派吧。我可以帮你快速地传送到你想要去的门派哟。请选择你要进行传送的门派：",
			选项 = {
				"方寸山",
				"女儿村",
				"神木林",
				"化生寺",
				"大唐官府",
				"盘丝洞",
				"阴曹地府",
				"无底洞",
				"魔王寨",
				"狮驼岭",
				"天宫",
				"普陀山",
				"凌波城",
				"五庄观",
				"龙宫",
				"花果山",
				"九黎城"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 20 and (成就数据[self.数据.数字id].商人鬼魂 == 0 or 成就数据[self.数据.数字id].商人鬼魂 == nil) and (管理账号列表[玩家数据[self.数据.数字id].账号] == nil or 管理升级无限制 ~= true) then
		成就数据[self.数据.数字id].商人鬼魂 = 0
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "你尚未完成#Y商人鬼魂#剧情线,#G无法升级",
			选项 = {
				"好的我知道了!"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 40 and (成就数据[self.数据.数字id].白鹿精 == 0 or 成就数据[self.数据.数字id].白鹿精 == nil) and (管理账号列表[玩家数据[self.数据.数字id].账号] == nil or 管理升级无限制 ~= true) then
		成就数据[self.数据.数字id].白鹿精 = 0
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "你尚未完成#Y白鹿精#剧情线,#G无法升级",
			选项 = {
				"好的我知道了!"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 60 and (成就数据[self.数据.数字id].酒肉和尚 == 0 or 成就数据[self.数据.数字id].酒肉和尚 == nil) and (管理账号列表[玩家数据[self.数据.数字id].账号] == nil or 管理升级无限制 ~= true) then
		成就数据[self.数据.数字id].酒肉和尚 = 0
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "你尚未完成#酒肉和尚#剧情线,#G无法升级",
			选项 = {
				"好的我知道了!"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 突破等级 and (成就数据[self.数据.数字id].突破任务 == 0 or 成就数据[self.数据.数字id].突破任务 == nil) then
		成就数据[self.数据.数字id].突破任务 = 0
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "你尚未完成#Y突破任务#,#G无法升级#,请到#S西凉女儿国#找#Z女儿国王#进行突破战斗！",
			选项 = {
				"好的我知道了!"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 20 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "如果完成了相应的剧情任务,就可以升级了,你确定要升级吗?",
			选项 = {
				"我已确认将等级提升至21",
				"不用了"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 40 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "如果完成了相应的剧情任务,就可以升级了,你确定要升级吗?",
			选项 = {
				"我已确认将等级提升至41",
				"不用了"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 60 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "如果完成了相应的剧情任务,就可以升级了,你确定要升级吗?",
			选项 = {
				"我已确认将等级提升至61",
				"不用了"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 69 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "是否确定将等级提升至70级吗?如果技能修炼没有完成推荐停69级哦~",
			选项 = {
				"我已确认将等级提升至70",
				"不用了"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 29 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		self:升级处理(id, 1)

		local 成就提示 = "等级达到30级"
		local 成就提示1 = "少侠不妨先加入一个帮派"

		发送数据(id, 149, {
			内容 = 成就提示,
			内容1 = 成就提示1
		})

		return
	elseif self.数据.等级 == 109 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "是否确定将等级提升至110级吗?",
			选项 = {
				"我已确认将等级提升至110",
				"我先清理下包裹"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 129 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "是否确定将等级提升至130级吗?",
			选项 = {
				"我已确认将等级提升至130",
				"我先清理下包裹"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	elseif self.数据.等级 == 138 and self.数据.最大经验 <= self.数据.当前经验 and 系统 == nil then
		local 临时数据 = {
			模型 = self.数据.模型,
			名称 = self.数据.名称,
			对话 = "是否确定将等级提升至139级吗?",
			选项 = {
				"我已确认将等级提升至139",
				"我先清理下包裹"
			}
		}

		发送数据(id, 1501, 临时数据)

		return
	end

	if self:等级上限(id) then
		if self.数据.当前经验 < self.数据.最大经验 then
			常规提示(self.数据.数字id, "你没有那么多的经验")

			return 0
		end

		self.数据.等级 = self.数据.等级 + 1
		self.数据.体质 = self.数据.体质 + 1
		self.数据.魔力 = self.数据.魔力 + 1
		self.数据.力量 = self.数据.力量 + 1
		self.数据.耐力 = self.数据.耐力 + 1
		self.数据.敏捷 = self.数据.敏捷 + 1
		self.数据.潜力 = self.数据.潜力 + 服务端参数.角色升级潜能点
		self.数据.最大体力 = self.数据.最大体力 + 10
		self.数据.最大活力 = self.数据.最大活力 + 10
		self.数据.当前经验 = self.数据.当前经验 - self.数据.最大经验

		if self.数据.自动加点 == true and self.数据.加点方案 ~= nil and not 判断是否为空表(self.数据.加点方案) and self.数据.潜力 > 0 then
			local sx = {
				"体质",
				"魔力",
				"力量",
				"耐力",
				"敏捷"
			}
			local aa = 0

			for i = 1, self.数据.潜力 do
				aa = self.数据.加点方案[self.数据.加点方案.当前]
				self.数据[sx[aa]] = self.数据[sx[aa]] + 1
				self.数据.加点方案.当前 = self.数据.加点方案.当前 + 1

				if self.数据.加点方案.当前 > 5 then
					self.数据.加点方案.当前 = 1
				end
			end

			self.数据.潜力 = 0
		end

		self:刷新信息("1")
		发送数据(id, 10, self:取总数据())
		发送数据(id, 11)
		地图处理类:加入动画(self.数据.数字id, self.数据.地图数据.编号, self.数据.地图数据.x, self.数据.地图数据.y, "升级")

		if self.数据.等级 == 25 then
			礼包奖励类:升级奖励25(self.数据.数字id)
		elseif self.数据.等级 == 35 then
			礼包奖励类:升级奖励35(self.数据.数字id)
		elseif self.数据.等级 == 45 then
			礼包奖励类:升级奖励45(self.数据.数字id)
		elseif self.数据.等级 == 55 then
			礼包奖励类:升级奖励55(self.数据.数字id)
		elseif self.数据.等级 == 65 then
			礼包奖励类:升级奖励65(self.数据.数字id)
		end
	end

	if self.数据.帮派数据 == nil then
		self.数据.帮派数据 = {
			权限 = 0
		}
	end

	if self.数据.帮派数据.编号 ~= nil then
		local 帮派编号 = self.数据.帮派数据.编号
		local id2 = self.数据.ID
		帮派数据[帮派编号].成员数据[id2].等级 = self.数据.等级
	end

	local 等级 = self.数据.等级

	if self.数据.等级 <= 120 then
		self.数据.修炼.攻击修炼[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.修炼.防御修炼[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.修炼.法术修炼[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.修炼.抗法修炼[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.修炼.猎术修炼[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.bb修炼.攻击控制力[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.bb修炼.防御控制力[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.bb修炼.法术控制力[3] = math.floor(取人物修炼等级上限(self.数据.等级))
		self.数据.bb修炼.抗法控制力[3] = math.floor(取人物修炼等级上限(self.数据.等级))
	end

	self.数据.装备属性.可换乾元丹 = 取可换乾元丹(self.数据.等级)

	if 等级 <= 50 and self.数据.新手银子 ~= nil then
		local 说明 = ""
		local 银子 = 0

		if self.数据.新手银子[等级] == nil then
			local 数值 = math.floor(等级 / 10) * 10000

			if 数值 < 10000 then
				数值 = 5000
			end

			银子 = 银子 + 数值
			说明 = 说明 .. "、" .. 等级 .. "-" .. 数值
		end

		if 等级 >= 50 then
			self.数据.新手银子 = nil
		end

		if 银子 > 0 and 吊游定制 == nil then
			self:添加银子(银子, 说明, 1)
		end
	end
end

function 角色处理类:取气血数据()
	if self.数据.最大气血 < self.数据.气血上限 then
		self.数据.气血上限 = self.数据.最大气血
	end

	if self.数据.气血上限 < self.数据.气血 then
		self.数据.气血 = self.数据.气血上限
	end

	return {
		气血 = self.数据.气血,
		气血上限 = self.数据.气血上限,
		最大气血 = self.数据.最大气血,
		魔法 = self.数据.魔法,
		最大魔法 = self.数据.最大魔法,
		愤怒 = self.数据.愤怒
	}
end

function 角色处理类:等级上限(id)
	self.初始上限 = 145

	if self.数据.剧情.飞升 == true and self.数据.飞升 == true then
		self.初始上限 = 155
	end

	if self.数据.剧情.渡劫 ~= nil and self.数据.剧情.渡劫 then
		self.初始上限 = 165
	end
	if self.数据.化圣 == 1 and self.数据.化圣 then
		self.初始上限 = 180
	end


	if self.初始上限 <= self.数据.等级 then
		常规提示(self.数据.数字id, "您的等级已经到达了上限,未飞升最高145,未渡劫最高155,未化圣最高165！")

		return false
	else
		return true
	end
end

function 角色处理类:取好友数据(id, 连接id, 序号)
	for n = 1, #self.数据.好友数据.好友 do
		if 玩家数据[self.数据.好友数据.好友[n].id] ~= nil and self.数据.好友数据.好友[n].好友度 ~= nil and self.数据.好友数据.好友[n].好友度 >= 10 then
			self.数据.好友数据.好友[n].在线 = nil

			for i = 1, #玩家数据[self.数据.好友数据.好友[n].id].角色.数据.好友数据.好友 do
				if 玩家数据[self.数据.好友数据.好友[n].id].角色.数据.好友数据.好友[i].id == id then
					self.数据.好友数据.好友[n].在线 = true
				end
			end
		else
			self.数据.好友数据.好友[n].在线 = nil
		end
	end

	发送数据(连接id, 序号, self.数据.好友数据)
end

添加储备修炼 = function(id, 数值)
	玩家数据[id].角色.数据.储备修炼 = (玩家数据[id].角色.数据.储备修炼 or 0) + 数值

	常规提示(id, format("#Y你的#S储备修炼#Y增加了#R%s#Y点、目前总储备#R%s#Y点。", 数值, 玩家数据[id].角色.数据.储备修炼))
end

扣除储备修炼 = function(id, 数值)
	if 数值 > (玩家数据[id].角色.数据.储备修炼 or 0) then
		return false
	else
		玩家数据[id].角色.数据.储备修炼 = (玩家数据[id].角色.数据.储备修炼 or 0) - 数值

		常规提示(id, format("#Y你的#S储备修炼#Y扣除了#R%s#Y点、目前总储备#R%s#Y点。", 数值, 玩家数据[id].角色.数据.储备修炼))

		return true
	end
end

function 角色处理类:添加人物修炼经验(id, 数值)
	if self.数据.修炼[self.数据.修炼.当前][3] <= self.数据.修炼[self.数据.修炼.当前][1] then
		常规提示(id, format("你的人物#R%s#Y已达到上限！", self.数据.修炼.当前))
		添加储备修炼(id, 数值)

		return
	end

	self.数据.修炼[self.数据.修炼.当前][2] = self.数据.修炼[self.数据.修炼.当前][2] + 数值

	常规提示(id, format("#W你的人物#Y%s经验#W增加了#R%s#W点", self.数据.修炼.当前, 数值))

	while 计算修炼等级经验(self.数据.修炼[self.数据.修炼.当前][1], self.数据.修炼[self.数据.修炼.当前][3]) <= self.数据.修炼[self.数据.修炼.当前][2] and self.数据.修炼[self.数据.修炼.当前][1] < self.数据.修炼[self.数据.修炼.当前][3] do
		self.数据.修炼[self.数据.修炼.当前][2] = self.数据.修炼[self.数据.修炼.当前][2] -
			计算修炼等级经验(self.数据.修炼[self.数据.修炼.当前][1], self.数据.修炼[self.数据.修炼.当前][3])
		self.数据.修炼[self.数据.修炼.当前][1] = self.数据.修炼[self.数据.修炼.当前][1] + 1

		常规提示(id, format("#W你的人物#Y%s#W等级提升至#R%s#W级", self.数据.修炼.当前, self.数据.修炼[self.数据.修炼.当前][1]))
	end

	刷新修炼数据(id)
end

function 角色处理类:帮派添加人物修炼经验(id, 数值, 类型)
	if self.数据.修炼[类型][3] <= self.数据.修炼[类型][1] then
		常规提示(id, format("你的人物#R%s#Y已达到上限！", 类型))

		return
	end

	self.数据.修炼[类型][2] = self.数据.修炼[类型][2] + 数值

	常规提示(id, format("#W你的人物#Y%s经验#W增加了#R%s#W点", 类型, 数值))

	while 计算修炼等级经验(self.数据.修炼[类型][1], self.数据.修炼[类型][3]) <= self.数据.修炼[类型][2] and self.数据.修炼[类型][1] < self.数据.修炼[类型][3] do
		self.数据.修炼[类型][2] = self.数据.修炼[类型][2] - 计算修炼等级经验(self.数据.修炼[类型][1], self.数据.修炼[类型][3])
		self.数据.修炼[类型][1] = self.数据.修炼[类型][1] + 1

		常规提示(id, format("#W你的人物#Y%s#W等级提升至#R%s#W级", 类型, self.数据.修炼[类型][1]))
	end

	刷新修炼数据(id)
end

function 角色处理类:添加bb修炼经验(id, 数值)
	if self.数据.bb修炼[self.数据.bb修炼.当前][3] <= self.数据.bb修炼[self.数据.bb修炼.当前][1] then
		常规提示(id, format("你的召唤兽#R%s#Y已达到上限！", self.数据.bb修炼.当前))

		return
	end

	self.数据.bb修炼[self.数据.bb修炼.当前][2] = self.数据.bb修炼[self.数据.bb修炼.当前][2] + 数值

	常规提示(id, format("#W你的召唤兽#Y%s经验#W增加了#R%s#W点", self.数据.bb修炼.当前, 数值))

	while 计算修炼等级经验(self.数据.bb修炼[self.数据.bb修炼.当前][1], self.数据.bb修炼[self.数据.bb修炼.当前][3]) <= self.数据.bb修炼[self.数据.bb修炼.当前][2] and self.数据.bb修炼[self.数据.bb修炼.当前][1] < self.数据.bb修炼[self.数据.bb修炼.当前][3] do
		self.数据.bb修炼[self.数据.bb修炼.当前][2] = self.数据.bb修炼[self.数据.bb修炼.当前][2] -
			计算修炼等级经验(self.数据.bb修炼[self.数据.bb修炼.当前][1], self.数据.bb修炼[self.数据.bb修炼.当前][3])
		self.数据.bb修炼[self.数据.bb修炼.当前][1] = self.数据.bb修炼[self.数据.bb修炼.当前][1] + 1

		常规提示(id, format("#W你的召唤兽#Y%s#W等级提升至#R%s#W级", self.数据.bb修炼.当前, self.数据.bb修炼[self.数据.bb修炼.当前][1]))
	end

	刷新修炼数据(id)
end

function 角色处理类:取法宝格子()
	for n = 1, 100 do
		if self.数据.法宝[n] == nil then
			return n
		end
	end

	return 0
end

function 角色处理类:取超级行囊格子(类型)
	if self.数据.超级行囊 == nil then
		self.数据.超级行囊 = {}
	end

	if self.数据.超级行囊[类型] == nil then
		self.数据.超级行囊[类型] = {}
	end

	for n = 1, 超级行囊格子数 do
		if self.数据.超级行囊[类型][n] == nil then
			return n
		end
	end

	return 0
end

function 角色处理类:取道具格子()
	for n = 1, 100 do
		if self.数据.道具[n] == nil then
			return n
		end
	end

	return 0
end

function 角色处理类:取道具格子2()
	local 数量 = 0

	for n = 1, 100 do
		if self.数据.道具[n] == nil then
			数量 = 数量 + 1
		end
	end

	return 数量
end

function 角色处理类:取道具格子1(类型)
	local num = 100

	if 类型 == "行囊" then
		num = 20
	end

	for n = 1, num do
		if self.数据[类型][n] == nil then
			return n
		end
	end

	return 0
end

function 角色处理类:强化技能消耗(等级, 名称)
	local 经验 = 5000000 * (1 + 等级 / 10)
	local 银子 = 2000000 * (1 + 等级 / 10)

	if 角色强化技能列表1[名称] ~= nil then
		银子 = 3000000 * (1 + 等级 / 10)
	elseif 等级 <= 10 then
		银子 = 银子 * 0.1
		经验 = 经验 * 0.1
	elseif 等级 >= 51 then
		银子 = 银子 * 5
		经验 = 经验 * 5
	end

	return {
		经验 = 经验,
		金钱 = 银子
	}
end

取帮贡 = function(id)
	if 是否有帮派(id) then
		玩家数据[id].角色.数据.帮贡 = 帮派数据[玩家数据[id].角色.数据.帮派数据.编号].成员数据[id].帮贡.当前 or 0

		return 玩家数据[id].角色.数据.帮贡
	else
		return 0
	end
end

GM添加点卡 = function(id, 数额)
	local 账号 = 玩家数据[id].账号
	local 点卡 = f函数.读配置(程序目录 .. "data\\" .. 账号 .. "\\账号信息.txt", "账号配置", "点卡")

	if tonumber(点卡) == nil then
		点卡 = 0
	end

	点卡 = 点卡 + 数额

	f函数.写配置(程序目录 .. "data\\" .. 账号 .. "\\账号信息.txt", "账号配置", "点卡", 点卡)
	常规提示(id, "#Y获得了#R" .. 数额 .. "#Y点点卡")
end

全服添加点卡 = function(数额)
	for k, v in pairs(玩家数据) do
		local id = k
		local 账号 = v.账号
		local 点卡 = f函数.读配置(程序目录 .. "data\\" .. 账号 .. "\\账号信息.txt", "账号配置", "点卡")

		if tonumber(点卡) == nil then
			点卡 = 0
		end

		点卡 = 点卡 + 数额

		f函数.写配置(程序目录 .. "data\\" .. 账号 .. "\\账号信息.txt", "账号配置", "点卡", 点卡)
		常规提示(id, "#Y获得了#R" .. 数额 .. "#Y点点卡")
	end
end

添加帮贡 = function(id, 数额)
	if 是否有帮派(id) then
		local 帮派编号 = 玩家数据[id].角色.数据.帮派数据.编号
		帮派数据[帮派编号].成员数据[id].帮贡.当前 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 + 数额
		帮派数据[帮派编号].成员数据[id].帮贡.上限 = 帮派数据[帮派编号].成员数据[id].帮贡.上限 + 数额
		玩家数据[id].角色.数据.帮贡 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 or 0

		常规提示(id, "你获得了#R" .. 数额 .. "#Y点帮贡、剩余帮贡#R" .. 玩家数据[id].角色.数据.帮贡 .. "#Y点")

		return true
	else
		常规提示(id, "你没有帮派。")

		return false
	end
end

扣除帮贡 = function(id, 数额)
	if 是否有帮派(id) then
		local 帮派编号 = 玩家数据[id].角色.数据.帮派数据.编号

		if 数额 <= 帮派数据[帮派编号].成员数据[id].帮贡.当前 then
			帮派数据[帮派编号].成员数据[id].帮贡.当前 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 - 数额
			玩家数据[id].角色.数据.帮贡 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 or 0

			常规提示(id, "你失去了#R" .. 数额 .. "#Y点帮贡、剩余帮贡#R" .. 玩家数据[id].角色.数据.帮贡 .. "#Y点")

			return true
		end
	end

	return false
end

助战学习技能扣除金钱 = function(id, 数额, 扣除)
	local 资产 = 0
	local 仅储备 = true

	if 玩家数据[id].角色.数据.助战消耗银两 == true then
		资产 = 取储备加银两(id)
		仅储备 = false
	else
		资产 = 玩家数据[id].角色.数据.储备
	end

	if 资产 < 数额 then
		return false
	end

	if 扣除 == nil then
		return true
	elseif 仅储备 then
		return 玩家数据[id].角色:扣除储备(数额, "助战学习技能消耗")
	else
		return 玩家数据[id].角色:扣除储备和银子(数额, "助战学习技能消耗")
	end
end

取储备加银两 = function(id)
	return 玩家数据[id].角色.数据.储备 + 玩家数据[id].角色.数据.银子
end

function 角色处理类:学习生活技能(连接id, id, 编号)
	if self.数据.辅助技能[编号] == 0 then
		常规提示(id, "你没有这样的技能")

		return
	end

	local 已学等级 = 0
	local 总消耗 = {
		经验 = 0,
		银子 = 0,
		储备 = 0
	}

	for i = 1, self.数据.辅助技能学习次数 do
		if self.数据.辅助技能[编号].名称 == "神速" or self.数据.辅助技能[编号].名称 == "强壮" then
			if 强壮神速最高等级 <= self.数据.辅助技能[编号].等级 then
				常规提示(id, "你这个技能已经升到满级了")

				break
			elseif self.数据.等级 < self.数据.辅助技能[编号].等级 * 3 then
				常规提示(id, "学习失败、该技能等级不能超过【自身等级÷3】")

				break
			end
		elseif self.数据.辅助技能[编号].等级 >= 40 and self.数据.辅助技能[编号].名称 ~= "养生之道" and self.数据.辅助技能[编号].名称 ~= "健身术" then
			常规提示(id, "该技能在此只能学习到40级\n剩下的需要去#G帮派学习#哦!")

			break
		elseif self.数据.辅助技能[编号].等级 >= self.数据.等级 + 50 then
			常规提示(id, "学习失败、辅助技能等级不能超过自身等级+50")

			break
		elseif 辅助强化技能最高等级 <= self.数据.辅助技能[编号].等级 then
			常规提示(id, "该技能在此只能学习到" .. 辅助强化技能最高等级 .. "级!")

			break
		end

		local 临时消耗 = 取生活技能消耗(self.数据.辅助技能[编号].等级 + 1)

		if self.数据.辅助技能[编号].名称 == "强壮" or self.数据.辅助技能[编号].名称 == "神速" then
			临时消耗 = 取生活技能消耗((self.数据.辅助技能[编号].等级 + 1) * 3)
		end

		if self.数据.当前经验 < 临时消耗.经验 then
			常规提示(id, "你没有那么多的经验")

			break
		end

		local 提示 = ""

		if 临时消耗.金钱 <= self.数据.储备 then
			self.数据.储备 = self.数据.储备 - 临时消耗.金钱
			总消耗.储备 = 总消耗.储备 + 临时消耗.金钱

			常规提示(id, format("#S(学习辅助技能)#Y你花费了#R%s#Y点经验、#R%s#Y储备", 数字转简(临时消耗.经验), 数字转简(临时消耗.金钱)))
		elseif 临时消耗.金钱 <= self.数据.储备 + self.数据.银子 then
			临时消耗.金钱 = 临时消耗.金钱 - self.数据.储备
			总消耗.储备 = 总消耗.储备 + self.数据.储备
			总消耗.银子 = 总消耗.银子 + 临时消耗.金钱
			self.数据.银子 = self.数据.银子 - 临时消耗.金钱

			常规提示(id,
				format("#S(学习辅助技能)#Y你花费了#R%s#Y点经验、#R%s#Y储备、#R%s#Y银两", 数字转简(临时消耗.经验), 数字转简(self.数据.储备), 数字转简(临时消耗.金钱)))

			self.数据.储备 = 0
		else
			常规提示(id, "你没有那么多的银子")

			break
		end

		self.数据.当前经验 = self.数据.当前经验 - 临时消耗.经验
		总消耗.经验 = 总消耗.经验 + 临时消耗.经验
		self.数据.辅助技能[编号].等级 = self.数据.辅助技能[编号].等级 + 1
		已学等级 = 已学等级 + 1
	end

	if 已学等级 > 0 then
		self:日志记录("学习" ..
			已学等级 ..
			"次生活技能[" ..
			self.数据.辅助技能[编号].名称 .. "]消耗" .. 数字转简(总消耗.经验) .. "点经验、" .. 数字转简(总消耗.储备) .. "点储备、" .. 数字转简(总消耗.银子) .. "两银子")
		self:银子记录()
		发送数据(连接id, 34, {
			序列 = 编号,
			等级 = self.数据.辅助技能[编号].等级
		})
		刷新货币(连接id, id)

		local 名称 = self.数据.辅助技能[编号].名称

		if 名称 == "强身术" or 名称 == "健身术" or 名称 == "冥想" or 名称 == "养生之道" or 名称 == "强壮" or 名称 == "神速" then
			self:刷新信息(1)
			发送数据(连接id, 31, 玩家数据[id].角色:取总数据(1))
		end
	end
end

function 角色处理类:学习强化技能(连接id, id, 编号)
	if self.数据.强化技能[编号] == nil then
		常规提示(id, "你没有这样的技能")

		return
	elseif not 强化技能开关 then
		常规提示(id, "当前服务器未开启强化技能学习。")

		return
	end

	local 已学等级 = 0
	local 总消耗 = {
		经验 = 0,
		银子 = 0,
		储备 = 0
	}

	for i = 1, self.数据.辅助技能学习次数 do
		if self.数据.强化技能[编号].等级 >= self.数据.等级 + 50 then
			常规提示(id, "学习失败、强化技能等级不能超过自身等级+50")

			break
		elseif 辅助强化技能最高等级 <= self.数据.强化技能[编号].等级 then
			常规提示(id, "学习失败、强化技能等级不能超过" .. 辅助强化技能最高等级 .. "级")

			break
		end

		local 临时消耗 = {}

		if self.数据.强化技能[编号].等级 < 40 then
			临时消耗 = 取生活技能消耗(self.数据.强化技能[编号].等级 + 1)
		else
			临时消耗 = 取生活技能消耗(self.数据.强化技能[编号].等级 + 1, "消耗帮贡")
		end

		临时消耗.经验 = 临时消耗.经验 * 强化技能消耗倍率
		临时消耗.金钱 = 临时消耗.金钱 * 强化技能消耗倍率

		if self.数据.当前经验 < 临时消耗.经验 then
			常规提示(id, "你没有那么多的经验")

			break
		elseif self.数据.储备 + self.数据.银子 < 临时消耗.金钱 then
			常规提示(id, "你没有那么多的储备和银子")

			break
		elseif 临时消耗.帮贡 ~= nil and 扣除帮贡(id, 临时消耗.帮贡) == false then
			常规提示(id, "你的帮贡不足#R" .. 临时消耗.帮贡)

			break
		end

		self:扣除储备和银子(临时消耗.金钱, "学习强化技能[" .. self.数据.强化技能[编号].名称 .. "]消耗")
		常规提示(id, format("#S(学习强化技能)#Y你花费了#R%s#Y点经验", 数字转简(临时消耗.经验)))

		self.数据.当前经验 = self.数据.当前经验 - 临时消耗.经验
		已学等级 = 已学等级 + 1
		总消耗.经验 = 总消耗.经验 + 临时消耗.经验
		self.数据.强化技能[编号].等级 = self.数据.强化技能[编号].等级 + 1
	end

	if 已学等级 > 0 then
		发送数据(连接id, 34.1, {
			序列 = 编号,
			等级 = self.数据.强化技能[编号].等级
		})
		self:日志记录("学习" .. 已学等级 .. "次强化技能[" .. self.数据.强化技能[编号].名称 .. "]消耗" .. 数字转简(总消耗.经验) .. "点经验")
		刷新货币(连接id, id)
		self:刷新信息(1)
		发送数据(连接id, 31, 玩家数据[id].角色:取总数据(1))
	end
end

function 角色处理类:帮派学习生活技能(连接id, id, 编号, 次数)
	if self.数据.辅助技能[编号] == 0 then
		常规提示(id, "你没有这样的技能")

		return
	end

	次数 = 次数 or 1
	已学等级 = 0

	for i = 1, 次数 do
		if self.数据.辅助技能[编号].等级 >= 160 then
			常规提示(id, "你这个技能已经升到满级了")

			break
		elseif self.数据.辅助技能[编号].名称 == "神速" or self.数据.辅助技能[编号].名称 == "强壮" then
			if 强壮神速最高等级 <= self.数据.辅助技能[编号].等级 then
				常规提示(id, "你这个技能已经升到满级了")

				break
			elseif self.数据.等级 < self.数据.辅助技能[编号].等级 * 3 then
				常规提示(id, "学习失败、该技能等级不能超过【自身等级÷3】")

				break
			end
		elseif self.数据.辅助技能[编号].等级 >= self.数据.等级 + 50 and (self.数据.辅助技能[编号].名称 == "暗器技巧" or self.数据.辅助技能[编号].名称 == "冥想" or self.数据.辅助技能[编号].名称 == "强身术") then
			常规提示(id, "学习失败、该技能等级不能超过自身等级+50")

			break
		end

		local 临时消耗 = 取生活技能消耗(self.数据.辅助技能[编号].等级 + 1, "消耗帮贡")

		if self.数据.辅助技能[编号].名称 == "强壮" or self.数据.辅助技能[编号].名称 == "神速" then
			临时消耗 = 取生活技能消耗((self.数据.辅助技能[编号].等级 + 1) * 3, "消耗帮贡")
		end

		if self.数据.当前经验 < 临时消耗.经验 then
			常规提示(id, "你没有那么多的经验")

			break
		elseif 取储备加银两(id) < 临时消耗.金钱 then
			常规提示(id, "你没有那么多的储备和银子")

			break
		end

		local 帮派编号 = 玩家数据[id].角色.数据.帮派数据.编号
		local 帮派规模 = 帮派数据[帮派编号].帮派规模

		if (self.数据.辅助技能[编号].名称 == "强壮" or self.数据.辅助技能[编号].名称 == "神速") and 帮派规模 <= 2 then
			常规提示(id, "你当前的#R帮派的规模#无法让你学习强壮和神速")

			break
		end

		local 帮派编号 = 玩家数据[id].角色.数据.帮派数据.编号
		local 等级上限 = 帮派数据[帮派编号].技能数据[self.数据.辅助技能[编号].名称].当前

		if 等级上限 <= self.数据.辅助技能[编号].等级 then
			常规提示(id, "你当前生活技能等级已达帮派所研究的等级上限")

			break
		end

		local 当前帮贡 = 帮派数据[帮派编号].成员数据[id].帮贡.当前 or 0
		local 帮贡上限 = 帮派数据[帮派编号].成员数据[id].帮贡.上限 or 0
		local 学习消耗 = 临时消耗.帮贡

		if 帮贡上限 < 临时消耗.需求 then
			常规提示(id, "学习该技能需要#R" .. 临时消耗.需求 .. "#Y点帮贡上限,你当前的帮贡上限为#R" .. 帮贡上限 .. "#Y。")

			break
		end

		if 当前帮贡 < 学习消耗 then
			常规提示(id, "你的帮贡不足#R" .. 学习消耗)

			break
		end

		self:扣除储备和银子(临时消耗.金钱, "学习辅助技能[" .. self.数据.辅助技能[编号].名称 .. "]消耗")

		self.数据.当前经验 = self.数据.当前经验 - 临时消耗.经验

		self:日志记录("学习生活技能[" .. self.数据.辅助技能[编号].名称 .. "]消耗" .. 数字转简(临时消耗.经验) .. "点经验")
		扣除帮贡(id, 临时消耗.帮贡)

		self.数据.辅助技能[编号].等级 = self.数据.辅助技能[编号].等级 + 1
		已学等级 = 已学等级 + 1
	end

	if 已学等级 > 0 then
		self:银子记录()
		发送数据(连接id, 34, {
			序列 = 编号,
			等级 = self.数据.辅助技能[编号].等级
		})
		刷新货币(连接id, id)

		local 名称 = self.数据.辅助技能[编号].名称

		if 名称 == "强身术" or 名称 == "健身术" or 名称 == "冥想" or 名称 == "养生之道" or 名称 == "强壮" or 名称 == "神速" then
			self:刷新信息(1)
			发送数据(连接id, 31, 玩家数据[id].角色:取总数据(1))
		end
	end
end

function 角色处理类:学习剧情技能(id, 名称, 消耗, 上限)
	if self.数据.剧情点 < 消耗 then
		常规提示(id, "你的剧情点不够哟")

		return
	end

	local 编号 = 0

	for n = 1, #self.数据.剧情技能 do
		if self.数据.剧情技能[n].名称 == 名称 then
			编号 = n
		end
	end

	if 编号 ~= 0 then
		if 上限 <= self.数据.剧情技能[编号].等级 then
			常规提示(id, "你的这项技能等级已达上限")

			return
		end
	else
		self.数据.剧情技能[#self.数据.剧情技能 + 1] = {
			等级 = 0,
			名称 = 名称
		}
		编号 = #self.数据.剧情技能
	end

	self.数据.剧情点 = self.数据.剧情点 - 消耗
	self.数据.剧情技能[编号].等级 = self.数据.剧情技能[编号].等级 + 1

	常规提示(id, "#Y/你的剧情点减少了" .. 消耗 .. "点")
	常规提示(id, "你的" .. 名称 .. "等级提升至" .. self.数据.剧情技能[编号].等级 .. "级")
end

function 角色处理类:取门派基础技能(id, 门派)
	local 门派基础技能 = ""

	if 门派 == "大唐官府" then
		门派基础技能 = "为官之道"
	elseif 门派 == "方寸山" then
		门派基础技能 = "黄庭经"
	elseif 门派 == "化生寺" then
		门派基础技能 = "小乘佛法"
	elseif 门派 == "女儿村" then
		门派基础技能 = "毒经"
	elseif 门派 == "阴曹地府" then
		门派基础技能 = "灵通术"
	elseif 门派 == "魔王寨" then
		门派基础技能 = "牛逼神功"
	elseif 门派 == "狮驼岭" then
		门派基础技能 = "魔兽神功"
	elseif 门派 == "盘丝洞" then
		门派基础技能 = "蛛丝阵法"
	elseif 门派 == "天宫" then
		门派基础技能 = "天罡气"
	elseif 门派 == "五庄观" then
		门派基础技能 = "周易学"
	elseif 门派 == "龙宫" then
		门派基础技能 = "九龙诀"
	elseif 门派 == "普陀山" then
		门派基础技能 = "金刚经"
	elseif 门派 == "神木林" then
		门派基础技能 = "瞬息万变"
	elseif 门派 == "凌波城" then
		门派基础技能 = "天地无极"
	elseif 门派 == "无底洞" then
		门派基础技能 = "枯骨心法"
	elseif 门派 == "女魃墓" then
		门派基础技能 = "天火献誓"
	elseif 门派 == "天机城" then
		门派基础技能 = "神工无形"
	elseif 门派 == "花果山" then
		门派基础技能 = "神通广大"
	elseif 门派 == "九黎城" then
		门派基础技能 = "九黎战歌"
	end

	for i = 1, #self.数据.师门技能 do
		if self.数据.师门技能[i].名称 == 门派基础技能 then
			return {
				编号 = i,
				基础技能 = self.数据.师门技能[i].名称
			}
		end
	end
end

function 角色处理类:学习门派技能(连接id, id, 编号, 学习等级)
	if self.数据.师门技能[编号] == nil then
		常规提示(id, "你没有这样的技能")

		return
	elseif self.数据.师门技能[编号].等级 >= self.数据.等级 + 10 then
		常规提示(id, "门派技能不能超过角色等级+10")

		return
	elseif 师门技能上限等级 <= self.数据.师门技能[编号].等级 then
		常规提示(id, "门派技能不能超过" .. 师门技能上限等级 .. "级")

		return
	else
		local 基础等级 = self.数据.师门技能[self:取门派基础技能(id, self.数据.门派).编号].等级

		if 基础等级 <= self.数据.师门技能[编号].等级 + 学习等级 and 编号 ~= self:取门派基础技能(id, self.数据.门派).编号 then
			if 基础等级 <= self.数据.师门技能[编号].等级 then
				常规提示(id, "请先提升门派基础技能" .. self:取门派基础技能(id, self.数据.门派).基础技能)

				return
			else
				学习等级 = 基础等级 - self.数据.师门技能[编号].等级
			end
		end

		local 技能提升等级 = 0

		if self.数据.师门技能[编号].等级 + 学习等级 <= math.min(self.数据.等级 + 10, 师门技能上限等级) then
			技能提升等级 = 学习等级
		else
			技能提升等级 = math.min(self.数据.等级 + 10, 师门技能上限等级) - self.数据.师门技能[编号].等级
		end

		local 临时消耗 = {
			经验 = 0,
			金钱 = 0
		}

		for i = 1, 技能提升等级 do
			if self.数据.当前经验 < 临时消耗.经验 + 技能消耗.经验[self.数据.师门技能[编号].等级 + i] then
				技能提升等级 = i - 1

				break
			end

			临时消耗.经验 = 临时消耗.经验 + 技能消耗.经验[self.数据.师门技能[编号].等级 + i]
			临时消耗.金钱 = 临时消耗.金钱 + 技能消耗.金钱[self.数据.师门技能[编号].等级 + i]
		end

		if 技能提升等级 == 0 then
			常规提示(id, "学习技能失败、你的经验不足#R" .. 数字转简(技能消耗.经验[self.数据.师门技能[编号].等级 + 1]) .. "#Y点")

			return
		end

		if 临时消耗.金钱 <= self.数据.储备 + self.数据.银子 then
			self:扣除储备和银子(临时消耗.金钱, "师门技能")
		else
			常规提示(id, "你没有那么多的银子")

			return
		end

		self.数据.当前经验 = self.数据.当前经验 - 临时消耗.经验

		发送数据(玩家数据[self.数据.数字id].连接id, 38, {
			内容 = "你消耗了" .. 数字转简(临时消耗.经验) .. "点经验",
			金钱 = 临时消耗.金钱,
			经验 = 临时消耗.经验
		})
		self:日志记录("学习师门技能[" .. self.数据.师门技能[编号].名称 .. "]消耗" .. 数字转简(临时消耗.金钱) .. "点金钱和 " .. 数字转简(临时消耗.经验) .. "点经验")
		self:银子记录()

		self.数据.师门技能[编号].等级 = self.数据.师门技能[编号].等级 + 技能提升等级

		角色升级门派技能(self.数据, self.数据.师门技能[编号])
		发送数据(连接id, 31, 玩家数据[id].角色:取总数据(1))
		刷新货币(连接id, id)
	end
end

退出门派返还计算 = function(角色数据)
	local 返还经验 = 0
	local 返还储备 = 0

	for i = 1, #角色数据.师门技能 do
		if 角色数据.师门技能[i].等级 ~= nil and 角色数据.师门技能[i].等级 > 0 then
			for i = 1, 角色数据.师门技能[i].等级 do
				返还经验 = 返还经验 + 技能消耗.经验[i]
				返还储备 = 返还储备 + 技能消耗.金钱[i]
			end
		end
	end

	return {
		经验 = qz(返还经验 * 退出门派返还比例 / 100),
		金钱 = qz(返还储备 * 退出门派返还比例 / 100)
	}
end

function 角色处理类:银子记录()
	self:日志记录(self.数据.当前经验 .. "点经验、" .. self.数据.储备 .. "点储备、" .. self.数据.银子 .. "两银子、" .. self.数据.存银 .. "两存银")
end

function 角色处理类:师门技能消耗(目标技能等级)
	local 等级 = 目标技能等级
	local 技能消耗 = {
		{
			经验 = 16,
			金钱 = 6
		},
		{
			经验 = 32,
			金钱 = 12
		},
		{
			经验 = 52,
			金钱 = 19
		},
		{
			经验 = 75,
			金钱 = 28
		},
		{
			经验 = 103,
			金钱 = 38
		},
		{
			经验 = 136,
			金钱 = 51
		},
		{
			经验 = 179,
			金钱 = 67
		},
		{
			经验 = 231,
			金钱 = 86
		},
		{
			经验 = 295,
			金钱 = 110
		},
		{
			经验 = 372,
			金钱 = 139
		},
		{
			经验 = 466,
			金钱 = 174
		},
		{
			经验 = 578,
			金钱 = 216
		},
		{
			经验 = 711,
			金钱 = 266
		},
		{
			经验 = 867,
			金钱 = 325
		},
		{
			经验 = 1049,
			金钱 = 393
		},
		{
			经验 = 1260,
			金钱 = 472
		},
		{
			经验 = 1503,
			金钱 = 563
		},
		{
			经验 = 1780,
			金钱 = 667
		},
		{
			经验 = 2096,
			金钱 = 786
		},
		{
			经验 = 2452,
			金钱 = 919
		},
		{
			经验 = 2854,
			金钱 = 1070
		},
		{
			经验 = 3304,
			金钱 = 1238
		},
		{
			经验 = 3807,
			金钱 = 1426
		},
		{
			经验 = 4364,
			金钱 = 1636
		},
		{
			经验 = 4983,
			金钱 = 1868
		},
		{
			经验 = 5664,
			金钱 = 2124
		},
		{
			经验 = 6415,
			金钱 = 2404
		},
		{
			经验 = 7238,
			金钱 = 2714
		},
		{
			经验 = 8138,
			金钱 = 3050
		},
		{
			经验 = 9120,
			金钱 = 3420
		},
		{
			经验 = 10188,
			金钱 = 3820
		},
		{
			经验 = 11347,
			金钱 = 4255
		},
		{
			经验 = 12602,
			金钱 = 4725
		},
		{
			经验 = 13959,
			金钱 = 5234
		},
		{
			经验 = 15423,
			金钱 = 5783
		},
		{
			经验 = 16998,
			金钱 = 6374
		},
		{
			经验 = 18692,
			金钱 = 7009
		},
		{
			经验 = 20508,
			金钱 = 7690
		},
		{
			经验 = 22452,
			金钱 = 8419
		},
		{
			经验 = 24532,
			金钱 = 9199
		},
		{
			经验 = 26753,
			金钱 = 10032
		},
		{
			经验 = 29121,
			金钱 = 10920
		},
		{
			经验 = 31642,
			金钱 = 11865
		},
		{
			经验 = 34323,
			金钱 = 12871
		},
		{
			经验 = 37169,
			金钱 = 13938
		},
		{
			经验 = 40188,
			金钱 = 15070
		},
		{
			经验 = 43388,
			金钱 = 16270
		},
		{
			经验 = 46773,
			金钱 = 17540
		},
		{
			经验 = 50352,
			金钱 = 18882
		},
		{
			经验 = 54132,
			金钱 = 20299
		},
		{
			经验 = 58120,
			金钱 = 21795
		},
		{
			经验 = 62324,
			金钱 = 23371
		},
		{
			经验 = 66750,
			金钱 = 25031
		},
		{
			经验 = 71407,
			金钱 = 26777
		},
		{
			经验 = 76303,
			金钱 = 28613
		},
		{
			经验 = 81444,
			金钱 = 30541
		},
		{
			经验 = 86840,
			金钱 = 32565
		},
		{
			经验 = 92500,
			金钱 = 34687
		},
		{
			经验 = 98430,
			金钱 = 36911
		},
		{
			经验 = 104640,
			金钱 = 39240
		},
		{
			经验 = 111136,
			金钱 = 41676
		},
		{
			经验 = 117931,
			金钱 = 44224
		},
		{
			经验 = 125031,
			金钱 = 46886
		},
		{
			经验 = 132444,
			金钱 = 49666
		},
		{
			经验 = 140183,
			金钱 = 52568
		},
		{
			经验 = 148253,
			金钱 = 55595
		},
		{
			经验 = 156666,
			金钱 = 58749
		},
		{
			经验 = 165430,
			金钱 = 62036
		},
		{
			经验 = 174556,
			金钱 = 65458
		},
		{
			经验 = 184052,
			金钱 = 69019
		},
		{
			经验 = 193930,
			金钱 = 72723
		},
		{
			经验 = 204198,
			金钱 = 76574
		},
		{
			经验 = 214868,
			金钱 = 80575
		},
		{
			经验 = 225948,
			金钱 = 84730
		},
		{
			经验 = 237449,
			金钱 = 89043
		},
		{
			经验 = 249383,
			金钱 = 93518
		},
		{
			经验 = 261760,
			金钱 = 98160
		},
		{
			经验 = 274589,
			金钱 = 102971
		},
		{
			经验 = 287884,
			金钱 = 107956
		},
		{
			经验 = 301652,
			金钱 = 113119
		},
		{
			经验 = 315908,
			金钱 = 118465
		},
		{
			经验 = 330662,
			金钱 = 123998
		},
		{
			经验 = 345924,
			金钱 = 129721
		},
		{
			经验 = 361708,
			金钱 = 135640
		},
		{
			经验 = 378023,
			金钱 = 141758
		},
		{
			经验 = 394882,
			金钱 = 148080
		},
		{
			经验 = 412297,
			金钱 = 154611
		},
		{
			经验 = 430280,
			金钱 = 161355
		},
		{
			经验 = 448844,
			金钱 = 168316
		},
		{
			经验 = 468000,
			金钱 = 175500
		},
		{
			经验 = 487760,
			金钱 = 182910
		},
		{
			经验 = 508137,
			金钱 = 190551
		},
		{
			经验 = 529145,
			金钱 = 198429
		},
		{
			经验 = 550796,
			金钱 = 206548
		},
		{
			经验 = 573103,
			金钱 = 214913
		},
		{
			经验 = 596078,
			金钱 = 223529
		},
		{
			经验 = 619735,
			金钱 = 232400
		},
		{
			经验 = 644088,
			金钱 = 241533
		},
		{
			经验 = 669149,
			金钱 = 250931
		},
		{
			经验 = 694932,
			金钱 = 260599
		},
		{
			经验 = 721452,
			金钱 = 270544
		},
		{
			经验 = 748722,
			金钱 = 280770
		},
		{
			经验 = 776755,
			金钱 = 291283
		},
		{
			经验 = 805566,
			金钱 = 302087
		},
		{
			经验 = 835169,
			金钱 = 313188
		},
		{
			经验 = 865579,
			金钱 = 324592
		},
		{
			经验 = 896809,
			金钱 = 336303
		},
		{
			经验 = 928876,
			金钱 = 348328
		},
		{
			经验 = 961792,
			金钱 = 360672
		},
		{
			经验 = 995572,
			金钱 = 373339
		},
		{
			经验 = 1030234,
			金钱 = 386337
		},
		{
			经验 = 1065190,
			金钱 = 399671
		},
		{
			经验 = 1102256,
			金钱 = 413346
		},
		{
			经验 = 1139649,
			金钱 = 427368
		},
		{
			经验 = 1177983,
			金钱 = 441743
		},
		{
			经验 = 1217273,
			金钱 = 456477
		},
		{
			经验 = 1256104,
			金钱 = 471576
		},
		{
			经验 = 1298787,
			金钱 = 487045
		},
		{
			经验 = 1341043,
			金钱 = 502891
		},
		{
			经验 = 1384320,
			金钱 = 519120
		},
		{
			经验 = 1428632,
			金钱 = 535737
		},
		{
			经验 = 1473999,
			金钱 = 552749
		},
		{
			经验 = 1520435,
			金钱 = 570163
		},
		{
			经验 = 1567957,
			金钱 = 587984
		},
		{
			经验 = 1616583,
			金钱 = 606218
		},
		{
			经验 = 1666328,
			金钱 = 624873
		},
		{
			经验 = 1717211,
			金钱 = 643954
		},
		{
			经验 = 1769248,
			金钱 = 663468
		},
		{
			经验 = 1822456,
			金钱 = 683421
		},
		{
			经验 = 1876852,
			金钱 = 703819
		},
		{
			经验 = 1932456,
			金钱 = 724671
		},
		{
			经验 = 1989284,
			金钱 = 745981
		},
		{
			经验 = 2047353,
			金钱 = 767757
		},
		{
			经验 = 2106682,
			金钱 = 790005
		},
		{
			经验 = 2167289,
			金钱 = 812733
		},
		{
			经验 = 2229192,
			金钱 = 835947
		},
		{
			经验 = 2292410,
			金钱 = 859653
		},
		{
			经验 = 2356960,
			金钱 = 883860
		},
		{
			经验 = 2422861,
			金钱 = 908573
		},
		{
			经验 = 2490132,
			金钱 = 933799
		},
		{
			经验 = 2558792,
			金钱 = 959547
		},
		{
			经验 = 2628860,
			金钱 = 985822
		},
		{
			经验 = 2700356,
			金钱 = 1012633
		},
		{
			经验 = 2773296,
			金钱 = 1039986
		},
		{
			经验 = 2847703,
			金钱 = 1067888
		},
		{
			经验 = 2923593,
			金钱 = 1096347
		},
		{
			经验 = 3000989,
			金钱 = 1125371
		},
		{
			经验 = 3079908,
			金钱 = 1154965
		},
		{
			经验 = 3160372,
			金钱 = 1185139
		},
		{
			经验 = 3242400,
			金钱 = 1215900
		},
		{
			经验 = 6652022,
			金钱 = 2494508
		},
		{
			经验 = 6822452,
			金钱 = 2558419
		},
		{
			经验 = 6996132,
			金钱 = 2623549
		},
		{
			经验 = 7173104,
			金钱 = 2689914
		},
		{
			经验 = 7353406,
			金钱 = 2757527
		},
		{
			经验 = 11305620,
			金钱 = 4239607
		},
		{
			经验 = 11586254,
			金钱 = 4344845
		},
		{
			经验 = 11872072,
			金钱 = 4452027
		},
		{
			经验 = 12163140,
			金钱 = 4561177
		},
		{
			经验 = 12459518,
			金钱 = 4672319
		},
		{
			经验 = 15033471,
			金钱 = 450041
		},
		{
			经验 = 15315219,
			金钱 = 4594563
		},
		{
			经验 = 15600468,
			金钱 = 4680138
		},
		{
			经验 = 15889236,
			金钱 = 4766769
		},
		{
			经验 = 16181550,
			金钱 = 4854465
		},
		{
			经验 = 16477425,
			金钱 = 4943226
		},
		{
			经验 = 16776885,
			金钱 = 5033064
		},
		{
			经验 = 17079954,
			金钱 = 5123985
		},
		{
			经验 = 17386650,
			金钱 = 5215995
		},
		{
			经验 = 17697000,
			金钱 = 5309100
		},
		{
			经验 = 24014692,
			金钱 = 7204407
		},
		{
			经验 = 24438308,
			金钱 = 7331490
		},
		{
			经验 = 24866880,
			金钱 = 7460064
		},
		{
			经验 = 25300432,
			金钱 = 7590129
		},
		{
			经验 = 25739000,
			金钱 = 7721700
		},
		{
			经验 = 32728255,
			金钱 = 9818475
		},
		{
			经验 = 33289095,
			金钱 = 9986727
		},
		{
			经验 = 33856310,
			金钱 = 10156893
		},
		{
			经验 = 34492930,
			金钱 = 10328979
		},
		{
			经验 = 40842000,
			金钱 = 12252600
		}
	}

	return {
		经验 = 技能消耗[目标技能等级].经验,
		金钱 = qz(技能消耗[目标技能等级].金钱)
	}
end

取生活技能消耗 = function(目标技能等级, 消耗帮贡)
	local 等级 = 目标技能等级
	local 技能消耗 = {
		{
			经验 = 16,
			金钱 = 6
		},
		{
			经验 = 32,
			金钱 = 12
		},
		{
			经验 = 52,
			金钱 = 19
		},
		{
			经验 = 75,
			金钱 = 28
		},
		{
			经验 = 103,
			金钱 = 38
		},
		{
			经验 = 136,
			金钱 = 51
		},
		{
			经验 = 179,
			金钱 = 67
		},
		{
			经验 = 231,
			金钱 = 86
		},
		{
			经验 = 295,
			金钱 = 110
		},
		{
			经验 = 372,
			金钱 = 139
		},
		{
			经验 = 466,
			金钱 = 174
		},
		{
			经验 = 578,
			金钱 = 216
		},
		{
			经验 = 711,
			金钱 = 266
		},
		{
			经验 = 867,
			金钱 = 325
		},
		{
			经验 = 1049,
			金钱 = 393
		},
		{
			经验 = 1260,
			金钱 = 472
		},
		{
			经验 = 1503,
			金钱 = 563
		},
		{
			经验 = 1780,
			金钱 = 667
		},
		{
			经验 = 2096,
			金钱 = 786
		},
		{
			经验 = 2452,
			金钱 = 919
		},
		{
			经验 = 2854,
			金钱 = 1070
		},
		{
			经验 = 3304,
			金钱 = 1238
		},
		{
			经验 = 3807,
			金钱 = 1426
		},
		{
			经验 = 4364,
			金钱 = 1636
		},
		{
			经验 = 4983,
			金钱 = 1868
		},
		{
			经验 = 5664,
			金钱 = 2124
		},
		{
			经验 = 6415,
			金钱 = 2404
		},
		{
			经验 = 7238,
			金钱 = 2714
		},
		{
			经验 = 8138,
			金钱 = 3050
		},
		{
			经验 = 9120,
			金钱 = 3420
		},
		{
			经验 = 10188,
			金钱 = 3820
		},
		{
			经验 = 11347,
			金钱 = 4255
		},
		{
			经验 = 12602,
			金钱 = 4725
		},
		{
			经验 = 13959,
			金钱 = 5234
		},
		{
			经验 = 15423,
			金钱 = 5783
		},
		{
			经验 = 16998,
			金钱 = 6374
		},
		{
			经验 = 18692,
			金钱 = 7009
		},
		{
			经验 = 20508,
			金钱 = 7690
		},
		{
			经验 = 22452,
			金钱 = 8419
		},
		{
			经验 = 24532,
			金钱 = 9199
		},
		{
			经验 = 26753,
			金钱 = 10032
		},
		{
			经验 = 29121,
			金钱 = 10920
		},
		{
			经验 = 31642,
			金钱 = 11865
		},
		{
			经验 = 34323,
			金钱 = 12871
		},
		{
			经验 = 37169,
			金钱 = 13938
		},
		{
			经验 = 40188,
			金钱 = 15070
		},
		{
			经验 = 43388,
			金钱 = 16270
		},
		{
			经验 = 46773,
			金钱 = 17540
		},
		{
			经验 = 50352,
			金钱 = 18882
		},
		{
			经验 = 54132,
			金钱 = 20299
		},
		{
			经验 = 58120,
			金钱 = 21795
		},
		{
			经验 = 62324,
			金钱 = 23371
		},
		{
			经验 = 66750,
			金钱 = 25031
		},
		{
			经验 = 71407,
			金钱 = 26777
		},
		{
			经验 = 76303,
			金钱 = 28613
		},
		{
			经验 = 81444,
			金钱 = 30541
		},
		{
			经验 = 86840,
			金钱 = 32565
		},
		{
			经验 = 92500,
			金钱 = 34687
		},
		{
			经验 = 98430,
			金钱 = 36911
		},
		{
			经验 = 104640,
			金钱 = 39240
		},
		{
			经验 = 111136,
			金钱 = 41676
		},
		{
			经验 = 117931,
			金钱 = 44224
		},
		{
			经验 = 125031,
			金钱 = 46886
		},
		{
			经验 = 132444,
			金钱 = 49666
		},
		{
			经验 = 140183,
			金钱 = 52568
		},
		{
			经验 = 148253,
			金钱 = 55595
		},
		{
			经验 = 156666,
			金钱 = 58749
		},
		{
			经验 = 165430,
			金钱 = 62036
		},
		{
			经验 = 174556,
			金钱 = 65458
		},
		{
			经验 = 184052,
			金钱 = 69019
		},
		{
			经验 = 193930,
			金钱 = 72723
		},
		{
			经验 = 204198,
			金钱 = 76574
		},
		{
			经验 = 214868,
			金钱 = 80575
		},
		{
			经验 = 225948,
			金钱 = 84730
		},
		{
			经验 = 237449,
			金钱 = 89043
		},
		{
			经验 = 249383,
			金钱 = 93518
		},
		{
			经验 = 261760,
			金钱 = 98160
		},
		{
			经验 = 274589,
			金钱 = 102971
		},
		{
			经验 = 287884,
			金钱 = 107956
		},
		{
			经验 = 301652,
			金钱 = 113119
		},
		{
			经验 = 315908,
			金钱 = 118465
		},
		{
			经验 = 330662,
			金钱 = 123998
		},
		{
			经验 = 345924,
			金钱 = 129721
		},
		{
			经验 = 361708,
			金钱 = 135640
		},
		{
			经验 = 378023,
			金钱 = 141758
		},
		{
			经验 = 394882,
			金钱 = 148080
		},
		{
			经验 = 412297,
			金钱 = 154611
		},
		{
			经验 = 430280,
			金钱 = 161355
		},
		{
			经验 = 448844,
			金钱 = 168316
		},
		{
			经验 = 468000,
			金钱 = 175500
		},
		{
			经验 = 487760,
			金钱 = 182910
		},
		{
			经验 = 508137,
			金钱 = 190551
		},
		{
			经验 = 529145,
			金钱 = 198429
		},
		{
			经验 = 550796,
			金钱 = 206548
		},
		{
			经验 = 573103,
			金钱 = 214913
		},
		{
			经验 = 596078,
			金钱 = 223529
		},
		{
			经验 = 619735,
			金钱 = 232400
		},
		{
			经验 = 644088,
			金钱 = 241533
		},
		{
			经验 = 669149,
			金钱 = 250931
		},
		{
			经验 = 694932,
			金钱 = 260599
		},
		{
			经验 = 721452,
			金钱 = 270544
		},
		{
			经验 = 748722,
			金钱 = 280770
		},
		{
			经验 = 776755,
			金钱 = 291283
		},
		{
			经验 = 805566,
			金钱 = 302087
		},
		{
			经验 = 835169,
			金钱 = 313188
		},
		{
			经验 = 865579,
			金钱 = 324592
		},
		{
			经验 = 896809,
			金钱 = 336303
		},
		{
			经验 = 928876,
			金钱 = 348328
		},
		{
			经验 = 961792,
			金钱 = 360672
		},
		{
			经验 = 995572,
			金钱 = 373339
		},
		{
			经验 = 1030234,
			金钱 = 386337
		},
		{
			经验 = 1065190,
			金钱 = 399671
		},
		{
			经验 = 1102256,
			金钱 = 413346
		},
		{
			经验 = 1139649,
			金钱 = 427368
		},
		{
			经验 = 1177983,
			金钱 = 441743
		},
		{
			经验 = 1217273,
			金钱 = 456477
		},
		{
			经验 = 1256104,
			金钱 = 471576
		},
		{
			经验 = 1298787,
			金钱 = 487045
		},
		{
			经验 = 1341043,
			金钱 = 502891
		},
		{
			经验 = 1384320,
			金钱 = 519120
		},
		{
			经验 = 1428632,
			金钱 = 535737
		},
		{
			经验 = 1473999,
			金钱 = 552749
		},
		{
			经验 = 1520435,
			金钱 = 570163
		},
		{
			经验 = 1567957,
			金钱 = 587984
		},
		{
			经验 = 1616583,
			金钱 = 606218
		},
		{
			经验 = 1666328,
			金钱 = 624873
		},
		{
			经验 = 1717211,
			金钱 = 643954
		},
		{
			经验 = 1769248,
			金钱 = 663468
		},
		{
			经验 = 1822456,
			金钱 = 683421
		},
		{
			经验 = 1876852,
			金钱 = 703819
		},
		{
			经验 = 1932456,
			金钱 = 724671
		},
		{
			经验 = 1989284,
			金钱 = 745981
		},
		{
			经验 = 2047353,
			金钱 = 767757
		},
		{
			经验 = 2106682,
			金钱 = 790005
		},
		{
			经验 = 2167289,
			金钱 = 812733
		},
		{
			经验 = 2229192,
			金钱 = 835947
		},
		{
			经验 = 2292410,
			金钱 = 859653
		},
		{
			经验 = 2356960,
			金钱 = 883860
		},
		{
			经验 = 2422861,
			金钱 = 908573
		},
		{
			经验 = 2490132,
			金钱 = 933799
		},
		{
			经验 = 2558792,
			金钱 = 959547
		},
		{
			经验 = 2628860,
			金钱 = 985822
		},
		{
			经验 = 2700356,
			金钱 = 1012633
		},
		{
			经验 = 2773296,
			金钱 = 1039986
		},
		{
			经验 = 2847703,
			金钱 = 1067888
		},
		{
			经验 = 2923593,
			金钱 = 1096347
		},
		{
			经验 = 3000989,
			金钱 = 1125371
		},
		{
			经验 = 3079908,
			金钱 = 1154965
		},
		{
			经验 = 3160372,
			金钱 = 1185139
		},
		{
			经验 = 3242400,
			金钱 = 1215900
		},
		{
			经验 = 6652022,
			金钱 = 2494508
		},
		{
			经验 = 6822452,
			金钱 = 2558419
		},
		{
			经验 = 6996132,
			金钱 = 2623549
		},
		{
			经验 = 7173104,
			金钱 = 2689914
		},
		{
			经验 = 7353406,
			金钱 = 2757527
		},
		{
			经验 = 11305620,
			金钱 = 3239607
		},
		{
			经验 = 11586254,
			金钱 = 3344845
		},
		{
			经验 = 11872072,
			金钱 = 3452027
		},
		{
			经验 = 12163140,
			金钱 = 3561177
		},
		{
			经验 = 12459518,
			金钱 = 3672319
		},
		{
			经验 = 15033471,
			金钱 = 3800418
		},
		{
			经验 = 15315219,
			金钱 = 3994563
		},
		{
			经验 = 15600468,
			金钱 = 4180138
		},
		{
			经验 = 15889236,
			金钱 = 4266769
		},
		{
			经验 = 16181550,
			金钱 = 4454465
		},
		{
			经验 = 16477425,
			金钱 = 4643226
		},
		{
			经验 = 16776885,
			金钱 = 4833064
		},
		{
			经验 = 17079954,
			金钱 = 5023985
		},
		{
			经验 = 17386650,
			金钱 = 5115995
		},
		{
			经验 = 17697000,
			金钱 = 5309100
		},
		{
			经验 = 24014692,
			金钱 = 6204407
		},
		{
			经验 = 24438308,
			金钱 = 6331490
		},
		{
			经验 = 24866880,
			金钱 = 6460064
		},
		{
			经验 = 25300432,
			金钱 = 6590129
		},
		{
			经验 = 25739000,
			金钱 = 6721700
		},
		{
			经验 = 32728255,
			金钱 = 7518475
		},
		{
			经验 = 33289095,
			金钱 = 7786727
		},
		{
			经验 = 33856310,
			金钱 = 7915689
		},
		{
			经验 = 34492930,
			金钱 = 8128979
		},
		{
			经验 = 40842000,
			金钱 = 8552600
		}
	}

	if 消耗帮贡 == nil then
		return {
			经验 = 技能消耗[目标技能等级].经验,
			金钱 = 技能消耗[目标技能等级].金钱
		}
	else
		return {
			经验 = 技能消耗[目标技能等级].经验,
			金钱 = qz(技能消耗[目标技能等级].金钱 / 2),
			帮贡 = 目标技能等级,
			需求 = 目标技能等级 * 5
		}
	end
end

function 角色处理类:生活技能强壮消耗(目标技能等级)
	local 等级 = 目标技能等级
	local 技能消耗 = {
		{
			经验 = 1720000,
			金钱 = 430000
		},
		{
			经验 = 1980000,
			金钱 = 495000
		},
		{
			经验 = 2280000,
			金钱 = 570000
		},
		{
			经验 = 2620000,
			金钱 = 655000
		},
		{
			经验 = 3000000,
			金钱 = 750000
		},
		{
			经验 = 3420000,
			金钱 = 855000
		},
		{
			经验 = 3880000,
			金钱 = 970000
		},
		{
			经验 = 4380000,
			金钱 = 1095000
		},
		{
			经验 = 4920000,
			金钱 = 1230000
		},
		{
			经验 = 5500000,
			金钱 = 1375000
		},
		{
			经验 = 6120000,
			金钱 = 1530000
		},
		{
			经验 = 6780000,
			金钱 = 1695000
		},
		{
			经验 = 7480000,
			金钱 = 1870000
		},
		{
			经验 = 8220000,
			金钱 = 2055000
		},
		{
			经验 = 9000000,
			金钱 = 2250000
		},
		{
			经验 = 9820000,
			金钱 = 2455000
		},
		{
			经验 = 10680000,
			金钱 = 2670000
		},
		{
			经验 = 11580000,
			金钱 = 2895000
		},
		{
			经验 = 12520000,
			金钱 = 3130000
		},
		{
			经验 = 13500000,
			金钱 = 3375000
		},
		{
			经验 = 14520000,
			金钱 = 3630000
		},
		{
			经验 = 15580000,
			金钱 = 3895000
		},
		{
			经验 = 16680000,
			金钱 = 4170000
		},
		{
			经验 = 17820000,
			金钱 = 4455000
		},
		{
			经验 = 19000000,
			金钱 = 4750000
		},
		{
			经验 = 20220000,
			金钱 = 5055000
		},
		{
			经验 = 21480000,
			金钱 = 5370000
		},
		{
			经验 = 22780000,
			金钱 = 5695000
		},
		{
			经验 = 24120000,
			金钱 = 6030000
		},
		{
			经验 = 25500000,
			金钱 = 6375000
		},
		{
			经验 = 26920000,
			金钱 = 6730000
		},
		{
			经验 = 28380000,
			金钱 = 7095000
		},
		{
			经验 = 29880000,
			金钱 = 7470000
		},
		{
			经验 = 31420000,
			金钱 = 7855000
		},
		{
			经验 = 33000000,
			金钱 = 8250000
		},
		{
			经验 = 34620000,
			金钱 = 8655000
		},
		{
			经验 = 36280000,
			金钱 = 9070000
		},
		{
			经验 = 37980000,
			金钱 = 9495000
		},
		{
			经验 = 39720000,
			金钱 = 9930000
		},
		{
			经验 = 41500000,
			金钱 = 10375000
		}
	}

	return {
		经验 = 技能消耗[目标技能等级].经验,
		金钱 = qz(技能消耗[目标技能等级].金钱),
		帮贡 = 目标技能等级,
		需求 = 目标技能等级 * 5
	}
end

取指定道具背包位置 = function(id, 道具名称)
	local 位置 = 0

	for k, v in pairs(玩家数据[id].角色.数据.道具) do
		if 玩家数据[id].道具.数据[v] ~= nil and 玩家数据[id].道具.数据[v].名称 == 道具名称 then
			位置 = k + 0

			break
		end
	end

	return 位置
end

扣除多个道具 = function(id, 扣除列表1)
	if 扣除列表1 == nil or type(扣除列表1) ~= "table" then
		常规提示(id, "#Y扣除道具出错。")

		return false
	end

	local 扣除列表 = DeepCopy(扣除列表1)
	local 扣除数据 = {}

	for k, v in pairs(玩家数据[id].角色.数据.道具) do
		if 玩家数据[id].道具.数据[v] ~= nil and 扣除列表[玩家数据[id].道具.数据[v].名称] ~= nil then
			local aa = 玩家数据[id].道具.数据[v]
			local 所需扣除 = 扣除列表[玩家数据[id].道具.数据[v].名称] + 0

			if 所需扣除 <= (aa.数量 or 1) then
				扣除数据[#扣除数据 + 1] = {
					物品 = v,
					格子 = k,
					数量 = 所需扣除
				}
				扣除列表[aa.名称] = nil
			else
				扣除数据[#扣除数据 + 1] = {
					物品 = v,
					格子 = k,
					数量 = aa.数量 or 1
				}
				扣除列表[aa.名称] = 扣除列表[aa.名称] - (aa.数量 or 1)
			end
		end
	end

	for k, v in pairs(扣除列表) do
		if type(v) == "number" and v <= 0 then
			扣除列表[k] = nil
		end
	end

	if 判断是否为空表(扣除列表) then
		for k, v in pairs(扣除数据) do
			if 玩家数据[id].道具.数据[v.物品] ~= nil then
				玩家数据[id].道具.数据[v.物品].数量 = (玩家数据[id].道具.数据[v.物品].数量 or 1) - v.数量

				if 玩家数据[id].道具.数据[v.物品].数量 < 1 then
					玩家数据[id].角色.数据.道具[v.格子] = nil
					玩家数据[id].道具.数据[v.物品] = nil
				end
			end

			刷新道具行囊单格(id, "道具", v.格子, v.物品)
		end

		return true
	else
		常规提示(id, "#Y你身上#R所需道具#Y不足")

		return false
	end
end

扣除道具 = function(id, 道具名称, 数量, 不提示)
	数量 = 数量 or 1
	local 所需扣除 = 数量 or 1
	local 扣除数据 = {}

	for k, v in pairs(玩家数据[id].角色.数据.道具) do
		if 玩家数据[id].道具.数据[v] ~= nil and 玩家数据[id].道具.数据[v].名称 == 道具名称 then
			if 所需扣除 <= (玩家数据[id].道具.数据[v].数量 or 1) then
				扣除数据[#扣除数据 + 1] = {
					物品 = v,
					格子 = k,
					数量 = 所需扣除
				}
				所需扣除 = 0

				break
			else
				所需扣除 = 所需扣除 - (玩家数据[id].道具.数据[v].数量 or 1)
				扣除数据[#扣除数据 + 1] = {
					物品 = v,
					格子 = k,
					数量 = 玩家数据[id].道具.数据[v].数量 or 1
				}
			end
		end
	end

	if 所需扣除 == 0 then
		for k, v in pairs(扣除数据) do
			if 玩家数据[id].道具.数据[v.物品] ~= nil then
				玩家数据[id].道具.数据[v.物品].数量 = (玩家数据[id].道具.数据[v.物品].数量 or 1) - v.数量

				if 玩家数据[id].道具.数据[v.物品].数量 < 1 then
					玩家数据[id].角色.数据.道具[v.格子] = nil
					玩家数据[id].道具.数据[v.物品] = nil
				end

				刷新道具行囊单格(id, "道具", v.格子, v.物品)
			end
		end

		return true
	else
		if 玩家数据[id].战斗 == 0 and 不提示 == nil then
			常规提示(id, "#Y你身上的#R" .. 道具名称 .. "#Y不足" .. 数量 .. "个")
		end

		return false
	end
end

扣除背包位置道具 = function(id, 背包编号, 数量)
	数量 = 数量 or 1
	local 所需扣除 = 数量 or 1
	local 扣除数据 = {}
	local 道具数据 = 玩家数据[id].道具.数据
	local 道具编号 = 玩家数据[id].角色.数据.道具[背包编号]

	if 道具编号 ~= nil and 道具数据[道具编号] ~= nil and 所需扣除 <= (道具数据[道具编号].数量 or 1) then
		道具数据[道具编号].数量 = (道具数据[道具编号].数量 or 1) - 所需扣除

		if 道具数据[道具编号].数量 < 1 then
			道具数据[道具编号] = nil
			玩家数据[id].角色.数据.道具[背包编号] = nil
		end

		刷新道具行囊单格(id, "道具", 背包编号, 道具编号)

		return true
	else
		常规提示(id, "#Y你身上没有指定物品或物品数量不足！")

		return false
	end
end

银两不生效途径 = {
	商城购买 = 1,
	兑换银两 = 1,
	神秘宝箱 = 1,
	藏宝阁 = 1,
	出售 = 1,
	造化丹 = 1,
	仙玉换取银子 = 1,
	兑换 = 1,
	奖励 = 1,
	坐骑任务取消 = 1,
	GM工具充值 = 1,
	比武大会比赛报名费返还 = 1,
	剧情任务 = 1,
	GM命令 = 1,
	回收 = 1,
	月卡 = 1,
	福利宝箱 = 1,
	礼包 = 1,
	交易中心 = 1,
	系统出售 = 1,
	退回保证金 = 1,
	抽奖 = 1
}
精修生效途径 = {
	妖魔鬼怪 = 1,
	捉鬼 = 1,
	封妖战斗 = 1,
	野外 = 1
}

function 角色处理类:添加银子(数额, 说明, 提示)
	if 数额 == nil or 数额 + 0 <= 0 then
		数额 = 0
	end

	local 之前银子 = self.数据.银子
	local 聚宝盆加成 = 0
	local 基础倍率 = 服务端参数.银子获得率
	local 倍率 = 1

	if 银两不生效途径[说明] == nil and string.find(说明, "出售") == nil and string.find(说明, "藏宝阁") == nil and string.find(说明, "回收") == nil and string.find(说明, "兑换") == nil and string.find(说明, "购买") == nil and string.find(tostring(提示), "出售") == nil then
		if self:取任务(3) ~= 0 and 精修生效途径[说明] ~= nil then
			倍率 = 倍率 + 1
		end

		if 经验倍数银两生效 == 1 then
			if self:取任务(2) ~= 0 then
				倍率 = 倍率 + 1
			end

			if 服务端参数.倍率模式 == 1 then
				if self:取任务(7756) ~= 0 then
					倍率 = 倍率 * 2
				end

				if self:取任务(7755) ~= 0 then
					倍率 = 倍率 * 3
				end

				if self:取任务(7757) ~= 0 then
					倍率 = 倍率 * 10
				end
			else
				if self:取任务(7756) ~= 0 then
					倍率 = 倍率 + 1
				end

				if self:取任务(7755) ~= 0 then
					倍率 = 倍率 + 2
				end

				if self:取任务(7757) ~= 0 then
					倍率 = 倍率 + 9
				end
			end
		end

		if self.数据.聚宝盆 ~= nil and self.数据.聚宝盆 > 0 then
			if 聚宝盆上限 < self.数据.聚宝盆 then
				self.数据.聚宝盆 = 聚宝盆上限 + 0
			end

			聚宝盆加成 = qz1(数额 * 倍率 * self.数据.聚宝盆 * 基础倍率)
			基础倍率 = 基础倍率 * (1 + self.数据.聚宝盆)
		end
	else
		基础倍率 = 1
	end

	数额 = qz1(数额 * 倍率 * 基础倍率)
	local VIP加成 = 0

	if self.数据.当前称谓 == "西游小萌新" then
		VIP加成 = 0
	elseif self.数据.当前称谓 == "笑看西游" then
		VIP加成 = 0
	elseif self.数据.当前称谓 == "西游任我行" then
		VIP加成 = 0
	elseif self.数据.当前称谓 == "梦幻任逍遥" then
		VIP加成 = 0
	elseif self.数据.当前称谓 == "天人开造化" then
		VIP加成 = 0
	end

	self.数据.银子 = self.数据.银子 + 数额

	if 提示 ~= nil then
		if VIP加成 == 0 then
			if 聚宝盆加成 > 0 then
				常规提示(self.数据.数字id, "#Y你获得了#R" .. 数字转简(数额) .. "#Y两银子(其中聚宝盆额外加成#R" .. 数字转简(聚宝盆加成) .. "#Y两)")
			else
				常规提示(self.数据.数字id, "#Y你获得了#R" .. 数字转简(数额) .. "#Y两银子")
			end
		else
			常规提示(self.数据.数字id, "#Y你获得了#R" .. 数字转简(数额) .. "#Y两银子,佩戴VIP称谓额外获得#R" .. VIP加成 .. "#Y两银子。")
		end
	end

	self:日志记录(format("事件:获得银子,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前银子, self.数据.银子))

	if 大额额度 < 数额 then
		self:大额日志记录(format("%s(%s)获得银子,类型%s,数额%s,倍率%s,获得前%s,获得后%s", self.数据.名称, self.数据.数字id, 说明, 数额, 倍率, 之前银子,
			self.数据.银子))
	end

	if 银子数据[self.数据.数字id] == nil then
		银子数据[self.数据.数字id] = {
			id = self.数据.数字id,
			名称 = self.数据.名称,
			银子 = self.数据.银子 + self.数据.存银,
			门派 = self.数据.门派,
			等级 = self.数据.等级
		}
	else
		银子数据[self.数据.数字id].银子 = 银子数据[self.数据.数字id].银子 + 数额
		银子数据[self.数据.数字id].等级 = self.数据.等级
	end

	刷新货币(玩家数据[self.数据.数字id].连接id, self.数据.数字id)
end

function 角色处理类:添加储备(数额, 说明, 提示)
	if 数额 == nil or 数额 + 0 <= 0 then
		数额 = 0
	end

	local 基础倍率 = 服务端参数.储备获得率
	local 倍率 = 1

	if self:取任务(3) ~= 0 and 精修生效途径[说明] ~= nil then
		倍率 = 倍率 + 1
	end

	if 说明 ~= "不加倍" and 经验丹加储备 then
		if 服务端参数.倍率模式 == 1 then
			if self:取任务(7756) ~= 0 then
				倍率 = 倍率 * 2
			end

			if self:取任务(7755) ~= 0 then
				倍率 = 倍率 * 3
			end

			if self:取任务(7757) ~= 0 then
				倍率 = 倍率 * 10
			end
		else
			if self:取任务(7756) ~= 0 then
				倍率 = 倍率 + 1
			end

			if self:取任务(7755) ~= 0 then
				倍率 = 倍率 + 2
			end

			if self:取任务(7757) ~= 0 then
				倍率 = 倍率 + 9
			end
		end
	end

	数额 = 数额 * 倍率 * 基础倍率
	local 之前银子 = self.数据.储备
	self.数据.储备 = self.数据.储备 + 数额

	if 提示 ~= nil then
		常规提示(self.数据.数字id, "#Y你获得了#R" .. 数字转简(数额) .. "#Y点储备金")
	end

	self:日志记录(format("事件:获得储备,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前银子, self.数据.储备))
	刷新货币(玩家数据[self.数据.数字id].连接id, self.数据.数字id)
end

function 角色处理类:添加存银(数额, 说明, 提示)
	if 数额 == nil or 数额 + 0 <= 0 then
		数额 = 0
	end

	local 之前银子 = self.数据.存银
	self.数据.存银 = self.数据.存银 + 数额
	local 倍率 = 1

	if 提示 ~= nil then
		常规提示(self.数据.数字id, "你存入了" .. 数额 .. "点银子")
	end

	self:日志记录(format("事件:存入存银,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前银子, self.数据.存银))

	if 银子数据[self.数据.数字id] == nil then
		银子数据[self.数据.数字id] = {
			id = self.数据.数字id,
			名称 = self.数据.名称,
			银子 = self.数据.银子 + self.数据.存银,
			门派 = self.数据.门派,
			等级 = self.数据.等级
		}
	else
		银子数据[self.数据.数字id].银子 = 银子数据[self.数据.数字id].银子 + 数额
		银子数据[self.数据.数字id].等级 = self.数据.等级
	end

	刷新货币(玩家数据[self.数据.数字id].连接id, self.数据.数字id)
end

function 角色处理类:扣除银子(数额, 储备, 存银, 说明, 提示)
	数额 = 数额 + 0

	if 数额 <= 0 then
		数额 = 0
	end

	local 之前银子 = self.数据.银子
	local 倍率 = 1

	if 储备 == 0 and 存银 == 0 then
		if 数额 <= self.数据.银子 then
			self.数据.银子 = self.数据.银子 - 数额

			if 提示 ~= nil and 说明 ~= "商店购买" then
				常规提示(self.数据.数字id, "你失去了#R" .. 数字转简(数额) .. "#Y两银子")
			end

			self:日志记录(format("事件:扣除银子,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前银子, self.数据.银子))

			if 大额额度 < 数额 then
				self:日志记录(format("%s(%s)扣除银子,类型%s,数额%s,倍率%s,获得前%s,获得后%s", self.数据.名称, self.数据.数字id, 说明, 数额, 倍率, 之前银子,
					self.数据.银子))
			end

			if 银子数据[self.数据.数字id] ~= nil then
				银子数据[self.数据.数字id].银子 = 银子数据[self.数据.数字id].银子 - 数额
				银子数据[self.数据.数字id].等级 = self.数据.等级
			end

			刷新货币(玩家数据[self.数据.数字id].连接id, self.数据.数字id)

			return true
		else
			if 提示 ~= nil then
				常规提示(id, "#Y/你没有#P" .. 数字转简(数额) .. "两#Y那么多的银两！")
			end

			return false
		end
	end
end

function 角色处理类:扣除储备(金额, 说明)
	local 数额 = 金额 + 0

	if 数额 <= 0 then
		数额 = 0
	end

	if 数额 <= self.数据.储备 then
		self.数据.储备 = self.数据.储备 - 数额

		self:日志记录(说明 .. "消耗" .. 数额 .. "点储备")
		self:银子记录()
		常规提示(self.数据.数字id, "你失去了#R" .. 数字转简(数额) .. "#Y点储备")
		刷新货币(玩家数据[self.数据.数字id].连接id, self.数据.数字id)

		return true
	else
		常规提示(id, "你没有那么多的储备")

		return false
	end

	return false
end

function 角色处理类:扣除储备和银子(金额, 说明)
	local 数额 = 金额 + 0

	if 数额 <= 0 then
		数额 = 0
	end

	if 数额 <= self.数据.储备 then
		self.数据.储备 = self.数据.储备 - 数额

		self:日志记录(说明 .. "消耗" .. 数额 .. "点储备")
		self:银子记录()
		刷新货币(玩家数据[self.数据.数字id].连接id, self.数据.数字id)
		常规提示(self.数据.数字id, "你失去了#R" .. 数字转简(数额) .. "#Y点储备")

		return true
	elseif 数额 <= self.数据.储备 + self.数据.银子 then
		数额 = 数额 - self.数据.储备

		self:日志记录(说明 .. "消耗" .. self.数据.储备 .. "点储备、" .. 数额 .. "两银子")
		常规提示(self.数据.数字id, "你失去了#R" .. 数字转简(self.数据.储备) .. "#Y两储备、#R" .. 数字转简(数额) .. "#Y两银子")
		self:银子记录()

		self.数据.银子 = self.数据.银子 - 数额
		self.数据.储备 = 0

		刷新货币(玩家数据[self.数据.数字id].连接id, self.数据.数字id)

		return true
	else
		常规提示(id, "你没有那么多的银子")

		return false
	end

	return false
end

function 角色处理类:扣除钓鱼积分(数额, 储备, 存银, 说明, 提示)
	数额 = 数额 + 0
	local 之前银子 = self.数据.钓鱼积分
	local 倍率 = 1

	if 储备 == 0 and 存银 == 0 and 数额 <= self.数据.钓鱼积分 then
		self.数据.钓鱼积分 = self.数据.钓鱼积分 - 数额

		if 提示 ~= nil and 说明 ~= "商店购买" then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "积分")
		end

		self:日志记录(format("事件:扣除钓鱼积分,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前银子, self.数据.钓鱼积分))

		return true
	end
end

function 角色处理类:扣除经验(数额, 说明, 提示)
	数额 = 数额 + 0

	if 数额 <= self.数据.当前经验 then
		self.数据.当前经验 = self.数据.当前经验 - 数额

		if 提示 ~= nil then
			常规提示(self.数据.数字id, "你失去了" .. 数字转简(数额) .. "点经验")
		end

		return true
	else
		return false
	end
end

function 角色处理类:扣除积分(数额, 说明, 提示)
	数额 = 数额 + 0
	local 之前积分 = self.数据.比武积分.当前积分

	if 数额 <= self.数据.比武积分.当前积分 then
		self.数据.比武积分.当前积分 = self.数据.比武积分.当前积分 - 数额

		if 提示 ~= nil and 说明 ~= "商店购买" then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "点比武积分")
		end

		self:日志记录(format("事件:扣除积分,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前积分, self.数据.比武积分.当前积分))

		return true
	else
		return false
	end
end

添加军功 = function(id, 数额)
	数额 = 数额 or 0

	if 数额 <= 0 then
		return
	end

	if 玩家数据[id].角色.数据.军功 == nil then
		玩家数据[id].角色.数据.军功 = {}
	end

	玩家数据[id].角色.数据.军功.当前 = (玩家数据[id].角色.数据.军功.当前 or 0) + 数额
	玩家数据[id].角色.数据.军功.全部 = (玩家数据[id].角色.数据.军功.全部 or 0) + 数额

	常规提示(id, "#Y/你的军功增加了#R/" .. 数额 .. "#Y/点！")
end

function 角色处理类:扣除军功(数额, 说明, 提示)
	数额 = 数额 + 0

	if self.数据.军功 == nil then
		self.数据.军功 = {
			全部 = 0,
			当前 = 0
		}
	end

	local 之前积分 = self.数据.军功.当前 + 0

	if 数额 <= self.数据.军功.当前 then
		self.数据.军功.当前 = self.数据.军功.当前 - 数额

		if 提示 ~= nil and 说明 ~= "商店购买" then
			常规提示(self.数据.数字id, "你消耗了" .. 数额 .. "点军功")
		end

		self:日志记录(format("事件:扣除军功,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前积分, self.数据.军功.当前))

		return true
	else
		return false
	end
end

给妖魔积分 = function(id, 数额)
	数额 = 数额 or 0

	if 数额 <= 0 then
		return
	end

	if 妖魔积分[id] == nil then
		妖魔积分[id] = {
			总计 = 0,
			当前 = 0,
			使用 = 0
		}
	end

	妖魔积分[id].当前 = (妖魔积分[id].当前 or 0) + 数额
	妖魔积分[id].总计 = (妖魔积分[id].总计 or 0) + 数额

	常规提示(id, "你获得了#R" .. 数额 .. "#Y点妖魔积分")
end

给副本积分 = function(id, 数额)
	if 数额 <= 0 then
		return
	end

	玩家数据[id].角色.数据.副本积分 = (玩家数据[id].角色.数据.副本积分 or 0) + 数额

	常规提示(id, "你获得了#R" .. 数额 .. "#Y点副本积分")
end

给种族积分 = function(id, 数额)
	数额 = 数额 or 0

	if 数额 <= 0 then
		return
	end

	玩家数据[id].角色.数据.种族积分 = (玩家数据[id].角色.数据.种族积分 or 0) + 数额

	常规提示(id, "你获得了#R" .. 数额 .. "#Y点种族积分")
end

function 角色处理类:扣除副本积分(数额, 说明, 提示)
	数额 = 数额 + 0
	local 之前积分 = self.数据.副本积分 + 0

	if 数额 <= self.数据.副本积分 then
		self.数据.副本积分 = self.数据.副本积分 - 数额

		if 提示 ~= nil and 说明 ~= "商店购买" then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "点副本积分")
		end

		self:日志记录(format("事件:扣除积分,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前积分, self.数据.副本积分))

		return true
	else
		return false
	end
end

function 角色处理类:扣除种族积分(数额, 说明, 提示)
	数额 = 数额 + 0

	if self.数据.种族积分 == nil then
		self.数据.种族积分 = 0
	end

	local 之前积分 = self.数据.种族积分 + 0

	if 数额 <= self.数据.种族积分 then
		self.数据.种族积分 = self.数据.种族积分 - 数额

		if 提示 ~= nil and 说明 ~= "商店购买" then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "点种族积分")
		end

		self:日志记录(format("事件:扣除积分,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前积分, self.数据.种族积分))

		return true
	else
		return false
	end
end

function 角色处理类:扣除妖魔积分(数额, 说明, 提示)
	数额 = 数额 + 0
	local 之前积分 = 妖魔积分[self.数据.数字id].当前

	if 数额 <= 妖魔积分[self.数据.数字id].当前 then
		妖魔积分[self.数据.数字id].当前 = 妖魔积分[self.数据.数字id].当前 - 数额

		if 提示 ~= nil and 说明 ~= "商店购买" then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "点妖魔积分")
		end

		self:日志记录(format("事件:扣除积分,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前积分, 妖魔积分[self.数据.数字id].当前))

		return true
	else
		return false
	end
end

function 角色处理类:扣除活跃(数额, 说明, 提示)
	数额 = 数额 + 0
	local 之前活跃 = self.数据.累积活跃.当前积分

	if 数额 <= self.数据.累积活跃.当前积分 then
		self.数据.累积活跃.当前积分 = self.数据.累积活跃.当前积分 - 数额

		if 提示 ~= nil and 说明 ~= "商店购买" then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "点可用活跃")
		end

		self:日志记录(format("事件:扣除活跃,类型%s,数额%s,倍率%s,获得前%s,获得后%s", 说明, 数额, 倍率, 之前活跃, self.数据.累积活跃.当前积分))

		return true
	end

	return false
end

function 角色处理类:取消任务(id)
	local 任务id = 0

	for n, v in pairs(self.数据.任务) do
		if v == id then
			任务id = n
		end
	end

	if 任务id ~= 0 then
		self.数据.任务[任务id] = nil
	end

	if self.数据.取消任务 == 8800 then
		for n, v in pairs(任务数据) do
			if 任务数据[n] ~= nil and tonumber(任务数据[n].类型) ~= nil and tonumber(任务数据[n].类型) >= 8800 and tonumber(任务数据[n].类型) <= 8821 and 任务数据[n].玩家id == self.数据.数字id then
				地图处理类:删除单位(任务数据[n].地图编号, 任务数据[n].单位编号)
			end
		end

		self.数据.取消任务 = nil
	end

	self:刷新任务跟踪()
end

function 角色处理类:获取当前地图任务人物位置(连接id, 地图编号, id)
	local 任务信息 = {}

	if 地图处理类.地图单位[地图编号] ~= nil then
		for k, v in pairs(地图处理类.地图单位[地图编号]) do
			if v ~= nil and v.名称 ~= nil and v.x ~= nil and v.y ~= nil and v.模型 ~= nil then
				if v.副本id ~= nil then
					if v.副本id == id then
						任务信息[#任务信息 + 1] = {
							X = v.x,
							Y = v.y,
							名称 = v.名称,
							模型 = v.模型
						}
					end
				else
					任务信息[#任务信息 + 1] = {
						X = v.x,
						Y = v.y,
						名称 = v.名称,
						模型 = v.模型
					}
				end
			end
		end
	end

	任务信息.地图编号 = 地图编号

	发送数据(连接id, 39.1, 任务信息)
end

function 角色处理类:获取任务信息(连接id)
	local 任务信息 = {}

	for n, v in pairs(self.数据.任务) do
		if 任务数据[v] ~= nil then
			任务信息[#任务信息 + 1] = 任务处理类:取任务说明(self.数据.数字id, v)
		else
			self.数据.任务[n] = nil
		end
	end

	发送数据(连接id, 40, 任务信息)
end

function 角色处理类:取助战任务(id, 编号)
	local 任务id = 0

	for n, v in pairs(self.数据.任务) do
		if 任务数据[v] ~= nil and 任务数据[v].类型 == id and 任务数据[v].编号 == 编号 then
			任务id = v
		end
	end

	return 任务id
end

function 角色处理类:取任务(id)
	local 任务id = 0

	for n, v in pairs(self.数据.任务) do
		if 任务数据[v] ~= nil and 任务数据[v].类型 == id then
			任务id = v

			break
		end
	end

	return 任务id
end

function 角色处理类:取任务1(id)
	local 任务id = {}

	for n, v in pairs(self.数据.任务) do
		if 任务数据[v] ~= nil and 任务数据[v].类型 == id then
			任务id[#任务id + 1] = v
		end
	end

	if #任务id == 0 then
		return false
	else
		return 任务id
	end
end

function 角色处理类:添加任务(id)
	for n, v in pairs(self.数据.任务) do
		if v == id then
			return
		end
	end

	local 任务id = 0

	for n, v in pairs(self.数据.任务) do
		if v == nil then
			任务id = n
		end
	end

	if 任务id ~= 0 then
		self.数据.任务[任务id] = id
	else
		self.数据.任务[#self.数据.任务 + 1] = id
	end

	self:刷新任务跟踪()
end

function 角色处理类:刷新任务跟踪()
	发送数据(玩家数据[self.数据.数字id].连接id, 47)

	local 任务发送 = {}

	for n, v in pairs(self.数据.任务) do
		if v ~= nil and 任务数据[v] ~= nil then
			任务发送[#任务发送 + 1] = 任务处理类:取任务说明(self.数据.数字id, v)
			任务发送[#任务发送][3] = 任务数据[v].起始
		elseif 任务数据[v] == nil then
			self.数据.任务[n] = nil
		end
	end

	table.sort(任务发送, function(a, b)
		return b[3] < a[3]
	end)

	for n = 1, #任务发送 do
		发送数据(玩家数据[self.数据.数字id].连接id, 46, 任务发送[n])
	end
end

添加门贡 = function(id, 数额)
	数额 = 数额 or 0

	if 数额 > 0 and 玩家数据[id].角色.数据.门派 ~= "无" then
		玩家数据[id].角色.数据.门贡 = (玩家数据[id].角色.数据.门贡 or 0) + 数额
		玩家数据[id].角色.数据.最大门贡 = (玩家数据[id].角色.数据.最大门贡 or 0) + 数额

		常规提示(id, "#Y/你获得了#G" .. 数额 .. "#Y点门派贡献。")
	end

	if 玩家数据[id].角色.数据.门贡 > (玩家数据[id].角色.数据.最大门贡 or 0) then
		玩家数据[id].角色.数据.门贡 = 玩家数据[id].角色.数据.最大门贡 or 0
	end
end

扣除门贡 = function(id, 数额)
	数额 = 数额 or 0

	if 数额 > 0 and 玩家数据[id].角色.数据.门派 ~= "无" and 数额 <= 玩家数据[id].角色.数据.门贡 and 数额 <= (玩家数据[id].角色.数据.最大门贡 or 0) then
		玩家数据[id].角色.数据.门贡 = 玩家数据[id].角色.数据.门贡 - 数额

		常规提示(id, "#Y/你消耗了#G" .. 数额 .. "#Y点门派贡献。")

		return true
	end

	if 玩家数据[id].角色.数据.门贡 > (玩家数据[id].角色.数据.最大门贡 or 0) then
		玩家数据[id].角色.数据.门贡 = 玩家数据[id].角色.数据.最大门贡 or 0
	end

	return false
end

领取武官称谓 = function(id)
	if id ~= nil and 玩家数据[id] ~= nil and (玩家数据[id].角色.数据.武勋 or 0) > 0 then
		local 文功 = (玩家数据[id].角色.数据.文功 or 0) + 0
		local 武勋 = (玩家数据[id].角色.数据.武勋 or 0) + 0

		if 玩家数据[id].角色.数据.称谓 == nil then
			玩家数据[id].角色.数据.称谓 = {}
		end

		local 称谓列表 = 列表模式转换(玩家数据[id].角色.数据.称谓)
		local 待领取称谓 = ""
		local 待删除称谓 = {}
		local 待删除称谓1 = {}
		local 下一官职 = {}
		local 最大官职 = false

		for i = 1, #武官称谓 do
			if 武官称谓[i][2] <= 文功 and 武官称谓[i][3] <= 武勋 then
				if i == #武官称谓 then
					最大官职 = true
					下一官职 = {}
				else
					下一官职 = DeepCopy(武官称谓[i + 1])
				end

				待领取称谓 = 武官称谓[i][1]
				玩家数据[id].角色.数据.武官级别 = math.max(i + 0, 玩家数据[id].角色.数据.武官级别 or 0)

				if 称谓列表[武官称谓[i][1]] ~= nil then
					待删除称谓[#待删除称谓 + 1] = 称谓列表[武官称谓[i][1]]
					待删除称谓1[武官称谓[i][1]] = #待删除称谓 + 0
				end
			else
				下一官职 = DeepCopy(武官称谓[i])

				break
			end
		end

		local aa = ""

		if not 判断是否为空表(下一官职) then
			aa = "\n\n#P【下次升官条件】#S" .. 下一官职[1] .. "#Y需要#G" .. 下一官职[2] .. "#Y点文功、#R" .. 下一官职[3] .. "#Y点武勋"
		end

		if 待领取称谓 ~= "" then
			if 待删除称谓1[待领取称谓] == nil then
				无错误删除列表多个元素(玩家数据[id].角色.数据.称谓, 待删除称谓)
				玩家数据[id].角色:添加称谓(id, 待领取称谓)
				角色刷新信息(id, 玩家数据[id].角色.数据)
				添加最后对话(id, "#84#Y恭喜少侠荣升——#S" .. 待领取称谓 .. "#Y" .. aa)
			elseif not 最大官职 then
				添加最后对话(id, "少侠当前不满足升官条件、请继续努力！" .. aa)
			else
				添加最后对话(id, "少侠已经是#P最高品级武官#了！")
			end
		else
			添加最后对话(id, "少侠当前不满足任职条件、请继续努力！" .. aa)
		end
	else
		添加最后对话(id, "大胆！#P寸功未建#也敢冒领官职？！#4")
	end
end

领取文官称谓 = function(id)
	if id ~= nil and 玩家数据[id] ~= nil and (玩家数据[id].角色.数据.文功 or 0) > 0 then
		local 文功 = (玩家数据[id].角色.数据.文功 or 0) + 0
		local 武勋 = (玩家数据[id].角色.数据.武勋 or 0) + 0

		if 玩家数据[id].角色.数据.称谓 == nil then
			玩家数据[id].角色.数据.称谓 = {}
		end

		local 称谓列表 = 列表模式转换(玩家数据[id].角色.数据.称谓)
		local 待领取称谓 = ""
		local 待删除称谓 = {}
		local 待删除称谓1 = {}
		local 下一官职 = {}
		local 最大官职 = false

		for i = 1, #文官称谓 do
			if 文官称谓[i][2] <= 文功 and 文官称谓[i][3] <= 武勋 then
				if i == #文官称谓 then
					最大官职 = true
					下一官职 = {}
				else
					下一官职 = DeepCopy(文官称谓[i + 1])
				end

				待领取称谓 = 文官称谓[i][1]
				玩家数据[id].角色.数据.文官级别 = math.max(i + 0, 玩家数据[id].角色.数据.文官级别 or 0)

				if 称谓列表[文官称谓[i][1]] ~= nil then
					待删除称谓[#待删除称谓 + 1] = 称谓列表[文官称谓[i][1]]
					待删除称谓1[文官称谓[i][1]] = #待删除称谓 + 0
				end
			else
				下一官职 = DeepCopy(文官称谓[i])

				break
			end
		end

		local aa = ""

		if not 判断是否为空表(下一官职) then
			aa = "\n\n#P【下次升官条件】#S" .. 下一官职[1] .. "#Y需要#G" .. 下一官职[2] .. "#Y点文功、#R" .. 下一官职[3] .. "#Y点武勋"
		end

		if 待领取称谓 ~= "" then
			if 待删除称谓1[待领取称谓] == nil then
				无错误删除列表多个元素(玩家数据[id].角色.数据.称谓, 待删除称谓)
				玩家数据[id].角色:添加称谓(id, 待领取称谓)
				角色刷新信息(id, 玩家数据[id].角色.数据)
				添加最后对话(id, "#84#Y恭喜少侠荣升——#S" .. 待领取称谓 .. "#Y" .. aa)
			elseif not 最大官职 then
				添加最后对话(id, "少侠当前不满足升官条件、请继续努力！" .. aa)
			else
				添加最后对话(id, "少侠已经是#P最高品级文官#了！")
			end
		else
			添加最后对话(id, "少侠当前不满足任职条件、请继续努力！" .. aa)
		end
	else
		添加最后对话(id, "大胆！#P寸功未建#也敢冒领官职？！#4")
	end
end

添加文功 = function(id, 数额)
	数额 = qz(数额 or 0)

	if id ~= nil and 玩家数据[id] ~= nil and 数额 > 0 then
		玩家数据[id].角色.数据.文功 = (玩家数据[id].角色.数据.文功 or 0) + 数额

		常规提示(id, "#P(官职)#Y/你获得了#G" .. 数额 .. "#Y点#R文功")

		local 总贡献 = (玩家数据[id].角色.数据.文功 or 0) + (玩家数据[id].角色.数据.武勋 or 0)

		if 排行榜数据.文功 ~= nil and 排行榜数据.文功[#排行榜数据.文功].分数 < 玩家数据[id].角色.数据.文功 then
			刷新角色单个排行榜(id, "文功", 玩家数据[id].角色.数据.文功)
		end

		if 排行榜数据.总贡献 ~= nil and 排行榜数据.总贡献[#排行榜数据.总贡献].分数 < 总贡献 then
			刷新角色单个排行榜(id, "总贡献", 总贡献)
		end
	end
end

添加武勋 = function(id, 数额)
	数额 = qz(数额 or 0)

	if id ~= nil and 玩家数据[id] ~= nil and 数额 > 0 then
		玩家数据[id].角色.数据.武勋 = (玩家数据[id].角色.数据.武勋 or 0) + 数额

		常规提示(id, "#P(官职)#Y/你获得了#G" .. 数额 .. "#Y点#R武勋")

		local 总贡献 = (玩家数据[id].角色.数据.文功 or 0) + (玩家数据[id].角色.数据.武勋 or 0)

		if 排行榜数据.武勋 ~= nil and 排行榜数据.武勋[#排行榜数据.武勋].分数 < 玩家数据[id].角色.数据.武勋 then
			刷新角色单个排行榜(id, "武勋", 玩家数据[id].角色.数据.武勋)
		end

		if 排行榜数据.总贡献 ~= nil and 排行榜数据.总贡献[#排行榜数据.总贡献].分数 < 总贡献 then
			刷新角色单个排行榜(id, "总贡献", 总贡献)
		end
	end
end

添加活跃度 = function(id, 数额)
	数额 = qz(数额 or 0)

	if 数额 < 1 then
		return
	end

	if 活跃数据[id] == nil then
		活跃数据[id] = {
			领取300活跃 = false,
			领取500活跃 = false,
			领取400活跃 = false,
			领取200活跃 = false,
			领取100活跃 = false,
			活跃度 = 0
		}
	end

	活跃数据[id].活跃度 = (活跃数据[id].活跃度 or 0) + 数额
	玩家数据[id].角色.数据.累积活跃.当前积分 = 玩家数据[id].角色.数据.累积活跃.当前积分 + 数额

	常规提示(id, "#Y/你获得了#G" .. 数额 .. "#Y点活跃度。")
	广播消息({
		频道 = "xt",
		内容 = format("#S(任务活动)#R/%s#Y少侠完成任务时，辛苦劳累，小姐姐给你捶捶背#110#G/%s#Y", 玩家数据[id].角色.数据.名称, 奖励名称[id])
	})
end

function 角色处理类:购买灵饰(等级, 仙玉, id)
	if self:取道具格子2() < 4 then
		添加最后对话(id, "你身上的空间似乎无法携带更多的物品了。")

		return
	end

	if self:扣除仙玉(仙玉, "购买灵饰,等级为[" .. 等级 .. "],消费数额为" .. 仙玉, id) then
		添加最后对话(id, "你成功购买了一套" .. 等级 .. "级灵饰")
		礼包奖励类:全套灵饰(id, 等级, "无级别限制", 专用)
		广播消息({
			频道 = "xt",
			内容 = format("#G%s#R大手一挥,扔出一堆仙玉在建邺城装备购买员处购买了#G%s#R级全套灵饰,真是叫人羡慕呀#80", self.数据.名称, 等级)
		})
		道具刷新(id)
	end
end

function 角色处理类:完成法宝任务()
	名称 = {
		"定风珠",
		"雷兽",
		"迷魂灯",
		"幽灵珠",
		"缚妖索",
		"碧玉葫芦",
		"五色旗盒",
		"飞剑",
		"拭剑石",
		"金甲仙衣",
		"惊魂铃",
		"嗜血幡",
		"风袋",
		"九黎战鼓",
		"盘龙壁",
		"神行飞剑",
		"汇灵盏",
		"天师符",
		"织女扇",
		"清心咒"
	}

	return 名称[取随机数(1, #名称)]
end

function 角色处理类:取随机法宝()
	local 名称 = {
		"碧玉葫芦",
		"五色旗盒",
		"飞剑",
		"拭剑石",
		"金甲仙衣",
		"惊魂铃",
		"嗜血幡",
		"风袋",
		"清心咒",
		"九黎战鼓",
		"盘龙壁",
		"神行飞剑",
		"汇灵盏",
		"发瘟匣",
		"断线木偶",
		"五彩娃娃",
		"鬼泣",
		"月光宝盒",
		"混元伞",
		"无魂傀儡",
		"苍白纸人",
		"聚宝盆",
		"乾坤玄火塔",
		"无尘扇",
		"无字经"
	}

	if self.数据.门派 == "大唐官府" then
		名称 = {
			"七杀",
			"干将莫邪",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "化生寺" then
		名称 = {
			"慈悲",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "方寸山" then
		名称 = {
			"救命毫毛",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "天宫" then
		名称 = {
			"伏魔天书",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "普陀山" then
		名称 = {
			"金刚杵",
			"普渡",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "龙宫" then
		名称 = {
			"镇海珠",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "五庄观" then
		名称 = {
			"奇门五行令",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "狮驼岭" then
		名称 = {
			"兽王令",
			"失心钹",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "魔王寨" then
		名称 = {
			"五火神焰印",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	elseif self.数据.门派 == "阴曹地府" then
		名称 = {
			"九幽",
			"碧玉葫芦",
			"五色旗盒",
			"飞剑",
			"拭剑石",
			"金甲仙衣",
			"惊魂铃",
			"嗜血幡",
			"风袋",
			"清心咒",
			"九黎战鼓",
			"盘龙壁",
			"神行飞剑",
			"汇灵盏",
			"发瘟匣",
			"断线木偶",
			"五彩娃娃",
			"鬼泣",
			"月光宝盒",
			"混元伞",
			"无魂傀儡",
			"苍白纸人",
			"聚宝盆",
			"乾坤玄火塔",
			"无尘扇",
			"无字经"
		}
	end

	return 名称[取随机数(1, #名称)]
end

function 角色处理类:购买装备(等级, 仙玉, id)
	if self:取道具格子2() < 6 then
		添加最后对话(id, "你身上的空间似乎无法携带更多的物品了。")

		return
	end

	if self:扣除仙玉(仙玉, "购买装备,等级为[" .. 等级 .. "],消费数额为" .. 仙玉, id) then
		添加最后对话(id, "你成功购买了一套" .. 等级 .. "级装备")
		礼包奖励类:全套装备礼包(id, 等级, "无级别限制", "专用")
		广播消息({
			频道 = "xt",
			内容 = format("#G%s#R大手一挥,扔出一堆仙玉在建邺城装备购买员处购买了#G%s#R级全套装备,真是叫人羡慕呀#80", self.数据.名称, 等级)
		})
		道具刷新(id)
	end
end

function 角色处理类:购买装备礼包(等级, id)
	常规提示(id, "你成功获得了一套" .. 等级 .. "级装备")
	礼包奖励类:全套装备礼包(id, 等级, "无级别限制", "专用")
	道具刷新(id)
end

function 角色处理类:购买高级装备礼包(等级, id)
	常规提示(id, "你成功购买了一套" .. 等级 .. "级装备")
	礼包奖励类:全套高级装备礼包(id, 等级, "无级别限制", "专用")
	道具刷新(id)
end

function 角色处理类:购买超级神兽(仙玉, 类型, id)
	if 玩家数据[id].角色.数据.召唤兽携带数量 <= #玩家数据[id].召唤兽.数据 then
		常规提示(id, "#Y/你目前最多只能携带#R" .. 玩家数据[id].角色.数据.召唤兽携带数量 .. "只召唤兽")

		return
	end

	if self:扣除仙玉(仙玉, "购买超级神兽[" .. 类型 .. "],消费数额为" .. 仙玉, id) then
		玩家数据[id].召唤兽:添加召唤兽(类型, nil, nil, true, 0)
		常规提示(id, "#Y/你获得了一只#R/" .. 类型)
	end
end

function 角色处理类:扣除仙玉(数额, 事件, id)
	local 仙玉 = f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "仙玉") + 0 + (临时仙玉列表[玩家数据[id].账号] or 0)

	if 数额 < 0 or 数额 + 0 == nil then
		常规提示(id, "#Y你没有那么多的仙玉")

		return false
	end

	if 数额 <= 仙玉 then
		local 之前 = 仙玉
		仙玉 = 仙玉 - 数额

		f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "仙玉", 仙玉)

		临时仙玉列表[玩家数据[id].账号] = nil

		self:日志记录(format("事件:扣除仙玉,类型%s,数额%s,获得前%s,获得后%s", 事件, 数额, 之前, 仙玉))
		常规提示(id, "#Y你扣除了" .. 数额 .. "点仙玉")

		return true
	else
		常规提示(id, "#Y你没有那么多的仙玉")

		return false
	end
end

function 角色处理类:扣除点卡(数额, 事件, id)
	local 点卡 = f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "点卡") + 0

	if 数额 < 0 or 数额 + 0 == nil then
		常规提示(id, "#Y你没有那么多的点卡")

		return false
	end

	if 数额 <= 点卡 then
		local 之前 = 点卡
		点卡 = 点卡 - 数额

		f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "点卡", 点卡)

		local 日志 = 读入文件("data\\" .. 玩家数据[id].账号 .. "\\消费记录.txt")
		日志 = 日志 ..
			"\n" ..
			时间转换(os.time()) ..
			事件 ..
			format("。以下为具体扣费信息：扣除数额为%s点点卡,扣除之前点卡数额为%s点,扣除之后剩余点卡%s点。本次操作的角色id为%s,角色名称为%s#分割符\n", 数额, 之前, 点卡, self.数据.数字id,
				self.数据.名称)

		写出文件("data\\" .. 玩家数据[id].账号 .. "\\消费记录.txt", 日志)
		常规提示(id, "#Y你扣除了#R" .. 数额 .. "#Y点点卡,剩余#R" .. 点卡 .. "#Y点点卡。")

		return true
	else
		常规提示(id, "#Y你没有那么多的点卡")

		return false
	end
end

function 角色处理类:删除角色(id, 数据)
	local 删除 = 数据.文本 + 0
	local 玩家 = self.数据.数字id

	if 玩家 ~= 删除 then
		发送数据(玩家数据[id].连接id, 7, "/#Y/咋的少侠？你还想删了他人的角色吗#55")
	else
		local 写入信息 = table.loadstring(读入文件("data/" .. self.数据.账号 .. "/信息.txt"))

		for i, v in ipairs(写入信息) do
			if v == 删除 then
				table.remove(写入信息, i)
			end
		end

		写出文件("data/" .. self.数据.账号 .. "/信息.txt", table.tostring(写入信息))
		发送数据(玩家数据[id].连接id, 998, "你已经与这个世界隔离了,88了您")

		玩家数据[id].连接id = id

		系统处理类:断开游戏(id)

		__N连接数 = __N连接数 - 1
	end
end

玩家强化技能顺序调整 = function(角色数据)
	local tz = false

	if 角色数据.强化技能 == nil then
		角色数据.强化技能 = {}
	end

	if #角色数据.强化技能 == #角色强化技能列表 then
		for i = 1, #角色数据.强化技能 do
			if 角色数据.强化技能[i].名称 ~= 角色强化技能列表[i] then
				tz = true

				break
			end
		end
	else
		tz = true
	end

	if tz then
		local sx = 列表模式转换(角色强化技能列表)
		local sx1 = {}

		for i = 1, #角色数据.强化技能 do
			if sx[角色数据.强化技能[i].名称] ~= nil then
				sx1[sx[角色数据.强化技能[i].名称]] = 角色数据.强化技能[i]
			end
		end

		for i = 1, #角色强化技能列表 do
			if sx1[i] == nil then
				sx1[i] = {
					等级 = 60,
					名称 = 角色强化技能列表[i]
				}
			end
		end

		角色数据.强化技能 = sx1
	end
end

玩家辅助技能顺序调整 = function(角色数据)
	local tz = false

	if #角色数据.辅助技能 == #角色辅助技能列表 then
		for i = 1, #角色数据.辅助技能 do
			if 角色数据.辅助技能[i].名称 ~= 角色辅助技能列表[i] then
				tz = true

				break
			end
		end
	else
		tz = true
	end

	if tz then
		local sx = 列表模式转换(角色辅助技能列表)
		local sx1 = {}

		for i = 1, #角色数据.辅助技能 do
			if sx[角色数据.辅助技能[i].名称] ~= nil then
				sx1[sx[角色数据.辅助技能[i].名称]] = 角色数据.辅助技能[i]
			end
		end

		for i = 1, #角色辅助技能列表 do
			if sx1[i] == nil then
				sx1[i] = {
					等级 = 60,
					名称 = 角色辅助技能列表[i]
				}
			end
		end

		角色数据.辅助技能 = sx1
	end
end

function 角色处理类:加载数据(账号, id)
	self.数据 = table.loadstring(读入文件("data/" .. 账号 .. "/" .. id .. "/角色.txt"))
	self.数据.数字id = id

	if self.数据.变身数据 ~= nil and (self:取任务(1) == 0 or 任务数据[self:取任务(1)] == nil) then
		self:取消任务(self:取任务(1))

		self.数据.变身数据 = nil

		if self.数据.变异 ~= nil then
			self.数据.变异 = nil
		end
	end

	for n, v in pairs(self.数据.任务) do
		if 任务数据[v] == nil then
			self.数据.任务[n] = nil
		end
	end

	if self.数据.当前剧情 == nil then
		self.数据.当前剧情 = {}
	end

	玩家辅助技能顺序调整(self.数据)
	玩家强化技能顺序调整(self.数据)

	玩家数据[self.数据.数字id].联机 = not 单机设置

	发送数据(玩家数据[self.数据.数字id].连接id, 133, {
		月卡激活 = self.数据.月卡激活,
		到期时间 = self.数据.飞行时间限制,
		联机 = 玩家数据[self.数据.数字id].联机,
		点卡 = 取点卡数据(nil, 账号)
	})
	发送数据(玩家数据[self.数据.数字id].连接id, 133.5, {
		挂机月卡 = self.数据.挂机月卡,
		到期时间 = self.数据.挂机时间限制,
		点卡 = 取点卡数据(nil, 账号)
	})

	if self.数据.接受给予 == nil then
		self.数据.接受给予 = true
	end

	if self.数据.账号 ~= 账号 then
		self.数据.账号 = 账号
	end

	if f函数.文件是否存在("data/" .. 账号 .. "/" .. id .. "/日志记录/" .. self.数据.日志编号 .. ".txt") == false then
		self.日志内容 = "日志创建\n"

		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/日志记录/" .. self.数据.日志编号 .. ".txt", "日志创建\n")
	end

	self.日志内容 = 读入文件("data/" .. 账号 .. "/" .. id .. "/日志记录/" .. self.数据.日志编号 .. ".txt") .. "\n"

	if self.数据.自动遇怪 then
		自动遇怪[self.数据.数字id] = os.time()

		return 0
	end

	if self.数据.自动捉鬼 then
		自动捉鬼[self.数据.数字id] = os.time()

		return 0
	end

	if self.数据.飞行中 then
		self.数据.飞行中 = false
	end
end

function 角色处理类:取地图数据()
	local 要求数据 = {
		x = self.数据.地图数据.x,
		y = self.数据.地图数据.y,
		名称 = self.数据.名称,
		模型 = self.数据.模型,
		id = self.数据.数字id,
		种族 = self.数据.种族,
		门派 = self.数据.门派,
		帮派 = self.数据.帮派 or "无帮派",
		当前称谓 = self.数据.当前称谓,
		队长 = 玩家数据[self.数据.数字id].队长,
		染色组 = self.数据.染色组,
		染色方案 = self.数据.染色方案,
		变身数据 = self.数据.变身数据,
		变异 = self.数据.变异,
		战斗开关 = self.战斗开关,
		坐骑 = self.数据.坐骑,
		锦衣 = {},
		pk开关 = self.数据.PK开关,
		强p开关 = self.数据.强P开关,
		月卡激活 = self.数据.月卡激活,
		移速加成 = self.数据.移速加成,
		飞行中 = self.数据.飞行中
	}

	if self.数据.装备[3] ~= nil then
		要求数据.武器 = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.装备[3]]))
	end

	if self.数据.装备[4] ~= nil and self.数据.模型 == "影精灵" and 玩家数据[self.数据.数字id].道具.数据[self.数据.装备[4]].子类 == 911 then
		要求数据.副武器 = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.装备[4]]))
	end

	if self.数据.锦衣[1] ~= nil then
		要求数据.锦衣[1] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[1]]))
	end

	if self.数据.锦衣[2] ~= nil then
		要求数据.锦衣[2] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[2]]))
	end

	if self.数据.锦衣[3] ~= nil then
		要求数据.锦衣[3] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[3]]))
	end

	if self.数据.锦衣[4] ~= nil then
		要求数据.锦衣[4] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[4]]))
	end

	if 玩家数据[self.数据.数字id].摊位数据 ~= nil then
		要求数据.摊位名称 = 玩家数据[self.数据.数字id].摊位数据.名称
	end

	return 要求数据
end

function 角色处理类:取队伍信息()
	local 发送数据 = {
		模型 = self.数据.模型,
		染色 = self.染色,
		等级 = self.数据.等级,
		名称 = self.数据.名称,
		门派 = self.数据.门派,
		染色组 = self.数据.染色组,
		染色方案 = self.数据.染色方案,
		当前称谓 = self.数据.当前称谓,
		id = self.数据.数字id,
		变身数据 = self.数据.变身数据,
		变异 = self.数据.变异,
		坐骑 = self.数据.坐骑,
		装备 = {},
		锦衣 = {}
	}

	if self.数据.装备[3] ~= nil then
		发送数据.装备[3] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.装备[3]]))
	end

	if self.数据.模型 == "影精灵" and self.数据.装备[4] ~= nil and 玩家数据[self.数据.数字id].道具.数据[self.数据.装备[4]].子类 == 911 then
		发送数据.装备[4] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.装备[4]]))
	end

	if self.数据.锦衣[1] ~= nil then
		发送数据.锦衣[1] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[1]]))
	end

	if self.数据.锦衣[2] ~= nil then
		发送数据.锦衣[2] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[2]]))
	end

	if self.数据.锦衣[3] ~= nil then
		发送数据.锦衣[3] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[3]]))
	end

	if self.数据.锦衣[4] ~= nil then
		发送数据.锦衣[4] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[4]]))
	end

	return 发送数据
end

不必要数据列表 = {
	技能 = 1,
	五宝数据 = 1,
	超级行囊 = 1,
	道具 = 1,
	对话类型 = 1,
	军功 = 1,
	好友数据 = 1,
	转换角色次数 = 1,
	灵饰 = 1,
	装备 = 1,
	法宝 = 1,
	召唤兽仓库 = 1,
	道具仓库 = 1,
	锦衣 = 1,
	助战好友度 = 1,
	行囊 = 1
}

function 角色处理类:取总数据(战斗)
	local 存档数据 = {}

	if self.数据.气血上限 == nil then
		self.数据.气血上限 = self.数据.最大气血
	end

	if self.数据.最大气血 < self.数据.气血上限 then
		self.数据.气血上限 = self.数据.最大气血
	end

	if self.数据.气血上限 < self.数据.气血 then
		self.数据.气血 = self.数据.气血上限
	end

	for i, v in pairs(self.数据) do
		if 不必要数据列表[i] == nil then
			存档数据[i] = self.数据[i]
		end
	end

	if 战斗 == nil then
		存档数据.装备 = self:取装备数据()
		存档数据.灵饰 = self:取灵饰数据()
		存档数据.锦衣 = self:取锦衣数据()
	end

	存档数据.时辰 = 时辰信息.当前

	if 强化技能 and self.数据.强化技能 == nil then
		self.数据.强化技能 = {
			{
				等级 = 0,
				名称 = "强化气血上限"
			},
			{
				等级 = 0,
				名称 = "强化魔法上限"
			},
			{
				等级 = 0,
				名称 = "强化伤害"
			},
			{
				等级 = 0,
				名称 = "强化法伤"
			},
			{
				等级 = 0,
				名称 = "强化物理防御"
			},
			{
				等级 = 0,
				名称 = "强化法防"
			},
			{
				等级 = 0,
				名称 = "强化固定伤害"
			},
			{
				等级 = 0,
				名称 = "强化封印命中等级"
			},
			{
				等级 = 0,
				名称 = "强化抵抗封印等级"
			},
			{
				等级 = 0,
				名称 = "强化治疗能力"
			}
		}
	end

	return 存档数据
end

function 角色处理类:存档()
	if self.日志内容 == nil then
		self.日志内容 = "日志创建\n"
	end

	写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/日志记录/" .. self.数据.日志编号 .. ".txt", self.日志内容)

	if string.len(self.日志内容) >= 10240 then
		self.日志内容 = "日志创建\n"
		self.数据.日志编号 = self.数据.日志编号 + 1

		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/日志记录/" .. self.数据.日志编号 .. ".txt", "日志创建\n")
	end

	写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/角色.txt", table.tostring(self.数据))

	if 玩家数据[self.数据.数字id] == nil then
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/道具.txt", table.tostring({}))
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/召唤兽.txt", table.tostring({}))
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/助战.txt", table.tostring({}))
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/召唤兽仓库.txt", table.tostring({
			{}
		}))
	else
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/道具.txt", table.tostring(玩家数据[self.数据.数字id].道具.数据))
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/召唤兽.txt", table.tostring(玩家数据[self.数据.数字id].召唤兽:取存档数据()))
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/助战.txt", table.tostring(玩家数据[self.数据.数字id].助战:取数据()))
		写出文件("data/" .. self.数据.账号 .. "/" .. self.数据.数字id .. "/召唤兽仓库.txt", table.tostring(玩家数据[self.数据.数字id].召唤兽仓库.数据))
	end
end

function 角色处理类:加入门派(id, 门派)
	if 可入门派[self.数据.种族][门派] == nil and 可入门派[self.数据.种族][self.数据.性别][门派] == nil and (f函数.读配置(程序目录 .. "配置文件.ini", "主要配置", "门派限制") == nil or f函数.读配置(程序目录 .. "配置文件.ini", "主要配置", "门派限制") == "" or f函数.读配置(程序目录 .. "配置文件.ini", "主要配置", "门派限制") == 1 or f函数.读配置(程序目录 .. "配置文件.ini", "主要配置", "门派限制") == "1") then
		常规提示(id, "本门派不收你这样的弟子")

		return
	elseif self.数据.门派 ~= "无门派" then
		常规提示(id, "#Y你已经投入其它门派")

		return
	end

	self.数据.门派 = 门派

	常规提示(id, "你成为了#R/" .. 门派 .. "#Y/弟子")
	发送数据(玩家数据[self.数据.数字id].连接id, 31.2, 门派)

	self.数据.师门技能 = {}

	if self.数据.门派 ~= "无门派" and self.数据.师门技能[1] == nil then
		local 列表 = 取门派技能(self.数据.门派)

		for n = 1, #列表 do
			self.数据.师门技能[n] = jnzb()

			self.数据.师门技能[n]:置对象(列表[n])

			self.数据.师门技能[n].包含技能 = {}
			self.数据.师门技能[n].等级 = 30
			local w = 取包含技能(self.数据.师门技能[n].名称)

			for s = 1, #w do
				self.数据.师门技能[n].包含技能[s] = jnzb()

				self.数据.师门技能[n].包含技能[s]:置对象(w[s])

				self.数据.师门技能[n].包含技能[s].等级 = 0
			end
		end
	end

	if self.数据.帮派数据 == nil then
		self.数据.帮派数据 = {
			权限 = 0
		}
	end

	if self.数据.帮派数据.编号 ~= nil then
		local 帮派编号 = self.数据.帮派数据.编号
		local id2 = self.数据.ID
		帮派数据[帮派编号].成员数据[id2].门派 = self.数据.门派
	end

	礼包奖励类:设置拜师奖励(self.数据.数字id)
end

角色卸下灵饰 = function(id, 角色数据, 道具)
	if 道具 == nil then
		return false
	end

	for n = 1, #灵饰正常属性 do
		if 道具.幻化属性.基础.类型 == 灵饰正常属性[n] then
			角色数据.装备属性[灵饰正常属性[n]] = 角色数据.装备属性[灵饰正常属性[n]] - 道具.幻化属性.基础.数值
		end

		for i = 1, #道具.幻化属性.附加 do
			if 道具.幻化属性.附加[i].类型 == 灵饰正常属性[n] then
				角色数据.装备属性[灵饰正常属性[n]] = 角色数据.装备属性[灵饰正常属性[n]] - 道具.幻化属性.附加[i].数值 - 道具.幻化属性.附加[i].强化
			end
		end
	end

	for n = 1, #灵饰战斗属性 do
		if 道具.幻化属性.基础.类型 == 灵饰战斗属性[n] and 角色数据.装备属性[灵饰战斗属性[n]] ~= nil then
			角色数据.装备属性[灵饰战斗属性[n]] = 角色数据.装备属性[灵饰战斗属性[n]] - 道具.幻化属性.基础.数值
		end

		for i = 1, #道具.幻化属性.附加 do
			if 道具.幻化属性.附加[i].类型 == 灵饰战斗属性[n] and 角色数据.装备属性[灵饰战斗属性[n]] ~= nil then
				角色数据.装备属性[灵饰战斗属性[n]] = 角色数据.装备属性[灵饰战斗属性[n]] - 道具.幻化属性.附加[i].数值 - 道具.幻化属性.附加[i].强化
			end
		end
	end

	if 道具.附加特性 ~= nil and 道具.附加特性.幻化类型 ~= nil then
		角色数据[道具.附加特性.幻化类型] = 角色数据[道具.附加特性.幻化类型] - 道具.附加特性.幻化等级

		if 角色数据[道具.附加特性.幻化类型] <= 0 then
			角色数据[道具.附加特性.幻化类型] = nil
		end
	end

	for n = 1, #灵饰正常属性1 do
		if 道具[灵饰正常属性1[n]] ~= nil and 道具[灵饰正常属性1[n]] > 0 then
			角色数据.装备属性[灵饰正常属性1[n]] = 角色数据.装备属性[灵饰正常属性1[n]] - 道具[灵饰正常属性1[n]]
		end
	end
end

角色卸下法宝 = function(连接id, id, 角色数据, 编号, 助战编号, 替换指定格子)
	if 助战编号 ~= nil then
		local 格子 = 玩家数据[id].角色:取道具格子()

		if 替换指定格子 ~= nil then
			格子 = 替换指定格子
		elseif 格子 == 0 then
			常规提示(id, "#Y你的道具已经满了")

			return
		end

		玩家数据[id].角色.数据.道具[格子] = 角色数据.法宝佩戴[编号]
		角色数据.法宝佩戴[编号] = nil

		刷新道具行囊单格(id, "道具", 格子, 玩家数据[id].角色.数据.道具[格子])
		发送数据(连接id, 104.2, 玩家数据[id].助战:取法宝数据(连接id, id, 助战编号))
		玩家数据[id].助战:索要法宝(连接id, id, 助战编号)
	else
		local 格子 = 玩家数据[id].角色:取法宝格子()

		if 替换指定格子 ~= nil then
			格子 = 替换指定格子
		elseif 格子 == 0 then
			常规提示(id, "#Y你的法宝栏已经满了")

			return
		end

		local 名称 = 玩家数据[id].道具.数据[玩家数据[id].角色.数据.法宝佩戴[编号]].名称
		local 境界 = 玩家数据[id].道具.数据[玩家数据[id].角色.数据.法宝佩戴[编号]].气血

		if 名称 == "通灵宝玉" then
			玩家数据[id].角色.数据[名称] = math.max((玩家数据[id].角色.数据[名称] or 0) - qz(境界 / 3 * 2) / 100, 0)
		end

		if 名称 == "聚宝盆" then
			玩家数据[id].角色.数据[名称] = math.max((玩家数据[id].角色.数据[名称] or 0) - qz(境界 / 3 * 2) / 100, 0)
		end

		玩家数据[id].角色.数据.法宝[格子] = 玩家数据[id].角色.数据.法宝佩戴[编号]
		玩家数据[id].角色.数据.法宝佩戴[编号] = nil

		刷新道具行囊单格(id, "法宝", 格子, 玩家数据[id].角色.数据.法宝[格子])
		玩家数据[id].道具:索要法宝(连接id, id)
	end
end

角色佩戴法宝 = function(连接id, id, 角色数据, 编号, 助战编号)
	local 道具id, 道具1 = nil
	local 角色道具数据 = 玩家数据[id].角色.数据
	local 道具数据 = 玩家数据[id].道具.数据

	if 助战编号 ~= nil then
		道具1 = 角色道具数据.道具
		道具id = 角色道具数据.道具[编号]

		if 角色道具数据.道具[编号] == nil or 道具id == nil or 道具数据[道具id] == nil then
			玩家数据[id].助战:索要法宝(连接id, id, 助战编号)

			return
		end
	else
		道具1 = 角色道具数据.法宝
		道具id = 角色道具数据.法宝[编号]

		if 角色道具数据.法宝[编号] == nil or 道具id == nil or 道具数据[道具id] == nil then
			玩家数据[id].道具:索要法宝(连接id, id)

			return
		end
	end

	local 名称 = 道具数据[道具id].名称
	local 境界 = 道具数据[道具id].气血
	local 门派 = 角色数据.门派
	local 个数 = 法宝列表1[名称]
	local 级别 = 道具数据[道具id].分类

	if 个数 ~= nil then
		if 个数 == 0 then
			常规提示(id, "#Y主动法宝无法佩戴！")

			return
		end

		local aa = 取物品数据(名称)[6]

		if aa ~= nil and 道具数据[道具id].特技 ~= nil and 道具数据[道具id].特技 ~= aa then
			道具数据[道具id].特技 = aa
		end

		local aa = 取物品数据(名称)[5]

		if aa ~= nil and 道具数据[道具id].使用 ~= nil and 道具数据[道具id].使用 ~= aa then
			道具数据[道具id].使用 = aa
		end
	else
		常规提示(id, "#Y非法宝无法佩戴！")

		return
	end

	if 名称 == "天师符" and 门派 ~= "方寸山" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "织女扇" and 门派 ~= "女儿村" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "雷兽" and 门派 ~= "天宫" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "定风珠" and 门派 ~= "五庄观" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "七杀" and 门派 ~= "大唐官府" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "罗汉珠" and 门派 ~= "化生寺" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "天师符" and 门派 ~= "方寸山" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "金刚杵" and 门派 ~= "普陀山" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "兽王令" and 门派 ~= "狮驼岭" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "摄魂" and 门派 ~= "阴曹地府" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "干将莫邪" and 门派 ~= "大唐官府" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "慈悲" and 门派 ~= "化生寺" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "救命毫米" and 门派 ~= "方寸山" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "伏魔天书" and 门派 ~= "天宫" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "普渡" and 门派 ~= "普陀山" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "镇海珠" and 门派 ~= "龙宫" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "奇门五行令" and 门派 ~= "五庄观" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "失心钹" and 门派 ~= "狮驼岭" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "五火神焰印" and 门派 ~= "魔王寨" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "九幽" and 门派 ~= "阴曹地府" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "月影" and 门派 ~= "神木林" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "驭魔笼" and 门派 ~= "九黎城" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "金蟾" and 门派 ~= "无底洞" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "斩魔" and 门派 ~= "凌波城" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "琉璃灯" and 门派 ~= "花果山" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	elseif 名称 == "金箍棒" and 门派 ~= "花果山" then
		常规提示(id, "#Y你的门派不允许你使用这样的法宝")

		return
	end

	local 佩戴格子 = 0

	for n = 1, 4 do
		if 角色数据.法宝佩戴[n] == nil then
			佩戴格子 = n

			break
		end
	end

	if 佩戴格子 == 0 then
		佩戴格子 = 4
	end

	local lb = {}
	local mc = {}
	local jb = {}
	local md = 法宝矛盾列表[名称]

	for n = 1, 4 do
		if n ~= 佩戴格子 and 角色数据.法宝佩戴[n] ~= nil then
			local 法宝类型 = 玩家数据[id].道具.数据[角色数据.法宝佩戴[n]].特技
			local 法宝名称 = 玩家数据[id].道具.数据[角色数据.法宝佩戴[n]].名称
			local 法宝级别 = 玩家数据[id].道具.数据[角色数据.法宝佩戴[n]].分类
			lb[法宝类型] = (lb[法宝类型] or 0) + 1
			mc[法宝名称] = (mc[法宝名称] or 0) + 1
			jb[法宝级别] = (jb[法宝级别] or 0) + 1

			if md ~= nil and md[法宝名称] ~= nil then
				常规提示(id, "#R" .. 名称 .. "#Y无法和#R" .. 法宝名称 .. "#Y同时佩戴。")

				return
			end
		end
	end

	if mc[名称] ~= nil and 个数 < mc[名称] + 1 then
		常规提示(id, "#R" .. 名称 .. "#Y法宝最多只能佩戴#R" .. 个数 .. "#Y件")

		return
	end

	if 级别 == 4 and jb[4] == 2 then
		常规提示(id, "#Y四级法宝只能同时佩戴两件")

		return
	end

	local 法宝类型 = 道具数据[道具id].特技 + 0

	if (lb[法宝类型] or 0) >= 2 then
		常规提示(id, "#Y此类型法宝只能同时佩戴两件")

		return
	end

	道具1[编号] = nil

	if 角色数据.法宝佩戴[佩戴格子] ~= nil then
		角色卸下法宝(连接id, id, 角色数据, 佩戴格子, 助战编号, 编号)
	end

	角色数据.法宝佩戴[佩戴格子] = 道具id

	if 名称 == "聚宝盆" and 助战编号 == nil then
		玩家数据[id].角色.数据.聚宝盆 = (玩家数据[id].角色.数据.聚宝盆 or 0) + qz(境界 / 3) / 100
	end

	if 名称 == "通灵宝玉" and 助战编号 == nil then
		玩家数据[id].角色.数据.通灵宝玉 = (玩家数据[id].角色.数据.通灵宝玉 or 0) + qz(境界 / 3 * 2) / 100
	end

	if 助战编号 ~= nil then
		刷新道具行囊单格(id, "道具", 编号, 角色道具数据.道具[编号])
		发送数据(连接id, 104.2, 玩家数据[id].助战:取法宝数据(连接id, id, 助战编号))
	else
		刷新道具行囊单格(id, "法宝", 编号, 角色道具数据.法宝[编号])
		玩家数据[id].道具:索要法宝(连接id, id)
	end
end

角色佩戴灵饰 = function(id, 角色数据, 道具)
	for n = 1, #灵饰正常属性 do
		if 道具.幻化属性.基础.类型 == 灵饰正常属性[n] then
			角色数据.装备属性[灵饰正常属性[n]] = 角色数据.装备属性[灵饰正常属性[n]] + 道具.幻化属性.基础.数值
		end

		for i = 1, #道具.幻化属性.附加 do
			if 道具.幻化属性.附加[i].类型 == 灵饰正常属性[n] then
				角色数据.装备属性[灵饰正常属性[n]] = 角色数据.装备属性[灵饰正常属性[n]] + 道具.幻化属性.附加[i].数值 + 道具.幻化属性.附加[i].强化
			end
		end
	end

	for n = 1, #灵饰战斗属性 do
		if 道具.幻化属性.基础.类型 == 灵饰战斗属性[n] then
			角色数据.装备属性[灵饰战斗属性[n]] = (角色数据.装备属性[灵饰战斗属性[n]] or 0) + 道具.幻化属性.基础.数值
		end

		for i = 1, #道具.幻化属性.附加 do
			if 道具.幻化属性.附加[i].类型 == 灵饰战斗属性[n] then
				角色数据.装备属性[灵饰战斗属性[n]] = (角色数据.装备属性[灵饰战斗属性[n]] or 0) + 道具.幻化属性.附加[i].数值 + 道具.幻化属性.附加[i].强化
			end
		end
	end

	if 道具.附加特性 ~= nil and 道具.附加特性.幻化类型 ~= nil then
		if 角色数据[道具.附加特性.幻化类型] == nil then
			角色数据[道具.附加特性.幻化类型] = 道具.附加特性.幻化等级
		else
			角色数据[道具.附加特性.幻化类型] = 角色数据[道具.附加特性.幻化类型] + 道具.附加特性.幻化等级
		end
	end

	for n = 1, #灵饰正常属性1 do
		if 道具[灵饰正常属性1[n]] ~= nil and 道具[灵饰正常属性1[n]] > 0 then
			角色数据.装备属性[灵饰正常属性1[n]] = 角色数据.装备属性[灵饰正常属性1[n]] + 道具[灵饰正常属性1[n]]
		end
	end
end

function 角色处理类:佩戴灵饰(道具)
	角色佩戴灵饰(self.数据.id, self.数据, 道具)
	self:刷新信息("6")
end

function 角色处理类:卸下灵饰(道具, 不刷新)
	if 角色卸下灵饰(self.数据.id, self.数据, 道具) ~= false and 不刷新 == nil then
		self:刷新信息("6")
	end
end

刷新附魔 = function(id, 装备, 角色数据)
	local 刷新判定 = false

	for i, v in pairs(装备.临时附魔) do
		if 装备.临时附魔[i].数值 > 0 and type(装备.临时附魔[i].时间) == "string" and tonumber(装备.临时附魔[i].时间) == nil then
			local 月份 = 分割文本(装备.临时附魔[i].时间, "/")
			local 日份 = 分割文本(月份[3], " ")
			local 时分 = 分割文本(日份[2], ":")
			local 时间戳 = os.time({
				second = 0,
				minute = 0,
				day = 日份[1],
				month = 月份[2],
				year = 月份[1],
				hour = 时分[1]
			}) + 时分[2] * 60

			if os.time() - 时间戳 >= 0 then
				if 角色数据 ~= nil then
					角色数据.装备属性[i] = 角色数据.装备属性[i] - 装备.临时附魔[i].数值
				end

				装备.临时附魔[i].数值 = 0
				装备.临时附魔[i].时间 = 0
				刷新判定 = true

				常规提示(id, "#Y/你的" .. 装备.名称 .. "附魔特效消失了！")
			end
		end
	end

	return 刷新判定
end

附魔刷新 = function(id, 装备id, 角色数据)
	local 刷新判定 = false
	local 临时道具id = 装备id
	local 装备 = 玩家数据[id].道具.数据[临时道具id]
	刷新判定 = 刷新附魔(id, 装备, 角色数据)

	return 刷新判定
end

function 角色处理类:附魔装备刷新(id, 装备id)
	local 刷新判定 = 附魔刷新(id, 装备id, 玩家数据[id].角色.数据)

	if 刷新判定 then
		道具刷新(id, 1)
		self:刷新信息("2")
	end
end

角色卸下装备 = function(id, 传入数据, 装备, 格子)
	if 装备.耐久 ~= nil and 装备.耐久 <= 0 and 玩家数据[id].无耐久减属性 == nil then
		return
	end

	if 装备.星位 ~= nil then
		for a = 1, 5 do
			if 装备.星位[a] ~= nil and 装备.星位[a].符石属性 ~= nil then
				for k, v in pairs(装备.星位[a].符石属性) do
					if 传入数据.装备属性 ~= nil and 传入数据.装备属性[k] ~= nil then
						传入数据.装备属性[k] = 传入数据.装备属性[k] - v
					end
				end
			end
		end

		if 装备.星位.组合 ~= nil and 装备.星位.组合等级 ~= nil then
			local 师门技能列表 = 列表模式转换(取门派技能(传入数据.门派))
			local 星位技能 = ""

			if string.find(装备.星位.组合, "符石") then
				星位技能 = 分割文本(装备.星位.组合, "符石")[1]
			end

			if 星位技能 ~= "" and 师门技能列表[星位技能] ~= nil then
				local n = 师门技能列表[星位技能]
				传入数据.装备属性[星位技能 .. "等级"] = math.max((传入数据.装备属性[星位技能 .. "等级"] or 0) - (符石技能等级[装备.星位.组合等级] or 0), 0)
			end
		end

		if 装备.星位[6] ~= nil then
			if 装备.星位[6].符石属性 ~= nil then
				for k, v in pairs(装备.星位[6].符石属性) do
					传入数据.装备属性[k] = 传入数据.装备属性[k] - v
				end
			end

			if 装备.星位[6].相互 ~= nil then
				for k, v in pairs(装备.星位[6].相互) do
					传入数据.装备属性[k] = 传入数据.装备属性[k] - v
				end
			end
		end
	end

	if 装备.熔炼属性 ~= nil then
		for i = 1, #装备.熔炼属性 do
			if 装备.熔炼属性[i] ~= nil then
				if 装备.熔炼属性[i][1] == "气血" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.气血 = 传入数据.装备属性.气血 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "气血" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.气血 = 传入数据.装备属性.气血 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "魔法" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.魔法 = 传入数据.装备属性.魔法 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "魔法" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.魔法 = 传入数据.装备属性.魔法 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "命中" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.命中 = 传入数据.装备属性.命中 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "命中" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.命中 = 传入数据.装备属性.命中 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "伤害" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.伤害 = 传入数据.装备属性.伤害 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "伤害" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.伤害 = 传入数据.装备属性.伤害 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "防御" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.防御 = 传入数据.装备属性.防御 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "防御" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.防御 = 传入数据.装备属性.防御 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "速度" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.速度 = 传入数据.装备属性.速度 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "速度" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.速度 = 传入数据.装备属性.速度 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "灵力" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.灵力 = 传入数据.装备属性.灵力 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "灵力" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.灵力 = 传入数据.装备属性.灵力 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "力量" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.力量 = 传入数据.装备属性.力量 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "力量" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.力量 = 传入数据.装备属性.力量 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "体质" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.体质 = 传入数据.装备属性.体质 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "体质" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.体质 = 传入数据.装备属性.体质 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "耐力" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.耐力 = 传入数据.装备属性.耐力 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "耐力" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.耐力 = 传入数据.装备属性.耐力 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "敏捷" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.敏捷 = 传入数据.装备属性.敏捷 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "敏捷" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.敏捷 = 传入数据.装备属性.敏捷 + (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "魔力" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.魔力 = 传入数据.装备属性.魔力 - (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "魔力" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.魔力 = 传入数据.装备属性.魔力 + (装备.熔炼属性[i][2] or 0)
				end
			end
		end
	end

	if 装备.分类 == 4 and 装备.子类 == 911 then
		传入数据.铸斧 = (传入数据.铸斧 or 0) - 1
	elseif 装备.分类 == 3 and 装备.子类 == 910 then
		传入数据.铸斧 = (传入数据.铸斧 or 0) - 1
	end

	传入数据.铸斧 = math.max(math.min(传入数据.铸斧 or 0, 2), 0)

	if 传入数据.铸斧 <= 0 then
		传入数据.铸斧 = nil
	end

	if 装备.临时附魔 ~= nil then
		for i = 1, #附魔属性列表 do
			if 装备.临时附魔[附魔属性列表[i]] ~= nil then
				传入数据.装备属性[附魔属性列表[i]] = (传入数据.装备属性[附魔属性列表[i]] or 0) - (装备.临时附魔[附魔属性列表[i]].数值 or 0)
			end
		end
	end

	if 装备.临时附魔 ~= nil and 刷新附魔(id, 装备) then
		道具刷新(id, 1)
	end

	for i = 1, #装备基础属性列表 do
		传入数据.装备属性[装备基础属性列表[i]] = (传入数据.装备属性[装备基础属性列表[i]] or 0) - (装备[装备基础属性列表[i]] or 0)
	end

	if 装备.染色效果 ~= nil and 传入数据.装备属性[装备.染色效果.类型] ~= nil then
		传入数据.装备属性[装备.染色效果.类型] = 传入数据.装备属性[装备.染色效果.类型] - 装备.染色效果.数值
	end

	if 装备.特殊附加属性 ~= nil and 传入数据.装备属性[装备.特殊附加属性.类型] ~= nil then
		传入数据.装备属性[装备.特殊附加属性.类型] = 传入数据.装备属性[装备.特殊附加属性.类型] - 装备.特殊附加属性.数值
	end

	if 装备.超级五行 ~= nil and 装备.超级五行.类型 ~= nil and 传入数据.装备属性[装备.超级五行.属性] ~= nil then
		传入数据.装备属性[装备.超级五行.属性] = 传入数据.装备属性[装备.超级五行.属性] - 装备.超级五行.数值
	end

	if 装备.百炼效果 ~= nil and 格子 < 7 then
		if 传入数据.百炼数据 == nil then
			传入数据.百炼数据 = {}
		end

		for i = 1, #装备.百炼效果 do
			if 传入数据.装备属性[装备.百炼效果[i].类别] ~= nil then
				if 百炼词条叠加 == true then
					传入数据.装备属性[装备.百炼效果[i].类别] = math.max(传入数据.装备属性[装备.百炼效果[i].类别] - 装备.百炼效果[i].数值, 0)
				else
					传入数据.装备属性[装备.百炼效果[i].类别] = 0
				end
			end
		end

		传入数据.百炼数据[格子] = {}

		if not 百炼词条叠加 then
			for i = 1, #百炼2 do
				传入数据.装备属性[百炼2[i] .. "百分百"] = 0
			end

			local aa = {}

			for k, v in pairs(传入数据.百炼数据) do
				for n, m in pairs(v) do
					aa[n] = math.max(aa[n] or 0, m)
				end
			end

			for k, v in pairs(aa) do
				传入数据.装备属性[k] = v
			end
		end
	end
end

角色穿戴装备 = function(id, 传入数据, 装备, 格子)
	if 装备.星位 ~= nil then
		for a = 1, 5 do
			if 装备.星位[a] ~= nil and 装备.星位[a].符石属性 ~= nil then
				for k, v in pairs(装备.星位[a].符石属性) do
					if 传入数据.装备属性 ~= nil and 传入数据.装备属性[k] ~= nil then
						传入数据.装备属性[k] = 传入数据.装备属性[k] + v
					end
				end
			end
		end

		if 装备.星位.组合 ~= nil and 装备.星位.组合等级 ~= nil then
			local 师门技能列表 = 列表模式转换(取门派技能(传入数据.门派))
			local 星位技能 = ""

			if string.find(装备.星位.组合, "符石") then
				星位技能 = 分割文本(装备.星位.组合, "符石")[1]
			end

			if 星位技能 ~= "" and 师门技能列表[星位技能] ~= nil then
				local n = 师门技能列表[星位技能]
				传入数据.装备属性[星位技能 .. "等级"] = math.max((传入数据.装备属性[星位技能 .. "等级"] or 0) + (符石技能等级[装备.星位.组合等级] or 0), 0)
			end
		end

		if 装备.星位[6] ~= nil then
			if 装备.星位[6].符石属性 ~= nil then
				for k, v in pairs(装备.星位[6].符石属性) do
					传入数据.装备属性[k] = 传入数据.装备属性[k] + v
				end
			end

			if 装备.星位[6].相互 ~= nil then
				for k, v in pairs(装备.星位[6].相互) do
					传入数据.装备属性[k] = 传入数据.装备属性[k] + v
				end
			end
		end
	end

	if 装备.临时附魔 ~= nil and 刷新附魔(id, 装备) then
		道具刷新(id, 1)
	end

	if 装备.熔炼属性 ~= nil then
		for i = 1, #装备.熔炼属性 do
			if 装备.熔炼属性[i] ~= nil then
				if 装备.熔炼属性[i][1] == "气血" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.气血 = 传入数据.装备属性.气血 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "气血" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.气血 = 传入数据.装备属性.气血 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "魔法" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.魔法 = 传入数据.装备属性.魔法 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "魔法" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.魔法 = 传入数据.装备属性.魔法 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "命中" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.命中 = 传入数据.装备属性.命中 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "命中" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.命中 = 传入数据.装备属性.命中 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "伤害" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.伤害 = 传入数据.装备属性.伤害 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "伤害" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.伤害 = 传入数据.装备属性.伤害 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "防御" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.防御 = 传入数据.装备属性.防御 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "防御" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.防御 = 传入数据.装备属性.防御 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "速度" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.速度 = 传入数据.装备属性.速度 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "速度" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.速度 = 传入数据.装备属性.速度 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "灵力" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.灵力 = 传入数据.装备属性.灵力 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "灵力" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.灵力 = 传入数据.装备属性.灵力 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "力量" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.力量 = 传入数据.装备属性.力量 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "力量" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.力量 = 传入数据.装备属性.力量 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "体质" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.体质 = 传入数据.装备属性.体质 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "体质" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.体质 = 传入数据.装备属性.体质 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "耐力" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.耐力 = 传入数据.装备属性.耐力 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "耐力" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.耐力 = 传入数据.装备属性.耐力 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "敏捷" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.敏捷 = 传入数据.装备属性.敏捷 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "敏捷" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.敏捷 = 传入数据.装备属性.敏捷 - (装备.熔炼属性[i][2] or 0)
				end

				if 装备.熔炼属性[i][1] == "魔力" and 装备.熔炼属性[i][3] == "+" then
					传入数据.装备属性.魔力 = 传入数据.装备属性.魔力 + (装备.熔炼属性[i][2] or 0)
				elseif 装备.熔炼属性[i][1] == "魔力" and 装备.熔炼属性[i][3] == "-" then
					传入数据.装备属性.魔力 = 传入数据.装备属性.魔力 - (装备.熔炼属性[i][2] or 0)
				end
			end
		end
	end

	if 装备.临时附魔 ~= nil then
		for i = 1, #附魔属性列表 do
			if 装备.临时附魔[附魔属性列表[i]] ~= nil then
				传入数据.装备属性[附魔属性列表[i]] = (传入数据.装备属性[附魔属性列表[i]] or 0) + (装备.临时附魔[附魔属性列表[i]].数值 or 0)
			end
		end
	end

	if 装备.分类 == 4 and 装备.子类 == 911 then
		传入数据.铸斧 = (传入数据.铸斧 or 0) + 1
	elseif 装备.分类 == 3 and 装备.子类 == 910 then
		传入数据.铸斧 = (传入数据.铸斧 or 0) + 1
	end

	传入数据.铸斧 = math.max(math.min(传入数据.铸斧 or 0, 2), 0)

	if 传入数据.铸斧 <= 0 then
		传入数据.铸斧 = nil
	end

	for i = 1, #装备基础属性列表 do
		传入数据.装备属性[装备基础属性列表[i]] = (传入数据.装备属性[装备基础属性列表[i]] or 0) + (装备[装备基础属性列表[i]] or 0)
	end

	if 装备.染色效果 ~= nil then
		装备.染色效果.首次 = nil
		传入数据.装备属性[装备.染色效果.类型] = (传入数据.装备属性[装备.染色效果.类型] or 0) + 装备.染色效果.数值
	end

	if 装备.特殊附加属性 ~= nil then
		传入数据.装备属性[装备.特殊附加属性.类型] = (传入数据.装备属性[装备.特殊附加属性.类型] or 0) + 装备.特殊附加属性.数值
	end

	if 装备.超级五行 ~= nil and 装备.超级五行.类型 ~= nil then
		传入数据.装备属性[装备.超级五行.属性] = (传入数据.装备属性[装备.超级五行.属性] or 0) + 装备.超级五行.数值
	end

	if 装备.百炼效果 ~= nil and 格子 < 7 then
		if 传入数据.百炼数据 == nil then
			传入数据.百炼数据 = {}
		end

		传入数据.百炼数据[格子] = {}

		for i = 1, #装备.百炼效果 do
			if 百炼词条叠加 == true then
				传入数据.装备属性[装备.百炼效果[i].类别] = (传入数据.装备属性[装备.百炼效果[i].类别] or 0) + 装备.百炼效果[i].数值
			else
				传入数据.百炼数据[格子][装备.百炼效果[i].类别] = 装备.百炼效果[i].数值 + 0
			end
		end

		if not 百炼词条叠加 then
			for i = 1, #百炼2 do
				传入数据.装备属性[百炼2[i] .. "百分百"] = 0
			end

			local aa = {}

			for k, v in pairs(传入数据.百炼数据) do
				for n, m in pairs(v) do
					aa[n] = math.max(aa[n] or 0, m)
				end
			end

			for k, v in pairs(aa) do
				传入数据.装备属性[k] = v
			end
		end
	end
end

function 角色处理类:卸下装备(装备, 格子, id, 不刷新)
	角色卸下装备(id, self.数据, 装备, 格子)

	if 格子 < 7 then
		if 装备.特技 ~= nil then
			self.数据.特殊技能[格子] = nil
		end

		if 装备.套装效果 ~= nil and self.套装 ~= nil and #self.套装 ~= nil then
			for i = 1, #self.套装 do
				if self.套装[i] ~= nil and self.套装[i][1] == 装备.套装效果[1] and self.套装[i][2] == 装备.套装效果[2] then
					local abd = nil

					for s = 1, #self.套装[i][4] do
						if self.套装[i][4][s] == 格子 then
							abd = s

							break
						end
					end

					if abd then
						remove(self.套装[i][4], abd)
					end

					if #self.套装[i][4] == 0 then
						remove(self.套装, i)
					end
				end
			end
		end

		if 格子 == 3 then
		end
	else
		self.数据.灵饰[格子 - 9] = nil

		if 格子 - 9 == 5 then
			tp.场景.人物:卸下翅膀()
		end
	end

	if 不刷新 == nil then
		self:刷新信息("2")
	end
end

function 角色处理类:穿戴装备(装备, 格子, id)
	角色穿戴装备(id, self.数据, 装备, 格子)

	if 格子 < 7 then
		if 装备.特技 ~= nil then
			self.数据.特殊技能[格子] = jnzb()

			self.数据.特殊技能[格子]:置对象(装备.特技)
		end

		if 装备.套装效果 ~= nil then
			local sl = {}
			local ab = true

			if self.套装 ~= nil and #self.套装 ~= nil then
				for i = 1, #self.套装 do
					if self.套装[i][1] == 装备.套装效果[1] and self.套装[i][2] == 装备.套装效果[2] then
						local abc = false
						local abd = true

						for s = 1, #self.套装[i][4] do
							if self.套装[i][4][s] == 格子 then
								abd = false

								break
							end
						end

						if abd then
							insert(self.套装[i][4], 格子)

							abc = true
						end

						if abc then
							self.套装[i][3] = (self.套装[i][3] or 0) + 1
						end

						ab = false

						break
					end
				end

				if ab then
					insert(self.套装, {
						装备.套装效果[1],
						装备.套装效果[2],
						1,
						{
							格子
						}
					})
				end
			end
		end
	else
		self.数据.灵饰[格子 - 9] = 装备

		if 格子 - 9 == 5 then
			tp.场景.人物:穿戴翅膀()
		end
	end

	self:刷新信息("2")
end

角色洗点 = function(角色数据, 飞升)
	角色数据.体质 = 10 + 角色数据.等级
	角色数据.魔力 = 10 + 角色数据.等级
	角色数据.力量 = 10 + 角色数据.等级
	角色数据.耐力 = 10 + 角色数据.等级
	角色数据.敏捷 = 10 + 角色数据.等级
	local 升级潜能点 = 服务端参数.角色升级潜能点 + 0

	if 角色数据.渡劫 == true then
		升级潜能点 = qz(升级潜能点 * 1.2)
	end

	if 角色数据.化圣 == 1 then
		角色数据.潜力 = qz(升级潜能点 + 5000)
	end




	if 飞升 == true or 角色数据.飞升 == true then
		角色数据.潜力 = 角色数据.等级 * 升级潜能点 + 升级潜能点 * 16
	else
		角色数据.潜力 = 角色数据.等级 * 升级潜能点 + 升级潜能点
	end



	if 角色数据.五虎上将 ~= nil then
		if 角色数据.五虎上将 == 1 then
			角色数据.潜力 = 角色数据.潜力 + 升级潜能点 * 2
		elseif 角色数据.五虎上将 == 2 then
			角色数据.潜力 = 角色数据.潜力 + 升级潜能点 * 6
		elseif 角色数据.五虎上将 == 3 then
			角色数据.潜力 = 角色数据.潜力 + 升级潜能点 * 12
		elseif 角色数据.五虎上将 == 4 then
			角色数据.潜力 = 角色数据.潜力 + 升级潜能点 * 20
		elseif 角色数据.五虎上将 >= 5 then
			角色数据.潜力 = 角色数据.潜力 + 升级潜能点 * 30
		end
	end

	if 角色数据.潜能果 ~= nil then
		角色数据.潜力 = 角色数据.潜力 + 角色数据.潜能果 * 2
	end
	if 角色数据.月饼 ~= nil then
		角色数据.潜力 = 角色数据.潜力 + 角色数据.月饼 * 1
	end
	if 角色数据.月饼1 ~= nil then
		角色数据.潜力 = 角色数据.潜力 + 角色数据.月饼1 * 1
	end
	if 角色数据.月饼2 ~= nil then
		角色数据.潜力 = 角色数据.潜力 + 角色数据.月饼2 * 1
	end
	if 角色数据.月饼3 ~= nil then
		角色数据.潜力 = 角色数据.潜力 + 角色数据.月饼3 * 1
	end
	if 角色数据.转生 ~= nil then
		角色数据.潜力 = 角色数据.潜力 + 角色数据.转生 * 255
	end
	if 角色数据.宝宝月饼 ~= nil then
		角色数据.宝宝月饼 = 角色数据.宝宝月饼 * 1
	end
end

function 角色处理类:洗点操作(id)
	local 银子 = self.数据.洗点次数 * 10000

	if self.数据.银子 < 银子 then
		常规提示(id, "#Y你身上没有那么多的银子")

		return
	end

	self.数据.洗点次数 = self.数据.洗点次数 + 1

	self:扣除银子(银子, 0, 0, "人物洗点", 1)
	角色洗点(self.数据)
	self:刷新信息("1")
	添加最后对话(id, "你的人物属性点重置成功！")
end

function 角色处理类:飞升洗点操作(id)
	self.数据.等级 = self.数据.等级 - 15

	角色洗点(self.数据, true)
	self:刷新信息("1")
	常规提示(id, "你的人物属性点重置成功！")
end

function 角色处理类:渡劫洗点操作(id)
	角色洗点(self.数据)
	self:刷新信息("1")
	常规提示(id, "你的人物属性点重置成功！")
end

function 角色处理类:化圣洗点操作(id)
	角色洗点(self.数据)
	self:刷新信息("1")
	常规提示(id, "你的人物属性点重置成功！")
end

function 角色处理类:退出门派(id)
	for n, v in pairs(self.数据.装备) do
		if self.数据.装备[n] ~= nil then
			常规提示(id, "#Y请先卸下人物装备")

			return
		end
	end

	for n, v in pairs(self.数据.灵饰) do
		if self.数据.灵饰[n] ~= nil then
			常规提示(id, "#Y请先卸下灵饰")

			return
		end
	end

	for n, v in pairs(self.数据.锦衣) do
		if self.数据.锦衣[n] ~= nil then
			常规提示(id, "#Y请先卸下锦衣")

			return
		end
	end

	for n, v in pairs(self.数据.法宝佩戴) do
		if self.数据.法宝佩戴[n] ~= nil then
			常规提示(id, "#Y请先卸下法宝")

			return
		end
	end

	if self.数据.银子 < 退出门派消耗银两 * 10000 then
		常规提示(id, "#Y你身上没有那么多的银子")

		return
	end

	for i = 1, #self.数据.称谓 do
		if 门派称谓列表1[self.数据.称谓[i]] ~= nil or self.数据.称谓[i] == self.数据.门派 .. "首席大弟子" then
			self:删除称谓(self.数据.数字id, self.数据.称谓[i])
		end
	end

	self:扣除银子(退出门派消耗银两 * 10000, 0, 0, "退出门派", 1)

	local 返还 = 退出门派返还计算(self.数据)
	玩家数据[id].角色.数据.门贡 = 0
	玩家数据[id].角色.数据.最大门贡 = 0
	玩家数据[id].角色.数据.当前经验 = 玩家数据[id].角色.数据.当前经验 + 返还.经验
	玩家数据[id].角色.数据.储备 = 玩家数据[id].角色.数据.储备 + 返还.金钱

	常规提示(id, "#Y/你获得了" .. 返还.金钱 .. "点退出门派返还储备")
	常规提示(id, "#Y/你获得了" .. 返还.经验 .. "点退出门派返还经验")

	self.数据.门派 = "无门派"
	self.数据.师门技能 = {}

	if self.数据.奇经八脉 ~= nil and self.数据.奇经八脉.经脉流派 ~= nil then
		self:删除称谓(id, self.数据.奇经八脉.经脉流派)
	end

	self.数据.奇经八脉 = {}
	self.数据.经脉流派 = nil
	self.数据.开启奇经八脉 = nil
	self.数据.技能树 = nil
	self.数据.装备属性.剩余乾元丹 = self.数据.装备属性.剩余乾元丹 + self.数据.装备属性.乾元丹
	self.数据.装备属性.乾元丹 = 0
	self.数据.快捷技能 = {}
	self.数据.技能属性 = {
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
	self.数据.人物技能 = {}
	self.数据.技能 = {}

	self:刷新信息("1")
	发送数据(玩家数据[self.数据.数字id].连接id, 42, self.数据.快捷技能)
	添加最后对话(id, "你已经退出门派了,成为了无门派人士！")
	广播消息({
		频道 = "xt",
		内容 = format("#G%s#R背信弃义,背叛了门派,现昭告天下,有钱你就了不起啊、了不起啊!#" .. 取随机数(1, 110), self.数据.名称)
	})

	if self.数据.帮派数据 == nil then
		self.数据.帮派数据 = {
			权限 = 0
		}
	end

	if self.数据.帮派数据.编号 ~= nil then
		local 帮派编号 = self.数据.帮派数据.编号
		local id2 = self.数据.ID
		帮派数据[帮派编号].成员数据[id2].门派 = self.数据.门派
	end
end

function 角色处理类:转换角色操作(id, 造型)
	for n, v in pairs(self.数据.装备) do
		if self.数据.装备[n] ~= nil then
			常规提示(id, "#Y请先卸下人物装备")

			return
		end
	end

	for n, v in pairs(self.数据.灵饰) do
		if self.数据.灵饰[n] ~= nil then
			常规提示(id, "#Y请先卸下灵饰")

			return
		end
	end

	for n, v in pairs(self.数据.锦衣) do
		if self.数据.锦衣[n] ~= nil then
			常规提示(id, "#Y请先卸下锦衣")

			return
		end
	end

	for n, v in pairs(self.数据.法宝佩戴) do
		if self.数据.法宝佩戴[n] ~= nil then
			常规提示(id, "#Y请先卸下法宝")

			return
		end
	end

	for n = 1, #self.数据.坐骑列表 do
		if self.数据.坐骑列表[n] ~= nil and self.数据.坐骑列表[n].统御召唤兽 ~= nil and (self.数据.坐骑列表[n].统御召唤兽[1] ~= nil or self.数据.坐骑列表[n].统御召唤兽[2] ~= nil) then
			常规提示(id, "#Y请将所有坐骑统御召唤兽清除！")

			return
		end
	end

	local 银子 = self.数据.转换角色次数 * 10000

	if self.数据.银子 < 银子 then
		常规提示(id, "#Y你身上没有" .. 银子 .. "银子")

		return
	end

	if self.数据.门派 ~= nil and self.数据.门派 ~= "无门派" then
		常规提示(id, "#Y有门派的角色无法转换为其他的角色！")

		return
	end

	self.数据.转换角色次数 = self.数据.转换角色次数 + 1

	self:扣除银子(银子, 0, 0, "转换角色", 1)

	self.数据.造型 = 造型
	self.数据.模型 = 造型
	local ls = self:队伍角色(造型)
	self.数据.种族坐骑 = nil
	self.数据.染色方案 = ls.染色方案
	self.数据.染色组 = {
		0,
		0,
		0
	}

	if 造型 == "逍遥生" or 造型 == "剑侠客" or 造型 == "偃无师" or 造型 == "虎头怪" or 造型 == "巨魔王" or 造型 == "杀破狼" or 造型 == "龙太子" or 造型 == "神天兵" or 造型 == "羽灵神" then
		self.数据.性别 = "男"
	else
		self.数据.性别 = "女"
	end

	if 造型 == "逍遥生" or 造型 == "剑侠客" or 造型 == "偃无师" or 造型 == "英女侠" or 造型 == "飞燕女" or 造型 == "巫蛮儿" then
		self.数据.种族 = "人"
	elseif 造型 == "虎头怪" or 造型 == "巨魔王" or 造型 == "杀破狼" or 造型 == "鬼潇潇" or 造型 == "骨精灵" or 造型 == "狐美人" or 造型 == "影精灵" then
		self.数据.种族 = "魔"
	elseif 造型 == "龙太子" or 造型 == "神天兵" or 造型 == "羽灵神" or 造型 == "桃夭夭" or 造型 == "舞天姬" or 造型 == "玄彩娥" then
		self.数据.种族 = "仙"
	end

	角色洗点(self.数据, self.数据.飞升)
	self:刷新信息("1")
	添加最后对话(id, "角色转换成功并重置属性点,请重新登陆！")
end

function 角色处理类:转换门派操作(id, 门派)
	for n, v in pairs(self.数据.装备) do
		if self.数据.装备[n] ~= nil then
			常规提示(id, "#Y请先卸下人物装备")

			return
		end
	end

	for n, v in pairs(self.数据.灵饰) do
		if self.数据.灵饰[n] ~= nil then
			常规提示(id, "#Y请先卸下灵饰")

			return
		end
	end

	for n, v in pairs(self.数据.锦衣) do
		if self.数据.锦衣[n] ~= nil then
			常规提示(id, "#Y请先卸下锦衣")

			return
		end
	end

	for n, v in pairs(self.数据.法宝佩戴) do
		if self.数据.法宝佩戴[n] ~= nil then
			常规提示(id, "#Y请先卸下法宝")

			return
		end
	end

	if 可入门派[self.数据.种族][门派] == nil and 可入门派[self.数据.种族][self.数据.性别][门派] == nil then
		常规提示(id, "本门派不收你这样的弟子")

		return
	end

	local 银子 = self.数据.转换门派次数 * 3000000

	if self.数据.银子 < 银子 then
		常规提示(id, "#Y你身上没有300万的银子")

		return
	end

	for i = 1, #self.数据.称谓 do
		if self.数据.称谓[i] == self.数据.门派 .. "首席大弟子" then
			self:删除称谓(self.数据.数字id, self.数据.门派 .. "首席大弟子")
		end
	end

	self.数据.门派 = 门派
	self.数据.转换门派次数 = self.数据.转换门派次数 + 1

	self:扣除银子(银子, 0, 0, "转换角色", 1)
	常规提示(id, "门派转换成功,你成为了#R/" .. 门派 .. "#Y/弟子")

	self.数据.师门技能 = {}
	self.数据.奇经八脉 = {}
	self.数据.开启奇经八脉 = nil
	self.数据.技能树 = nil
	self.数据.装备属性.剩余乾元丹 = self.数据.装备属性.剩余乾元丹 + self.数据.装备属性.乾元丹
	self.数据.装备属性.乾元丹 = 0
	self.数据.快捷技能 = {}
	self.数据.人物技能 = {}

	if self.数据.门派 ~= "无门派" and self.数据.师门技能[1] == nil then
		local 列表 = 取门派技能(self.数据.门派)

		for n = 1, #列表 do
			self.数据.师门技能[n] = jnzb()

			self.数据.师门技能[n]:置对象(列表[n])

			self.数据.师门技能[n].包含技能 = {}
			self.数据.师门技能[n].等级 = 0
			local w = 取包含技能(self.数据.师门技能[n].名称)

			for s = 1, #w do
				self.数据.师门技能[n].包含技能[s] = jnzb()

				self.数据.师门技能[n].包含技能[s]:置对象(w[s])

				self.数据.师门技能[n].包含技能[s].等级 = 0
			end
		end
	end

	if self.数据.师门技能[1] ~= nil and 是否 == "2" then
		for n = 1, 7 do
			for l = 1, #self.数据.师门技能[n].包含技能 do
				if 有无技能(self.数据, self.数据.师门技能[n].包含技能[l].名称) then
					self.数据.师门技能[n].包含技能[l].学会 = true
				end
			end
		end
	end
end

function 角色处理类:转换武器操作(id, 装备, 子类, 道具格子, 道具id)
	local 装备转换费用 = 1000

	if 玩家数据[id].账号 == nil or id == nil or 装备 == nil then
		print("报错了")

		return
	end

	local 仙玉 = f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "仙玉") + 0

	if 装备转换费用 > 仙玉 then
		常规提示(id, "装备转换造型需要1000仙玉,少侠的仙玉不够哦！")

		return
	end

	local 等级 = math.floor(装备.级别限制 / 10)
	local 装备名称 = ""

	if 装备.分类 == 3 and 子类 < 19 then
		装备名称 = 玩家数据[id].装备.打造物品[子类][等级 + 1]

		if 等级 >= 9 and 等级 < 12 then
			装备名称 = 玩家数据[id].装备.打造物品[子类][取随机数(10, 12)]
		elseif 等级 >= 12 and 等级 < 15 then
			装备名称 = 玩家数据[id].装备.打造物品[子类][取随机数(13, 15)]
		end
	elseif 装备.分类 == 4 and (子类 == 22 or 子类 == 23) then
		local 衣服类型 = 2

		if 子类 == 22 then
			衣服类型 = 1
		end

		子类 = 21
		装备名称 = 玩家数据[id].装备.打造物品[子类][等级 + 1][衣服类型]
	elseif 装备.分类 == 1 and (子类 == 19 or 子类 == 20) then
		local 头盔类型 = 1

		if 子类 == 20 then
			头盔类型 = 2
		end

		子类 = 19
		装备名称 = 玩家数据[id].装备.打造物品[子类][等级 + 1][头盔类型]
	else
		常规提示(id, "请选择正确的转换造型")

		return
	end

	self:扣除仙玉(1000, "转换武器", id)

	装备.子类 = 子类
	装备.名称 = 装备名称

	if 装备.性别限制 ~= nil and 取物品数据(装备.名称) ~= nil and 取物品数据(装备.名称)[6] ~= nil then
		装备.性别限制 = 取物品数据(装备.名称)[6]
	end

	if 装备.角色限制 ~= nil and 取物品数据(装备.名称) ~= nil and 取物品数据(装备.名称)[7] ~= nil then
		装备.角色限制 = 取物品数据(装备.名称)[7]
	end

	刷新道具行囊单格(id, "道具", 道具格子, 道具id)
	常规提示(id, "装备造型转换成功！")
end

function 角色处理类:取装备数据()
	local 返回数据 = {}

	for n, v in pairs(self.数据.装备) do
		返回数据[n] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.装备[n]]))
	end

	return 返回数据
end

function 角色处理类:取特技()
	local 返回数据 = {}

	for n, v in pairs(self.数据.装备) do
		if self.数据.装备[n] ~= nil and 玩家数据[self.数据.数字id].道具.数据[self.数据.装备[n]] ~= nil and 玩家数据[self.数据.数字id].道具.数据[self.数据.装备[n]].特技 ~= nil then
			local 加入 = true

			for i = 1, #返回数据 do
				if 返回数据[i] == 玩家数据[self.数据.数字id].道具.数据[self.数据.装备[n]].特技 then
					加入 = false
				end
			end

			if 加入 then
				返回数据[#返回数据 + 1] = 玩家数据[self.数据.数字id].道具.数据[self.数据.装备[n]].特技
			end
		end
	end

	return 返回数据
end

function 角色处理类:取灵饰数据()
	local 返回数据 = {}

	for n, v in pairs(self.数据.灵饰) do
		返回数据[n] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.灵饰[n]]))
	end

	return 返回数据
end

function 角色处理类:取锦衣数据()
	local 返回数据 = {}

	for n, v in pairs(self.数据.锦衣) do
		返回数据[n] = table.loadstring(table.tostring(玩家数据[self.数据.数字id].道具.数据[self.数据.锦衣[n]]))
	end

	return 返回数据
end

function 角色处理类:死亡处理()
end

function 角色处理类:取新增宝宝数量()
	if #玩家数据[self.数据.数字id].召唤兽.数据 < self.数据.召唤兽携带数量 then
		return true
	else
		return false
	end
end

function 角色处理类:取生活技能等级(名称)
	return 取角色生活技能等级(self.数据, 名称)
end

function 角色处理类:取强化技能等级(名称)
	return 取角色强化技能等级(self.数据, 名称)
end

取角色生活技能等级 = function(角色数据, 名称)
	for n = 1, #角色数据.辅助技能 do
		if 角色数据.辅助技能[n].名称 == 名称 then
			if (名称 == "强壮" or 名称 == "神速") and 强壮神速最高等级 < 角色数据.辅助技能[n].等级 then
				角色数据.辅助技能[n].等级 = 强壮神速最高等级
			end

			return 角色数据.辅助技能[n].等级
		end
	end

	return 0
end

取角色强化技能等级 = function(角色数据, 名称)
	if 角色数据.强化技能 == nil then
		return 0
	end

	for n = 1, #角色数据.强化技能 do
		if 角色数据.强化技能[n].名称 == 名称 then
			return 角色数据.强化技能[n].等级
		end
	end
end

符石组合效果刷新 = function(角色数据, 符石组合)
	local aa = {}

	for k, v in pairs(符石组合) do
		aa[k] = (aa[k] or 0) + 1

		if aa[k] <= 2 then
			if k == "无懈可击" then
				角色数据.额外技能属性.防御 = (角色数据.额外技能属性.防御 or 0) + #v * 6
			elseif k == "望穿秋水" then
				角色数据.额外技能属性.灵力 = (角色数据.额外技能属性.灵力 or 0) + #v * 3
			elseif k == "万里横行" then
				角色数据.额外技能属性.伤害 = (角色数据.额外技能属性.伤害 or 0) + #v * 4
			elseif k == "日落西山" then
				角色数据.额外技能属性.速度 = (角色数据.额外技能属性.速度 or 0) + #v * 4
			elseif k == "万丈霞光" then
				local 属性值 = 0
				local 参数表 = {
					3,
					5,
					8,
					10
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.万丈霞光 = 属性值
			elseif k == "真元护体" then
				local 属性值 = 0
				local 参数表 = {
					1,
					3,
					5
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.真元护体 = 属性值
			elseif k == "风卷残云" then
				local 属性值 = 0
				local 参数表 = {
					5,
					10,
					15,
					20
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.风卷残云 = 属性值
			elseif k == "无所畏惧" then
				local 属性值 = 0
				local 参数表 = {
					1,
					2,
					3,
					4
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[i]
				end

				角色数据.符石技能效果.无所畏惧 = 属性值
			elseif k == "柳暗花明" then
				local 属性值 = 0
				local 参数表 = {
					2,
					4,
					6,
					8
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.柳暗花明 = 属性值
			elseif k == "飞檐走壁" then
				local 属性值 = 0
				local 参数表 = {
					0,
					8,
					12,
					16
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.飞檐走壁 = 属性值
			elseif k == "点石成金" then
				local 属性值 = 0
				local 参数表 = {
					10,
					20,
					25,
					25
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.点石成金 = 属性值
			elseif k == "百步穿杨" then
				local 属性值 = 0
				local 参数表 = {
					25,
					45,
					75,
					100
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.百步穿杨 = 属性值
			elseif k == "雪照云光" then
				local 属性值 = 0
				local 参数表 = {
					2,
					4,
					6
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.雪照云光 = 属性值
			elseif k == "心灵手巧" then
				local 属性值 = 0
				local 参数表 = {
					5,
					8,
					10
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.心灵手巧 = 属性值
			elseif k == "隔山打牛" then
				local 属性值 = 0
				local 参数表 = {
					20,
					30,
					50,
					70
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.隔山打牛 = 属性值
			elseif k == "心随我动" then
				local 属性值 = 0
				local 参数表 = {
					25,
					45,
					70,
					90
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.心随我动 = 属性值
			elseif k == "云随风舞" then
				local 属性值 = 0
				local 参数表 = {
					20,
					40,
					70,
					80
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.云随风舞 = 属性值
			elseif k == "天降大任" then
				local 属性值 = 0
				local 参数表 = {
					nil,
					5,
					10,
					15
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.天降大任 = 属性值
			elseif k == "高山流水" then
				local 属性值 = 0
				local 参数表 = {
					[2] = 角色数据.等级 / 3 + 30,
					[3] = 角色数据.等级 / 2 + 30,
					[4] = 角色数据.等级 + 30
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.高山流水 = qz(属性值)
			elseif k == "百无禁忌" then
				local 属性值 = 0
				local 参数表 = {
					nil,
					4,
					8,
					12
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.百无禁忌 = 属性值
			elseif k == "暗渡陈仓" then
				local 属性值 = 0

				for i = 1, #v do
					属性值 = 属性值 + #v * 3
				end

				角色数据.符石技能效果.暗渡陈仓 = 属性值
			elseif k == "化敌为友 " then
				local 属性值 = 0

				for i = 1, #v do
					属性值 = 属性值 + #v * 3
				end

				角色数据.符石技能效果["化敌为友 "] = 属性值
			elseif k == "网罗乾坤" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 * 0.5,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.网罗乾坤 = 属性值
			elseif k == "石破天惊" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.石破天惊 = 属性值
			elseif k == "天雷地火" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.天雷地火 = 属性值
			elseif k == "凤舞九天" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.凤舞九天 = 属性值
			elseif k == "烟雨飘摇" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.烟雨飘摇 = 属性值
			elseif k == "索命无常" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.索命无常 = 属性值
			elseif k == "行云流水" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.行云流水 = 属性值
			elseif k == "福泽天下" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.福泽天下 = 属性值
			elseif k == "势如破竹" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.势如破竹 = 属性值
				角色数据.符石技能效果.扣除防御 = (角色数据.符石技能效果.扣除防御 or 0) + #v
			elseif k == "销魂噬骨" then
				local 属性值 = 0
				local 参数表 = {
					角色数据.等级 / 3,
					角色数据.等级 / 2,
					角色数据.等级
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.销魂噬骨 = 属性值
			elseif k == "无心插柳" then
				local 属性值 = 0
				local 词条个数 = 0
				local 参数表 = {
					0.15,
					0.2,
					0.25,
					0.3
				}

				for i = 1, #v do
					属性值 = 属性值 + 参数表[v[i]]
					词条个数 = 词条个数 + 1
				end

				角色数据.符石技能效果.无心插柳 = 属性值
				角色数据.符石技能效果.无心插柳词条个数 = 词条个数
			elseif k == "降妖伏魔" then
				local 属性值 = 0
				local 参数表 = {
					[2.0] = 8,
					[3.0] = 15
				}

				for i = 1, #v do
					属性数值 = 属性值 + 参数表[v[i]]
				end

				角色数据.符石技能效果.降妖伏魔 = 属性值
			end
		end
	end
end

门派称谓所需贡献 = {
	300,
	1000,
	2000,
	3500,
	6000
}
门派称谓属性 = {
	魔法 = 50,
	最大魔法 = 50,
	法伤 = 10,
	气血 = 50,
	最大气血 = 50,
	法防 = 10,
	伤害 = 10,
	速度 = 5,
	防御 = 10
}
门派称谓属性倍率 = {
	1,
	2,
	4,
	7,
	11
}
门派称谓列表1 = {
	莲花仙子 = 2,
	道家童女 = 1,
	化血使者 = 3,
	九天圣女 = 5,
	银沙彩贝 = 2,
	鬼灵精怪 = 1,
	九天妖王 = 5,
	游方行者 = 2,
	清秀书生 = 1,
	雷部天兵 = 3,
	神武都尉 = 4,
	小家碧玉 = 1,
	紫竹仙君 = 3,
	通天战神 = 5,
	瑶池天将 = 4,
	佛门小僧 = 1,
	妙手金刚 = 3,
	凋零祭司 = 5,
	红尘侠客 = 4,
	黑风老妖 = 3,
	红缨校尉 = 2,
	归元圣女 = 5,
	传令信差 = 1,
	楚楚伊人 = 3,
	落迦玄女 = 5,
	骠骑将军 = 5,
	大罗仙姬 = 3,
	伏魔真人 = 5,
	巾帼英豪 = 4,
	覆海神龙 = 4,
	秽土郡主 = 4,
	百媚妖灵 = 1,
	凌霄天姬 = 4,
	天庭守卫 = 2,
	魔寨蛮妖 = 2,
	拘魂女使 = 3,
	孤魂野鬼 = 1,
	出水芙蓉 = 4,
	神木小花 = 1,
	散花小仙 = 1,
	血咒法王 = 4,
	九黎战神 = 5,
	紫竹仙姬 = 3,
	碧波神女 = 5,
	俊逸郎君 = 3,
	惊魂妖姬 = 3,
	嗜血娇娘 = 2,
	玉虚神女 = 5,
	驱风灵童 = 2,
	斗战神佛 = 5,
	八卦天师 = 4,
	倾城公主 = 4,
	大力鬼王 = 5,
	逍遥罗汉 = 5,
	蛮铁统领 = 2,
	煞焰魔将 = 3,
	血枫祭司 = 4,
	煞气魔尊 = 4,
	乾坤真人 = 5,
	酆都女王 = 5,
	素心小仙 = 1,
	度邪灵姝 = 2,
	历劫英娥 = 3,
	护鼎巫师 = 3,
	斜月佳人 = 3,
	齐天女圣 = 5,
	奉桃仙童 = 1,
	邪魔太岁 = 4,
	雷霆神将 = 5,
	福地戍卫 = 1,
	混水泥鳅 = 1,
	幽冥女鬼 = 2,
	逍遥神尼 = 5,
	勾魂魔女 = 2,
	搅海帅首 = 3,
	魔灵妖女 = 2,
	山精地怪 = 1,
	道家仙童 = 1,
	阴风太保 = 2,
	遁地小妖 = 1,
	绣阁千金 = 2,
	忘情罗刹 = 5,
	催命无常 = 4,
	花语佳人 = 2,
	翻江猛蛟 = 3,
	凌日邪神 = 5,
	温文尔雅 = 5,
	灵溪小鱼 = 1,
	桃园力士 = 1,
	灌江校尉 = 2,
	神道玉女 = 4,
	凌波鸿雁 = 2,
	伏妖行者 = 2,
	炎火魔卒 = 1,
	灵台侍者 = 2,
	净瓶使者 = 4,
	幽冥鬼卒 = 2,
	潇湘隐士 = 3,
	威虎校尉 = 2,
	追云仙姬 = 3,
	佛门小尼 = 1,
	沧海名珠 = 3,
	飘香丽人 = 5,
	三清道童 = 1,
	八部天龙 = 5,
	灵霄美玉 = 2,
	红尘侠女 = 4,
	山野藤精 = 1,
	飞骑御使 = 3,
	钻洞小兵 = 1,
	离火郡主 = 4,
	绮罗御使 = 3,
	灵台道长 = 2,
	蚀天教主 = 5,
	牡丹御使 = 3,
	勾魂使者 = 3,
	火云魔尊 = 5,
	掌灯童子 = 1,
	降魔天师 = 4,
	三界妖将 = 3,
	夺命妖姬 = 3,
	炎天妖姬 = 3,
	掌灯仕女 = 1,
	莲花公子 = 2,
	平妖法师 = 3,
	三界散仙 = 2,
	玉面修罗 = 4,
	火云圣女 = 5,
	掣浪云骑 = 3,
	护城小兵 = 1,
	断岳神将 = 4,
	荡魔武圣 = 4,
	星月巫师 = 4,
	三星小童 = 1,
	森罗郡主 = 4,
	济世神医 = 4,
	噬血狂魔 = 4,
	风流才子 = 2,
	夺命妖王 = 3,
	巡海夜叉 = 2,
	巡山小妖 = 1,
	木兰秋水 = 5,
	百兽统领 = 2,
	勾魂魔王 = 2,
	黯月娘娘 = 5,
	梅山守卫 = 1,
	古怪刁钻 = 1,
	逍遥公主 = 4,
	落迦神将 = 5
}
门派称谓列表 = {
	大唐官府 = {
		男 = {
			"护城小兵",
			"威虎校尉",
			"飞骑御使",
			"神武都尉",
			"骠骑将军"
		},
		女 = {
			"传令信差",
			"红缨校尉",
			"牡丹御使",
			"巾帼英豪",
			"木兰秋水"
		}
	},
	方寸山 = {
		男 = {
			"三清道童",
			"灵台道长",
			"平妖法师",
			"降魔天师",
			"伏魔真人"
		},
		女 = {
			"三星小童",
			"灵台侍者",
			"斜月佳人",
			"神道玉女",
			"归元圣女"
		}
	},
	化生寺 = {
		男 = {
			"佛门小僧",
			"游方行者",
			"妙手金刚",
			"济世神医",
			"逍遥罗汉"
		},
		女 = {
			"佛门小尼",
			"游方行者",
			"妙手金刚",
			"济世神医",
			"逍遥神尼"
		}
	},
	女儿村 = {
		男 = {
			"清秀书生",
			"风流才子",
			"俊逸郎君",
			"红尘侠客",
			"温文尔雅"
		},
		女 = {
			"小家碧玉",
			"绣阁千金",
			"楚楚伊人",
			"红尘侠女",
			"飘香丽人"
		}
	},
	神木林 = {
		男 = {
			"山野藤精",
			"驱风灵童",
			"护鼎巫师",
			"血咒法王",
			"蚀天教主"
		},
		女 = {
			"神木小花",
			"花语佳人",
			"绮罗御使",
			"星月巫师",
			"凋零祭司"
		}
	},
	魔王寨 = {
		男 = {
			"山精地怪",
			"魔寨蛮妖",
			"黑风老妖",
			"邪魔太岁",
			"火云魔尊"
		},
		女 = {
			"古怪刁钻",
			"魔灵妖女",
			"炎天妖姬",
			"离火郡主",
			"火云圣女"
		}
	},
	狮驼岭 = {
		男 = {
			"巡山小妖",
			"百兽统领",
			"三界妖将",
			"噬血狂魔",
			"九天妖王"
		},
		女 = {
			"巡山小妖",
			"百兽统领",
			"三界妖将",
			"噬血狂魔",
			"九天妖王"
		}
	},
	阴曹地府 = {
		男 = {
			"孤魂野鬼",
			"幽冥鬼卒",
			"勾魂使者",
			"催命无常",
			"大力鬼王"
		},
		女 = {
			"鬼灵精怪",
			"幽冥女鬼",
			"拘魂女使",
			"森罗郡主",
			"酆都女王"
		}
	},
	盘丝洞 = {
		男 = {
			"百媚妖灵",
			"勾魂魔王",
			"夺命妖王",
			"玉面修罗",
			"忘情罗刹"
		},
		女 = {
			"百媚妖灵",
			"勾魂魔女",
			"夺命妖姬",
			"玉面修罗",
			"忘情罗刹"
		}
	},
	无底洞 = {
		男 = {
			"钻洞小兵",
			"阴风太保",
			"化血使者",
			"煞气魔尊",
			"凌日邪神"
		},
		女 = {
			"遁地小妖",
			"嗜血娇娘",
			"惊魂妖姬",
			"秽土郡主",
			"黯月娘娘"
		}
	},
	天宫 = {
		男 = {
			"桃园力士",
			"天庭守卫",
			"雷部天兵",
			"瑶池天将",
			"雷霆神将"
		},
		女 = {
			"散花小仙",
			"灵霄美玉",
			"大罗仙姬",
			"逍遥公主",
			"九天圣女"
		}
	},
	龙宫 = {
		男 = {
			"混水泥鳅",
			"巡海夜叉",
			"翻江猛蛟",
			"覆海神龙",
			"八部天龙"
		},
		女 = {
			"灵溪小鱼",
			"银沙彩贝",
			"沧海名珠",
			"出水芙蓉",
			"碧波神女"
		}
	},
	五庄观 = {
		男 = {
			"道家仙童",
			"三界散仙",
			"潇湘隐士",
			"八卦天师",
			"乾坤真人"
		},
		女 = {
			"道家童女",
			"三界散仙",
			"潇湘隐士",
			"八卦天师",
			"乾坤真人"
		}
	},
	普陀山 = {
		男 = {
			"掌灯童子",
			"莲花公子",
			"紫竹仙君",
			"净瓶使者",
			"落迦神将"
		},
		女 = {
			"掌灯仕女",
			"莲花仙子",
			"紫竹仙姬",
			"净瓶使者",
			"落迦玄女"
		}
	},
	凌波城 = {
		男 = {
			"梅山守卫",
			"灌江校尉",
			"掣浪云骑",
			"断岳神将",
			"通天战神"
		},
		女 = {
			"素心小仙",
			"凌波鸿雁",
			"追云仙姬",
			"倾城公主",
			"玉虚神女"
		}
	},
	九黎城 = {
		男 = {
			"炎火魔卒",
			"蛮铁统领",
			"煞焰魔将",
			"血枫祭司",
			"九黎战神"
		},
		女 = {
			"炎火魔卒",
			"蛮铁统领",
			"煞焰魔将",
			"血枫祭司",
			"九黎战神"
		}
	},
	花果山 = {
		男 = {
			"福地戍卫",
			"伏妖行者",
			"搅海帅首",
			"荡魔武圣",
			"斗战神佛"
		},
		女 = {
			"奉桃仙童",
			"度邪灵姝",
			"历劫英娥",
			"凌霄天姬",
			"齐天女圣"
		}
	}
}

角色刷新信息 = function(id, 角色数据)
	local 坐骑加成 = 1
	local 穿戴锦衣加成 = 1
	local 穿戴足印加成 = 1
	local 穿戴足迹加成 = 1

	if 判断是否为空表(角色数据.装备) and 判断是否为空表(角色数据.灵饰) and 判断是否为空表(角色数据.锦衣) then
		local 月饼 = 角色数据.装备属性.月饼 or 0
		local 乾元丹 = 角色数据.装备属性.乾元丹 or 0
		local 附加乾元丹 = 角色数据.装备属性.附加乾元丹 or 0
		local 剩余乾元丹 = 角色数据.装备属性.剩余乾元丹 or 0
		local 可换乾元丹 = 角色数据.装备属性.可换乾元丹 or 20
		角色数据.装备属性 = {
			伤害 = 0,
			体质 = 0,
			气血 = 0,
			力量 = 0,
			敏捷 = 0,
			魔法 = 0,
			魔力 = 0,
			灵力 = 0,
			速度 = 0,
			防御 = 0,
			耐力 = 0,
			躲避 = 0,
			命中 = 0,
			月饼 = 月饼,
			乾元丹 = 乾元丹,
			附加乾元丹 = 附加乾元丹,
			剩余乾元丹 = 剩余乾元丹,
			可换乾元丹 = 可换乾元丹
		}
	end

	if 角色数据.师门技能 ~= nil then
		for i = 1, #角色数据.师门技能 do
			角色升级技能(角色数据.师门技能[i], 角色数据)
		end
	end

	角色数据.动物套属性 = {
		件数 = 0,
		体质 = 0,
		力量 = 0,
		敏捷 = 0,
		名称 = "无",
		耐力 = 0,
		魔力 = 0
	}
	角色数据.额外技能属性 = {
		暗器防御 = 0,
		伤害 = 0,
		气血 = 0,
		魔法 = 0,
		躲避 = 0,
		灵力 = 0,
		治疗能力 = 0,
		速度 = 0,
		命中 = 0,
		防御 = 0
	}
	角色数据.符石技能效果 = {}
	角色数据.额外技能等级 = {}
	local 符石组合 = {}
	local 动物套 = {}

	for n, v in pairs(角色数据.装备) do
		local 装备数据 = 玩家数据[id].道具.数据[角色数据.装备[n]]

		if 装备数据 ~= nil then
			if 装备数据.套装效果 ~= nil and n ~= 3 and 装备数据.套装效果[1] == "变身术之" then
				if 判断是否为空表(动物套) then
					动物套[#动物套 + 1] = {
						装备数据.套装效果[2],
						数量 = 1
					}
				else
					local 新套装效果 = true

					for i = 1, #动物套 do
						if 动物套[i][1] == 装备数据.套装效果[2] then
							动物套[i].数量 = 动物套[i].数量 + 1
							新套装效果 = false
						end
					end

					if 新套装效果 then
						动物套[#动物套 + 1] = {
							装备数据.套装效果[2],
							数量 = 1
						}
					end
				end
			end

			if 装备数据.星位 ~= nil and 装备数据.星位.组合 ~= nil and (装备数据.星位.门派 == nil or 装备数据.星位.门派 == 角色数据.门派) then
				if 符石组合[装备数据.星位.组合] == nil then
					符石组合[装备数据.星位.组合] = {}
					符石组合[装备数据.星位.组合][#符石组合[装备数据.星位.组合] + 1] = 装备数据.星位.组合等级
				elseif 装备数据.星位.组合 == "高山流水" or 装备数据.星位.组合 == "天降大任" or 装备数据.星位.组合 == "柳暗花明" then
					for k, i in pairs(符石组合[装备数据.星位.组合]) do
						if i < 装备数据.星位.组合等级 then
							i = 装备数据.星位.组合等级

							break
						end
					end
				else
					符石组合[装备数据.星位.组合][#符石组合[装备数据.星位.组合] + 1] = 装备数据.星位.组合等级

					if #符石组合[装备数据.星位.组合] > 2 then
						table.sort(符石组合[装备数据.星位.组合])
						table.remove(符石组合[装备数据.星位.组合], 1)
					end
				end
			end
		end
	end

	if not 判断是否为空表(符石组合) then
		符石组合效果刷新(角色数据, 符石组合)
	end

	if 判断是否为空表(动物套) ~= nil then
		for i = 1, #动物套 do
			if 动物套[i].数量 >= 3 then
				local 属性加成 = 取动物套加成(动物套[i][1], 角色数据.等级)
				local 数值 = 0

				if 动物套[i].数量 >= 5 then
					数值 = 数值 + 属性加成.属性 + 属性加成.件数[2]
					角色数据.动物套属性[属性加成.类型] = 角色数据.动物套属性[属性加成.类型] + 数值
				else
					数值 = 数值 + 属性加成.属性 + 属性加成.件数[1]
					角色数据.动物套属性[属性加成.类型] = 角色数据.动物套属性[属性加成.类型] + 数值
				end

				角色数据.动物套属性.名称 = 动物套[i][1]
				角色数据.动物套属性.件数 = 动物套[i].数量
			end
		end
	end

	local 坐骑属性 = {
		0,
		0,
		0,
		0,
		0
	}
	local 坐骑数据 = nil

	if 角色数据.助战等级 ~= nil then
		if 角色数据.坐骑认证码 ~= nil and 玩家数据[id] ~= nil and 玩家数据[id].角色.数据.坐骑列表 ~= nil and not 判断是否为空表(玩家数据[id].角色.数据.坐骑列表) then
			for i = 1, #玩家数据[id].角色.数据.坐骑列表 do
				if 玩家数据[id].角色.数据.坐骑列表[i].认证码 == 角色数据.坐骑认证码 and 玩家数据[id].角色.数据.坐骑列表[i].助战参战 ~= nil then
					坐骑数据 = 玩家数据[id].角色.数据.坐骑列表[i]

					break
				end
			end
		end
	elseif 玩家数据[id] ~= nil and 玩家数据[id].角色.数据.坐骑 ~= nil and not 判断是否为空表(玩家数据[id].角色.数据.坐骑) then
		坐骑数据 = 玩家数据[id].角色.数据.坐骑
	end

	if 坐骑数据 ~= nil then
		local 属性加成 = {
			体质 = 1,
			力量 = 1,
			敏捷 = 1,
			耐力 = 1,
			魔力 = 1
		}
		属性加成[五行影响[坐骑数据.五行]] = 属性加成[五行影响[坐骑数据.五行]] * 五行系数1
		坐骑属性[1] = ceil(坐骑数据.体质 * 0.1 * 坐骑数据.体力资质 / 100 * 坐骑数据.成长 * 属性加成.体质)
		坐骑属性[2] = ceil(坐骑数据.魔力 * 0.1 * 坐骑数据.法力资质 / 100 * 坐骑数据.成长 * 属性加成.魔力)
		坐骑属性[3] = ceil(坐骑数据.力量 * 0.1 * 坐骑数据.攻击资质 / 100 * 坐骑数据.成长 * 属性加成.力量)
		坐骑属性[4] = ceil(坐骑数据.耐力 * 0.1 * 坐骑数据.防御资质 / 100 * 坐骑数据.成长 * 属性加成.耐力)
		坐骑属性[5] = ceil(坐骑数据.敏捷 * 0.1 * (坐骑数据.速度资质 + 坐骑数据.躲闪资质) / 200 * 坐骑数据.成长 * 属性加成.敏捷)
	end

	角色数据.装备属性.百炼灵力 = nil
	角色数据.装备属性.百炼命中 = nil
	角色数据.装备属性.百炼躲避 = nil

	for i = 1, #百炼2 do
		if 角色数据.装备属性[百炼2[i] .. "百分比"] ~= nil then
			角色数据[百炼2[i] .. "百分比"] = 角色数据.装备属性[百炼2[i] .. "百分比"]

			if 百炼3[百炼2[i]] ~= nil then
				角色数据.装备属性["百炼" .. 百炼2[i]] = qz(((角色数据.装备属性[百炼2[i]] or 0) + 坐骑属性[百炼3[百炼2[i]]] + 角色数据[百炼2[i]]) *
					角色数据.装备属性[百炼2[i] .. "百分比"] / 100)
			end
		end
	end

	local 官职加成 = 0

	if 角色数据.官职级别验证 ~= 官职级别验证 then
		刷新官职级别(角色数据)
	end

	if (角色数据.文官级别 or 0) > 0 then
		官职加成 = 官职加成 + math.min(角色数据.文官级别, 30)
	end

	if (角色数据.武官级别 or 0) > 0 then
		官职加成 = 官职加成 + math.min(角色数据.武官级别, 30)
	end

	if (角色数据.特殊官职级别 or 0) > 0 then
		官职加成 = 官职加成 + 角色数据.特殊官职级别
	end

	官职加成 = 官职加成 * 官职加成数
	local 计算五维 = {
		角色数据.体质 + 角色数据.动物套属性.体质 + 角色数据.装备属性.体质 + (角色数据.装备属性.百炼体质 or 0) + 坐骑属性[1] + 官职加成,
		角色数据.魔力 + 角色数据.动物套属性.魔力 + 角色数据.装备属性.魔力 + (角色数据.装备属性.百炼魔力 or 0) + 坐骑属性[2] + 官职加成,
		角色数据.力量 + 角色数据.动物套属性.力量 + 角色数据.装备属性.力量 + (角色数据.装备属性.百炼力量 or 0) + 坐骑属性[3] + 官职加成,
		角色数据.耐力 + 角色数据.动物套属性.耐力 + 角色数据.装备属性.耐力 + (角色数据.装备属性.百炼耐力 or 0) + 坐骑属性[4] + 官职加成,
		角色数据.敏捷 + 角色数据.动物套属性.敏捷 + 角色数据.装备属性.敏捷 + (角色数据.装备属性.百炼敏捷 or 0) + 坐骑属性[5] + 官职加成
	}
	角色数据.计算体质 = 计算五维[1] + 0
	角色数据.计算魔力 = 计算五维[2] + 0
	角色数据.计算力量 = 计算五维[3] + 0
	角色数据.计算耐力 = 计算五维[4] + 0
	角色数据.计算敏捷 = 计算五维[5] + 0
	local 五维属性 = 取角色属性(角色数据.种族, {
		计算五维[1],
		计算五维[2],
		计算五维[3],
		计算五维[4],
		计算五维[5]
	}, 角色数据.技能等级, 角色数据.门派)
	local 基础属性 = {
		命中 = 五维属性.命中,
		伤害 = 五维属性.伤害,
		防御 = 五维属性.防御
	}

	if 角色数据.符石技能效果.扣除防御 ~= nil then
		基础属性.防御 = qz(基础属性.防御 * (100 - 角色数据.符石技能效果.扣除防御 * 5) / 100)
	end

	基础属性.速度 = 五维属性.速度
	基础属性.灵力 = 五维属性.灵力
	基础属性.躲避 = 五维属性.躲避
	基础属性.最大气血 = (五维属性.气血 + 取角色生活技能等级(角色数据, "强壮") * 15) * (1 + 取角色生活技能等级(角色数据, "强身术") * 0.01)
	基础属性.最大魔法 = 五维属性.法力 * (1 + 取角色生活技能等级(角色数据, "冥想") * 0.01)
	local 减少属性 = {}

	if (角色数据.铸斧 == 2 or 角色数据.模型 ~= "影精灵" and 角色数据.铸斧 == 1) and 角色数据.装备[3] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[3]] ~= nil and 角色数据.装备[4] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[4]] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[4]].子类 == 911 then
		local 武器数据1 = 玩家数据[id].道具.数据[角色数据.装备[3]]
		local 武器数据2 = 玩家数据[id].道具.数据[角色数据.装备[4]]
		local lb = {
			"命中",
			"伤害"
		}

		for i = 1, #lb do
			减少属性[lb[i]] = (减少属性[lb[i]] or 0) +
				qz((玩家数据[id].道具.数据[角色数据.装备[3]][lb[i]] or 0) + (玩家数据[id].道具.数据[角色数据.装备[4]][lb[i]] or 0)) * (1 - 九黎城双斧减属性)
		end
	end

	角色数据.命中 = 基础属性.命中 + 角色数据.装备属性.命中 + 角色数据.技能属性.命中 + 角色数据.额外技能属性.命中 - (减少属性.命中 or 0)
	角色数据.伤害 = 基础属性.伤害 + 角色数据.装备属性.伤害 + 角色数据.技能属性.伤害 - (减少属性.伤害 or 0) +
		(角色数据.装备属性.命中 - (减少属性.命中 or 0) + 角色数据.额外技能属性.命中 + 角色数据.技能属性.命中) / 3
	角色数据.防御 = 基础属性.防御 + 角色数据.装备属性.防御 + 角色数据.技能属性.防御 + 角色数据.额外技能属性.防御 - (减少属性.防御 or 0)
	角色数据.速度 = 基础属性.速度 + 角色数据.装备属性.速度 + 角色数据.技能属性.速度 + 角色数据.额外技能属性.速度 - (减少属性.速度 or 0)
	角色数据.灵力 = 基础属性.灵力 + 角色数据.装备属性.灵力 + 角色数据.技能属性.灵力 + 角色数据.额外技能属性.灵力 - (减少属性.灵力 or 0)
	角色数据.法伤 = 角色数据.灵力 + (角色数据.装备属性.伤害 + (角色数据.装备属性.命中 - (减少属性.命中 or 0) + 角色数据.额外技能属性.命中 + 角色数据.技能属性.命中) / 3) * 0.25
	角色数据.法防 = 角色数据.灵力
	角色数据.躲避 = 基础属性.躲避 + 角色数据.装备属性.躲避 + 角色数据.技能属性.躲避 + 角色数据.额外技能属性.躲避 - (减少属性.躲避 or 0)
	角色数据.最大气血 = 基础属性.最大气血 + 角色数据.装备属性.气血 + 角色数据.技能属性.气血 + 角色数据.额外技能属性.气血 - (减少属性.气血 or 0)
	角色数据.最大魔法 = 基础属性.最大魔法 + 角色数据.装备属性.魔法 + 角色数据.技能属性.魔法 + 角色数据.额外技能属性.魔法 - (减少属性.魔法 or 0)
	角色数据.最大活力 = 10 + 角色数据.等级 * 5 + 取角色生活技能等级(角色数据, "养生之道") * 5
	角色数据.最大体力 = 10 + 角色数据.等级 * 5 + 取角色生活技能等级(角色数据, "健身术") * 5
	角色数据.最大气血 = 角色数据.最大气血 + 取角色强化技能等级(角色数据, "强化气血上限") * 角色强化技能列表2.强化气血上限
	角色数据.最大魔法 = 角色数据.最大魔法 + 取角色强化技能等级(角色数据, "强化魔法上限") * 角色强化技能列表2.强化魔法上限
	角色数据.伤害 = 角色数据.伤害 + 取角色强化技能等级(角色数据, "强化伤害") * 角色强化技能列表2.强化伤害
	角色数据.防御 = 角色数据.防御 + 取角色强化技能等级(角色数据, "强化物理防御") * 角色强化技能列表2.强化物理防御
	角色数据.速度 = 角色数据.速度 + (取角色生活技能等级(角色数据, "神速") or 0) * 1.5
	角色数据.法防 = 角色数据.法伤 + 取角色强化技能等级(角色数据, "强化法防") * 角色强化技能列表2.强化法防
	角色数据.法伤 = 角色数据.法防 + 取角色强化技能等级(角色数据, "强化法伤") * 角色强化技能列表2.强化法伤
	角色数据.气血回复效果 = 0
	角色数据.抗法术暴击等级 = 0
	角色数据.格挡值 = 0
	角色数据.抗物理暴击等级 = 0
	角色数据.封印命中等级 = 取角色强化技能等级(角色数据, "强化封印命中等级") * 角色强化技能列表2.强化封印命中等级 + 0
	角色数据.抵抗封印等级 = 取角色强化技能等级(角色数据, "强化抵抗封印等级") * 角色强化技能列表2.强化抵抗封印等级 + 0
	角色数据.暗器技巧 = 取角色生活技能等级(角色数据, "暗器技巧")
	角色数据.固定伤害 = 角色数据.暗器技巧 * 2 + 取角色强化技能等级(角色数据, "强化固定伤害") * 角色强化技能列表2.强化固定伤害 + 0
	角色数据.法术暴击等级 = 0
	角色数据.物理暴击等级 = 0
	角色数据.狂暴等级 = 0
	角色数据.穿刺等级 = 0
	角色数据.法术伤害结果 = 0
	角色数据.治疗能力 = 取角色强化技能等级(角色数据, "强化治疗能力") * 角色强化技能列表2.强化治疗能力 + 0

	for i = 1, #灵饰战斗属性 do
		if 角色数据.装备属性[灵饰战斗属性[i]] ~= nil then
			角色数据[灵饰战斗属性[i]] = (角色数据[灵饰战斗属性[i]] or 0) + 角色数据.装备属性[灵饰战斗属性[i]]
		end
	end

	if (角色数据.门派称谓级别 or 0) > 0 then
		local bl = 门派称谓属性倍率[math.min(角色数据.门派称谓级别, 5)]

		for k, v in pairs(门派称谓属性) do
			角色数据[k] = 角色数据[k] + v * bl
		end
	end

	if 角色数据.五虎上将 ~= nil and 角色数据.五虎上将 == 5 then
		角色数据.最大气血 = 角色数据.最大气血 + 200
	end

	if 吊游定制 and 角色数据.当前称谓 == "后起之秀" then
		角色数据.最大气血 = 角色数据.最大气血 + 200
		角色数据.气血 = 角色数据.气血 + 200
	elseif 吊游定制 and 角色数据.当前称谓 == "三界菁英" then
		角色数据.最大气血 = 角色数据.最大气血 + 300
		角色数据.气血 = 角色数据.气血 + 300
	elseif 吊游定制 and 角色数据.当前称谓 == "武林高手" then
		角色数据.最大气血 = 角色数据.最大气血 + 500
		角色数据.气血 = 角色数据.气血 + 500
	elseif 吊游定制 and 角色数据.当前称谓 == "独孤求败" then
		角色数据.最大气血 = 角色数据.最大气血 + 800
		角色数据.气血 = 角色数据.气血 + 800
	elseif 吊游定制 and 角色数据.当前称谓 == "九天罗刹" then
		角色数据.最大气血 = 角色数据.最大气血 + 1000
		角色数据.气血 = 角色数据.气血 + 1000
	elseif 吊游定制 and 角色数据.当前称谓 == "皓月战神" then
		角色数据.最大气血 = 角色数据.最大气血 + 1300
		角色数据.气血 = 角色数据.气血 + 1300
	elseif 吊游定制 and 角色数据.当前称谓 == "梦幻元勋" then
		角色数据.最大气血 = 角色数据.最大气血 + 1700
		角色数据.气血 = 角色数据.气血 + 1700
	elseif 吊游定制 and 角色数据.当前称谓 == "叱咤三界" then
		角色数据.最大气血 = 角色数据.最大气血 + 2000
		角色数据.气血 = 角色数据.气血 + 2000
	elseif 吊游定制 and 角色数据.当前称谓 == "笑傲西游" then
		角色数据.最大气血 = 角色数据.最大气血 + 2400
		角色数据.气血 = 角色数据.气血 + 2400
	elseif 吊游定制 and 角色数据.当前称谓 == "唯吾独尊" then
		角色数据.最大气血 = 角色数据.最大气血 + 2800
		角色数据.气血 = 角色数据.气血 + 2800
	elseif 吊游定制 and 角色数据.当前称谓 == "狂暴之力" then
		角色数据.最大气血 = 角色数据.最大气血 + 3000
		角色数据.气血 = 角色数据.气血 + 3000
	elseif 吊游定制 and 角色数据.当前称谓 == "超凡入圣" then
		角色数据.最大气血 = 角色数据.最大气血 + 3300
		角色数据.气血 = 角色数据.气血 + 3300
	elseif 吊游定制 and 角色数据.当前称谓 == "武林圣者" then
		角色数据.最大气血 = 角色数据.最大气血 + 3300
		角色数据.气血 = 角色数据.气血 + 3300
	elseif 吊游定制 and 角色数据.当前称谓 == "至尊财神" then
		角色数据.最大气血 = 角色数据.最大气血 + 3500
		角色数据.气血 = 角色数据.气血 + 3500
	elseif 吊游定制 and 角色数据.当前称谓 == "洞察先机" then
		角色数据.最大气血 = 角色数据.最大气血 + 1000
		角色数据.气血 = 角色数据.气血 + 1000
		角色数据.速度 = 角色数据.速度 + 200
	elseif 吊游定制 and 角色数据.当前称谓 == "龙皇" then
		角色数据.灵力 = 角色数据.灵力 + 300
		角色数据.法伤 = 角色数据.法伤 + 300
		角色数据.法防 = 角色数据.法防 + 300
	elseif 吊游定制 and 角色数据.当前称谓 == "神豪" then
		角色数据.最大气血 = 角色数据.最大气血 + 4000
		角色数据.气血 = 角色数据.气血 + 4000
	elseif 吊游定制 and 角色数据.当前称谓 == "战神" then
		角色数据.伤害 = 角色数据.伤害 + 300
	elseif 角色数据.当前称谓 == "西游小萌新" then
		角色数据.最大气血 = 角色数据.最大气血 + 300
		角色数据.气血 = 角色数据.气血 + 300
	elseif 角色数据.当前称谓 == "笑看西游" or 角色数据.当前称谓 == "大唐官府首席大弟子" or 角色数据.当前称谓 == "神木林首席大弟子" or 角色数据.当前称谓 == "九黎城首席大弟子" or 角色数据.当前称谓 == "方寸山首席大弟子" or 角色数据.当前称谓 == "化生寺首席大弟子" or 角色数据.当前称谓 == "女儿村首席大弟子" or 角色数据.当前称谓 == "天宫首席大弟子" or 角色数据.当前称谓 == "普陀山首席大弟子" or 角色数据.当前称谓 == "五庄观首席大弟子" or 角色数据.当前称谓 == "凌波城首席大弟子" or 角色数据.当前称谓 == "龙宫首席大弟子" or 角色数据.当前称谓 == "魔王寨首席大弟子" or 角色数据.当前称谓 == "狮驼岭首席大弟子" or 角色数据.当前称谓 == "花果山首席大弟子" or 角色数据.当前称谓 == "九黎首席大弟子" or 角色数据.当前称谓 == "盘丝洞首席大弟子" or 角色数据.当前称谓 == "无底洞首席大弟子" or 角色数据.当前称谓 == "阴曹地府首席大弟子" then
		角色数据.最大气血 = 角色数据.最大气血 + 100
		角色数据.气血 = 角色数据.气血 + 100
		角色数据.伤害 = 角色数据.伤害 + 10
		角色数据.防御 = 角色数据.防御 + 10
		角色数据.灵力 = 角色数据.灵力 + 10
		角色数据.法伤 = 角色数据.法伤 + 10
		角色数据.法防 = 角色数据.法防 + 10
		角色数据.速度 = 角色数据.速度 + 10
	elseif 角色数据.当前称谓 == "大海龟杀手" then
		角色数据.最大气血 = 角色数据.最大气血 + 10
		角色数据.气血 = 角色数据.气血 + 10
	elseif 角色数据.当前称谓 == "荒漠屠夫" then
		角色数据.伤害 = 角色数据.伤害 + 10
	elseif 角色数据.当前称谓 == "僵尸道长" then
		角色数据.灵力 = 角色数据.灵力 + 10
		角色数据.法伤 = 角色数据.法伤 + 10
		角色数据.法防 = 角色数据.法防 + 10
	elseif 角色数据.当前称谓 == "快递小哥" then
		角色数据.速度 = 角色数据.速度 + 10
	elseif 角色数据.当前称谓 == "摸金校尉" then
		角色数据.防御 = 角色数据.防御 + 10
	elseif 角色数据.当前称谓 == "当代清官" then
		角色数据.伤害 = 角色数据.伤害 + 5
		角色数据.灵力 = 角色数据.灵力 + 5
		角色数据.法伤 = 角色数据.法伤 + 5
		角色数据.法防 = 角色数据.法防 + 5
	elseif 角色数据.当前称谓 == "首席小弟子" then
		角色数据.最大气血 = 角色数据.最大气血 + 10
		角色数据.气血 = 角色数据.气血 + 10
		角色数据.伤害 = 角色数据.伤害 + 2
		角色数据.防御 = 角色数据.防御 + 2
		角色数据.灵力 = 角色数据.灵力 + 2
		角色数据.法伤 = 角色数据.法伤 + 2
		角色数据.法防 = 角色数据.法防 + 2
		角色数据.速度 = 角色数据.速度 + 2
	elseif 角色数据.当前称谓 == "西游任我行" then
		角色数据.最大气血 = 角色数据.最大气血 + 800
		角色数据.气血 = 角色数据.气血 + 800
	elseif 角色数据.当前称谓 == "梦幻任逍遥" then
		角色数据.最大气血 = 角色数据.最大气血 + 1000
		角色数据.气血 = 角色数据.气血 + 1000
	elseif 角色数据.当前称谓 == "天人开造化" then
		角色数据.最大气血 = 角色数据.最大气血 + 2000
		角色数据.气血 = 角色数据.气血 + 2000
	elseif 角色数据.当前称谓 == "至尊财神" then
		角色数据.最大气血 = 角色数据.最大气血 + 2000
		角色数据.气血 = 角色数据.气血 + 2000
	elseif 角色数据.当前称谓 == "狂暴之力" then
		角色数据.最大气血 = 角色数据.最大气血 + 1000
		角色数据.气血 = 角色数据.气血 + 1000
	elseif 角色数据.当前称谓 == "武林圣者" then
		角色数据.最大气血 = 角色数据.最大气血 + 1000
		角色数据.气血 = 角色数据.气血 + 1000
	elseif 角色数据.当前称谓 == "敢为人先" then
		角色数据.最大气血 = 角色数据.最大气血 + 300
		角色数据.气血 = 角色数据.气血 + 300
	elseif 角色数据.当前称谓 == "家园卫士" then
		角色数据.最大气血 = 角色数据.最大气血 + 300
		角色数据.气血 = 角色数据.气血 + 300
		角色数据.速度 = 角色数据.速度 + 30
	elseif 角色数据.当前称谓 == "突厥杀手" then
		角色数据.最大气血 = 角色数据.最大气血 + 300
		角色数据.气血 = 角色数据.气血 + 300
		角色数据.速度 = 角色数据.速度 + 30
		角色数据.防御 = 角色数据.防御 + 30
		角色数据.法防 = 角色数据.法防 + 30
	elseif 角色数据.当前称谓 == "侠之大者" then
		角色数据.最大气血 = 角色数据.最大气血 + 300
		角色数据.气血 = 角色数据.气血 + 300
		角色数据.速度 = 角色数据.速度 + 30
		角色数据.防御 = 角色数据.防御 + 30
		角色数据.法防 = 角色数据.法防 + 30
		角色数据.伤害 = 角色数据.伤害 + 50
		角色数据.灵力 = 角色数据.灵力 + 50
		角色数据.法伤 = 角色数据.法伤 + 50
		角色数据.法防 = 角色数据.法防 + 50
	elseif 角色数据.当前称谓 == "为国为民" then
		角色数据.最大气血 = 角色数据.最大气血 + 500
		角色数据.气血 = 角色数据.气血 + 500
		角色数据.速度 = 角色数据.速度 + 50
		角色数据.防御 = 角色数据.防御 + 50
		角色数据.法防 = 角色数据.法防 + 50
		角色数据.伤害 = 角色数据.伤害 + 80
		角色数据.灵力 = 角色数据.灵力 + 80
		角色数据.法伤 = 角色数据.法伤 + 80
		角色数据.法防 = 角色数据.法防 + 80
	end

	if 角色数据.结婚 ~= nil and (角色数据.结婚.老公 ~= nil or 角色数据.结婚.老婆 ~= nil) then
		if 角色数据.结婚.老婆 ~= nil and 角色数据.当前称谓 == 角色数据.结婚.老婆 .. "的相公" then
			角色数据.灵力 = 角色数据.灵力 + 30
			角色数据.法伤 = 角色数据.法伤 + 30
			角色数据.法防 = 角色数据.法防 + 30
			角色数据.伤害 = 角色数据.伤害 + 30
			角色数据.防御 = 角色数据.防御 + 20
		elseif 角色数据.结婚.老公 ~= nil and 角色数据.当前称谓 == 角色数据.结婚.老公 .. "的娘子" then
			角色数据.灵力 = 角色数据.灵力 + 30
			角色数据.法伤 = 角色数据.法伤 + 30
			角色数据.法防 = 角色数据.法防 + 30
			角色数据.伤害 = 角色数据.伤害 + 30
			角色数据.防御 = 角色数据.防御 + 20
		end
	end



	if 角色数据.哈哈 ~= nil then
		角色数据.最大气血 = 角色数据.最大气血 * 1.15
		角色数据.气血 = 角色数据.气血 * 1.15
		角色数据.伤害 = 角色数据.伤害 * 1.15
		角色数据.防御 = 角色数据.防御 * 1.15
		角色数据.灵力 = 角色数据.灵力 * 1.15
		角色数据.法伤 = 角色数据.法伤 * 1.15
		角色数据.法防 = 角色数据.法防 * 1.15
		角色数据.速度 = 角色数据.速度 * 1.15
	end
	if 角色数据.哈哈1 ~= nil then
		角色数据.最大气血 = 角色数据.最大气血 * 1.3
		角色数据.气血 = 角色数据.气血 * 1.3
		角色数据.伤害 = 角色数据.伤害 * 1.3
		角色数据.防御 = 角色数据.防御 * 1.3
		角色数据.灵力 = 角色数据.灵力 * 1.3
		角色数据.法伤 = 角色数据.法伤 * 1.3
		角色数据.法防 = 角色数据.法防 * 1.3
		角色数据.速度 = 角色数据.速度 * 1.3
	end

	if 角色数据.哈哈2 ~= nil then
		角色数据.最大气血 = 角色数据.最大气血 * 1.45
		角色数据.气血 = 角色数据.气血 * 1.45
		角色数据.伤害 = 角色数据.伤害 * 1.45
		角色数据.防御 = 角色数据.防御 * 1.45
		角色数据.灵力 = 角色数据.灵力 * 1.45
		角色数据.法伤 = 角色数据.法伤 * 1.45
		角色数据.法防 = 角色数据.法防 * 1.45
		角色数据.速度 = 角色数据.速度 * 1.45
	end

	if 角色数据.当前称谓 == "大佬称谓" then
		角色数据.最大气血 = 角色数据.最大气血 * 1.25
		角色数据.气血 = 角色数据.气血 * 1.25
		角色数据.速度 = 角色数据.速度 * 1.25
		角色数据.防御 = 角色数据.防御 * 1.25
		角色数据.法防 = 角色数据.法防 * 1.25
		角色数据.伤害 = 角色数据.伤害 * 1.25
		角色数据.灵力 = 角色数据.灵力 * 1.25
		角色数据.法伤 = 角色数据.法伤 * 1.25
		角色数据.法防 = 角色数据.法防 * 1.25
	end


	if 角色数据.哈哈3 ~= nil then
		角色数据.最大气血 = 角色数据.最大气血 * 1.65
		角色数据.气血 = 角色数据.气血 * 1.65
		角色数据.伤害 = 角色数据.伤害 * 1.65
		角色数据.防御 = 角色数据.防御 * 1.65
		角色数据.灵力 = 角色数据.灵力 * 1.65
		角色数据.法伤 = 角色数据.法伤 * 1.65
		角色数据.法防 = 角色数据.法防 * 1.65
		角色数据.速度 = 角色数据.速度 * 1.65
	end
	if 角色数据.哈哈4 ~= nil then
		角色数据.最大气血 = 角色数据.最大气血 * 1.85
		角色数据.气血 = 角色数据.气血 * 1.85
		角色数据.伤害 = 角色数据.伤害 * 1.85
		角色数据.防御 = 角色数据.防御 * 1.85
		角色数据.灵力 = 角色数据.灵力 * 1.85
		角色数据.法伤 = 角色数据.法伤 * 1.85
		角色数据.法防 = 角色数据.法防 * 1.85
		角色数据.速度 = 角色数据.速度 * 1.85
	end
	if 角色数据.当前称谓 == "大佬称谓加1" then
		角色数据.最大气血 = 角色数据.最大气血 * 1.5
		角色数据.气血 = 角色数据.气血 * 1.5
		角色数据.速度 = 角色数据.速度 * 1.5
		角色数据.防御 = 角色数据.防御 * 1.5
		角色数据.法防 = 角色数据.法防 * 1.5
		角色数据.伤害 = 角色数据.伤害 * 1.5
		角色数据.灵力 = 角色数据.灵力 * 1.5
		角色数据.法伤 = 角色数据.法伤 * 1.5
		角色数据.法防 = 角色数据.法防 * 1.5
	end
	if 角色数据.当前称谓 == "大佬称谓加2" then
		角色数据.最大气血 = 角色数据.最大气血 * 2.25
		角色数据.气血 = 角色数据.气血 * 2.25
		角色数据.速度 = 角色数据.速度 * 2.25
		角色数据.防御 = 角色数据.防御 * 2.25
		角色数据.法防 = 角色数据.法防 * 2.25
		角色数据.伤害 = 角色数据.伤害 * 2.25
		角色数据.灵力 = 角色数据.灵力 * 2.25
		角色数据.法伤 = 角色数据.法伤 * 2.25
		角色数据.法防 = 角色数据.法防 * 2.25
	end
	if 角色数据.当前称谓 == "大佬称谓加4" then
		角色数据.最大气血 = 角色数据.最大气血 * 2.7
		角色数据.气血 = 角色数据.气血 * 2.7
		角色数据.速度 = 角色数据.速度 * 2.7
		角色数据.防御 = 角色数据.防御 * 2.7
		角色数据.法防 = 角色数据.法防 * 2.7
		角色数据.伤害 = 角色数据.伤害 * 2.7
		角色数据.灵力 = 角色数据.灵力 * 2.7
		角色数据.法伤 = 角色数据.法伤 * 2.7
		角色数据.法防 = 角色数据.法防 * 2.7
	end
	if 角色数据.当前称谓 == "大佬称谓加5" then
		角色数据.最大气血 = 角色数据.最大气血 * 3.5
		角色数据.气血 = 角色数据.气血 * 3.5
		角色数据.速度 = 角色数据.速度 * 3.5
		角色数据.防御 = 角色数据.防御 * 3.5
		角色数据.法防 = 角色数据.法防 * 3.5
		角色数据.伤害 = 角色数据.伤害 * 3.5
		角色数据.灵力 = 角色数据.灵力 * 3.5
		角色数据.法伤 = 角色数据.法伤 * 3.5
		角色数据.法防 = 角色数据.法防 * 3.5
	end

	if 角色数据.单人闯关 ~= nil then
		-- 获取单人闯关增加的数值
		local increase = 角色数据.单人闯关
		角色数据.最大气血 = 角色数据.最大气血 * (1 + increase * 0.01)
		角色数据.命中 = 角色数据.命中 * (1 + increase * 0.01)
		角色数据.伤害 = 角色数据.伤害 * (1 + increase * 0.01)
		角色数据.法伤 = 角色数据.法伤 * (1 + increase * 0.01)
		角色数据.法防 = 角色数据.法防 * (1 + increase * 0.01)
		角色数据.速度 = 角色数据.速度 * (1 + increase * 0.01)
		角色数据.防御 = 角色数据.防御 * (1 + increase * 0.01)
	end
	if 角色数据.单人闯关10 ~= nil then
		local increase = 角色数据.单人闯关10

		角色数据.最大气血 = 角色数据.最大气血 + (increase * 500)
	end

	if 角色数据.单人闯关100 ~= nil then
		local increase = 角色数据.单人闯关100

		角色数据.最大气血 = 角色数据.最大气血 + (increase * 5000)
	end


	if 角色数据.化圣 == 1 then
		角色数据.最大气血 = 角色数据.最大气血 + 20000
	end

	if 角色数据.单人闯关1 ~= nil then
		local increase = 角色数据.单人闯关1

		角色数据.命中 = 角色数据.命中 + (increase * 500)
	end

	if 角色数据.单人闯关2 ~= nil then
		local increase = 角色数据.单人闯关2

		角色数据.伤害 = 角色数据.伤害 + (increase * 500)
	end
	if 角色数据.单人闯关3 ~= nil then
		local increase = 角色数据.单人闯关3

		角色数据.防御 = 角色数据.防御 + (increase * 100)
	end

	if 角色数据.单人闯关4 ~= nil then
		local increase = 角色数据.单人闯关4

		角色数据.速度 = 角色数据.速度 + (increase * 500)
	end

	if 角色数据.单人闯关5 ~= nil then
		local increase = 角色数据.单人闯关5

		角色数据.法伤 = 角色数据.法伤 + (increase * 500)
	end
	if 角色数据.单人闯关55 ~= nil then
		local increase = 角色数据.单人闯关55

		角色数据.法伤 = 角色数据.法伤 + (increase * 500)
	end
	if 角色数据.单人闯关8 ~= nil then
		local increase = 角色数据.单人闯关8

		角色数据.法伤 = 角色数据.法伤 * (1 + increase * 0.01) --+(increase*100)
	end
	if 角色数据.单人闯关88 ~= nil then
		local increase = 角色数据.单人闯关88

		角色数据.法伤 = 角色数据.法伤 * (1 + increase * 0.01) --+(increase*100)
	end
	if 角色数据.单人闯关9 ~= nil then
		local increase = 角色数据.单人闯关9

		角色数据.伤害 = 角色数据.伤害 * (1 + increase * 0.01) --+(increase*100)
	end
	if 角色数据.单人闯关6 ~= nil then
		local increase = 角色数据.单人闯关6

		角色数据.法防 = 角色数据.法防 + (increase * 100)
	end


	if 角色数据.哥哥11 ~= nil then
		local increase = 角色数据.哥哥11

		角色数据.伤害 = 角色数据.伤害 * (1 + increase * 0.01) --+(increase*100)
		角色数据.法伤 = 角色数据.法伤 * (1 + increase * 0.01) --+(increase*100)

		角色数据.法防 = 角色数据.法防 + (increase * 100)
		角色数据.最大气血 = 角色数据.最大气血 + (increase * 500)
		角色数据.速度 = 角色数据.速度 + (increase * 500)
		角色数据.防御 = 角色数据.防御 + (increase * 100)
		角色数据.命中 = 角色数据.命中 + (increase * 500)
		角色数据.法伤 = 角色数据.法伤 + (increase * 500)
		角色数据.伤害 = 角色数据.伤害 + (increase * 500)
	end


	if 角色数据.狂浪滔天 ~= nil then
		角色数据.灵力 = 角色数据.灵力 * (1 + 角色数据.狂浪滔天 / 100)
		角色数据.法伤 = 角色数据.法伤 * (1 + 角色数据.狂浪滔天 / 100)
		角色数据.法防 = 角色数据.法防 * (1 + 角色数据.狂浪滔天 / 100)
	end

	if 角色数据.固若金汤 ~= nil then
		角色数据.防御 = 角色数据.防御 * (1 + 角色数据.固若金汤 / 100)
	end

	if 角色数据.锐不可当 ~= nil then
		角色数据.伤害 = 角色数据.伤害 * (1 + 角色数据.锐不可当 / 100)
	end

	if 角色数据.血气方刚 ~= nil then
		角色数据.最大气血 = 角色数据.最大气血 * (1 + 角色数据.血气方刚 / 100)
	end

	if 角色数据.健步如飞 ~= nil then
		角色数据.速度 = 角色数据.速度 * (1 + 角色数据.健步如飞 / 100)
	end

	if 角色数据.变身数据 ~= nil and 变身卡数据[角色数据.变身数据] ~= nil and 变身卡数据[角色数据.变身数据].属性 ~= 0 then
		if 变身卡数据[角色数据.变身数据].单独 == 1 then
			if 变身卡数据[角色数据.变身数据].类型 == "气血" or 变身卡数据[角色数据.变身数据].类型 == "魔法" then
				if 变身卡数据[角色数据.变身数据].正负 == 1 then
					角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] = 角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] + 变身卡数据[角色数据.变身数据].属性
				else
					角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] = 角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] - 变身卡数据[角色数据.变身数据].属性
				end
			else
				local aa = {
					变身卡数据[角色数据.变身数据].类型 .. ""
				}

				if 变身卡数据[角色数据.变身数据].类型 == "灵力" then
					aa[#aa + 1] = "法伤"
					aa[#aa + 1] = "法防"
				end

				for i = 1, #aa do
					if 变身卡数据[角色数据.变身数据].正负 == 1 then
						角色数据[aa[i]] = 角色数据[aa[i]] + 变身卡数据[角色数据.变身数据].属性
					else
						角色数据[aa[i]] = 角色数据[aa[i]] - 变身卡数据[角色数据.变身数据].属性
					end
				end
			end
		elseif 变身卡数据[角色数据.变身数据].类型 == "气血" or 变身卡数据[角色数据.变身数据].类型 == "魔法" then
			if 变身卡数据[角色数据.变身数据].正负 == 1 then
				角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] = 角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] +
					math.floor(角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] * 变身卡数据[角色数据.变身数据].属性 / 100)
			else
				角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] = 角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] -
					math.floor(角色数据["最大" .. 变身卡数据[角色数据.变身数据].类型] * 变身卡数据[角色数据.变身数据].属性 / 100)
			end
		else
			local aa = {
				变身卡数据[角色数据.变身数据].类型 .. ""
			}

			if 变身卡数据[角色数据.变身数据].类型 == "灵力" then
				aa[#aa + 1] = "法伤"
				aa[#aa + 1] = "法防"
			end

			for i = 1, #aa do
				if 变身卡数据[角色数据.变身数据].正负 == 1 then
					角色数据[aa[i]] = 角色数据[aa[i]] + math.floor(角色数据[aa[i]] * 变身卡数据[角色数据.变身数据].属性 / 100)
				else
					角色数据[aa[i]] = 角色数据[aa[i]] - math.floor(角色数据[aa[i]] * 变身卡数据[角色数据.变身数据].属性 / 100)
				end
			end
		end
	end

	for i = 1, #百炼4 do
		角色数据.装备属性["百炼" .. 百炼4[i]] = nil

		if 角色数据.装备属性[百炼4[i] .. "百分比"] ~= nil and 角色数据.装备属性[百炼4[i] .. "百分比"] > 0 then
			if 百炼4[i] == "气血" or 百炼4[i] == "魔法" then
				角色数据.装备属性["百炼" .. 百炼4[i]] = qz(角色数据["最大" .. 百炼4[i]] * 角色数据.装备属性[百炼4[i] .. "百分比"] / 100)
			elseif 百炼4[i] == "基础属性" then
				local jc = {
					"气血",
					"魔法",
					"伤害",
					"命中",
					"防御",
					"速度",
					"躲避",
					"法防",
					"法伤"
				}

				for i = 1, #jc do
					if i <= 2 then
						角色数据.装备属性["百炼" .. jc[i]] = qz((角色数据.装备属性["百炼" .. jc[i]] or 0) +
							((角色数据.装备属性["百炼" .. jc[i]] or 0) + 角色数据["最大" .. jc[i]]) * 角色数据.装备属性.基础属性百分比 / 100)
					else
						角色数据.装备属性["百炼" .. jc[i]] = qz((角色数据.装备属性["百炼" .. jc[i]] or 0) +
							((角色数据.装备属性["百炼" .. jc[i]] or 0) + 角色数据[jc[i]]) * 角色数据.装备属性.基础属性百分比 / 100)
					end
				end
			else
				角色数据.装备属性["百炼" .. 百炼4[i]] = qz(角色数据[百炼4[i]] * 角色数据.装备属性[百炼4[i] .. "百分比"] / 100)
			end
		end
	end

	角色数据.最大气血 = qz(math.max(角色数据.最大气血 + (角色数据.装备属性.百炼气血 or 0), 70))
	角色数据.气血上限 = qz(math.max(角色数据.最大气血, 70))
	角色数据.最大魔法 = qz(math.max(角色数据.最大魔法 + (角色数据.装备属性.百炼魔法 or 0), 70))
	角色数据.气血 = qz(角色数据.最大气血 + 0)
	角色数据.魔法 = qz(角色数据.最大魔法 + 0)
	角色数据.命中 = qz(math.max(角色数据.命中 + (角色数据.装备属性.百炼命中 or 0), 1))
	角色数据.伤害 = qz(math.max(角色数据.伤害 + (角色数据.装备属性.百炼伤害 or 0), 1))
	角色数据.防御 = qz(math.max(角色数据.防御 + (角色数据.装备属性.百炼防御 or 0), 1))
	角色数据.速度 = qz(math.max(角色数据.速度 + (角色数据.装备属性.百炼速度 or 0), 1))
	角色数据.躲避 = qz(math.max(角色数据.躲避 + (角色数据.装备属性.百炼躲避 or 0), 1))
	角色数据.灵力 = qz(math.max(角色数据.灵力 + (角色数据.装备属性.百炼灵力 or 0), 1))
	角色数据.法防 = qz(math.max(角色数据.法防 + (角色数据.装备属性.百炼法防 or 0) + (角色数据.装备属性.百炼灵力 or 0), 1))
	角色数据.法伤 = qz(math.max(角色数据.法伤 + (角色数据.装备属性.百炼法伤 or 0) + (角色数据.装备属性.百炼灵力 or 0), 1))

	更新助战技能(id, 角色数据)
end

function 角色处理类:刷新信息(是否, 体质, 魔力)
	角色刷新信息(self.数据.数字id, self.数据)

	if 是否 == "1" then
		self.数据.气血 = self.数据.最大气血
		self.数据.气血上限 = self.数据.最大气血
		self.数据.魔法 = self.数据.最大魔法
	end

	if 体质 ~= nil and 体质 > 0 then
		self.数据.气血 = self.数据.最大气血
		self.数据.气血上限 = self.数据.最大气血
	end

	if self.数据.气血上限 == nil then
		self.数据.气血上限 = self.数据.最大气血
	end

	if 魔力 ~= nil and 魔力 > 0 then
		self.数据.魔法 = self.数据.最大魔法
	end

	if self.数据.最大气血 < self.数据.气血上限 then
		self.数据.气血上限 = self.数据.最大气血
	end

	if self.数据.气血上限 < self.数据.气血 then
		self.数据.气血 = self.数据.气血上限
	end

	if self.数据.最大魔法 < self.数据.魔法 then
		self.数据.魔法 = self.数据.最大魔法
	end

	if self.数据.愤怒 > 150 then
		self.数据.愤怒 = 150
	end

	if self.数据.最大活力 < self.数据.活力 then
		self.数据.活力 = self.数据.最大活力
	end

	if self.数据.最大体力 < self.数据.体力 then
		self.数据.体力 = self.数据.最大体力
	end

	if self.数据.等级 <= 174 then
		self.数据.最大经验 = 统一取经验(1, self.数据.等级)

		if 吊游定制 then
			self.数据.最大经验 = self.数据.最大经验 * 5
		end

		if 刻晴定制 and self.数据.等级 >= 144 then
			self.数据.最大经验 = self.数据.最大经验 * 3
		end
	end

	if self.数据.门派 ~= "无门派" and self.数据.师门技能[1] == nil then
		local 列表 = 取门派技能(self.数据.门派)

		if 列表 ~= nil and #列表 ~= nil then
			for n = 1, #列表 do
				self.数据.师门技能[n] = jnzb()

				self.数据.师门技能[n]:置对象(列表[n])

				self.数据.师门技能[n].包含技能 = {}
				local w = 取包含技能(self.数据.师门技能[n].名称)

				for s = 1, #w do
					self.数据.师门技能[n].包含技能[s] = jnzb()

					self.数据.师门技能[n].包含技能[s]:置对象(w[s])
				end
			end
		end
	end

	if self.数据.师门技能[1] ~= nil and 是否 == "2" then
		for n = 1, 7 do
			for l = 1, #self.数据.师门技能[n].包含技能 do
				if 有无技能(self.数据, self.数据.师门技能[n].包含技能[l].名称) then
					self.数据.师门技能[n].包含技能[l].学会 = true
				end
			end
		end
	end

	if 是否 == "2" or 是否 == "6" then
		发送数据(玩家数据[self.数据.数字id].连接id, 5506, {
			玩家数据[self.数据.数字id].角色:取气血数据()
		})
	end
end

更新助战技能 = function(id, 角色数据)
	if 角色数据.师门技能 ~= nil and #角色数据.师门技能 > 0 then
		角色数据.技能 = {}

		for n = 1, #角色数据.师门技能 do
			local w = 取包含技能(角色数据.师门技能[n].名称)

			for s = 1, #w do
				if 角色数据.师门技能[n].包含技能[s] == nil then
					角色数据.师门技能[n].包含技能[s] = {
						学会 = false,
						等级 = 角色数据.师门技能[n].等级,
						名称 = w[s]
					}
				end

				local 符石等级 = math.max(math.min(角色数据.装备属性[角色数据.师门技能[n].名称 .. "等级"] or 0, 符石技能等级[4] * 2), 0)

				if 角色数据.师门技能[n].包含技能[s].学会 then
					角色数据.技能[#角色数据.技能 + 1] = {
						名称 = 角色数据.师门技能[n].包含技能[s].名称,
						等级 = 角色数据.师门技能[n].等级 + 符石等级
					}
				end

				if s == #w then
					角色数据.技能[#角色数据.技能 + 1] = {
						名称 = 角色数据.师门技能[n].名称,
						等级 = 角色数据.师门技能[n].等级 + 符石等级
					}
				end
			end
		end
	end
end

取门派技能 = function(门派)
	local n = {}

	if 门派 == "大唐官府" then
		return {
			"为官之道",
			"无双一击",
			"神兵鉴赏",
			"疾风步",
			"十方无敌",
			"紫薇之术",
			"文韬武略"
		}
	elseif 门派 == "方寸山" then
		return {
			"黄庭经",
			"磐龙灭法",
			"霹雳咒",
			"符之术",
			"归元心法",
			"神道无念",
			"斜月步"
		}
	elseif 门派 == "化生寺" then
		return {
			"小乘佛法",
			"金刚伏魔",
			"诵经",
			"佛光普照",
			"大慈大悲",
			"歧黄之术",
			"渡世步"
		}
	elseif 门派 == "女儿村" then
		return {
			"毒经",
			"倾国倾城",
			"沉鱼落雁",
			"闭月羞花",
			"香飘兰麝",
			"玉质冰肌",
			"清歌妙舞"
		}
	elseif 门派 == "阴曹地府" then
		return {
			"灵通术",
			"六道轮回",
			"幽冥术",
			"拘魂诀",
			"九幽阴魂",
			"尸腐恶",
			"无常步"
		}
	elseif 门派 == "魔王寨" then
		return {
			"牛逼神功",
			"震天诀",
			"火云术",
			"火牛阵",
			"牛虱阵",
			"回身击",
			"裂石步"
		}
	elseif 门派 == "狮驼岭" then
		return {
			"魔兽神功",
			"生死搏",
			"训兽诀",
			"阴阳二气诀",
			"狂兽诀",
			"大鹏展翅",
			"魔兽反噬"
		}
	elseif 门派 == "盘丝洞" then
		return {
			"蛛丝阵法",
			"迷情大法",
			"秋波暗送",
			"天外魔音",
			"盘丝大法",
			"盘丝步",
			"姊妹相随"
		}
	elseif 门派 == "天宫" then
		return {
			"天罡气",
			"傲世诀",
			"清明自在",
			"宁气诀",
			"乾坤塔",
			"混天术",
			"云霄步"
		}
	elseif 门派 == "五庄观" then
		return {
			"周易学",
			"潇湘仙雨",
			"乾坤袖",
			"修仙术",
			"混元道果",
			"明性修身",
			"七星遁"
		}
	elseif 门派 == "龙宫" then
		return {
			"九龙诀",
			"破浪诀",
			"呼风唤雨",
			"龙腾术",
			"逆鳞术",
			"游龙术",
			"龙附术"
		}
	elseif 门派 == "普陀山" then
		return {
			"灵性",
			"护法金刚",
			"观音咒",
			"五行学说",
			"金刚经",
			"五行扭转",
			"莲花宝座"
		}
	elseif 门派 == "神木林" then
		return {
			"瞬息万变",
			"万灵诸念",
			"巫咒",
			"万物轮转",
			"天人庇护",
			"神木恩泽",
			"驭灵咒"
		}
	elseif 门派 == "凌波城" then
		return {
			"天地无极",
			"九转玄功",
			"武神显圣",
			"啸傲",
			"气吞山河",
			"诛魔",
			"法天象地"
		}
	elseif 门派 == "无底洞" then
		return {
			"枯骨心法",
			"阴风绝章",
			"鬼蛊灵蕴",
			"燃灯灵宝",
			"地冥妙法",
			"混元神功",
			"秘影迷踪"
		}
	elseif 门派 == "女魃墓" then
		return {
			"天火献誓",
			"天罚之焰",
			"煌火无明",
			"化神以灵",
			"弹指成烬",
			"藻光灵狱",
			"离魂"
		}
	elseif 门派 == "天机城" then
		return {
			"神工无形",
			"攻玉以石",
			"擎天之械",
			"千机奇巧",
			"匠心不移",
			"运思如电",
			"探奥索隐"
		}
	elseif 门派 == "花果山" then
		return {
			"神通广大",
			"如意金箍",
			"齐天逞胜",
			"金刚之躯",
			"灵猴九窍",
			"七十二变",
			"腾云驾霧"
		}
	elseif 门派 == "九黎城" then
		return {
			"九黎战歌",
			"魂枫战舞",
			"兵铸乾坤",
			"燃铁飞花",
			"战火雄魂",
			"魔神降世",
			"风行九黎"
		}
	end

	return n
end

function 角色处理类:取门派主技能(门派)
	if 门派 == 1 then
		a = {
			"催眠符",
			"落雷符",
			"追魂符",
			"五雷咒",
			"定身符",
			"定身符"
		}
	elseif 门派 == 2 then
		a = {
			"红袖添香",
			"楚楚可怜",
			"满天花雨",
			"雨落寒沙",
			"莲步轻舞",
			"如花解语"
		}
	elseif 门派 == 3 then
		a = {
			"落叶萧萧",
			"冰川怒",
			"血雨",
			"雾杀",
			"星月之惠",
			"蜜润"
		}
	elseif 门派 == 4 then
		a = {
			"唧唧歪歪",
			"韦陀护法",
			"金刚护体",
			"达摩护体",
			"一苇渡江",
			"金刚护法",
			"我佛慈悲",
			"推拿",
			"解毒",
			"活血",
			"推气过宫",
			"妙手回春",
			"救死扶伤"
		}
	elseif 门派 == 5 then
		a = {
			"杀气决",
			"后发制人",
			"横扫千军",
			"破釜沉舟",
			"先发制人"
		}
	elseif 门派 == 6 then
		a = {
			"还阳术",
			"阎罗令",
			"判官令"
		}
	elseif 门派 == 7 then
		a = {
			"勾魂",
			"摄魄",
			"含情脉脉"
		}
	elseif 门派 == 8 then
		a = {
			"移魂化骨",
			"夺魄令",
			"煞气决",
			"惊魂掌",
			"摧心术",
			"夺命咒",
			"地涌金莲"
		}
	elseif 门派 == 9 then
		a = {
			"三昧真火",
			"飞砂走石",
			"牛劲"
		}
	elseif 门派 == 10 then
		a = {
			"连环击",
			"鹰击",
			"狮搏",
			"象形",
			"变身"
		}
	elseif 门派 == 11 then
		a = {
			"五雷轰顶",
			"天雷斩",
			"百万神兵",
			"天神护体",
			"天神护法",
			"雷霆万钧"
		}
	elseif 门派 == 12 then
		a = {
			"普渡众生",
			"紧箍咒",
			"杨柳甘露",
			"日光华",
			"靛沧海",
			"巨岩破",
			"苍茫树",
			"地裂火",
			"颠倒五行",
			"灵动九天"
		}
	elseif 门派 == 13 then
		a = {
			"不动如山",
			"碎星诀",
			"裂石",
			"浪涌",
			"断岳势",
			"天崩地裂",
			"翻江搅海",
			"惊涛怒"
		}
	elseif 门派 == 14 then
		a = {
			"烟雨剑法",
			"飘渺式",
			"日月乾坤",
			"炼气化神",
			"生命之泉",
			"三花聚顶"
		}
	elseif 门派 == 15 then
		a = {
			"龙卷雨击",
			"龙腾",
			"龙吟",
			"逆鳞",
			"乘风破浪",
			"双龙戏珠"
		}
	elseif 门派 == 16 then
		a = {
			"炽火流离",
			"极天炼焰",
			"谜毒之缚",
			"诡蝠之刑",
			"怨怖之泣",
			"誓血之祭",
			"唤灵·魂火",
			"唤魔·堕羽",
			"唤魔·毒魅",
			"唤灵·焚魂",
			"天魔觉醒",
			"净世煌火",
			"焚魔烈焰",
			"幽影灵魄",
			"魂兮归来"
		}
	elseif 门派 == 17 then
		a = {
			"一发而动",
			"针锋相对",
			"攻守易位",
			"锋芒毕露",
			"诱袭",
			"匠心·破击",
			"匠心·削铁",
			"匠心·固甲",
			"匠心·蓄锐",
			"天马行空",
			"鬼斧神工",
			"移山填海"
		}
	elseif 门派 == 18 then
		a = {
			"威震凌霄",
			"气慑天军",
			"当头一棒",
			"神针撼海",
			"杀威铁棒",
			"泼天乱棒",
			"九幽除名",
			"移星换斗",
			"云暗天昏",
			"担山赶月",
			"铜头铁臂",
			"无所遁形",
			"天地洞明",
			"除光息焰",
			"呼子唤孙",
			"八戒上身",
			"筋斗云"
		}
	end

	return a
end

门派技能列表 = {
	为官之道 = {
		"杀气诀",
		"翩鸿一击"
	},
	无双一击 = {
		"后发制人",
		"先发制人"
	},
	神兵鉴赏 = {
		"兵器谱"
	},
	疾风步 = {
		"千里神行"
	},
	十方无敌 = {
		"横扫千军",
		"破釜沉舟"
	},
	紫薇之术 = {
		"斩龙诀"
	},
	文韬武略 = {
		"反间之计",
		"安神诀",
		"嗜血"
	},
	黄庭经 = {
		"三星灭魔"
	},
	磐龙灭法 = {
		"离魂符",
		"失魂符",
		"定身符",
		"碎甲符",
		"落雷符"
	},
	霹雳咒 = {
		"五雷咒"
	},
	符之术 = {
		"飞行符",
		"兵解符",
		"催眠符",
		"失心符",
		"落魄符",
		"失忆符",
		"追魂符"
	},
	归元心法 = {
		"归元咒",
		"凝神术"
	},
	神道无念 = {
		"乾天罡气",
		"分身术",
		"神兵护法"
	},
	斜月步 = {
		"乙木仙遁"
	},
	小乘佛法 = {
		"紫气东来"
	},
	金刚伏魔 = {
		"佛法无边"
	},
	诵经 = {
		"唧唧歪歪"
	},
	佛光普照 = {
		"达摩护体",
		"金刚护法",
		"韦陀护法",
		"金刚护体",
		"一苇渡江",
		"拈花妙指"
	},
	大慈大悲 = {
		"我佛慈悲"
	},
	歧黄之术 = {
		"推拿",
		"活血",
		"推气过宫",
		"妙手回春",
		"救死扶伤",
		"解毒",
		"舍身取义"
	},
	渡世步 = {
		"佛门普渡",
		"谆谆教诲"
	},
	毒经 = {},
	倾国倾城 = {
		"红袖添香",
		"楚楚可怜",
		"一笑倾城"
	},
	沉鱼落雁 = {
		"满天花雨",
		"情天恨海",
		"雨落寒沙"
	},
	闭月羞花 = {
		"莲步轻舞",
		"如花解语",
		"似玉生香",
		"娉婷袅娜"
	},
	香飘兰麝 = {
		"轻如鸿毛"
	},
	玉质冰肌 = {
		"百毒不侵"
	},
	清歌妙舞 = {
		"移形换影",
		"飞花摘叶"
	},
	灵通术 = {
		"堪察令",
		"寡欲令"
	},
	六道轮回 = {
		"魂飞魄散"
	},
	幽冥术 = {
		"阎罗令",
		"锢魂术",
		"黄泉之息"
	},
	拘魂诀 = {
		"判官令",
		"还阳术",
		"尸气漫天"
	},
	九幽阴魂 = {
		"幽冥鬼眼",
		"冤魂不散"
	},
	尸腐恶 = {
		"尸腐毒",
		"修罗隐身"
	},
	无常步 = {
		"杳无音讯"
	},
	牛逼神功 = {
		"魔王护持"
	},
	震天诀 = {
		"踏山裂石"
	},
	火云术 = {
		"飞砂走石",
		"三昧真火",
		"火甲术"
	},
	火牛阵 = {
		"牛劲"
	},
	牛虱阵 = {
		"无敌牛虱",
		"无敌牛妖",
		"摇头摆尾"
	},
	回身击 = {
		"魔王回首"
	},
	裂石步 = {
		"牛屎遁"
	},
	魔兽神功 = {
		"变身",
		"魔兽啸天"
	},
	生死搏 = {
		"象形",
		"鹰击",
		"狮搏",
		"天魔解体"
	},
	训兽诀 = {
		"威慑"
	},
	阴阳二气诀 = {
		"定心术",
		"魔息术"
	},
	狂兽诀 = {
		"连环击",
		"神力无穷"
	},
	大鹏展翅 = {
		"振翅千里"
	},
	魔兽反噬 = {
		"极度疯狂"
	},
	蛛丝阵法 = {
		"盘丝舞",
		"夺命蛛丝"
	},
	迷情大法 = {
		"含情脉脉",
		"瘴气",
		"魔音摄魂"
	},
	秋波暗送 = {
		"勾魂",
		"摄魄"
	},
	天外魔音 = {},
	盘丝大法 = {
		"盘丝阵",
		"复苏"
	},
	盘丝步 = {
		"天罗地网",
		"天蚕丝",
		"幻镜术"
	},
	姊妹相随 = {
		"姐妹同心"
	},
	天罡气 = {
		"天神护体",
		"天神护法",
		"天诛地灭",
		"五雷轰顶",
		"雷霆万钧",
		"浩然正气"
	},
	傲世诀 = {
		"天雷斩"
	},
	清明自在 = {
		"知己知彼"
	},
	宁气诀 = {
		"宁心"
	},
	乾坤塔 = {
		"镇妖",
		"错乱",
		"掌心雷"
	},
	混天术 = {
		"百万神兵",
		"金刚镯"
	},
	云霄步 = {
		"腾云驾雾"
	},
	九龙诀 = {
		"解封",
		"清心",
		"龍魂",
		"二龙戏珠"
	},
	破浪诀 = {
		"神龙摆尾"
	},
	呼风唤雨 = {
		"龙卷雨击"
	},
	龙腾术 = {
		"龙腾"
	},
	逆鳞术 = {
		"逆鳞"
	},
	游龙术 = {
		"乘风破浪",
		"水遁"
	},
	龙附术 = {
		"龙吟",
		"龙啸九天",
		"龙附"
	},
	灵性 = {
		"自在心法"
	},
	护法金刚 = {},
	观音咒 = {
		"紧箍咒",
		"杨柳甘露"
	},
	五行学说 = {
		"日光华",
		"靛沧海",
		"巨岩破",
		"苍茫树",
		"地裂火"
	},
	金刚经 = {
		"普渡众生",
		"灵动九天",
		"莲华妙法"
	},
	五行扭转 = {
		"五行错位",
		"颠倒五行"
	},
	莲花宝座 = {
		"坐莲"
	},
	周易学 = {
		"驱魔",
		"驱尸"
	},
	潇湘仙雨 = {
		"烟雨剑法",
		"飘渺式"
	},
	乾坤袖 = {
		"日月乾坤",
		"天地同寿",
		"乾坤妙法"
	},
	修仙术 = {
		"炼气化神",
		"生命之泉",
		"一气化三清"
	},
	混元道果 = {
		"太极生化"
	},
	明性修身 = {
		"三花聚顶"
	},
	七星遁 = {
		"斗转星移"
	},
	瞬息万变 = {
		"落叶萧萧"
	},
	万灵诸念 = {
		"荆棘舞",
		"尘土刃",
		"冰川怒"
	},
	巫咒 = {
		"雾杀",
		"血雨"
	},
	万物轮转 = {
		"星月之惠"
	},
	天人庇护 = {
		"炎护",
		"叶隐"
	},
	神木恩泽 = {
		"神木呓语"
	},
	驭灵咒 = {
		"蜜润",
		"蝼蚁蚀天"
	},
	天地无极 = {
		"穿云破空"
	},
	九转玄功 = {
		"不动如山"
	},
	武神显圣 = {
		"碎星诀",
		"镇魂诀"
	},
	啸傲 = {
		"指地成钢"
	},
	气吞山河 = {
		"裂石",
		"断岳势",
		"天崩地裂",
		"浪涌",
		"惊涛怒",
		"翻江搅海"
	},
	诛魔 = {
		"腾雷"
	},
	法天象地 = {
		"无穷妙道",
		"纵地金光"
	},
	枯骨心法 = {
		"移魂化骨"
	},
	阴风绝章 = {
		"夺魄令",
		"煞气诀",
		"惊魂掌",
		"摧心术"
	},
	鬼蛊灵蕴 = {
		"夺命咒"
	},
	燃灯灵宝 = {
		"明光宝烛",
		"金身舍利"
	},
	地冥妙法 = {
		"地涌金莲",
		"万木凋枯"
	},
	混元神功 = {
		"元阳护体"
	},
	秘影迷踪 = {
		"遁地术"
	},
	天火献誓 = {},
	天罚之焰 = {
		"炽火流离",
		"极天炼焰"
	},
	煌火无明 = {
		"谜毒之缚",
		"诡蝠之刑",
		"怨怖之泣",
		"誓血之祭"
	},
	化神以灵 = {
		"唤灵·魂火",
		"唤魔·堕羽",
		"唤魔·毒魅",
		"唤灵·焚魂",
		"天魔觉醒"
	},
	弹指成烬 = {
		"净世煌火",
		"焚魔烈焰"
	},
	藻光灵狱 = {
		"幽影灵魄"
	},
	离魂 = {
		"魂兮归来"
	},
	神工无形 = {
		"一发而动"
	},
	攻玉以石 = {
		"针锋相对",
		"攻守易位"
	},
	擎天之械 = {
		"锋芒毕露"
	},
	千机奇巧 = {
		"诱袭",
		"匠心·破击"
	},
	匠心不移 = {
		"匠心·削铁",
		"匠心·固甲",
		"匠心·蓄锐"
	},
	运思如电 = {
		"天马行空"
	},
	探奥索隐 = {
		"鬼斧神工",
		"移山填海"
	},
	神通广大 = {
		"如意神通",
		"威震凌霄",
		"气慑天军"
	},
	如意金箍 = {
		"当头一棒",
		"神针撼海",
		"杀威铁棒",
		"泼天乱棒"
	},
	齐天逞胜 = {
		"九幽除名",
		"移星换斗",
		"云暗天昏"
	},
	金刚之躯 = {
		"担山赶月",
		"铜头铁臂"
	},
	灵猴九窍 = {
		"无所遁形",
		"天地洞明",
		"除光息焰"
	},
	七十二变 = {
		"呼子唤孙",
		"八戒上身"
	},
	腾云驾霧 = {
		"筋斗云"
	},
	九黎战歌 = {
		"黎魂",
		"战鼓",
		"怒哮",
		"炎魂"
	},
	魂枫战舞 = {
		"枫影二刃"
	},
	兵铸乾坤 = {
		"一斧开天"
	},
	燃铁飞花 = {
		"三荒尽灭"
	},
	战火雄魂 = {
		"铁血生风"
	},
	魔神降世 = {
		"力辟苍穹"
	},
	风行九黎 = {
		"故壤归心"
	}
}

取包含技能 = function(名称)
	return 门派技能列表[名称]
end

function 角色处理类:取技能id(名称)
	for n, v in pairs(门派技能列表) do
		for i = 1, #门派技能列表[n] do
			if 门派技能列表[n][i] == 名称 then
				return n
			end
		end
	end

	return 0
end

有无技能 = function(角色数据, 名称)
	if 角色数据.人物技能 == nil then
		角色数据.人物技能 = {}
	end

	for n = 1, #角色数据.人物技能 do
		if 角色数据.人物技能[n].名称 == 名称 then
			return true
		end
	end

	return false
end

function 角色处理类:取模型(ID)
	local 角色信息 = {
		"飞燕女",
		"英女侠",
		"巫蛮儿",
		"逍遥生",
		"剑侠客",
		"狐美人",
		"骨精灵",
		"杀破狼",
		"巨魔王",
		"虎头怪",
		"舞天姬",
		"玄彩娥",
		"羽灵神",
		"神天兵",
		"龙太子",
		"桃夭夭",
		"偃无师",
		"鬼潇潇",
		"影精灵"
	}

	return 角色信息[ID]
end

function 角色处理类:队伍角色(模型)
	local 角色信息 = {
		飞燕女 = {
			染色方案 = 3,
			性别 = "女",
			模型 = "飞燕女",
			ID = 1,
			种族 = "人",
			门派 = {
				"大唐官府",
				"女儿村",
				"方寸山",
				"神木林"
			},
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
			门派 = {
				"大唐官府",
				"女儿村",
				"方寸山",
				"神木林"
			},
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
			门派 = {
				"大唐官府",
				"女儿村",
				"方寸山",
				"神木林"
			},
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
			门派 = {
				"大唐官府",
				"化生寺",
				"方寸山",
				"神木林"
			},
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
			门派 = {
				"大唐官府",
				"化生寺",
				"方寸山",
				"神木林"
			},
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
			门派 = {
				"盘丝洞",
				"阴曹地府",
				"魔王寨",
				"无底洞"
			},
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
			门派 = {
				"盘丝洞",
				"阴曹地府",
				"魔王寨",
				"无底洞"
			},
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
			门派 = {
				"狮驼岭",
				"阴曹地府",
				"魔王寨",
				"无底洞"
			},
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
			门派 = {
				"狮驼岭",
				"阴曹地府",
				"魔王寨",
				"无底洞"
			},
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
			门派 = {
				"狮驼岭",
				"阴曹地府",
				"魔王寨",
				"无底洞"
			},
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
			门派 = {
				"天宫",
				"普陀山",
				"龙宫",
				"凌波城"
			},
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
			门派 = {
				"天宫",
				"普陀山",
				"龙宫",
				"凌波城"
			},
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
			门派 = {
				"天宫",
				"普陀山",
				"龙宫",
				"凌波城"
			},
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
			门派 = {
				"天宫",
				"五庄观",
				"龙宫",
				"凌波城"
			},
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
			门派 = {
				"天宫",
				"五庄观",
				"龙宫",
				"凌波城"
			},
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
			门派 = {
				"天宫",
				"普陀山",
				"龙宫",
				"凌波城"
			},
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
			门派 = {
				"大唐官府",
				"化生寺",
				"方寸山",
				"神木林"
			},
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
			门派 = {
				"盘丝洞",
				"阴曹地府",
				"魔王寨",
				"无底洞"
			},
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
			门派 = {
				"盘丝洞",
				"阴曹地府",
				"魔王寨",
				"无底洞"
			},
			武器 = {
				"魔棒",
				"爪刺"
			}
		}
	}

	return 角色信息[模型]
end

function 角色处理类:取初始属性(种族)
	local 属性 = {
		人 = {
			10,
			10,
			10,
			10,
			10
		},
		魔 = {
			12,
			11,
			11,
			8,
			8
		},
		仙 = {
			12,
			5,
			11,
			12,
			10
		}
	}

	return 属性[种族]
end

取角色属性 = function(种族, 五维, 技能, 门派)
	local 属性 = {}
	local 力量 = 五维[3]
	local 体质 = 五维[1]
	local 魔力 = 五维[2]
	local 耐力 = 五维[4]
	local 敏捷 = 五维[5]
	技能 = 技能 or {
		0,
		0,
		0,
		0
	}

	if 种族 == "人" or 种族 == 1 and 门派 ~= "九黎城" then
		属性 = {
			命中 = ceil(力量 * 2 + 30),
			伤害 = ceil(力量 * 0.67 + 39),
			防御 = ceil(耐力 * 1.5),
			速度 = ceil((体质 + 力量 + 耐力) * 0.1 + 敏捷 * 0.7),
			灵力 = ceil(体质 * 0.3 + 魔力 * 0.7 + 耐力 * 0.2 + 力量 * 0.4),
			躲避 = ceil(敏捷 + 10),
			气血 = ceil((体质 * 5 + 100) * (1 + 技能[1] / 100) + 技能[3] * 4),
			法力 = ceil((魔力 * 3 + 80) * (1 + 技能[2] / 100))
		}
	elseif 种族 == "魔" or 种族 == 2 or 门派 == "九黎城" then
		属性 = {
			命中 = ceil(力量 * 2.3 + 29),
			伤害 = ceil(力量 * 0.77 + 39),
			防御 = ceil(耐力 * 1.4),
			速度 = ceil((体质 + 力量 + 耐力) * 0.1 + 敏捷 * 0.7),
			灵力 = ceil(体质 * 0.3 + 魔力 * 0.7 + 耐力 * 0.2 + 力量 * 0.4),
			躲避 = ceil(敏捷 + 10),
			气血 = ceil((体质 * 6 + 100) * (1 + 技能[1] / 100) + 技能[3] * 4),
			法力 = ceil((魔力 * 2.5 + 80) * (1 + 技能[2] / 100))
		}
	elseif 种族 == "仙" or 种族 == 3 and 门派 ~= "九黎城" then
		属性 = {
			命中 = ceil(力量 * 1.7 + 30),
			伤害 = ceil(力量 * 0.57 + 39),
			防御 = ceil(耐力 * 1.6),
			速度 = ceil((体质 + 力量 + 耐力) * 0.1 + 敏捷 * 0.7),
			灵力 = ceil(体质 * 0.3 + 魔力 * 0.7 + 耐力 * 0.2 + 力量 * 0.4),
			躲避 = ceil(敏捷 + 10),
			气血 = ceil((体质 * 4.5 + 100) * (1 + 技能[1] / 100) + 技能[3] * 4),
			法力 = ceil((魔力 * 3.5 + 80) * (1 + 技能[2] / 100))
		}
	end

	return 属性
end

function 角色处理类:日志记录(内容)
	self.日志内容 = self.日志内容 .. "\n" .. 时间转换(os.time()) .. 内容 .. "#分割符" .. "\n"
end

function 角色处理类:大额日志记录(内容)
	大额日志内容 = 大额日志内容 .. "\n" .. 时间转换(os.time()) .. 内容 .. "#分割符" .. "\n"
end

function 角色处理类:显示(x, y)
end

学会技能 = function(角色数据, id, gz)
	if 角色数据.师门技能[id] ~= nil then
		local mpjn = 取门派技能(角色数据.门派)

		if mpjn ~= nil and mpjn[id] ~= nil then
			local bhjn = 取包含技能(mpjn[id])

			if #角色数据.师门技能[id].包含技能 < #bhjn then
				local jn1 = {}

				for i = 1, #角色数据.师门技能[id].包含技能 do
					jn1[角色数据.师门技能[id].包含技能[i].名称] = 1
				end

				for i = 1, #bhjn do
					if jn1[bhjn[i]] == nil then
						角色数据.师门技能[id].包含技能[#角色数据.师门技能[id].包含技能 + 1] = {
							学会 = false,
							名称 = bhjn[i],
							等级 = 角色数据.师门技能[id].等级
						}
					end
				end
			end
		end

		for s = 1, #角色数据.师门技能[id].包含技能 do
			if 角色数据.师门技能[id].包含技能[s].名称 == gz and (角色数据.师门技能[id].包含技能[s].学会 == false or not 有无技能(角色数据, gz)) then
				local 飞升技能 = 列表模式转换(取飞升技能(角色数据.门派))

				if 飞升技能[角色数据.师门技能[id].包含技能[s].名称] == nil or 角色数据.飞升 == true then
					角色数据.师门技能[id].包含技能[s].学会 = true
					角色数据.师门技能[id].包含技能[s].等级 = 角色数据.师门技能[id].等级

					if 角色数据.人物技能 == nil then
						角色数据.人物技能 = {}
					end

					table.insert(角色数据.人物技能, table.loadstring(table.tostring(角色数据.师门技能[id].包含技能[s])))

					if 角色数据.助战等级 == nil then
						常规提示(角色数据.数字id, "恭喜你学会了新技能#R/" .. 角色数据.师门技能[id].包含技能[s].名称)
					else
						常规提示(角色数据.玩家id, "恭喜你学会了新技能#R/" .. 角色数据.师门技能[id].包含技能[s].名称)
					end
				end
			elseif 角色数据.师门技能[id].包含技能[s].名称 == gz then
				角色数据.师门技能[id].包含技能[s].等级 = 角色数据.师门技能[id].等级
			end
		end
	end
end

function 角色处理类:取是否飞升()
	if self.数据.剧情.飞升 == true and self.数据.飞升 == true then
		return true
	end

	return fasle
end

角色升级门派技能 = function(角色数据, jn)
	if jn.等级 == nil then
		jn.等级 = 1
	end

	if jn.名称 == "小乘佛法" then
		角色数据.技能属性.灵力 = floor(jn.等级 * 1)

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "紫气东来")
		end
	elseif jn.名称 == "金刚伏魔" then
		角色数据.技能属性.伤害 = floor(jn.等级 * 2)

		if jn.等级 >= 109 then
			学会技能(角色数据, 2, "佛法无边")
		end
	elseif jn.名称 == "诵经" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "唧唧歪歪")
		end
	elseif jn.名称 == "佛光普照" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "韦陀护法")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "金刚护体")
			学会技能(角色数据, 4, "拈花妙指")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "达摩护体")
			学会技能(角色数据, 4, "一苇渡江")
			学会技能(角色数据, 4, "金刚护法")
		end
	elseif jn.名称 == "大慈大悲" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "我佛慈悲")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "歧黄之术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "推拿")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "解毒")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "活血")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "推气过宫")
			学会技能(角色数据, 6, "救死扶伤")
			学会技能(角色数据, 6, "妙手回春")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 6, "舍身取义")
		end
	elseif jn.名称 == "渡世步" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "佛门普渡")
		end

		if jn.等级 >= 45 then
			学会技能(角色数据, 7, "谆谆教诲")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "为官之道" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "杀气诀")
		end

		if jn.等级 >= 45 then
			学会技能(角色数据, 1, "翩鸿一击")
		end
	elseif jn.名称 == "无双一击" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "后发制人")
			学会技能(角色数据, 2, "先发制人")
		end

		角色数据.技能属性.命中 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "神兵鉴赏" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "兵器谱")
		end
	elseif jn.名称 == "疾风步" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 4, "千里神行")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "十方无敌" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "横扫千军")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 5, "破釜沉舟")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "紫薇之术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "斩龙诀")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "文韬武略" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "反间之计")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "嗜血")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 7, "安神诀")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "九龙诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "清心")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "解封")
		end

		if jn.等级 >= 45 then
			学会技能(角色数据, 1, "龍魂")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 1, "二龙戏珠")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "破浪诀" then
		角色数据.技能属性.伤害 = floor(jn.等级 * 2.1)

		if jn.等级 >= 109 then
			学会技能(角色数据, 2, "神龙摆尾")
		end
	elseif jn.名称 == "呼风唤雨" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "龙卷雨击")
		end
	elseif jn.名称 == "龙腾术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "龙腾")
		end
	elseif jn.名称 == "逆鳞术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "逆鳞")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "游龙术" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 6, "水遁")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "乘风破浪")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "龙附术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "龙啸九天")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "龙吟")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "龙附")
		end
	elseif jn.名称 == "黄庭经" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "三星灭魔")
		end
	elseif jn.名称 == "磐龙灭法" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "离魂符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "失魂符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "定身符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "落雷符")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 2, "碎甲符")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "霹雳咒" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "五雷咒")
		end
	elseif jn.名称 == "符之术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "催眠符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "兵解符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "落魄符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "追魂符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "飞行符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "失忆符")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "失心符")
		end
	elseif jn.名称 == "归元心法" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "归元咒")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "凝神术")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "神道无念" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "乾天罡气")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "神兵护法")
			学会技能(角色数据, 6, "浩然正气")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 6, "分身术")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "斜月步" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "乙木仙遁")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "灵通术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "堪察令")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "寡欲令")
		end
	elseif jn.名称 == "幽冥术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "阎罗令")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "锢魂术")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 3, "黄泉之息")
		end
	elseif jn.名称 == "六道轮回" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "魂飞魄散")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "拘魂诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "判官令")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "尸气漫天")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 4, "还阳术")
		end
	elseif jn.名称 == "九幽阴魂" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "幽冥鬼眼")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "冤魂不散")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "尸腐恶" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "尸腐毒")
			学会技能(角色数据, 6, "修罗隐身")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "无常步" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "杳无音讯")
		end

		角色数据.技能属性.速度 = floor(jn.等级 * 0.3)
	elseif jn.名称 == "天罡气" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "天神护体")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "天神护法")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "五雷轰顶")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "天诛地灭")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "浩然正气")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 1, "雷霆万钧")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "傲世诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "天雷斩")
		end
	elseif jn.名称 == "清明自在" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "知己知彼")
		end

		角色数据.技能属性.气血 = floor(jn.等级 * 3)
	elseif jn.名称 == "宁气诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "宁心")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "乾坤塔" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "错乱")
		end

		if jn.等级 >= 50 then
			学会技能(角色数据, 5, "镇妖")
		end

		if jn.等级 >= 50 then
			学会技能(角色数据, 5, "掌心雷")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "混天术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "百万神兵")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 6, "金刚镯")
		end
	elseif jn.名称 == "云霄步" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "腾云驾雾")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "牛逼神功" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "魔王护持")
		end
	elseif jn.名称 == "火云术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "飞砂走石")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "三昧真火")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 3, "火甲术")
		end
	elseif jn.名称 == "裂石步" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "牛屎遁")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "震天诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "踏山裂石")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "火牛阵" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "牛劲")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "牛虱阵" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "无敌牛妖")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 5, "摇头摆尾")
			学会技能(角色数据, 5, "无敌牛虱")
		end
	elseif jn.名称 == "回身击" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "魔王回首")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "裂石步" then
		角色数据.技能属性.速度 = floor(jn.等级 * 0.3)
	elseif jn.名称 == "灵性" then
		角色数据.技能属性.灵力 = floor(jn.等级 * 1)

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "自在心法")
		end
	elseif jn.名称 == "护法金刚" then
		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "金刚经" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "普渡众生")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "莲华妙法")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 5, "灵动九天")
		end
	elseif jn.名称 == "观音咒" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "紧箍咒")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "杨柳甘露")
		end
	elseif jn.名称 == "五行学说" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "日光华")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "靛沧海")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "巨岩破")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "苍茫树")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "地裂火")
		end
	elseif jn.名称 == "五行扭转" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "五行错位")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "颠倒五行")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "莲花宝座" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "坐莲")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "周易学" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "驱魔")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "驱尸")
		end

		角色数据.技能属性.魔法 = floor(jn.等级 * 3)
	elseif jn.名称 == "潇湘仙雨" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "烟雨剑法")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "飘渺式")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 1.8)
	elseif jn.名称 == "乾坤袖" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "日月乾坤")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 3, "天地同寿")
			学会技能(角色数据, 3, "乾坤妙法")
		end
	elseif jn.名称 == "修仙术" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "炼气化神")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "生命之泉")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "一气化三清")
		end
	elseif jn.名称 == "混元道果" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "太极生化")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "明性修身" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "三花聚顶")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "七星遁" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "斗转星移")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "魔兽神功" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "变身")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "魔兽啸天")
		end
	elseif jn.名称 == "生死搏" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "象形")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "鹰击")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "狮搏")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 2, "天魔解体")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "阴阳二气诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "定心术")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 4, "魔息术")
		end
	elseif jn.名称 == "训兽诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "威慑")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "狂兽诀" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "连环击")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "神力无穷")
		end
	elseif jn.名称 == "大鹏展翅" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 6, "振翅千里")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "魔兽反噬" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "极度疯狂")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "秋波暗送" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "勾魂")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "摄魄")
		end

		角色数据.技能属性.命中 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "蛛丝阵法" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "盘丝舞")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "夺命蛛丝")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "迷情大法" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "含情脉脉")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 2, "魔音摄魂")
			学会技能(角色数据, 2, "瘴气")
		end
	elseif jn.名称 == "盘丝大法" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "盘丝阵")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "复苏")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "天外魔音" then
		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "盘丝步" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "天罗地网")
		end

		if jn.等级 >= 1 then
			学会技能(角色数据, 6, "天蚕丝")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 6, "幻镜术")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "姊妹相随" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "姐妹同心")
		end
	elseif jn.名称 == "天地无极" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "穿云破空")
		end
	elseif jn.名称 == "九转玄功" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "不动如山")
		end
	elseif jn.名称 == "武神显圣" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "碎星诀")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 3, "镇魂诀")
		end
	elseif jn.名称 == "气吞山河" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "裂石")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "浪涌")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "断岳势")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "天崩地裂")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "翻江搅海")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "惊涛怒")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "啸傲" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "指地成钢")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "诛魔" then
		if jn.等级 >= 120 then
			学会技能(角色数据, 6, "腾雷")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "法天象地" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "纵地金光")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "无穷妙道")
		end

		角色数据.技能属性.命中 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "瞬息万变" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "落叶萧萧")
		end
	elseif jn.名称 == "万灵诸念" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "荆棘舞")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "尘土刃")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "冰川怒")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "巫咒" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "雾杀")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 3, "血雨")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "万物轮转" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "星月之惠")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "天人庇护" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "炎护")
		end

		if jn.等级 >= 1 then
			学会技能(角色数据, 5, "叶隐")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "神木恩泽" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "神木呓语")
		end
	elseif jn.名称 == "驭灵咒" then
		if jn.等级 >= 109 then
			学会技能(角色数据, 7, "蜜润")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 7, "蝼蚁蚀天")
		end

		角色数据.技能属性.魔法 = floor(jn.等级 * 3)
	elseif jn.名称 == "枯骨心法" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 1, "移魂化骨")
		end
	elseif jn.名称 == "阴风绝章" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "夺魄令")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "煞气诀")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "惊魂掌")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 2, "摧心术")
		end
	elseif jn.名称 == "鬼蛊灵蕴" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "夺命咒")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "燃灯灵宝" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "明光宝烛")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 4, "金身舍利")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "地冥妙法" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "地涌金莲")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "万木凋枯")
		end
	elseif jn.名称 == "混元神功" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "元阳护体")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "秘影迷踪" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "遁地术")
		end

		角色数据.技能属性.速度 = floor(jn.等级 * 0.3)
	elseif jn.名称 == "毒经" then
		角色数据.技能属性.伤害 = floor(jn.等级 * 2)
	elseif jn.名称 == "倾国倾城" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "红袖添香")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "楚楚可怜")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 2, "一笑倾城")
		end
	elseif jn.名称 == "沉鱼落雁" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "满天花雨")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "情天恨海")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "雨落寒沙")
		end
	elseif jn.名称 == "闭月羞花" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "莲步轻舞")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "如花解语")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "似玉生香")
		end

		if jn.等级 >= 10 then
			学会技能(角色数据, 4, "娉婷袅娜")
		end
	elseif jn.名称 == "香飘兰麝" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 5, "轻如鸿毛")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "玉质冰肌" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "百毒不侵")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "清歌妙舞" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "移形换影")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 7, "飞花摘叶")
		end

		角色数据.技能属性.速度 = floor(jn.等级 * 0.7)
	elseif jn.名称 == "天罚之焰" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 2, "炽火流离")
		end

		if jn.等级 >= 25 then
			学会技能(角色数据, 2, "极天炼焰")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "煌火无明" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 3, "诡蝠之刑")
		end

		if jn.等级 >= 15 then
			学会技能(角色数据, 3, "谜毒之缚")
		end

		if jn.等级 >= 30 then
			学会技能(角色数据, 3, "怨怖之泣")
		end

		if jn.等级 >= 40 then
			学会技能(角色数据, 3, "誓血之祭")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "化神以灵" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 4, "唤灵·魂火")
		end

		if jn.等级 >= 20 then
			学会技能(角色数据, 4, "唤魔·堕羽")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 4, "唤魔·毒魅")
			学会技能(角色数据, 4, "唤灵·焚魂")
		end
	elseif jn.名称 == "弹指成烬" then
		if jn.等级 >= 25 then
			学会技能(角色数据, 5, "净世煌火")
		end

		if jn.等级 >= 35 then
			学会技能(角色数据, 5, "焚魔烈焰")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "藻光灵狱" then
		if jn.等级 >= 35 then
			学会技能(角色数据, 6, "幽影灵魄")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "离魂" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "魂兮归来")
		end

		角色数据.技能属性.速度 = floor(jn.等级 * 0.3)
	elseif jn.名称 == "攻玉以石" then
		if jn.等级 >= 25 then
			学会技能(角色数据, 2, "针锋相对")
		end

		if jn.等级 >= 109 then
			学会技能(角色数据, 2, "攻守易位")
		end
	elseif jn.名称 == "擎天之械" then
		if jn.等级 >= 25 then
			学会技能(角色数据, 3, "锋芒毕露")
		end
	elseif jn.名称 == "千机奇巧" then
		if jn.等级 >= 45 then
			学会技能(角色数据, 4, "诱袭")
		end

		if jn.等级 >= 1 then
			学会技能(角色数据, 4, "匠心·破击")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "匠心不移" then
		if jn.等级 >= 109 then
			学会技能(角色数据, 5, "匠心·削铁")
		end

		if jn.等级 >= 35 then
			学会技能(角色数据, 5, "匠心·固甲")
		end

		if jn.等级 >= 25 then
			学会技能(角色数据, 5, "匠心·蓄锐")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "运思如电" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 6, "天马行空")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "探奥索隐" then
		if jn.等级 >= 35 then
			学会技能(角色数据, 7, "鬼斧神工")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "神通广大" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 1, "如意神通")
		end

		if jn.等级 >= 120 then
			学会技能(角色数据, 1, "威震凌霄")
			学会技能(角色数据, 1, "气慑天军")
		end
	elseif jn.名称 == "如意金箍" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 2, "当头一棒")
			学会技能(角色数据, 2, "神针撼海")
			学会技能(角色数据, 2, "杀威铁棒")
			学会技能(角色数据, 2, "泼天乱棒")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "齐天逞胜" then
		if jn.等级 >= 15 then
			学会技能(角色数据, 3, "移星换斗")
		end

		if jn.等级 >= 1 then
			学会技能(角色数据, 3, "九幽除名")
			学会技能(角色数据, 3, "云暗天昏")
		end

		if jn.等级 >= 15 then
			学会技能(角色数据, 3, "移星换斗")
		end
	elseif jn.名称 == "金刚之躯" then
		if jn.等级 >= 35 then
			学会技能(角色数据, 4, "担山赶月")
		end

		if jn.等级 >= 1 then
			学会技能(角色数据, 4, "铜头铁臂")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "灵猴九窍" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 5, "无所遁形")
		end

		if jn.等级 >= 25 then
			学会技能(角色数据, 5, "除光息焰")
		end

		角色数据.技能属性.命中 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "七十二变" then
		if jn.等级 >= 10 then
			学会技能(角色数据, 6, "呼子唤孙")
		end

		if jn.等级 >= 45 then
			学会技能(角色数据, 6, "八戒上身")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "腾云驾霧" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "筋斗云")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "九黎战歌" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 1, "黎魂")
			学会技能(角色数据, 1, "战鼓")
			学会技能(角色数据, 1, "怒哮")
			学会技能(角色数据, 1, "炎魂")
		end
	elseif jn.名称 == "魂枫战舞" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 2, "枫影二刃")
		end

		角色数据.技能属性.伤害 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "兵铸乾坤" then
		if jn.等级 >= 30 then
			学会技能(角色数据, 3, "一斧开天")
		end

		角色数据.技能属性.灵力 = floor(jn.等级 * 1)
	elseif jn.名称 == "燃铁飞花" then
		if jn.等级 >= 30 then
			学会技能(角色数据, 4, "三荒尽灭")
		end

		角色数据.技能属性.命中 = floor(jn.等级 * 2.5)
	elseif jn.名称 == "战火雄魂" then
		if jn.等级 >= 30 then
			学会技能(角色数据, 5, "铁血生风")
		end

		角色数据.技能属性.防御 = floor(jn.等级 * 1.5)
	elseif jn.名称 == "魔神降世" then
		if jn.等级 >= 30 then
			学会技能(角色数据, 6, "力辟苍穹")
		end
	elseif jn.名称 == "风行九黎" then
		if jn.等级 >= 1 then
			学会技能(角色数据, 7, "故壤归心")
		end

		角色数据.技能属性.躲避 = floor(jn.等级 * 2.5)
	end

	if 角色数据.助战等级 == nil then
		玩家数据[角色数据.数字id].角色:刷新信息()
	end
end

角色耐久处理 = function(id, 类型, 角色数据, 助战编号, 耐久标准, 次数)
	if (次数 or 0) < 1 then
		return
	end

	local 扣除耐久 = 耐久标准 * 次数
	local 特效永不磨损 = false

	if 类型 == 1 then
		local aa = {
			3
		}

		if 角色数据.门派 == "九黎城" and 角色数据.装备[4] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[4]] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[4]].子类 == 911 then
			aa[#aa + 1] = 4

			if 角色数据.装备[3] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[3]] ~= nil then
				扣除耐久 = 扣除耐久 * 0.5
			end
		end

		for i = 1, #aa do
			local w = aa[i]

			if 角色数据.装备[w] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[w]] ~= nil then
				if 玩家数据[id].道具.数据[角色数据.装备[w]].星位 ~= nil then
					for i = 1, 6 do
						if 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i] ~= nil then
							if 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].耐久 == nil then
								local lv = 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].符石等级 or 3
								玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].耐久 = math.max(lv * 100, 150)
							end

							if 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].耐久 > 0 then
								玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].耐久 = 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].耐久 - 扣除耐久
							end

							if 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].耐久 <= 0 then
								if 助战编号 ~= nil then
									发送数据(玩家数据[id].连接id, 7,
										"#P(助战)#S/" ..
										玩家数据[id].助战.数据[助战编号].名称 ..
										"#Y的#r/" ..
										玩家数据[id].道具.数据[角色数据.装备[w]].名称 ..
										"#y/的#S/" .. 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].名称 .. "#y因耐久度过低已无法使用！")
								else
									发送数据(玩家数据[id].连接id, 7,
										"#y/你的#r/" ..
										玩家数据[id].道具.数据[角色数据.装备[w]].名称 ..
										"#y/的#S/" .. 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].名称 .. "#y因耐久度过低已无法使用！")
								end

								if 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].符石属性 ~= nil then
									for k, v in pairs(玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].符石属性) do
										角色数据.装备属性[k] = 角色数据.装备属性[k] - v
									end
								end

								if 玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].相互 ~= nil then
									for k, v in pairs(玩家数据[id].道具.数据[角色数据.装备[w]].星位[i].相互) do
										角色数据.装备属性[k] = 角色数据.装备属性[k] - v
									end
								end

								玩家数据[id].道具.数据[角色数据.装备[w]].星位[i] = nil

								if 助战编号 == nil then
									发送数据(玩家数据[id].连接id, 3503, 玩家数据[id].角色:取装备数据())
								end
							end
						end
					end
				end

				特效永不磨损 = false
				local 特效判断 = {}

				if 玩家数据[id].道具.数据[角色数据.装备[w]].特效 ~= nil then
					特效判断 = 列表模式转换(玩家数据[id].道具.数据[角色数据.装备[w]].特效)
				end

				if 特效判断.永不磨损 ~= nil then
					特效永不磨损 = true
				end

				if 特效永不磨损 == false and 玩家数据[id].道具.数据[角色数据.装备[w]].耐久 > 0 then
					if 角色数据.门派 == "大唐官府" then
						扣除耐久 = 扣除耐久 * 0.5
					elseif 角色数据.门派 == "狮驼岭" then
						扣除耐久 = 扣除耐久 * 0.7
					elseif 角色数据.门派 ~= "大唐官府" and 角色数据.奇经八脉 ~= nil and 角色数据.奇经八脉.锤炼 ~= nil then
						扣除耐久 = 扣除耐久 * 0.6
					end

					玩家数据[id].道具.数据[角色数据.装备[w]].耐久 = 玩家数据[id].道具.数据[角色数据.装备[w]].耐久 - 扣除耐久

					if 玩家数据[id].道具.数据[角色数据.装备[w]].耐久 <= 0 then
						玩家数据[id].道具.数据[角色数据.装备[w]].耐久 = 0
						玩家数据[id].无耐久减属性 = true

						if 助战编号 ~= nil then
							玩家数据[id].助战:卸下装备(助战编号, 玩家数据[id].道具.数据[角色数据.装备[w]])
							发送数据(玩家数据[id].连接id, 7,
								"#P(助战)#S/" ..
								玩家数据[id].助战.数据[助战编号].名称 .. "#Y的#r/" .. 玩家数据[id].道具.数据[角色数据.装备[w]].名称 .. "#y/因耐久度过低已无法使用")
						else
							玩家数据[id].角色:卸下装备(玩家数据[id].道具.数据[角色数据.装备[w]], 玩家数据[id].道具.数据[角色数据.装备[w]].分类, id)
							发送数据(玩家数据[id].连接id, 7, "#y/你的#r/" .. 玩家数据[id].道具.数据[角色数据.装备[w]].名称 .. "#y/因耐久度过低已无法使用")
							发送数据(玩家数据[id].连接id, 3503, 玩家数据[id].角色:取装备数据())
						end

						玩家数据[id].无耐久减属性 = nil
					end
				end
			end
		end
	elseif 类型 == 2 then
		for n = 1, 6 do
			特效永不磨损 = false

			if n ~= 3 and 角色数据.装备[n] ~= nil and 玩家数据[id].道具.数据[角色数据.装备[n]] ~= nil and (n ~= 4 or 玩家数据[id].道具.数据[角色数据.装备[n]].子类 ~= 911) then
				if 玩家数据[id].道具.数据[角色数据.装备[n]].星位 ~= nil then
					for i = 1, 6 do
						if 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i] ~= nil then
							if 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].耐久 == nil then
								local lv = 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].符石等级 or 3
								玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].耐久 = math.max(lv * 100, 150)
							end

							if 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].耐久 > 0 then
								玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].耐久 = 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].耐久 - 扣除耐久
							end

							if 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].耐久 <= 0 then
								if 助战编号 ~= nil then
									发送数据(玩家数据[id].连接id, 7,
										"#P(助战)#S/" ..
										玩家数据[id].助战.数据[助战编号].名称 ..
										"#Y的#r/" ..
										玩家数据[id].道具.数据[角色数据.装备[n]].名称 ..
										"#y/的#S/" .. 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].名称 .. "#y因耐久度过低已无法使用！")
								else
									发送数据(玩家数据[id].连接id, 7,
										"#y/你的#r/" ..
										玩家数据[id].道具.数据[角色数据.装备[n]].名称 ..
										"#y/的#S/" .. 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].名称 .. "#y因耐久度过低已无法使用！")
								end

								if 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].符石属性 ~= nil then
									for k, v in pairs(玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].符石属性) do
										角色数据.装备属性[k] = 角色数据.装备属性[k] - v
									end
								end

								if 玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].相互 ~= nil then
									for k, v in pairs(玩家数据[id].道具.数据[角色数据.装备[n]].星位[i].相互) do
										角色数据.装备属性[k] = 角色数据.装备属性[k] - v
									end
								end

								玩家数据[id].道具.数据[角色数据.装备[n]].星位[i] = nil

								if 助战编号 == nil then
									发送数据(玩家数据[id].连接id, 3503, 玩家数据[id].角色:取装备数据())
								end
							end
						end
					end
				end

				local 特效判断 = {}

				if 玩家数据[id].道具.数据[角色数据.装备[n]].特效 ~= nil then
					特效判断 = 列表模式转换(玩家数据[id].道具.数据[角色数据.装备[n]].特效)
				end

				if 特效判断.永不磨损 ~= nil then
					特效永不磨损 = true
				end

				if 玩家数据[id].道具.数据[角色数据.装备[n]].耐久 == nil then
					玩家数据[id].道具.数据[角色数据.装备[n]].耐久 = 500
				end

				if 特效永不磨损 == false and 玩家数据[id].道具.数据[角色数据.装备[n]].耐久 > 0 then
					if 角色数据.门派 == "大唐官府" then
						玩家数据[id].道具.数据[角色数据.装备[n]].耐久 = 玩家数据[id].道具.数据[角色数据.装备[n]].耐久 - 扣除耐久 / 2
					elseif 角色数据.门派 ~= "大唐官府" then
						玩家数据[id].道具.数据[角色数据.装备[n]].耐久 = 玩家数据[id].道具.数据[角色数据.装备[n]].耐久 - 扣除耐久
					end

					if 玩家数据[id].道具.数据[角色数据.装备[n]].耐久 <= 0 then
						玩家数据[id].道具.数据[角色数据.装备[n]].耐久 = 0
						玩家数据[id].无耐久减属性 = true

						if 助战编号 ~= nil then
							玩家数据[id].助战:卸下装备(助战编号, 玩家数据[id].道具.数据[角色数据.装备[n]])
							发送数据(玩家数据[id].连接id, 7,
								"#P(助战)#S/" ..
								玩家数据[id].助战.数据[助战编号].名称 .. "#Y的#r/" .. 玩家数据[id].道具.数据[角色数据.装备[n]].名称 .. "#y/因耐久度过低已无法使用")
						else
							玩家数据[id].角色:卸下装备(玩家数据[id].道具.数据[角色数据.装备[n]], 玩家数据[id].道具.数据[角色数据.装备[n]].分类, id)
							发送数据(玩家数据[id].连接id, 7, "#y/你的#r/" .. 玩家数据[id].道具.数据[角色数据.装备[n]].名称 .. "#y/因耐久度过低已无法使用")
							发送数据(玩家数据[id].连接id, 3503, 玩家数据[id].角色:取装备数据())
						end

						玩家数据[id].无耐久减属性 = nil
					end
				end
			end
		end

		for n = 1, 4 do
			特效永不磨损 = false

			if 角色数据.灵饰[n] ~= nil and 玩家数据[id].道具.数据[角色数据.灵饰[n]] ~= nil then
				local 特效判断 = {}

				if 玩家数据[id].道具.数据[角色数据.灵饰[n]].特效 ~= nil then
					特效判断 = 列表模式转换(玩家数据[id].道具.数据[角色数据.灵饰[n]].特效)
				end

				if 特效判断.永不磨损 ~= nil then
					特效永不磨损 = true
				end

				if 玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 == nil then
					玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 = 500
				end

				if 特效永不磨损 == false and 玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 > 0 then
					if 角色数据.门派 == "大唐官府" then
						玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 = 玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 - 扣除耐久 / 2
					elseif 角色数据.门派 ~= "大唐官府" then
						玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 = 玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 - 扣除耐久
					end

					if 玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 <= 0 then
						玩家数据[id].道具.数据[角色数据.灵饰[n]].耐久 = 0

						if 助战编号 ~= nil then
							玩家数据[id].助战:灵饰卸下(助战编号, 玩家数据[id].道具.数据[角色数据.灵饰[n]])
							发送数据(玩家数据[id].连接id, 7,
								"#P(助战)#S/" ..
								玩家数据[id].助战.数据[助战编号].名称 .. "#Y的#r/" .. 玩家数据[id].道具.数据[角色数据.灵饰[n]].名称 .. "#y/因耐久度过低已无法使用")
						else
							玩家数据[id].角色:卸下灵饰(玩家数据[id].道具.数据[角色数据.灵饰[n]])
							发送数据(玩家数据[id].连接id, 7, "#y/你的#r/" .. 玩家数据[id].道具.数据[角色数据.灵饰[n]].名称 .. "#y/因耐久度过低已无法使用")
							发送数据(玩家数据[id].连接id, 3506, 玩家数据[id].角色:取灵饰数据())
						end
					end
				end
			end
		end
	end
end

function 角色处理类:飞升技能检测(名称)
	local 技能组 = 取飞升技能(self.数据.门派)

	if #技能组 == 2 then
		if self.数据.剧情.飞升 == true and self.数据.飞升 == true then
			return true
		else
			for n = 1, #技能组 do
				if 技能组[n] == 名称 then
					return false
				end
			end
		end
	end

	return true
end

function 角色处理类:化圣技能检测(名称)
	local 技能组 = self:取化圣技能(self.数据.门派)

	if #技能组 == 2 then
		if self.数据.剧情.化圣 ~= nil and self.数据.剧情.化圣.化圣 ~= nil and self.数据.剧情.化圣.化圣 then
			return true
		else
			for n = 1, #技能组 do
				if 技能组[n] == 名称 then
					return false
				end
			end
		end
	end

	return true
end

function 角色处理类:取化圣技能(门派)
	local n = {}

	if 门派 == "大唐官府" then
		return {
			"风林火山"
		}
	elseif 门派 == "方寸山" then
		return {
			"否极泰来"
		}
	elseif 门派 == "化生寺" then
		return {
			"醍醐灌顶"
		}
	elseif 门派 == "女儿村" then
		return {
			"月下霓裳"
		}
	elseif 门派 == "阴曹地府" then
		return {
			"无间地狱"
		}
	elseif 门派 == "魔王寨" then
		return {
			"魔火焚世"
		}
	elseif 门派 == "狮驼岭" then
		return {
			"疯狂鹰击"
		}
	elseif 门派 == "盘丝洞" then
		return {
			"媚眼如丝"
		}
	elseif 门派 == "天宫" then
		return {
			"鸣雷诀"
		}
	elseif 门派 == "五庄观" then
		return {
			"同伤式"
		}
	elseif 门派 == "龙宫" then
		return {
			"龙战于野"
		}
	elseif 门派 == "普陀山" then
		return {
			"清静菩提"
		}
	elseif 门派 == "神木林" then
		return {
			"花语歌谣"
		}
	elseif 门派 == "凌波城" then
		return {
			"无双战魂"
		}
	elseif 门派 == "无底洞" then
		return {
			"净土灵华"
		}
	end

	return {}
end

取飞升技能 = function(门派)
	local n = {}

	if 门派 == "大唐官府" then
		return {
			"破釜沉舟",
			"安神诀"
		}
	elseif 门派 == "方寸山" then
		return {
			"分身术",
			"碎甲符"
		}
	elseif 门派 == "化生寺" then
		return {
			"舍身取义",
			"佛法无边"
		}
	elseif 门派 == "女儿村" then
		return {
			"一笑倾城",
			"飞花摘叶"
		}
	elseif 门派 == "阴曹地府" then
		return {
			"还阳术",
			"黄泉之息"
		}
	elseif 门派 == "魔王寨" then
		return {
			"火甲术",
			"摇头摆尾",
			"无敌牛虱"
		}
	elseif 门派 == "狮驼岭" then
		return {
			"天魔解体",
			"魔息术"
		}
	elseif 门派 == "盘丝洞" then
		return {
			"幻镜术",
			"瘴气",
			"魔音摄魂"
		}
	elseif 门派 == "天宫" then
		return {
			"雷霆万钧",
			"金刚镯"
		}
	elseif 门派 == "五庄观" then
		return {
			"天地同寿",
			"乾坤妙法"
		}
	elseif 门派 == "龙宫" then
		return {
			"二龙戏珠",
			"神龙摆尾"
		}
	elseif 门派 == "普陀山" then
		return {
			"灵动九天",
			"颠倒五行"
		}
	elseif 门派 == "神木林" then
		return {
			"蜜润",
			"血雨"
		}
	elseif 门派 == "凌波城" then
		return {
			"镇魂诀",
			"腾雷"
		}
	elseif 门派 == "无底洞" then
		return {
			"金身舍利",
			"摧心术"
		}
	elseif 门派 == "女魃墓" then
		return {
			"唤魔·毒魅",
			"唤灵·焚魂"
		}
	elseif 门派 == "天机城" then
		return {
			"攻守易位",
			"匠心·削铁"
		}
	elseif 门派 == "花果山" then
		return {
			"气慑天军",
			"威震凌霄"
		}
	elseif 门派 == "九黎城" then
		return {}
	end

	return {}
end

function 角色处理类:添加飞升技能()
	local 技能 = 取飞升技能(self.数据.门派)

	for n = 1, #技能 do
		local 技能id = self:取技能id(技能[n])
		local 技能1 = 取门派技能(self.数据.门派)

		for i = 1, #技能1 do
			if 技能1[i] == 技能id then
				技能id = i
			end
		end

		for i = 1, #self.数据.师门技能[技能id].包含技能 do
			if self.数据.师门技能[技能id].包含技能[i].名称 == 技能[n] and self.数据.师门技能[技能id].等级 >= 109 then
				self.数据.师门技能[技能id].包含技能[i].学会 = true
				self.数据.师门技能[技能id].包含技能[i].等级 = self.数据.师门技能[技能id].等级

				insert(self.数据.人物技能, table.loadstring(table.tostring(self.数据.师门技能[技能id].包含技能[i])))
				常规提示(self.数据.数字id, "恭喜你学会了新技能#R/" .. self.数据.师门技能[技能id].包含技能[i].名称)
			end
		end
	end
end

function 角色处理类:添加化圣技能()
	local 技能 = self:取化圣技能(self.数据.门派)

	for n = 1, 2 do
		local 技能id = self:取技能id(技能[n])
		local 技能1 = 取门派技能(self.数据.门派)

		for i = 1, #技能1 do
			if 技能1[i] == 技能id then
				技能id = i
			end
		end

		for i = 1, #self.数据.师门技能[技能id].包含技能 do
			if self.数据.师门技能[技能id].包含技能[i].名称 == 技能[n] and self.数据.师门技能[技能id].等级 >= 120 then
				self.数据.师门技能[技能id].包含技能[i].学会 = true
				self.数据.师门技能[技能id].包含技能[i].等级 = self.数据.师门技能[技能id].等级

				insert(self.数据.人物技能, table.loadstring(table.tostring(self.数据.师门技能[技能id].包含技能[i])))
				常规提示(self.数据.数字id, "恭喜你学会了新技能#R/" .. self.数据.师门技能[技能id].包含技能[i].名称)
			end
		end
	end
end

统御属性刷新 = function(id, 召唤兽数据, 坐骑数据, 召唤兽编号)
	if 坐骑数据.忠诚 > 0 then
		local 属性加成 = {
			体质 = 1,
			力量 = 1,
			敏捷 = 1,
			耐力 = 1,
			魔力 = 1
		}
		属性加成[五行影响[坐骑数据.五行]] = 属性加成[五行影响[坐骑数据.五行]] * 五行系数1
		召唤兽数据.统御属性.力量 = qz1(坐骑数据.力量 * 0.1 * 坐骑数据.攻击资质 / 100 * 坐骑数据.成长 * 属性加成.力量)
		召唤兽数据.统御属性.魔力 = qz1(坐骑数据.魔力 * 0.1 * 坐骑数据.法力资质 / 100 * 坐骑数据.成长 * 属性加成.魔力)
		召唤兽数据.统御属性.体质 = qz1(坐骑数据.体质 * 0.1 * 坐骑数据.体力资质 / 100 * 坐骑数据.成长 * 属性加成.体质)
		召唤兽数据.统御属性.敏捷 = qz1(坐骑数据.敏捷 * 0.1 * (坐骑数据.速度资质 + 坐骑数据.躲闪资质) / 200 * 坐骑数据.成长 * 属性加成.敏捷)
		召唤兽数据.统御属性.耐力 = qz1(坐骑数据.耐力 * 0.1 * 坐骑数据.防御资质 / 100 * 坐骑数据.成长 * 属性加成.耐力)
	else
		召唤兽数据.统御属性.力量 = 0
		召唤兽数据.统御属性.魔力 = 0
		召唤兽数据.统御属性.体质 = 0
		召唤兽数据.统御属性.敏捷 = 0
		召唤兽数据.统御属性.耐力 = 0
	end

	玩家数据[id].召唤兽:刷新信息(召唤兽编号)
end

function 角色处理类:坐骑刷新(编号)
	self.数据.坐骑列表[编号].忠诚 = self.数据.坐骑列表[编号].忠诚 or 100
	self.数据.坐骑列表[编号].最大气血 = ceil(self.数据.坐骑列表[编号].等级 * self.数据.坐骑列表[编号].体力资质 / 1000 +
		self.数据.坐骑列表[编号].体质 * self.数据.坐骑列表[编号].成长 * 6)
	self.数据.坐骑列表[编号].最大魔法 = ceil(self.数据.坐骑列表[编号].等级 * self.数据.坐骑列表[编号].法力资质 / 500 +
		self.数据.坐骑列表[编号].魔力 * self.数据.坐骑列表[编号].成长 * 3)
	self.数据.坐骑列表[编号].伤害 = ceil(self.数据.坐骑列表[编号].等级 * self.数据.坐骑列表[编号].攻击资质 * (self.数据.坐骑列表[编号].成长 + 1.4) / 750 +
		self.数据.坐骑列表[编号].力量 * self.数据.坐骑列表[编号].成长)
	self.数据.坐骑列表[编号].防御 = ceil(self.数据.坐骑列表[编号].等级 * self.数据.坐骑列表[编号].防御资质 * (self.数据.坐骑列表[编号].成长 + 1.4) / 1143 +
		self.数据.坐骑列表[编号].耐力 * (self.数据.坐骑列表[编号].成长 - 0.003952569169960474) * 253 / 190)
	self.数据.坐骑列表[编号].速度 = ceil(self.数据.坐骑列表[编号].速度资质 * self.数据.坐骑列表[编号].敏捷 / 1000)
	self.数据.坐骑列表[编号].灵力 = ceil(self.数据.坐骑列表[编号].等级 * (self.数据.坐骑列表[编号].法力资质 + 1666) / 3333 + self.数据.坐骑列表[编号].魔力 * 0.7 +
		self.数据.坐骑列表[编号].力量 * 0.4 + self.数据.坐骑列表[编号].体质 * 0.3 + self.数据.坐骑列表[编号].耐力 * 0.2)
	self.数据.坐骑列表[编号].气血 = self.数据.坐骑列表[编号].最大气血
	self.数据.坐骑列表[编号].魔法 = self.数据.坐骑列表[编号].最大魔法

	发送数据(玩家数据[self.数据.数字id].连接id, 61.1, {
		编号 = 编号,
		数据 = self.数据.坐骑列表[编号]
	})

	for i = 1, 2 do
		if self.数据.坐骑列表[编号].统御召唤兽 ~= nil and self.数据.坐骑列表[编号].统御召唤兽[i] ~= nil then
			local 召唤兽编号 = self.数据.坐骑列表[编号].统御召唤兽[i]

			if 玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号] == nil then
				self.数据.坐骑列表[编号].统御召唤兽[i] = nil

				常规提示(self.数据.数字id,
					"#Y你的坐骑#P" .. self.数据.坐骑列表[编号].名称 .. "#R(" .. 编号 .. ")#Y第#S" .. i .. "只统御召唤兽数据出错、已自动为你删除出错统御。")
			else
				玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号].统御属性 = {}

				统御属性刷新(self.数据.数字id, 玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号], self.数据.坐骑列表[编号], 召唤兽编号)
				发送数据(玩家数据[self.数据.数字id].连接id, 20, 玩家数据[self.数据.数字id].召唤兽:取存档数据(召唤兽编号))
			end
		end
	end

	if self.数据.坐骑列表[编号].参战信息 ~= nil then
		self.数据.坐骑 = table.loadstring(table.tostring(self.数据.坐骑列表[编号]))

		角色刷新信息(self.数据.数字id, self.数据)
		发送数据(玩家数据[self.数据.数字id].连接id, 10, self:取总数据())
	end

	if self.数据.坐骑列表[编号].助战参战 ~= nil then
		local 助战编号 = self.数据.坐骑列表[编号].助战参战

		if 玩家数据[self.数据.数字id].助战.数据[助战编号] == nil then
			self.数据.坐骑列表[编号].助战参战 = nil
		else
			角色刷新信息(self.数据.数字id, 玩家数据[self.数据.数字id].助战.数据[助战编号])
			发送数据(玩家数据[self.数据.数字id].连接id, 100, {
				编号 = 助战编号,
				数据 = 玩家数据[self.数据.数字id].助战:取指定数据(助战编号)
			})
		end
	end
end

function 角色处理类:坐骑升级(编号)
	self.数据.坐骑列表[编号].等级 = self.数据.坐骑列表[编号].等级 + 1

	if self.数据.坐骑列表[编号].等级 % 6 == 0 then
		self.数据.坐骑列表[编号].技能点 = self.数据.坐骑列表[编号].技能点 + 1
	end

	self.数据.坐骑列表[编号].体质 = self.数据.坐骑列表[编号].体质 + 1
	self.数据.坐骑列表[编号].魔力 = self.数据.坐骑列表[编号].魔力 + 1
	self.数据.坐骑列表[编号].力量 = self.数据.坐骑列表[编号].力量 + 1
	self.数据.坐骑列表[编号].耐力 = self.数据.坐骑列表[编号].耐力 + 1
	self.数据.坐骑列表[编号].敏捷 = self.数据.坐骑列表[编号].敏捷 + 1
	self.数据.坐骑列表[编号].潜力 = self.数据.坐骑列表[编号].潜力 + 服务端参数.坐骑升级潜能点
	self.数据.坐骑列表[编号].当前经验 = self.数据.坐骑列表[编号].当前经验 - self.数据.坐骑列表[编号].最大经验

	self:坐骑刷新(编号)
end

function 角色处理类:坐骑洗点(编号)
	self.数据.坐骑列表[编号].潜力 = (self.数据.坐骑列表[编号].等级 + 1) * 服务端参数.坐骑升级潜能点
	self.数据.坐骑列表[编号].体质 = 20 + self.数据.坐骑列表[编号].等级
	self.数据.坐骑列表[编号].魔力 = 20 + self.数据.坐骑列表[编号].等级
	self.数据.坐骑列表[编号].力量 = 20 + self.数据.坐骑列表[编号].等级
	self.数据.坐骑列表[编号].耐力 = 20 + self.数据.坐骑列表[编号].等级
	self.数据.坐骑列表[编号].敏捷 = 20 + self.数据.坐骑列表[编号].等级
	self.数据.坐骑列表[编号].技能点 = math.floor(self.数据.坐骑列表[编号].等级 / 6)
	local jn = self.数据.坐骑列表[编号].技能
	local dj = self.数据.坐骑列表[编号].技能等级
	local jn1 = {}
	local 特殊1 = {
		"雷击",
		"落岩",
		"水攻",
		"烈火"
	}
	local 特殊2 = {
		奔雷咒 = 1,
		地狱烈火 = 4,
		水漫金山 = 3,
		泰山压顶 = 2
	}

	for i = 1, #jn do
		if dj[i] ~= nil and dj[i] == 3 then
			if jn[i] ~= "高级法术抵抗" and string.find(jn[i], "高级") then
				jn1[#jn1 + 1] = string.gsub(jn[i], "高级", "")
			elseif 特殊2[jn[i]] ~= nil then
				jn1[#jn1 + 1] = 特殊1[特殊2[jn[i]]]
			else
				jn1[#jn1 + 1] = jn[i] .. "【伪】"
			end
		else
			jn1[#jn1 + 1] = jn[i]
		end
	end

	self.数据.坐骑列表[编号].技能等级 = {}
	self.数据.坐骑列表[编号].技能 = jn1

	self:坐骑刷新(编号)
end

function 角色处理类:坐骑加点(编号, 加点内容)
	local 总点数 = 0
	local 检测是否合格 = true

	for k, v in pairs(加点内容) do
		if v < 0 then
			检测是否合格 = false
		end

		总点数 = 总点数 + v
	end

	if 检测是否合格 then
		if 总点数 <= 0 then
			return
		elseif self.数据.坐骑列表[编号].潜力 < 总点数 then
			return
		else
			self.数据.坐骑列表[编号].体质 = self.数据.坐骑列表[编号].体质 + 加点内容.体质
			self.数据.坐骑列表[编号].魔力 = self.数据.坐骑列表[编号].魔力 + 加点内容.魔力
			self.数据.坐骑列表[编号].力量 = self.数据.坐骑列表[编号].力量 + 加点内容.力量
			self.数据.坐骑列表[编号].耐力 = self.数据.坐骑列表[编号].耐力 + 加点内容.耐力
			self.数据.坐骑列表[编号].敏捷 = self.数据.坐骑列表[编号].敏捷 + 加点内容.敏捷
			self.数据.坐骑列表[编号].潜力 = self.数据.坐骑列表[编号].潜力 - 总点数

			self:坐骑刷新(编号)
		end
	end
end

function 角色处理类:坐骑喂养1(数额)
	local 基础倍率 = 服务端参数.经验获得率
	local 倍率 = 1

	if self:取任务(2) ~= 0 then
		倍率 = 倍率 + 1
	end

	if self:取任务(3) ~= 0 then
		倍率 = 倍率 + 1
	end

	if 服务端参数.倍率模式 == 1 then
		if self:取任务(7756) ~= 0 then
			倍率 = 倍率 * 2
		end

		if self:取任务(7755) ~= 0 then
			倍率 = 倍率 * 3
		end

		if self:取任务(7757) ~= 0 then
			倍率 = 倍率 * 10
		end
	else
		if self:取任务(7756) ~= 0 then
			倍率 = 倍率 + 1
		end

		if self:取任务(7755) ~= 0 then
			倍率 = 倍率 + 2
		end

		if self:取任务(7757) ~= 0 then
			倍率 = 倍率 + 9
		end
	end

	local 数额1 = math.floor(qz(数额 * 倍率 * 基础倍率))
	local 助战坐骑 = {}

	if 队伍数据[玩家数据[self.数据.数字id].队伍] ~= nil and 队伍数据[玩家数据[self.数据.数字id].队伍].成员数据[1] == self.数据.数字id then
		local id = self.数据.数字id

		for i = 2, 5 do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, i) ~= 0 then
				local 助战编号 = 队伍处理类:取助战编号(玩家数据[id].队伍, i)
				助战坐骑[助战编号] = 1
			end
		end
	end

	local 坐骑数据 = self.数据.坐骑列表

	for i = 1, #坐骑数据 do
		if 坐骑数据[i].参战信息 ~= nil or 助战坐骑[坐骑数据[i].助战参战] ~= nil then
			if 坐骑数据[i].等级 == 175 then
				break
			else
				坐骑数据[i].当前经验 = 坐骑数据[i].当前经验 + 数额1
			end

			while 坐骑数据[i].最大经验 <= 坐骑数据[i].当前经验 do
				if self.数据.等级 <= 坐骑数据[i].等级 then
					break
				end

				self:坐骑升级(i)

				if 坐骑数据[i].等级 <= 175 then
					坐骑数据[i].最大经验 = 统一取经验(1, 坐骑数据[i].等级)
				end

				发送数据(玩家数据[self.数据.数字id].连接id, 27, {
					频道 = "xt",
					文本 = "#W/你的坐骑#R/" .. 坐骑数据[i].名称 .. "#W/等级提升到了#R/" .. 坐骑数据[i].等级 .. "#W/级"
				})
			end
		end
	end
end

function 角色处理类:坐骑喂养(编号, 数额)
	self.数据.坐骑列表[编号].当前经验 = self.数据.坐骑列表[编号].当前经验 + 数额

	while self.数据.坐骑列表[编号].最大经验 <= self.数据.坐骑列表[编号].当前经验 do
		if self.数据.等级 <= self.数据.坐骑列表[编号].等级 then
			break
		end

		self:坐骑升级(编号)

		if self.数据.坐骑列表[编号].等级 <= 175 then
			self.数据.坐骑列表[编号].最大经验 = 统一取经验(1, self.数据.坐骑列表[编号].等级)
		end

		发送数据(玩家数据[self.数据.数字id].连接id, 27, {
			频道 = "xt",
			文本 = "#W/你的坐骑#R/" .. self.数据.坐骑列表[编号].名称 .. "#W/等级提升到了#R/" .. self.数据.坐骑列表[编号].等级 .. "#W/级"
		})
	end
end

function 角色处理类:坐骑放生(编号)
	if self.数据.坐骑列表[编号].统御召唤兽 ~= nil and (self.数据.坐骑列表[编号].统御召唤兽[1] ~= nil or self.数据.坐骑列表[编号].统御召唤兽[2] ~= nil) then
		常规提示(self.数据.数字id, "#Y该坐骑尚有统御的召唤兽未消除")

		return
	elseif self.数据.坐骑列表[编号].饰品 ~= nil or self.数据.坐骑列表[编号].饰品物件 ~= nil then
		常规提示(self.数据.数字id, "#Y请卸下该坐骑的饰品")

		return
	elseif self.数据.坐骑 ~= nil and self.数据.坐骑.认证码 == self.数据.坐骑列表[编号].认证码 then
		常规提示(self.数据.数字id, "#Y该坐骑正在骑乘中,请解除骑乘状态后再进行此操作！")

		return
	elseif self.数据.坐骑列表[编号].助战参战 ~= nil then
		常规提示(self.数据.数字id, "#Y该坐骑正在被#P助战[" .. self.数据.坐骑列表[编号].助战参战 .. "]#Y骑乘中,请解除骑乘状态后再进行此操作！")

		return
	else
		if self.数据.坐骑列表[编号] == nil then
			return
		end

		for i = 编号, #self.数据.坐骑列表 do
			if 编号 < i and self.数据.坐骑列表[i].统御召唤兽 ~= nil then
				local 删除统御 = {}

				for n = 1, #self.数据.坐骑列表[i].统御召唤兽 do
					local 召唤兽编号 = self.数据.坐骑列表[i].统御召唤兽[n]

					if 玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号] ~= nil and 玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号].统御 == i then
						玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号].统御 = i - 1
					else
						玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号].统御 = nil
						删除统御[#删除统御 + 1] = i
					end
				end

				for w = 1, #删除统御 do
					if 删除统御[w] - (w - 1) > 0 then
						table.remove(self.数据.坐骑列表[i].统御召唤兽, 删除统御[w] - (w - 1))
					end
				end
			elseif i == 编号 and self.数据.坐骑列表[i].统御召唤兽 ~= nil then
				for n = 1, #self.数据.坐骑列表[i].统御召唤兽 do
					local 召唤兽编号 = self.数据.坐骑列表[i].统御召唤兽[n]

					if 玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号] ~= nil then
						玩家数据[self.数据.数字id].召唤兽.数据[召唤兽编号].统御 = nil
					end
				end
			end
		end

		table.remove(self.数据.坐骑列表, 编号)
		发送数据(玩家数据[self.数据.数字id].连接id, 61, 玩家数据[self.数据.数字id].角色.数据.坐骑列表)
	end
end

刷新体活 = function(id)
	if 玩家数据[id] ~= nil and 玩家数据[id].角色.数据 ~= nil then
		发送数据(玩家数据[id].连接id, 15, {
			体力 = 玩家数据[id].角色.数据.体力 or 0,
			活力 = 玩家数据[id].角色.数据.活力 or 0
		})
	end
end

function 角色处理类:扣除体力(数额, 说明, 提示)
	数额 = 数额 + 0

	if 数额 <= self.数据.体力 then
		self.数据.体力 = self.数据.体力 - 数额

		if 提示 ~= nil then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "点体力")
		end

		刷新体活(self.数据.数字id)

		return true
	else
		return false
	end
end

function 角色处理类:扣除活力(数额, 说明, 提示)
	数额 = 数额 + 0

	if 数额 <= self.数据.活力 then
		self.数据.活力 = self.数据.活力 - 数额

		if 提示 ~= nil then
			常规提示(self.数据.数字id, "你失去了" .. 数额 .. "点活力")
		end

		刷新体活(self.数据.数字id)

		return true
	else
		return false
	end
end

function 角色处理类:取玩家装备信息(id, 对方id)
	if 玩家数据[id].摊位数据 ~= nil then
		常规提示(id, "#Y摆摊情况下无法进行此操作")

		return
	end

	self.发送信息 = {
		名称 = 玩家数据[对方id].角色.数据.名称,
		模型 = 玩家数据[对方id].角色.数据.模型,
		等级 = 玩家数据[对方id].角色.数据.等级,
		锦衣特效 = 玩家数据[对方id].角色.数据.穿戴锦衣,
		变身数据 = 玩家数据[对方id].角色.数据.变身数据,
		锦衣 = {
			{
				名称 = 玩家数据[对方id].角色.数据.穿戴锦衣
			},
			{
				名称 = 玩家数据[对方id].角色.数据.穿戴足迹
			},
			[4] = {
				名称 = 玩家数据[对方id].角色.数据.穿戴翅膀,
				[3] = {
					名称 = 玩家数据[对方id].角色.数据.穿戴足印
				}
			}
		},
		装备 = {}
	}

	for n = 1, 6 do
		if 玩家数据[对方id].角色.数据.装备[n] ~= nil then
			self.发送信息.装备[n] = table.loadstring(table.tostring(玩家数据[对方id].道具.数据[玩家数据[对方id].角色.数据.装备[n]]))
		end
	end

	发送数据(玩家数据[id].连接id, 146, self.发送信息)
end

return 角色处理类
