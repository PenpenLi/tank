--[[
静态配置类
]]

local Config = {
}


-- 懒加载
setmetatable(Config, {
    __index = function(t, k)
        local ok, ret = pcall(function()
            return require("data/" .. k)
        end)

        if ok then
            rawset(t, k, ret)
        end

        return ret
    end
})


return Config
