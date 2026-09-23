取正常地图 = function(id)
	if id >= 1600 and id <= 1620 then
		return false
	elseif id == 5001 or id == 5003 then
		return false
	elseif id >= 3000 and id <= 3150 then
		return false
	elseif id >= 6003 and id <= 6009 then
		return false
	elseif id >= 6010 and id <= 6019 then
		return false
	elseif id == 6020 then
		return false
	end

	return true
end

场景置换 = {
	[34480] = {
		1042,
		"双叉岭"
	},
	[34481] = {
		1002,
		"观音寺"
	},
	[34482] = {
		1210,
		"黑风山"
	},
	[34483] = {
		1215,
		"黑风洞"
	},
	[6036] = {
		1514,
		"花果山前"
	},
	[6037] = {
		1122,
		"地府"
	},
	[6038] = {
		1111,
		"天庭"
	},
	[6039] = {
		1009,
		"七宝玲珑塔"
	}
}
地图名称转地图id列表 = {
	凌云渡 = 1920,
	傲来钱庄 = 1099,
	傲来杂货 = 1105,
	女儿村村长家 = 1143,
	傲来武器店 = 1101,
	龙窟二层 = 1178,
	狮王洞 = 1134,
	锦绣饰品店 = 1017,
	江南野外 = 1193,
	须弥东界 = 1242,
	东海海底 = 1507,
	龙宫 = 1116,
	江州府 = 1168,
	观星台 = 1223,
	方寸山 = 1135,
	无名鬼城 = 1202,
	比丘国 = 1232,
	琉璃殿 = 1156,
	女儿村 = 1142,
	老雕洞 = 1133,
	战神山 = 1205,
	傲来国客栈 = 1093,
	地狱迷宫一层 = 1127,
	海底迷宫三层 = 1120,
	民居内室 = 1534,
	月宫 = 1114,
	龙窟一层 = 1177,
	长寿村 = 1070,
	水晶宫 = 1117,
	龙窟四层 = 1180,
	阴曹地府 = 1122,
	小雷音寺 = 1204,
	建邺兵铁铺 = 1502,
	凤巢五层 = 1190,
	高老庄大厅 = 1170,
	凌霄宝殿 = 1112,
	凤巢四层 = 1189,
	解阳山 = 1042,
	海底迷宫四层 = 1121,
	碗子山 = 1228,
	大唐官府 = 1198,
	五庄观 = 1146,
	一级帮派青龙堂_门左 = 1860,
	海蓝系华宅 = 1414,
	海底迷宫二层 = 1119,
	精锐组 = 6003,
	程咬金府 = 1054,
	凤巢七层 = 1192,
	留香阁 = 1033,
	梦战岩洞 = 6045,
	国子监书库 = 1026,
	金銮殿 = 1044,
	比武场 = 1197,
	傲来服饰店 = 1095,
	地狱迷宫四层 = 1130,
	光华殿 = 1528,
	琅嬛福地 = 1212,
	凌霄殿 = 6042,
	灵感之腹 = 6030,
	海蓝系民宅 = 1413,
	海底迷宫五层 = 1532,
	大象洞 = 1132,
	桃源村 = 1003,
	女魃墓 = 1249,
	潮音洞 = 1141,
	炼焰谷地 = 1213,
	天鸣洞天 = 16050,
	["二、三级帮派聚义堂_门右"] = 1873,
	庭院 = 1885,
	凤巢六层 = 1191,
	长寿村服装店 = 1083,
	龙窟五层 = 1181,
	四方城 = 7001,
	花果山 = 1514,
	凤巢二层 = 1187,
	一级帮派书院_门右 = 1821,
	李记布庄 = 1503,
	普通庭院 = 1420,
	普陀山 = 6028,
	中级庭院 = 1341,
	蟠桃园 = 1511,
	一级帮派金库_门左 = 1810,
	张记布庄 = 1022,
	帮派金库 = 1815,
	长安酒店一楼 = 1028,
	长寿村神庙 = 1082,
	["二、三级帮派金库_门左"] = 1812,
	灵台宫 = 1137,
	一级帮派金库_门右 = 1811,
	乾坤殿 = 1147,
	崔府正厅 = 7002,
	盘丝洞 = 1144,
	海蓝系豪宅 = 1415,
	长安酒店二楼 = 1029,
	["二、三级帮派书院_门左"] = 1822,
	["二、三级帮派书院_门右"] = 1823,
	首席争霸 = 6009,
	东海湾 = 1506,
	["二、三级帮派兽室_门左"] = 1832,
	大雁塔七层 = 1009,
	凤巢一层 = 1186,
	["二、三级帮派兽室_门右"] = 1833,
	天元组 = 6008,
	一级帮派厢房_门左 = 1840,
	魔王居 = 1145,
	海底迷宫一层 = 1118,
	神木屋 = 1154,
	一级帮派厢房_门右 = 1841,
	["二、三级帮派厢房_门左"] = 1842,
	["二、三级帮派厢房_门右"] = 1843,
	墨家禁地 = 1221,
	一级帮派兽室_门右 = 1831,
	乌鸡国皇宫 = 6002,
	帮派厢房_ = 1845,
	小西天 = 1203,
	一级帮派药房_门左 = 1850,
	大雁塔一层 = 1004,
	高级华宅 = 1411,
	一级帮派药房_门右 = 1851,
	["二、三级帮派药房_门左"] = 1852,
	["二、三级帮派药房_门右"] = 1853,
	帮派药房 = 1855,
	长寿村钱庄 = 1081,
	["副本-花果山"] = 6033,
	一级帮派青龙堂_门右 = 1861,
	回春堂药店 = 1016,
	["二、三级帮派青龙堂_门左"] = 1862,
	轮回司 = 1125,
	["二、三级帮派青龙堂_门右"] = 1863,
	大雁塔二层 = 1005,
	顶级豪宅 = 7003,
	帮派青龙堂 = 1865,
	一级帮派聚义堂_门右 = 1871,
	天宫 = 1111,
	["二、三级帮派聚义堂_门左"] = 1872,
	朱紫国皇宫 = 1209,
	水帘洞 = 1103,
	蓬莱仙岛 = 1207,
	丝绸之路 = 1235,
	地府 = 6037,
	帮派聚义堂 = 1875,
	波月洞 = 1229,
	长寿郊外 = 1091,
	废弃的御花园 = 6001,
	大雁塔四层 = 1007,
	帮派厢房 = 1844,
	大雁塔三层 = 1006,
	龙窟七层 = 1183,
	大雁塔五层 = 1008,
	一级帮派聚义堂_门左 = 1870,
	勇武组 = 6004,
	神威组 = 6005,
	天启组 = 6007,
	太岁府 = 1211,
	藏经阁 = 1043,
	沉船内室 = 1509,
	沉船 = 1508,
	兜率宫 = 1113,
	长寿村武器店 = 1085,
	天庭 = 6038,
	幻境 = 1400,
	冰风秘境 = 1214,
	一级帮派兽室_门左 = 1830,
	龙窟三层 = 1179,
	傲来国 = 1092,
	三清道观 = 6021,
	无底洞 = 1139,
	凤巢三层 = 1188,
	道观大殿 = 6022,
	东海龙宫 = 34471,
	妖魔巢穴 = 6026,
	水陆道场 = 6024,
	妖怪巢穴 = 5003,
	女娲神迹 = 1201,
	盘丝岭 = 1513,
	墨家村 = 1218,
	通天河底 = 6029,
	大雁塔六层 = 1090,
	冯记铁铺 = 1025,
	花果山前 = 6036,
	钟乳石窟 = 1215,
	子母河底 = 1041,
	仙缘洞天 = 1216,
	帮派兽室 = 1835,
	普通民宅 = 1410,
	七宝玲珑塔 = 6039,
	万宇钱庄 = 1524,
	大唐国境 = 1110,
	神木林 = 1138,
	地狱迷宫三层 = 1129,
	帮派 = 1339,
	西梁女国 = 1040,
	书香斋 = 1019,
	傲来药店 = 1104,
	长安城 = 1001,
	柳林坡 = 1233,
	梦战建邺城 = 6043,
	云来酒店 = 1030,
	宝象国皇宫 = 1227,
	梦战东海湾 = 6044,
	方壶 = 2004,
	一级帮派书院_门左 = 1820,
	傲来圣殿 = 1100,
	龙窟六层 = 1182,
	天科组 = 6006,
	初级庭院 = 1340,
	丞相府 = 1049,
	帮派书院 = 1825,
	鬼市 = 2001,
	普通房屋 = 1332,
	长风镖局 = 1024,
	凌波城 = 1150,
	鬼蜮深渊 = 2007,
	--九黎城 = 2008，
	沧浪墟 = 7004,
	大唐境外 = 1173,
	高小姐闺房 = 1171,
	地藏王府 = 1124,
	狮驼岭 = 1131,
	森罗殿 = 1123,
	化生寺 = 1002,
	梦战海底 = 6046,
	朱紫国 = 1208,
	建邺城 = 1501,
	["二、三级帮派金库_门右"] = 1813,
	麒麟山 = 1210,
	高级庭院 = 1342,
	武神坛 = 1206,
	广源钱庄 = 1013,
	万胜武器店 = 1020,
	陈家庄 = 6027,
	帮派1 = 5003,
	北俱芦洲 = 1174,
	梦战天宫 = 6040,
	幻境花果山 = 1251,
	金山寺 = 1153,
	合生记 = 1523,
	地狱迷宫二层 = 1128,
	赤水洲 = 1258,
	天机堂 = 1253,
	宝象国 = 1226,
	高老庄 = 34470,
	九霄云外 = 6023,
	["副本-蟠桃园"] = 6031,
	繁华京城 = 6025,
	女魃墓室内 = 1252,
	["副本-瑶池宴"] = 6032,
	东海岩洞 = 1126,
	南岭山 = 1876,
	魔王寨 = 1512,
	建邺衙门 = 1537,
	东升货栈 = 1505,
	["副本-天宫"] = 6035,
	天机城 = 1250,
	梦战兜率宫 = 6041,
	回春堂分店 = 1504
}

