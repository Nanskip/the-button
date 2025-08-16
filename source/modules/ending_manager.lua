local ending_manager = {}

ending_manager.give_ending = function(self, ending)
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

ending_manager.endings = {
    protocolviolation = {
        name = "Protocol violation",
        description = "You cannot be tested anymore.\nTry to think about yourself.",
        badge = true,
    },
}