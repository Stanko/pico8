-- ftf
-- by muffinman


----------------
----- INIT -----
----------------

function init_ship()
  ship = {
    x = 64,
    y = 100,
    speed = 3,

    shield = 0,

    lives = 3,
    hp = 10,
    max_hp = 10,
    energy = 3,
    max_energy = 3,

    power = 1,

    super = 2,

    fly_away_frame = -1,
    flown_away = false,

    r = 4,
    c = { x = 0, y = -1 },

    sprite = {
      still = { { 0, 1 }, { 16, 17 } },
      right = { { 2, 3 }, { 18, 19 } },
      left = { { 4, 5 }, { 20, 21 } },
    },

    x_dir = "still",
    y_dir = "up",

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

    moved_to_boss_fight_position = false,

    draw = function()
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

      -- hp and shield
      local won = ship.fly_away_frame > 0 or ship.flown_away == true

      if is_boss_fight_pending() == false and won == false then
        local shield_left = flr(ship.x - 2 - (ship.shield - 1) * 5 / 2)
        for i = 1, ship.shield do
          spr(221, shield_left + (i - 1) * 5, ship.y - 16)
        end

        -- hp
        draw_hp_bar(ship.hp, ship.max_hp, 95, 101)

        -- energy
        for i = 1, ship.energy do
          spr(202, 4, 116 - (i - 1) * 4)
        end
      end

      draw_col(ship)
    end
  }
end

