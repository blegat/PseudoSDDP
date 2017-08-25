
abstract type AbstractSPSolver end


mutable struct SDDP <: AbstractSPSolver
    stat
    option
    stopcrit
end






