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
    
    -- What should be placed in the case off
    local cursor_lookup = {}
    cursor_lookup[
        "fluidic-medium-pole-in-electric"
    ] = "fluidic-medium-pole-in"
    cursor_lookup[
        "fluidic-medium-pole-out-electric"
    ] = "fluidic-medium-pole-out"
    cursor_lookup[
        "fluidic-medium-pole-in"
    ] = "fluidic-medium-pole-in-electric"
    cursor_lookup[
        "fluidic-medium-pole-out"
    ] = "fluidic-medium-pole-out-electric"

    if cursor_lookup[entity.name] then
        if not entity_exists_at(cursor_lookup[entity.name], entity.surface, entity.position) 
        then
            entity.surface.create_entity{
                name = cursor_lookup[entity.name],
                position = {x = entity.position.x, y = entity.position.y},
                direction = entity.direction,                
                force = entity.force,
                raise_built = false
            }
        else
            game.print("Didn't place")
        end
    end
end

function power_pole.on_entity_removed(event)
    if event.entity and event.entity.valid then
      local surface = event.entity.surface
      if event.entity.name == "fluidic-medium-pole-in-electric" then
        local e = event.entity.surface.find_entity("fluidic-medium-pole-in", event.entity.position)
        if e then e.destroy{raise_destroy=false} end        
      elseif event.entity.name == "fluidic-medium-pole-out-electric" then
        local e = event.entity.surface.find_entity("fluidic-medium-pole-out", event.entity.position)
        if e then e.destroy{raise_destroy=false} end
      end
    end
end


function entity_exists_at(entity_name, surface, position)
    local e = surface.find_entity(entity_name, position)
    if e then return true end
    return false
end

return power_pole