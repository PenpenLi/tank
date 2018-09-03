local DungeonUtil = class("DungeonUtil")

function DungeonUtil:getSystemWidth()
    local size = cc.Director:getInstance():getWinSize()
    return size.width / size.height * 750
end



function DungeonUtil.isSamePos(p1, p2) return p1.x == p2.x and p1.y == p2.y end


function DungeonUtil.getLine(p1, p2)
    local result = {}
    result.p1 = p1
    result.p2 = p2
    return result
end



--异步延时执行
function DungeonUtil.asynExecute(fun, delay)
    if not delay then
        delay = math.random() / 10
    end 

    local timer = qy.tank.utils.Timer.new(delay, 1,function()       
        fun()
    end)
    
    timer:start()
    return timer
end




--判断是否是数组
function DungeonUtil.isArrayTable(t)
    if type(t) ~= "table" then  
        return false  
    end  
  
    local n = #t  
    for i,v in pairs(t) do  
        if type(i) ~= "number" then  
            return false  
        end  
          
        if i > n then  
            return false  
        end   
    end  
  
    return true   
end


--
function DungeonUtil.getTableLength(t)
    local num = 0
    for k, v in pairs(t) do
        num = num + 1
    end

    return num
end



--创建序列帧动画 path以/结尾
function DungeonUtil.createFrames(path, length, duration, loop, callback, endCallBack)
    if path == nil then return nil end

    local arr = {}
    for i = 1, length do
        -- print(path..i..".png")
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(path..i..".png")
        frame:getTexture():setAliasTexParameters()
        table.insert(arr,frame)
    end

    local animation = cc.Animation:createWithSpriteFrames(arr, duration / length)
    local animate = cc.Animate:create(animation)

    local seq
    if callback then
        seq = cc.Sequence:create(animate,cc.CallFunc:create(callback))
    else
        seq = cc.Sequence:create(animate)
    end

    local rep
    if loop > 0 then
        rep = cc.Repeat:create(seq,loop)
    else
        rep = cc.RepeatForever:create(animate)
    end    

    local action
    if endCallBack then
        action = cc.Sequence:create(rep,cc.CallFunc:create(endCallBack))
    else
        action = rep
    end

    return action
end


--创建一个龙骨动画
function DungeonUtil.createDragonBone(path, name, playName, callback, callbackTime, speedScale)  
    if path == nil then return nil end  

    qy.tank.utils.cache.CachePoolUtil.addArmatureFile(path)
    print(path, name, playName)
    local action = ccs.Armature:create(name)
    action:getAnimation():setSpeedScale(speedScale or 0.5)

    if playName then
        action:getAnimation():play(playName)
    end

    if callback then
        if callbackTime then
            action:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(callbackTime), 
                    cc.CallFunc:create(function(sender)
                        callback(sender)
                    end)
                ))
        else
            action:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
                if movementType == ccs.MovementEventType.complete then
                    armatureBack:runAction(
                        cc.Sequence:create(
                            cc.DelayTime:create(0.01), 
                            cc.CallFunc:create(function(sender)
                                callback(sender)
                            end)
                        )
                    )
                end
            end)
        end
    end

    return action
end


--根据max随机返回一个1到max之间的整数，包含1和max
function DungeonUtil.random(max)
    return math.floor(math.random() * max + 1)
end


--https://www.indienova.com/indie-game-development/probability-and-games-damage-rolls-2/
--非对称性随机  s骰子面数/随机的区间，n数量  要求s乘以n等于100  n最小等于1  s最大为100  n越小随机的越均衡
function DungeonUtil.asymmetryRandom(s, n)
    local result = 0
    n = math.max(1, n)
    s = math.min(100, s)

    for i = 1, n do
        --math.random(10) 区间为1～10  math.random(10 + 1) - 1 区间为1～11再减去1  即0～10
        result = result + math.random(s + 1) - 1
    end

    return result
end



function DungeonUtil.splitByStr(str, char)
    if type(str) == "table" then
        for i = 1, #str do
            str[i] = qy.tank.utils.String.split(str[i], char)
        end
    else
        str = qy.tank.utils.String.split(str, char)
    end
    return str
