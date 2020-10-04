local spellutil = {}

local nextID = 0

function spellutil.newProjID()
    nextID = nextID + 1
    return nextID
end

return spellutil