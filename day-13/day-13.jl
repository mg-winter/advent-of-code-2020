include("../Helpers.jl")

function getwaittime(arrivaltime, frequency)
    timebefore = arrivaltime % frequency
    if arrivaltime % frequency == 0
        return 0
    else
        return  frequency - timebefore
        
        # beforeteration = arrivaltime ÷ frequency
        # return ((beforeteration + 1) * frequency) - arrivaltime
    end
end

function readtable(file)
    lines = readlines(file)
    arrivaltime = parse(Int, lines[1])
    frequencies = split(lines[2], ',') |> curry_filter(s -> s != "x") |> curry_map(s -> parse(Int, s))
    return (arrivaltime, frequencies)
end

function readforcontest(file)
    lines = readlines(file)
    times = split(lines[2], ',')

    return (1:length(times)) |> curry_map(i -> (i, times[i] == "x" ? times[i] : parse(Int, times[i]))) |> curry_filter(t -> t[2] != "x")
end

function getshortestwaittime(arrivaltime, frequencies)
    return frequencies |> curry_map(f -> (f, getwaittime(arrivaltime, f))) |> curry(min, t -> t[2], true) |> prod
end

getshortestwaittime(file) = getshortestwaittime(readtable(file)...)

function findcontesttimestamp(frequencies::AbstractVector)

    i = 1
    increment = 1
    totalfreqs = length(frequencies)
   
    remainingfreqs = frequencies[2:totalfreqs]

    firsttimestamp = -1
    while length(remainingfreqs) > 0

        firsttimestamp = frequencies[1][2] * i
       
        while length(remainingfreqs) > 0 && (firsttimestamp + remainingfreqs[1][1] - 1) % remainingfreqs[1][2] == 0
            curfreq = popfirst!(remainingfreqs)
            increment *= curfreq[2]
        end     
        
        i += increment
    end

    return firsttimestamp
end

findcontesttimestamp(file) = findcontesttimestamp(readforcontest(file))

function test_a()
    return run(getshortestwaittime, [TestPermutation((["tests/test.txt"]), 295)])
end

function test_b()
    return run(findcontesttimestamp, [TestPermutation((["tests/test-b-2.txt"]), 3417),
                                        TestPermutation((["tests/test.txt"]), 1068781)])
end

function run_a()
    return getshortestwaittime("input.txt")
end

function run_b()
     return findcontesttimestamp("input.txt")
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