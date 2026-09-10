module KitaevDerivation

using Symbolics
using SymbolicUtils

# Export fundamental abstract types and submodules
export AbstractQuantumOperator, FermionOp, SpinOp, ProjectorOp
export commutator, anticommutator

abstract type AbstractQuantumOperator end
abstract type FermionOp <: AbstractQuantumOperator end
abstract type SpinOp <: AbstractQuantumOperator end
abstract type ProjectorOp <: AbstractQuantumOperator end

include("BasisAndAlgebra.jl")
include("AuxiliaryOperators.jl")
include("SingleSiteSOC.jl")
include("TwoSiteKanamori.jl")
include("SchriefferWolff.jl")
include("ExchangeExtraction.jl")

end
