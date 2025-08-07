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
  {
    label = "difficulty",
    options = { "easy", "medium", "hard" },
    default = 1,
    location = STORAGE_DIFFICULTY,
  },
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
