---
--- @file
--- Map point definitions.
---

local _, this = ...

local points = {}
local maps = this.maps

points['stormheim'] = {
  [84000950] = {
    icon = 'poi-door-left',
    type = 'world',
    portal = maps['shields_rest'],
  },
  [31405710] = {
    icon = 'poi-door-left',
    type = 'world',
    portal = maps['stormscale_cavern'],
  },
  [29905510] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['stormscale_cavern'],
  },
}

points['shields_rest'] = {
  [75005910] = {
    icon = 'poi-door-right',
    type = 'world',
    portal = maps['stormheim'],
  },
}

points['stormscale_cavern'] = {
  [60501770] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['stormheim'],
  },
  [81504890] = {
    icon = 'poi-door-right',
    type = 'world',
    portal = maps['stormheim'],
  },
}

-- Assign all zones to our addon.
for zoneName, data in pairs(points) do
  this.points[maps[zoneName]] = data
end
