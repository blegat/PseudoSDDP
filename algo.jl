function iteration!(stat, g, option)
  npaths = option[:npaths]
  root = master(g)
  sol = solve(root)
  paths = [(npaths, root, sol)]
  for i in 1:num_stages
    merge_paths!(paths)
    #parallelism_possible_here
    for (node, sol) in paths
      samples = sample(node, npaths, option[:sampler]) # 6 -> [3, 2, 0 , 1]
      for i, child in enumerate(children(g, node))
        cutgenerator = magic
        if samples[i] > 0 || isavgcut(cutmode(node))
          csol = solve(child, sol)
          push!(paths, (samples[i], child, csol))
          addchildsol!(cutgenerator, csol)
        end
        sendcut!(g, generatecut(cutgenerator))
      end
    end
  end
end
function solve!(g::AbstractGraph, stropctrit::StoppingCriterion, options::Dict)
  stat = init stats
  while !stopcrit.stop(stat)
    iteration(!stat, g, options)
  end
  stat
end