end

--讲一个table转换为数组table
function DungeonUtil.tableConvert(table1, sort)    
    local result = {}
    for k, v in pairs(table1) do
        result[#result + 1] = v
    end

    if sort and type(sort) == "function" then
        table.sort(result, sort)
    end

    return result
end



function DungeonUtil.blurNode(sp, radius)
    if not tolua.cast(sp,"cc.Node") then
        print("参数sp不是一个节点")
        return
    end

    local vert = [[  
        attribute vec4 a_position;   
        attribute vec2 a_texCoord;   
        attribute vec4 a_color;   
        #ifdef GL_ES    
        varying lowp vec4 v_fragmentColor;  
        varying mediump vec2 v_texCoord;  
        #else                        
        varying vec4 v_fragmentColor;   
        varying vec2 v_texCoord;    
        #endif      
        void main()   
        {  
            gl_Position = CC_PMatrix * a_position;   
            v_fragmentColor = a_color;  
            v_texCoord = a_texCoord;  
        }  
    ]]  
      
    local frag = [[  
        #ifdef GL_ES   
        precision mediump float;   
        #endif   
        varying vec4 v_fragmentColor;   
        varying vec2 v_texCoord;   
        uniform float limit;        // 半径  
        uniform vec2 my_size;       // 纹理大小（宽和高），为了计算周围各点的纹理坐标，必须传入它，因为纹理坐标范围是0~1  
      
        void main(void)   
        {   
            vec2 unit = 1.0 / my_size.xy;   // 单位尺寸  
            float r = limit;                  
            float step = r / 2.0;           // 步长  
      
            float totalWeight = 0.0;        // 总权重  
            vec4 all = vec4(0);             // 所有像素点颜色之和  
              
            // 遍历当前像素点周围的所有像素点，将它们的颜色值相加  
            // 根据像素点距离当前像素点的距离设置权重  
            for(float i = -r; i < r; i += step)  
            {  
                for(float j = -r; j < r; j += step)  
                {  
                    // 权重  
                    float weight = (r - abs(i)) * (r - abs(j));  
                    // 加上该像素点颜色值*权重  
                    all += texture2D(CC_Texture0, v_texCoord + vec2(i * unit.x, j * unit.y)) * weight;   
                    totalWeight += weight;  
                }  
            }  
            // 设置当前像素点的颜色为总颜色之和除以总权重  
            gl_FragColor = all / totalWeight;  
      
        }  
          
    ]]  
    -- 1.创建glProgram  
    local glProgram = cc.GLProgram:createWithByteArrays(vert, frag)  
    -- 2.获取glProgramState  
    local glProgramState = cc.GLProgramState:getOrCreateWithGLProgram(glProgram)  
    -- 3.设置属性值  
    glProgramState:setUniformFloat("limit", radius or 2)  
    -- 4.获取材质的尺寸。self.blur为Sprite  
    local size = sp:getTexture():getContentSizeInPixels()  
      
    glProgramState:setUniformVec2("my_size", cc.p(size.width, size.height))  
    sp:setGLProgram(glProgram)  
    sp:setGLProgramState(glProgramState)  


end


function DungeonUtil.grayNode(node)
    if not tolua.cast(node,"cc.Node") then
        print("参数node不是一个节点")
        return
    end

    local vertDefaultSource = [[

        attribute vec4 a_position;
        attribute vec2 a_texCoord;
        attribute vec4 a_color;

        #ifdef GL_ES
            varying lowp vec4 v_fragmentColor;
            varying mediump vec2 v_texCoord;
        #else
            varying vec4 v_fragmentColor;
            varying vec2 v_texCoord;
        #endif

        void main()
        {
            gl_Position = CC_PMatrix * a_position;
            v_fragmentColor = a_color;
            v_texCoord = a_texCoord;
        }

    ]]

    local pszFragSource = [[

        #ifdef GL_ES
            precision mediump float;
        #endif
        varying vec4 v_fragmentColor;
        varying vec2 v_texCoord;

        void main(void)
        {
            vec4 c = texture2D(CC_Texture0, v_texCoord);
            gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b);
            gl_FragColor.w = c.w;
        }

    ]]

    local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource, pszFragSource)

    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end



