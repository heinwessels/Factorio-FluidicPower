utils = {}


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

return utils