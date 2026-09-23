local ffi = require("ffi")
local _bor = bit.bor
local _lshift = bit.lshift
local _rshift = bit.rshift
local _band = bit.band
local _copy = ffi.copy
local _cast = ffi.cast
local _new = ffi.new
local _string = ffi.string

local function _修复图片(dst, src, slen)
	local s = 0
	local d = 0
	local dlen = 0

	while s < slen and src[s] == 255 do
		dst[d] = 255
		d = d + 1
		s = s + 1

		if src[s] == 216 then
			dst[d] = src[s]
			d = d + 1
			s = s + 1
		elseif src[s] == 160 then
			d = d - 1
			s = s + 1
		elseif src[s] == 192 or src[s] == 196 or src[s] == 219 then
			dst[d] = src[s]
			d = d + 1
			s = s + 1
			local len = _bor(_lshift(src[s], 8), src[s + 1])

			for i = 1, len do
				dst[d] = src[s]
				d = d + 1
				s = s + 1
			end
		elseif src[s] == 218 then
			dst[d] = 218
			d = d + 1
			dst[d] = 0
			d = d + 1
			dst[d] = 12
			d = d + 1
			s = s + 1
			local len = _bor(_lshift(src[s], 8), src[s + 1]) - 2
			s = s + 2

			for i = 1, len do
				dst[d] = src[s]
				d = d + 1
				s = s + 1
			end

			dst[d] = 0
			d = d + 1
			dst[d] = 63
			d = d + 1
			dst[d] = 0
			d = d + 1

			for i = 1, slen - s do
				if src[s] == 255 then
					dst[d] = 255
					d = d + 1
					dst[d] = 0
					d = d + 1
					s = s + 1
					dlen = dlen + 1
				else
					dst[d] = src[s]
					d = d + 1
					s = s + 1
				end
			end

			dst[d - 2] = 217

			break
		end
	end

	return dlen + slen
end

local function _解压数据(ip, op)
	local t = 0
	local o = 0
	local i = 0
	local m = 0
	local run = 1

	if ip[i] > 17 then
		t = ip[i] - 17
		i = i + 1

		if t < 4 then
			repeat
				op[o] = ip[i]
				o = o + 1
				i = i + 1
				t = t - 1
			until t == 0

			t = ip[i]
			i = i + 1
			run = 0
		else
			repeat
				op[o] = ip[i]
				o = o + 1
				i = i + 1
				t = t - 1
			until t == 0

			run = 2
		end
	end

	while true do
		if run == 1 then
			t = ip[i]
			i = i + 1

			if t < 16 and t == 0 then
				while ip[i] == 0 do
					t = t + 255
					i = i + 1
				end

				t = t + 15 + ip[i]
				i = i + 1
			end
		end

		t = t - 1 + 4

		while run == 1 and t < 16 and t - 1 + 4 do
			repeat
				op[o] = ip[i]
				o = o + 1
				i = i + 1
				t = t - 1
			until t == 0

			run = 2

			if run == 2 then
				run = 1
				t = ip[i]
				i = i + 1
				m = o - 2049 - _rshift(t, 2) - _lshift(ip[i], 2)
				i = i + 1
				op[o] = op[m]
				o = o + 1
				m = m + 1
				op[o] = op[m]
				o = o + 1
				m = m + 1
				op[o] = op[m]
				o = o + 1
				t = _band(ip[-2], 3)
			end
		end

		repeat
			op[o] = ip[i]
			o = o + 1
			i = i + 1
			t = t - 1
		until t == 0

		t = ip[i]
		i = i + 1

		if i + 1 then
			run = 1
		end

		while true do
			if t >= 64 then
				m = o - 1 - _band(_rshift(t, 2), 7) - _lshift(ip[i], 3)
				i = i + 1
				t = _rshift(t, 5) + 1

				repeat
					op[o] = op[m]
					o = o + 1
					m = m + 1
					t = t - 1
				until t == 0

				if false then
					if false then
						if t >= 32 then
							t = _band(t, 31)

							if t == 0 then
								while ip[i] == 0 do
									t = t + 255
									i = i + 1
								end

								t = t + 31 + ip[i]
								i = i + 1
							end

							m = o - 1 - _rshift(_bor(ip[i], _lshift(ip[i + 1], 8)), 2)
							i = i + 2
						else
							m = o - _lshift(_band(t, 8), 11)
							t = _band(t, 7)

							if t == 0 then
								while ip[i] == 0 do
									t = t + 255
									i = i + 1
								end

								t = t + 7 + ip[i]
								i = i + 1
							end

							m = m - _rshift(_bor(ip[i], _lshift(ip[i + 1], 8)), 2)
							i = i + 2

							if m == o then
								return o
							end

							m = m - 16384
							m = o - 1 - _rshift(t, 2) - _lshift(ip[i], 2)
							i = i + 1
							op[o] = op[m]
							o = o + 1
							m = m + 1
							op[o] = op[m]
							o = o + 1
						end
					end

					t = t + 2

					repeat
						op[o] = op[m]
						o = o + 1
						m = m + 1
						t = t - 1
					until t == 0
				end
			end

			t = _band(ip[i - 2], 3)

			if t == 0 then
				break
			end

			repeat
				op[o] = ip[i]
				o = o + 1
				i = i + 1
				t = t - 1
			until t == 0

			t = ip[i]
			i = i + 1
		end
	end
