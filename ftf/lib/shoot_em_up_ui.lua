function draw_shoot_em_up_ui()
  for i = 1, 3 do
    if (i <= ship.lives) then
      spr(30, 2 + (i - 1) * 9, 2)
    else
      spr(31, 2 + (i - 1) * 9, 2)
    end
  end

  for i = 1, ship.power do
    local x = 28 + i * 5
    -- rectfill(x, 2, x + 1, 8, 11)
    spr(12, x, 1)
  end

  draw_super_weapon_ui()
end
