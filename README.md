# [Fluidic Power](https://mods.factorio.com/mod/FluidicPower)

This mod changes the power network to use the game's in-built fluid system in an attempt to make electricity more realistic. This makes it possible to add working transformers for high power transmission, and all new and interesting power distribution challenges.

More realistic power distribution has been requested from players for years. Essentially, you shouldn't be able to power your entire factory through a single small power pole. However, the developers decided not to implement this for simplicity and performance reasons. There are outdated mods that have attempted this as well. For example [Flow Network](https://mods.factorio.com/mods/Simdezimon/flownetwork) from Factorio 0.13 and [High Voltage](https://mods.factorio.com/mods/JeroenDStout/highvoltage) for Factorio 0.15. However, both these mods had a massive impact on the game's performance because they manually calculated the power transmission between all poles on every game tick. What sets `Fluidic Power` apart is that it utilizes the game's `built-in fluid system` to simulate the transmission of power between poles. No on tick power calculations are done. 

---

*Note: This mod is still in Alpha. This means there will be no automatic migration from one version to the next. It won't break your save, but you might need to set new transformer recipes for example.*

*Another note: If you're curious about the performance of this mod, or what kind of UPS you will be able to get, see the [FAQ](https://mods.factorio.com/mod/FluidicPower/faq).*

---

## How It Works

The gameplay is designed to be close to vanilla where possible, which means the way you play and understand power stays mostly the same. However, there are of course a few differences that you should know about.

### Basics
This mod simulates power as a fluid using the `Joules` unit. This means that if `1 Joule` of "power fluid" flows through your pole in `1 second` it's the equivalent transmitting `1 Watt`. This fluid will travel through your base in different concentrations (e.g. `1kJ` or `1MJ`) and hopefully power all your entities. These `concentrations` can be seen as the `voltage` that you're transmitting the power, and that's how it will be referred to, but more on that later.

### Two Types of Power poles 

Power poles are similar to pipes. This means they need to be placed inline with one another, and cannot be placed diagonally like vanilla power poles. When placing a power pole you will know it's connected to another pole, similar to how a connection between underground pipes are shown.

There are `two` types of `power poles`. The first is most of the normal power poles, i.e. the small and medium power poles and the substation. These you will use to distribute your power and supply power to your buildings as you would usually. However, each tier pole can only supply a limited amount of power, for example, the small pole can only supply 5MW, but can transmit more.
 
Then there is a new type, the **Power Pole Source**. These are used *only* where you generate your power. You will place these next to steam engines, turbines, solar panels, or any modded power generation building (not accumulators). Currently, these poles cannot connect to one another directly, so you would need to transfer the generated power away by connecting each source pole *directly* to a normal pole (or transformer!). Each tier can only source a limited amount of power to your network. For example, the small electric pole can only source 5MW.

![](https://github.com/heinwessels/Factorio-FluidicPower/blob/main/images/pole-types.png?raw=true)

*Here a source pole (left) transfers the power to the normal pole (right) to power the radar. They look the same but have different icons in `Alt-Mode`. The lack of visual wire will be explained later.*

The big power pole is different in that it can *only* transmit power. It cannot source power from generators or supply any buildings. It's also the only power pole that can transmit higher "voltages", but for that, you would need transformers. More on that next.

![](https://github.com/heinwessels/Factorio-FluidicPower/blob/main/images/big-pole-overlay.png?raw=true)

*Example of how big electric poles can be used to transmit power. Note that small power poles are still requried to source and supply the power from the turbine to the radars, the big poles simply distributes it.*

You probably noticed that's there's currently no visible wire connection between the electric poles in the first picture. Unfortunately, this is a current limitation of the mod. However, you are supplied with a green overlay that shows your connections, as seen in the second picture. This overlay shows all connected entities when selecting any power pole with `Alt-mode` enabled.

### Transformers and Distribution

All power generation and consumption are done at a low voltage More specifically, all machines can only consume `10kJ` units of energy, and similarly, turbines and solar panels can only supply `10kJ` units. This is good enough for a smallish base, but as your factory grows the poles will struggle to transmit sufficient power over larger distances. You could remedy this by attempting to replace low tier poles with higher-tier poles that cross larger distances, similar to how you would use underground pipes. However, this doesn't scale at all and is exactly what the transformers are for.

Transformers will increase the voltage of your power and allow you to distribute your power through the big power poles. For example, a `Transformer` can turn `1000 10kJ` fluid units into a single `10MJ` fluid. This higher voltage should distribute further and more balanced through your network. However, remember you need to bring the voltage down again using another transformer. 

![](https://github.com/heinwessels/Factorio-FluidicPower/blob/main/images/transformer-alt.png?raw=true)

Currently, there are 3 voltage levels, or different fluid concentrations, namely `10kJ`, `1MJ`, and `100MJ`. It's recommended to not use the highest voltage (`100MJ`), except when necessary (See FAQ: `My generators runs full speed while it shouldn't?`). You need to set the voltage to step-up or step-down to, similar to an assembler.

### Other Important Components

With Fluidic Power it's necessary to better manage your flow of power, even more so than in vanilla. Therefore you are provided with the following components:

- **Accumulator:** This mod turns electricity into a fluid means it also turns accumulators into simple storage of fluid. Currently, a single accumulator will store `5MJ`. However, you will have to manage when to charge and when to discharge them yourself. 

- **Power Switch:** This is what it says, allows or stops the flow of power. It needs to be built inline between power poles. This switch acts as a pump, which means it also acts as a `one-way` valve, and is `on` by default. The network `overlay` will show a connection regardless of if the switch is `on` or `off`. Unfortunately, the switch won't visually disconnect as it does in vanilla, but the sparks do move.

- **Energy Sensor:** This is a little sensor that measures the power level of a power pole - or more accurately - the amount of energy currently in the pole. This entity also has another useful feature, it has a `Flush` button to clean all the connected power poles of any power (be careful). It needs to be placed directly adjacent to a power pole.

---

### New Challenges

This mod will create all kind of new power distribution challenges! For example, how will you store power during the night when accumulators act as simple storage tanks?

Here you can see an example of how such an accumulator power storage could look like, showing some of the different components. The two transformers ensure the accumulators function at the required voltage, but the voltage is increased as it connects to the Big Electric Poles. The power switches control the flow (the bottom one is enabled in the picture).

![](https://github.com/heinwessels/Factorio-FluidicPower/blob/main/images/example-accumulator.png?raw=true)