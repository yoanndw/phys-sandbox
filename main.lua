local MAP_W = 30
local MAP_H = 50

local TILE_SZ = 10

local SAND = 1
local WATER = 2

local BORDER_COLOR = { 1, 1, 1, 0.3 }

local COLORS = {
    { 255/255, 209/255, 112/255 },
    { 0, 0, 1 }
}

local TIMER = 0.1

local map = {}

function pixelToTiles(x)
    return math.floor(x / TILE_SZ) + 1
end

function betweenII(val, min, max)
    return val >= min and val <= max
end

function inBounds(x, y)
    return betweenII(x, 1, MAP_W) and betweenII(y, 1, MAP_H)
end

function isEmpty(x, y)
    if not inBounds(x, y) then
        return false
    end

    return map[y][x] == 0
end

function initMap()
    map = {}
    for i = 1, MAP_H do
        map[i] = {}
        for j = 1, MAP_W do
            map[i][j] = 0
        end
    end
end

function Block(x, y, type)
    local b = {
        x = x,
        y = y,
        type = type
    }

    map[b.y][b.x] = type

    function b:updatePos()
        map[self.y][self.x] = self.type
    end

    -- Check if it's empty at (x + dx, y + dy)
    function b:check(dx, dy)
        return isEmpty(self.x + dx, self.y + dy)
    end

    function b:move(dx, dy)
        if self:check(dx, dy) then
            map[self.y][self.x] = 0

            self.x = self.x + dx
            self.y = self.y + dy

            self:updatePos()
        end
    end

    -- Sand block fall:
    --  * If empty down: fall down
    --  * Else: first fall left, then right if left not empty
    function b:moveSand()
        if self:check(0, 1) then
            self:move(0, 1)
        elseif self:check(-1, 1) then -- look bottom-left
            self:move(-1, 1)
        elseif self:check(1, 1) then -- look bottom-right
            self:move(1, 1)
        end
    end

    function b:update()
        if self.type == SAND then
            self:moveSand()
        end
    end

    return b
end

function drawMap()
    for i = 1, MAP_H do
        for j = 1, MAP_W do
            local x = (j - 1) * TILE_SZ
            local y = (i - 1) * TILE_SZ

            love.graphics.setColor(BORDER_COLOR)
            love.graphics.rectangle("line", x, y, TILE_SZ, TILE_SZ)

            local tile = map[i][j]
            if tile ~= 0 then
                local color = COLORS[tile]
                love.graphics.setColor(color)

                love.graphics.rectangle("fill", x, y, TILE_SZ, TILE_SZ)
            end
        end
    end
end

local blocks = {}
local moveTimer = TIMER

function createBlock(x, y, type)
    local b = Block(x, y, type)

    table.insert(blocks, b)
end

function updateBlocks()
    for _, b in pairs(blocks) do
        b:update()
    end
end

function love.load()
    love.window.setMode(MAP_W * TILE_SZ, MAP_H * TILE_SZ)

    initMap()
end

function love.update(dt)
    moveTimer = moveTimer - dt

    if moveTimer <= 0 then
        updateBlocks()
        moveTimer = TIMER
    end
end

function love.draw()
    drawMap()
end

function love.mousepressed(x, y, button, istouche, presses)
    local gridX = pixelToTiles(x)
    local gridY = pixelToTiles(y)

    if isEmpty(gridX, gridY) then
        createBlock(gridX, gridY, SAND)
    end
end

function love.keypressed(key)

end