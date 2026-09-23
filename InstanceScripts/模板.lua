-- @作者: baidwwy
-- @邮箱:  小巷子资源网:vvxxz.com
-- @创建时间:   2022-10-17 21:46:41
-- @最后修改来自: baidwwy
-- @Last Modified time: 2022-10-17 21:47:05
-- @作者: baidwwy
-- @邮箱:  小巷子资源网:vvxxz.com
-- @创建时间:   2022-10-17 20:12:06
-- @最后修改来自: baidwwy
-- @Last Modified time: 2022-10-17 21:45:34
local 模板 = class()


function 模板:初始化(副本ID)
	self.进程=0
	self.地图编号=7001 --关联地图编号
	self.任务类型=201 --任务类型
	self.副本玩家={}
	self.副本ID=副本ID
	self.开始时间=os.time()
end

function 模板:设置副本进程(进程)
	if 进程==nil then
		self.进程=self.进程+1
	end
	if 进程==1 then
	    for n=1,5 do
	      local 任务id=id.."_202_"..os.time().."_"..随机序列.."_"..取随机数(88,99999999).."_1_"..n
	      local xy=地图处理类.地图坐标[self.地图编号]:取随机点()
	      任务数据[任务id]={
	        id=任务id,
	        起始=os.time(),
	        结束=7200,
	        玩家id={},
	        队伍组=任务数据[self.副本ID].队伍组,
	        名称="芭蕉木妖",
	        模型="树怪",
	        变异=true,
	        行走开关=true,
	        x=xy.x,
	        y=xy.y,
	        副本id=id,
	        地图编号=self.地图编号,
	        地图名称=取地图名称(self.地图编号),
	        类型=202,
	        真实副本id = self.副本ID
	      }
	      地图处理类:添加单位(任务id)
	    end
	end
end

function 模板:更新(dt)

end


function 模板:显示()

end

function 模板:添加玩家(id)
	self.副本玩家[#self.副本玩家 + 1]=id
end

function 模板:完成副本(玩家id)
	副本数据.模板.完成[玩家id] = true
end

function 模板:获取地图ID()
	return self.地图编号
end

return 模板