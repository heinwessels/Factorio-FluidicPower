utils = {}

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

return utils