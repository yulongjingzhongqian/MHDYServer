local CFile = class()
local ffi = require("ffi")

ffi.getptr = function(p)
	return tonumber(ffi.cast("intptr_t", p))
end

ffi.cdef([[
    void*       fopen(const char*,const char*);
    int         fseek(void*,long,int);
    long        ftell(void*);
    void        rewind(void*);
    int         fread(void*,int,int,void*);
    const char* fgets(void*,int,void*);
    int         fwrite(void*,int,int,void*);
    int         fclose(void*);
    int         feof(void*);

     // 精灵动画的文件头
    typedef struct
    {
        uint16_t Flag;        // 精灵文件标志 SP 0x5053
        uint16_t HLen;        // 文件头的长度 默认为 12
        uint16_t Group;       // 精灵图片的组数，即方向数
        uint16_t Frame;       // 每组的图片数，即帧数
        uint16_t Width;       // 精灵动画的宽度，单位像素
        uint16_t Height;      // 精灵动画的高度，单位像素
        int16_t  Key_X;       // 精灵动画的关键位X
        int16_t  Key_Y;       // 精灵动画的关键位Y
    }WAS_HEADER;
    // 帧的文件头
    typedef struct
    {
        int32_t  Key_X;       // 图片的关键位X
        int32_t  Key_Y;       // 图片的关键位Y
        uint32_t Width;       // 图片的宽度，单位像素
        uint32_t Height;      // 图片的高度，单位像素
    }FRAME;
    typedef struct
    {
        uint32_t R;
        uint32_t G;
        uint32_t B;
    }PalRGB;
    typedef struct //方案
    {
        PalRGB Color[3];
    }PalProgram;
     // 地图的文件头(梦幻、大话2)
    typedef struct
    {
        uint32_t      Flag;       //文件标志
        uint32_t      Width;      //地图宽
        uint32_t      Height;     //地图高
    }MAP_HEADER;
     typedef struct
    {
        char  Flag[4];
        uint32_t  Size;
    }BlockHead;
    typedef struct
    {
        int     X;
        int     Y;
        uint32_t      Width;
        uint32_t      Height;
        uint32_t      Size;   // mask数据大小
    }MaskInfo;
    typedef struct
    {
        int     X;
        int     Y;
        uint32_t  Width;
        uint32_t  Height;
        uint32_t  BlockX;// 块坐标
        uint32_t  BlockY;
        uint32_t  BlockID;
        uint32_t  Offset;//遮罩偏移
    }MaskInfo2;
    typedef struct
    {
        char Flag[4]; // 包裹的标签
        uint32_t Number; // 包裹中的文件数量
        uint32_t Offset; // 包裹中的文件列表偏移位置
    }WDF_HEADER;

    typedef struct
    {
        uint32_t Hash; // 文件的名字散列
        uint32_t Offset; // 文件的偏移
        uint32_t Size; // 文件的大小
        uint32_t Spaces; // 文件的空间
    }FILELIST;
    typedef struct {
        uint32_t    flag;      /* 'FSB4' */
        int32_t     Number; /* number of samples in the file */
        int32_t     shdrsize;   /* size in bytes of all of the sample headers including extended information */
        int32_t     datasize;   /* size in bytes of compressed sample data */
        uint32_t    version;    /* extended fsb version */
        uint32_t    mode;       /* flags that apply to all samples in the fsb */
        char        zero[8];    /* ??? */
        uint8_t     hash[16];   /* hash??? */
    } FSB4_HEADER;
    typedef struct {
        uint16_t    size;
        char        name[30];
        uint32_t    len;
        uint32_t    clen;
        uint32_t    loopstart;
        uint32_t    loopend;
        uint32_t    mode;
        int32_t     deffreq;
        uint16_t    defvol;
        int16_t     defpan;
        uint16_t    defpri;
        uint16_t    channels;
        int32_t     mindistance;
        int32_t     maxdistance;
        int32_t     varfreq;
        uint16_t    varvol;
        int16_t     varpan;
    } FSB4_LIST;
]])

local line, data = nil
local linelen = 0
local datalen = 0
local short = ffi.new("short[1]")
local int = ffi.new("int[1]")
CFile.SEEK_SET = 0
CFile.SEEK_CUR = 1
CFile.SEEK_END = 2

function CFile:初始化(路径, 模式)
	self.fp = ffi.gc(ffi.C.fopen(路径, 模式 or "rb"), ffi.C.fclose)

	if self.fp == nil then
		error("打开失败->\"" .. 路径 .. "\".")
	end
end

function CFile:读入数据(数据, 长度, 重复)
	ffi.C.fread(数据, 长度 or ffi.sizeof(数据), 重复 or 1, self.fp)

	return 数据
end

function CFile:移动读写位置(距离, 起始)
	ffi.C.fseek(self.fp, 距离, 起始 or 0)
end

return CFile
