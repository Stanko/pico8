-- TODO move to the ship object

function init_ship()
  ship = {
    -- position
    x = 64,
    y = 100,
    x_dir = "still",
    y_dir = "up",

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

    -- TODO these are deprecated, remove
    fly_away_frame = -1,
    flown_away = false,
    moved_to_boss_fight_position = false,

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

function update_ship_shoot_em_up()
  if (ship.lives > 0) then
    -- TODO move to the game controller
    -- add enemy to increase difficulty every 180 frames (6 seconds)
    -- if (level_frame % 180 == 0) then
    --   spawn_enemy()
    -- end

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
    if (ship.y < 8) then
      ship.y = 8
    elseif (ship.y > 118) then
      ship.y = 118
    elseif (ship.x < 8) then
      ship.x = 8
    elseif (ship.x > 120) then
      ship.x = 120
    end

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
        local directions = bullet_directions[ship.power]
        for i = 1, #positions do
          -- TODO implement nicer spread
          -- spawn_bullet(positions[i], ship.y - 8, directions[i])
          spawn_bullet(positions[i])
        end

        -- TODO score
        -- if (score > 0) then
        --   score -= ship.power
        -- end
      end
    end

    -- super
    if btnp(5) or btn(5) then
      if get_super_weapon_progress() == 1 and ship.super > 0 then -- and level_frame > 10
        ship.super_last_shot = frame

        spawn_super_bullets(ship.x, ship.y)

        ship.super -= 1

        -- TODO score
        -- if (score > 8) then
        --   score -= 8
        -- end
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

  -- -- hp and shield
  -- local won = ship.fly_away_frame > 0 or ship.flown_away == true

  -- if is_boss_fight_pending() == false and won == false then
  --   local shield_left = flr(ship.x - 2 - (ship.shield - 1) * 5 / 2)
  --   for i = 1, ship.shield do
  --     spr(221, shield_left + (i - 1) * 5, ship.y - 16)
  --   end

  --   -- hp
  --   draw_hp_bar(ship.hp, ship.max_hp, 95, 101)

  --   -- energy
  --   for i = 1, ship.energy do
  --     spr(202, 4, 116 - (i - 1) * 4)
  --   end
  -- end

  draw_col(ship)
end
