include("../Helpers.jl")

function parsebagdesc(bagdesc)
    bagregex = r"^\s*(\d)\s(\w+\s\w+).+"
    m = match(bagregex, bagdesc)
    return (m[2], parse(Int, m[1]))
end

function parsebaglist(bags)
    if bags == "no other bags"
        return []
    else
        return map(parsebagdesc, split(bags, ','))
    end
end

function parsebagrule(rule)
    toplevelregex = r"^(\w+\s\w+) bags contain (.+)\."
    m = match(toplevelregex, rule)
    containing = m[1]
    allcontained = parsebaglist(m[2])

    return (containing, allcontained)
    
end

parsebagrules(file) = readcollection(file, parsebagrule)

function invertrules(rules)
    inverted = Dict()

    for rule = rules
        for contained = rule[2]
            if !haskey(inverted, contained[1])
                push!(inverted, contained[1] => [])
            end

            push!(inverted[contained[1]], (rule[1], contained[2]))
        end
    end

    return inverted
end

function getvalidcontaining(file, inner)
    parsedrules = parsebagrules(file)
    invertedrules = invertrules(parsedrules)

    typestocheck = [inner]

    res = Set()
    while length(typestocheck) > 0
        curtype = popfirst!(typestocheck)
        
        if haskey(invertedrules, curtype)
            for containing = invertedrules[curtype]
                if !in(containing, res) #prevent cycles by not pushing descriptions that were already checked
                    push!(res, containing[1])
                    push!(typestocheck, containing[1])
                end
            end
        end
    end
    return res
end

countmustcontain(rules::Dict, contained::AbstractVector) = length(contained) == 0 ? 0 : sum(map(t -> t[2], contained)) + sum(map(t -> t[2] * countmustcontain(rules, t[1]),contained))

countmustcontain(rules::Dict, outer) = haskey(rules, outer) ? countmustcontain(rules, rules[outer]) : 0
    
countmustcontain(file, outer) = countmustcontain(Dict(map(t -> t[1] => t[2],parsebagrules(file))), outer)

function countvalidcontaining(file, inner)
    return length(getvalidcontaining(file, inner))
end

function test_a()
    return run(countvalidcontaining, [TestPermutation(("test-day-7.txt", "shiny gold"), 4)])
end

function test_b()
    return run(countmustcontain, [TestPermutation(("test-day-7.txt", "shiny gold"), 32), 
                                    TestPermutation(("test-day-7-2.txt", "shiny gold"), 126)])
end

function run_a()
    return countvalidcontaining("input-7.txt", "shiny gold")
end

function run_b()
     return countmustcontain("input-7.txt", "shiny gold")
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