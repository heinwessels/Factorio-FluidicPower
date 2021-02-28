utils = {}

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
function utils.entity_has_attribute(entity, attribute)
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

return utils