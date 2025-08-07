function init_menu_values(menu)
  for i, item in ipairs(menu) do
    if (item.options) then
      dset(item.location, item.default)
    end
  end
end

function update_active_menu()
  if (btnp(2)) then
    menu_selected_item = (menu_selected_item - 1) % #menu
  elseif (btnp(3)) then
    menu_selected_item = (menu_selected_item + 1) % #menu
  end

  if (menu_selected_item == 0) then
    menu_selected_item = #menu
  end

  local item = menu[menu_selected_item]

  if (item.options and item.location) then
    if (btnp(0) or btnp(1)) then
      local value = dget(item.location)

      if (btnp(0)) then
        value = (value - 1) % #item.options
      else
        value = (value + 1) % #item.options
      end

      dset(item.location, value)
    end
  elseif (item.on_select) then
    if (btnp(4)) then
      item.on_select()
    end
  end
end

function draw_active_menu(pos, colors)
  pos = pos or {}
  local width = pos.width or 80;
  local top = pos.top or 24;
  local left = 64 - width / 2;
  local right = left + width;

  local row = 7;

  colors = colors or {}
  local color = colors.color or 7
  local value_color = colors.value or 12
  local indicator_color = colors.indicator or 9

  print('*', left - 6, top + row * (menu_selected_item - 1), indicator_color)

  for i, item in ipairs(menu) do
    print(item.label, left, top + row * (i - 1), color)

    if (item.options) then
      -- TODO it is probably not a good idea to use dget in the draw loop
      local value = dget(item.location)
      local option_label = item.options[value + 1];
      print(option_label, right - #option_label * 4, top + row * (i - 1), value_color)
    end
  end
end
