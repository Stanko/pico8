function init_pickups()
  pickups = {}
end

function spawn_pickup(x, y)
  local rotation_speed = random(0.01, 0.02)

  local pickup_options = {
    {
      condition = ship.power < 3,
      type = "power",
      sprite = { 80, 81 },
    },
    {
      condition = ship.lives < 3,
      type = "hp",
      sprite = { 29, 30 },
    },
    {
      condition = ship.super < 3,
      type = "super",
      sprite = { 96, 97 },
    }
  }

  local p = rnd(pickup_options)

  local radius = random_int(17, 22)
  if (rnd(1) > 0.5) then
    radius = radius * -1
  end

  if (p.condition and rnd(1) > 0.8) then
    add(pickups, {
      x = x,
      y = y,
      center = {
        x = x - cos(frame * rotation_speed) * radius,
        y = y - sin(frame * rotation_speed) * radius
      },
      radius = radius,
      type = p.type,
      sprite = p.sprite,
      speed = 1,
      rotation_speed = rotation_speed,
      r = 5,
      c = { x = 0, y = 0 },
    })
  end

  -- TODO card updates pickups
  -- elseif (#sts.deck <= 17) and rnd(1) > 0.98 then
  --   -- user starts with 14 cards, and can add only 3 more
  --   local cards_options = {
  --     {
  --       type = "weak",
  --       sprite = { card_sprites.weak }
  --     },
  --     {
  --       type = "super",
  --       sprite = { card_sprites.super }
  --     },
  --     {
  --       type = "bash",
  --       sprite = { card_sprites.bash }
  --     }
  --   }
  --   local card = rnd(cards_options)

  --   add(pickups, {
  --     center = { x = enemy.x - cos(frame * 0.01 * rotation_speed) * radius, y = enemy.y - sin(frame * 0.01 * rotation_speed) * radius },
  --     radius = radius,
  --     x = enemy.x,
  --     y = enemy.y,
  --     type = card.type,
  --     sprite = card.sprite,
  --     speed = 1,
  --     rotation_speed = rotation_speed,
  --     r = 6,
  --     c = { x = 0, y = 0 },
  --   })
  -- end
end

function update_pickups()
  for i = #pickups, 1, -1 do
    local pickup = pickups[i]
    pickup.center.y += pickup.speed
    pickup.x = pickup.center.x + cos(frame * pickup.rotation_speed) * pickup.radius
    pickup.y = pickup.center.y + sin(frame * pickup.rotation_speed) * pickup.radius
  end
end

function draw_pickups()
  for i = 1, #pickups do
    local pickup = pickups[i]
    animate(pickup.sprite, pickup.x, pickup.y, 10)
    -- draw_col(pickup)
  end
end
