local name,addon=...

local color = {
    accent = 'C33453',
    red = "FF0000",
    green = "00FF00",
    blue = "0000FF",
    white = "FFFFFF",
    black = "000000",
    yellow = "FFFF00",
    orange = "FFA500",
    purple = "800080",
    pink = "FFC0CB",
    brown = "A52A2A",
    grey = "808080",
    cyan = "00FFFF",
    lime = "00FF00",
}
--[[
    w = width of the image
    h = height of the image
    s =  ?
    m = max frames
    is = ?
    se = ?
]]
local stopMotion = {
    [1]={
        img = "Interface\\AddOns\\".. name .."\\StopMotion\\frieren.blp",
        w = 256,
        h = 256,
        speed = 0.15,
        max_frames = 14
    },
    [2]={
        img = "Interface\\AddOns\\".. name .."\\StopMotion\\frieren2.blp",
        w = 256,
        h = 196,
        speed = 0.10
    },
    [3]={
        img = "Interface\\AddOns\\".. name .."\\StopMotion\\frieren3.blp",
        w = 256,
        h = 200,
        speed = 0.10,
        cols = 8,
        rows = 4,
        effect = {
               [16]={.6,.9,1,.4},
               [17]={.12,.52,1,.3},
               [18]=-1,
               [19]=-1,
               [20]={.12,.52,1,.1},
               [24]={.6,.9,1,.3},
               [25]={.12,.52,1,.3},
               [26]={.12,.52,1,.2},
               [27]={.12,.52,1,.1},
               [28]={.12,.52,1,.05},
               [29]=-1
        }
   },
   [4]={
       img = "Interface\\AddOns\\".. name .."\\StopMotion\\Sylvanas.blp",
       w = 256,
       h = 256,
       speed = 0.035,
       cols = 8,
       rows = 8,
       max_frames = 60,
   },
   [5]={
       img = "Interface\\AddOns\\".. name .."\\StopMotion\\Allianz.blp",
       w = 256,
       h = 256,
       speed = 0.035,
       cols = 8,
       rows = 8,
       max_frames = 55,
   },
   [6]={
       img = "Interface\\AddOns\\".. name .."\\StopMotion\\Noko.blp",
       w = 256,
       h = 256,
       speed = 0.040,
       cols = 8,
       rows = 4,
       max_frames = 31,
   },
}

addon.static = {
    color = color,
    stopMotion = stopMotion
}
