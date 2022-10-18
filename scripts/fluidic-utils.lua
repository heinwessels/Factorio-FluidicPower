local utils = {}

utils.entity_fluid_to_electric_lu = { }
utils.entity_fluid_to_electric_lu[
    "fluidic-small-electric-pole-in"
] = "fluidic-small-electric-pole-in-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-small-electric-pole-out"
] = "fluidic-small-electric-pole-out-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-medium-electric-pole-in"
] = "fluidic-medium-electric-pole-in-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-medium-electric-pole-out"
] = "fluidic-medium-electric-pole-out-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-substation-in"
] = "fluidic-substation-in-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-substation-out"
] = "fluidic-substation-out-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-big-electric-pole"
] = "fluidic-big-electric-pole-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-kr-substation-mk2-in"
] = "fluidic-kr-substation-mk2-in-electric"
utils.entity_fluid_to_electric_lu[
    "fluidic-kr-substation-mk2-out"
] = "fluidic-kr-substation-mk2-out-electric"

utils.entity_electric_to_fluid_lu = { }
utils.entity_electric_to_fluid_lu[
    "fluidic-small-electric-pole-in-electric"
] = "fluidic-small-electric-pole-in"
utils.entity_electric_to_fluid_lu[
    "fluidic-small-electric-pole-out-electric"
] = "fluidic-small-electric-pole-out"
utils.entity_electric_to_fluid_lu[
    "fluidic-medium-electric-pole-in-electric"
] = "fluidic-medium-electric-pole-in"
utils.entity_electric_to_fluid_lu[
    "fluidic-medium-electric-pole-out-electric"
] = "fluidic-medium-electric-pole-out"
utils.entity_electric_to_fluid_lu[
    "fluidic-substation-in-electric"
] = "fluidic-substation-in"
utils.entity_electric_to_fluid_lu[
    "fluidic-substation-out-electric"
] = "fluidic-substation-out"
utils.entity_electric_to_fluid_lu[
    "fluidic-big-electric-pole-electric"
] = "fluidic-big-electric-pole"
utils.entity_electric_to_fluid_lu[
    "fluidic-kr-substation-mk2-in-electric"
] = "fluidic-kr-substation-mk2-in"
utils.entity_electric_to_fluid_lu[
    "fluidic-kr-substation-mk2-out-electric"
] = "fluidic-kr-substation-mk2-out"

function utils.get_fluidic_entity_from_electric(entity)
	-- Given the electric part of a fluidic power pole,
	-- return the fluidic entity
	local fluidic_name = utils.entity_electric_to_fluid_lu[entity.name]
	if fluidic_name then
		-- It is one of the fluidic poles. Return the fluidic entity
		return entity.surface.find_entity(
			fluidic_name, 
			entity.position
		)
	end
	
	-- No fluidic entity found
	return nil
end


-- Recreation of the one in lualib, except for
-- fixing the odd usage of `B`
function utils.format_number(amount, append_suffix)
    local suffix = ""
    if append_suffix then
        local suffix_list =
        {
            ["T"] = 1000000000000,
            ["G"] = 1000000000,   -- `G` and not `B`!
            ["M"] = 1000000,
            ["k"] = 1000,
            [""] = 1  -- Otherwise below 1k formats odd. Probably hack and not actual problemssa
        }
        for letter, limit in pairs (suffix_list) do
            if math.abs(amount) >= limit then
                amount = math.floor(amount/(limit/10))/10
                suffix = letter
                break
            end
        end
    end
    return amount..suffix
end

function utils.overwrite_technology_for_recipe(old_recipe, new_recipe)
	-- Looks for all technologies that unlocks the old_recipe,
	-- and replaces said recipe with a new_recipe
	for _, technology in pairs(data.raw.technology) do		
		if not technology.enabled and technology.effects then			
			for _, effect in pairs(technology.effects) do
				if effect.type == "unlock-recipe" then					
					if effect.recipe == old_recipe then
						-- Overwrite the result
						effect.recipe = new_recipe
					end
				end
			end
		end
	end
end

function utils.find_technology_for_recipe(recipe)
	-- Looks for the technology that unlocks the recipe
	for _, technology in pairs(data.raw.technology) do		
		if not technology.enabled and technology.effects then			
			for _, effect in pairs(technology.effects) do
				if effect.type == "unlock-recipe" then					
					if effect.recipe == recipe then
						return technology.name
					end
				end
			end
		end
	end
	return nil
end

-- Check if an entity have an attribute,
-- check that if entity is not null too
-- Credit to Fluid Must Flow mod
-- @entity, entity to check attributes
-- @attribute, attribute to check existence
function utils.table_has_attribute(entity, attribute)
	if (entity and type(entity) == "table") or type(attribute) == "string" then
		local no_err, _ = pcall(function() return entity[attribute] end)
		return no_err
	end
	return nil
end


function utils.entity_exists_at(entity_name, surface, position)
    local e = surface.find_entity(entity_name, position)
    if e then return true end
    return false
end

function utils.drop_items_with_decon(surface, force, items, position)
    -- Drops an item at the position and mark it with the
	-- decontruction planner so that a robot would pick it up.
	surface.spill_item_stack(
		position,
		items,
		true, 	-- will automatically be picked up by player force
		force,
		false	-- Allow belts is false
	)
end

function utils.get_fluid_neighbours(entity)
    -- Returns all fluid neighbours of this entity    
    local neighbours = {}
    local neighbours_lu = {}    -- Ensures no duplicate entries

    -- Is this a valid entity with neighbours we want?
    if not utils.table_has_attribute(entity, "neighbours") then return neighbours end
    if #entity.fluidbox == 0 then return neighbours end
    if not entity.neighbours then return neighbours end

    -- It does. Look at it's neighbours
    for _, neighbours_section in pairs(entity.neighbours) do
        if next(neighbours_section) == nil then break end    -- Table is empty
        for _, neighbour in ipairs(neighbours_section) do            
            if not neighbours_lu[neighbour.unit_number] then
                table.insert(neighbours, neighbour)
                neighbours_lu[neighbour.unit_number]=true
            end
        end 
    end
    return neighbours
end

function utils.is_connection_fluids_mixed(this_entity, that_entity)
    if not this_entity.neighbours or 
            not that_entity.neighbours then return false end
    for this_index = 1, #this_entity.fluidbox do
        if this_entity.fluidbox[this_index] then
            local this_fluid = this_entity.fluidbox[this_index]
            for _, that_fluidbox in pairs(this_entity.fluidbox.get_connections(this_index)) do
                if that_fluidbox.owner.unit_number == that_entity.unit_number then
                    -- We now this is a connection between this and that entity
                    for that_index = 1, #that_fluidbox do
                        if that_fluidbox[that_index] ~= nil then
                            -- Now we must make sure that that fluidbox is actually
                            -- connected to this
                            for _, backtrack_fluidbox in pairs(that_fluidbox.get_connections(that_index)) do
                                if backtrack_fluidbox.owner.unit_number == this_entity.unit_number then
                                    local that_fluid = that_fluidbox[that_index]
                                    if this_fluid.name ~= that_fluid.name then
                                        return {this_fluid, that_fluid}
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

return utils