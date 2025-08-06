------------
--- MATH ---
------------

-- random float, exclusive
function random(a, b)
  return rnd(b - a) + a
end

-- random integer, inclusive
function random_int(a, b)
  return flr(rnd(b - a + 1)) + a
end

function pow(x, y)
  result = x

  for i = 2, y do
    result = result * x
  end

  return result
end

--------------
--- HELPERS ---
--------------

function to_string(o)
  if type(o) == "function" then return "function" end
  if o == nil then return "nil" end
  if type(o) == "string" then return o end
  if type(o) == "boolean" then return o and "true" or "false" end
  if type(o) == "number" then return "" .. o end
  if type(o) == "table" then -- recursion
    local str = "{\n"
    for k, v in pairs(o) do
      str = str .. " " .. tostring(k) .. ":" .. tostring(v) .. "\n"
    end
    return str .. "}"
  end
  return "unkown" -- should never show
end

------------
--- GAME ---
------------

debug = ""
frame = 0

function add_movement(obj, x, y, speed, callback)
  local vector = {
    x = x - obj.x,
    y = y - obj.y
  }
  local distance = sqrt(vector.x * vector.x + vector.y * vector.y)
  local unit_vector = {
    x = vector.x / distance,
    y = vector.y / distance
  }

  obj.movement = {
    type = "speed",
    obj = obj,
    x = x,
    y = y,
    speed = speed or 1,
    callback = callback,
    unit_vector = unit_vector,
    distance = distance,
  }
end

function add_movement_over_time(obj, x, y, duration, easing, callback)
  local easing = easing or function(t) return 1 - pow(1 - t, 3) end -- ease out

  obj.movement = {
    type = "time",
    obj = obj,
    x = x,
    y = y,
    start_x = obj.x,
    start_y = obj.y,
    vector = {
      x = x - obj.x,
      y = y - obj.y
    },
    easing = easing,
    start_frame = frame,
    duration = duration,
    callback = callback,
  }
end

update_movement = function(obj)
  if obj.movement then
    update_movement_methods[obj.movement.type](obj, obj.movement)
  end
end

update_movement_methods = {}

update_movement_methods.speed = function(obj, movement)
  local x = movement.x
  local y = movement.y
  local speed = movement.speed or 1

  local vector = {
    x = x - obj.x,
    y = y - obj.y
  }
  local distance = sqrt(vector.x * vector.x + vector.y * vector.y)

  if (distance <= speed) then
    obj.x = x
    obj.y = y
    -- callback
    if movement.callback then
      movement.callback()
    end

    obj.movement = nil
    return
  end

  obj.x += movement.unit_vector.x * speed
  obj.y += movement.unit_vector.y * speed
end

update_movement_methods.time = function(obj, movement)
  local start_x = movement.start_x
  local start_y = movement.start_y
  local vector = movement.vector
  local easing = movement.easing
  local t = (frame - movement.start_frame) / movement.duration;

  if (t >= 1) then
    obj.x = movement.x
    obj.y = movement.y
    -- callback
    if movement.callback then
      movement.callback()
    end

    obj.movement_over_time = nil
    return
  end

  obj.x = start_x + vector.x * easing(t)
  obj.y = start_y + vector.y * easing(t)
end

ball = {
  x = 64,
  y = 64,
  sprite = 0,
  draw = function()
    spr(ball.sprite, ball.x, ball.y)
  end,
  movement = nil,
  update = function()
    update_movement(ball)
  end
}

function _init()
  frame = 0
end

function _update()
  if (btnp(4)) then
    add_movement(ball, random_int(10, 118), random_int(10, 118), 3, function()
      print("Ball moved!")
    end)
  end
  if (btnp(5)) then
    add_movement_over_time(ball, random_int(10, 118), random_int(10, 118), 30, nil, function()
      print("Ball moved over time!")
    end)
  end

  ball.update()

  frame = frame + 1
end

function _draw()
  cls()
  ball.draw()

  print(debug)
end
