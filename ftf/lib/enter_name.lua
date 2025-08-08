local max_str_len = 3

-- charset and maps
local charset     = "abcdefghijklmnopqrstuvwxyz0123456789 ._-*"
local char_to_int = {}
local int_to_char = {}

for i = 1, #charset do
  local ch = sub(charset, i, i)
  char_to_int[ch] = i - 1
  int_to_char[i - 1] = ch
end

function str_to_number(s)
  local v = {}
  for i = 1, max_str_len do
    local ch = sub(s, i, i) or "a"
    local idx = char_to_int[ch] or 0
    v[i] = idx
  end
  return v[1] / #charset + v[2] + v[3] * #charset
end

function number_to_str(number)
  local c1 = (round((number % 1) * #charset))
  local c2 = (flr(number) % #charset)
  local c3 = (flr(number - c2) / #charset) -- % #charset

  local ch1 = int_to_char[c1] or 'a'
  local ch2 = int_to_char[c2] or 'a'
  local ch3 = int_to_char[c3] or 'a'

  return ch1 .. ch2 .. ch3
end

-- initialize name input
function init_enter_name()
  name_selected_letter = 1
  local last_name = dget(STORAGE_HIGH_SCORES_LAST_NAME)
  name = number_to_str(last_name)
end

-- update name input
function update_enter_name(callback)
  -- left/right to move cursor
  if btnp(0) then
    name_selected_letter = (name_selected_letter - 2) % max_str_len + 1
  elseif btnp(1) then
    name_selected_letter = name_selected_letter % max_str_len + 1
  end

  -- get current char index
  local ch = sub(name, name_selected_letter, name_selected_letter) or "a"
  local idx = char_to_int[ch] or 0

  -- up/down to cycle through chars
  if btnp(2) then
    idx = (idx - 1) % #charset
  elseif btnp(3) then
    idx = (idx + 1) % #charset
  end

  local new_ch = int_to_char[idx] or "."
  name = sub(name, 1, name_selected_letter - 1) ..
      new_ch ..
      sub(name, name_selected_letter + 1, max_str_len)

  -- save name
  if (btnp(4) or btnp(5)) and callback then
    dset(STORAGE_HIGH_SCORES_LAST_NAME, str_to_number(name))
    callback(name)
  end
end

-- draw name input UI
function draw_enter_name(top)
  top = top or 20
  local left = 54

  local msg = "use arrows to enter name"
  print(msg, 64 - #msg * 2, top, 5)
  msg = "🅾️ or ❎ to save"
  print(msg, 64 - #msg * 2, top + 7, 5)

  local ui_string = ""
  for i = 1, max_str_len do
    local ch = sub(name, i, i)
    ui_string = ui_string .. ch .. " "
  end
  print(ui_string, left, top + 14, 7)

  print("^", left + (name_selected_letter - 1) * 8, top + 21, 9)

  -- debug
  -- print("debug:")
  -- print("name: " .. name)
  -- print("encoded: " .. str_to_number(name))
  -- print("decoded: " .. number_to_str(str_to_number(name)))
end
