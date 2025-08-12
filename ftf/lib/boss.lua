function init_boss()
  boss = {
    hp = 16,
    max_hp = 16,
    x = 64,
    y = -40,
    r = 40,
    c = { x = 0, y = -28 },
    in_position = false,

    played = false,

    weak = 0,
    vulnerable = 0,
    shield = 0,

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

    move_label = "attack X2",

    set_next_move = function()
      if (boss.hp == boss.max_hp) then
        boss.move_label = rnd({ "attack", "shield", "shield_and_attack" })
      else
        boss.move_label = rnd({ "attack", "shield", "shield_and_attack", "heal" })
      end

      if (boss.move_label == "attack") then
        local bullet_count = random_int(1, 3)
        boss.move = function()
          available_moves.attack(bullet_count)()
        end
        boss.move_label = boss.move_label .. " X" .. bullet_count
      else
        boss.move = available_moves[boss.move_label]()
      end
    end
  }

  available_moves = {
    attack = function(bullet_count)
      local label = 'attack'

      if bullet_count > 1 then
        label = label .. 'x' .. bullet_count
      end

      return function()
        local positions = shuffle({ { x = -7, y = 12 }, { x = 7, y = 12 }, { x = 0, y = 16 } })

        for i = 1, bullet_count do
          add_animation({
            position = boss,
            offset = positions[i],
            rate = 3,
            frames = { 40, 41, 42 },
            delay = (i - 1) * 5
          }, function()
            spawn_enemy_bullet(boss.x + positions[i].x, boss.y + positions[i].y)
          end)
        end
      end
    end,
    shield_and_attack = function()
      return function()
        local shield = random_int(1, 3)

        for i = 1, shield do
          do_once(function()
            boss.shield += 1
            play_sound(7)
          end, (i - 1) * 10)
        end

        -- shoot once
        add_animation({
          position = boss,
          offset = { x = 0, y = 16 },
          rate = 3,
          frames = { 40, 41, 42 },
          delay = shield * 10
        }, function()
          spawn_enemy_bullet(boss.x, boss.y + 16)
        end)
      end
    end,
    shield = function()
      return function()
        local shield = random_int(1, 3)

        for i = 1, shield do
          do_once(function()
            boss.shield += 1
            play_sound(7)
          end, (i - 1) * 10)
        end
      end
    end,
    heal = function()
      return function()
        local hp = min(random_int(1, 3), boss.max_hp - boss.hp)

        for i = 1, hp do
          do_once(function()
            boss.hp += 1
            play_sound(4)
          end, (i - 1) * 10)
        end
      end
    end
  }

  boss.move = function()
    available_moves.attack(2)()
  end
end

function end_boss_turn()
  ship.shield = 0
  ship.energy = ship.max_energy
  boss.set_next_move()
  hand = get_hand()
  deal_hand()
  if boss.vulnerable > 0 then
    boss.vulnerable -= 1
  end
  if boss.weak > 0 then
    boss.weak -= 1
  end
  turn = "player"
end

function update_boss()
  if boss.in_position then
    if (turn == "boss") then
      if not boss.played then
        -- debug = debug .. "boss playing" .. boss.move_label .. "\n"
        boss.played = true

        do_once(function()
          boss.move()

          do_once(function()
            end_boss_turn()
          end, 60)
        end, 20)
      end
    end

    -- boss / bullets collisions
    for i = #bullets, 1, -1 do
      local bullet = bullets[i]

      if collision(bullet, boss) then
        -- save a copy
        local boss_shield = boss.shield
        local hit = 1

        if (boss.vulnerable > 0) then
          hit = 2
        end

        -- update the shields
        boss.shield -= hit
        if boss.shield <= 0 then
          boss.shield = 0
        end

        -- reduce the hit
        hit = hit - boss_shield
        if hit <= 0 then
          hit = 0
        end

        -- finally remove the hp
        boss.hp -= hit

        play_sound(1)
        deli(bullets, i)

        if (boss.hp <= 0) then
          if not added_boss_score then
            score += 50 + (ship.hp * 10)
            added_boss_score = true
          end

          add_animation({
            position = { x = boss.x, y = boss.y },
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
              boss.sprite_halftone
            },
            rate = 5,
            bg_color = 7,
          })
          spawn_explosions(boss.x, boss.y, 64, 28, 60, 60)

          ship.fly_away_frame = frame + 30
          level_state = "boss_defeated_transition"

          do_once(function()
            level_state = "win_transition"
            move_to(ship, 64, -16, 2, function()
              ship.y = 144

              do_once(function()
                move_to(ship, 64, 100, 2, function()
                  init_level_one(true)
                end)
              end, 10)
            end)
          end, 30)
        else
          spawn_large_explosion(bullet.x, bullet.y)
        end
      end
    end
  end
end

function draw_boss()
  if (boss and boss.hp > 0) then
    local offset = 0
    if boss.in_position then
      offset = flr(frame / 30) % 2

      if (ship.hp > 0) then
        -- move label
        print(boss.move_label, 64 - (#boss.move_label * 2), 1, 2)

        -- hp
        draw_hp_bar(boss.hp, boss.max_hp, 8, 12)

        if boss.weak > 0 then
          spr(175, boss.x + 40, boss.y + offset - 5)
          if boss.weak > 1 then
            print("X" .. boss.weak, boss.x + 50, boss.y + offset - 3, 8)
          end
        end
        if boss.vulnerable > 0 then
          spr(159, boss.x + 40, boss.y + offset - 14)
          if boss.vulnerable > 1 then
            print("X" .. boss.vulnerable, boss.x + 50, boss.y + offset - 12, 8)
          end
        end
      end
    end

    palt(0, false) -- make black non transparent
    palt(7, true)  -- boss transparent color
    multi_spr(boss.sprite, boss.x, boss.y + offset)
    palt()

    local shield_left = flr(62 - (boss.shield - 1) * 5 / 2)
    for i = 1, boss.shield do
      spr(221, shield_left + (i - 1) * 5, boss.y - 12)
    end

    -- draw_col(boss)
  end
end
