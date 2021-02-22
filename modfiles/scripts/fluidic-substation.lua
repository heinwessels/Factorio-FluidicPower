power_pole_out = {}

function power_pole_out.on_entity_created(event)
    local entity
    if event.entity and event.entity.valid then
        entity = event.entity
    end
    if event.created_entity and event.created_entity.valid then
        entity = event.created_entity
    end
    if not entity then return end
    if entity.name == "fluidic-substation-out" or entity.name == "fluidic-substation-in" then
        local pole = entity.surface.create_entity{
            name = "fluidic-substation-dummy",
            position = {x = entity.position.x, y = entity.position.y},
            direction = entity.direction,                
            force = entity.force
        }
    end
end

function power_pole_out.on_entity_removed(event)
    if event.entity and event.entity.valid then
      local surface = event.entity.surface
      if event.entity.name == "fluidic-substation-out" or event.entity.name == "fluidic-substation-in" then
        local e = event.entity.surface.find_entity("fluidic-substation-dummy", event.entity.position)
        if e then e.destroy() end        
      end
    end
end

return power_pole_out