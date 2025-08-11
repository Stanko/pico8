local default_animation = { 14, 15 }

function spawn_enemy_bullet(x, y, direction, animation)
  direction = direction or direction or { x = 0, y = -5 }
  animation = animation or default_animation

  add(enemy_bullets, {
    x = x,
    y = y,
    r = 2,
    c = { x = 0, y = 0 },
    animation = animation,
    direction = direction,
  })

  play_sound(0)
end

function update_enemy_bullets()
  for i = #enemy_bullets, 1, -1 do
    local bullet = enemy_bullets[i]
    bullet.x = bullet.x - bullet.direction.x
    bullet.y = bullet.y - bullet.direction.y
    if bullet.y < 0 then
      del(bullets, bullet)
    end
  end
end

function draw_enemy_bullets()
  for i = 1, #enemy_bullets do
    local bullet = enemy_bullets[i]
    animate(bullet.animation, bullet.x, bullet.y, 10)
    -- draw_col(bullet)
  end
end
