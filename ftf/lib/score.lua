function init_score()
  score = 0
end

function draw_score()
  local score_len = #tostr(score)
  print("score:", 103 - score_len * 4, 2, 5)
  print(score, 127 - score_len * 4, 2, 7)
end
