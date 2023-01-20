local poles_to_check = {
    ["small-electric-pole"] = true,
    ["medium-electric-pole"] = true,
    ["big-electric-pole"] = true,
    ["substation"] = true,
}

if mods["Krastorio2"] and data.raw.recipe["kr-substation-mk2"] then
    poles_to_check["kr-substation-mk2"] = true
end

for technology_name, technology in pairs(data.raw.technology) do
    if not technology.effects then goto continue end

    local effects_to_add = { }
    for index, effect in pairs(technology.effects) do
        if poles_to_check[effect.recipe] then
            poles_to_check[effect.recipe] = false -- Remember to not `enable` recipe itself
            if data.raw.recipe["fluidic-"..effect.recipe.."-in"] then
                -- This is a in/out pole, so we need to also handle the `-in` entity recipe
                effects_to_add[index] = { -- Index shows where to insert at
                    type = "unlock-recipe",
                    recipe = "fluidic-"..effect.recipe.."-in"
                }
            end
        end
    end

    -- Now add the actual techs
    for index, effect in pairs(effects_to_add) do
        -- The index to place the in-pole next to the out-pole
        -- in the `This research unlocks` GUI
        table.insert(technology.effects, index, effect)
    end

    ::continue::
end

-- Find all poles that doesn't need to be unlocked by a technology
-- and unlock those recipes
for pole, needs_technology in pairs(poles_to_check) do
    if needs_technology and data.raw.recipe[pole] then
        data.raw.recipe[pole].enabled = true
        if data.raw.recipe["fluidic-"..pole.."-in"] then
            -- This is a in/out pole, so we need to also handle the `-in` entity recipe
            data.raw.recipe["fluidic-"..pole.."-in"].enabled = true
        end
    end
end