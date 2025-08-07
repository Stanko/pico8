menu_high_scores = {
  {
    label = "back",
    on_select = function()
      debug = debug .. "back\n"
      init_main_menu()
    end
  }
}

function init_high_scores()
  menu = menu_high_scores
  menu_selected_item = 1
  scene = "high_scores"

  high_scores = {}

  local max_len = 20 -- in characters

  for i = 1, 10 do
    local name_int = tostr(dget(STORAGE_HIGH_SCORES_START + (i - 1) * 2));
    local name = int_to_str(name_int)
    local score = tostr(dget(STORAGE_HIGH_SCORES_START + (i - 1) * 2 + 1));

    -- name is always 3 characters
    -- 2 charactes for padding
    local dots_count = (max_len - #score - 5);

    local dots = ""
    for j = 1, dots_count do
      dots = dots .. "."
    end

    high_scores[i] = name .. " " .. dots .. " " .. score
  end
end

function update_high_scores()
  update_active_menu()
end

function draw_high_scores()
  for i = 1, #high_scores do
    print(high_scores[i], 24, 35 + 7 * (i - 1), 7)
  end

  draw_active_menu()
end
