include("../Helpers.jl")

struct Instruction
    code::AbstractString
    args::AbstractVector

    Instruction(code, args) = new(code, args)
    function Instruction(str)
        vals = split(str, ' ')
        new(vals[1], [parse(Int, vals[2])])
    end
end

mutable struct ConsoleState
    accumulator::Number
    instrptr::Number

    ConsoleState(acc, ptr) = new(acc, ptr)
    ConsoleState() = new(0,1)
end

struct Console
    instructions::AbstractVector{Instruction}
    state::ConsoleState
    pastinstructions::AbstractSet
    
    Console(instructions, state, past) = new(instructions, state, past)
    Console(instructions) = new(instructions, ConsoleState(), Set())
end




nop(acc, instrptr) = (acc, instrptr + 1)
nop(acc, instrptr, value) = nop(acc, instrptr)

jmp(acc, instrptr, offset) = (acc, instrptr+offset)

acc(acc, instrptr, delta) = (acc + delta, instrptr+1)

const INSTRUCTIONS_REF = Dict(["nop" => nop, "jmp" => jmp, "acc" => acc])

isrepeat(console) = in(console.state.instrptr, console.pastinstructions)
isvalidinstr(console) = console.state.instrptr > 0 && console.state.instrptr <= length(console.instructions)

function execute(console)
    push!(console.pastinstructions, console.state.instrptr)

    curinstr = console.instructions[console.state.instrptr] 
    res = INSTRUCTIONS_REF[curinstr.code](console.state.accumulator, console.state.instrptr, curinstr.args...)
    console.state.accumulator = res[1]
    console.state.instrptr = res[2]
end

function run(console::Console)
    len = length(console.instructions)

    while isvalidinstr(console) && !isrepeat(console)
        execute(console)
    end

    return (console.state.accumulator, isrepeat(console))

end

parseinstructions(file) = readcollection(file, Instruction)

run(file::AbstractString) = run(Console(parseinstructions(file)))


function flip(instr::Instruction)
    if instr.code == "acc"
        return instr
    elseif instr.code == "jmp"
        return Instruction("nop", instr.args)
    else
        return Instruction("jmp", instr.args)
    end
end

function tryfixes(file)
    original = parseinstructions(file)

    len = length(original)
    for i = 1:len
        instr = original[i]
        if instr.code !== "acc"
            newset = copy(original)
            newset[i] = flip(instr)
            res = run(Console(newset))

            if !res[2]
                return res
            end
        end
    end

    return (-1, false)
end


function test_a()
    return run(run, [TestPermutation((["test-day-8.txt"]), (5, true))])
end

function test_b()
    return run(tryfixes, [TestPermutation((["test-day-8.txt"]), (8, false))])
end

function run_a()
    run("input-8.txt")
end

function run_b()
    tryfixes("input-8.txt")
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