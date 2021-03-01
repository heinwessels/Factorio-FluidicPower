## Will the UPS be playable?

Yes, it is. You will be able to build a decent sized based without any issues. Obviously you won't be able to build as big as you can in vanilla, but that's exacltly why it isn't part of vanilla.

## Does it work with other mods?

It should work out of the box if the other mod doesn't touch power poles or create any new power poles. Contact me if you want to make sure that it works with your mods. This also means that overhaul mods like Krastorio or Space Exploration will definitely not work.

## Can I see my total power production and consumption on a graph?
Yes! Open the production GUI (`P`) and click on `Fluids`. There you will see the total amount of kilojoules created and consumed in your world, while not taking transformers into the calculation. However, it will also show how much power you stepped up to higher voltages by using your transformers in the `Production`-tab. To put the numbers you see into usable terms you can do the following quick calculation:

1. Read the production or consumption per minute, e.g. `1.35M/m`.
2. Divide it by 60 to get it in `per second`, e.g. `1.35 M/m / 60 = 22.5k/s`.
3. Hover over the fluid to see the unit and multiply this value by that unit, e.g. with a unit of `1 fluid = 10kJ` it will be `225 kJ/s`.
4. You just calculated the power production or consmption, e.g. `225kW`. Power (`Watt`) is always Energy (`Joule`) per second.

## No Electric Network Info when I select Big Power Pole?

This is as designed. The `Big Electric Pole` does not consume or supply power, only the other power poles does that. If you want to know the energy level on a Big Power Pole (the amount of fluid inside) place a `Energy Meter` right next to it.

## The Power Network Overlay doesn't show my power poles are connected when they should be?

This is normal. The overlay algorithm is still under development, and sometimes it doesn't draw a connection to all connected power poles. This effect is more noticable at increased drawing `depth`. If you want to make sure your power poles are connected set the `depth` settings to something lower, e.g. `2`, and it will likely draw the connection. This will be fixed.

## My accumulators isn't supplying power through the source power pole?

That is because accumulators doesn't work as it does in vanilla where they supply power. They simply store the power as a fluid, which makes them storage tanks. The accumulators should connect to one another, and you simply transfer the power to and from the accumulators using normal power poles.

## My accumulators don't charge only when I have excess power?
This is as designed. As mentioned in the previous question, accumulators are simple storage tanks, and not as smart as they are in vanilla. You need to control the flow of power to and from the accumulators yourself using power switches and curcuits. See Interesting Challenges on the main mod page.

## My accumulators supply power even though I have enough power generation?
This is as designed. As mentioned in the previous question, accumulators are simple storage tanks, and not as smart as they are in vanilla. You need to control the flow of power to and from the accumulators yourself using power switches and curcuits. See Interesting Challenges on the main mod page.

## My generators runs full speed while it shouldn't?

If you're using `transformers` then it will definitely run full speed for a while to fill up the buffers inside the transformer. Each powerpole also has a tiny buffer which needs to fill up. Don't worry, the power isn't dissapearing, it's just stored.

If you're transforming your power into `gigajoules` using two `step-up transformers` in series then your powerplant will take a while to fill up the buffers in the transformers. Remember, each unit of `gigajoule` fluid in the transformer buffer is equivalent to 200 vanilla accumulators, and a transformer can easily buffer up to 100. Don't step up the power so high unless you have the means to supply it.


## Some power poles look like there's another one underneath it?

This is normal. What you're seeing is the fluid implementation of the electric pole underneath it, which means it should be there. This is a current limitation of the mod, but I hope to remove make the fluidic entity invisible at some point. (Simply removing the graphic won't work, since it's used when you place the power pole. I have a solution in mind.)