include("../Helpers.jl")

struct PasswordRule
    char::Char
    low::Number
    high::Number
    matchfunc::Function

    PasswordRule(char::Char, low::Number, high::Number, matchfunc::Function) = new(char, low, high, matchfunc)
    function PasswordRule(str, matchfunc::Function)
        parts = split(str, ' ')
        validrange = split(parts[1], '-')
        new(parts[2][1], parse(Int, validrange[1]), parse(Int, validrange[2]), matchfunc)
    end
end

struct Password
    rule::PasswordRule
    password::String

    Password(rule, password) = new(rule, password)
    function Password(str, matchfunc::Function)
        input = map(strip, split(str, ':'))
        new(PasswordRule(input[1], matchfunc), input[2])
    end
end

countchar(s::String, c::Char) = size(split(s, c), 1) - 1

matches_a(pwd::String, rule::PasswordRule) = (count = countchar(pwd, rule.char); count <= rule.high && count >= rule.low)

matches_b(pwd::String, rule::PasswordRule) = (pwd[rule.low] === rule.char) ⊻ (pwd[rule.high] === rule.char)

valid(pwd::Password) = pwd.rule.matchfunc(pwd.password, pwd.rule)


findvalid(arr) = filter(valid,arr)

getpasswords(file, matchfunc) = readcollection(file, s -> Password(s, matchfunc))

getvalid(file, matchfunc) = getpasswords(file, matchfunc) |> findvalid


convert_res_for_test(rescoll) = map(res -> res.password, rescoll)

test(matchfunc, expected) = run(getvalid, [TestPermutation(("test-day-2.txt", matchfunc), expected)], convert_res_for_test)

testA() = test(matches_a, ["abcde", "ccccccccc"])

testB() = test(matches_b, ["abcde"])


println("Test A")
println(tostring(testA()))
println("")
println("A")
println(size(getvalid("input-2.txt", matches_a), 1))

println("")
println("Test B")
println(tostring(testB()))
println("")
println("B")
println(size(getvalid("input-2.txt", matches_b), 1))


