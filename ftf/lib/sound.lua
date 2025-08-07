function play_music()
  if (settings.music == 1) then
    if rnd(1) > 0.5 then
      music(0)
    else
      music(7)
    end
  end
end

function play_sound(sound_id)
  if (settings.sfx == 1) then
    sfx(sound_id)
  end
end
