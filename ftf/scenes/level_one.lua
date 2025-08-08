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
  elseif (level_state == "game_over") then
    update_game_over()
  end

  level_frame = level_frame + 1

  -- add enemy to increase difficulty every 180 frames (6 seconds)
  if (level_frame % 180 == 0) then
    spawn_enemy()
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
  elseif (level_state == "game_over") then
    draw_game_over()
  end
end
