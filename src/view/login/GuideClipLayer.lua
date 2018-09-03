--[[
    CG片头
    Author: H.X.Sun 
    Date：2015-11-06
]]

local GuideClipLayer = class("GuideClipLayer", qy.tank.view.BaseView)

function GuideClipLayer:ctor(ResPaths,strKeys,needlisten)
    GuideClipLayer.super.ctor(self)
    self._visibleSize = nil -- 屏幕大小size
    self._origin      = nil -- 原点  
    self._nodef      = nil -- 模板(可以响应触摸事件)  
    self._cutSprites  = nil-- 挖掉的那个图(可以响应触摸事件)  
    self._cutNotListenSprites = nil -- 挖掉的那个图(不可以响应触摸事件)  
    self._enableClick = needlisten -- 响应点击事件
    self._visibleSize = cc.Director:getInstance():getVisibleSize()  
    self._origin = cc.Director:getInstance():getVisibleOrigin()
    self:addChild(self:createClip(ResPaths,strKeys,NotListenResPaths,strNotListenKeys),1)
    self:addChild(self:createistenLayer())     
    local ColorLayer = cc.LayerColor:create(cc.c4b(0,0,0,80))
    self:addChild(ColorLayer)
end

function GuideClipLayer:createClip(ResPaths, strKeys,NotListenResPaths,strNotListenKeys)
    local clip = cc.ClippingNode:create()--创建裁剪节点    
    clip:setInverted(true)--设置底板可见    
    clip:setAlphaThreshold(0.0)--设置透明度Alpha值为0

    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,150))  
    clip:addChild(layerColor,8)-- 在裁剪节点添加一个灰色的透明层

    -- 创建模板，也就是你要在裁剪节点上挖出来的那个”洞“是什么形状的
    self._nodef = cc.Node:create()-- 创建模版
    --响应点击事件挖孔
    if ResPaths == nil then 
            print("裁剪节点跟资源个数不对应")
    else
        local nodeSprite= strKeys
        self._cutSprites = cc.Sprite:create(ResPaths[1]) -- 这里使用的那个图标 
        local Pos = cc.p(nodeSprite:getParent():convertToWorldSpace(cc.p(nodeSprite:getPosition())))
        self._cutSprites:setPosition(Pos) -- 设置坐标位置   
        self._nodef:addChild(self._cutSprites)-- 在模版上添加精灵

        local width =  self._cutSprites:getContentSize().width
        local height =  self._cutSprites:getContentSize().height
        local quan = cc.Sprite:create("Resources/login/quan.png")
        quan:setPosition(Pos)
        self:addChild(quan,999)

        quan:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(1.0, 0.5), cc.ScaleTo:create(1.0, 1.0))))
    end

    local Pos = cc.p(0,0)
    self._nodef:setPosition(Pos) -- 设置的坐标的坐标位置上    
    clip:setStencil(self._nodef)-- 设置模版     

    return clip    
end

--按键监听
function GuideClipLayer:createistenLayer()
    local listen_layer = cc.Layer:create()
    -- 注册单点触摸
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerTouchOneByOne:create()--创建一个触摸监听(单点触摸）
     -- 触摸开始
    local function onTouchBegan(touch, event)
        if not self._enableClick then 
            listener:setSwallowTouches(true)
            return true         
        end
        local pos = touch:getLocation() -- 获取触点的位置
        local posnodef = cc.p(self._nodef:getPosition())
        
        local enableSwTc = false
        local rect = self._cutSprites:getBoundingBox()
        rect= {y = rect.y+posnodef.y, x = rect.x + posnodef.x, height = rect.height, width=rect.width}
        if cc.rectContainsPoint(rect,pos) then   
            enableSwTc = true
        end
        
        if enableSwTc then   
            listener:setSwallowTouches(false)  -- 如果触点处于rect中 则事件向下透传 
        else  
            listener:setSwallowTouches(true)  
        end
        
        return true                     -- 必须返回true 后边move end才会被处理
    end
        
    -- 触摸移动
    local function onTouchMoved(touch, event)
        -- print("Touch Moved")
    end

    -- 触摸结束
    local function onTouchEnded(touch, event)
        -- print("Touch Ended")
    end 

    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)

    dispatcher:addEventListenerWithSceneGraphPriority(listener, listen_layer)-- 将listener和listen_layer绑定，放入事件委托中  

    return listen_layer  
end

return GuideClipLayer