--数字图片的工具类
local NumPicUtils = {}

function NumPicUtils.getNumPicInfoByType(numType)
	if numType == 1 then
		return {
			["numImg"] = "font/num/num_1.png",
			["width"] = 62,
			["height"] = 61,
		}
	elseif numType == 2 then
		return {
			["numImg"] = "font/num/num_2.png",
			["width"] = 81,
			["height"] = 101,
		}
	elseif numType == 3 then
		return {
			["numImg"] = "font/num/num_3.png",
			["width"] = 53,
			["height"] = 56,
		}
	elseif numType == 4 then
		return {
			["numImg"] = "font/num/num_4.png",
			["width"] = 67,
			["height"] = 78,
		}
	elseif numType == 5 then
		return {
			["numImg"] = "font/num/num_5.png",
			["width"] = 48,
			["height"] = 59,
		}
	elseif numType == 6 then
		return {
			["numImg"] = "font/num/num_6.png",
			["width"] = 29,
			["height"] = 38,
		}
	end

	assert(false, qy.TextUtil:substitute(70027, numType))
end


return NumPicUtils
