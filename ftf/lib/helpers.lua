-- draw multi sprite object
-- sprite - number[][] - sprite matrix representing multi sprite object
function multi_spr(sprite, x, y)
  local x_offset = #sprite[1] * 4
  local y_offset = #sprite * 4

  for d_y = 1, #sprite do
    for d_x = 1, #sprite[d_y] do
      spr(sprite[d_y][d_x], x + (d_x - 1) * 8 - x_offset, y + (d_y - 1) * 8 - y_offset)
    end
  end
end

-- x - number - x position of the sprite
-- y - number - y position of the sprite
-- frames - number[] | number[][][] - frames of the animation (single or multiple sprites per frame)
-- rate - number - rate of the animation (duration of the frame in global frames)
function animate(frames, x, y, rate)
  -- frame index
  local i = flr(frame / rate) % #frames + 1
  -- frame
  local frame = frames[i]

  if (type(frame) == "number") then
    -- single sprite
    spr(frame, x - 4, y - 4)
  else
    -- multi sprite
    multi_spr(frame, x, y)
  end
end

function collision(obj1, obj2)
  local dx = (obj1.x + obj1.c.x) - (obj2.x + obj2.c.x)
  local dy = (obj1.y + obj1.c.y) - (obj2.y + obj2.c.y)
  local dr = obj1.r + obj2.r

  -- check if objects are too far apart to collide
  if abs(dx) > dr or abs(dy) > dr then
    return false
  end

  -- avoiding sqrt calculation
  return dx * dx + dy * dy <= dr * dr
end

-- draws collision circle outline
local col_colors = { 8, 10 }

function draw_col(obj)
  if (COLLISSION_DEBUG) then
    local r = obj.r
    local i = flr(frame / 15) % 2 + 1
    local c = obj.c
    local x1 = obj.x + c.x - r
    local y1 = obj.y + c.y - r
    local x2 = obj.x + r + c.x - 1
    local y2 = obj.y + r + c.y - 1

    -- outter and inner black rings
    oval(x1 - 1, y1 - 1, x2 + 1, y2 + 1, 0)
    oval(x1 + 1, y1 + 1, x2 - 1, y2 - 1, 0)
    -- blinking yellow/red ring
    oval(x1, y1, x2, y2, col_colors[i])
  end
end

function to_string(o)
  if type(o) == "function" then return "function" end
  if o == nil then return "nil" end
  if type(o) == "string" then return o end
  if type(o) == "boolean" then return o and "true" or "false" end
  if type(o) == "number" then return "" .. o end
  if type(o) == "table" then -- recursion
    local str = "{\n"
    for k, v in pairs(o) do
      str = str .. " " .. to_string(k) .. ":" .. to_string(v) .. "\n"
    end
    return str .. "}"
  end
  return "unkown" -- should never show
end

function reverse_table(data)
  local reversed = {}
  for i = #data, 1, -1 do
    add(reversed, data[i])
  end
  return reversed
end

function sort_table_by_field(data, field, desc)
  -- move a partition backwards,
  -- beginning with one sorted element
  for num_sorted = 1, #data - 1 do
    -- value to insert
    local new_val = data[num_sorted + 1]
    local i = num_sorted + 1

    -- shift elements until
    -- we find the insertion point
    while i > 1 and new_val[field] < data[i - 1][field] do
      -- shift up the value we
      -- compared against
      data[i] = data[i - 1]

      -- descend to the next value
      i -= 1
    end

    -- insert here
    data[i] = new_val
  end

  if desc then
    return reverse_table(data)
  end

  return data
end
