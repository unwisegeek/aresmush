---
toc: Pathfinder Second Edition
summary: Pathfinder 2E daily preparation-related commands.
aliases:
- refresh
---

# Daily Preparation Commands

These commands manage daily preparation code. Please note that daily refresh can only be run once every 24 hours. If you need to refresh more often (e.g. for a plot), you'll need to contact staff.

`daily`: Performs a manual daily reset of spells, condition recovery attempts, HP, and other items prepared during daily preparations.
`daily/set <morning|noon|evening>`: Sets up an automatic daily reset to run at 6 AM (morning), 12 noon (noon), or 6 PM (evening) game time each day.
`daily/clear`: Clears automatic daily reset.

In all commands, the word `daily` can be replaced with the word `refresh`, if you prefer. This is for backwards compatibility with the previous edition of Emblem of Ea.

## Staff Command

This command may only be run by game admin.

`daily/reset <character>`: Removes the refresh timer from <character> and allows them to refresh again.
