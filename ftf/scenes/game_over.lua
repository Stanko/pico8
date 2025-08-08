function init_game_over()
  level_state = "game_over"
  game_over_start_frame = -1
  game_over_has_high_score = is_high_score()

  if game_over_has_high_score then
    init_enter_name()
  end
end

function update_game_over()
  if (game_over_start_frame == -1) then
    game_over_start_frame = frame
  end

  if (game_over_start_frame > -1 and frame - game_over_start_frame > 30) then
    if game_over_has_high_score then
      update_enter_name(
        function(name)
          game_over_has_high_score = false
          add_high_score(name, score)
        end
      )
    else
      -- game over
      if btnp(4) then
        init_level_one()
        level = 2
      end
      if btnp(5) then
        init_main_menu()
      end
    end
  end

  -- if (hiscore_saved == false and score > hiscore) then
  --   hiscore = score
  --   dset(50, hiscore)
  --   hiscore_saved = true
  -- end
end

function draw_game_over()
  local msg = "game over!"
  print(msg, 64 - #msg * 2, 24, 12)

  if (game_over_start_frame > -1 and frame - game_over_start_frame > 30) then
    if (game_over_has_high_score) then
      msg = "new hiscore! #" .. game_over_has_high_score
      print(msg, 64 - #msg * 2, 40, 7)

      draw_enter_name(50)
    else
      -- add a short delay before the level can be restarted
      msg = "press 🅾️ to restart"
      print(msg, 64 - #msg * 2, 50, 5)
      msg = "or ❎ for menu"
      print(msg, 64 - #msg * 2, 57, 5)
    end
  end

  -- if (hiscore_saved) then
  --   msg = "new hiscore!"
  --   print(msg, 64 - #msg * 2, 85, 7)
  -- end

  music(-1, 500)
end
