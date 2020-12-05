using DelimitedFiles
using Base
using Printf

curry(func::Function, first, expectone = false) = args -> expectone ? func(first, args) : func(first, args...)

curry_map(mapfunc::Function, expectone = false) = curry(map, mapfunc, expectone)

curry_filter(filterfunc::Function, expectone = false) = curry(filter, filterfunc, expectone)


readchargrid(file) = permutedims(hcat(map(collect, readlines(file))...))

readgrid(file, delim = nothing, type = nothing) = delim == nothing ? readchargrid(file) : (params = type == nothing ? (file, delim) : (file, delim, type); readdlm(params...))
    
readcollection(file, converter = nothing) = (res = readlines(file); converter == nothing ? res : map(converter, res))


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

