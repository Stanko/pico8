local charset = "_abcdefghijklmnopqrstuvwxyz0123456789"
local char_to_int = {}
for i = 1, #charset do
  char_to_int[sub(charset, i, i)] = i - 1
end

local int_to_char = {}
for i = 1, #charset do
  int_to_char[i - 1] = sub(charset, i, i)
end

function str_to_int(s)
  local n = 0
  for i = 1, 3 do
    local ch = sub(s, i, i)
    n = n * #charset + char_to_int[ch]
  end
  return n
end

function int_to_str(n)
  local s = ""
  for i = 1, 3 do
    local rem = n % #charset
    s = int_to_char[rem] .. s
    n = flr(n / #charset)
  end
  return s
end

function init_enter_name()
  name_selected_letter = 1
  name = "aaa"
end

function update_enter_name(callback)
  if btnp(0) then
    name_selected_letter = (name_selected_letter - 1) % 3
  elseif btnp(1) then
    name_selected_letter = (name_selected_letter + 1) % 3
  end

  if name_selected_letter == 0 then
    name_selected_letter = 3
  end

  local idx = char_to_int[sub(name, name_selected_letter, name_selected_letter)]

  if btnp(2) then
    idx = (idx - 1) % #charset
  elseif btnp(3) then
    idx = (idx + 1) % #charset
  end

  local new_ch = int_to_char[idx]
  name = sub(name, 1, name_selected_letter - 1) .. new_ch .. sub(name, name_selected_letter + 1)

  if btnp(4) then
    callback(name)
  end
end

function draw_enter_name(top)
  top = top or 20
  local left = 54

  print("*", left + (name_selected_letter - 1) * 8, top, 9)

  local ui_string = ""
  for i = 1, 3 do
    local ch = sub(name, i, i)
    ui_string = ui_string .. ch .. " "
  end
  print(ui_string, left, top + 7, 7)

  -- for debug purposes only
  -- print(str_to_int(name), left, top + 14, 9)
end
