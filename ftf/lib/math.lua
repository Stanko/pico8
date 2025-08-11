-- random float, exclusive
function random(a, b)
  return rnd(b - a) + a
end

-- random integer, inclusive
function random_int(a, b)
  return flr(rnd(b - a + 1)) + a
end
