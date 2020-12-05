include("../Helpers.jl")


seatid(row, col) = row * 8  + col

function subsection(section, is_lower)
    diff = section[2] - section[1]
    middle = section[1] + ((section[2] - section[1] - 1) ÷ 2)
    return is_lower ? (section[1], middle) : (middle + 1, section[2])
end

function position(startsection, subsectionposes)

    section = startsection

    for is_lower = subsectionposes
        section = subsection(section, is_lower)
    end

    return section[1]
end

function convertsection(letter)
    letters = Dict([
        'F' => true,
        'B' => false,
        'L' => true,
        'R' => false
    ])

    return letters[letter]
end

function readbsp(str)
    arr = collect(str)
    return (map(convertsection, arr[1:7]), map(convertsection, arr[8:10]))
end

function getsectiondata(rowsections, colsections, str)
    pos = readbsp(str)
    row = position(rowsections, pos[1])
    col = position(colsections, pos[2])

    return (row, col, seatid(row, col))
end

getsectiondata_a(str) = getsectiondata((0, 127), (0,8), str)
function test_a()
    testperms = [
        TestPermutation((["FBFBBFFRLR"]), (44, 5, 357)),
        TestPermutation((["BFFFBBFRRR"]), (70, 7, 567)),
        TestPermutation((["FFFBBBFRRR"]), (14, 7, 119)),
        TestPermutation((["BBFFBBFRLL"]), (102, 4, 820))
    ]
    return run(getsectiondata_a, testperms)
end

function test_b()
    return []
end

function run_a()
    input = readcollection("input-5.txt")
    results = map(getsectiondata_a, input)
    return  max(map(res -> res[3], results)...)
end

function run_b()
    input = readcollection("input-5.txt")
    results = map(getsectiondata_a, input)
    ids = map(res -> res[3], results)
    sorted = sort(ids)

    firsts = 1:(size(sorted, 1) -  1)

    return firsts |> curry_map(i -> (sorted[i], sorted[i+1], sorted[i+1] - sorted[i]), true) |>
                        curry_filter(t -> t[3] == 2, true) |>
                        curry_map(t -> t[1] + 1,true)

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