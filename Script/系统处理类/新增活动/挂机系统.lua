local 自动挂机系统 = class()
local 对话内容 = require("script/对话处理类/对话内容")()

function 自动挂机系统:初始化()
end

function 自动挂机系统:处理()
	for n, v in pairs(自动挂机) do
		if 玩家数据[n] == nil then
			自动挂机[n] = nil
		end

		if 自动挂机[n] ~= nil then
			if not 取是否可自动挂机(n) then
				自动挂机[n] = nil

				常规提示(n, "#Y/您当前无法使用#P自动挂机#Y功能。")

				return
			end

			if 自动挂机[n].停止时间 ~= nil then
				自动挂机[n].停止时间 = 自动挂机[n].停止时间 - 1
				自动挂机[n].停止时间提醒 = (自动挂机[n].停止时间提醒 or 1) + 1

				if 自动挂机[n].停止时间 <= 0 then
					自动挂机[n].停止时间 = nil
					自动挂机[n].停止时间提醒 = nil

					常规提示(n, "#Y/暂停时间已过、自动挂机#P继续进行#Y！")
				elseif 自动挂机[n].停止时间提醒 > 5 then
					自动挂机[n].停止时间提醒 = 1

					常规提示(n, "#Y/自动挂机将在#R" .. tostring(qz(自动挂机[n].停止时间 * (自动挂机间隔标准 + 1))) .. "#Y秒后#P继续进行#Y！")
				end
			elseif #自动挂机[n].任务挂机 > 0 then
				自动挂机处理(n, 自动挂机[n].任务挂机[1])
			elseif #自动挂机[n].场景地图 > 0 then
				自动挂机处理(n, "场景怪")
			else
				自动挂机[n] = nil
			end
		end
	end
end

