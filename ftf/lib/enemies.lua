function init_enemies()
  enemies = {}

  for i = 1, 5 do
    -- spawn first wave of enemies a bit further away -> from -192 to -128
    local y = -random_int(128, 192)
    spawn_enemy(y)
  end
end

function spawn_enemy(y)
  local x = random_int(8, 120) -- 8 padding on each side
  y = y or flr(rnd(128)) * -1

  if rnd(1) > 0.5 then
    local x_movement = random_int(16, 48);
    local speed = random(3, 5)

    if rnd(1) > 0.5 then
      x_movement = x_movement * -1
    end

    add(enemies, {
      type = "fighter",

      -- position
      x = x,
      y = y,

      -- movement
      speed = speed,
      x_movement = x_movement,
      start_x = x,
      start_frame = frame,

      -- colission box
      r = 6,
      c = { x = 0, y = 0 },

      -- sprite
      dir = "still",
      sprite = {
        still = { { 6, 7 }, { 22, 23 } },
        right = { { 8, 9 }, { 24, 25 } },
        left = { { 10, 11 }, { 26, 27 } },
      },
    })
  else
    local speed = random(1, 3)
    add(enemies, {
      type = "bomber",

      -- position
      x = x,
      y = y,

      -- movement
      speed = speed,

      -- fire
      wind_up = 0,

      -- collision box
      r = 6,
      c = { x = 0, y = 0 },

      -- sprite
      sprite = { { 137, 138 }, { 153, 154 } },
    })
  end
end

function update_enemies_bullets_collisions()
  -- bullets / enemies collisions
  for bullet_index = #bullets, 1, -1 do
    local bullet = bullets[bullet_index]

    for enemy_index = #enemies, 1, -1 do
      local enemy = enemies[enemy_index]
      if collision(enemy, bullet) then
        enemy.hit = true
        deli(bullets, bullet_index)
        deli(enemies, enemy_index)

        spawn_large_explosion(enemy.x, enemy.y)
        spawn_enemy()
        play_sound(2)

        score += 6

        spawn_pickup(enemy.x, enemy.y)
        break
      end
    end
  end
end

function update_enemies()
  for i = #enemies, 1, -1 do
    local enemy = enemies[i]
    enemy.y = enemy.y + enemy.speed

    if enemy.type == "fighter" then
      local delta = frame - enemies[i].start_frame
      local s = sin(delta * 0.01)
      enemy.x = enemy.start_x + s * enemy.x_movement

      if (s > 0.1) then
        enemy.dir = "right"
      elseif (s < -0.1) then
        enemy.dir = "left"
      else
        enemy.dir = "still"
      end
    elseif enemy.type == "bomber" then
      if enemy.y > 5 and enemy.y < 20 then
        if (rnd(1) > 0.9 and not enemy.shooting) then
          enemy.shooting = true
          add_animation({
            position = enemy,
            offset = { x = 0, y = 8 },
            rate = 3,
            frames = { 40, 41, 42 }
          }, function()
            if (not enemy.hit) then
              spawn_enemy_bullet(enemy.x, enemy.y + 8)
              enemy.shooting = false
            end
          end)
        end
      end
    end

    if enemy.y > 140 then
      deli(enemies, i)

      if (level_state == "shoot_em_up") then
        spawn_enemy()
      end
    end
  end

  update_enemies_bullets_collisions()
end

function draw_enemies()
  for i = 1, #enemies do
    local enemy = enemies[i]

    if enemy.type == "fighter" then
      multi_spr(enemy.sprite[enemy.dir], enemy.x, enemy.y)
    elseif enemy.type == "bomber" then
      multi_spr(enemy.sprite, enemy.x, enemy.y)
    end
  end
end
