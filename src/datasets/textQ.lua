local textQ = {
    timer = 0,
    currentText = " ";
    queued = {}
}

function textQ.add(text)
    table.insert(textQ.queued, text)
end

function textQ.update(dt)
    if textQ.queued ~= {} then
        for i = 1, #textQ.queued do
            textQ.currentText = textQ.queued[i]/6
            while timer < string.len(textQ.queued[i]/6) do
                timer = timer + dt
            end
            textQ.currentText = ""
            table.remove(textQ.queued, i)
        end
    end
end