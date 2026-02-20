local name, Plugin = ...;

do
    local frame = CreateFrame('Frame');
    frame:HookScript('OnEvent', function(_, _, addonName) Plugin:ADDON_LOADED(addonName); end);
    frame:RegisterEvent('ADDON_LOADED');
end

function Plugin:ADDON_LOADED(addonName)
    if addonName ~= name then return; end
    local compatible = false;

    --- @type BlizzMoveAPI
    local BlizzMoveAPI = _G.BlizzMoveAPI;
    if BlizzMoveAPI and BlizzMoveAPI.GetVersion and BlizzMoveAPI.RegisterAddOnFrames then
        local _, _, _, _, versionInt = BlizzMoveAPI:GetVersion();
        if (versionInt == nil or versionInt >= 30200) then
            compatible = true;
        end
    end

    if not compatible then
        print(name .. ' is not compatible with the current version of BlizzMove, please update.');
        return;
    end

    if not RematchFrame then
        print(name .. ' current version of Rematch is not supported by this plugin. Please notify the author of this plugin on CurseForge or GitHub.');
        return;
    end
    hooksecurefunc(RematchFrame, 'SetParent', function(_, parent)
        if parent == CollectionsJournal then
            BlizzMoveAPI:UnregisterFrame('Rematch', 'RematchFrame');
        else
            BlizzMoveAPI:RegisterAddOnFrames({ ['Rematch'] = { RematchFrame = {} } });
        end
    end);
end
