function iteration!(sddp::SDDP, g)
    paths = forwardpass!(sddp, g)
    backwardpass!(sddp, g, paths)
end


"""Sample a `paths` with SDDP."""
function forwardpass!(sddp, g)
    stat = sddp.stat

    npaths = sddp.option[:npaths]
    root = master(g)
    sol = solve(root)
    paths = [(npaths, root, sol)]

    for i in 1:num_stages
        merge_paths!(paths)
        #parallelism_possible_here
        for (npaths, node, sol) in paths
            # Imagine 6 paths arrive at node. We dispatch this 6 paths
            # to its children with the function sample
            samples = sample(node, npaths, option[:sampler]) # 6 -> [3, 2, 0 , 1]

            for i, child in enumerate(children(g, node))
                if samples[i] > 0 || isavgcut(cutmode(node))
                    csol = solve(child, sol)
                    push!(paths, (samples[i], child, csol))
                end
            end
        end
    end

    return paths
end



"""Compute cuts backward in nodes inside `paths`."""
function backwardpass!(sddp, g, paths)

    for (_, node, sol) in reverse(paths)

        # if the node is terminal, we discard the cuts computation
        if ~isleaf(node)
            # use cutgenerator from StructDualDynProg
            cutgenerator = magic
            csol = solve(child, sol)

            # TODO: should we use all children nodes
            # or only those crossed during forward pass?
            addchildsol!(cutgenerator, csol)
            sendcut!(g, generatecut(cutgenerator))
        end

    end
end


function solve!(sddp::SDDP, g::AbstractGraph)
    stat = sddp.stat
    while !sddp.stopcrit.stop(stat)
        iteration!(sddp, g)
    end
end

