local objectives = {
    sleep = false,
    smell = true,
    checks = {

        -- Act 0
        brewCoffee = false,
        bloodStain = false,
        tidyup = false,
        reorganizeBookshelves = false,
        reviewNotes = false

        -- 
    }
}

function objectives.addCheck(check)
    objectives.checks[check] = true
end
return objectives