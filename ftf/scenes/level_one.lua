function init_level_one()
  scene = "level_one"
  level_part = "shoot-em-up"
  init_settings()
  init_bullets()
  init_ship()
  init_enemies()
  init_enemy_bullets()

  play_music()
end

function update_level_one()
  update_bullets()
  update_enemies()
  update_enemy_bullets()
  update_ship_shoot_em_up()
end

function draw_level_one()
  draw_bullets()
  draw_enemies()
  draw_enemy_bullets()
  draw_super_weapon_ui()
  draw_ship()
end
