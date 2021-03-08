## Found a bug?

Please let me know! You can do this either in the modpage discussion, or find me on the Official Factorio Discord.

---

## What about my precious UPS?

Your UPS will be fine. Factorio is a *very optimized game*, even when this mod is hacking systems to do something it wasn't really designed for. This mod will require more processing which means you won't be able to build as big as you usually could, similar to other performance heavy mods (e.g. [Rampant](https://mods.factorio.com/mod/Rampant)). But, you can still build a decently sized factory.

How big though? The limits are not well known yet, but it's better than you might think. The worst use-case is a large spread apart factory which with many power poles. Therefore, I made an almost-worst-case 90SPM base as benchmark. It's a very spread-apart 45 SPM base using no beacons or mudules - which is duplicated. All powered from a single location. This base runs at more than 200 UPS on my six year old `i7-4770K` CPU.

Here are some timing information:

```
Update: 4.7 / 3.7 / 9.2
    Game update:    4.6 / 3.6 / 9
        Transport lines:    0.71    / 0.49  / 1.21
        Fluid Manager:      0.03    / 0.01  / 0.15
        Entity Update:      1.48    / 1.08  / 2.79
        Electric Network:   2.35    / 1.87  / 6.19

    Script Update:  0.03 / 0.02 / 0.7
        mod-FluidicPower:   0.03 / 0.02 / 0.06
```

Interesting enough, it's not the `Fluid Manager` that takes the most time. Rather, it's the `Electric Network` update. This is understandable, since each and every pole is it's own seperate electric network, which could introduce a lot of extra calculations. Also note that the transport belts in my main bus still use `more than 8 times` as much processing than the fluids in the mod's power poles!

It's impossible to predict how exactly large you can build. It depends on your PC specs and Factorio layout. But if you have an average CPU, you can definitely finish the game, and *likely* even scale up production to at least 60 SPM, all while still running at 60 UPS. And if you have a beefy CPU, you might even be able to reach a few hundred SPM if built correctly!

---

## Do I need to start a new game?

Yes. At the moment there's no automatic migration from vanilla to Fluidic Power. It is possible to add it to your game, but then it's up to you to make sure there's no vanilla power poles left.

---

## Does it work with other mods?

It should work out of the box if the other mod doesn't touch power poles or create any new power poles. Contact me if you want to make sure that it works with your mods. This also means that overhaul mods like Krastorio or Space Exploration will definitely not work.

---

## Can I still see my total power production and consumption on a graph?
Yes! Open the production GUI (`P`) and click on `Fluids`. There you will see the total amount of energy created and consumed in your world, while not taking transformers into the calculation. To put these numbers into usable terms you can do the following quick calculation:

1. Read the production or consumption per minute, e.g. `1.35M/m` fluid units.
2. Divide it by 60 to get it in `per second`, e.g. `1.35 M/m / 60 = 22.5k/s` fluid units.
3. Hover over the fluid to see the fluid's unit and multiply this value by that unit, e.g. with a unit of `1 fluid = 10kJ` it will be `225 kJ/s`.
4. You just calculated the power production or consumption, e.g. `225kW`. Power (`Watt`) is always Energy (`Joule`) over time.

This means that it's not possible to see the global power produced per entity, but unlike vanilla, it's now possible to see a graph of your `total` power production and consumption.

*Note: If you place normal power poles (i.e. not big poles) in your solar farm it will offset your statistics. Therefore it's better to build solar farms using only source poles and big poles."

---

## No Electric Network Info when I select Big Power Pole?

This is as designed. The `Big Electric Pole` does not consume or supply power, only the other power poles do that. If you want to know the energy level on a Big Power Pole (the amount of fluid inside) place an `Energy Meter` right next to it.

---

## My accumulators aren't supplying power through the source power pole?

That is because accumulators don't work as it does in vanilla where they supply power. They simply store power as a fluid, which means they act as storage tanks. The accumulators connect to one another and you simply transfer the power to and from the accumulators using `normal power poles`.

---

## My accumulators don't charge only when I have excess power?
This is as designed. As mentioned in the previous question, accumulators are simple storage tanks, and not as smart as they are in vanilla. You need to control the flow of power to and from the accumulators yourself using power switches and circuits. See Interesting Challenges on the main mod page.

---

## My accumulators supply power even though I have enough power generation?
See the previous question's answer. 

---

## The Source Pole Seems to draw power from the normal power pole?
This is normal in sub-optimal power generation designs. This happens when a normal pole is right next to a source pole, which creates a feedback loop and will saturate the source pole. Due to the limited amount of electricity usage priorities in Factorio there is currently no way around it. However, it has an easy workaround. Ensure that no normal pole's supply coverage overlaps with a source pole. This is also the perfect location for Big Power Poles, which have no supply coverage at all.

---

## My generators run full speed while they shouldn't?

If you're using `transformers` then it will definitely run full speed for a while to fill up the buffers inside the transformer. Each power pole also has a tiny buffer that needs to fill up. Don't worry, the power isn't disappearing, it's just stored.

If you're transforming your power into `gigajoules` using two `step-up transformers` in series then your powerplant will take a while to fill up the buffers in the transformers. Remember, each unit of `gigajoule` fluid in the transformer buffer is equivalent to 200 vanilla accumulators, and a transformer can easily buffer up to 100. Don't step up the power so high unless you have the means to supply it.

---

## Solar farm not exporting all it's power.

Solar farms work best using only source poles and big poles. If the electric network on a source pole still doesn't show the full output then the network cannot handle the power flow. Use less poles or step-up the voltage using a transformer.