end

local map = class()
local 文件 = require("Script/文件类")
local ceil = math.ceil
local floor = math.floor
local insert = table.insert

function map:初始化(路径)
	self.int = _new("uint32_t[1]")
	self.File = 文件(路径)

	self.File:读入数据(self.int)
	self.File:移动读写位置(0)

	self.Flag = _string(self.int, 4)
	local head = self.File:读入数据(_new("MAP_HEADER"))
	self.Height = head.Height
	self.Width = head.Width
	self.MapRowNum = ceil(head.Height / 240)
	self.MapColNum = ceil(head.Width / 320)
	self.MapNum = self.MapRowNum * self.MapColNum
	self.MapList = self.File:读入数据(_new("uint32_t[?]", self.MapNum))

	self.File:读入数据(self.int)
	self.File:移动读写位置(self.int[0])

	self.MaskNum = self.File:读入数据(self.int)[0]

	if self.MaskNum > 0 then
		self.MaskList = self.File:读入数据(_new("uint32_t[?]", self.MaskNum))
	end

	self.Block = _new("BlockHead")
	self.MInfo = _new("MaskInfo")
	self.Temp = _new("unsigned char[1048576]")
	self.Temp2 = self.Temp + 524288
	self.Mask = _new("unsigned char[524288]")
	self.缓存 = {}
end

function map:取障碍()
	if self.Flag == "0.1M" then
		local Clen = (self.MapColNum - 1) * 16
		local Blen = self.MapColNum * 192
		local n = 0
		local w, c, Flag = nil
		local cell = _new("unsigned char[192]")
		local t1 = self.Temp
		local int = self.int

		for h = 0, self.MapRowNum - 1 do
			for l = 0, self.MapColNum - 1 do
				self.File:移动读写位置(self.MapList[n])

				n = n + 1

				self.File:读入数据(int)

				if int[0] > 0 then
					self.File:移动读写位置(int[0] * 4, self.File.SEEK_CUR)
				end

				repeat
					self.File:读入数据(self.Block)

					Flag = _string(self.Block.Flag, 4)

					if Flag == "LLEC" then
						self.File:读入数据(cell, self.Block.Size)

						w = h * Blen + l * 16
						c = 0

						for hh = 1, 12 do
							for ll = 1, 16 do
								t1[w] = cell[c]
								w = w + 1
								c = c + 1
							end

							w = w + Clen
						end

						break
					elseif Flag == "\0\0\0\0" then
						break
					else
						self.File:移动读写位置(self.Block.Size, self.File.SEEK_CUR)
					end
				until false
			end
		end

		return ffi.getptr(t1), self.MapNum * 192
	end
end

return map
