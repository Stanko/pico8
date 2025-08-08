-- random float, exclusive
function random(a, b)
  return rnd(b - a) + a
end

-- random integer, inclusive
function random_int(a, b)
  return flr(rnd(b - a + 1)) + a
end

function pow(x, y)
  result = x

  for i = 2, y do
    result = result * x
  end

  return result
end

function round(number)
  return flr(number + 0.5)
end
