local BotManager = class()

function BotManager:初始化()
	__gge.print(false, 11, "=======================")
	__gge.print(false, 10, " 假人加载 ")
	__gge.print(false, 11, "=======================\n")

	local itemtxt = 读入文件("tysj/Bot/ItemTable.txt")
	local itemCfg = table.loadstring(itemtxt)

	BoothDb:initItemTable(itemCfg)

	local bbtxt = 读入文件("tysj/Bot/BBTable.txt")
	local bbCfg = table.loadstring(bbtxt)

	BoothDb:initBBTable(bbCfg)

	local boothbottxt = 读入文件("tysj/Bot/BoothBot.txt")
	local boothBotCfg = table.loadstring(boothbottxt)

	BoothCtrl:initAddTime(boothBotCfg.addTime)
	BoothDb:addBoothBot(boothBotCfg.boothList)

	--todo: 读取假人聊天配置
	local chatbottxt = 读入文件("tysj/Bot/ChatBot.txt")
	local chatBotCfg = table.loadstring(chatbottxt)
	ChatDb:initWordChatList(chatBotCfg.wordChat)
	ChatDb:initSystemList(chatBotCfg.systemChat)
	ChatDb:initNameList(chatBotCfg.nameList)
	ChatDb:initItemList(chatBotCfg.itemList)

	ChatCtrl:initWordChatTime(chatBotCfg.systemTime)
	ChatCtrl:initSysChatTime(chatBotCfg.wordTime)

	--todo: 读取地图假人配置
	local fightbottxt = 读入文件("tysj/Bot/FightBot.txt")
	local fightBotCfg = table.loadstring(fightbottxt)
	BotDb:initTeamDb(fightBotCfg.teamList)
	BotDb:initAloneDb(fightBotCfg.botList)

	BotCtrl:initShowCtrl(fightBotCfg.botAddTime)
	BotCtrl:initTeamShowCtrl(fightBotCfg.teamBotAddTime)
	BotCtrl:initFightTime(fightBotCfg.fightTime)
	BotCtrl:initRunTime(fightBotCfg.runTime)

	__gge.print(false, 11, "=======================")
	__gge.print(false, 10, " 假人完成 ")
	__gge.print(false, 11, "=======================\n")
end

function BotManager:刷新摆摊(参数)
	local boothbottxt = 读入文件("tysj/Bot/BoothBot.txt")
	local boothBotCfg = table.loadstring(boothbottxt)
	local 假人数量 = #boothBotCfg.boothList

	for n = 1, 假人数量 do
		local id = boothBotCfg.boothList[n].id
		local bot = BoothDb:getBotById(id)
		local ItemID = bot.bot.itemTable
		local BBID = bot.bot.BBTable

		if ItemID then
			bot:setItemTable(self:RandomTable(ItemID))
		end

		if BBID then
			bot:setBBTable(self:RandomTable(BBID, 1))
		end
	end
end

function BotManager:RandomTable(id, sort)
	local 道具1 = 读入文件("tysj/Bot/ItemTable.txt")
	local 摆摊道具 = table.loadstring(道具1)
	local 宝宝1 = 读入文件("tysj/Bot/BBTable.txt")
	local 宝宝 = table.loadstring(宝宝1)
	local ret = {}
	local Table = 摆摊道具[id]
	local Limit = math.random(1, 20)

	if sort then
		Limit = math.random(1, 8)
		Table = 宝宝[id]
	end

	for k, v in pairs(Table) do
		ret[#ret + 1] = DeepCopy(v)

		table.remove(Table, k)

		if Limit < #ret then
			break
		end
	end

	return ret
end

function BotManager:getBoothBot(botId)
end

function BotManager:isBot(userid)
end

function BotManager:onPlayerJoin(mapid, cid)
	BotCtrl:sendBot(mapid, cid)
	BoothCtrl:sendBoothBot(mapid, cid)
end

function BotManager:secondLoop()
	BotCtrl:timeLoop()
	-- BoothCtrl:timeLoop()
	ChatCtrl:timeLoop()
end

return BotManager
