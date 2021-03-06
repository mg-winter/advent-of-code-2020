include("../Helpers.jl")


seatid(row, col) = row << 3  + col

position(subsectionposes) = sum(subsectionposes .<< reverse(0:size(subsectionposes, 1)-1))

function convertsection(letter)
    letters = Dict([
        'F' => 0,
        'B' => 1,
        'L' => 0,
        'R' => 1
    ])

    return letters[letter]
end

function readbsp(str)
    arr = collect(str)
    return (map(convertsection, arr[1:7]), map(convertsection, arr[8:10]))
end

function getsectiondata(str)
    pos = readbsp(str)
    row = position(pos[1])
    col = position(pos[2])

    return (row, col, seatid(row, col))
end

function test_a()
    testperms = [
        TestPermutation((["FBFBBFFRLR"]), (44, 5, 357)),
        TestPermutation((["BFFFBBFRRR"]), (70, 7, 567)),
        TestPermutation((["FFFBBBFRRR"]), (14, 7, 119)),
        TestPermutation((["BBFFBBFRLL"]), (102, 4, 820))
    ]
    return run(getsectiondata, testperms)
end

function test_b()
    return []
end

function run_a()
    input = readcollection("input-5.txt")
    results = map(getsectiondata, input)
    return  max(map(res -> res[3], results)...)
end

function run_b()
    input = readcollection("input-5.txt")
    results = map(getsectiondata, input)
    ids = map(res -> res[3], results)
    sorted = sort(ids)

    firsts = 1:(size(sorted, 1) -  1)

    return firsts |> curry_map(i -> (sorted[i], sorted[i+1], sorted[i+1] - sorted[i]), true) |>
                        curry_filter(t -> t[3] == 2) |>
                        curry_map(t -> t[1] + 1)

end

println("Test part A")
println(tostring(test_a(), false))

println("")
println("Result for part A")
println(run_a())

println("")
println("Test part B")
println(tostring(test_b()))

println("")
println("Result for part B")
println(run_b())