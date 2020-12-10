include("../Helpers.jl")


function addsum!(sumsbysum, sumsbyindex, numbers, i, j)
    
    sum = numbers[i] + numbers[j]

    indexnum = min(i, j)
    if (!haskey(sumsbysum, sum))
        sumsbysum[sum] = []
    end
    push!(sumsbysum[sum], indexnum)

    if !haskey(sumsbyindex, indexnum)
        sumsbyindex[indexnum] = []
    end
    push!(sumsbyindex[indexnum], sum)

end

function getallinvalid(numbers::AbstractVector, preamblesize)
    tocheck = numbers[preamblesize+1:length(numbers)]

    firstcheck = 1
    lastcheck = preamblesize

    sumsbysum = Dict()
    sumsbyindex = Dict()

    for i = 1:preamblesize-1
        for j = i+1:preamblesize
            addsum!(sumsbysum, sumsbyindex, numbers, i, j) 
        end
    end

    
    currange = []

    res = []

    for n = tocheck 
        if !haskey(sumsbysum, n) 
            push!(res, n)
        end 
            #remove all sums that must have numbers[firstcheck] in them from sumsbysum
            sums = sumsbyindex[firstcheck]
            for sum = sums
                if haskey(sumsbysum, sum)
                    sumsbysum[sum] = filter(min -> min !== firstcheck, sumsbysum[sum])
                    if length(sumsbysum[sum]) < 1
                        delete!(sumsbysum, sum)
                    end
                end
            end

           
            
            firstcheck += 1
            lastcheck += 1

            for newindex = firstcheck:(lastcheck-1)
                addsum!(sumsbysum, sumsbyindex, numbers, newindex, lastcheck)
            end
    end

    return res
end

getallinvalid(file, preamblesize) = getallinvalid(readnumbers(file), preamblesize)

getfirstinvalid(file, preamblesize) = getallinvalid(file, preamblesize)[1]

function getfirstrangesum(file, preamblesize)
    numbers = readnumbers(file)
    invalid = getfirstinvalid(numbers, preamblesize)

    for i = 1:(length(numbers) - 2)
        sum = numbers[i]
        j = i + 1
        sumrange = [numbers[i]]
        while sum < invalid && j < length(numbers)
           
            sum += numbers[j]
            push!(sumrange, numbers[j])

            if invalid == sum
                return max(sumrange...) + min(sumrange...)
            end
            j += 1
        end
    end
end

function test_a()
    return run(getfirstinvalid, [TestPermutation(("test-day-9.txt", 5), 127)])
end

function test_b()
    return run(getfirstrangesum, [TestPermutation(("test-day-9.txt", 5), 62)])
end

function run_a()
    return getfirstinvalid("input.txt", 25)
end

function run_b()
    return getfirstrangesum("input.txt", 25)
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