_addon.name = 'Besieged'
_addon.author  = 'Dean James (Xurion of Bismarck)'
_addon.version = '0.0.1'
_addon.commands = {'besieged', 'bs'}

timeit = require('timeit');
timer = timeit.new()
interval = 300
minimum_interval = 60
requesting = false
last_notification = '' --set empty so the first notification is not an empty one

beastman_statuses_map = {
    0 = 'Training',
    1 = 'Advancing',
    2 = 'Attacking',
    3 = 'Retreating',
    4 = 'Defending',
    5 = 'Preparing',
}

windower.register_event('load', function()
    timer:start()
end)

windower.register_event('prerender', function()
    if timer:check() >= interval and not requesting then
        requesting = true
        request_besieged_data()
        timer:next()
    end
end)

windower.register_event('addon command', function(...)
    if not ... then return end
    local args = {...}
    if args[0] == 'stop' then
        timer:stop()
        windower.add_to_chat(8, 'Besieged alerts stopped')
    else if args[0] == 'start' then
        timer:start()
        windower.add_to_chat(8, 'Besieged alerts resumed')
    else if args[0] == 'interval' and args[1] then
        if type(args[1]) ~= 'number' or args[1] < minimum_interval then
            windower.add_to_chat(8, 'Cannot set interval lower than ' .. minimum_interval)
        else
            interval = args[1]
            windower.add_to_chat(8, 'Interval set to ' .. interval)
        end
    end
end)

windower.register_event('incoming chunk', function(id, packet)
    if id == 0x05E && requesting then
        local notification = '';
        requesting = false
        local besieged_statuses = parse_besieged_packet(packet)

        if besieged_statuses.mamool == 'Attacking' then
            notification = 'Level ' .. besieged_statuses.mamool_level .. ' Mamool Ja Savages are attacking Al Zahbi!\n'
        end

        if besieged_statuses.trolls == 'Attacking' then
            notification = notification .. 'Level ' .. besieged_statuses.trolls_level .. ' Troll Mercenaries are attacking Al Zahbi!\n'
        end

        if besieged_statuses.llamia == 'Attacking' then
            notification = notification .. 'Level ' .. besieged_statuses.llamia_level .. ' Undead Swarm are attacking Al Zahbi!\n'
        end

        if besieged_statuses.mamool == 'Advancing' then
            notification = notification .. 'Level ' .. besieged_statuses.mamool_level .. ' Mamool Ja Savages are advancing towards Al Zahbi!\n'
        end

        if besieged_statuses.trolls == 'Advancing' then
            notification = notification .. 'Level ' .. besieged_statuses.trolls_level .. ' Troll Mercenaries are advancing towards Al Zahbi!\n'
        end

        if besieged_statuses.llamia == 'Advancing' then
            notification = notification .. 'Level ' .. besieged_statuses.llamia_level .. ' Undead Swarm are advancing towards Al Zahbi!\n'
        end

        if notification then
            notification = 'Besieged Update:\n' .. notification;
        end

        --remove last character to prevent extra line feed?

        --Only alert the player if the notification is different from the previous
        if last_notification != notification then
            last_notification = notification
            windower.add_to_chat(8, notification)
        end
    end
end)

function request_besieged_data()
    --send a 0x05A
end

function parse_besieged_packet(packet)
    local mamool_status_code = packet:byte(0) --define packet ID
    local mamool_status = beastman_status_map[mamool_status_code]
    local mamool_level = packet:byte(0) / 1 --define packet ID and divisor
    local trolls_status_code = packet:byte(0) --define packet ID
    local trolls_status = beastman_status_map[trolls_status_code]
    local trolls_level = packet:byte(0) / 1 --define packet ID and divisor
    local llamia_status_code = packet:byte(0) --define packet ID
    local llamia_status = beastman_status_map[llamia_status_code]
    local llamia_level = packet:byte(0) / 1 --define packet ID and divisor

    return {
        mamool = mamool_status,
        mamool_level = mamool_level,
        trolls = trolls_status,
        trolls_level = trolls_level,
        llamia = llamia_status,
        llamia_level = llamia_level,
    }
end
