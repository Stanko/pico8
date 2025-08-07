function init_stars()
  stars = {}
  stars_global_speed = 1

  for i = 1, 30 do
    stars[i] = {
      x = flr(rnd(128)),
      y = flr(rnd(256)) - 128,
      speed = 1,
      color = 1,
      r = rnd(2)
    }
  end
  for i = 1, 16 do
    stars[i] = {
      x = flr(rnd(128)),
      y = flr(rnd(256)) - 128,
      speed = 2,
      color = 5,
      r = rnd(2)
    }
  end
  for i = 1, 5 do
    stars[i] = {
      x = flr(rnd(128)),
      y = flr(rnd(256)) - 128,
      speed = 3,
      color = 13,
      r = 1
    }
  end
end

function update_stars()
  for i = 1, #stars do
    stars[i].y = stars[i].y + stars[i].speed * stars_global_speed
    if stars[i].y > 127 then
      stars[i].x = flr(rnd(128))
      stars[i].y = flr(rnd(128)) * -1
    end
  end
end

function draw_stars()
  for i = 1, #stars do
    local y = stars[i].y
    local x = stars[i].x
    circfill(x, y, stars[i].r, stars[i].color)
  end
end
