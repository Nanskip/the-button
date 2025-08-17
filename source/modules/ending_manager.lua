local ending_manager = {}

ending_manager.give_ending = function(self, ending)
    if ending == nil then
        debug.log("Ending Manager: Ending is nil.")
    end
    debug.log("Ending Manager: Giving ending: " .. ending)

    local ending_data = ending_manager.endings[ending]
    if ending_data ~= nil then
        if ending_data.badge then
            _BADGES:unlockBadge(ending, function(err)
                if err == nil then
                    debug.log("Ending Manager: Ending unlocked: " .. ending)
                else
                    debug.log("Ending Manager: Error unlocking ending: " .. err)
                end
            end)
        end
    end
end

ending_manager.restart = function(self)
    debug.log("Ending Manager: Restarting game.")
    for i=1, World.ChildrenCount do
        -- destroy all objects, except tagged with _IS_DEFAULT
        if World:GetChild(i)._IS_DEFAULT or World:GetChild(i) == Player then
            debug.log("Item [" .. i .. "]: " .. tostring(World:GetChild(i)) .. " is default.")
        else
            if World:GetChild(i).Destroy ~= nil then
                World:GetChild(i):Destroy()
            end
        end
    end

    for i=1, map_manager.map.ChildrenCount do
        if map_manager.map:GetChild(i).Destroy ~= nil then
            map_manager.map:GetChild(i):Destroy()
        end
    end

    for i=1, #map_manager.timers do
        map_manager.timers[i]:Cancel()
        map_manager.timers[i] = nil
    end
end

ending_manager.endings = {
    protocolviolation = {
        name = "Protocol violation",
        description = "You cannot be tested anymore.\nTry to think about yourself.",
        badge = true,
    },
}