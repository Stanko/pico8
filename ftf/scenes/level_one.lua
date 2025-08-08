function init_level_one()
  scene = "level_one"
  level_state = "shoot_em_up"
  score = 0

  init_settings()
  init_bullets()
  init_ship()
  init_enemies()
  init_enemy_bullets()
  init_score()

  play_music()
end

function update_level_one()
  update_bullets()
  update_enemies()
  update_enemy_bullets()


  if (level_state == "shoot_em_up") then
    update_ship_shoot_em_up()
  elseif (level_state == "game_over") then
    update_game_over()
  end
end

function draw_level_one()
  draw_bullets()
  draw_enemies()
  draw_enemy_bullets()
  draw_ship()
  draw_score()

  if (level_state == "shoot_em_up") then
    draw_super_weapon_ui()
  elseif (level_state == "game_over") then
    draw_game_over()
  end
end
