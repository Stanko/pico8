function init_enemies()
  enemies = {}

  for i = 1, 5 do
    -- spawn first wave of enemies a bit further away -> from -192 to -128
    local y = -random_int(128, 192)
    spawn_enemy(y)
  end
end

function spawn_enemy(y)
  if rnd(1) > 0.5 then
    spawn_enemy_fighter(y)
  else
    spawn_enemy_bomber(y)
  end
end

function spawn_enemy_bomber(y)
  local x = random_int(8, 120) -- 8 padding on each side
  local speed = random(1, 3)

  y = y or flr(rnd(128)) * -1

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

function update_enemy_bomber(enemy, i)
  enemy.y = enemy.y + enemy.speed

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

function spawn_enemy_fighter(y)
  local x = random_int(8, 120) -- 8 padding on each side
  local x_movement = random_int(16, 48);
  local speed = random(3, 5)

  if rnd(1) > 0.5 then
    x_movement = x_movement * -1
  end

  y = y or flr(rnd(128)) * -1

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

    -- TODO update
  })
end

function update_enemy_fighter(enemy, i)
  local delta = frame - enemies[i].start_frame
  local s = sin(delta * 0.01)
  enemy.y = enemy.y + enemy.speed
  enemy.x = enemy.start_x + s * enemy.x_movement

  if (s > 0.1) then
    enemy.dir = "right"
  elseif (s < -0.1) then
    enemy.dir = "left"
  else
    enemy.dir = "still"
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

        -- local rotation_speed = rnd(1) + 1

        -- local pickup_options = {
        --   {
        --     condition = ship.power < 3,
        --     type = "power",
        --     sprite = { 80, 81 },
        --   },
        --   {
        --     condition = ship.lives < 3,
        --     type = "hp",
        --     sprite = { 29, 30 },
        --   },
        --   {
        --     condition = ship.super < 3,
        --     type = "super",
        --     sprite = { 96, 97 },
        --   }
        -- }

        -- local p = rnd(pickup_options)

        -- local radius = flr(rnd(5)) + 17
        -- if (rnd(1) > 0.5) then
        --   radius = radius * -1
        -- end

        -- if (p.condition and rnd(1) > 0.8) then
        --   add(pickups, {
        --     center = { x = enemy.x - cos(frame * 0.01 * rotation_speed) * radius, y = enemy.y - sin(frame * 0.01 * rotation_speed) * radius },
        --     radius = radius,
        --     x = enemy.x,
        --     y = enemy.y,
        --     type = p.type,
        --     sprite = p.sprite,
        --     speed = 1,
        --     rotation_speed = rotation_speed,
        --     r = 5,
        --     c = { x = 0, y = 0 },
        --   })
        -- elseif (#sts.deck <= 17) and rnd(1) > 0.98 then
        --   -- user starts with 14 cards, and can add only 3 more
        --   local cards_options = {
        --     {
        --       type = "weak",
        --       sprite = { card_sprites.weak }
        --     },
        --     {
        --       type = "super",
        --       sprite = { card_sprites.super }
        --     },
        --     {
        --       type = "bash",
        --       sprite = { card_sprites.bash }
        --     }
        --   }
        --   local card = rnd(cards_options)

        --   add(pickups, {
        --     center = { x = enemy.x - cos(frame * 0.01 * rotation_speed) * radius, y = enemy.y - sin(frame * 0.01 * rotation_speed) * radius },
        --     radius = radius,
        --     x = enemy.x,
        --     y = enemy.y,
        --     type = card.type,
        --     sprite = card.sprite,
        --     speed = 1,
        --     rotation_speed = rotation_speed,
        --     r = 6,
        --     c = { x = 0, y = 0 },
        --   })
        -- end
        break
      end
    end
  end
end

function update_enemies()
  for i = #enemies, 1, -1 do
    local enemy = enemies[i]

    if enemy.type == "fighter" then
      update_enemy_fighter(enemy, i)
    elseif enemy.type == "bomber" then
      update_enemy_bomber(enemy, i)
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
