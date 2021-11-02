## Found a bug?

Please let me know! You can do this either in the modpage discussion, or find me on the Official Factorio Discord.

---

## What about my precious UPS?

Your UPS will be fine. Factorio is a *very optimized game*, even when this mod is hacking systems to do something it wasn't really designed for. This mod will require more processing which means you won't be able to build as big as you usually could, similar to other performance heavy mods (e.g. [Rampant](https://mods.factorio.com/mod/Rampant)). But, you can still build a fairly big factory, depending on your hardware and factory layout.

In `Fluidic Power` the main `bottleneck` is the `Electric Network` calculations - by a very big margin. This is because each pole creates its own electric network. The game is designed to handle a handful of very large electric networks, but now it needs to manage hundreds of very small ones. Therefore, the most UPS efficient base with Fluidic Power will be the base with the least amount of poles. You're likely wondering about the fluids calculations? Well, the `Fluid Manager`, which does all fluid calculations, has an almost negligible impact on performance in a normal factory.

I built two benchmark bases to get some idea how big a performance hit this mod is and ran the bases until steady state. One base is steam-powered, and the other is solar-powered.  They are both `90 SPM` bases. They are both using a very spread-out main bus, with no modules and also no electric furnaces. It consumes around `280MW` at full pace. My trusty old computer has a 7-year-old `i7-4770k 3.5GHz` CPU.

**Steam Powered: 220+ UPS**
```
Update: 4.38 / 3.02 / 8.81
    Game update:    4.29 / 2.86 / 8.73
        Transport Lines:    0.65    / 0.34  / 1.06
        Fluid Manager:      0.02    / 0.01  / 0.09
        Entity Update:      1.32    / 0.66  / 2.69
        Electric Network:   2.21    / 1.47  / 6.55

    Script Update:  0.04 / 0.01 / 0.08
        mod-FluidicPower:   0.04 / 0.01 / 0.08
```

**Solar Powered: 140+ UPS**
```
Update: 6.25 / 5.16 / 15.18
    Game update:    6.16 / 5.12 / 15
        Transport Lines:    0.70    / 0.44  / 1.26
        Fluid Manager:      0.03    / 0.01  / 0.38
        Entity Update:      1.53    / 1.10  / 2.48
        Electric Network:   3.35    / 2.82  / 12.8

    Script Update:  0.04 / 0.02 / 0.10
        mod-FluidicPower:   0.03 / 0.02 / 0.10
```

Here you can see the clear effect bottleneck of the `Electric Network`. The solar farm requires over 400 more power poles than using steam, which causes the `Electric Network`'s effect to increase drastically. This also means that with Fluidic Power power generation through steam is UPS king. The `Fluid Manager`'s effect on UPS is negligible. For reference, the `Transport Lines` in the main bus is more than 5 times more performance heavy than the fluids. 

Therefore, Fluidic Power is `not too performance heavy`. You can definitely finish the game on average hardware and likely reach 100SPM. And if you build efficiently and/or if you have a beefy CPU, you can even reach a few hundred SPM. All while running at a smooth 60 UPS.


If you want to maximize UPS, remember:

- The fewer power poles the better.
- Compact bases are better.
- Use big poles as far as you can.
- Steam is better than solar.

---

## Do I need to start a new game?

Yes. At the moment there's no automatic migration from vanilla to Fluidic Power. It is possible to add it to your game, but then it's up to you to make sure there's no vanilla power poles left.

---

## Does it work with other mods?

It *should* work out of the box if the other mod doesn't touch power poles or create any new power poles. Contact me if you want to make sure that it works with your mods. This also means that overhaul mods like Krastorio or Space Exploration will definitely not work.

---

## Can I add it to my mod?

Yes. It's just important to remember that Fluidic Power creates all new power poles (all prefixed with ``fluidic-...``), but leaves the vanilla power poles in the game. So you need to be careful to not give players access to the vanilla poles by accident. I've added a tag in the vanilla item and entity description to not use them if you have access to them by accident.

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

## My machines keep browning out?

It happens often in this mod that your machines will intermittently lose power and it might seem like the power poles are not transferring enough power. This is usually caused by not enough power generation, because the fuller the poles the further the power will travel. I also struggled with this in my playthrough and solved this by building a little circuit alarm on my high voltage line that notifies me when the pole's energy drops below 60%.

---

## No Electric Network Info when I select Big Power Pole?

This is as designed. The `Big Electric Pole` does not consume or supply power, only the other power poles do that. If you want to know the energy level on a Big Power Pole (the amount of fluid inside) place an `Energy Meter` right next to it.

---

## My accumulators aren't supplying power through the source power pole?

That is because accumulators don't work as it does in vanilla where they supply power. They simply store power as a fluid, which means they act as storage tanks. The accumulators connect to one another and you simply transfer the power to and from the accumulators using `normal power poles`.

---

## The Source Pole Seems to draw power from the normal power pole?
This is normal in sub-optimal power generation designs. This happens when a normal pole is right next to a source pole, which creates a feedback loop and will saturate the source pole. Due to the limited amount of electricity usage priorities in Factorio there is currently no way around it. However, it has an easy workaround. Ensure that no normal pole's supply coverage overlaps with a source pole. This is also the perfect location for Big Power Poles, which have no supply coverage at all.

---

## My generators run full speed while they shouldn't?

If you're using `transformers` then it will definitely run full speed for a while to fill up the buffers inside the transformer. Each power pole also has a tiny buffer that needs to fill up. Don't worry, the power isn't disappearing, it's just stored, similar to how items are stored on a belt.

If you're transforming your power into `100MJ` units using two `step-up transformers` in series then your powerplant will take a while to fill up the buffers in the transformers. Remember, each unit of `100MJ` fluid in the transformer buffer is equivalent to 20 vanilla accumulators. Don't step up the power so high unless you have the means to supply it.

---

## Solar farm not exporting all it's power.

Solar farms work best using only source poles and big poles. If the electric network on a source pole still doesn't show the full output then the network cannot handle the power flow. Use fewer poles or step-up the voltage using a transformer.

---

## Upgrade Planner is broken

Yes, sort off. It's possible to upgrade small poles to medium poles using the Upgrade Planner when adding no custom filters to it. Further compatibility is still under development, such as downgrading power poles, although that isn't used often.
