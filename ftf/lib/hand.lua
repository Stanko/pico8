local draw_pile_position = {
  x = 120,
  y = 120
}

local played_position = {
  x = 8,
  y = 120
}

local hand_center_position = {
  x = 64,
  y = 102
}

function init_hand()
  hand_selected_card = 1

  hand_disabled_input = true

  draw_pile_list = {
    "shield",
    "shield",
    "attack",
    "shield",
    "super",
    "super",
    "shield",
    "attack",
    "shield",
    "attack",
    "super",
    "shield",
    "attack",
    "shield",
    "attack",
  }

  played = {
  }

  hand = get_hand()

  hand_total_width = #hand * 9 + (#hand - 1) * 3

  turn = "player"

  for i = 1, #hand do
    local card = hand[i]
    card.x = draw_pile_position.x
    card.y = draw_pile_position.y
  end

  deal_hand()
end

function get_hand(n)
  local hand = {}
  n = n or 5

  -- TODO handle the case when there is not enough cards in the draw pile

  for i = 1, n do
    add(hand, get_card(draw_pile_list[i]))
  end
  return hand
end

function end_player_turn()
  turn = "boss"

  local x = played_position.x
  local y = played_position.y

  for i = #hand, 1, -1 do
    local card = hand[i]

    flip_card(card)
    move_to_over_time(card, x, y, 20, nil, function()
      hand_disabled_input = false
      -- remove card from hand
      deli(hand, 1)
      -- add it to the played pile
      add(played, card.type)

      debug = debug .. "removed: " .. card.type .. " " .. #hand .. "\n"
    end, (i - 1) * 6)
  end
end

function deal_hand()
  hand_disabled_input = true
  for i = 1, #hand do
    local card = hand[i]
    local delay = (i - 1) * 10
    local x = hand_center_position.x - (hand_total_width / 2) + (i - 1) * 12 + 5
    local y = hand_center_position.y

    flip_card(card, delay)
    do_once(function() deli(draw_pile_list, 1) end, delay)
    move_to_over_time(card, x, y, 20, nil, function()
      if (i == #hand) then
        hand_disabled_input = false
      end
    end, delay)
  end
end

function update_hand()
  for i = 1, #hand do
    update_card(hand[i])
  end

  if not hand_disabled_input then
    -- select card
    if btnp(0) then
      hand_selected_card = hand_selected_card - 1
      if hand_selected_card < 1 then
        hand_selected_card = 1
      end
    elseif btnp(1) then
      hand_selected_card = hand_selected_card + 1
      if hand_selected_card > #hand then
        hand_selected_card = #hand
      end
    end

    -- play card
    if btnp(4) then
      local i = hand_selected_card
      local card = hand[i]

      if (ship.energy >= card.cost) then
        ship.energy = ship.energy - card.cost
      else
        play_sound(20)
        return
      end

      if (card.type == "attack") then
        spawn_bullet(ship.x)
      elseif (card.type == "shield") then
        ship.shield += 1
        play_sound(7)
      elseif (card.type == "super") then
        spawn_super_bullets(ship.x, ship.y)
      end

      local x = played_position.x
      local y = played_position.y
      hand_disabled_input = true

      flip_card(card)
      move_to_over_time(card, x, y, 20, nil, function()
        hand_disabled_input = false
        -- remove card from hand
        deli(hand, i)
        -- add it to the played pile
        add(played, card.type)

        debug = debug .. "removed: " .. card.type .. " " .. #hand .. "\n"

        if ship.energy <= 0 or #hand == 0 then
          end_player_turn()
        end
      end)

      hand_selected_card = hand_selected_card - 1
      if hand_selected_card <= 0 then
        hand_selected_card = 1
      end
    elseif btnp(5) then
      end_player_turn()
    end
  end
end

function draw_pile(pile, position)
  for i = 1, #pile do
    local x = position.x - 5
    local y = position.y - (#pile - i + 1) * 3 - 5

    card_back(x, y)
  end
end

function draw_hand()
  print(hand_selected_card, 110, 0, 7)
  print(#hand, 110, 10, 7)

  if #hand > 0 and not hand_disabled_input and hand_selected_card <= #hand then
    local indicator_index = flr(frame / 20) % 2
    spr(198 + indicator_index, hand[hand_selected_card].x - 4, hand[hand_selected_card].y - 16)
  end

  draw_pile(draw_pile_list, draw_pile_position)
  draw_pile(played, played_position)

  for i = #hand, 1, -1 do
    draw_card(hand[i])
  end

  -- draw the ship energy

  -- take the highlight color from the card
  local card_color = 12
  if #hand > 0 and hand[hand_selected_card] then
    local card = hand[hand_selected_card]
    card_color = card.color
  end

  local energy_width = ship.max_energy * 5;
  local left = 64 - energy_width / 2;

  for i = 1, ship.max_energy do
    -- color only the cells felt
    local color = 0
    if i <= ship.energy then
      color = card_color
    end
    card_rect(left + (i - 1) * 5, 114, 5, 2, 2, color)
  end

  -- shield

  local shield_left = flr(ship.x - 2 - (ship.shield - 1) * 5 / 2)
  for i = 1, ship.shield do
    spr(221, shield_left + (i - 1) * 5, ship.y - 14)
  end

  -- hp
  draw_hp_bar(ship.hp, ship.max_hp, 120, 125)
end
