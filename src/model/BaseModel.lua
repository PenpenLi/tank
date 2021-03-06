--
--

local BaseModel = qy.class("BaseModel", qy.tank.entity.BaseEntity)

function BaseModel:dispatchEvent(name, usedata)
    qy.Event.dispatch(name, usedata)
end

function BaseModel.M(parent, t)
    return setmetatable(t or {}, {__index = parent})
end

return BaseModel
