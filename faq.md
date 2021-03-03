## Found a bug?

Please let me know! You can do this either in the modpage discussion, or find me on the Official Factorio Discord.

## Will the UPS be playable?

Yes, it definitely playable and won't bring your PC to a halt. You will be able to build a decently sized base without any issues. Obviously, you won't be able to build as big as you could without this mod, but that's exactly the reason why it isn't part of vanilla. If your computer can run an unoptimized megabase, then you can build a solid base with this mod.

Watch this space for some real data.

## Does it work with other mods?

It should work out of the box if the other mod doesn't touch power poles or create any new power poles. Contact me if you want to make sure that it works with your mods. This also means that overhaul mods like Krastorio or Space Exploration will definitely not work.

## Can I still see my total power production and consumption on a graph?
Yes! Open the production GUI (`P`) and click on `Fluids`. There you will see the total amount of energy created and consumed in your world, while not taking transformers into the calculation. To put these numbers into usable terms you can do the following quick calculation:

1. Read the production or consumption per minute, e.g. `1.35M/m` fluid units.
2. Divide it by 60 to get it in `per second`, e.g. `1.35 M/m / 60 = 22.5k/s` fluid units.
3. Hover over the fluid to see the fluid's unit and multiply this value by that unit, e.g. with a unit of `1 fluid = 10kJ` it will be `225 kJ/s`.
4. You just calculated the power production or consumption, e.g. `225kW`. Power (`Watt`) is always Energy (`Joule`) over time.

This means that it's not possible to see the global power produced per entity, but unlike vanilla, it's now possible to see a graph of your `total` power production and consumption.

## No Electric Network Info when I select Big Power Pole?

This is as designed. The `Big Electric Pole` does not consume or supply power, only the other power poles do that. If you want to know the energy level on a Big Power Pole (the amount of fluid inside) place an `Energy Meter` right next to it.

## The Power Network Overlay doesn't show my power poles are connected when they should be?

This is normal. The overlay algorithm is still under development, and sometimes it doesn't draw a connection to all connected power poles. This effect is more noticeable at increased drawing `depth`. If you want to make sure your power poles are connected set the `depth` settings to something lower, e.g. `2`, and it will likely draw the connection. This will be fixed.

## My accumulators aren't supplying power through the source power pole?

That is because accumulators don't work as it does in vanilla where they supply power. They simply store power as a fluid, which means they act as storage tanks. The accumulators connect to one another and you simply transfer the power to and from the accumulators using `normal power poles`.

## My accumulators don't charge only when I have excess power?
This is as designed. As mentioned in the previous question, accumulators are simple storage tanks, and not as smart as they are in vanilla. You need to control the flow of power to and from the accumulators yourself using power switches and circuits. See Interesting Challenges on the main mod page.

## My accumulators supply power even though I have enough power generation?
See the previous question's answer. 

## The Source Pole Seems to draw power from the normal power pole?
This is normal in sub-optimal power generation designs. This happens when a normal pole is right next to a source pole, which creates a feedback loop and will saturate the source pole. Due to the limited amount of electricity usage priorities in Factorio there is currently no way around it. However, it has an easy workaround. Ensure that no normal pole's supply coverage overlaps with a source pole. This is also the perfect location for Big Power Poles, which have no supply coverage at all.

## My generators run full speed while they shouldn't?

If you're using `transformers` then it will definitely run full speed for a while to fill up the buffers inside the transformer. Each power pole also has a tiny buffer that needs to fill up. Don't worry, the power isn't disappearing, it's just stored.

If you're transforming your power into `gigajoules` using two `step-up transformers` in series then your powerplant will take a while to fill up the buffers in the transformers. Remember, each unit of `gigajoule` fluid in the transformer buffer is equivalent to 200 vanilla accumulators, and a transformer can easily buffer up to 100. Don't step up the power so high unless you have the means to supply it.