for i, v in pairs(场景置换) do
	地图名称转地图id列表[v[2]] = i + 0
end

地图名称转地图id = function(名称)
	local aa = {
		迷宫15层 = 15,
		迷宫7层 = 7,
		迷宫10层 = 10,
		迷宫0层 = 0,
		迷宫17层 = 17,
		迷宫20层 = 20,
		迷宫4层 = 4,
		迷宫6层 = 6,
		迷宫5层 = 5,
		迷宫14层 = 14,
		迷宫9层 = 9,
		迷宫12层 = 12,
		迷宫8层 = 8,
		迷宫18层 = 18,
		迷宫19层 = 19,
		迷宫16层 = 16,
		迷宫2层 = 2,
		迷宫11层 = 11,
		迷宫13层 = 13,
		迷宫1层 = 1,
		迷宫3层 = 3
	}

	if 名称 == "中立区" then
		return 6020
	elseif aa[名称] ~= nil then
		return 1600 + aa[名称]
	elseif string.find(名称, "地宫") then
		local aa = 分割文本(名称, "地宫")[2]
		aa[2] = string.gsub(aa[2], "层", "")

		return tonumber(aa[2]) + 3000 - 1
	end

	return 地图名称转地图id列表[名称]
end

取地图名称 = function(id)
	if 场景置换[id] ~= nil then
		return 场景置换[id][2]
	end

	if id >= 1600 and id <= 1620 then
		return "迷宫" .. id - 1600 .. "层"
	elseif id >= 3000 and id <= 3150 then
		return "地宫" .. id - 3000 + 1 .. "层"
	elseif id >= 6010 and id <= 6019 then
		return "帮派竞赛"
	elseif id == 6020 then
		return "中立区"
	elseif id == 1339 then
		return "帮派"
	elseif id == 1932 then
		return "帮派1"
	elseif id == 1501 then
		return "建邺城"
	elseif id == 1502 then
		return "建邺兵铁铺"
	elseif id == 1503 then
		return "李记布庄"
	elseif id == 1504 then
		return "回春堂分店"
	elseif id == 1505 then
		return "东升货栈"
	elseif id == 1523 then
		return "合生记"
	elseif id == 1524 then
		return "万宇钱庄"
	elseif id == 1526 or id == 1525 or id == 1527 then
		return "建邺民居"
	elseif id == 1534 then
		return "民居内室"
	elseif id == 1537 then
		return "建邺衙门"
	elseif id == 1506 then
		return "东海湾"
	elseif id == 1116 then
		return "龙宫"
	elseif id == 1126 then
		return "东海岩洞"
	elseif id == 1507 then
		return "东海海底"
	elseif id == 1508 then
		return "沉船"
	elseif id == 1509 then
		return "沉船内室"
	elseif id == 1193 then
		return "江南野外"
	elseif id == 1001 or id == 4001 then
		return "长安城"
	elseif id == 1002 then
		return "化生寺"
	elseif id == 1198 then
		return "大唐官府"
	elseif id == 1054 then
		return "程咬金府"
	elseif id == 1004 then
		return "大雁塔一层"
	elseif id == 1005 then
		return "大雁塔二层"
	elseif id == 1006 then
		return "大雁塔三层"
	elseif id == 1007 then
		return "大雁塔四层"
	elseif id == 1008 then
		return "大雁塔五层"
	elseif id == 1090 then
		return "大雁塔六层"
	elseif id == 1009 then
		return "大雁塔七层"
	elseif id == 1028 then
		return "长安酒店一楼"
	elseif id == 1029 then
		return "长安酒店二楼"
	elseif id == 1020 then
		return "万胜武器店"
	elseif id == 1017 then
		return "锦绣饰品店"
	elseif id == 1022 then
		return "张记布庄"
	elseif id == 1030 then
		return "云来酒店"
	elseif id == 1043 then
		return "藏经阁"
	elseif id == 1528 then
		return "光华殿"
	elseif id == 1110 then
		return "大唐国境"
	elseif id == 1104 then
		return "傲来药店"
	elseif id == 1105 then
		return "傲来杂货"
	elseif id == 1150 then
		return "凌波城"
	elseif id == 1116 then
		return "龙宫"
	elseif id == 1117 then
		return "水晶宫"
	elseif id == 1122 then
		return "阴曹地府"
	elseif id == 1140 then
		return "普陀山"
	elseif id == 1092 then
		return "傲来国"
	elseif id == 1101 then
		return "傲来武器店"
	elseif id == 1100 then
		return "傲来圣殿"
	elseif id == 1514 then
		return "花果山"
	elseif id == 1174 then
		return "北俱芦洲"
	elseif id == 1091 then
		return "长寿郊外"
	elseif id == 1177 then
		return "龙窟一层"
	elseif id == 1178 then
		return "龙窟二层"
	elseif id == 1179 then
		return "龙窟三层"
	elseif id == 1180 then
		return "龙窟四层"
	elseif id == 1181 then
		return "龙窟五层"
	elseif id == 1182 then
		return "龙窟六层"
	elseif id == 1183 then
		return "龙窟七层"
	elseif id == 1186 then
		return "凤巢一层"
	elseif id == 1187 then
		return "凤巢二层"
	elseif id == 1188 then
		return "凤巢三层"
	elseif id == 1189 then
		return "凤巢四层"
	elseif id == 1190 then
		return "凤巢五层"
	elseif id == 1191 then
		return "凤巢六层"
	elseif id == 1192 then
		return "凤巢七层"
	elseif id == 1142 then
		return "女儿村"
	elseif id == 1143 then
		return "女儿村村长家"
	elseif id == 1127 then
		return "地狱迷宫一层"
	elseif id == 1128 then
		return "地狱迷宫二层"
	elseif id == 1129 then
		return "地狱迷宫三层"
	elseif id == 1130 then
		return "地狱迷宫四层"
	elseif id == 1118 then
		return "海底迷宫一层"
	elseif id == 1119 then
		return "海底迷宫二层"
	elseif id == 1120 then
		return "海底迷宫三层"
	elseif id == 1121 then
		return "海底迷宫四层"
	elseif id == 1532 then
		return "海底迷宫五层"
	elseif id == 1111 then
		return "天宫"
	elseif id == 1070 then
		return "长寿村"
	elseif id == 1081 then
		return "长寿村钱庄"
	elseif id == 1099 then
		return "傲来钱庄"
	elseif id == 1135 then
		return "方寸山"
	elseif id == 1137 then
		return "灵台宫"
	elseif id == 1223 then
		return "观星台"
	elseif id == 1173 then
		return "大唐境外"
	elseif id == 1153 then
		return "金山寺"
	elseif id == 1168 then
		return "江州府"
	elseif id == 1123 then
		return "森罗殿"
	elseif id == 1124 then
		return "地藏王府"
	elseif id == 1112 then
		return "凌霄宝殿"
	elseif id == 1512 then
		return "魔王寨"
	elseif id == 1145 then
		return "魔王居"
	elseif id == 1141 then
		return "潮音洞"
	elseif id == 1146 then
		return "五庄观"
	elseif id == 1147 then
		return "乾坤殿"
	elseif id == 1131 then
		return "狮驼岭"
	elseif id == 1132 then
		return "大象洞"
	elseif id == 1133 then
		return "老雕洞"
	elseif id == 1134 then
		return "狮王洞"
	elseif id == 1202 then
		return "无名鬼城"
	elseif id == 1201 then
		return "女娲神迹"
	elseif id == 1138 then
		return "神木林"
	elseif id == 1139 then
		return "无底洞"
	elseif id == 1513 then
		return "盘丝岭"
	elseif id == 1144 then
		return "盘丝洞"
	elseif id == 1205 then
		return "战神山"
	elseif id == 1154 then
		return "神木屋"
	elseif id == 1228 then
		return "碗子山"
	elseif id == 1156 then
		return "琉璃殿"
	elseif id == 1103 then
		return "水帘洞"
	elseif id == 1040 then
		return "西梁女国"
	elseif id == 1208 then
		return "朱紫国"
	elseif id == 1209 then
		return "朱紫国皇宫"
	elseif id == 1226 then
		return "宝象国"
	elseif id == 1227 then
		return "宝象国皇宫"
	elseif id == 1235 then
		return "丝绸之路"
	elseif id == 1042 then
		return "解阳山"
	elseif id == 1041 then
		return "子母河底"
	elseif id == 1210 then
		return "麒麟山"
	elseif id == 1211 then
		return "太岁府"
	elseif id == 1242 then
		return "须弥东界"
	elseif id == 1232 then
		return "比丘国"
	elseif id == 1207 then
		return "蓬莱仙岛"
	elseif id == 1229 then
		return "波月洞"
	elseif id == 1233 then
		return "柳林坡"
	elseif id == 1114 then
		return "月宫"
	elseif id == 1231 then
		return "蟠桃园"
	elseif id == 1203 then
		return "小西天"
	elseif id == 1204 then
		return "小雷音寺"
	elseif id == 1218 then
		return "墨家村"
	elseif id == 1221 then
		return "墨家禁地"
	elseif id == 1920 then
		return "凌云渡"
	elseif id == 1016 then
		return "回春堂药店"
	elseif id == 1033 then
		return "留香阁"
	elseif id == 1024 then
		return "长风镖局"
	elseif id == 1026 then
		return "国子监书库"
	elseif id == 1044 then
		return "金銮殿"
	elseif id == 1400 then
		return "幻境"
	elseif id == 1511 then
		return "蟠桃园"
	elseif id == 1197 then
		return "比武场"
	elseif id == 1113 then
		return "兜率宫"
	elseif id == 1095 then
		return "傲来服饰店"
	elseif id == 1093 then
		return "傲来国客栈"
	elseif id == 1083 then
		return "长寿村服装店"
	elseif id == 1085 then
		return "长寿村武器店"
	elseif id == 1082 then
		return "长寿村神庙"
	elseif id == 1003 then
		return "桃源村"
	elseif id == 1013 then
		return "广源钱庄"
	elseif id == 1019 then
		return "书香斋"
	elseif id == 1025 then
		return "冯记铁铺"
	elseif id == 1249 then
		return "女魃墓"
	elseif id == 1250 then
		return "天机城"
	elseif id == 1253 then
		return "天机堂"
	elseif id == 1251 then
		return "幻境花果山"
	elseif id == 1252 then
		return "女魃墓室内"
	elseif id == 1258 then
		return "赤水洲"
	elseif id == 1216 then
		return "仙缘洞天"
	elseif id == 16050 then
		return "天鸣洞天"
	elseif id == 1125 then
		return "轮回司"
	elseif id == 1237 then
		return "四方城"
	elseif id == 1876 then
		return "南岭山"
	elseif id == 1212 then
		return "琅嬛福地"
	elseif id == 1213 then
		return "炼焰谷地"
	elseif id == 1214 then
		return "冰风秘境"
	elseif id == 1215 then
		return "钟乳石窟"
	elseif id == 1885 then
		return "庭院"
	elseif id == 1401 then
		return "普通民宅"
	elseif id == 1402 then
		return "高级华宅"
	elseif id == 1403 then
		return "顶级豪宅"
	elseif id == 1404 then
		return "普通民宅"
	elseif id == 1405 then
		return "高级华宅"
	elseif id == 1406 then
		return "顶级豪宅"
	elseif id == 1407 then
		return "普通民宅"
	elseif id == 1408 then
		return "高级华宅"
	elseif id == 1409 then
		return "顶级豪宅"
	elseif id == 1410 then
		return "普通民宅"
	elseif id == 1411 then
		return "高级华宅"
	elseif id == 1412 then
		return "顶级豪宅"
	elseif id == 1413 then
		return "海蓝系民宅"
	elseif id == 1414 then
		return "海蓝系华宅"
	elseif id == 1415 then
		return "海蓝系豪宅"
	elseif id == 1420 then
		return "普通庭院"
	elseif id == 1421 then
		return "中级庭院"
	elseif id == 1422 then
		return "高级庭院"
	elseif id == 1810 then
		return "一级帮派金库_门左"
	elseif id == 1811 then
		return "一级帮派金库_门右"
	elseif id == 1812 then
		return "二、三级帮派金库_门左"
	elseif id == 1813 then
		return "二、三级帮派金库_门右"
	elseif id == 1814 then
		return "帮派金库"
	elseif id == 1815 then
		return "帮派金库"
	elseif id == 1820 then
		return "一级帮派书院_门左"
	elseif id == 1821 then
		return "一级帮派书院_门右"
	elseif id == 1822 then
		return "二、三级帮派书院_门左"
	elseif id == 1823 then
		return "二、三级帮派书院_门右"
	elseif id == 1824 then
		return "帮派书院"
	elseif id == 1825 then
		return "帮派书院"
	elseif id == 1830 then
		return "一级帮派兽室_门左"
	elseif id == 1831 then
		return "一级帮派兽室_门右"
	elseif id == 1832 then
		return "二、三级帮派兽室_门左"
	elseif id == 1833 then
		return "二、三级帮派兽室_门右"
	elseif id == 1834 then
		return "帮派兽室"
	elseif id == 1835 then
		return "帮派兽室"
	elseif id == 1840 then
		return "一级帮派厢房_门左"
	elseif id == 1841 then
		return "一级帮派厢房_门右"
	elseif id == 1842 then
		return "二、三级帮派厢房_门左"
	elseif id == 1843 then
		return "二、三级帮派厢房_门右"
	elseif id == 1844 then
		return "帮派厢房"
	elseif id == 1845 then
		return "帮派厢房_"
	elseif id == 1850 then
		return "一级帮派药房_门左"
	elseif id == 1851 then
		return "一级帮派药房_门右"
	elseif id == 1852 then
		return "二、三级帮派药房_门左"
	elseif id == 1853 then
		return "二、三级帮派药房_门右"
	elseif id == 1854 then
		return "帮派药房"
	elseif id == 1855 then
		return "帮派药房"
	elseif id == 1860 then
		return "一级帮派青龙堂_门左"
	elseif id == 1861 then
		return "一级帮派青龙堂_门右"
	elseif id == 1862 then
		return "二、三级帮派青龙堂_门左"
	elseif id == 1863 then
		return "二、三级帮派青龙堂_门右"
	elseif id == 1864 then
		return "帮派青龙堂"
	elseif id == 1865 then
		return "帮派青龙堂"
	elseif id == 1870 then
		return "一级帮派聚义堂_门左"
	elseif id == 1871 then
		return "一级帮派聚义堂_门右"
	elseif id == 1872 then
		return "二、三级帮派聚义堂_门左"
	elseif id == 1873 then
		return "二、三级帮派聚义堂_门右"
	elseif id == 1874 then
		return "帮派聚义堂"
	elseif id == 1875 then
		return "帮派聚义堂"
	elseif id == 6001 then
		return "废弃的御花园"
	elseif id == 6002 then
		return "乌鸡国皇宫"
	elseif id == 6003 then
		return "精锐组"
	elseif id == 6004 then
		return "勇武组"
	elseif id == 6005 then
		return "神威组"
	elseif id == 6006 then
		return "天科组"
	elseif id == 6007 then
		return "天启组"
	elseif id == 6008 then
		return "天元组"
	elseif id == 6009 then
		return "首席争霸"
	elseif id == 1125 then
		return "轮回司"
	elseif id == 6021 then
		return "三清道观"
	elseif id == 6022 then
		return "道观大殿"
	elseif id == 6023 then
		return "九霄云外"
	elseif id == 6024 then
		return "水陆道场"
	elseif id == 6025 then
		return "繁华京城"
	elseif id == 6026 then
		return "妖魔巢穴"
	elseif id == 6027 then
		return "陈家庄"
	elseif id == 6028 then
		return "普陀山"
	elseif id == 6029 then
		return "通天河底"
	elseif id == 6030 then
		return "灵感之腹"
	elseif id == 1340 then
		return "初级庭院"
	elseif id == 1341 then
		return "中级庭院"
	elseif id == 1342 then
		return "高级庭院"
	elseif id == 1332 then
		return "普通房屋"
	elseif id == 6036 then
		return "花果山前"
	elseif id == 6037 then
		return "地府"
	elseif id == 6038 then
		return "天庭"
	elseif id == 5001 then
		return "宝藏山"
	elseif id == 6039 then
		return "七宝玲珑塔"
	elseif id == 6040 then
		return "梦战天宫"
	elseif id == 6041 then
		return "梦战兜率宫"
	elseif id == 6042 then
		return "凌霄殿"
	elseif id == 6043 then
		return "梦战建邺城"
	elseif id == 6044 then
		return "梦战东海湾"
	elseif id == 6045 then
		return "梦战岩洞"
	elseif id == 6046 then
		return "梦战海底"
	elseif id == 7001 then
		return "四方城"
	elseif id == 7002 then
		return "崔府正厅"
	elseif id == 7003 then
		return "顶级豪宅"
	elseif id == 7004 then
		return "沧浪墟"
	elseif id == 34470 then
		return "高老庄"
	elseif id == 34471 then
		return "东海龙宫"
	elseif id == 6031 then
		return "副本-蟠桃园"
	elseif id == 6032 then
		return "副本-瑶池宴"
	elseif id == 6033 then
		return "副本-花果山"
	elseif id == 6035 then
		return "副本-天宫"
	elseif id == 5003 then
		return "妖怪巢穴"
	elseif id == 2001 then
		return "鬼市"
	elseif id == 2004 then
		return "方壶"
	elseif id == 2007 then
		return "鬼蜮深渊"
	elseif id == 2008 then
		return "九黎城"
	elseif id == 1049 then
		return "丞相府"
	elseif id == 1171 then
		return "高小姐闺房"
	elseif id == 1170 then
		return "高老庄大厅"
	elseif id == 1206 then
		return "武神坛"
	elseif id >= 100000 and id <= 400000000 then
		local res = tonumber(string.sub(id, 1, 1))

		if res == 1 then
			return "高级庭院"
		else
			return "室内"
		end
	else
		return "未知地图"
	end
end
