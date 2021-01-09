---
toc: Pathfinder Second Edition
summary: How to use Pathfinder Second Edition dice commands.
---

# Rolling Dice in Pathfinder Second Edition

The roll commands on this game have been constructed to be reasonably familiar to those familiar with AresMUSH FS3 games, but the mechanics behind them are compliant with Pathfinder Second Edition.

`roll <dice + modifiers>[= <character list>]`: The <dice + modifiers> string can be any combination of integers, dice to roll, and specific keywords. A keyword that is not recognized will be passed to the roller as 0, so it won't affect the roll.

For example --

`roll 1d20+3-1+5+strength` will find the character's Strength modifier, roll 1d20, and add the string of numbers together to get the result.

Public rolls appear in the log and are sent to everyone in the room. Including the optional <character list> will send the roll only to you and the list of people you specify. In a combat, it will also send the roll to the DM, but it will not attach it to the scene.

`roll/expand <dice + modifiers>[= <character list>]`: As the roll command, but the output will show the outcome of each die rolled.

`rollfor <character> = <dice + modifiers>`: Rolls <dice + modifiers> for another PC. Anyone can do this, but the display cannot be made private and shows the name of the roller as well as the name of the character rolled for. This command is intended to be used to help someone who is AFK or having network issues.

You can also do opposed rolls, either versus another character or versus a flat DC.

`roll <modifiers> vs <string>/<modifiers>`: Rolls 1d20 + your modifier string versus something and their modifier + 1d20. A win by 5 or more is a solid victory, and a win by 10 or more is a crushing victory.

If <string> is another character, <modifiers> can include keywords. If not, it should be integers only, or the result will be inaccurate.

`roll <modifiers> vs <string>/dc<dc>`: As above, except <dc> is a flat integer. Guidance on what this integer should be can be found in the Pathfinder 2E rules. <string> in this case does not check for a character.

These commands have rollfor options, as well:

`rollfor <character> = <modifiers> vs <string>/<modifiers>`
`rollfor <character> = <modifiers> vs <string>/dc<dc>`

### See also: help roll keywords
