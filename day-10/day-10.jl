include("../Helpers.jl")

function countruns(adapters, desirednum)
    sorted = sort(adapters)
    res = []
    currun = 0
    prev = 0
    for adapter = sorted
        diff = adapter - prev
       if diff == desirednum
            currun += 1
       else
            if currun > 0
                push!(res, currun)
            end
            currun = 0
        end
        prev = adapter
    end

    if currun > 0
        push!(res, currun)
    end

    return res

end
function countdiffs(adapters::AbstractVector)
    diffs = Dict()

    curr = 0
    sorted = sort(adapters)

    for adapter = sorted
        diff = adapter - curr
        if haskey(diffs, diff)
            diffs[diff] += 1
        else 
            diffs[diff] = 1
        end

        curr = adapter
    end



    return diffs
end

countdiffs(file) = countdiffs(readnumbers(file))

function countdiffs_a(file) 
    res = countdiffs(file)
    num3s = haskey(res, 3) ? res[3] : 0
    return((res[1], num3s + 1))
end

function countarrangements(file)
    res  = readnumbers(file)

    #count runs of 1
    runs = countruns(res, 1)

    #get runs where at least 1 adapter can be removed without breaking the rules;
    #count the number of adapters in the middle of the run (ie not first or last),
    #as these are removable
    rangeswithremovable = map(r -> r - 1, filter(r -> r > 1, runs))

    #there are no runs with more than 3 adapters in the middle.
    #For runs of < 3 adapters in the middle, any combination of
    # middle adapters can be removed.
    # For runs of 3 adapters in the middle, only 0, 1, or 2 can be removed.  
    # Otherwise the difference between the edge adapters would be too big.
    # If we wanted to support runs of > 3 adapters in the middle, the formula
    # would have to be adapted for the fact that no more than 2 immediately 
    # adjacent adapters can be removed

    removaloptions = map(r -> r + binomial(r, 2) + 1, rangeswithremovable)

    return prod(removaloptions)

end

function test_a()
    return run(countdiffs_a, [TestPermutation((["tests/test-short.txt"]), (7, 5)), TestPermutation((["tests/test-long.txt"]), (22, 10))])
end

function test_b()
    return run(countarrangements, [TestPermutation((["tests/test-short.txt"]), 8), TestPermutation((["tests/test-long.txt"]), 19208)])
end

function run_a()
    res = countdiffs_a("input.txt")
    return (res, prod(res))
end

function run_b()
    return countarrangements("input.txt")
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