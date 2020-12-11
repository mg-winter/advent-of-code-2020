include("../Helpers.jl")


function isseat(grid, coords)
    val = grid[coords...]
    return val === '#' || val === 'L'
end

function isoccupiedseat(grid, coords)
    val = grid[coords...]
    return val === '#'
end

isvalidcoord(coord, top) = coord > 0 && coord <= top


isvalidcoords(coords, height, width) = isvalidcoord(coords[1], height) && isvalidcoord(coords[2], width)


onestep(dir, coords) = dir .+ coords
onestep(dir, coords, height, width, grid) = onestep(dir, coords)

function steptillseat(dir, coords, height, width, grid)

    curcoords = onestep(dir, coords)

    while isvalidcoords(curcoords, height, width) && !isseat(grid, curcoords)
        curcoords = onestep(dir, curcoords)
    end
    
    return curcoords
end

function getadjacent(grid, coords, stepfunc)
    height = size(grid, 1)
    width = size(grid, 2)

    directions = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]

    return directions |> curry_map(dir -> stepfunc(dir, coords, height, width, grid)) |> 
                         curry_filter(newcoords -> isvalidcoords(newcoords, height, width))
end



function countoccupiedadjacent(grid, coords, stepfunc)
    return getadjacent(grid, coords, stepfunc) |> curry_filter(c -> isoccupiedseat(grid, c)) |> length
end

function applyrules(grid, stepfunc, maxoccupied)
   newgrid = copy(grid)
   numchanges = 0

    for y = 1:size(grid, 1), x = 1:size(grid, 2)
        coords = (y, x)
        if isseat(grid, coords)
            numoccupied = countoccupiedadjacent(grid, coords, stepfunc)
            isoccuppied = isoccupiedseat(grid, coords)
            if numoccupied == 0 && !isoccuppied
                newgrid[coords...] = '#'
                numchanges += 1
            elseif numoccupied >= maxoccupied && isoccuppied
                newgrid[coords...] = 'L'
                numchanges += 1
            end
        end
    end

   return (newgrid, numchanges)
end


function simulateseating(grid::AbstractArray, stepfunc, maxoccuppied)
    curgrid = grid
    numchanges = -1

    while numchanges != 0
        curgrid, numchanges = applyrules(curgrid, stepfunc, maxoccuppied)
    end

    return curgrid |> curry_filter(val -> val == '#') |> length
end

simulateseating_a(file) = simulateseating(readgrid(file), onestep, 4)
simulateseating_b(file) =simulateseating(readgrid(file), steptillseat, 5)



function test_a()
    return run(simulateseating_a, [TestPermutation([("tests/test.txt")], 37)])
end

function test_b()
    return return run(simulateseating_b, [TestPermutation([("tests/test.txt")], 26)])
end

function run_a()
    return simulateseating_a("input.txt")
end

function run_b()
    return simulateseating_b("input.txt")
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