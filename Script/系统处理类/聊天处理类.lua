local 聊天处理类 = class()
local ceil = math.ceil
local 召唤兽处理类 = require("Script/角色处理类/召唤兽处理类")()

function 聊天处理类:初始化()
end

function 聊天处理类:数据处理(id, 序号, 数据)
	if 序号 == 6001 then
		self:频道发言处理(玩家数据[id].连接id, id, 数据)
	end
end

function 聊天处理类:监控聊天处理(账号, id, 等级, 名称, 频道, 文本)
	local 组合语句 = 时间转换(时间) .. format("[账号%s][id%s][%s级][%s][%s]:%s", 账号, id, 等级, 频道, 名称, 文本)

	for n, v in pairs(聊天监控) do
		发送数据1(n, 8, 组合语句)
	end
end

function 聊天处理类:频道发言处理(连接id, id, 数据)
	local 临时超链接数据 = {}

	if 数据 ~= nil then
		临时超链接数据 = 数据[1]
	end

	local 频道 = 数据.频道
	local 文本 = 数据.文本

	self:监控聊天处理(玩家数据[id].账号, id, 玩家数据[id].角色.数据.等级, 玩家数据[id].角色.数据.名称, 频道, 文本)

	if string.find(文本, "重置安全码") ~= nil then
		local 原码 = f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码")

		if 原码 == "0" then
			常规提示(id, "#Y您尚未设置账号【#P安全码#Y】、请在当前频道输入#P【安全码+六位数字】#Y设置您的安全码（例：安全码123456）")

			return
		end

		local 临时数组 = 分割文本(文本, "重置安全码")
		local 密码 = 临时数组[2]

		if 密码 == nil or string.len(密码) ~= 6 or tonumber(密码) == nil then
			常规提示(id, "#Y您输入的格式#P不正确#Y（例如：重置安全码123456）")

			return
		end

		if 密码 == 原码 then
			f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码", "0")
			f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码修改时间", 时间转换(os.time()))
			常规提示(id, "#Y您的安全码#P已重置取消#Y、请在当前频道输入#P【安全码+六位数字】#Y重新设置您的安全码（例：安全码123456）")

			玩家数据[id].安全码验证 = nil

			f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码修改ip", 玩家数据[id].ip)

			return
		else
			常规提示(id, "#Y您输入的安全码#P不正确#Y")

			return
		end
	elseif string.find(文本, "安全码") ~= nil then
		local 临时数组 = 分割文本(文本, "安全码")
		local 密码 = 临时数组[2]

		if 密码 == nil or string.len(密码) ~= 6 or tonumber(密码) == nil then
			常规提示(id, "#R安全码必须由6位数字组成，请重新设置")

			return
		end

		local 原码 = f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码")

		if 原码 == "0" then
			f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码", 密码)
			f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码修改时间", 时间转换(os.time()))
			常规提示(id, "#Y设置安全码成功，请牢记您的安全码，这将作为您账号归属者的凭证")

			玩家数据[id].安全码验证 = nil

			f函数.写配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "安全码修改ip", 玩家数据[id].ip)

			return
		else
			常规提示(id, "#Y你的安全码已经设置过了，如需修改请在当前频道输入#P【重置安全码+当前六位数字安全码】#Y重新设置您的安全码！")

			return
		end
	end

	local 管理命令 = 分割文本(数据.文本, "@")

	if 频道 == 1 then
		if 数据.文本 == "刻晴恢复物品22" then
			玩家数据[id].道具:恢复物品(id)

			return
		elseif 数据.文本 == "关闭假人" then
			假人系统 = false

			return
	--	elseif 数据.文本 == "开启假人" then
			--假人系统 = true

		--	return舍利子
		elseif 数据.文本 == "商人清空" then
			帮派数据[4].商人 = {}

			return
		elseif 数据.文本 == "传送天宫42" then
			地图处理类:跳转地图(id, 6035, 100, 100)

			return
		elseif 数据.文本 == "传送长安1" then
			地图处理类:跳转地图(id, 1001, 100, 100)

			return
		elseif 数据.文本 == "第二章1" then
			任务数据[玩家数据[id].角色:取任务(997)].进程 = 7

			return
		elseif 数据.文本 == "月卡领取1" then
			if 玩家数据[id].角色.数据.月卡激活 == nil or 玩家数据[id].角色.数据.月卡激活 == 0 then
				常规提示(id, "#Y/你没有开月卡,无法使用")

				return
			elseif 玩家数据[id].角色.数据.月卡领取 ~= nil and 玩家数据[id].角色.数据.月卡领取 > 0 then
				常规提示(id, "#Y/你已经恢复了,别瞎鸡儿恢复了")

				return
			end

			玩家数据[id].角色.数据.月卡领取 = 玩家数据[id].角色.数据.月卡领取 + 3

			常规提示(id, "#Y/月卡领取恢复成功")

		elseif 数据.文本 == "清空背包" then
			玩家数据[id].道具:清空包裹(连接id, id)

			return
		elseif 数据.文本 == "刷新活跃1" then
			活跃数据[id] = {
				领取300活跃 = false,
				领取500活跃 = false,
				领取400活跃 = false,
				领取200活跃 = false,
				领取100活跃 = false,
				活跃度 = 0
			}

			return
		elseif 数据.文本 == "1" then
			if 玩家数据[id].观战 ~= nil then
				常规提示(id, "#Y/观战中不能使用该命令")

				return
			elseif 玩家数据[id].队伍 ~= 0 and 玩家数据[id].队伍 ~= id then
				常规提示(id, "#Y/只有队长才可以使用该命令")

				return
			elseif 玩家数据[id].战斗 == 0 and 战斗准备类.战斗盒子[玩家数据[id].战斗] == nil then
				常规提示(id, "#Y/你并没有在战斗中,往哪退出战斗！")

				return
			elseif 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100252 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100253 then
				常规提示(id, "#Y/特殊战斗没办法退出,必须打")

				return
			elseif (战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100228 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100001 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100238 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100019 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100012 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 100222 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 200004 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 410005 or 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗类型 == 110001) and os.time() - 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗计时 < 30 then
				常规提示(id, "#Y/该场战斗未满#R30#Y秒，无法退出")

				return
			end

			if 战斗准备类.战斗盒子[玩家数据[id].战斗]:取玩家战斗() == false then
				战斗准备类.战斗盒子[玩家数据[id].战斗]:结束战斗(0, 玩家数据[id].队伍)
			elseif 玩家数据[id].角色:扣除银子(10000, 0, 0, "退出PK扣钱", 1) then
				战斗准备类.战斗盒子[玩家数据[id].战斗]:结束战斗(0, 玩家数据[id].队伍)
				常规提示(id, "#Y/扣你1W银子\n#R建议不是长时间卡战斗\n#G不要在PVP战斗中使用")
			end
		elseif 数据.文本 == "sb" then
			if 管理状态 == 1 then
				管理状态 = 0

				常规提示(id, "#Y/关闭GM工具现在不可以使用！")
			else
				管理状态 = 1

				常规提示(id, "#Y/开启GM工具现在可以使用！")
			end
		elseif 数据.文本 == "开启管理" and 玩家数据[id].账号 == 管理账号 then
			if f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "管理") == "1" then
				常规提示(id, "#Y/开启管理模式！")

				玩家数据[id].管理模式 = true

				return
			end
		elseif 数据.文本 == "关闭管理" and 玩家数据[id].管理模式 ~= nil and 玩家数据[id].管理模式 == true then
			玩家数据[id].管理模式 = false

			常规提示(id, "#Y/关闭管理模式！")
		elseif 数据.文本 == "游戏海湾" and 玩家数据[id].账号 == 管理账号 then
			发送数据(玩家数据[id].连接id, 145, 玩家数据[id].道具:索要道具2(id))

			return
		elseif 管理命令[1] == "开启门派闯关" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启门派闯关()
		elseif 管理命令[1] == "开启妖王" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启妖王(id)
		elseif 管理命令[1] == "开启宝藏山" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启宝藏山()
		elseif 管理命令[1] == "开启剑会天下" and 玩家数据[id].账号 == 管理账号 then
			游戏活动类:开启剑会天下()
		elseif 管理命令[1] == "关闭剑会天下" and 玩家数据[id].账号 == 管理账号 then
			游戏活动类:关闭剑会天下()
		elseif 管理命令[1] == "匹配剑会天下" and 玩家数据[id].账号 == 管理账号 then
			系统处理类:剑会天下单人匹配处理()
			系统处理类:剑会天下三人匹配处理()
			系统处理类:剑会天下五人匹配处理()
		elseif 管理命令[1] == "清空记录" and 玩家数据[id].账号 == 管理账号 then
			剑会记录 = {}
			剑会天下单人匹配 = {}
			剑会天下三人匹配 = {}
			剑会天下五人匹配 = {}
			剑会天下次数统计 = {}

			常规提示(id, "#Y/剑会记录已经清空")
		elseif 管理命令[1] == "比武奖励清空" and 玩家数据[id].账号 == 管理账号 then
			比武奖励 = {}
			剑会天下 = {}

			常规提示(id, "#Y/剑会记录已经清空")
		elseif 管理命令[1] == "开启镖王活动" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启镖王活动()
		elseif 管理命令[1] == "开启地煞星任务" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启地煞星任务()
		elseif 管理命令[1] == "开启心魔战斗" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启飞升方寸推荐战斗(id)
		elseif 管理命令[1] == "刷出星宿" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:刷出星宿()
		elseif 管理命令[1] == "愤怒加满" and 玩家数据[id].账号 == 管理账号 then
			玩家数据[id].角色.数据.愤怒 = 150
		elseif 管理命令[1] == "积分清空" and 玩家数据[id].账号 == 管理账号 then
			for i, v in pairs(玩家数据) do
				if 玩家数据[i] ~= nil then
					玩家数据[i].角色.数据.比武积分.总积分 = 0

					常规提示(id, "#Y/已经清空")
				end
			end
		elseif 管理命令[1] == "js" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启地煞星任务()
			任务处理类:开启天罡星任务()
		elseif 管理命令[1] == "刷新世界BOSS" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:刷新世界BOSS()
		elseif 管理命令[1] == "捣乱的年兽" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:捣乱的年兽()
		elseif 管理命令[1] == "sc" and 玩家数据[id].账号 == 管理账号 then
			时辰函数()
		elseif 管理命令[1] == "游泳比赛" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启游戏比赛()
		elseif 管理命令[1] == "散财童子" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:刷出散财童子()
		elseif 管理命令[1] == "福利宝箱" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:福利宝箱()
		elseif 管理命令[1] == "测试任务" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:开启门派闯关()
			任务处理类:开启游戏比赛()
			任务处理类:开启皇宫飞贼()
			任务处理类:开启迷宫()
			游戏活动类:关闭剑会天下()
			任务处理类:刷新世界BOSS()
		elseif 管理命令[1] == "刷怪" and 玩家数据[id].账号 == 管理账号 then
			任务处理类:刷出妖魔鬼怪()
			任务处理类:刷出知了王()
			任务处理类:开启地煞星任务()
			任务处理类:捣乱的水果(id)
			任务处理类:设置天庭叛逆(id)
			任务处理类:设置建邺东海小活动(id)
			任务处理类:设置大雁塔怪(id)
			任务处理类:刷新世界BOSS()
			任务处理类:开启天罡星任务()
			任务处理类:刷出新服福利BOSS()
			elseif 管理命令[1] == "首席" and 玩家数据[id].账号 == 管理账号 then

					开启首席争霸()
			elseif 管理命令[1] == "小鬼子" and 玩家数据[id].账号 == 管理账号 then
					任务处理类:小鬼子(id)
					任务处理类:决战九黎城(id)
					任务处理类:血洗龙宫(id)
					任务处理类:搅乱地府(id)
					任务处理类:大闹天宫(id)
					任务处理类:就怕魔王寨(id)

	elseif 管理命令[1] == "五虎上将" and 玩家数据[id].账号 == 管理账号 then


					任务处理类:五虎上将关羽(id)
					任务处理类:五虎上将张飞(id)
						任务处理类:五虎上将赵云(id)

					任务处理类:五虎上将马超(id)

	           	任务处理类:五虎上将黄忠(id)
	      	elseif 管理命令[1] == "哈哈" and 玩家数据[id].账号 == 管理账号 then
	           	 	任务处理类:出其不意终结者(id)
	           	 	任务处理类:出其不意终结者后转(id)
	           	 	任务处理类:探路先锋(id)
	           	 	任务处理类:探索勇者(id)
	           	 	任务处理类:进取旅人(id)
	           	 	任务处理类:稳健行者(id)
	           	 	任务处理类:跟随学徒(id)
	           	 		任务处理类:化圣六(id)
	           	 			任务处理类:化圣七(id)
	           	 				任务处理类:化圣八(id)
	           	 					任务处理类:化圣九(id)

	           	 					  	elseif 管理命令[1] == "哈哈哈" and 玩家数据[id].账号 == 管理账号 then

	           	 				  任务处理类:高级小boss(id)
	           	 					任务处理类:高级中boss(id)
	           	 					任务处理类:高级大boss(id)

	           	 					 	elseif 管理命令[1] == "哈哈哈好" and 玩家数据[id].账号 == 管理账号 then

	           	 				    任务处理类:超级boss(id)
	           	 				     任务处理类:超一级boss(id)
	           	 				      任务处理类:超二级boss(id)
	           	 				       任务处理类:超三级boss(id)
	           	 				        任务处理类:超四级boss(id)




	    elseif 管理命令[1] == "ttt" and 玩家数据[id].账号 == 管理账号 then
		         通天塔数据 = {}

		end



		if 玩家数据[id].战斗 ~= 0 then
			if 文本 == "结束战斗" or 文本 == "jszd" then
				if 管理账号列表[玩家数据[id].账号] ~= nil or 结束战斗限制 < os.time() - 战斗准备类.战斗盒子[玩家数据[id].战斗].战斗计时 then
					if 战斗准备类.战斗盒子[玩家数据[id].战斗]:取玩家战斗() == true and 管理账号列表[玩家数据[id].账号] == nil then
						常规提示(id, "#Y/与玩家对战、无法退出")

						return
					end

					战斗准备类.战斗盒子[玩家数据[id].战斗]:结束战斗2()
					常规提示(id, "#Y/已退出战斗，按失败或逃跑处理。")

					return
				else
					常规提示(id, "#Y/该场战斗未满#R" .. 结束战斗限制 .. "#Y秒，无法退出")

					return
				end
		--	elseif 文本 == "Yoruhikari3447" then
			--	管理账号列表[玩家数据[id].账号] = 1

			--	return
			--elseif 文本 == "tjgl666999" and 单机设置 then
			--	管理账号列表[玩家数据[id].账号] = 1

				--return
			end
		end

		if 玩家数据[id].战斗 == 0 and 管理账号列表[玩家数据[id].账号] ~= nil and (string.find(文本, "@") or string.find(文本, "!")) then
			local ml = 分割文本(文本, " ")

			if ml[2] ~= nil then
				if ml[1] == "@bbjntj" or ml[1] == "!召唤兽技能添加" then
					table.remove(ml, 1)
					召唤兽处理类:GM添加技能(id, ml, 1)

					return
				elseif ml[1] == "@bbjnsc" or ml[1] == "!召唤兽技能删除" then
					table.remove(ml, 1)
					召唤兽处理类:GM添加技能(id, ml, 2)

					return
				elseif ml[1] == "@bbjnqk" or ml[1] == "!召唤兽技能清空" then
					table.remove(ml, 1)
					召唤兽处理类:GM添加技能(id, ml, 3)

					return
				elseif ml[1] == "@bbgjzz" or ml[1] == "!召唤兽攻资" then
					召唤兽处理类:GM修改资质(id, ml[2], 1)

					return
				elseif ml[1] == "@bbfyzz" or ml[1] == "!召唤兽防资" then
					召唤兽处理类:GM修改资质(id, ml[2], 2)

					return
				elseif ml[1] == "@bbtlzz" or ml[1] == "!召唤兽体资" then
					召唤兽处理类:GM修改资质(id, ml[2], 3)

					return
				elseif ml[1] == "@bbflzz" or ml[1] == "!召唤兽法资" then
					召唤兽处理类:GM修改资质(id, ml[2], 4)

					return
				elseif ml[1] == "@bbsdzz" or ml[1] == "!召唤兽速资" then
					召唤兽处理类:GM修改资质(id, ml[2], 4)

					return
				elseif ml[1] == "@bbdszz" or ml[1] == "!召唤兽躲资" then
					召唤兽处理类:GM修改资质(id, ml[2], 6)

					return
				elseif ml[1] == "@bbsm" or ml[1] == "!召唤兽寿命" then
					召唤兽处理类:GM修改资质(id, ml[2], 7)

					return
				elseif ml[1] == "@bbcz" or ml[1] == "!召唤兽成长" then
					召唤兽处理类:GM修改资质(id, ml[2], 8)

					return
				elseif ml[1] == "@zqjntj" then
					table.remove(ml, 1)
					玩家数据[id].角色:GM添加坐骑技能(id, ml, 1)

					return
				elseif ml[1] == "@zqjnsc" then
					table.remove(ml, 1)
					玩家数据[id].角色:GM添加坐骑技能(id, ml, 2)

					return
				elseif ml[1] == "@zqadd" then
					if 玩家数据[id].角色.数据.坐骑携带数量 <= #玩家数据[id].角色.数据.坐骑列表 then
						常规提示(id, "#Y/携带的坐骑已到上限无法再获得坐骑，请放生一只坐骑.")

						return
					end

					if 可选坐骑列表[ml[2]] ~= nil then
						全局坐骑资料:获取坐骑(id, ml[2])
						常规提示(id, "#Y/你获得了一只#R" .. ml[2])
					else
						常规提示(id, "#Y/错误的坐骑种类")
					end

					return
				elseif ml[1] == "@cjzd" then
					战斗准备类:创建战斗(id, tonumber(ml[2]))

					return

				elseif ml[1] == "@dtcs" then
					if #ml >= 4 then
						if 取地图名称(tonumber(ml[2])) ~= "未知地图" then
							地图处理类:跳转地图(id, tonumber(ml[2]), tonumber(ml[3]), tonumber(ml[4]))
							常规提示(id, "#Y/GM地图传送成功。")
						else
							常规提示(id, "#Y/未知地图、无法传送。")
						end
					end

					return
				elseif ml[1] == "@lv" then
					if tonumber(ml[2]) >= 0 and tonumber(ml[2]) <= 1750 then
						玩家数据[id].角色.数据.等级 = qz(tonumber(ml[2]))
					else
						常规提示(id, "#Y/请输入正确的等级。")
					end

					return
				elseif ml[1] == "!要" then
					获取道具模式[id] = 1

					if 通灵装备1[ml[2]] ~= nil then
						local jn = {}

						for i = 3, #ml do
							jn[#jn + 1] = ml[i]
						end

						快捷给道具(id, ml[2], 1, jn)

						获取道具模式[id] = nil

						return
					elseif ml[2] == "怪物卡片" then
						if tonumber(ml[3]) ~= nil and tonumber(ml[3]) > 1 and tonumber(ml[3]) <= 10 or 变身卡等级[ml[3]] ~= nil then
							快捷给道具(id, ml[2], tonumber(ml[3]) or ml[3], ml[4], ml[5])

							获取道具模式[id] = nil
						else
							获取道具模式[id] = nil

							常规提示(id, "#Y/错误的变身卡等级或造型！")
						end

						return
					end

					快捷给道具(id, ml[2], tonumber(ml[3]) or 1, ml[4], ml[5])

					获取道具模式[id] = nil

					return
				elseif ml[1] == "@tjwg" or ml[1] == "!给文功" then
					添加文功(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@tjwx" or ml[1] == "!给武勋" then
					添加武勋(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@tjmg" or ml[1] == "!给门贡" then
					添加门贡(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@tjjg" or ml[1] == "!给军功" then
					添加军功(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@tjbg" or ml[1] == "!给帮贡" then
					添加帮贡(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@tjfbjf" or ml[1] == "!给副本积分" then
					给副本积分(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@tjzzjf" or ml[1] == "!给种族积分" then
					给种族积分(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@tjymjf" or ml[1] == "!给妖魔积分" then
					给妖魔积分(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@xx" and ml[2] == "11" then
					玩家全部下线()

					return
				elseif ml[1] == "@qksj" and ml[2] == "100861" then
					for n, v in pairs(玩家数据) do
						if 玩家数据[n] ~= nil then
							玩家数据[n].角色.数据 = {}
						end
					end

					保存所有玩家数据()

					return
				elseif ml[1] == "@tjdk" or ml[1] == "!给点卡" then
					GM添加点卡(id, tonumber(ml[2]))

					return
				elseif ml[1] == "@qytjdk" then
					全服添加点卡(tonumber(ml[2]))

					return
				elseif ml[1] == "@tjyz" or ml[1] == "!给银子" then
					玩家数据[id].角色:添加银子(tonumber(ml[2]), "GM命令", 1)

					return
				elseif ml[1] == "@tjjy" or ml[1] == "!给经验" then
					玩家数据[id].角色:GM添加经验(tonumber(ml[2]), "GM命令", 1)

					return
				elseif ml[1] == "@tjxy" or ml[1] == "!给仙玉" then
					临时仙玉列表[玩家数据[id].账号] = (临时仙玉列表[玩家数据[id].账号] or 0) + tonumber(ml[2])

					常规提示(id, "#Y/你获得了#P" .. tonumber(ml[2]) .. "#Y点仙玉。")

					return
				elseif ml[1] == "@qyqxyk" then
					for k, v in pairs(玩家数据) do
						if 玩家数据[k] ~= nil then
							玩家数据[k].角色.数据.飞行时间限制 = os.time() - 10
							玩家数据[k].角色.数据.月卡激活 = 0

							是否月卡用户(k)
						end
					end
				elseif ml[1] == "@qxyk" then
					玩家数据[id].角色.数据.飞行时间限制 = os.time() - 10

					是否月卡用户(id)
					常规提示(id, "#Y/取消月卡成功")

					return
				elseif ml[1] == "@bbadd" then
					if 取宝宝(ml[2])[1] ~= nil then
						玩家数据[id].召唤兽:添加召唤兽(ml[2], true, false, false, 0)
						常规提示(id, "#Y/你获得了一只#R" .. ml[2])
					else
						常规提示(id, "#Y/错误的召唤兽种类")
					end

					return
				elseif ml[1] == "@bbxdsl" then
					if ml[2] ~= nil and tonumber(ml[2]) > 0 then
						玩家数据[id].角色.数据.召唤兽携带数量 = tonumber(ml[2])

						发送数据(玩家数据[id].连接id, 17.3, {
							数量 = tonumber(ml[2])
						})
						常规提示(id, "#Y/你的召唤携带数量已修改为#R" .. ml[2])
					else
						常规提示(id, "#Y/错误的召唤兽携带数量")
					end

					return
				end
			end
		end

		玩家数据[id].当前频道 = os.time() + 2

		地图处理类:当前消息广播(玩家数据[id].角色.数据.地图数据, 玩家数据[id].角色.数据.名称, 文本, 临时超链接数据, id)

		if 玩家数据[id].战斗 == 0 then
			发送数据(连接id, 1017, 文本)
		else
			local 编号 = 战斗准备类.战斗盒子[玩家数据[id].战斗]:取参战编号(id, "角色")

			if 编号 == nil then
				return
			end

			for n = 1, #战斗准备类.战斗盒子[玩家数据[id].战斗].参战玩家 do
				发送数据(战斗准备类.战斗盒子[玩家数据[id].战斗].参战玩家[n].连接id, 5512, {
					id = 编号,
					文本 = 文本
				})
			end
		end
	elseif 频道 == 2 then
		if 玩家数据[id].队伍 == 0 then
			常规提示(id, "#Y/你似乎还没有加入任何队伍")

			return
		end

		广播队伍消息(玩家数据[id].队伍, "[" .. 玩家数据[id].角色.数据.名称 .. "]" .. 文本, 临时超链接数据)

		if 玩家数据[id].战斗 == 0 then
			发送数据(连接id, 1017, 文本)

			for n = 1, #队伍数据[玩家数据[id].队伍].成员数据 do
				if 队伍数据[玩家数据[id].队伍].成员数据[n] ~= id then
					发送数据(玩家数据[队伍数据[玩家数据[id].队伍].成员数据[n]].连接id, 1018, {
						id = id,
						文本 = 文本
					})
				end
			end
		else
			local 编号 = 战斗准备类.战斗盒子[玩家数据[id].战斗]:取参战编号(id, "角色")

			if 编号 == nil then
				return
			end

			for n = 1, #队伍数据[玩家数据[id].队伍].成员数据 do
				发送数据(玩家数据[队伍数据[玩家数据[id].队伍].成员数据[n]].连接id, 5512, {
					id = 编号,
					文本 = 文本
				})
			end
		end
	elseif 频道 == 3 then
		local 发言限制 = 100 - 玩家数据[id].角色.数据.等级

		if 发言限制 < 20 then
			发言限制 = 10
		end

		if 玩家数据[id].角色.数据.等级 < 30 then
			常规提示(id, "#Y/等级达到30级才可在世界频道发言")

			return
		end

		玩家数据[id].世界频道 = os.time()

		广播消息({
			频道 = "sj",
			内容 = "[" .. 玩家数据[id].角色.数据.名称 .. "]" .. 文本,
			超链 = 临时超链接数据
		})

		if 三界书院.开关 and 三界书院.答案 == 文本 then
			local 名单重复 = false

			for n = 1, #三界书院.名单 do
				if 三界书院.名单[n].id == id then
					名单重复 = true
				end
			end

			if 名单重复 == false then
				三界书院.名单[#三界书院.名单 + 1] = {
					id = id,
					名称 = 玩家数据[id].角色.数据.名称,
					用时 = os.time() - 三界书院.起始
				}
			end
		end
	elseif 频道 == 4 then
		if 玩家数据[id].角色.数据.等级 < 30 then
			常规提示(id, "#Y/等级达到30级才可在世界频道发言")

			return
		elseif 玩家数据[id].角色.数据.门派 == nil or 玩家数据[id].角色.数据.门派 == "无门派" then
			常规提示(id, "#Y/请加入门派后再在此频道发言。")

			return
		end

		self.门派代号 = 门派代号(玩家数据[id].角色.数据.门派)

		广播门派消息({
			内容 = "[" .. 玩家数据[id].角色.数据.名称 .. "]" .. 文本,
			超链 = 临时超链接数据,
			频道 = self.门派代号
		}, 玩家数据[id].角色.数据.门派)
	elseif 频道 == 9 then
		if f函数.读配置(程序目录 .. "data\\" .. 玩家数据[id].账号 .. "\\账号信息.txt", "账号配置", "管理") ~= "1" then
			常规提示(id, "#Y/你没有GM权限！")

			return
		end

		广播消息({
			频道 = "gm",
			内容 = "[" .. 玩家数据[id].角色.数据.名称 .. "]" .. 文本,
			超链 = 临时超链接数据
		})
	elseif 频道 == 5 then
		if 玩家数据[id].角色.数据.等级 < 30 then
			常规提示(id, "#Y/等级达到20级才可在世界频道发言")

			return
		elseif 玩家数据[id].角色.数据.银子 < 5000 then
			常规提示(id, "#Y/本频道发言需要消耗5000两银子")

			return
		end

		玩家数据[id].传闻频道 = os.time()

		玩家数据[id].角色:扣除银子(5000, 0, 0, "传闻频道发言", 1)

		if 取随机数() <= 10 then
			广播消息({
				频道 = "cw",
				内容 = "[" .. 玩家数据[id].角色.数据.名称 .. "]" .. 文本,
				超链 = 临时超链接数据
			})
		else
			广播消息({
				频道 = "cw",
				内容 = "[某人]" .. 文本,
				超链 = 临时超链接数据
			})
		end
	elseif 频道 == 6 then
		if 玩家数据[id].角色.数据.帮派 == "无帮派" or 玩家数据[id].角色.数据.帮派数据 == nil then
			常规提示(id, "#Y/请加入帮派后再在此频道发言。")

			return
		end

		广播帮派消息({
			频道 = "bp",
			内容 = "[" .. 玩家数据[id].角色.数据.名称 .. "]" .. 文本,
			超链 = 临时超链接数据
		}, 玩家数据[id].角色.数据.帮派数据.编号)
	elseif 频道 == 12 then
		if 玩家数据[id].角色.数据.传音纸鹤 < 1 then
			常规提示(id, "#Y/好像没有剩余的传音纸鹤可使用")
		else
			玩家数据[id].角色.数据.传音纸鹤 = 玩家数据[id].角色.数据.传音纸鹤 - 1
			local cg = 发送传音(玩家数据[id].角色.数据.名称, 数据.文本, 取随机数(1, 4), 临时超链接数据)

			常规提示(id, "#Y/传音剩余#R" .. 玩家数据[id].角色.数据.传音纸鹤 .. "#Y次")

			if cg ~= true then
				常规提示(id, "#Y/传音发送成功、但需要等待！消息队列排序第#R" .. cg .. "#Y")
			end
		end
	end
end

function 聊天处理类:更新(dt)
end

function 聊天处理类:显示(x, y)
end

return 聊天处理类
