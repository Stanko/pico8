function init_ship()
  ship = {
    -- position
    x = 64,
    y = 100,
    x_dir = "still",
    y_dir = "up",
    movement = nil,

    -- colission box
    r = 4,
    c = { x = 0, y = -1 },

    -- fire
    last_shot = -100,
    shot_delay = 8,

    -- super weapon
    super_last_shot = -100,
    super_shot_delay = 60,

    -- stats
    lives = 3,
    power = 1,
    super = 2,

    -- deck builder
    shield = 0,
    hp = 10,
    max_hp = 10,
    energy = 3,
    max_energy = 3,

    sprite = {
      still = { { 0, 1 }, { 16, 17 } },
      right = { { 2, 3 }, { 18, 19 } },
      left = { { 4, 5 }, { 20, 21 } },
    },

    animation_thrusters = {
      still = {
        still = { 32, 33 },
        up = { 34, 35 },
        down = { { { 36, 37 } }, { { 38, 39 } } }
      },
      right = {
        still = { 48, 49 },
        up = { 49, 50 },
        down = { 53, 54 }
      },
      left = {
        still = { 48, 51 },
        up = { 51, 52 },
        down = { 55, 56 }
      },
    },

    down_offsets = {
      still = { x = 0, y = -4, },
      right = { x = -4, y = -4, },
      left = { x = 4, y = -4, },
    },
  }
end

function ship_hit(obj)
  if ship.lives > 0 then
    ship.lives -= 1
    play_sound(1)

    if (ship.lives == 0) then
      spawn_explosions(ship.x, ship.y, 12, 12, 10, 15)
    else
      spawn_explosion(obj.x, obj.y)
    end
  end
end

function update_ship_shoot_em_up()
  if (ship.lives > 0) then
    -- TODO move to the game controller

    ship.x_dir = "still"
    ship.y_dir = "still"

    local move = { x = 0, y = 0 }

    -- horizontal movement
    if btn(0) == btn(1) then
    elseif btn(0) then
      -- left
      ship.x_dir = "left"
      move.x = -3
    elseif btn(1) then
      -- right
      ship.x_dir = "right"
      move.x = 3
    end

    -- vertical movement
    if btn(2) == btn(3) then
    elseif btn(2) then
      -- up
      ship.y_dir = "up"
      move.y = -3
    elseif btn(3) then
      -- down
      ship.y_dir = "down"
      move.y = 3
    end

    -- set diagonal movement to 2, 2
    -- we can't use flr() as we have both positive and negative numbers
    -- this needs to be manually updated if the ship's speed changes
    if (move.x != 0 and move.y != 0) then
      move.x = move.x / 3 * 2
      move.y = move.y / 3 * 2
    end

    -- move ship
    ship.x += move.x
    ship.y += move.y

    -- limit ship to screen boundaries
    ship.y = max(ship.y, 8)
    ship.y = min(ship.y, 120)
    ship.x = max(ship.x, 8)
    ship.x = min(ship.x, 120)

    -- fire
    if btnp(4) or btn(4) then
      if (frame - ship.last_shot) > ship.shot_delay then
        ship.last_shot = frame

        local bullet_x_positions = {
          { ship.x },
          { ship.x - 4, ship.x + 4 },
          { ship.x - 8, ship.x,    ship.x + 8 }
        }
        local bullet_directions = {
          { { x = 0, y = 4 } },
          { { x = 1, y = 3 }, { x = -1, y = 3 } },
          { { x = 1, y = 3 }, { x = 0, y = 4 }, { x = -1, y = 3 } }
        }

        local positions = bullet_x_positions[ship.power]
        -- local directions = bullet_directions[ship.power]
        for i = 1, #positions do
          -- TODO implement nicer spread
          -- spawn_bullet(positions[i], ship.y - 8, directions[i])
          spawn_bullet(positions[i])
        end

        if (score > 0) then
          score -= ship.power
        end
      end
    end

    -- super
    if btnp(5) then
      if get_super_weapon_progress() == 1 and ship.super > 0 then -- and level_frame > 10
        ship.super_last_shot = frame

        spawn_super_bullets(ship.x, ship.y)

        ship.super -= 1

        if (score > 8) then
          score -= 8
        end
      else
        play_sound(20)
      end
    end

    -- enemy bullets collisions
    for i = #enemy_bullets, 1, -1 do
      local bullet = enemy_bullets[i]

      if collision(bullet, ship) then
        ship_hit(bullet)
        deli(enemy_bullets, i)

        if (ship.power > 1) then
          ship.power -= 1
        end
      end
    end

    -- enemy collisions
    for i = #enemies, 1, -1 do
      local enemy = enemies[i]

      if collision(enemy, ship) then
        if ship.lives > 0 then
          ship_hit(enemy)
          deli(enemies, i)
        end
      end
    end

    -- pickups collisions
    for i = #pickups, 1, -1 do
      local pickup = pickups[i]

      if collision(pickup, ship) then
        if ship.lives > 0 then
          play_sound(3)
          deli(pickups, i)

          if pickup.type == "power" and ship.power < 3 then
            ship.power += 1
          elseif pickup.type == "hp" and ship.lives < 3 then
            ship.lives += 1
          elseif pickup.type == "super" and ship.super < 3 then
            ship.super += 1
            -- TODO
            -- elseif pickup.type == "weak" or pickup.type == "super" or pickup.type == "bash" then
            --   add(sts.deck, pickup.type)
          end
        end
      end
    end
  else
    init_game_over()
  end
end

function update_ship_deck_builder()
  -- enemy bullets collisions
  for i = #enemy_bullets, 1, -1 do
    local bullet = enemy_bullets[i]

    if collision(bullet, ship) then
      -- save a copy
      local ship_shield = ship.shield
      local hit = 2

      if boss.weak > 0 then
        hit = 1
      end

      -- update the shields
      ship.shield -= hit
      if ship.shield <= 0 then
        ship.shield = 0
      end

      -- reduce the hit
      hit = hit - ship_shield
      if hit <= 0 then
        hit = 0
      end

      -- finally remove the hp
      ship.hp -= hit

      play_sound(1)
      deli(enemy_bullets, i)

      if (ship.hp <= 0) then
        ship.hp = 0
        spawn_explosions(ship.x, ship.y, 12, 12, 10, 15)
        init_game_over()
      else
        spawn_explosion(bullet.x, bullet.y)
      end
    end
  end
end

function draw_ship()
  if (ship.lives == 0 or ship.hp == 0) then
    return
  end

  palt(0, false) -- make black non transparent
  palt(2, true)  -- ship transparent color
  local sprite = ship.sprite[ship.x_dir]
  multi_spr(sprite, ship.x, ship.y)
  palt()

  local thrusters = ship.animation_thrusters[ship.x_dir][ship.y_dir]
  local thrusters_offset = { x = 0, y = 10 }

  if (ship.y_dir == "down") then
    thrusters_offset = ship.down_offsets[ship.x_dir]
  end
  animate(thrusters, ship.x + thrusters_offset.x, ship.y + thrusters_offset.y, 5)

  -- draw_col(ship)
end
