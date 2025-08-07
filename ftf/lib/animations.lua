function init_animations()
  animations = {}
end

-- anim is an animation object containing:
-- frames
-- position - { x, y } or an existing object if you want animation to follow it
-- offset - { x, y } - optional - practical if you want to position it relative to the object
-- rate
-- delay - optional
-- bg_color - optional
function add_animation(anim, callback)
  local delay = anim.delay or 0
  local offset = anim.offset or { x = 0, y = 0 }

  add(animations, {
    start = frame + delay,
    position = anim.position,
    offset = offset,
    frames = anim.frames,
    rate = anim.rate,
    bg_color = anim.bg_color,
    callback = callback,
    index = -1,
  })
end

function update_animations()
  for i = #animations, 1, -1 do
    local anim = animations[i]
    local delta = frame - anim.start


    if (delta > 0) then
      anim.index = flr(delta / anim.rate) + 1

      -- animations is done
      if (anim.index > #anim.frames) then
        if (anim.callback) then
          anim.callback()
        end

        deli(animations, i)
      end
    end
  end
end

function draw_animations()
  for i = 1, #animations do
    local anim = animations[i]

    if (anim.bg_color) then
      palt(0, false)            -- make black non transparent
      palt(anim.bg_color, true) -- transparent color
    end

    if (anim.index > 0) then
      local frame = anim.frames[anim.index]
      local x = anim.position.x + anim.offset.x
      local y = anim.position.y + anim.offset.y

      if (type(frame) == "number") then
        -- single sprite
        spr(frame, x - 4, y - 4)
      else
        -- multi sprite
        multi_spr(frame, x, y)
      end
    end

    if (anim.bg_color) then
      palt() -- reset
    end
  end
end
