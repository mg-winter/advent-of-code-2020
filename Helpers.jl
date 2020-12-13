using DelimitedFiles
using Base
using Printf

curry(func::Function, first, expectone = false) = args -> expectone ? func(first, args) : func(first, args...)

curry_map(mapfunc::Function, expectone = true) = curry(map, mapfunc, expectone)

curry_filter(filterfunc::Function, expectone = true) = curry(filter, filterfunc, expectone)

function foldfuncl(accumulator::Function, itr, init)
    acc = init
    for item = itr
        acc = accumulator(acc, item)
    end
    return acc
end

function min(comparator::Function, itr) 
    return length(itr) == 0 ? nothing : foldfuncl((a, b) -> comparator(a) < comparator(b) ? a : b , itr, itr[1])
end

function max(comparator::Function, itr, init) 
    return length(itr) == 0 ? nothing : foldfuncl((a, b) -> comparator(a) > comparator(b) ? a : b , itr, itr[1])
end

readchargrid(file) = permutedims(hcat(map(collect, readlines(file))...))

readgrid(file, delim = nothing, type = nothing) = delim == nothing ? readchargrid(file) : (params = type == nothing ? (file, delim) : (file, delim, type); readdlm(params...))
    
readcollection(file, converter = nothing) = (res = readlines(file); converter == nothing ? res : map(converter, res))

readnumbers(file) = readcollection(file, curry(parse, Int, true))

pushall!(coll, items) = push!(coll, items...)
function readgroups(lines::AbstractArray, lineconverter = l -> l, groupinitializer = () -> [], groupupdater! = push!)
    
    groups = []
    group = groupinitializer() 

    for line = lines
        if line == ""
            push!(groups, group)
            group = groupinitializer()
        else
            converted = lineconverter(line)
            groupupdater!(group, converted)
        end
    end

    push!(groups, group)

    return groups
end

readgroups(file::AbstractString, lineconverter = l -> l, groupinitializer = () -> [], groupupdater! = push!) = readgroups(readcollection(file), lineconverter, groupinitializer, groupupdater!)

joinparas(arr) = join(arr, "\n\n")

struct TestPermutation
    args
    expected
end

struct Test
    func::Function
    permutation::TestPermutation
    resultconverter

    Test(func, permutation, resultconverter) = new(func, permutation, resultconverter)
    Test(func, permutation) = new(func, permutation, nothing)
end

struct TestResult
    test::Test
    actual
    compare_actual
    ispass
end

function run(test::Test)
    res = test.func(test.permutation.args...)
    rescompare = test.resultconverter == nothing ? res : test.resultconverter(res)
    return TestResult(test, res, rescompare, rescompare == test.permutation.expected)
end

run(tests::AbstractVector{Test}) = map(run, tests)

tests(func, permutations, converterfunc = nothing) = map(p -> Test(func, p, converterfunc), permutations)

run(func, permutations, converterfunc = nothing) = tests(func, permutations, converterfunc) |> run

skipfirst(coll) = (len = size(coll, 1); len > 1 ? coll[2:len] : [])

function tostring(perm::TestPermutation, skipinput::Bool = true)
    args = skipinput ? skipfirst(perm.args) : perm.args

    return @sprintf("Args: %s\nExpected: %s", args, perm.expected)
end

tostring(t::Test, skipinput::Bool = true) = @sprintf("Function: %s\n%s\nConverter: %s", t.func, tostring(t.permutation, skipinput), t.resultconverter)

tostring(res::TestResult, skipinput::Bool = true) = @sprintf("%s\nActual: %s\nPass: %s", tostring(res.test, skipinput), res.actual, res.ispass)

tostring(reslist::AbstractVector, skipinput::Bool = true) = map(res -> tostring(res, skipinput), reslist) |> joinparas

prettyprint(val) = (show(stdout, "text/plain", val); println(""))