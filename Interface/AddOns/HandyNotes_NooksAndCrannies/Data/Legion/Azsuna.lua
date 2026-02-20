---
--- @file
--- Map point definitions.
---

local _, this = ...

local points = {}
local maps = this.maps

points['azsuna'] = {
  [53804030] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['narthalas_academy'],
  },
  [49005900] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['oceanus_cove'],
  },
  [50805950] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['oceanus_cove'],
  },
  [45805550] = {
    icon = 'poi-door-right',
    type = 'world',
    portal = maps['oceanus_cove'],
  },
  [48105050] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['oceanus_cove'],
  },
  [56106860] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['temple_of_thousand_lights'],
  },
}

points['narthalas_academy'] = {
  [63608770] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['azsuna'],
  },
}

points['oceanus_cove'] = {
  [56308850] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['azsuna'],
  },
  [73209020] = {
    icon = 'poi-door-down',
    type = 'world',
    portal = maps['azsuna'],
  },
  [25005580] = {
    icon = 'poi-door-left',
    type = 'world',
    portal = maps['azsuna'],
  },
  [43201450] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['azsuna'],
  },
}

points['temple_of_thousand_lights'] = {
  [68101250] = {
    icon = 'poi-door-up',
    type = 'world',
    portal = maps['azsuna'],
  },
}

-- Assign all zones to our addon.
for zoneName, data in pairs(points) do
  this.points[maps[zoneName]] = data
end
