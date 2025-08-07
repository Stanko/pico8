function _init()
  debug = ""
  frame = 0

  cartdata("never_astronaut_muffinman_gundam")

  -- when the game is first played, flag 63 is set to 1
  if (dget(STORAGE_ALREADY_PLAYED) != 1) then
    -- on the first play, initialize the menu values using the default values
    init_menu_values(menu_settings)
    dset(STORAGE_ALREADY_PLAYED, 1)

    -- TODO remove or replace with real text
    dset(STORAGE_HIGH_SCORES_START, str_to_int("mfn"))
    dset(STORAGE_HIGH_SCORES_START + 1, 1000)
    dset(STORAGE_HIGH_SCORES_START + 2, str_to_int("nvr"))
    dset(STORAGE_HIGH_SCORES_START + 3, 1000)
    dset(STORAGE_HIGH_SCORES_START + 4, str_to_int("csm"))
    dset(STORAGE_HIGH_SCORES_START + 5, 1000)
  end

  init_stars()
  init_animations()
  init_main_menu()
end

function _update()
  update_stars()
  update_animations()

  if scene == "menu" then
    update_active_menu()
  elseif scene == "high_scores" then
    update_high_scores()
  elseif scene == "level_one" then
    update_level_one()
  end

  frame = frame + 1
end

function _draw()
  cls()

  draw_stars()

  if scene == "menu" then
    draw_active_menu()
  elseif scene == "high_scores" then
    draw_high_scores()
  elseif scene == "level_one" then
    draw_level_one()
  end

  draw_animations()

  print(debug, 0, 8)
end
