type WNode
  w
  node
end
function solve(wn::WNode, sol)
  solve(wn.node, sol, wn.w)
end
