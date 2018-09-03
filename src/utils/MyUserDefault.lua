local MyUserDefault = {}

--[[--
--获取用户头像
-- headImg :后端给的 head_img 字段
--]]
function MyUserDefault.getString(key, default_value)
	print("_________UserDefault__________")
	print("key 			:", tostring(key))
	print("default_value:", default_value)

	if default_value == nil then default_value = "" end

	local value = cc.UserDefault:getInstance():getStringForKey(tostring(key), default_value)
	print("value 		:", value)
end

return MyUserDefault
