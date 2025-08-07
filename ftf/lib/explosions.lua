function spawn_explosion(x, y, delay)
  add_animation({
    delay = delay,
    position = { x = x, y = y },
    frames = { 45, 46, 47 },
    rate = 3,
  })
end

function spawn_large_explosion(x, y, delay)
  add_animation({
    delay = delay,
    position = { x = x, y = y },
    frames = {
      59,
      { { 60, 61 }, { 76, 77 } },
      { { 62, 63 }, { 78, 79 } },
    },
    rate = 2,
  })
end

function spawn_explosions(x, y, x_offset, y_offset, count, delay)
  for i = 1, count do
    if rnd(1) > 0.5 then
      spawn_large_explosion(
        x + flr(rnd(x_offset) - x_offset / 2),
        y + flr(rnd(y_offset) - y_offset / 2),
        flr(rnd(delay))
      )
    else
      spawn_explosion(
        x + flr(rnd(x_offset) - x_offset / 2),
        y + flr(rnd(y_offset) - y_offset / 2),
        flr(rnd(delay))
      )
    end
  end
end