function init_level()
  play_music()

  init_ship()

  score = 0
  added_boss_score = false

  hiscore = dget(50)
  hiscore_saved = false

  level_frame = 0

  game_over_start_frame = 0

  boss = {
    hp = 16,
    max_hp = 16,
    x = 64,
    y = -40,
    r = 40,
    c = { x = 0, y = -28 },
    moved_to_boss_fight_position = false,

    turn_start = -1,
    wind_up = 0,

    weak = 0,
    vulnerable = 0,

    sprite = {
      { 128, 129, 130, 131, 132, 133, 134, 135, 136 },
      { 144, 145, 146, 147, 148, 149, 150, 151, 152 },
      { 160, 161, 162, 163, 164, 165, 166, 167, 168 },
      { 176, 177, 178, 179, 180, 181, 182, 183, 184 }
    },
    sprite_halftone = {
      { 66,  67,  68,  69,  70,  71,  72,  73,  74 },
      { 82,  83,  84,  85,  86,  87,  88,  89,  90 },
      { 98,  99,  100, 101, 102, 103, 104, 105, 106 },
      { 114, 115, 116, 117, 118, 119, 120, 121, 122 }
    },

    move_key = "attack X2",
    move = function()
    end,

    set_next_move = function()
      if (boss.hp == boss.max_hp) then
        boss.move_key = "attack"
      else
        boss.move_key = rnd({ "attack", "heal" })
      end

      if (boss.move_key == "attack") then
        local bullets = ceil(rnd(3))
        boss.move = function(delta)
          boss_moves.attack(delta, bullets)
        end
        boss.move_key = boss.move_key .. " X" .. bullets
      else
        boss.move = boss_moves.heal
      end
    end,

    draw = function()
      if (boss.hp > 0) then
        local offset = 0
        if boss.moved_to_boss_fight_position then
          offset = flr(frame / 30) % 2

          if (ship.hp > 0) then
            -- move label
            print(boss.move_key, 64 - (#boss.move_key * 2), 1, 2)

            -- hp
            draw_hp_bar(boss.hp, boss.max_hp, 8, 12)
          end
        end

        palt(0, false) -- make black non transparent
        palt(7, true)  -- boss transparent color
        multi_spr(boss.sprite, boss.x, boss.y + offset)
        palt()

        if boss.weak > 0 then
          spr(218, boss.x + 40, boss.y + offset - 4)
          if boss.weak > 1 then
            print("X" .. boss.weak, boss.x + 50, boss.y + offset - 4, 14)
          end
        end
        if boss.vulnerable > 0 then
          spr(219, boss.x + 40, boss.y + offset - 12)
          if boss.vulnerable > 1 then
            print("X" .. boss.vulnerable, boss.x + 50, boss.y + offset - 12, 8)
          end
        end

        draw_col(boss)
      end
    end
  }

  boss_moves = {
    attack = function(delta, bullets)
      local x_positions = shuffle({ -6, 6, 0 })
      local start = 10
      -- boss move
      -- very dirty, but I was lazy to fix it

      for i = 1, bullets do
        local f = start + 12 * i - 1

        if (boss.wind_up == 0 and delta == f) then
          boss.wind_up = frame
        else
          if (f + 12) then
            spawn_enemy_bullet(boss, x_positions[i], 8)
          end
        end
      end
    end,
    heal = function(delta)
      -- delay a little bit
      if (boss.healed == true or delta < 20) then
        return;
      end

      local hp = flr(rnd(2)) + 1
      boss.hp = boss.hp + hp
      boss.healed = true
      play_sound(4)

      if (boss.hp > boss.max_hp) then
        boss.hp = boss.max_hp
      end
    end
  }

  boss.move = function(delta)
    boss_moves.attack(delta, 2)
  end

  card_sprites = {
    weak = {
      { 230, 231 },
      { 246, 247 }
    },
    bash = {
      { 232, 233 },
      { 248, 249 }
    },
    super = {
      { 234, 235 },
      { 250, 251 }
    },
    shield = {
      { 236, 237 },
      { 252, 253 }
    },
    attack = {
      { 238, 239 },
      { 254, 255 }
    },
  }

  sts = {
    turn = "player",
    selected_card = 1,
    mana = 3,
    deck = {
      "attack",
      "attack",
      "bash",
      "super",
      "attack",
      "shield",
      "shield",
      "attack",
      "attack",
      "shield",
      "weak",
      "attack",
      "shield",
      "shield",
    },
    pile = {},
    get_hand = function()
      local hand = {}
      for i = #sts.pile, #sts.pile - 4, -1 do
        if (i > 0) then
          add(hand, sts.pile[i])
          deli(sts.pile, i)
        end
      end

      -- we need to shuffle the pile again and deal the rest of the cards
      if (#hand < 5) then
        sts.pile = shuffle(sts.deck)
        for hand_index = 1, #hand do
          del(sts.pile, hand[hand_index])
        end


        for i = #sts.pile, 1, -1 do
          add(hand, sts.pile[i])
          deli(sts.pile, i)

          if (#hand == 5) then
            break
          end
        end
      end

      return hand
    end,
    hand = {},
    draw = function()
      if (is_boss_fight_pending() or ship.hp == 0) then
        return
      end

      local left = 64 - (8 * (#sts.hand - 1))

      if (sts.turn == "player") then
        for i = 1, #sts.hand do
          local card = sts.hand[i]

          if card != nil then
            local sprite = card_sprites[card]
            multi_spr(sprite, left + (i - 1) * 16, 116)
          end
        end

        local indicator_index = flr(frame / 20) % 2
        spr(198 + indicator_index, left + (sts.selected_card - 1) * 16 - 4, 100)
      end
    end,
    draw_pile = function()
      if (is_boss_fight_pending() or ship.hp == 0) then
        return
      end

      local top = 122 - #sts.pile * 4

      palt(0, false)
      palt(2, true)
      local card_sprite = { { 206, 207 }, { 222, 223 } }

      for i = 1, #sts.pile do
        multi_spr(card_sprite, 120, top + (i - 1) * 4)
      end

      palt()
    end,
  }

  sts.pile = shuffle(sts.deck);
  sts.hand = sts.get_hand();

  shot_delay = 8
  last_shot = -10 * shot_delay

  super_shot_delay = 60
  super_last_shot = -10 * super_shot_delay

  enemy_sprites = {
    {
      still = { { 6, 7 }, { 22, 23 } },
      right = { { 8, 9 }, { 24, 25 } },
      left = { { 10, 11 }, { 26, 27 } },
    },
    {
      still = { { 137, 138 }, { 153, 154 } },
      right = { { 137, 138 }, { 153, 154 } },
      left = { { 137, 138 }, { 153, 154 } },
    },
  }

  enemies = {}

  for i = 1, 5 do
    -- spawn first wave of enemies a bit further away -> from -192 to -128
    local y = rnd(64) - 192
    spawn_enemy(y)
  end

  bullet_animation = { 12, 13 }
  super_bullet_animation = { 43, 44 }
  bullets = {}

  enemy_bullet_animation = { 14, 15 }
  enemy_bullets = {}

  pickups = {}
end

function init_stars()
  stars = {}

  star_colors = { 5, 6, 13 }
  star_speeds = { 1 }

  for i = 1, 30 do
    stars[i] = {
      x = flr(rnd(128)),
      y = flr(rnd(256)) - 128,
      speed = 1,
      color = 1,
      r = rnd(2)
    }
  end
  for i = 1, 16 do
    stars[i] = {
      x = flr(rnd(128)),
      y = flr(rnd(256)) - 128,
      speed = 2,
      color = 5,
      r = rnd(2)
    }
  end
  for i = 1, 8 do
    stars[i] = {
      x = flr(rnd(128)),
      y = flr(rnd(256)) - 128,
      speed = 3,
      color = 13,
      r = rnd(2)
    }
  end
end

function init_menu()
  level = 1
  selected_setting = 1
  init_ship()
end

function _init()
  cartdata("muffinman_ftf")

  logo = {
    { 208, 209, 210, 211, 212, 213 },
    { 224, 225, 226, 227, 228, 229 },
    { 240, 241, 242, 243, 244, 245 }
  }

  -- 63 is used as a flag to determine if the game has been played before
  if (dget(63) != 1) then
    -- set default values
    dset(0, 1)  -- music on
    dset(1, 1)  -- sfx on

    dset(50, 0) -- hi score

    dset(63, 1) -- settings initialized
  end

  selected_setting = 1
  settings = {
    { key = "music", value = dget(0), },
    { key = "sfx",   value = dget(1) }
  }

  hiscore = dget(50)
  hiscore_saved = false

  debug = ""
  frame = 0
  level_frame = 0

  col_debug = false
  col_colors = { 8, 10 }

  animations = {}
  level = 1 -- home screen

  init_stars()
  init_ship()
end

-----------------
----- UTILS -----
-----------------

function get_super_progress()
  local progress = (frame - super_last_shot) / super_shot_delay
  if progress >= 1 then
    progress = 1
  end
  return progress
end

function move_to_position(x, y, obj, flag)
  if flag == nil then
    flag = "moved_to_boss_fight_position"
  end

  if obj[flag] then
    return
  end

  local direction = {
    x = x - obj.x,
    y = y - obj.y
  }

  local distance = sqrt(direction.x * direction.x + direction.y * direction.y)

  local speed = 2
  local dx = direction.x / distance * speed
  local dy = direction.y / distance * speed

  obj.x += dx
  obj.y += dy

  if (abs(obj.x - x) < 1.5 and abs(obj.y - y) < 1.5) then
    obj.x = x
    obj.y = y
    obj[flag] = true
  end
end

function is_boss_fight_pending()
  return ship.moved_to_boss_fight_position == false or boss.moved_to_boss_fight_position == false
end

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

function draw_col(obj)
  if (col_debug) then
    local r = obj.r
    local i = flr(frame / 15) % 2 + 1
    local c = obj.c
    -- fill collision outline
    -- ovalfill(obj.x + c.x - r, obj.y + c.y - r, obj.x + r + c.x - 1, obj.y + r + c.y - 1, 1)
    oval(obj.x + c.x - r, obj.y + c.y - r, obj.x + r + c.x - 1, obj.y + r + c.y - 1, col_colors[i])
  end
end

function shuffle(t)
  -- copy original table
  local temp = {}
  for i = 1, #t do
    add(temp, t[i])
  end

  -- shuffle the copy
  for i = #temp, 2, -1 do
    local j = flr(rnd(i)) + 1
    temp[i], temp[j] = temp[j], temp[i]
  end

  return temp
end

-----------------
----- SOUND -----
-----------------

function play_music()
  if (settings[1].value == 1) then
    if rnd(1) > 0.5 then
      music(0)
    else
      music(7)
    end
  end
end

function play_sound(sound_id)
  if (settings[2].value == 1) then
    sfx(sound_id)
  end
end

----------------------
----- ANIMATIONS -----
----------------------

function spawn_explosion(x, y, delay)
  add(animations, {
    delay = delay,
    start = -1,
    x = x,
    y = y,
    frames = { 45, 46, 47 },
    index = -1,
    rate = 3,
  })
end

function spawn_large_explosion(x, y, delay)
  add(animations, {
    delay = delay,
    start = -1,
    x = x,
    y = y,
    frames = {
      59,
      { { 60, 61 }, { 76, 77 } },
      { { 62, 63 }, { 78, 79 } },
    },
    index = -1,
    rate = 2,
  })
end

function spawn_explosions(x, y, x_offset, y_offset, count, delay)
  for i = 1, count do
    if rnd(1) > 0.5 then
      spawn_large_explosion(
        x + flr(rnd(x_offset) - x_offset / 2),
        y + flr(rnd(y_offset) - y_offset / 2),
        flr(rnd(delay))
      )
    else
      spawn_explosion(
        x + flr(rnd(x_offset) - x_offset / 2),
        y + flr(rnd(y_offset) - y_offset / 2),
        flr(rnd(delay))
      )
    end
  end
end

------------------------
----- GAME OBJECTS -----
------------------------

function spawn_bullet(x, y, direction, animation)
  if (y == nil) then
    y = ship.y - 8
  end

  if (direction == nil) then
    direction = { x = 0, y = 4 }
  end

  if (animation == nil) then
    animation = bullet_animation
  end

  add(bullets, {
    x = x,
    y = y,
    r = 2,
    c = { x = 0, y = -2 },
    animation = animation,
    direction = direction
  })
  play_sound(0)
end

function spawn_super_bullets(x, y)
  local bullet_positions = {
    {
      x = ship.x - 9,
      y = ship.y
    },
    {
      x = ship.x - 6,
      y = ship.y - 2
    },
    {
      x = ship.x - 3,
      y = ship.y - 4
    },
    {
      x = ship.x,
      y = ship.y - 6
    },
    {
      x = ship.x + 3,
      y = ship.y - 4
    },
    {
      x = ship.x + 6,
      y = ship.y - 2
    },
    {
      x = ship.x + 9,
      y = ship.y
    }
  }
  local bullet_directions = {
    {
      x = 4,
      y = 2
    },
    {
      x = 3,
      y = 3
    },
    {
      x = 2,
      y = 4
    },
    {
      x = 0,
      y = 4.5
    },
    {
      x = -2,
      y = 4
    },
    {
      x = -3,
      y = 3
    },
    {
      x = -4,
      y = 2
    }
  }

  for i = 1, #bullet_positions do
    local position = bullet_positions[i]
    local direction = bullet_directions[i]
    spawn_bullet(position.x, position.y, direction, super_bullet_animation)
  end
end

function spawn_enemy_bullet(e, x_offset, y_offset)
  if x_offset == nil then
    x_offset = 0
  end
  if y_offset == nil then
    y_offset = 0
  end

  local x = e.x + x_offset
  local y = e.y + y_offset
  local wind_up_delta = frame - e.wind_up

  if e.wind_up > 0 then
    if (wind_up_delta > 9) then
      -- shoot
      add(enemy_bullets, {
        x = x,
        y = y + 6,
        speed = 5,
        r = 2,
        c = { x = 0, y = 0 }
      })
      play_sound(0)
      e.wind_up = 0
    elseif (wind_up_delta > 6) then
      -- animation third frame
      spr(42, e.x - 4, e.y + 3)
    elseif (wind_up_delta > 3) then
      -- animation second frame
      spr(41, e.x - 4, e.y + 3)
    else
      -- animation first frame
      spr(40, e.x - 4, e.y + 3)
    end
  end
end

function spawn_enemy(y)
  local x = flr(rnd(112)) + 8 -- 8 - 119 (8 fee on each side)
  local type = flr(rnd(2)) + 1
  local speed = rnd(2) + 1
  local x_movement = 0

  if y == nil then
    y = flr(rnd(128)) * -1
  end

  if type == 1 then
    speed = rnd(2) + 3
    x_movement = rnd(32) + 16

    if rnd(1) > 0.5 then
      x_movement = x_movement * -1
    end
  end

  add(enemies, {
    x = x,
    y = y,
    r = 6,
    c = { x = 0, y = 0 },
    dir = "still",
    sprite = enemy_sprites[type],
    speed = speed,
    start_x = x,
    start_frame = frame,
    x_movement = x_movement,
    wind_up = 0,
  })
end

------------------
----- UPDATE -----
------------------

----- UPDATE STS

function update_boss_collisions()
  -- boss / bullets collisions
  for bi = #bullets, 1, -1 do
    local b = bullets[bi]

    if collision(b, boss) then
      boss.hp -= 1
      play_sound(1)
      deli(bullets, bi)

      if boss.vulnerable > 0 then
        boss.hp -= 1
      end

      if (boss.hp <= 0) then
        if added_boss_score == false then
          score += 50 + (ship.hp * 10)
          added_boss_score = true
        end

        add(animations, {
          start = frame,
          x = boss.x,
          y = boss.y,
          bg_color = 7,
          frames = {
            boss.sprite,
            boss.sprite_halftone,
            boss.sprite,
            boss.sprite_halftone,
            boss.sprite,
            boss.sprite_halftone,
            boss.sprite,
            boss.sprite_halftone,
            boss.sprite,
            boss.sprite_halftone,
          },
          index = -1,
          rate = 5,
        })
        spawn_explosions(boss.x, boss.y, 64, 28, 60, 60)

        ship.fly_away_frame = frame + 30
      else
        spawn_large_explosion(b.x, b.y)
      end
    end
  end

  -- ship / enemy bullets collisions
  for bi = #enemy_bullets, 1, -1 do
    local b = enemy_bullets[bi]

    if collision(b, ship) then
      local hit = 2
      if boss.weak > 0 then
        hit = 1
      end

      -- save a copy
      local ship_shield = ship.shield

      -- update the shields
      ship.shield -= hit
      if ship.shield <= 0 then
        ship.shield = 0
      end

      -- debug = debug .. "s:" .. ship_shield .. " h:" .. hit .. "\n"

      -- reduce the hit
      hit = hit - ship_shield
      if hit <= 0 then
        hit = 0
      end

      -- finally remove the hp
      ship.hp -= hit

      play_sound(1)
      deli(enemy_bullets, bi)

      if (ship.hp <= 0) then
        ship.hp = 0
        spawn_explosions(ship.x, ship.y, 12, 12, 10, 15)
      else
        spawn_explosion(b.x, b.y)
      end
    end
  end
end

function update_boss_fight()
  if (ship.flown_away) or (ship.hp <= 0) then
    update_game_over()
  elseif (#enemies == 0) then
    if is_boss_fight_pending() then
      move_to_position(64, 85, ship)
      move_to_position(64, 31, boss)
    else
      -- boss fight

      -- select card
      if btnp(0) then
        sts.selected_card = sts.selected_card - 1
        if sts.selected_card < 1 then
          sts.selected_card = 1
        end
      elseif btnp(1) then
        sts.selected_card = sts.selected_card + 1
        if sts.selected_card > #sts.hand then
          sts.selected_card = #sts.hand
        end
      end

      -- play card
      if btnp(4) then
        local card = sts.hand[sts.selected_card]

        local energy_costs = {
          attack = 1,
          shield = 1,
          super = 2,
          bash = 2,
          weak = 2
        }

        local energy_cost = energy_costs[card]

        if (energy_cost > ship.energy) then
          return
        end

        if (card == "attack") then
          spawn_bullet(ship.x)
        elseif (card == "shield") then
          ship.shield += 1
          play_sound(7)
        elseif (card == "super") then
          spawn_super_bullets()
        elseif (card == "bash") then
          add(animations, {
            start = -1,
            x = 64,
            y = 61,
            frames = {
              { { 216 }, { 216 }, { 216 }, { 216 } },
              { { 217 }, { 217 }, { 217 }, { 217 } },
              { { 216 }, { 216 }, { 216 }, { 216 } },
              { { 217 }, { 217 }, { 217 }, { 217 } },
              { { 216 }, { 216 }, { 216 }, { 216 } },
              { { 217 }, { 217 }, { 217 }, { 217 } },
              { { 216 }, { 216 }, { 216 }, { 216 } },
            },
            index = -1,
            rate = 2,
          })
          boss.vulnerable += 2
          play_sound(6)
        elseif (card == "weak") then
          add(animations, {
            start = -1,
            x = 64,
            y = 61,
            frames = {
              { { 214 }, { 214 }, { 214 }, { 214 } },
              { { 215 }, { 215 }, { 215 }, { 215 } },
              { { 214 }, { 214 }, { 214 }, { 214 } },
              { { 215 }, { 215 }, { 215 }, { 215 } },
              { { 214 }, { 214 }, { 214 }, { 214 } },
              { { 215 }, { 215 }, { 215 }, { 215 } },
              { { 214 }, { 214 }, { 214 }, { 214 } },
            },
            rate = 2,
            index = -1,
          })

          boss.weak += 2
          play_sound(5)
        end

        ship.energy -= energy_cost

        deli(sts.hand, sts.selected_card)
        if sts.selected_card > #sts.hand then
          sts.selected_card = #sts.hand
        end

        -- switch to boss turn
        if #sts.hand == 0 or ship.energy == 0 then
          sts.turn = "boss"
          sts.selected_card = 1
          boss.turn_start = frame
        end
      end

      if (ship.fly_away_frame > 0 and frame > ship.fly_away_frame and ship.flown_away == false) then
        ship.y_dir = "up"
        move_to_position(64, -32, ship, "flown_away")
      end

      update_boss_collisions()
    end

    if (sts.turn == "boss" and boss.hp > 0) then
      delta = frame - boss.turn_start

      boss.move(delta)

      -- end turn
      if delta > 60 then
        boss.turn_start = -1
        boss.healed = false

        boss.set_next_move()

        if (boss.vulnerable > 0) then
          boss.vulnerable -= 1
        end

        if (boss.weak > 0) then
          boss.weak -= 1
        end

        if (ship.hp > 0) then
          -- switch to player turn
          ship.shield = 0
          ship.energy = ship.max_energy
          sts.turn = "player"
          sts.hand = sts.get_hand()
        end
      end
    end
  end

  update_move_objects()
end

----- UPDATE SHMUP

function update_collisions()
  -- bullets / enemies collisions
  for bi = #bullets, 1, -1 do
    local b = bullets[bi]

    for ei = #enemies, 1, -1 do
      local e = enemies[ei]
      if collision(e, b) then
        b.hit = true
        deli(bullets, bi)
        deli(enemies, ei)
        spawn_large_explosion(e.x, e.y)
        spawn_enemy()
        play_sound(2)
        score += 6

        local rotation_speed = rnd(1) + 1

        local pickup_options = {
          {
            condition = ship.power < 3,
            type = "power",
            sprite = { 80, 81 },
          },
          {
            condition = ship.lives < 3,
            type = "hp",
            sprite = { 29, 30 },
          },
          {
            condition = ship.super < 3,
            type = "super",
            sprite = { 96, 97 },
          }
        }

        local p = rnd(pickup_options)

        local radius = flr(rnd(5)) + 17
        if (rnd(1) > 0.5) then
          radius = radius * -1
        end

        if (p.condition and rnd(1) > 0.8) then
          add(pickups, {
            center = { x = e.x - cos(frame * 0.01 * rotation_speed) * radius, y = e.y - sin(frame * 0.01 * rotation_speed) * radius },
            radius = radius,
            x = e.x,
            y = e.y,
            type = p.type,
            sprite = p.sprite,
            speed = 1,
            rotation_speed = rotation_speed,
            r = 5,
            c = { x = 0, y = 0 },
          })
        elseif (#sts.deck <= 17) and rnd(1) > 0.98 then
          -- user starts with 14 cards, and can add only 3 more
          local cards_options = {
            {
              type = "weak",
              sprite = { card_sprites.weak }
            },
            {
              type = "super",
              sprite = { card_sprites.super }
            },
            {
              type = "bash",
              sprite = { card_sprites.bash }
            }
          }
          local card = rnd(cards_options)

          add(pickups, {
            center = { x = e.x - cos(frame * 0.01 * rotation_speed) * radius, y = e.y - sin(frame * 0.01 * rotation_speed) * radius },
            radius = radius,
            x = e.x,
            y = e.y,
            type = card.type,
            sprite = card.sprite,
            speed = 1,
            rotation_speed = rotation_speed,
            r = 6,
            c = { x = 0, y = 0 },
          })
        end
        break
      end
    end
  end

  -- ship / enemy collisions
  for ei = #enemies, 1, -1 do
    local e = enemies[ei]

    if collision(e, ship) then
      if ship.lives > 0 then
        ship.lives -= 1
        play_sound(1)
        deli(enemies, ei)
        if (ship.lives == 0) then
          spawn_explosions(ship.x, ship.y, 12, 12, 10, 15)
        else
          spawn_explosion(e.x, e.y)
        end
      end
    end
  end

  -- ship / enemy bullets collisions
  for bi = #enemy_bullets, 1, -1 do
    local b = enemy_bullets[bi]

    if collision(b, ship) then
      if ship.lives > 0 then
        ship.lives -= 1
        play_sound(1)
        deli(enemy_bullets, bi)

        if (ship.power > 1) then
          ship.power -= 1
        end

        if (ship.lives == 0) then
          spawn_explosions(ship.x, ship.y, 12, 12, 10, 15)
        else
          spawn_explosion(b.x, b.y)
        end
      end
    end
  end

  -- ship / pickups collisions
  for pi = #pickups, 1, -1 do
    local p = pickups[pi]

    if collision(p, ship) then
      if ship.lives > 0 then
        play_sound(3)
        deli(pickups, pi)

        if p.type == "power" and ship.power < 3 then
          ship.power += 1
        elseif p.type == "hp" and ship.lives < 3 then
          ship.lives += 1
        elseif p.type == "super" and ship.super < 3 then
          ship.super += 1
        elseif p.type == "weak" or p.type == "super" or p.type == "bash" then
          add(sts.deck, p.type)
        end
      end
    end
  end
end

function update_level()
  ship.y_dir = "still"

  if (ship.lives > 0 and level == 2) then
    -- add enemy to increase difficulty every 180 frames (6 seconds)
    if (level_frame % 180 == 0) then
      spawn_enemy()
    end

    -- vertical movement
    if btn(2) == btn(3) then
    elseif btn(2) then
      -- up
      ship.y -= ship.speed
      ship.y_dir = "up"

      if (ship.y < 8) then
        ship.y = 8
      end
    elseif btn(3) then
      -- down
      ship.y += ship.speed
      ship.y_dir = "down"

      if (ship.y > 118) then
        ship.y = 118
      end
    end

    -- horizontal movement
    ship.x_dir = "still"

    if btn(0) == btn(1) then
    elseif btn(0) then
      -- left
      ship.x -= ship.speed
      ship.x_dir = "left"
      if (ship.x < 8) then
        ship.x = 8
      end
    elseif btn(1) then
      -- right
      ship.x += ship.speed
      ship.x_dir = "right"
      if (ship.x > 120) then
        ship.x = 120
      end
    end


    -- fire
    if btnp(4) or btn(4) then
      if (frame - last_shot) > shot_delay then
        last_shot = frame

        local bullet_x_positions = {
          { ship.x },
          { ship.x - 4, ship.x + 4 },
          { ship.x - 8, ship.x,    ship.x + 8 }
        }

        local positions = bullet_x_positions[ship.power]
        for i = 1, #positions do
          spawn_bullet(positions[i])
        end

        if (score > 0) then
          score -= ship.power
        end
      end
    end

    -- super
    if btnp(5) or btn(5) then
      if get_super_progress() == 1 and ship.super > 0 and level_frame > 10 then
        super_last_shot = frame

        spawn_super_bullets()

        ship.super -= 1
        if (score > 8) then
          score -= 8
        end
      end
    end
  else
    update_game_over()
  end

  update_move_objects()
  update_collisions()

  if (level_frame == 1000) and (ship.lives > 0) then
    ship.max_hp = 10 + flr(score / 80)
    ship.hp = ship.max_hp
    ship.max_energy = 3 + flr(score / 200)
    ship.energy = ship.max_energy
    level = 3
    ship.y_dir = "still"
    ship.x_dir = "still"
    ship.r = 5
    for i = 1, #enemies do
      enemies[i].speed *= 3
    end
  end
end

----- GENERAL

function update_menu()
  if btnp(5) or btnp(4) then
    init_level()
    level = 2
  end

  if (btnp(2)) then
    selected_setting = (selected_setting - 1) % #settings
  elseif (btnp(3)) then
    selected_setting = (selected_setting + 1) % #settings
  end

  if (selected_setting == 0) then
    selected_setting = #settings
  end

  if (btnp(0) or btnp(1)) then
    if settings[selected_setting].value == 1 then
      settings[selected_setting].value = 0
      dset(selected_setting - 1, 0)
    else
      settings[selected_setting].value = 1
      dset(selected_setting - 1, 1)
    end
  end
end

function update_game_over()
  if (game_over_start_frame == 0) then
    game_over_start_frame = frame
  end

  -- add slight delay before you can restart the level

  if (frame - game_over_start_frame > 30) then
    -- game over
    if btnp(4) then
      init_level()
      level = 2
    end
    if btnp(5) then
      init_menu()
    end
  end

  if (hiscore_saved == false and score > hiscore) then
    hiscore = score
    dset(50, hiscore)
    hiscore_saved = true
  end
end

function update_move_objects()
  -- move each bullet
  for i = #bullets, 1, -1 do
    local b = bullets[i]
    b.x = b.x - b.direction.x
    b.y = b.y - b.direction.y
    if b.y < 0 then
      del(bullets, b)
    end
  end

  for i = #enemy_bullets, 1, -1 do
    local b = enemy_bullets[i]
    b.y = b.y + b.speed
    if b.y > 132 then
      del(enemy_bullets, b)
    end
  end

  -- move each enemy
  for i = #enemies, 1, -1 do
    local delta = frame - enemies[i].start_frame
    local e = enemies[i]
    local s = sin(delta * 0.01)
    e.y = e.y + e.speed
    e.x = e.start_x + s * e.x_movement
    if (s > 0.1) then
      e.dir = "right"
    elseif (s < -0.1) then
      e.dir = "left"
    else
      e.dir = "still"
    end

    if e.speed < 3 and e.y > 0 and e.y < 20 then
      if (rnd(1) > 0.9 and e.wind_up == 0) then
        e.wind_up = frame
      end
    end

    if e.y > 140 then
      del(enemies, e)

      if (level == 2) then
        spawn_enemy()
      end
    end
  end

  -- move pickups
  for i = #pickups, 1, -1 do
    local p = pickups[i]
    p.center.y += p.speed
    p.x = p.center.x + cos(frame * 0.01 * p.rotation_speed) * p.radius
    p.y = p.center.y + sin(frame * 0.01 * p.rotation_speed) * p.radius
  end
end

----- MAIN UPDATE LOOP

function _update()
  frame = frame + 1
  level_frame = level_frame + 1

  if level == 1 then
    update_menu()
  elseif level == 2 then
    update_level()
  elseif level == 3 then
    update_boss_fight()
  end

  -- move each star
  for i = 1, #stars do
    stars[i].y = stars[i].y + stars[i].speed * 0.5
    if stars[i].y > 127 then
      stars[i].x = flr(rnd(128))
      stars[i].y = flr(rnd(128)) * -1
    end
  end

  -- animations
  for i = #animations, 1, -1 do
    local a = animations[i]
    local delay = a.delay or 0

    if (a.start == -1) then
      a.start = frame + delay
    end

    local delta = frame - a.start

    if (delta > 0) then
      a.index = flr(delta / a.rate) + 1

      if (a.index > #a.frames) then
        deli(animations, i)
      end
    end
  end
end

----------------
----- DRAW -----
----------------

function draw_hp_bar(hp, max_hp, top, bottom)
  local point_width = 3
  local bar_width = max_hp * point_width
  local left = 64 - bar_width / 2

  rectfill(left, top, left + bar_width, bottom, 1);

  for i = 0, max_hp - 1 do
    local x = left + 1 + i * point_width;

    if i < hp then
      rectfill(x, top + 1, x + point_width - 2, bottom - 1, 8);
      rectfill(x + point_width - 2, top + 1, x + point_width - 2, top + 1, 7)
    else
      rectfill(x, top + 1, x + point_width - 2, bottom - 1, 0);
    end
  end
end

function draw_stars()
  for i = 1, #stars do
    local y = stars[i].y
    local x = stars[i].x
    circfill(x, y, stars[i].r, stars[i].color)
  end
end

function draw_bullets()
  for i = 1, #bullets do
    local y = bullets[i].y
    local x = bullets[i].x
    animate(bullets[i].animation, x, y, 10)
    draw_col(bullets[i])
  end
end

function draw_enemy_bullets()
  for i = 1, #enemy_bullets do
    local b = enemy_bullets[i]
    local y = b.y
    local x = b.x
    animate(enemy_bullet_animation, x, y, 10)
    draw_col(b)
  end
end

function draw_enemies()
  for i = 1, #enemies do
    local e = enemies[i]
    local y = e.y
    local x = e.x
    multi_spr(e.sprite[e.dir], x, y)
    spawn_enemy_bullet(e)
    draw_col(e)
  end
end

function draw_animations()
  for i = 1, #animations do
    local a = animations[i]

    if (a.bg_color) then
      palt(0, false)         -- make black non transparent
      palt(a.bg_color, true) -- transparent color
    end

    if (a.index > 0) then
      local frame = a.frames[a.index]

      if (type(frame) == "number") then
        -- single sprite
        spr(frame, a.x - 4, a.y - 4)
      else
        -- multi sprite
        multi_spr(frame, a.x, a.y)
      end
    end

    if (a.bg_color) then
      palt() -- reset
    end
  end
end

function draw_pickups()
  for i = 1, #pickups do
    local p = pickups[i]
    animate(p.sprite, p.x, p.y, 10)
    draw_col(p)
  end
end

function draw_shmup_ui()
  draw_super_ui()

  for i = 1, 3 do
    if (i <= ship.lives) then
      spr(30, 2 + (i - 1) * 9, 2)
    else
      spr(31, 2 + (i - 1) * 9, 2)
    end
  end

  for i = 1, ship.power do
    local x = 28 + i * 5
    -- rectfill(x, 2, x + 1, 8, 11)
    spr(12, x, 1)
  end
end

function draw_score_and_game_over()
  local score_len = #tostr(score)
  print("score:", 103 - score_len * 4, 2, 5)
  print(score, 127 - score_len * 4, 2, 7)

  if (ship.lives == 0 or ship.hp == 0) then
    local msg = "game over!"
    print(msg, 64 - #msg * 2, 54, 12)

    if (game_over_start_frame > 0 and frame - game_over_start_frame > 30) then
      msg = "press 🅾️ to restart"
      print(msg, 64 - #msg * 2, 65, 5)
      msg = "or ❎ for menu"
      print(msg, 64 - #msg * 2, 72, 5)
    end

    if (hiscore_saved) then
      msg = "new hiscore!"
      print(msg, 64 - #msg * 2, 85, 7)
    end

    music(-1, 500)
    return
  end
end

function draw_menu()
  palt(0, false) -- make black non transparent
  palt(2, true)  -- ship transparent color
  multi_spr(logo, 64, 30)
  palt()

  local msg = "by muffinman"
  print(msg, 64 - #msg * 2, 44, 5)
  msg = "press ❎ or 🅾️ to start"
  print(msg, 64 - #msg * 2, 56, 12)

  msg = "hiscore: " .. hiscore
  print(msg, 64 - #msg * 2, 118, 7)

  local top = 64
  local left = 46

  for i = 1, #settings do
    local v = settings[i].value
    local key = settings[i].key
    local value = "on"
    if v == 0 then
      value = "off"
    end
    local str = key .. ": " .. value

    if selected_setting == i then
      print("*", left - 6, top + i * 7, 9)
    end
    print(str, left, top + i * 7, 7)
  end
end

function draw_splash()
  ship.y = 90
  local msg = "by muffinman"
  print(msg, 64 - #msg * 2, 54, 5)

  multi_spr({ { 62, 63 }, { 78, 79 } }, 20, 40)
  -- spr(12, 66, 55)
  -- spr(12, 60, 75)

  -- multi_spr({ { 8, 9 }, { 24, 25 } }, 40, 70)
  multi_spr({ { 137, 138 }, { 153, 154 } }, 104, 50)
  spr(14, 100, 60)

  palt(0, false) -- make black non transparent
  palt(2, true)  -- ship transparent color
  multi_spr(logo, 64, 40)
  palt()
end

function draw_super_ui()
  local super_progress = get_super_progress()
  local left = 57

  local outline = 5
  local fill = 9
  local progress_color = 9

  if (ship.super == 0) then
    progress_color = 13
  end

  line(left, 2, left, 7, outline)
  line(left + 5, 2, left + 5, 5, outline)
  line(left + 10, 2, left + 10, 5, outline)
  line(left + 15, 2, left + 15, 7, outline)

  line(left + 1, 1, left + 14, 1, outline)
  line(left + 1, 6, left + 14, 6, outline)
  line(left + 1, 8, left + 14, 8, outline)

  line(left + 1, 7, left + flr(super_progress * 14), 7, progress_color)

  for i = 0, ship.super - 1 do
    local x = left + i * 5 + 1
    rectfill(x, 2, x + 3, 5, fill)
    rectfill(x + 1, 3, x + 2, 4, 15)
    line(x + 3, 2, x + 3, 2, 7)
  end
end

function _draw()
  cls()

  draw_stars()

  if (level == 1) then
    draw_menu()
    -- draw_splash()
  else
    draw_enemies()
    draw_enemy_bullets()
    draw_bullets()
    draw_pickups()

    if (level == 3) then
      boss.draw()
      draw_score_and_game_over()

      if (ship.fly_away_frame == -1 and ship.flown_away == false) then
        sts.draw()
        sts.draw_pile()
      end

      if (ship.flown_away) then
        local msg = "congratulations!"
        print(msg, 64 - #msg * 2, 23, 9)
        msg = "and thank you for playing"
        print(msg, 64 - #msg * 2, 30, 9)
        msg = "fIGHT THE fIRE"
        print(msg, 64 - #msg * 2, 37, 12)
        msg = "an homage to old shoot em ups"
        print(msg, 64 - #msg * 2, 48, 7)
        msg = "and slay the spire"
        print(msg, 64 - #msg * 2, 55, 7)
        msg = "press 🅾️ to restart"
        print(msg, 64 - #msg * 2, 70, 5)
        msg = "or ❎ for menu"
        print(msg, 64 - #msg * 2, 77, 5)

        if (hiscore_saved) then
          msg = "new hiscore!"
          print(msg, 64 - #msg * 2, 92, 7)
        end

        music(-1, 3000)
      end
    else
      draw_shmup_ui()
      draw_score_and_game_over()
    end
    -- print(level_frame, 2, 20)
  end

  ship.draw()
  draw_animations()

  print(debug, 2, 2, 7)
end
