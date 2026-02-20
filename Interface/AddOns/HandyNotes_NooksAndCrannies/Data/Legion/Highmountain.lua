---
--- @file
--- Map point definitions.
---

local _, this = ...

local points = {}
local maps = this.maps

points['highmountain'] = {
  [37603360] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['cave_of_blood_trial'],
  },
  [38604280] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['mucksnout_den'],
  },
  [41704710] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['mucksnout_den'],
  },
  [38306120] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['lifespring_cavern_lower'],
  },
  [42402440] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['stonedark_grotto'],
  },
  [33602810] = {
    icon = 'poi-door-right',
    type = 'world',
    portal = maps['feltotem_caverns'],
  },
  [44807220] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['path_of_huln'],
  },
  [47508430] = {
    icon = 'poi-door-right',
    type = 'world',
    portal = maps['path_of_huln_second'],
  },
}

points['cave_of_blood_trial'] = {
  [50301370] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['highmountain'],
  },
}

points['mucksnout_den'] = {
  [33306380] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['highmountain'],
  },
  [54709010] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['highmountain'],
  },
}

points['lifespring_cavern_upper'] = {
  [64703630] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['lifespring_cavern_lower'],
  },
  [37007910] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['lifespring_cavern_lower'],
  },
}

points['lifespring_cavern_lower'] = {
  [39105630] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['lifespring_cavern_upper'],
  },
  [73708150] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['highmountain'],
  },
}

points['stonedark_grotto'] = {
  [20607940] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['highmountain'],
  },
}

points['feltotem_caverns'] = {
  [46601100] = {
    icon = 'poi-door-left',
    type = 'world',
    portal = maps['highmountain'],
  },
}

points['path_of_huln'] = {
  [24704070] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['highmountain'],
  },
  [49608450] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['path_of_huln_second'],
  },
}

points['path_of_huln_second'] = {
  [45501340] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['path_of_huln'],
  },
  [42009100] = {
    icon = 'poi-door-left',
    type = 'world',
    portal = maps['highmountain'],
  },
}

-- Assign all zones to our addon.
for zoneName, data in pairs(points) do
  this.points[maps[zoneName]] = data
end
