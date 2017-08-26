type WNode
    # probability to transit from current node to children
    w
    # abstract node, specifying the inner model
    # see SDDP.jl, StructDualDynProg.jl or StochDynamicProgramming.jl for
    # more details
    node
end

# FP: I'm not sure yet about this function's signature
function solve(wn::WNode, sol)
    solve(wn.node, sol, wn.w)
end
