function draw_hp_bar(hp, max_hp, top, bottom)
  local point_width = 3
  local bar_width = max_hp * point_width
  local left = 64 - bar_width / 2

  rectfill(left, top, left + bar_width, bottom, 1);

  for i = 0, max_hp - 1 do
    local x = left + 1 + i * point_width;

    if i < hp then
      rectfill(x, top + 1, x + point_width - 2, bottom - 1, 8);
      rectfill(x + point_width - 2, top + 1, x + point_width - 2, top + 1, 7)
    else
      rectfill(x, top + 1, x + point_width - 2, bottom - 1, 0);
    end
  end
end
