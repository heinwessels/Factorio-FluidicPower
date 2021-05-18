data:extend({
    {    
        type = "int-setting",
        name = "fluidic-electric-overlay-depth",           
        setting_type = "runtime-global",        
        default_value = 20,
        minimum_value = 0,
        maximum_value = 200
    },
    {
        type = "bool-setting",
        name = "fluidic-enable-build-limitations",
        setting_type = "runtime-global",
        default_value = true
    },    
    {
        type = "bool-setting",
        name = "fluidic-disable-accumulator-alt-info",
        setting_type = "startup",
        default_value = false
    },
})