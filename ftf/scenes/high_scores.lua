menu_high_scores = {
  {
    label = "back",
    on_select = function()
      init_main_menu()
    end
  }
}

function is_high_score()
  local high_scores = get_high_scores()

  for i = 1, #high_scores do
    if score > high_scores[i].score then
      return i
    end
  end

  return false
end

function add_high_score(name, score)
  local high_scores = get_high_scores()

  add(high_scores, { name = name, score = score })

  high_scores = sort_table_by_field(high_scores, "score")

  -- Add this before sorting to check your data
  function debug_table(t, field)
    print("table length: " .. #t)
    for i = 1, #t do
      if t[i] then
        print(i .. ": " .. (t[i][field] or "NIL_FIELD"))
      else
        print(i .. ": NIL_ITEM")
      end
    end
  end

  -- there is 10 high scores, we added one, so we need to remove the last one
  deli(high_scores, 11)

  -- save
  for i = 1, #high_scores do
    local offset = (i - 1) * 2
    dset(STORAGE_HIGH_SCORES_START + offset, str_to_number(high_scores[i].name))
    dset(STORAGE_HIGH_SCORES_START + offset + 1, high_scores[i].score)
  end

  dset(STORAGE_HIGH_SCORES_LAST_NAME, str_to_number(name))
end

function get_high_scores()
  local high_scores = {}

  for i = 1, 10 do
    local offset = (i - 1) * 2
    local name_number = dget(STORAGE_HIGH_SCORES_START + offset);
    local name = number_to_str(name_number)
    local score = dget(STORAGE_HIGH_SCORES_START + offset + 1);

    high_scores[i] = { name = name, score = score }
  end

  -- return sort_table_by_field(high_scores, "score", true)
  return high_scores
end

function init_high_scores()
  menu = menu_high_scores
  menu_selected_item = 1
  scene = "high_scores"

  high_scores = get_high_scores()
  high_scores_text = {}

  local max_len = 20 -- in characters

  for i = 1, #high_scores do
    local name = high_scores[i].name
    local score = tostr(high_scores[i].score);

    local index = tostr(i)
    if i < 10 then
      index = " " .. index
    end

    -- name is always 3 characters
    -- 2 charactes for padding
    -- 2 for ordinal number's fullstop and space afterwards
    local dots_count = (max_len - #score - 7 - #index);

    local dots = ""
    for j = 1, dots_count do
      dots = dots .. "."
    end

    high_scores_text[i] = index .. ". " .. name .. " " .. dots .. " " .. score
  end
end

function update_high_scores()
  update_active_menu()
end

function draw_high_scores()
  for i = 1, #high_scores_text do
    print(high_scores_text[i], 24, 35 + 7 * (i - 1), 7)
  end

  draw_active_menu()
end
