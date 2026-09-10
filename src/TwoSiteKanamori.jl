# Atomic Hamiltonian and d4 Multiplets

using Symbolics
using SymbolicUtils

export ResolventOp
export atomic_hamiltonian, d4_multiplet_projectors, kanamori_eigenvalues, kanamori_resolvent_rules

struct ResolventOp <: AbstractQuantumOperator end

"""
    atomic_hamiltonian()::Vector{AbstractQuantumOperator}

Returns the unperturbed local Hubbard-Kanamori Hamiltonian partitions (V_N, V_S, V_L).
"""
function atomic_hamiltonian()::Vector{AbstractQuantumOperator}
    return [GenericOp(:V_N), GenericOp(:V_S), GenericOp(:V_L)]
end

"""
    d4_multiplet_projectors()::Tuple{ProjectorOp, ProjectorOp, ProjectorOp}

Returns the physical d4 projectors for the singlet (L=0, L=2) and triplet (L=1) channels.
"""
function d4_multiplet_projectors()::Tuple{ProjectorOp, ProjectorOp, ProjectorOp}
    return (MultipletProjector(0), MultipletProjector(1), MultipletProjector(2))
end

"""
    kanamori_eigenvalues(U::Num, JH::Num)::Dict{ProjectorOp, Num}

Maps each d4 angular momentum projector to its respective analytical exact energy (Delta E_L).
"""
function kanamori_eigenvalues(U::Num, JH::Num)::Dict{ProjectorOp, Num}
    return Dict(
        MultipletProjector(0) => U + 2*JH,
        MultipletProjector(1) => U - 3*JH,
        MultipletProjector(2) => U - JH
    )
end

"""
    kanamori_resolvent_rules(U::Num, JH::Num)::Vector{Any}

Constructs the SymbolicUtils rewriting rules that apply the resolvent operator 
\\mathcal{R} = (E_0 - H_0)^{-1} directly onto the projected angular momentum channels.
"""
function kanamori_resolvent_rules(U::Num, JH::Num)::Vector{Any}
    eigen_dict = kanamori_eigenvalues(U, JH)
    R = ResolventOp()
    
    return [
        @rule( ~x * R * MultipletProjector(0) => ~x * (1 / eigen_dict[MultipletProjector(0)]) * MultipletProjector(0) ),
        @rule( ~x * R * MultipletProjector(1) => ~x * (1 / eigen_dict[MultipletProjector(1)]) * MultipletProjector(1) ),
        @rule( ~x * R * MultipletProjector(2) => ~x * (1 / eigen_dict[MultipletProjector(2)]) * MultipletProjector(2) ),
        # Boundary cases where R is the leading operator
        @rule( R * MultipletProjector(0) => (1 / eigen_dict[MultipletProjector(0)]) * MultipletProjector(0) ),
        @rule( R * MultipletProjector(1) => (1 / eigen_dict[MultipletProjector(1)]) * MultipletProjector(1) ),
        @rule( R * MultipletProjector(2) => (1 / eigen_dict[MultipletProjector(2)]) * MultipletProjector(2) )
    ]
end
