local mathlib = {}

function mathlib.lerp(a, b, t)
    return a + (b - a) * t
end

function mathlib.easeOutBack(a, b, t)
    local c1 = 0.5
    local c3 = c1 + 1
    local e = 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2
    return a + (b - a) * e
end

function mathlib.round(num)
    return math.floor(num + 0.5)
end

return mathlib