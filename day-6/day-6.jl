include("../Helpers.jl")

getanswers_anyone(file) = readgroups(file, collect, Set, pushall!)

countanswers_anyone(file) = sum(map(length,getanswers_anyone(file)))

getanswers_everyone(file) = readgroups(file, Set)

function countanswers_everyone_group(answersets)

    numsets = length(answersets)

    if numsets === 0
        return 0
    elseif numsets === 1
        return length(answersets[1])
    else
        bylength = sort(answersets, by = length)
        othersets = bylength[2:numsets]
        answers = filter(ans -> all(ansline -> in(ans, ansline),othersets), collect(bylength[1]))

        return length(answers)
    end
end

countanswers_everyone(file) = sum(map(countanswers_everyone_group, getanswers_everyone(file)))

function test_a()
    return run(countanswers_anyone, [TestPermutation([("test-day-6.txt")], 11)])
end

function test_b()
    return run(countanswers_everyone, [TestPermutation([("test-day-6.txt")], 6)])
end

function run_a()
    return countanswers_anyone("input-6.txt")
end

function run_b()
    return countanswers_everyone("input-6.txt")
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