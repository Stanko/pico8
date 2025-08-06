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
  selected_item = 1
  scene = "high_scores"

  high_scores = {}

  local max_len = 20 -- in characters

  for i = 1, 10 do
    local player = tostr(i);
    local score = tostr(dget(50 + i));


    local len = #player + #score;
    local dots_count = (max_len - len);

    local dots = ""
    for j = 1, dots_count do
      dots = dots .. "."
    end

    high_scores[i] = player .. dots .. score
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
