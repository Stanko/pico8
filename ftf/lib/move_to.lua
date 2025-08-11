function move_to(obj, x, y, speed, callback)
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

function move_to_over_time(obj, x, y, duration, easing, callback, delay)
  easing = easing or function(t) return 1 - (1 - t) * (1 - t) end -- ease out
  delay = delay or 0

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
    start_frame = frame + delay,
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
      movement.callback = nil
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

  if (t > 0) then
    obj.x = start_x + vector.x * easing(t)
    obj.y = start_y + vector.y * easing(t)
  end

  if (t >= 1) then
    obj.x = movement.x
    obj.y = movement.y
    -- callback
    if movement.callback then
      movement.callback()
      movement.callback = nil
    end

    obj.movement = nil
  end
end
