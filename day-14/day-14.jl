include("../Helpers.jl")
using Base.Iterators


struct Mask
    and::Int
    or::Int

    Mask(and, or) = new(and,or)
    Mask(str) = new(parsebin(replace(str, "X" => "1")), parsebin(replace(str, "X" => "0")))
end

struct MaskV2
    initialor::Int
    floatmasks::AbstractVector

    MaskV2(or, fms) = new(or, fms)
    function MaskV2(str)

        initor = parsebin(replace(str, "X" => "0"))
        i = findnext('X', str, 1)

        len = length(str)

        fms = []

        while i != nothing
            prefix = i == 1 ? ["", ""] : [repeat("1", i-1), repeat("0", i-1)]
            suffix = i == len ? ["", ""] : [repeat("1", len - i), repeat("0", len - i)]

            andmask = parsebin(prefix[1] * "0" * suffix[1])
            ormask = parsebin(prefix[2] * "1" * suffix[2])

            push!(fms, [((a, b) -> a & b, andmask), ((a, b) -> a | b, ormask)])

             i = findnext('X', str, i+1)
        end

        new(initor, fms)
    end
end


struct Instruction
    command
    args

    Instruction(command, args) = new(command, args)
    function Instruction(str, maskfunc)
        parts = split(str, "=") |> curry_map(strip)

        partmatch = match(r"^mem\[(\d+)\]", parts[1])

        if (partmatch != nothing)
            new("mem", [parse(Int,partmatch[1]), parse(Int, parts[2])])
        else
            new("mask", [maskfunc(parts[2])])
        end
    end
    Instruction(str) = Instruction(str, Mask)
end

apply(value, mask::Mask) = (value & mask.and) | mask.or

function getaddresses(initval, maskcombo)
    return foldfuncl((acc, val) -> val[1](acc, val[2]), collect(maskcombo), initval)
end

function getaddresses(addr, mask::MaskV2)
    initval = addr | mask.initialor

    maskcombos = product(mask.floatmasks...)

    return maskcombos |> curry_map(combo -> getaddresses(initval, combo))
end

function set!(memory, address, value, mask)
    newvalue = apply(value, mask)
    memory[address] = newvalue
end

function setmem!(memory, instr, mask)
    set!(memory, instr.args[1], instr.args[2], mask)
end

function setmemv2!(memory, instr, mask)
    addresses = getaddresses(instr.args[1],  mask)
    
    for addr = addresses
        memory[addr] = instr.args[2]
    end
end

function runprogram(program::AbstractVector, setmemfunc!)
    mask = Mask(repeat("X", 36))
    memory = Dict()

    for instr = program
        if instr.command == "mask"
            mask = instr.args[1]
        elseif instr.command == "mem"
            setmemfunc!(memory, instr, mask)
        end
    end

    return sum(values(memory))

end

runprogram(program::AbstractVector) = runprogram(program, setmem!)

readprogram(file, maskfunc) = readcollection(file, s -> Instruction(s, maskfunc))
readprogram(file) = readcollection(file, Mask)

runprogram(file, maskfunc, setmemfunc!) = runprogram(readprogram(file, maskfunc), setmemfunc!)
runprogram(file) = runprogram(file, Mask, setmem!)

function test_a()
    return run(runprogram, [TestPermutation((["tests/test.txt"]), 165)])
end

function test_b()
    return run(runprogram, [TestPermutation(("tests/test-b.txt", MaskV2, setmemv2!), 208)])
end

function run_a()
    return runprogram("input.txt")
end

function run_b()
    return runprogram("input.txt", MaskV2, setmemv2!)
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