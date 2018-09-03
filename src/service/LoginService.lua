--[[
    登陆请求服务
]]

local LoginService = qy.class("LoginService", qy.tank.service.BaseService)

local md5 = require("utils.Md5Util")

local userDefault = cc.UserDefault:getInstance()
local system_name = userDefault:getStringForKey("system_name", "")
local system_version = userDefault:getStringForKey("system_version", "")
local uuid = userDefault:getStringForKey("uuid", "")
local device_model = userDefault:getStringForKey("device_model", "")

-- 手机平台
local platform = device.platform == "mac" and "ios" or device.platform
-- 渠道
local channel = qy.tank.utils.SDK:channel()
-- 渠道编号
local channelCode = qy.tank.utils.SDK:channelCode()

local loginModel =  qy.tank.model.LoginModel

function LoginService:login(onSuccess,onError,ioError)
    -- self.userInfo = qy.tank.model.UserInfoModel
    local playerInfoEntity = loginModel:getPlayerInfoEntity()
    -- qy.tank.command.MainCommand:viewRedirectByModuleType(qy.tank.view.type.ModuleType.SCENE_LOADING)
    local _params = {
            ["platform"] = platform,
            ["channel"] = channel,
            ["d"] = channelCode,
            ["uid"] = playerInfoEntity.platform_user_id_:get(),
            ["s"] = loginModel:getLastDistrictEntity().index,
            ["sessionid"] = playerInfoEntity.session_token,
            ["sign"] = md5.sumhexa(playerInfoEntity.platform_user_id .. qy.LoginConfig.keyForMd5 .. playerInfoEntity.session_token),
            ["os"] = system_name,
            ["os_version"] = system_version,
            ["mac"] = uuid,
            ["phone_model"] = device_model,
            ["idfa"] = require("utils.Analytics"):getIDFA(),
            ["is_visitor"] = loginModel:getPlayerInfoEntity().is_visitor,
        }

    qy.Http.new(qy.Http.Request.new({
        ["m"] = "System.login",
        ["p"] = _params
    }))
    :setShowLoading(false)
    :send(function(response, request)
        qy.LoginConfig.setCid(response.data.cid)
        qy.LoginConfig.setSign(response.data.sign)
        onSuccess(response.data)

    end,onError,ioError)
end

--[[--
--获取服务器列表
--]]
function LoginService:getDistrictList(onSuccess,onError,ioError)
    local playInfo = loginModel:getPlayerInfo()
    local playerInfoEntity = loginModel:getPlayerInfoEntity()

    qy.Http.new(qy.Http.Request.new({
            ["m"] = "system.getServer",
            ["p"] = {
                ["channel"] = channel,
                ["d"] = channelCode,
                ["uid"] = loginModel:getDistrictParams().uid,
                ["sessionid"] = playInfo.token,
                ["mac"] = uuid,
                ["sign"] = md5.sumhexa(playerInfoEntity.platform_user_id .. qy.LoginConfig.keyForMd5 .. playerInfoEntity.session_token),
                ["is_visitor"] = loginModel:getPlayerInfoEntity().is_visitor
            }
        }))
        :setShowLoading(false)
        :send(function(response, request)
            local userinfo = response.data.userinfo
            if userinfo and userinfo.uid then
                playerInfoEntity.platform_user_id = userinfo.uid
            end
            if userinfo and userinfo.nickname then
                playerInfoEntity.nickname = userinfo.nickname
            end
            loginModel:initDistrictList(response.data)
            loginModel:setLastDistrict(response.data.last)
            onSuccess()
        end,onError,ioError)
end


function LoginService:getBindAccountAward(callback)
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "User.bind_award",
        ["p"] = {}
    })):send(function(response, request)
        qy.tank.command.AwardCommand:show(response.data.award)
        loginModel:setBindAccountStatus(1)
        callback(response.data)
    end)
end

--[[
    Facebook账号绑定
]]
function LoginService:bindFacebookAccount(onSuccess,onError,ioError)
    local playInfo = loginModel:getPlayerInfo()
    local playerInfoEntity = loginModel:getPlayerInfoEntity()
    local sdk = qy.tank.utils.SDK
    qy.Http.new(qy.Http.Request.new({
            ["m"] = "system.bindAccount",
            ["p"] = {
                ["channel"] = channel,
                ["d"] = channelCode,
                ["uid"] = sdk.loginData.uid,
                ["sessionid"] = sdk.loginData.token,
                ["mac"] = uuid,
                -- ["sign"] = md5.sumhexa(playerInfoEntity.platform_user_id .. qy.LoginConfig.keyForMd5 .. playerInfoEntity.session_token),
                ["sign"] = md5.sumhexa(uuid .. qy.LoginConfig.keyForMd5 .. uuid),
                ["is_visitor"] = loginModel:getPlayerInfoEntity().is_visitor
            }
        }))
        :setShowLoading(true)
        :send(function(response, request)
            loginModel:updateVisitorStatus(2)

            onSuccess()
        end,onError,ioError)
end


-- 游戏评分
function LoginService:gameScore()
    qy.Http.new(qy.Http.Request.new({
        ["m"] = "user.praise",
    }))
    :setShowLoading(false)
    :send(function(response, request)
    end)
end

return LoginService
