function init_single_actions()
  single_actions = {}
end

function do_once(action, delay)
  delay = delay or 0

  add(single_actions, {
    action = action,
    start = frame + delay
  })
end

function update_single_actions()
  for i = #single_actions, 1, -1 do
    local action = single_actions[i]

    if action.start <= frame then
      action.action()
      deli(single_actions, i)
    end
  end
end
