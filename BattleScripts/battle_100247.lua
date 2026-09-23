-- @作者: baidwwy
-- @邮箱:  小巷子资源网:vvxxz.com
-- @创建时间:   2022-10-18 23:13:44
-- @最后修改来自: baidwwy
-- @Last Modified time: 2022-10-29 18:11:42
-- @作者: baidwwy
-- @邮箱:  小巷子资源网:vvxxz.com
-- @创建时间:   2022-10-18 21:27:02
-- @最后修改来自: baidwwy
-- @Last Modified time: 2022-10-18 23:13:23
local battle_100247 = class()


function battle_100247:初始化(战斗id)
	self.战斗id=战斗id
end

function battle_100247:战斗准备后()

end

function battle_100247:单位死亡(编号)
	if self.参战单位[编号].名称=="魔族小鬼" and self.参战单位[编号].队伍==0 then
		if self.集火目标==nil then
			self.集火目标=self:取单个敌方目标(编号)
		end
	end
	if self.参战单位[编号].名称=="魔族小妖" and self.参战单位[编号].队伍==0 then
		if self.集火目标==nil then
			self.集火目标=self:取单个敌方目标(编号)
		end
	end
end

function battle_100247:命令回合前(回合数)
	    for n=1,#self.参战单位 do
		--集火事件是临时存的变量，但是是挂在战斗处理类下的，注意这种临时变量不要与战斗处理类里的同名
		if self.参战单位[n].名称=="洛川鬼" then
			if self.集火目标~=nil then
				local 目标名称=self.参战单位[self.集火目标].名称
	    		self:添加即时发言(n,"拜拜了,"..目标名称.."\n杀了我小弟你死定了#4")
			end
		end
    end
end


function battle_100247:NPC智能施法(编号,战斗单位,回合数)
  local 返回数据 = {类型="",目标=0,参数="",下达=false}
  --如果写召唤的话，把技能改成无敌牛虱这类的,在这里施法
  if 战斗单位.名称=="洛川鬼" then
  	if 回合数==1 or 回合数==10 or 回合数==10 or 回合数==20 or 回合数==30 or 回合数==40 or 回合数==50 or 回合数==60 or 回合数==70 or 回合数==80 or 回合数==90 then
	    返回数据.类型="法术"
	    返回数据.目标=self:取单个敌方目标(编号)
	    返回数据.参数="锢魂术"
	    返回数据.下达=true
	elseif self.集火目标~=nil then
	    返回数据.类型="法术"
	    返回数据.目标=self:取单个敌方目标(编号)
	    返回数据.参数="百爪狂杀"
	    返回数据.下达=true
	    self.集火目标=nil
	end
  end
  return 返回数据
end

function battle_100247:战斗胜利(胜利id,失败id)

end

function battle_100247:战斗失败(失败id,是否逃跑,胜利id)
	-- body
end

return battle_100247