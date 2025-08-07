function get_super_weapon_progress()
  local progress = (frame - ship.super_last_shot) / ship.super_shot_delay

  if progress > 1 then
    progress = 1
  end
  return progress
end

function draw_super_weapon_ui()
  local super_progress = get_super_weapon_progress()
  local left = 57

  local outline = 5
  local progress_color = 9

  if (ship.super == 0) then
    progress_color = 13
  end

  -- horizontal lines
  line(left + 1, 1, left + 14, 1, outline)
  line(left + 1, 6, left + 14, 6, outline)
  line(left + 1, 8, left + 14, 8, outline)

  -- vertical lines
  line(left, 2, left, 7, outline)
  line(left + 5, 2, left + 5, 5, outline)
  line(left + 10, 2, left + 10, 5, outline)
  line(left + 15, 2, left + 15, 7, outline)

  line(left + 1, 7, left + flr(super_progress * 14), 7, progress_color)

  for i = 0, ship.super - 1 do
    local x = left + i * 5 + 1
    rectfill(x, 2, x + 3, 5, 9)      -- outer orange rectangle
    rectfill(x + 1, 3, x + 2, 4, 15) -- inner pale rectangle
    line(x + 3, 2, x + 3, 2, 7)      -- white pixel highlight
  end
end
