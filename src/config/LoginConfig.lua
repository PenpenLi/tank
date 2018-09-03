--[[
    登录相关的配置
    Author: H.X.Sun
    Date: 2015-07-10
]]

local LoginConfig = {}
if qy.product == "sina" then
    LoginConfig.keyForMd5 = "UI45TREWQIOF00AxfmcdtoLHKjn932POI82SSDUNDIX"
elseif qy.product == "oversea" or qy.product == "oversea-test" then
    LoginConfig.keyForMd5 = "UI45POIERTXF00AmcMXKIDSLIjn932WERTXNBVRTUNDIX"
else
    LoginConfig.keyForMd5 = "UI45TREWQXF0AxfmcdtixIjn9n2POIUSDUNDIX"
end

--设备唯一标识
LoginConfig.UUID =cc.UserDefault:getInstance():getStringForKey("uuid", "")

LoginConfig.APP_ID = 2004
LoginConfig.APP_KEY = "6YG6Zq5omA"

--cid
LoginConfig.cid = ""
function LoginConfig.setCid(_cid)
    LoginConfig.cid = _cid
end

--签名
LoginConfig.sign = ""
function LoginConfig.setSign(_sign)
    LoginConfig.sign = _sign
end

return LoginConfig
