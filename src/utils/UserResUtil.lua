--[[
	获取用户资源工具类
	Author: H.X.Sun
    Date: 2015-09-14
]]

local UserResUtil = {}

--[[--
--获取用户头像
-- headImg :后端给的 head_img 字段
--]]
function UserResUtil.getRoleIconByHeadType(headImg)
	if headImg then
        return "Resources/user/icon_" .. headImg .. ".png"
    else
        return "Resources/user/icon_head_1.png"
    end
end

return UserResUtil
