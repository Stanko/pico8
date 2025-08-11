function _init()
  debug = ""
  frame = 0

  score = 0

  level_repeated = 1

  cartdata("muffinman_io_ftf")

  -- when the game is first played, flag 63 is set to 1
  if (dget(STORAGE_ALREADY_PLAYED) != 1) then
    -- on the first play, initialize the menu values using the default values
    init_menu_values(menu_settings)
    dset(STORAGE_ALREADY_PLAYED, 1)

    -- TODO remove or replace
    for i = 1, 10 do
      local offset = (i - 1) * 2
      dset(STORAGE_HIGH_SCORES_START + offset, str_to_number("ftf"))
      dset(STORAGE_HIGH_SCORES_START + offset + 1, 100 - (i - 1) * 10)
    end
  end

  init_stars()
  init_animations()
  init_main_menu()
  init_single_actions()
  init_ship()
end

function _update()
  update_stars()
  update_animations()
  update_single_actions()

  if scene == "menu" then
    update_main_menu()
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
    draw_main_menu()
  elseif scene == "high_scores" then
    draw_high_scores()
  elseif scene == "level_one" then
    draw_level_one()
  end

  draw_animations()

  print(debug, 0, 8, 7)
end
