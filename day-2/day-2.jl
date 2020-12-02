using DelimitedFiles
using Base
using Printf

struct PasswordRule
    char::Char
    low::Number
    high::Number
    matchfunc::Function

    function PasswordRule(str, matchfunc::Function)
        parts = split(str, ' ')
        validrange = split(parts[1], '-')
        new(parts[2][1], parse(Int, validrange[1]), parse(Int, validrange[2]), matchfunc)
    end

    PasswordRule(char::Char, low::Number, high::Number, matchfunc::Function) = new(char, low, high, matchfunc)
end

struct Password
    rule::PasswordRule
    password::String
end

countchar(s::String, c::Char) = size(split(s, c), 1) - 1

matches_a(pwd::String, rule::PasswordRule) = (count = countchar(pwd, rule.char); count <= rule.high && count >= rule.low)

matches_b(pwd::String, rule::PasswordRule) = (pwd[rule.low] === rule.char) ⊻ (pwd[rule.high] === rule.char)

valid(pwd::Password) = pwd.rule.matchfunc(pwd.password, pwd.rule)


findvalid(arr) = filter(valid,arr)

getpasswords(arr, matchfunc) = map(i -> Password(PasswordRule(arr[i, 1], matchfunc), arr[i,2]), 1:size(arr, 1))

function parseinput(file)
    input = readdlm(file,  ':', String)
    input_formatted = map(strip, input)
end

getvalid(file, matchfunc) = getpasswords(parseinput(file), matchfunc) |> findvalid

function testA()
    res = getvalid("test-day-2.txt", matches_a)
    return size(res, 1) == 2 && res[1].password == "abcde" && res[2].password == "ccccccccc"
end

function testB()
    res = getvalid("test-day-2.txt", matches_b)
    return size(res, 1) == 1 && res[1].password == "abcde"
end


println("A")
println(size(getvalid("input-2.txt", matches_a), 1))

println("B")
println(size(getvalid("input-2.txt", matches_b), 1))


