取随机怪 = function(a, b)
	local 临时信息 = 取等级怪(取随机数(a, b))
	local 临时模型 = 取敌人信息(临时信息[取随机数(1, #临时信息)])

	return 临时模型
end

取等级怪 = function(lv)
	local em = {}

	if lv <= 5 then
		em = {
			-500,
			-492,
			-488,
			-480,
			-520,
			-508,
			-516,
			-504,
			-512,
			-484,
			-472,
			-476,
			-496
		}
	elseif lv > 5 and lv <= 15 then
		em = {
			-548,
			-544,
			-528,
			-540,
			-536,
			-524,
			-532
		}
	elseif lv > 15 and lv <= 25 then
		em = {
			-572,
			-568,
			-564,
			-560,
			-556,
			-552
		}
	elseif lv > 25 and lv <= 35 then
		em = {
			-596,
			-592,
			-584,
			-588,
			-600,
			-580,
			-576
		}
	elseif lv > 35 and lv <= 45 then
		em = {
			-692,
			-700,
			-696,
			-688,
			-684
		}
	elseif lv > 45 and lv <= 55 then
		em = {
			-1492,
			-1496,
			-1488,
			-1484
		}
	elseif lv > 55 and lv <= 65 then
		em = {
			-2959,
			-2984,
			-1500,
			-2988,
			-2980,
			-2955
		}
	elseif lv > 65 and lv <= 75 then
		em = {
			-2967,
			-2971,
			-2963,
			-2975,
			-2996,
			-2992,
			-3004,
			-3000
		}
	elseif lv > 75 and lv <= 85 then
		em = {
			-6988,
			-6984,
			-6992,
			-7000,
			-6996
		}
	elseif lv > 85 and lv <= 95 then
		em = {
			-7958,
			-7966,
			-7962,
			-7974,
			-7970
		}
	elseif lv > 95 and lv <= 105 then
		em = {
			-8000,
			-7978,
			-7982,
			-7986
		}
	elseif lv > 105 and lv <= 125 then
		em = {
			-9879,
			-9895,
			-9883,
			-9887,
			-9899,
			-9903,
			-9891,
			-9907
		}
	elseif lv > 125 and lv <= 135 then
		em = {
			-9927,
			-9931,
			-9911,
			-9923,
			-9919,
			-9939,
			-9915,
			-9935
		}
	elseif lv > 135 and lv <= 145 then
		em = {
			-9943,
			-9947,
			-9951,
			-9955
		}
	elseif lv > 145 and lv <= 155 then
		em = {
			-9959,
			-9963,
			-9967,
			-9971,
			-9975,
			-9979,
			-9983,
			-9987
		}
	elseif lv > 155 then
		em = {
			-9991,
			-9995,
			-9999,
			40009,
			30006,
			130006,
			130002,
			30002,
			29998
		}
	end

	return em
end

取等级怪1 = function(lv1, lv2)
	local em = {}

	if lv1 <= 5 and lv2 >= 5 then
		em = {
			-500,
			-492,
			-488,
			-480,
			-520,
			-508,
			-516,
			-504,
			-512,
			-484,
			-472,
			-476,
			-496
		}
	end

	if lv1 <= 15 and lv2 >= 15 then
		em = 列表2加入到列表1(em, {
			-548,
			-544,
			-528,
			-540,
			-536,
			-524,
			-532
		})
	end

	if lv1 <= 25 and lv2 >= 25 then
		em = 列表2加入到列表1(em, {
			-572,
			-568,
			-564,
			-560,
			-556,
			-552
		})
	end

	if lv1 <= 35 and lv2 >= 35 then
		em = 列表2加入到列表1(em, {
			-596,
			-592,
			-584,
			-588,
			-600,
			-580,
			-576
		})
	end

	if lv1 <= 45 and lv2 >= 45 then
		em = 列表2加入到列表1(em, {
			-692,
			-700,
			-696,
			-688,
			-684
		})
	end

	if lv1 <= 55 and lv2 >= 55 then
		em = 列表2加入到列表1(em, {
			-1492,
			-1496,
			-1488,
			-1484
		})
	end

	if lv1 <= 65 and lv2 >= 65 then
		em = 列表2加入到列表1(em, {
			-2959,
			-2984,
			-1500,
			-2988,
			-2980,
			-2955
		})
	end

	if lv1 <= 75 and lv2 >= 75 then
		em = 列表2加入到列表1(em, {
			-2967,
			-2971,
			-2963,
			-2975,
			-2996,
			-2992,
			-3004,
			-3000
		})
	end

	if lv1 <= 85 and lv2 >= 85 then
		em = 列表2加入到列表1(em, {
			-6988,
			-6984,
			-6992,
			-7000,
			-6996
		})
	end

	if lv1 <= 95 and lv2 >= 95 then
		em = 列表2加入到列表1(em, {
			-7958,
			-7966,
			-7962,
			-7974,
			-7970
		})
	end

	if lv1 <= 105 and lv2 >= 105 then
		em = 列表2加入到列表1(em, {
			-8000,
			-7978,
			-7982,
			-7986
		})
	end

	if lv1 <= 125 and lv2 >= 125 then
		em = 列表2加入到列表1(em, {
			-9879,
			-9895,
			-9883,
			-9887,
			-9899,
			-9903,
			-9891,
			-9907
		})
	end

	if lv1 <= 135 and lv2 >= 135 then
		em = 列表2加入到列表1(em, {
			-9927,
			-9931,
			-9911,
			-9923,
			-9919,
			-9939,
			-9915,
			-9935
		})
	end

	if lv1 <= 145 and lv2 >= 145 then
		em = 列表2加入到列表1(em, {
			-9943,
			-9947,
			-9951,
			-9955
		})
	end

	if lv1 <= 155 and lv2 >= 155 then
		em = 列表2加入到列表1(em, {
			-9959,
			-9963,
			-9967,
			-9971,
			-9975,
			-9979,
			-9983,
			-9987
		})
	end

	if lv1 <= 156 and lv2 > 155 then
		em = 列表2加入到列表1(em, {
			-9991,
			-9995,
			-9999,
			40009,
			30006,
			130006,
			130002,
			30002,
			29998
		})
	end

	if lv1 > 180 and lv2 > 180 then
		em = 列表2加入到列表1(em, {
			60147,
			60148,
			60149,
			60150,
			60151,
			60152,
			60153,
			60154,
			60155,
			60156,
			60157,
			60144,
			60146
		})
	end

	return em
end

取场景等级 = function(map)
	if map == 1506 then
		return 1, 7
	elseif map == 1507 then
		return 5, 9
	elseif map == 1508 then
		return 9, 13
	elseif map == 1126 then
		return 5, 12
	elseif map == 1193 then
		return 6, 16
	elseif map == 1004 then
		return 8, 18
	elseif map == 1005 then
		return 12, 22
	elseif map == 1006 then
		return 16, 26
	elseif map == 1007 then
		return 20, 30
	elseif map == 1008 then
		return 24, 34
	elseif map == 1090 then
		return 28, 38
	elseif map == 1110 then
		return 11, 21
	elseif map == 1173 then
		return 20, 30
	elseif map == 1091 then
		return 26, 36
	elseif map == 1512 then
		return 32, 42
	elseif map == 1140 then
		return 36, 46
	elseif map == 1513 then
		return 38, 48
	elseif map == 1131 then
		return 40, 50
	elseif map == 1514 then
		return 29, 39
	elseif map == 1118 then
		return 33, 43
	elseif map == 1119 then
		return 35, 45
	elseif map == 1120 then
		return 37, 47
	elseif map == 1121 then
		return 40, 55
	elseif map == 1532 then
		return 55, 65
	elseif map == 1127 then
		return 33, 43
	elseif map == 1128 then
		return 35, 45
	elseif map == 1129 then
		return 37, 47
	elseif map == 1130 then
		return 40, 55
	elseif map == 1202 then
		return 100, 110
	elseif map == 1174 then
		return 40, 55
	elseif map == 1177 then
		return 42, 52
	elseif map == 1178 then
		return 44, 54
	elseif map == 1179 then
		return 46, 56
	elseif map == 1180 then
		return 48, 58
	elseif map == 1181 then
		return 50, 60
	elseif map == 1182 then
		return 60, 70
	elseif map == 1183 then
		return 80, 90
	elseif map == 1186 then
		return 42, 52
	elseif map == 1187 then
		return 44, 54
	elseif map == 1188 then
		return 46, 56
	elseif map == 1189 then
		return 48, 58
	elseif map == 1190 then
		return 50, 60
	elseif map == 1191 then
		return 70, 80
	elseif map == 1192 then
		return 80, 90
	elseif map == 1201 then
		return 100, 110
	elseif map == 1207 then
		return 130, 145
	elseif map == 1203 then
		return 115, 125
	elseif map == 1204 then
		return 125, 135
	elseif map == 1114 then
		return 40, 50
	elseif map == 1231 then
		return 150, 160
	elseif map == 1221 then
		return 140, 150
	elseif map == 1042 then
		return 80, 90
	elseif map == 1041 then
		return 70, 80
	elseif map == 1210 then
		return 90, 100
	elseif map == 1228 then
		return 130, 140
	elseif map == 1229 then
		return 150, 160
	elseif map == 1233 then
		return 150, 155
	elseif map == 1232 then
		return 155, 160
	elseif map == 1242 then
		return 170, 180
	elseif map == 16050 then
		return 50, 55
	elseif map == 1223 then
		return 50, 55
	elseif map == 1876 then
		return 30, 45
	elseif map == 1920 then
		return 170, 180
	elseif map == 1235 then
		return 90, 100
	elseif map == 2001 then
		return 140, 155
	elseif map == 2004 then
		return 160, 175
	elseif map == 2007 then
		return 170, 180
	elseif map == 1258 then
		return 100, 110
	elseif map == 1216 then
		return 130, 140
	end
end
