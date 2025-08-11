local default_animation = { 12, 13 }
local super_bullet_animation = { 43, 44 }

function init_bullets()
  bullets = {}
end

function spawn_bullet(x, y, direction, animation)
  y = y or ship.y - 8
  direction = direction or direction or { x = 0, y = 4 }
  animation = animation or default_animation

  add(bullets, {
    x = x,
    y = y,
    -- TODO maybe use different collision boxes
    -- although I didn't notice it is necessary
    r = 2,
    c = { x = 0, y = -2 },
    animation = animation,
    direction = direction
  })

  play_sound(0)
end

function spawn_super_bullet(x, y, direction)
  spawn_bullet(x, y, direction, super_bullet_animation)
end

function spawn_super_bullets(x, y)
  local bullet_positions = {
    { x = x - 9, y = y },
    { x = x - 6, y = y - 2 },
    { x = x - 3, y = y - 4 },
    { x = x,     y = y - 6 },
    { x = x + 3, y = y - 4 },
    { x = x + 6, y = y - 2 },
    { x = x + 9, y = y }
  }
  local bullet_directions = {
    { x = 4,  y = 2 },
    { x = 3,  y = 3 },
    { x = 2,  y = 4 },
    { x = 0,  y = 4.5 },
    { x = -2, y = 4 },
    { x = -3, y = 3 },
    { x = -4, y = 2 }
  }

  for i = 1, #bullet_positions do
    local position = bullet_positions[i]
    local direction = bullet_directions[i]
    spawn_super_bullet(position.x, position.y, direction)
  end
end

function update_bullets()
  for i = #bullets, 1, -1 do
    local bullet = bullets[i]
    bullet.x = bullet.x - bullet.direction.x
    bullet.y = bullet.y - bullet.direction.y
    if bullet.y < 0 then
      del(bullets, bullet)
    end
  end
end

function draw_bullets()
  for i = 1, #bullets do
    local bullet = bullets[i]
    animate(bullet.animation, bullet.x, bullet.y, 10)
    -- draw_col(bullet)
  end
end