function DungeonUtil.glStateRestore(node)
    node:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")))
end


function DungeonUtil.loadingBarAction(bar, percent, duration)
    local count = math.abs(percent - bar:getPercent()) / 1

    -- local timer = qy.Timer.create("loadingBarAction"..oldPercent..percent,function()
    --     if oldPercent > percent then
    --         bar:setPercent(math.min(bar:getPercent() - 3, percent))
    --     else
    --         bar:setPercent(math.max(bar:getPercent() + 3, percent))
    --     end
    -- end,0.05, count)

    -- timer:start()

    local time = duration and duration / (math.abs(sender:getPercent() - percent) / 1) or 0.02
    
    if bar:getPercent() ~= percent then
        bar:stopAllActions()
        bar:runAction(
            cc.Repeat:create(
                cc.Sequence:create(
                    cc.DelayTime:create(time), 
                    cc.CallFunc:create(function(sender)
                        if bar:getPercent() > percent then
                            sender:setPercent(math.max(sender:getPercent() - 1, percent))
                        else
                            sender:setPercent(math.min(sender:getPercent() + 1, percent))
                        end
                    end)
                )
            , count)
        )
    end
end


-- 1资源
-- 2道具
-- 3装备
-- 4钻石
-- 5体力
-- 6金币
-- 7技能
-- 8扎营技能
-- 11英雄
function DungeonUtil.getItemDataById(params)
    local data
    params["id"] = tostring(params["id"])

    -- print(params["type"], params["id"], params["num"])

    if params["type"] == 1 then
        data = clone(qy.Config.resources[params["id"]])
    elseif params["type"] == 2 then
        data = clone(qy.Config.props[params["id"]])
    elseif params["type"] == 3 then
        data = clone(qy.Config.equipment[params["id"]])
    elseif params["type"] == 4 then 
        data = {["name"] = "diamonds_name", ["icon"] = "zuanshi", ["quality"] = 4, ["picture"] = ""}        
    elseif params["type"] == 5 then
        data = {["name"] = "", ["icon"] = "", ["quality"] = 3, ["picture"] = ""}        
    elseif params["type"] == 6 then
        data = {["name"] = "gold_name", ["icon"] = "qianbi", ["quality"] = 3, ["picture"] = "money"}
    elseif params["type"] == 7 then
        
    elseif params["type"] == 8 then
        
    elseif params["type"] == 11 then

    end

    data["resouce_type"] = params["type"]
    data["num"] = params["num"]

    return data
end



function DungeonUtil.dropItem(spriteItems)
    for i = 1, #spriteItems do
        --随机一个-20到20的坐标
        local x = qy.DungeonUtil.random(80) - 40
        local offsetY = qy.DungeonUtil.random(40) - 20
        spriteItems[i]:setVisible(false)
        spriteItems[i]:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(0.05 * i),
                cc.CallFunc:create(function(sender)
                    sender:setVisible(true)
                end),
                cc.MoveBy:create(0.1, cc.p(x, 30)), 
                cc.MoveBy:create(0.3, cc.p(x * 1.5, -150 + offsetY)),
                cc.CallFunc:create(function(sender)
                    sender:showBgLight(true)
                end)
            )
        )
    end
end


