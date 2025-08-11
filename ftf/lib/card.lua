function card_rect(x, y, w, h, outline, fill)
  line(x + 1, y, x + w - 1, y, outline)
  line(x + w, y + 1, x + w, y - 1 + h, outline)
  line(x + w - 1, y + h, x + 1, y + h, outline)
  line(x, y + h - 1, x, y + 1, outline)
  rectfill(x + 1, y + 1, x + w - 1, y + h - 1, fill)
end

function card_back(x, y)
  card_rect(x, y, 9, 12, 2, 1)

  line(x + 1, y + 3, x + 8, y + 10, 0)
  line(x + 1, y + 5, x + 7, y + 11, 0)
  line(x + 1, y + 7, x + 5, y + 11, 0)
  line(x + 1, y + 9, x + 3, y + 11, 0)
  line(x + 1, y + 11, x + 1, y + 11, 0)
end

function card_back_2(x, y)
  card_rect(x, y, 6, 12, 2, 1)

  line(x + 1, y + 4, x + 3, y + 6, 0)
  line(x + 1, y + 6, x + 5, y + 10, 0)
  line(x + 1, y + 8, x + 4, y + 11, 0)
  line(x + 1, y + 10, x + 2, y + 11, 0)
end

function card_back_3(x, y)
  card_rect(x, y, 2, 12, 2, 1)

  line(x + 1, y + 10, x + 1, y + 10, 0)
end

-- function card_side(x, y)
--   line(x, y, x, y + 12, 2)
-- end

function card_front_3(x, y, sprite)
  card_rect(x, y, 2, 12, 2, 1)
  spr(sprite, x + 1, y + 2)
end

function card_front_2(x, y, sprite)
  card_rect(x, y, 6, 12, 2, 1)
  spr(sprite, x + 1, y + 2)
end

function card_front(x, y, sprite)
  card_rect(x, y, 9, 12, 2, 1)
  spr(sprite, x + 1, y + 2)
end

function flip_card(card, delay)
  delay = delay or 0

  card.flip_start = frame + delay
  card.flip_direction = card.flip_direction * -1
end

function update_card(card)
  if not card then return end

  local rate = 3

  update_movement(card)

  if (card.flip_start > 0 and card.flip_start <= frame) then
    local index = flr(((frame - card.flip_start) / rate)) + 1

    if (index > #card.frames) then
      card.flip_start = -1
    else
      if card.flip_direction > 0 then
        card.frame_index = index
      else
        card.frame_index = #card.frames - index + 1
      end
    end
  end
end

function draw_card(card)
  card.frames[card.frame_index]()

  -- draw card cost only when card if face up
  if card.frame_index == 7 then
    local energy_width = card.cost * 4;
    local left = card.x - energy_width / 2;
    for i = 1, card.cost do
      card_rect(left + (i - 1) * 4, card.y + 6, 3, 2, 2, card.color)
    end
  end
end

function get_card(type)
  local sprites = {
    super = { 127, 126, 125 },
    bash = { 159, 158, 157 },
    weak = { 175, 174, 173 },
    shield = { 143, 142, 141 },
    attack = { 111, 110, 109 },
  }
  local cost = {
    super = 2,
    bash = 2,
    weak = 2,
    shield = 1,
    attack = 1,
  }
  local color = {
    super = 9,
    bash = 8,
    weak = 14,
    shield = 12,
    attack = 11,
  }

  local card = {
    type = type,

    x = 120,
    y = 120,

    movement = nil,

    frame_index = 1,
    flip_start = -1,
    flip_direction = -1,

    cost = cost[type],
    color = color[type]
  }

  card.frames = {
    function() card_back(card.x - 5, card.y - 8) end,
    function() card_back_2(card.x - 3, card.y - 8) end,
    function() card_back_3(card.x - 1, card.y - 8) end,
    -- function() card_side(card.x, card.y - 8) end,
    function() card_front_3(card.x - 1, card.y - 8, sprites[type][3]) end,
    function() card_front_2(card.x - 3, card.y - 8, sprites[type][2]) end,
    function() card_front(card.x - 5, card.y - 8, sprites[type][1]) end,
  }

  return card
end
