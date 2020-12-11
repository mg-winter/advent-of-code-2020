include("../Helpers.jl")

function counttrees(roadmap, slope)
    height = size(roadmap, 1)
    width = size(roadmap, 2)

    points = map(step -> ((step-1) * slope[2] + 1, (((step - 1) * slope[1]) % width) + 1), 1:(height ÷ slope[2]))
    
    trees = filter(point -> roadmap[point...] === '#', points)

    return size(trees, 1)
end

getmap(file) = readgrid(file, nothing)

function test_a()
    return run(Test(counttrees, TestPermutation((getmap("test-day-3.txt"), (3, 1)), 7)))
end


function test_b()
    roadmap = getmap("test-day-3.txt")
    tests = [((1, 1), 2), ((3, 1), 7), ((5, 1), 3), ((7, 1), 4), ((1, 2), 2)]
    testperms = map(t -> TestPermutation((roadmap, t[1]), t[2]), tests)

    results =  run(counttrees, testperms)
    results_args = [[results]]
    return [results, run(Test(prod ∘ curry_map(res -> res.actual, false), (TestPermutation(results_args, 336))))]
end

function run_b()
    slopes = [(1, 1), (3, 1), (5, 1), (7, 1), (1, 2)]
    roadmap = getmap("input-3.txt")

    return prod(map(s -> counttrees(roadmap, s), slopes))
end

println("Test part A")
println(tostring(test_a()))

println("")
println("Result for part A")
println(counttrees(getmap("input-3.txt"), (3, 1)))

println("")
println("Test part B")
println(map(tostring, test_b()) |> joinparas)

println("")
println("Result for part B")
println(run_b())