置挂机详情 = function(id)
	if 自动挂机[id] ~= nil then
		if not 取是否可自动挂机(id) then
			自动挂机[id] = nil

			常规提示(id, "#Y/您当前无法使用#P自动挂机#Y功能。")

			return
		end

		if 玩家数据[id].队伍 ~= 0 and 玩家数据[id].队长 == false then
			自动挂机[id] = nil

			if 玩家数据[id].自动挂机 == true then
				玩家数据[id].自动挂机 = false

				发送数据(玩家数据[id].连接id, 48.2, {
					自动挂机 = 玩家数据[id].自动挂机
				})
				常规提示(id, "#Y/你关闭了自动挂机功能")
			else
				常规提示(id, "#Y/组队且不为队长无法自动挂机！")
			end
		end

		自动挂机[id] = {
			任务挂机 = {},
			场景地图 = {},
			怪物类型 = {}
		}

		for i = 1, #自动挂机类型列表 do
			local 类型 = 自动挂机类型列表[i]

			if 自动挂机列表[类型][id] ~= nil then
				if 自动挂机类型列表1[类型] == 1 then
					自动挂机[id].任务挂机[#自动挂机[id].任务挂机 + 1] = 类型
				elseif 类型 == "地煞1星" or 类型 == "地煞2星" or 类型 == "地煞3星" or 类型 == "地煞4星" or 类型 == "地煞5星"

				 or 类型 == "地煞6星"  or 类型 == "地煞7星"  or 类型 == "地煞8星"  or 类型 == "地煞9星"  or 类型 == "地煞10星"

				  or 类型 == "地煞11星"  or 类型 == "地煞12星"  or 类型 == "地煞13星"  or 类型 == "地煞14星"  or 类型 == "地煞15星"  then
					自动挂机[id].场景地图 = 列表2加入到列表1(自动挂机[id].场景地图, 刷怪地图范围.地煞星)

					if 自动挂机[id].怪物类型[tostring(自动挂机数据.地煞星.任务类型)] == nil then
						自动挂机[id].怪物类型[tostring(自动挂机数据.地煞星.任务类型)] = {}
					end

					自动挂机[id].怪物类型[tostring(自动挂机数据.地煞星.任务类型)][特殊挂机设置.地煞星[类型]] = 1
				else
					自动挂机[id].场景地图 = 列表2加入到列表1(自动挂机[id].场景地图, 刷怪地图范围[类型])
					自动挂机[id].怪物类型[tostring(自动挂机数据[类型].任务类型)] = 1
				end
			end
		end

		删除重复(自动挂机[id].场景地图)

		if 判断是否为空表(自动挂机[id].怪物类型) and 判断是否为空表(自动挂机[id].任务挂机) then
			自动挂机[id] = nil

			if 玩家数据[id].自动挂机 == true then
				玩家数据[id].自动挂机 = false

				发送数据(玩家数据[id].连接id, 48.2, {
					自动挂机 = 玩家数据[id].自动挂机
				})
				常规提示(id, "#Y/你关闭了自动挂机功能")
			else
				常规提示(id, "#Y/请至少勾选#R一种#Y怪物类别。")
			end
		end
	end
end

三人活动列表 = {
	福利BOSS = 60,
	散财童子 = 40,
	妖魔鬼怪 = 30,
	捣乱的水果 = 40,
	捣乱的水果 = 40,
	二十八星宿 = 30,
	飞贼贼王 = 30,
	玄武任务 = 10,
	初出江湖 = 10,
	天庭叛逆 = 39,
	皇宫飞贼 = 30
}
五人活动列表 = {
	知了王 = 69,
	天罡星 = 60,
	地煞星 = 60
}
类型对应活动名称 = {
	飞贼贼王 = "皇宫飞贼贼王",
	捉鬼 = "抓鬼任务"
}
单人活动列表 = {
	师门任务 = 20,
	宝图任务 = 30,
	青龙任务 = 10
}

取进入战斗要求 = function(id, 类型, 标识)
	if 单人活动列表[类型] ~= nil then
		if 任务数据[标识].战斗 ~= nil then
			常规提示(id, "#Y/对方正在战斗中")

			return
		end

		if 玩家数据[id].队伍 ~= 0 then
			常规提示(id, "#Y必须单人才能触发该活动")

			return
		end

		if 取等级要求(id, 单人活动列表[类型]) == false then
			常规提示(id, "#Y/挑战该活动至少要达到" .. 单人活动列表[类型] .. "级")

			return
		end

		if 活动次数查询(id, 类型对应活动名称[类型] or 类型) == false then
			return
		end
	elseif 三人活动列表[类型] ~= nil then
		if 任务数据[标识].战斗 ~= nil then
			常规提示(id, "#Y/对方正在战斗中")

			return
		end

		if 玩家数据[id].队伍 == 0 then
			常规提示(id, "#Y必须组队才能触发该活动")

			return
		end

		if 取队伍人数(id) < 3 then
			常规提示(id, "#Y/挑战该活动最少要有三人")

			return
		end

		if 取等级要求(id, 三人活动列表[类型]) == false then
			常规提示(id, "#Y/挑战该活动至少要达到" .. 三人活动列表[类型] .. "级")

			return
		end

		if 活动次数查询(id, 类型对应活动名称[类型] or 类型) == false then
			return
		end
	elseif 五人活动列表[类型] ~= nil then
		if 任务数据[标识].战斗 ~= nil then
			常规提示(id, "#Y/对方正在战斗中")

			return
		end

		if 玩家数据[id].队伍 == 0 then
			常规提示(id, "#Y必须组队才能触发该活动")

			return
		end

		if 取队伍人数(id) < 3 then
			常规提示(id, "#Y挑战该活动最少必须由五人进行")

			return
		end

		if 取等级要求(id, 五人活动列表[类型]) == false then
			常规提示(id, "#Y/挑战该活动至少要达到" .. 五人活动列表[类型] .. "级")

			return
		end

		if 活动次数查询(id, 类型对应活动名称[类型] or 类型) == false then
			return
		end
	elseif 类型 == "突厥探子" then
		if 任务数据[标识].战斗 ~= nil then
			常规提示(id, "#Y/对方正在战斗中")

			return
		end

		if 取队伍人数(id) < 活动限制列表.突厥探子.人数 then
			常规提示(id, "#Y队伍人数低于#R" .. 活动限制列表.突厥探子.人数 .. "#Y人，无法进入战斗")

			return
		elseif qz1(取队伍平均等级(玩家数据[id].队伍, id)) < 活动限制列表.突厥探子.等级 then
			常规提示(id, "#Y队伍平均等级小于#R" .. 活动限制列表.突厥探子.等级 .. "#Y级，无法进入战斗。")

			return
		end

		if 活动次数查询(id, "突厥探子") == false then
			return
		end
	elseif 类型 == "突厥精英" then
		if 取队伍人数(id) < 活动限制列表.突厥精英.人数 then
			常规提示(id, "#Y队伍人数低于#R" .. 活动限制列表.突厥精英.人数 .. "#Y人，无法进入战斗")

			return
		elseif qz1(取队伍平均等级(玩家数据[id].队伍, id)) < 活动限制列表.突厥精英.等级 then
			常规提示(id, "#Y队伍平均等级小于#R" .. 活动限制列表.突厥精英.等级 .. "#Y级，无法进入战斗。")

			return
		end

		if 活动次数查询(id, "突厥精英") == false then
			return
		end
	elseif 类型 == "捉鬼" or 类型 == "鬼王任务" or 类型 == "降妖伏魔" then
		if 玩家数据[id].队伍 == nil or 玩家数据[id].队伍 == 0 then
			常规提示(id, "#Y/请先组队！")

			return
		end

		if 任务数据[标识].战斗 ~= nil then
			常规提示(id, "#Y/对方正在战斗中")

			return
		end

		if 活动次数查询(id, 类型对应活动名称[类型] or 类型) == false then
			return
		end

		local 符合 = false

		for n = 1, #任务数据[标识].队伍组 do
			if 任务数据[标识].队伍组[n] == id then
				符合 = true
			end
		end

		return 符合
	elseif 类型 == "门派闯关" then
		if 玩家数据[id].角色:取任务(107) == 0 then
			常规提示(id, "#Y/你没有领取这样的任务")

			return
		end

		if 活动次数查询(id, "门派闯关") == false then
			return
		end

		if 玩家数据[id].队伍 == 0 then
			常规提示(id, "#Y必须组队才能触发该活动")

			return
		end

		if 取队伍人数(id) < 3 then
			常规提示(id, "#Y/进行门派闯关活动最少必须由三人进行")

			return
		end

		if 取等级要求(id, 30) == false then
			常规提示(id, "#Y/进行门派闯关活动至少要达到30级")

			return
		end

		local 任务id = 玩家数据[id].角色:取任务(107)

		for n = 1, #队伍数据[玩家数据[id].队伍] do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, n) == 0 and 玩家数据[队伍数据[玩家数据[id].队伍][n]].角色:取任务(107) ~= 任务id then
				常规提示(id, "#Y/队伍中有成员任务不一致")

				return
			end
		end
	end

	return true
end

刷怪地图范围 = {
	妖魔鬼怪 = {
		1237,
		1876,
		1041
	},
	知了王 = {
		1193,
		1091,
		1514
	},
	捣乱的水果 = {
		1506,
		1193,
		1514,
		1174,
		1210,
		1091
	},
		小鬼子 = {
		1506,
		1193,
		1514,
		1174,
		1210,
		1091
	},
	天庭叛逆 = {
		1040,
		1173,
		1092,
		1091,
		1174,
		1210,
		1110
	},
	突厥精英 = {
		1173,
		1110
	},
	突厥探子 = {
		1173,
		1110
	},
	天罡星 = {
		1201,
		1202,
		1203,
		1221,
		1210,
		1204,
		1258,
		1920,
		1232,
		1207,
		1228,
		1229,
		1231,
		1233,
		2007,
		2001
	},
	地煞星 = {
		1193,
		1514,
		1091,
		1140,
		1146,
		1513,
		1201,
		1203,
		1131,
		1512,
		1258,
		2001,
		1207,
		1232,
		1233,
		1203,
		2007,
		1920
	},
	二十八星宿 = {
		1193,
		1192,
		1116,
		1122,
		1131,
		1135,
		1140,
		1146,
		1173,
		1110,
		1070
	},
	福利BOSS = {
		1001,
		1501,
		1092,
		1208
	},
	散财童子 = {
		1501
	}
}
特殊挂机设置 = {
	地煞星 = {
		地煞1星 = "初出茅庐地煞星",
		地煞3星 = "伏虎斩妖地煞星",
		地煞5星 = "履水吐焰地煞星",
		地煞2星 = "小有所成地煞星",
		地煞4星 = "御风神行地煞星",
		地煞9星 = "无可匹敌地煞星",
		地煞10星 = "十全十美地煞星",
		地煞6星 = "牛逼轰轰地煞星",
		地煞7星 = "东倒西歪地煞星",
		地煞13星 = "十三星地煞星",
		地煞11星 = "十一星地煞星",
		地煞12星 = "十二星地煞星",
		地煞14星 = "十四星地煞星",
		地煞15星 = "十五星地煞星",
		地煞8星 = "稀奇古怪地煞星"
	}
}
自动挂机数据 = {
	捉鬼 = {
		任务类型 = 8,
		战斗编号 = 100008,
		地图 = {
			1122,
			57,
			63
		}
	},
	鬼王任务 = {
		任务类型 = 9000,
		战斗编号 = 100008.1,
		地图 = {
			1125,
			33,
			27
		}
	},
	初出江湖 = {
		任务类型 = 11,
		战斗编号 = 100021,
		地图 = {
			1001,
			219,
			100
		}
	},
	门派闯关 = {
		任务类型 = 107,
		战斗编号 = 100011,
		地图 = {
			1001,
			131,
			88
		}
	},
	降妖伏魔 = {
		任务类型 = 200,
		战斗编号 = 100242,
		地图 = {
			1091,
			136,
			86
		}
	},
	皇宫飞贼 = {
		任务类型 = 12,
		战斗编号 = 100022,
		地图 = {
			1001,
			107,
			66
		}
	},
	飞贼贼王 = {
		任务类型 = 15,
		战斗编号 = 100023,
		地图 = {
			1001,
			107,
			66
		}
	},
	玄武任务 = {
		任务类型 = 302,
		战斗编号 = 100035,
		地图 = {
			1845,
			21,
			19
		}
	},
	宝图任务 = {
		任务类型 = 4,
		战斗编号 = 100002,
		地图 = {
			1028,
			20,
			30
		}
	},
	师门任务 = {
		任务类型 = 111,
		战斗编号 = 100015,
		地图 = {
			1028,
			20,
			30
		}
	},
	青龙任务 = {
		任务类型 = 301,
		战斗编号 = 100034,
		地图 = {
			1865,
			25,
			20
		}
	},
	妖魔鬼怪 = {
		任务类型 = 105,
		战斗编号 = 100010
	},
	知了王 = {
		任务类型 = 210,
		战斗编号 = 100027
	},
	天庭叛逆 = {
		任务类型 = 128,
		战斗编号 = 100032
	},
	捣乱的水果 = {
		任务类型 = 129,
		战斗编号 = 100033
	},
	小鬼子 = {
		任务类型 = 199,
		战斗编号 = 199933
	},
	突厥精英 = {
		任务类型 = 100863,
		战斗编号 = 34479.2
	},
	突厥探子 = {
		任务类型 = 100862,
		战斗编号 = 34479.1
	},
	天罡星 = {
		任务类型 = 314,
		战斗编号 = 100056
	},
	地煞星 = {
		任务类型 = 304,
		战斗编号 = 100037
	},
	二十八星宿 = {
		任务类型 = 104,
		战斗编号 = 100009
	},
	福利BOSS = {
		任务类型 = 318,
		战斗编号 = 100060
	},
	散财童子 = {
		任务类型 = 337,
		战斗编号 = 100084
	}
}
自动挂机数据1 = {
	["304"] = "地煞星",
	["318"] = "福利BOSS",
	["104"] = "二十八星宿",
	["105"] = "妖魔鬼怪",
	["337"] = "散财童子",
	["128"] = "天庭叛逆",
	["100862"] = "突厥探子",
	["129"] = "捣乱的水果",
	["199"] = "小鬼子",
	["210"] = "知了王",
	["314"] = "天罡星",
	["100863"] = "突厥精英"
}
自动类型1 = {
	知了王 = 1,
	妖魔鬼怪 = 1
}
找人巡逻任务 = {
	玄武任务 = 1,
	师门任务 = 1,
	青龙任务 = 1
}

自动挂机处理 = function(id, 类型)
	if 玩家数据[id].战斗 ~= 0 then
		return
	end

	if 自动挂机[id].战斗停顿 ~= nil then
		自动挂机[id].战斗停顿 = 自动挂机[id].战斗停顿 - 1

		if 自动挂机[id].战斗停顿 <= 0 then
			自动挂机[id].战斗停顿 = nil
		else
			return
		end
	end

	if 自动挂机[id].全员月卡 == nil then
		自动挂机[id].全员月卡 = 取是否全员月卡(id)
	end

	local 角色数据 = 玩家数据[id].角色.数据

	if 自动挂机类型列表1[类型] == 1 then
		if 单人活动列表[类型] ~= nil and 玩家数据[id].队伍 ~= 0 then
			队伍处理类:退出队伍(id)

			return
		elseif 单人活动列表[类型] == nil and 玩家数据[id].队伍 == 0 then
			队伍处理类:创建队伍(id, {
				id = id + 0
			})

			return
		end

		local 任务id = 玩家数据[id].角色:取任务(自动挂机数据[类型].任务类型)
		local 临时地图, 临时师傅坐标 = nil

		if 类型 == "师门任务" then
			临时师傅坐标 = 门派师傅坐标[角色数据.门派]

			if 临时师傅坐标 == nil then
				常规提示(id, "#Y/门派数据错误！")
				取消挂机(id, 类型)

				return
			else
				临时地图 = {
					临时师傅坐标[1],
					临时师傅坐标[2],
					临时师傅坐标[3]
				}
			end
		end

		if 任务id ~= 0 then
			if 找人巡逻任务[类型] ~= nil then
				if 临时地图 == nil then
					临时地图 = {
						1001,
						50,
						50
					}
				else
					临时地图 = {
						取门派巡逻地图(角色数据.门派)[1],
						50,
						50
					}
				end

				local 临时任务类型 = "找人"

				if 类型 == "师门任务" then
					if 任务数据[任务id].分类 ~= 2 and 任务数据[任务id].分类 ~= 1 then
						if 任务数据[任务id].分类 == 5 or 任务数据[任务id].分类 == 6 or 任务数据[任务id].分类 == 7 then
							地图处理类:删除单位(任务数据[任务id].地图编号, 任务数据[任务id].单位编号)
						end

						玩家数据[id].角色:取消任务(任务id)

						任务数据[任务id] = nil

						添加最后对话(id, "已经为你取消了当前师门任务。")

						return
					elseif 任务数据[任务id].分类 == 2 then
						临时任务类型 = "巡逻"
					end
				elseif 类型 == "青龙任务" then
					if 任务数据[任务id].分类 ~= 4 and 任务数据[任务id].分类 ~= 1 then
						玩家数据[id].角色:取消任务(玩家数据[id].角色:取任务(301))
						发送数据(玩家数据[id].连接id, 1501, {
							名称 = "青龙总管",
							对话 = "已经成功帮你取消了任务。",
							模型 = "男人_兰虎"
						})

						return
					elseif 任务数据[任务id].分类 == 4 then
						临时任务类型 = "巡逻"
					end
				elseif 类型 == "玄武任务" then
					if 任务数据[任务id].分类 ~= 4 and 任务数据[任务id].分类 ~= 1 then
						local id组 = 取id组(id)

						for i = 1, #id组 do
							if 玩家数据[id组[i]].角色:取任务(302) ~= 0 then
								玩家数据[id组[i]].角色:取消任务(玩家数据[id组[i]].角色:取任务(302))
								发送数据(玩家数据[id组[i]].连接id, 1501, {
									名称 = "厢房总管",
									对话 = "已经成功帮你取消了任务。",
									模型 = "男人_兰虎"
								})
							end
						end
					elseif 任务数据[任务id].分类 == 4 then
						临时任务类型 = "巡逻"
					end
				end

				if 临时任务类型 == "找人" then
					if 角色数据.地图数据.编号 ~= 任务数据[任务id].地图编号 then
						if 自动挂机同地图模式 == 1 and 自动挂机[id].全员月卡 ~= true then
							local xy = 地图处理类.地图坐标[任务数据[任务id].地图编号]:取随机点()

							全队跳转地图(id, 任务数据[任务id].地图编号, xy.x, xy.y)
						else
							local xy = 取假人表1(任务数据[任务id].地图编号, nil, 任务数据[任务id].人物)

							全队跳转地图(id, 任务数据[任务id].地图编号, xy.X, xy.Y)
						end

						return
					else
						local xy = 取假人表1(任务数据[任务id].地图编号, nil, 任务数据[任务id].人物)
						local 怪物坐标 = {
							xy.X,
							xy.Y
						}
						local ax = qz(角色数据.地图数据.x / 20)
						local ay = qz(角色数据.地图数据.y / 20)
						local 通过 = false

						if math.abs(怪物坐标[1] - ax) >= 5 or math.abs(怪物坐标[2] - ay) >= 5 then
							if 自动挂机同地图模式 == 1 and 自动挂机[id].全员月卡 ~= true then
								if 判断是否为空表(玩家数据[id].移动数据 or {}) or math.abs(玩家数据[id].移动数据.移动目标.x - 怪物坐标[1]) >= 5 or math.abs(玩家数据[id].移动数据.移动目标.y - 怪物坐标[2]) >= 5 then
									地图处理类:移动请求(id, {
										x = 怪物坐标[1],
										y = 怪物坐标[2],
										数字id = id
									}, id, true)
								end

								if math.abs(怪物坐标[1] - ax) <= 7 or math.abs(怪物坐标[2] - ay) <= 7 then
									通过 = true
								end
							else
								全队跳转地图(id, 任务数据[任务id].地图编号, 怪物坐标[1], 怪物坐标[2])

								return
							end

							if not 通过 then
								if 玩家数据[id].挂机坐标记录 == nil then
									玩家数据[id].挂机坐标记录 = {
										ax,
										ay,
										0
									}
								end

								if ax == 玩家数据[id].挂机坐标记录[1] and ay == 玩家数据[id].挂机坐标记录[2] then
									玩家数据[id].挂机坐标记录[3] = 玩家数据[id].挂机坐标记录[3] + 1
								else
									玩家数据[id].挂机坐标记录 = {
										ax,
										ay,
										0
									}
								end

								if 玩家数据[id].挂机坐标记录[3] >= 4 then
									玩家数据[id].挂机坐标记录[3] = 0
									通过 = true
								elseif 玩家数据[id].挂机坐标记录[3] >= 2 then
									地图处理类:移动请求(id, {
										x = math.max(怪物坐标[1] - 1, 1),
										y = math.max(怪物坐标[2] - 1, 1),
										数字id = id
									}, id, true)
								end

								if not 通过 then
									return
								end
							end
						end

						if 取固定NPC对话(id, 任务数据[任务id].地图编号, 任务数据[任务id].人物) ~= true then
							print("固定NPC对话错误【" .. 任务数据[任务id].地图编号 .. "、" .. 任务数据[任务id].人物 .. "】")
						end
					end
				elseif 临时任务类型 == "巡逻" then
					local ax = qz(角色数据.地图数据.x / 20)
					local ay = qz(角色数据.地图数据.y / 20)

					if 玩家数据[id].挂机坐标记录 == nil then
						玩家数据[id].挂机坐标记录 = {
							ax,
							ay,
							0
						}
					end

					if ax == 玩家数据[id].挂机坐标记录[1] and ay == 玩家数据[id].挂机坐标记录[2] then
						玩家数据[id].挂机坐标记录[3] = 玩家数据[id].挂机坐标记录[3] + 1
					else
						玩家数据[id].挂机坐标记录 = {
							ax,
							ay,
							0
						}
					end

					local 卡地形 = false

					if 玩家数据[id].挂机坐标记录[3] >= 3 then
						卡地形 = true
					end

					if 角色数据.地图数据.编号 ~= 临时地图[1] or 卡地形 == true then
						local xy = 地图处理类.地图坐标[临时地图[1]]:取随机点()

						全队跳转地图(id, 临时地图[1], xy.x, xy.y)

						return
					else
						开启全队自动战斗(id)

						local xy = 地图处理类.地图坐标[临时地图[1]]:取随机点()

						地图处理类:移动请求(id, {
							x = xy.x,
							y = xy.y,
							数字id = id
						}, id, true)
					end
				end
			else
				local 怪物地图 = 任务数据[任务id].地图编号
				local 怪物坐标 = {
					任务数据[任务id].x,
					任务数据[任务id].y
				}

				if 角色数据.地图数据.编号 ~= 怪物地图 then
					if 自动挂机同地图模式 == 1 and 自动挂机[id].全员月卡 ~= true then
						local xy = 地图处理类.地图坐标[怪物地图]:取随机点()

						全队跳转地图(id, 怪物地图, xy.x, xy.y)
					else
						全队跳转地图(id, 怪物地图, 怪物坐标[1], 怪物坐标[2])
					end
				else
					local ax = qz(角色数据.地图数据.x / 20)
					local ay = qz(角色数据.地图数据.y / 20)
					local 通过 = false

					if math.abs(怪物坐标[1] - ax) >= 5 or math.abs(怪物坐标[2] - ay) >= 5 then
						if 自动挂机同地图模式 == 1 and 自动挂机[id].全员月卡 ~= true then
							if 判断是否为空表(玩家数据[id].移动数据 or {}) or math.abs(玩家数据[id].移动数据.移动目标.x - 怪物坐标[1]) >= 5 or math.abs(玩家数据[id].移动数据.移动目标.y - 怪物坐标[2]) >= 5 then
								地图处理类:移动请求(id, {
									x = 怪物坐标[1],
									y = 怪物坐标[2],
									数字id = id
								}, id, true)
							end

							if math.abs(怪物坐标[1] - ax) <= 7 or math.abs(怪物坐标[2] - ay) <= 7 then
								通过 = true
							end
						else
							全队跳转地图(id, 怪物地图, 怪物坐标[1], 怪物坐标[2])

							return
						end

						if not 通过 then
							if 玩家数据[id].挂机坐标记录 == nil then
								玩家数据[id].挂机坐标记录 = {
									ax,
									ay,
									0
								}
							end

							if ax == 玩家数据[id].挂机坐标记录[1] and ay == 玩家数据[id].挂机坐标记录[2] then
								玩家数据[id].挂机坐标记录[3] = 玩家数据[id].挂机坐标记录[3] + 1
							else
								玩家数据[id].挂机坐标记录 = {
									ax,
									ay,
									0
								}
							end

							if 玩家数据[id].挂机坐标记录[3] >= 4 then
								玩家数据[id].挂机坐标记录[3] = 0
								通过 = true
							elseif 玩家数据[id].挂机坐标记录[3] >= 2 then
								地图处理类:移动请求(id, {
									x = math.max(怪物坐标[1] - 1, 1),
									y = math.max(怪物坐标[2] - 1, 1),
									数字id = id
								}, id, true)
							end

							if not 通过 then
								return
							end
						end
					end

					local 怪物编号 = 任务数据[任务id].单位编号
					local 找到指定单位 = false

					if 类型 == "门派闯关" then
						if 任务数据[任务id].当前序列 == nil or Q_门派编号[任务数据[任务id].当前序列] == nil then
							取消挂机(id, 类型)

							return
						end

						for k, v in pairs(地图处理类.地图单位[怪物地图]) do
							if type(v) == "table" and tostring(v.类型) == "106" and v.名称 == Q_门派编号[任务数据[任务id].当前序列] .. "护法" then
								找到指定单位 = true
								任务id = v.id
							end
						end
					elseif 地图处理类.地图单位[怪物地图][怪物编号] ~= nil and 地图处理类.地图单位[怪物地图][怪物编号].id == 任务id then
						找到指定单位 = true
					end

					if 找到指定单位 then
						local 符合 = 取进入战斗要求(id, 怪物类型, 任务id)

						if 符合 then
							开启全队自动战斗(id)
							战斗准备类:创建战斗(id + 0, 自动挂机数据[类型].战斗编号, 任务id)

							任务数据[任务id].战斗 = true
							玩家数据[id].地图单位 = nil
							自动挂机[id].战斗停顿 = 自动挂机战斗后停顿 + 1
						else
							常规提示(id, "#Y/任务数据错误！")
							取消挂机(id, 类型)

							return
						end
					end
				end
			end
		else
			if 临时地图 == nil then
				临时地图 = {
					自动挂机数据[类型].地图[1],
					自动挂机数据[类型].地图[2],
					自动挂机数据[类型].地图[3]
				}
			end

			if 角色数据.地图数据.编号 ~= 临时地图[1] then
				全队跳转地图(id, 临时地图[1], 临时地图[2], 临时地图[3])
			else
				local ax = qz(角色数据.地图数据.x / 20)
				local ay = qz(角色数据.地图数据.y / 20)

				if math.abs(临时地图[2] - ax) >= 10 or math.abs(临时地图[3] - ay) >= 10 then
					全队跳转地图(id, 临时地图[1], 临时地图[2], 临时地图[3])

					return
				end

				local 领取任务 = ""

				if 类型 == "捉鬼" then
					领取任务 = 任务处理类:添加抓鬼任务(id)
				elseif 类型 == "鬼王任务" then
					领取任务 = 任务处理类:添加鬼王任务(id)
				elseif 类型 == "初出江湖" then
					领取任务 = 任务处理类:添加江湖任务(id)
				elseif 类型 == "门派闯关" then
					领取任务 = 任务处理类:添加闯关任务(id)
				elseif 类型 == "降妖伏魔" then
					领取任务 = 任务处理类:添加降妖除魔任务(id)
				elseif 类型 == "皇宫飞贼" then
					领取任务 = 任务处理类:添加皇宫飞贼任务(id)
				elseif 类型 == "飞贼贼王" then
					领取任务 = 任务处理类:添加皇宫贼王任务(id)
				elseif 类型 == "宝图任务" then
					领取任务 = 任务处理类:添加宝图任务(id)
				elseif 类型 == "师门任务" then
					领取任务 = 任务处理类:添加门派任务(id, 角色数据.门派, 1)
				elseif 类型 == "玄武任务" then
					领取任务 = 任务处理类:设置玄武任务(id, 1)
				elseif 类型 == "青龙任务" then
					领取任务 = 任务处理类:设置青龙任务(id, 1)
				end

				if 领取任务 ~= true then
					取消挂机(id, 类型)

					return
				end
			end
		end
	elseif 类型 == "场景怪" then
		if 玩家数据[id].自动地图 == nil then
			玩家数据[id].自动地图 = {}
		end

		玩家数据[id].自动地图.记录 = 玩家数据[id].自动地图.记录 or 1

		if 玩家数据[id].自动地图.记录 > #自动挂机[id].场景地图 then
			玩家数据[id].自动地图.记录 = 1
		end

		local 怪物地图 = 自动挂机[id].场景地图[玩家数据[id].自动地图.记录]

		if 角色数据.地图数据.编号 ~= 怪物地图 then
			local xy = 地图处理类.地图坐标[怪物地图]:取随机点()

			全队跳转地图(id, 怪物地图, xy.x, xy.y)
		else
			if 玩家数据[id].自动地图.预备单位 == nil then
				local 可选 = {}

				for k, v in pairs(地图处理类.地图单位[怪物地图]) do
					if 自动挂机[id].怪物类型[tostring(v.类型)] ~= nil then
						local 符合 = true

						if 自动挂机数据1[tostring(v.类型)] == "地煞星" and 自动挂机[id].怪物类型[tostring(v.类型)][v.名称] == nil then
							符合 = false
						end

						if 符合 then
							可选[#可选 + 1] = v.id
						end
					end
				end

				if #可选 > 0 then
					local 任务id = 可选[ygsj(#可选)]

					if 任务数据[任务id].战斗 == nil then
						玩家数据[id].自动地图.预备单位 = 任务id

						if 自动挂机同地图模式 ~= 1 or 自动挂机[id].全员月卡 == true then
							全队跳转地图(id, 怪物地图, 任务数据[任务id].x, 任务数据[任务id].y)
						end

						return
					end
				end
			else
				local 任务id = 玩家数据[id].自动地图.预备单位

				if 任务数据[任务id] == nil then
					玩家数据[id].自动地图.预备单位 = nil

					return
				end

				local ax = qz(角色数据.地图数据.x / 20)
				local ay = qz(角色数据.地图数据.y / 20)

				if math.abs(任务数据[任务id].x - ax) >= 5 or math.abs(任务数据[任务id].y - ay) >= 5 then
					local 通过 = false

					if 自动挂机同地图模式 == 1 and 自动挂机[id].全员月卡 ~= true then
						if 判断是否为空表(玩家数据[id].移动数据 or {}) or math.abs(玩家数据[id].移动数据.移动目标.x - 任务数据[任务id].x) >= 5 or math.abs(玩家数据[id].移动数据.移动目标.y - 任务数据[任务id].y) >= 5 then
							地图处理类:移动请求(id, {
								x = 任务数据[任务id].x,
								y = 任务数据[任务id].y,
								数字id = id
							}, id, true)
						end

						if math.abs(任务数据[任务id].x - ax) <= 7 or math.abs(任务数据[任务id].y - ay) <= 7 then
							通过 = true
						end
					else
						全队跳转地图(id, 怪物地图, 任务数据[任务id].x, 任务数据[任务id].y)
					end

					if not 通过 then
						if 玩家数据[id].挂机坐标记录 == nil then
							玩家数据[id].挂机坐标记录 = {
								ax,
								ay,
								0
							}
						end

						if ax == 玩家数据[id].挂机坐标记录[1] and ay == 玩家数据[id].挂机坐标记录[2] then
							玩家数据[id].挂机坐标记录[3] = 玩家数据[id].挂机坐标记录[3] + 1
						else
							玩家数据[id].挂机坐标记录 = {
								ax,
								ay,
								0
							}
						end

						if 玩家数据[id].挂机坐标记录[3] >= 4 then
							玩家数据[id].挂机坐标记录[3] = 0
							通过 = true
						elseif 玩家数据[id].挂机坐标记录[3] >= 2 then
							地图处理类:移动请求(id, {
								x = math.max(任务数据[任务id].x - 1, 1),
								y = math.max(任务数据[任务id].y - 1, 1),
								数字id = id
							}, id, true)
						end

						if not 通过 then
							return
						end
					end
				end

				if 任务数据[任务id].战斗 == nil then
					local 怪物类型 = 自动挂机数据1[tostring(任务数据[任务id].类型)]

					if 单人活动列表[怪物类型] ~= nil and 玩家数据[id].队伍 ~= 0 then
						队伍处理类:退出队伍(id)

						return
					elseif 单人活动列表[怪物类型] == nil and 玩家数据[id].队伍 == 0 then
						队伍处理类:创建队伍(id, {
							id = id + 0
						})

						return
					end

					local 符合 = 取进入战斗要求(id, 怪物类型, 任务id)

					if 符合 == true then
						local 怪物坐标 = {
							任务数据[任务id].x,
							任务数据[任务id].y
						}
						玩家数据[id].自动地图.次数 = 0

						开启全队自动战斗(id)
						战斗准备类:创建战斗(id + 0, 自动挂机数据[怪物类型].战斗编号, 任务id)

						自动挂机[id].战斗停顿 = 自动挂机战斗后停顿 + 1
						任务数据[任务id].战斗 = true
						玩家数据[id].地图单位 = nil
						玩家数据[id].自动地图.预备单位 = nil
					else
						取消挂机(id, 怪物类型)
					end

					玩家数据[id].自动地图.预备单位 = nil

					return
				else
					常规提示(id, "#Y/怪被别人抢啦！#114")

					玩家数据[id].自动地图.预备单位 = nil

					return
				end
			end

			常规提示(id, "#Y/当前地图没有#P指定场景怪#Y了。")

			玩家数据[id].自动地图.记录 = 玩家数据[id].自动地图.记录 + 1
			玩家数据[id].自动地图.次数 = (玩家数据[id].自动地图.次数 or 0) + 1

			if 玩家数据[id].自动地图.记录 > #自动挂机[id].场景地图 then
				玩家数据[id].自动地图.记录 = 1
			end

			if 玩家数据[id].自动地图.次数 >= #自动挂机[id].场景地图 then
				玩家数据[id].自动地图.次数 = 0
				自动挂机[id].停止时间 = 自动挂机暂停时间 / (自动挂机间隔标准 + 1)

				常规提示(id, "#Y/指定场景怪的所有刷怪地图皆没有#P可战斗单位#Y、自动挂机将#S暂停#R" .. 自动挂机暂停时间 .. "秒#Y之后再继续进行。")

				return
			end
		end
	end
end

取消挂机 = function(id, 类型)
	if 特殊挂机设置[类型] ~= nil or 自动挂机列表[类型][id] ~= nil then
		if 特殊挂机设置[类型] ~= nil then
			for k, v in pairs(特殊挂机设置[类型]) do
				if 自动挂机列表[k] ~= nil then
					自动挂机列表[k][id] = nil
				end
			end
		else
			自动挂机列表[类型][id] = nil
		end

		置挂机详情(id)
		常规提示(id, "#Y/自动挂机#P【" .. 类型 .. "】#Y功能#R已关闭")
	end

	发送数据(玩家数据[id].连接id, 7010.4, 取挂机详情(id))
end

取消其他自动 = function(id, 类型)
	if 玩家数据[id].队伍 == 0 then
		取消自动(id, 类型)
	else
		for n = 1, #队伍数据[玩家数据[id].队伍].成员数据 do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, n) == 0 then
				local id1 = 队伍数据[玩家数据[id].队伍].成员数据[n]

				取消自动(id1, 类型)
			end
		end
	end
end

取消自动 = function(id, 类型)
	if 类型 ~= "挂机" then
		自动挂机[id] = nil

		if 玩家数据[id].自动挂机 == true then
			玩家数据[id].自动挂机 = false

			发送数据(玩家数据[id].连接id, 48.2, {
				自动挂机 = 玩家数据[id].自动挂机
			})
			常规提示(id, "#Y/你关闭了自动挂机功能")
		end
	end

	if 类型 ~= "遇怪" then
		自动遇怪[id] = nil

		if 玩家数据[id].角色.数据.自动遇怪 == true then
			玩家数据[id].角色.数据.自动遇怪 = false

			发送数据(玩家数据[id].连接id, 48, {
				遇怪 = 玩家数据[id].角色.数据.自动捉鬼
			})
			常规提示(id, "#Y/你关闭了自动遇怪功能")
		end
	end

	if 类型 ~= "捉鬼" then
		自动捉鬼[id] = nil

		if 玩家数据[id].角色.数据.自动捉鬼 == true then
			玩家数据[id].角色.数据.自动捉鬼 = false

			发送数据(玩家数据[id].连接id, 48.1, {
				自动捉鬼 = 玩家数据[id].角色.数据.自动捉鬼
			})
			常规提示(id, "#Y/你关闭了自动捉鬼功能")
		end
	end
end

开启全队自动战斗 = function(id)
	if 玩家数据[id].队伍 == 0 then
		玩家数据[id].角色.数据.自动战斗 = true
	else
		for n = 1, #队伍数据[玩家数据[id].队伍].成员数据 do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, n) == 0 then
				玩家数据[队伍数据[玩家数据[id].队伍].成员数据[n]].角色.数据.自动战斗 = true
			end
		end
	end
end

全队跳转地图 = function(id, 地图编号, x, y)
	if 玩家数据[id].队伍 == 0 then
		地图处理类:跳转地图(id, tonumber(地图编号), tonumber(x), tonumber(y))
	else
		for n = 1, #队伍数据[玩家数据[id].队伍].成员数据 do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, n) == 0 then
				地图处理类:跳转地图(队伍数据[玩家数据[id].队伍].成员数据[n], tonumber(地图编号), tonumber(x), tonumber(y))
			end
		end
	end
end

取固定NPC对话 = function(id, 地图, NPC名称)
	local jr = 取假人表(地图)
	local 编号 = 0

	for k, v in pairs(jr) do
		if v.名称 == NPC名称 then
			编号 = k + 0

			break
		end
	end

	if 编号 ~= 0 then
		对话内容:索取对话内容(玩家数据[id].连接id, id, nil, {
			地图 = 地图,
			编号 = 编号
		})

		return true
	else
		return false
	end
end

取挂机详情 = function(id)
	local 挂机详情 = {}

	for i = 1, #自动挂机类型列表 do
		挂机详情[#挂机详情 + 1] = {}
		挂机详情[#挂机详情][1] = 自动挂机类型列表[i]
		挂机详情[#挂机详情][2] = false

		if 自动挂机列表[自动挂机类型列表[i]][id] ~= nil then
			挂机详情[#挂机详情][2] = true
		end
	end

	return 挂机详情
end

挂机自动飞行 = function(id)
	if 玩家数据[id].角色.数据.飞行中 == true then
		return
	end

	local 坐骑 = false

	for i = 1, #玩家数据[id].角色.数据.坐骑列表 do
		if 玩家数据[id].角色.数据.坐骑列表[i].参战信息 ~= nil then
			坐骑 = true
		end
	end

	if 坐骑 then
		if 玩家数据[id].队伍 == 0 then
			玩家数据[id].角色.数据.飞行中 = true

			地图处理类:玩家是否飞行(id, 玩家数据[id].角色.数据.飞行中)
			常规提示(id, "#Y/你飞了起来...")
		elseif 队伍数据[玩家数据[id].队伍].成员数据[1] == id then
			玩家数据[id].角色.数据.飞行中 = true

			队伍处理类:取队伍飞行(玩家数据[id].队伍, id)
			常规提示(id, "#Y/你飞了起来...")
		else
			常规提示(id, "#Y你不是队长无法飞行")
		end

		发送数据(玩家数据[id].连接id, 60.1, {
			飞行中 = 玩家数据[id].角色.数据.飞行中
		})
	end
end

取是否全员月卡 = function(id)
	if 玩家数据[id].队伍 == 0 then
		return 是否月卡用户(id)
	else
		for n = 1, #队伍数据[玩家数据[id].队伍].成员数据 do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, n) == 0 then
				local id1 = 队伍数据[玩家数据[id].队伍].成员数据[n]

				if 是否月卡用户(id1) == false then
					return false
				end
			end
		end

		return true
	end
end

取是否可自动挂机 = function(id)
	if 玩家数据[id].队伍 == 0 then
		return 取是否挂机月卡(id)
	else
		for n = 1, #队伍数据[玩家数据[id].队伍].成员数据 do
			if 队伍处理类:取是否助战(玩家数据[id].队伍, n) == 0 then
				local id1 = 队伍数据[玩家数据[id].队伍].成员数据[n]

				if 取是否挂机月卡(id1, id) == false then
					return false
				end
			end
		end

		return true
	end
end

取是否挂机月卡 = function(id, 队长id)
	if (玩家数据[id].角色.数据.挂机月卡 or 0) <= 0 or (玩家数据[id].角色.数据.挂机时间限制 or 0) < os.time() then
		if (玩家数据[id].角色.数据.挂机月卡 or 0) > 0 then
			挂机月卡过期处理(id)
		end

		常规提示(id, "#Y/你没有#P挂机月卡")

		if 队长id ~= nil and 队长id ~= id then
			常规提示(队长id, "#P" .. 玩家数据[id].角色.数据.名称 .. "#Y尚未激活#P挂机月卡")
		end

		return false
	end

	return true
end

发送队伍挂机数据 = function(id)
	发送数据(玩家数据[id].连接id, 48.2, {
		自动挂机 = 玩家数据[id].自动挂机
	})

	if 玩家数据[id].队伍 ~= 0 then
		for n = 2, #队伍数据[玩家数据[id].队伍].成员数据 do
			if 玩家数据[id].队伍 ~= 0 and 队伍处理类:取是否助战(玩家数据[id].队伍, n) == 0 then
				local id1 = 队伍数据[玩家数据[id].队伍].成员数据[n]

				发送数据(玩家数据[id1].连接id, 48.3, {
					自动挂机 = 玩家数据[id].自动挂机
				})
			end
		end
	end
end

return 自动挂机系统
