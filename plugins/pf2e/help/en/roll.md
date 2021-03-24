---
toc: Pathfinder Second Edition
summary: How to use Pathfinder Second Edition dice commands.
---

# Rolling Dice in Pathfinder Second Edition

The roll commands on this game have been constructed to be reasonably familiar to those familiar with AresMUSH FS3 games, but the mechanics behind them are compliant with Pathfinder Second Edition.

`roll <dice + modifiers>: The <dice + modifiers> string can be any combination of integers, dice to roll, and specific keywords. A keyword that is not recognized will be passed to the roller as 0, so it won't affect the roll.

`roll <dice + modifiers>/<dc>`: As above, except <dc> is a flat integer. Guidance on what this integer should be can be found in the Pathfinder 2E rules, or may be provided by the DM.

For example --

`roll 1d20+3-1+5+strength` will find the character's Strength modifier, roll 1d20, and add the string of numbers together to get the result.

Public rolls appear in the log and are sent to everyone in the room.

`roll/expand <dice + modifiers>[= <character list>]`: As the roll command, but the output will show the outcome of each die rolled.

`rollfor <character> = <dice + modifiers>[/dc]`: Rolls <dice + modifiers> for another PC. Anyone can do this, but the display cannot be made private and shows the name of the roller as well as the name of the character rolled for. This command is intended to be used to help someone who is AFK or having network issues.

`roll/private <dice + modifiers>`: Send a dice roll only to yourself.
