function init_level_one()
  scene = "level_one"
  level_state = "shoot_em_up"
  level_frame = 0
  score = 0

  init_settings()
  init_bullets()
  init_ship()
  init_enemies()
  init_enemy_bullets()
  init_score()
  init_pickups()

  play_music()
end

function update_level_one()
  update_bullets()
  update_enemies()
  update_enemy_bullets()
  update_pickups()

  if (level_state == "shoot_em_up") then
    update_ship_shoot_em_up()

    -- add enemy to increase difficulty every 180 frames (6 seconds)
    if (level_frame % 180 == 0) then
      spawn_enemy()
    end
  elseif (level_state == "boss_fight_transition") or (level_state == "win_transition") then
    update_movement(ship)
  elseif (level_state == "boss_fight") then
    update_boss()
    update_movement(boss)
    update_hand()
    update_ship_deck_builder()
  elseif (level_state == "game_over") then
    update_game_over()
  end

  level_frame = level_frame + 1

  if (level_frame == 30) then
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

    -- ship.max_hp = 10 + flr(score / 80)
    -- ship.hp = ship.max_hp
    -- ship.max_energy = 3 + flr(score / 200)
    -- ship.energy = ship.max_energy
    -- level = 3
    -- ship.y_dir = "still"
    -- ship.x_dir = "still"
    -- ship.r = 5
    -- for i = 1, #enemies do
    --   enemies[i].speed *= 3
    -- end
  end
end

function draw_level_one()
  draw_bullets()
  draw_enemies()
  draw_enemy_bullets()
  draw_ship()
  draw_score()
  draw_pickups()

  if (level_state == "shoot_em_up") then
    draw_shoot_em_up_ui()
  elseif (level_state == "boss_fight") then
    draw_boss()
    draw_hand()
  elseif (level_state == "game_over") then
    draw_game_over()
  end
end
