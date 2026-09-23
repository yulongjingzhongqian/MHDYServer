local BoothCtrl = class()

function BoothCtrl:初始化(...)
	self.minCnt = 0
	self.timeCnt = 0
	self.time_create = 0
	self.create_num = 0
end

function BoothCtrl:minLoop(...)
	self.minCnt = self.minCnt + 1

	BoothDb:boothAdd(self.create_num)
end

function BoothCtrl:timeLoop(...)
	self.timeCnt = self.timeCnt + 1

	if self.timeCnt % 2 == 0 then
		self:minLoop()
	end
end

function BoothCtrl:MsgCtrl(id, msgIdx, arg, ctx)
	if msgIdx == 3725 then
		if not BoothDb:isBot(ctx.id) then
			return false
		end

		local bot = BoothDb:getBotById(ctx.id)

		发送数据(玩家数据[arg].连接id, 3520, 玩家数据[arg].角色.数据.银子)
		发送数据(玩家数据[arg].连接id, 3521, {
			bb = bot:getBBTable(),
			物品 = bot:getItemTable(),
			id = arg,
			摊主名称 = bot.bot.摊位名称,
			名称 = bot.bot.名称
		})

		玩家数据[arg].摊位查看 = os.time()
		玩家数据[arg].摊位id = ctx.id

		return true
	elseif msgIdx == 3726 then
		if not BoothDb:isBot(玩家数据[arg].摊位id) then
			return false
		end

		local bot = BoothDb:getBotById(玩家数据[arg].摊位id)

		if ctx.bb == nil then
			self:buyItem(id, arg, ctx.道具, ctx.数量)
		elseif ctx.道具 == nil then
			self:buyBB(arg, ctx.bb)
		end

		玩家数据[arg].摊位查看 = os.time() + 1
		玩家数据[arg].摊位id = bot.bot.id

		发送数据(玩家数据[arg].连接id, 3520, 玩家数据[arg].角色.数据.银子)
		发送数据(玩家数据[arg].连接id, 3522, {
			bb = bot:getBBTable(),
			物品 = bot:getItemTable(),
			id = bot.bot.id,
			摊主名称 = bot.bot.摊位名称,
			名称 = bot.bot.名称
		})

		return true
	end

	return false
end

function BoothCtrl:initAddTime(arr)
	self.time_create = arr[1]
	self.create_num = arr[2]
end

function BoothCtrl:sendBoothBot(mapId, cid)
	BoothDb:sendBoothBot(mapId, cid)
end

function BoothCtrl:sendMsg2Map(序号, 内容, 地图)
	for n, v in pairs(地图处理类.地图玩家[地图]) do
		发送数据(玩家数据[n].连接id, 序号, 内容)
	end
end

return BoothCtrl
