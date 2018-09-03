local DungeonGeneratorUtils = class("DungeonGeneratorUtils")
--public static Vector2 pointInCircle (float radius, Vector2 out) 
function DungeonGeneratorUtils.pointInCircle(radius)
    return DungeonGeneratorUtils.pointInEllipse(radius * 2, radius * 2);
end

-- public static Vector2 pointInEllipse (float width, float height, Vector2 out) {
function DungeonGeneratorUtils.pointInEllipse(width, height)
    --在圆内随机一点
    local t = 2*math.pi*math.random()
    local u = math.random()+math.random()
    local r = nil
    if u > 1 then r = 2-u else r = u end
    return width*r*math.cos(t)/2, height*r*math.sin(t)/2
end

-- public static Vector2 roundedPointInEllipse (float width, float height, float size, Vector2 out) {
function DungeonGeneratorUtils.roundedPointInEllipse(width, height, size)
    --在圆内随机一点后再使用函数控制x，y坐标可以整除size
    local x, y = DungeonGeneratorUtils.pointInEllipse(width, height)
    x = DungeonGeneratorUtils.roundToSize1(x, size)
    y = DungeonGeneratorUtils.roundToSize1(y, size)
    return x, y
end

-- public static Vector2 roundToSize (float value, float size) {
function DungeonGeneratorUtils.roundToSize1(value, size)
    --保证vale能整除size math.round四舍五入
    return ((math.floor(value / size + 0.99)) * size)
end

-- public static Vector2 roundToSize (Vector2 value, float size) {
function DungeonGeneratorUtils.roundToSize2(value, size)
    value.x = DungeonGeneratorUtils.roundToSize1(value.x, size);
    value.y = DungeonGeneratorUtils.roundToSize1(value.y, size);
    return value;
end

-- 原版从这里开始下面这几个函数真正的意义真没看懂，尤其是timeUtils.millis()的取值，TimeUtils.millis()为libgdx框架中的api
-- 在原版http://piotrjastrzebski.io/dungen/dungen/中  完全不懂grid对roomwidth的影响在哪
-- 原版调用roundedRngFloat时参数为 room_width, girdsize, girdsize.  这里真心看不懂grid的值对最终room_width影响是什么

-- private static Random rng = new Random(TimeUtils.millis());//我猜是获取当前毫秒 也就是0～999 但大概率不是

function DungeonGeneratorUtils.rngFloat1()
    --return (float)(rng.nextGaussian());
    return math.random(-qy.DungeonGeneratorConfig.roomWidth / 2, qy.DungeonGeneratorConfig.roomWidth / 2)
end

-- public static float rngFloat (float mean) 
function DungeonGeneratorUtils.rngFloat2(mean)
    return mean + DungeonGeneratorUtils.rngFloat1()
end

-- public static float rngFloat (float mean, float scale) 
function DungeonGeneratorUtils.rngFloat3(mean, scale)
    --获得一个随机的长度
    return (mean + DungeonGeneratorUtils.rngFloat1()) * scale;
end

-- public static float roundedRngFloat (float mean, float scale, float size) {
function DungeonGeneratorUtils.roundedRngFloat(mean, scale, size)
    --获取一个能整除网格大小（size，girdsize）的数
    return DungeonGeneratorUtils.roundToSize1(DungeonGeneratorUtils.rngFloat3(mean, scale), size)
end

-- 模拟libgdx中的MathUtils.isEqual(a, b) 判断2个数是否几乎相同
function DungeonGeneratorUtils.mathIsEqual(a, b)
    return math.floor(a * 100) == math.floor(b * 100)
end

-- 模拟libgdx中的MathUtils.randomBooleanValue
function DungeonGeneratorUtils.randomBoolean()
    return math.floor(math.random() * 2) == 1 and true or false
end


function DungeonGeneratorUtils.overlap(sprite1, sprite2)
    local x1, y1 = sprite1:getPosition()
    local rect1 = cc.rect(x1, y1, sprite1:getScaleX(), sprite1:getScaleY())

    local x2, y2 = sprite2:getPosition()
    local rect2 = cc.rect(x2, y2, sprite2:getScaleX(), sprite2:getScaleY())

    return cc.rectIntersectsRect(rect1, rect2)
end


return DungeonGeneratorUtils
