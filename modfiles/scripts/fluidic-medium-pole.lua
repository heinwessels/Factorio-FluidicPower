power_pole = {}

function power_pole.on_entity_created(event)
    local entity
    if event.entity and event.entity.valid then
        entity = event.entity
    end
    if event.created_entity and event.created_entity.valid then
        entity = event.created_entity
    end
    if not entity then return end
    if entity.name == "fluidic-medium-pole-in" or entity.name == "fluidic-medium-pole-out" then        
        local pole = entity.surface.create_entity{
            name = "fluidic-medium-pole-dummy",
            position = {x = entity.position.x, y = entity.position.y},
            direction = entity.direction,                
            force = entity.force
        }
        if entity.name == "fluidic-medium-pole-in" then entity.set_recipe("kilojoules") end
    end
end

function power_pole.on_entity_removed(event)
    if event.entity and event.entity.valid then
      local surface = event.entity.surface
      if event.entity.name == "fluidic-medium-pole-in" or event.entity.name == "fluidic-medium-pole-out" then
        local e = event.entity.surface.find_entity("fluidic-medium-pole-dummy", event.entity.position)
        if e then e.destroy() end        
      end
    end
end

return power_pole