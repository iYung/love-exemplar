local UI = {}

-- Half-open point test: true if (px, py) is inside rect.
-- rect is {x, y, w, h}. Half-open means x <= px < x+w, y <= py < y+h.
function UI.hit(rect, px, py)
    return px >= rect.x and px < rect.x + rect.w
       and py >= rect.y and py < rect.y + rect.h
end

-- First element in `elements` whose rect contains (px, py), or nil.
function UI.element_at(elements, px, py)
    for _, e in ipairs(elements) do
        if UI.hit(e.rect, px, py) then return e end
    end
    return nil
end

-- Element with matching id, or nil.
function UI.find(elements, id)
    for _, e in ipairs(elements) do
        if e.id == id then return e end
    end
    return nil
end

-- Centre of rect, rounded to whole pixels.
function UI.centre(rect)
    return math.floor(rect.x + rect.w / 2 + 0.5),
           math.floor(rect.y + rect.h / 2 + 0.5)
end

-- True if rects a and b intersect with positive area (shared edges don't count).
function UI.overlaps(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x
       and a.y < b.y + b.h and a.y + a.h > b.y
end

return UI
