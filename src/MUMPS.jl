module MUMPS

using SparseArrays
using Printf
using Distributed

mutable struct MUMPSfactorization{T}
	ptr::Int64     # pointer to factorization
	worker::Int64  # id of worker that holds factorization
	n::Int64       # matrix size
	a11::T         # first element (HACK for generating the right parametric type)
	time::Float64  # factorization time
end

const MUMPSlibPath  = abspath(joinpath(splitdir(Base.source_path())[1],"..","lib","MUMPS"))

export solveMUMPS,solveMUMPS!, factorMUMPS, applyMUMPS
export applyMUMPS!, destroyMUMPS, MUMPSfactorization

include("MUMPSfuncs.jl")

end
