include("../Helpers.jl")

const dirs = Dict(["N" => 0, "E" => 90, "S" => 180, "W" => 270])

function turn(curdir, dir, degrees)
    turndegrees = dir == "L" ? degrees * -1 : degrees
    return (360 + curdir + turndegrees) % 360
end

function getshift(dir, units)
    if (dir == 0)
        return (units, 0)
    elseif (dir == 90)
        return (0, units)
    elseif (dir == 180)
        return (units * -1, 0)
    else
        return (0, units * -1)
    end
end

move(curpos, dir, units) = curpos .+ getshift(dir, units)



function rotatewaypoint(waypoint, dir, degrees)
    turndegrees = dir == "L" ? 360 + (degrees * -1) : degrees
    newwaypoint = waypoint

    if turndegrees == 90
        return (waypoint[2] * -1, waypoint[1])
    elseif turndegrees == 270
        return (waypoint[2], waypoint[1] * -1)
    elseif turndegrees == 0
        return waypoint
    else
        return map(coord -> coord * -1, waypoint)
    end
end

movetowaypoint(waypoint, curpos, units) = curpos .+ map(coord -> coord * units, waypoint)

function navigate(curstate, instr)
    curdir, curpos = curstate

    command, value = instr

    if haskey(dirs, command)
        return (curdir, move(curpos, dirs[command], value))
    elseif command == "F"
        return (curdir, move(curpos, curdir, value))
    else 
        return (turn(curdir, command, value), curpos)
    end
end

function navigate_waypoint(curstate, instr)

    waypoint,  curpos = curstate

    command, value = instr

    if haskey(dirs, command)
        return (move(waypoint, dirs[command], value), curpos)
    elseif command == "F"
        return (waypoint, movetowaypoint(waypoint, curpos, value))
    else 
        return (rotatewaypoint(waypoint, command, value), curpos)
    end
end


manhattan(coords) = coords |> curry_map(abs) |> sum

navigate(instructions::AbstractVector) = foldfuncl(navigate, instructions, (90, (0,0)))[2]  |> manhattan

navigate_waypoint(instructions::AbstractVector) = foldfuncl(navigate_waypoint, instructions, ((1, 10), (0,0)))[2]  |> manhattan

function readdirection(dir)
    parseregex = r"^([A-Z])(\d+)$"
    matchres = match(parseregex, dir)
    return (matchres[1], parse(Int, matchres[2]))
end

readdirections(file) = readcollection(file, readdirection)

navigate(file) = navigate(readdirections(file))
navigate_waypoint(file) = navigate_waypoint(readdirections(file))

function test_a()
    return run(navigate, [TestPermutation((["tests/test.txt"]), 25)])
end

function test_b()
    return return run(navigate_waypoint, [TestPermutation((["tests/test.txt"]), 286)])
end

function run_a()
    return navigate("input.txt")
end

function run_b()
    return navigate_waypoint("input.txt")
end

println("Test part A")
println(tostring(test_a()))

println("")
println("Result for part A")
println(run_a())

println("")
println("Test part B")
println(tostring(test_b()))

println("")
println("Result for part B")
println(run_b())