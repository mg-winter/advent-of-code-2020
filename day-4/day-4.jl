include("../Helpers.jl")

containsall(passport::Dict, required::AbstractVector) = size(filter(field -> haskey(passport, field),required),1) == size(required, 1)

inbounds(bounds, num) = num >= bounds[1] && num <= bounds[2]

checknum(bounds, str) = occursin(r"^\d+$", str) ? inbounds(bounds, parse(Int, str)) : false

function checkheight(value)
    m = match(r"^(\d+)(in|cm)$", value)
    if m == nothing
        return false
    else
        bounds = m[2] == "cm" ? (150, 193) : (59, 76)
        height = parse(Int, m[1])
        return inbounds(bounds, height )
    end
end

function isvalid(field, value)
    validators = Dict([
        "byr" => curry(checknum, (1920, 2002), true),
        "iyr" => curry(checknum, (2010, 2020), true),
        "eyr" => curry(checknum, (2020, 2030), true),
        "hgt" => checkheight,
        "hcl" => value -> occursin(r"^#([0-9a-f]{6})$", value),
        "ecl" => value -> occursin(r"^amb|blu|brn|gry|grn|hzl|oth$", value),
        "pid" => value -> occursin(r"^\d{9}$", value)
    ])

    if (haskey(validators, field))
        return validators[field](value)
    else
        return true
    end
end

isvalid(field, passport::Dict) = isvalid(field, passport[field])

validate_a(passport::Dict) = containsall(passport, ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"])

function validate_b(passport::Dict) 
    if validate_a(passport) 
        fields = keys(passport)
        validfields = filter(field -> isvalid(field, passport), fields)
        return length(fields) == length(validfields)
    else
        return false
    end
end

getentrypairs(line) = map(entry -> (pair = split(entry, ':'); return pair[1] => pair[2]), split(line, ' '))

readpassports(file) = readgroups(file, getentrypairs, Dict, pushall!)
  
countvalid(passports::AbstractVector, validator::Function) = size(filter(validator, passports),1)
countvalid(file::String, validator::Function) = countvalid(readpassports(file), validator)

countvalid_a(passports::AbstractVector) = countvalid(passports, validate_a)
countvalid_a(file::String) = countvalid(file, validate_a)

countvalid_b(file::String) = countvalid(file, validate_b)

function test_a()
    passports = readpassports("test-day-4.txt")
    valid = [true, false, true, false]

    indres = run(validate_a, map(i -> TestPermutation([(passports[i])], valid[i]),1:4))
    countres =  run(countvalid_a, [TestPermutation([(passports)], 2)])

    return [indres..., countres]
end

function test_b()
    fieldtests = run(isvalid, [
        TestPermutation(("byr", "2002"), true),
        TestPermutation(("byr", "2003"), false),
        TestPermutation(("byr", "Kittens44"), false),
        TestPermutation(("hgt", "60in"), true),
        TestPermutation(("hgt", "190cm"), true),
        TestPermutation(("hgt", "190in"), false),
        TestPermutation(("hgt", "190"), false),
        TestPermutation(("hcl", "#123abc"), true),
        TestPermutation(("hcl", "#123abz"), false),
        TestPermutation(("hcl", "123abc"), false),
        TestPermutation(("ecl", "brn"), true),
        TestPermutation(("ecl", "wat"), false),
        TestPermutation(("pid", "000000001"), true),
        TestPermutation(("pid", "0123456789"), false)
    ])

    validpassports = readpassports("test-day-4b-valid.txt")
    invalidpassports = readpassports("test-day-4b-invalid.txt")

    passporttests = map(arr -> run(validate_b, map(passport -> TestPermutation([passport], arr[2]), arr[1])), [[validpassports, true], [invalidpassports, false]])

    return [fieldtests..., vcat(passporttests)...]
end

function run_a()
    return countvalid_a("input-4.txt")
end

function run_b()
    return countvalid_b("input-4.txt")
end

println("Test part A")
println(tostring(test_a()))

println("")
println("Result for part A")
println(run_a())

println("")
println("Test part B")
println(tostring(test_b(), false))

println("")
println("Result for part B")
println(run_b())