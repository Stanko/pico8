menu_main = {
  {
    label = "play",
    on_select = function()
      init_level_one()
    end
  },
  {
    label = "high scores",
    on_select = function()
      init_high_scores()
    end
  },
  {
    label = "settings",
    on_select = function()
      menu = menu_settings
      menu_selected_item = 1
    end
  },
}

menu_settings = {
  -- {
  --   label = "difficulty",
  --   options = { "easy", "medium", "hard" },
  --   default = 1,
  --   location = STORAGE_DIFFICULTY,
  -- },
  {
    label = "music",
    options = { "off", "on" },
    default = 1,
    location = STORAGE_MUSIC,
  },
  {
    label = "sfx",
    options = { "off", "on" },
    default = 1,
    location = STORAGE_SFX,
  },
  {
    label = "back",
    on_select = function()
      init_main_menu()
    end
  }
}

function init_main_menu()
  scene = "menu"
  menu = menu_main
  menu_selected_item = 1
end

function update_main_menu()
  update_active_menu()
end

function draw_main_menu()
  draw_active_menu({ top = 50 })

  local logo = {
    { 208, 209, 210, 211, 212, 213 },
    { 224, 225, 226, 227, 228, 229 },
    { 240, 241, 242, 243, 244, 245 }
  }

  palt(0, false)
  palt(2, true)
  multi_spr(logo, 64, 30)

  multi_spr({ { 0, 1 }, { 16, 17 } }, 64, 100)
  palt()
  animate({ 32, 33 }, 64, 110, 10)
end
