function init_level_one(repeat_level)
  scene = "level_one"
  level_state = "shoot_em_up"
  level_frame = 0

  enemy_bullets = {}
  ship.r = 4

  init_ship()
  boss = nil

  if repeat_level then
    level_repeated += 1
  else
    level_repeated = 1
    score = 0
  end

  init_settings()
  init_bullets()
  init_enemies()
  init_pickups()

  play_music()
end

function update_level_one()
  update_bullets()
  update_enemies()
  update_enemy_bullets()
  update_pickups()

  update_movement(ship)

  if (level_state == "shoot_em_up") then
    update_ship_shoot_em_up()

    -- add enemy to increase difficulty every 180 frames and reducing to 60 (6 to 2 seconds)
    if (level_frame % max(60, 210 - level_repeated * 30) == 0) then
      spawn_enemy()
    end
  elseif (level_state == "boss_fight_transition") or (level_state == "win_transition") then

  elseif (level_state == "boss_fight") then
    update_boss()
    update_movement(boss)
    update_hand()
    update_ship_deck_builder()
  elseif (level_state == "game_over") then
    update_game_over()
  end

  if (level_frame == 1000 * level_repeated and ship.lives > 0) then
    level_state = "boss_fight_transition"
    ship.y_dir = "still"
    ship.x_dir = "still"

    for i = 1, #enemies do
      enemies[i].speed *= 3
    end

    move_to(ship, 64, 80, 2, function()
      init_boss()
      init_hand()
      level_state = "boss_fight"

      move_to(boss, 64, 31, 2, function()
        boss.in_position = true
      end)
    end)

    ship.max_hp = 10 + flr(score / (80 * level_repeated))
    ship.hp = ship.max_hp
    ship.max_energy = 3 + flr(score / (200 * level_repeated))
    ship.energy = ship.max_energy
    ship.r = 6
  end

  level_frame += 1
end

function draw_level_one()
  draw_bullets()
  draw_enemies()
  draw_enemy_bullets()
  draw_ship()
  draw_pickups()

  if (level_state == "shoot_em_up") then
    -- hp
    for i = 1, 3 do
      if (i <= ship.lives) then
        spr(30, 2 + (i - 1) * 9, 2)
      else
        spr(31, 2 + (i - 1) * 9, 2)
      end
    end

    -- power
    for i = 1, ship.power do
      local x = 28 + i * 5
      spr(12, x, 1)
    end

    draw_super_weapon_ui()
  elseif (level_state == "boss_fight") then
    draw_hand()
    draw_boss()
  elseif (level_state == "game_over") then
    draw_boss()
    draw_game_over()
  end

  local score_len = #tostr(score)
  print("score:", 103 - score_len * 4, 2, 5)
  print(score, 127 - score_len * 4, 2, 7)

  -- print(level_frame)
end
