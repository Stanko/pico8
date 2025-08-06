menu_main = {
  {
    label = "play",
    on_select = function()
      scene = "game"
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
      selected_item = 1
    end
  },
}

menu_settings = {
  {
    label = "difficulty",
    options = { "easy", "medium", "hard" },
    default = 1,
    location = 10,
  },
  {
    label = "music",
    options = { "off", "on" },
    default = 1,
    location = 11,
  },
  {
    label = "sfx",
    options = { "off", "on" },
    default = 1,
    location = 12,
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
  selected_item = 1
end