function DungeonUtil.getPropertyPrompt(data, body)
    local effectValue   = data["effectValue"]
    print("getPropertyPrompt", data["property"])
    local propertyConfigData = qy.Config.property[string.sub(data["property"], 1, 3)]
    local resultType    = data["resultType"]
    local str           = ""
    local label

    --抵抗
    if data["property"] == "resist" then
        label = ccui.Text:create()
        label:setFontName("Resources/font/ttf/black_body.TTF")
        label:setFontSize(24)
        label:enableOutline(cc.c4b(0,0,0,255), 1)
        label:setColor(cc.c3b(102, 255, 0))
        
        str = qy.TextUtil:substitute("resist")
        return label, str
    end

    if data["property"] == 0 and effectValue == 0 then
        label = ccui.Text:create()
        label:setFontName("Resources/font/ttf/black_body.TTF")
        label:setFontSize(24)
        label:enableOutline(cc.c4b(0,0,0,255), 1)
        label:setColor(cc.c3b(102, 255, 0))
        
        str = qy.TextUtil:substitute("have_stronger")
        return label, str
    end

    if resultType == "crit" and effectValue < 0 then
        label = cc.LabelBMFont:create("", "font/fnt/baoji.fnt")

    elseif string.sub(data["property"], 1, 3) == "134" then
        --血量
        if effectValue > 0 then
            label = cc.LabelBMFont:create("", "font/fnt/zhiliao.fnt")
        else
            label = cc.LabelBMFont:create("", "font/fnt/diaoxue.fnt")
        end

        if tostring(data["property"]) == "13402" then
            effectValue = math.floor(body:getTotalProperty("134") * effectValue / 1000)
        end
    elseif string.sub(data["property"], 1, 3) == "223" then
        --血量
        if effectValue > 0 then
            label = cc.LabelBMFont:create("", "font/fnt/zhiliao.fnt")
        else
            label = cc.LabelBMFont:create("", "font/fnt/diaoxue.fnt")
        end

        effectValue = math.floor(body:getTotalProperty("106") * effectValue / 1000)
    elseif string.sub(data["property"], 1, 3) == "135" then     
        --能量           
        if effectValue > 0 then
            label = cc.LabelBMFont:create("", "font/fnt/nengliang.fnt")
        else
            label = cc.LabelBMFont:create("", "font/fnt/jiannengliang.fnt")
        end

    elseif string.sub(data["property"], 1, 3) == "113" then
        --压力值的变化有龙骨特效
        local effectDragonBone
        if effectValue < 0 then
            label = cc.LabelBMFont:create("", "font/fnt/jianya.fnt")
        else
            label = cc.LabelBMFont:create("", "font/fnt/jiaya.fnt")
        end
    else
        label = ccui.Text:create()
        label:setFontName("Resources/font/ttf/black_body.TTF")
        label:setFontSize(24)
        label:enableOutline(cc.c4b(0,0,0,255), 1)
    end

    if str == "" then
        if propertyConfigData["color_show"] == 1 and effectValue > 0 then
            label:setColor(cc.c3b(102, 255, 0))
        else
            label:setColor(cc.c3b(255, 0, 0))
        end

        local propertyText  = qy.TextUtil:substitute("property_"..data["property"])

        if propertyText == "" and string.len(data["property"]) == 5 then
            propertyText = qy.TextUtil:substitute("property_"..string.sub(data["property"], 1, 3))
        end

        if propertyText ~= "" then
            str = str..propertyText

            if propertyConfigData["display_numbers"] ~= 2 then

                if data["property"] and string.len(data["property"]) == 5 then
                    local isPercent = string.sub(data["property"], 4, 5)
                    if isPercent == "02" or isPercent == "03" or isPercent == "04" or propertyConfigData["property_permillage"] ~= 0 then
                        -- effectValue = string.sub(effectValue, 1, string.len(effectValue) - 1)
                        effectValue = math.floor(effectValue / 10).."%"           
                    end
                end

                if data["effectValue"] > 0 then
                    effectValue = "+"..effectValue
                end

                str = str..effectValue
            end
        end

    end
    print(effectValue)

    return label, str
end

function DungeonUtil.getDate(time,_type)
    local timestamp = time
    if _type == 1 then
        local date=os.date('%Y-%m-%d %H:%M:%S',timestamp)
        return date
    elseif _type == 2 then
        local date=os.date('%m-%d',timestamp)
        return date
    end
    
end


function DungeonUtil.appendNum(str, num)
    if tonumber(num) < 10 then
        return str.."0"..num
    else
        return str..num
    end
end


return DungeonUtil