local function compare(a,b,equal)
  local function veri(verstr)
    local last = 1
    return function()
      local ret, e = string.match(verstr,'(.-)%.()',last)
      if not ret and last < #verstr+1 then
        ret = string.sub(verstr,last)
        last = #verstr+1
        return ret
      end
      last = e
      return ret
    end
  end
  local ai, bi = veri(a), veri(b)
  local av, bv = ai(), bi()
  while av and bv do
    do
      --if both versions can be converted to numbers, compare them as such-
      --otherwise compare both as strings (think "3.0 RC4")
      local an, bn = tonumber(av), tonumber(bv)
      if an and bn then av, bv = an, bn end
    end
    if av < bv then
      return true
    elseif av > bv then
      return false
    end
    av, bv = ai(), bi()
  end
  if av then
    return false
  elseif bv then
    return true
  else
    return equal
  end
end

local vercmp={}

function vercmp.lt(a, b)
  return compare(a, b, false)
end

function vercmp.le(a, b)
  return compare(a, b, true)
end

--NOTE: If you're doing this, really,
--you might as well just compare the strings.
function vercmp.eq(a, b)
  return compare(a, b, "equal") == "equal"
end

return vercmp
