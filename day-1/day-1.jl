using DelimitedFiles
using Base
using Printf

function findaddto(sorted, target)
    
    top = 1
    bottom = size(sorted, 1)

    while top < bottom
        res = sorted[top] + sorted[bottom]
        if res == target
            return (sorted[top], sorted[bottom])
        elseif res > target
            bottom -=1
        else
            top += 1
        end
    end
    return nothing
end

input = readdlm("input-1.txt", ',', Int)
sortedinput = sort(input, dims=1)


answerA = findaddto(sortedinput, 2020)

println(@sprintf("%i + %i = %i", answerA[1], answerA[2], (answerA[1]+answerA[2])))
println(@sprintf("%i * %i = %i", answerA[1], answerA[2], (answerA[1]*answerA[2])))

function findaddto3(sorted, target)
    len = size(sorted, 1)

    # third last item is the last one we can check, because for last and second last 
    # there will not be 2 items remaining to be in a group with
    for i = 1:(len-2)

        # do not need to include items before current because if they were in the correct set 
        # they would have been picked up during an earlier iteration
        without = sorted[i+1:len]
        other2 = findaddto(without, target - sorted[i])
     
        if other2 != nothing
            return (other2..., sorted[i])
        end
    end

    return nothing
    
end

answerB = findaddto3(sortedinput, 2020)

println(@sprintf("%i + %i + %i = %i", answerB[1], answerB[2], answerB[3], (answerB[1]+answerB[2]+answerB[3])))
println(@sprintf("%i * %i * %i = %i", answerB[1], answerB[2], answerB[3], (answerB[1]*answerB[2]*answerB[3])))
