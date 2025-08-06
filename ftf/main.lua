function _init()
  debug = ""

  cartdata("never_astronaut_muffinman_gundam")

  -- when the game is first played, flag 63 is set to 1
  if (dget(63) != 1) then
    -- on the first play, initialize the menu values using the default values
    init_menu_values(menu_settings)
    dset(63, 1)
  end

  init_stars()
  init_main_menu()
end

function _update()
  update_stars()

  if scene == "menu" then
    update_active_menu()
  elseif scene == "high_scores" then
    update_high_scores()
  end
end

function _draw()
  cls()

  draw_stars()

  if scene == "menu" then
    draw_active_menu()
  elseif scene == "high_scores" then
    draw_high_scores()
  end
end
