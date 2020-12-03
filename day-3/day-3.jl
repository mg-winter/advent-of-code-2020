using DelimitedFiles
using Base
using Printf

function counttrees(roadmap, slope)
    height = size(roadmap, 1)
    width = size(roadmap, 2)

    points = map(step -> ((step-1) * slope[2] + 1, (((step - 1) * slope[1]) % width) + 1), 1:(height ÷ slope[2]))
    
    trees = filter(point -> roadmap[point...] === '#', points)

    return size(trees, 1)
end

getmap(file) = permutedims(hcat(map(collect, readlines(file))...))

function test_a()
    res = counttrees(getmap("test-day-3.txt"), (3, 1))
    println(res)
    return res == 7
end


function test_b()
    roadmap = getmap("test-day-3.txt")
    tests = [((1, 1), 2), ((3, 1), 7), ((5, 1), 3), ((7, 1), 4), ((1, 2), 2)]
    results = map(t -> (t, (res =counttrees(roadmap, t[1]); (res, res === t[2]))), tests)

    resultsonly = map(res -> res[2][1], results)

    mult = prod(resultsonly)

    return (results, mult, mult === 336)
end

function run_b()
    slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
    roadmap = getmap("input-3.txt")

    return prod(map(s -> counttrees(roadmap, s), slopes))
end

println("Test part A")
println(test_a())

println("")
println("Result for part A")
println(counttrees(getmap("input-3.txt"), (3, 1)))

println("")
println("Test part B")
println(test_b())

println("")
println("Result for part B")
println(run_b())

