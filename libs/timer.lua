local TimerManager = {}
TimerManager.timers = {}

function TimerManager:start(name, timestamp, finish)
    local target_time = tonumber(timestamp)

    for _, timer in ipairs(self.timers) do
        if timer.name == name then
            return false
        end
    end

    local timer = {
        name = name,
        target = target_time,
        finished = false,
        callback = finish
    }

    table.insert(self.timers, timer)
    return true
end

function TimerManager:update()
    local now = os.time()
    local i = 1
    
    while i <= #self.timers do
        local timer = self.timers[i]
        
        if timer.finished then
            table.remove(self.timers, i)
        else
            local remaining = timer.target - now
            if remaining <= 0 then
                timer.finished = true
                if timer.callback then
                    timer.callback()
                end
                table.remove(self.timers, i)
            else
                i = i + 1
            end
        end
    end
end

function TimerManager:stop(name)
    for i, timer in ipairs(self.timers) do
        if timer.name == name then
            timer.finished = true
            table.remove(self.timers, i)
            break
        end
    end
end

function TimerManager:clear()
    self.timers = {}
end

return TimerManager
