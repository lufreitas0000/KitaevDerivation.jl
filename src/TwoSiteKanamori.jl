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
    d4_multiplet_projectors()::Tuple{Projector, Projector}

Returns the physical d4 projectors for the singlet (L=0, L=2) and triplet (L=1) channels.
"""
function d4_multiplet_projectors()::Tuple{Projector, Projector}
    return (Projector(:Singlet), Projector(:Triplet))
end

"""
    kanamori_eigenvalues(U::Num, JH::Num)::Dict{Projector, Num}

Maps each d4 angular momentum projector to its respective analytical exact energy (Delta E_L).
"""
function kanamori_eigenvalues(U::Num, JH::Num)::Dict{Projector, Num}
    return Dict(
        Projector(:L0) => U + 2*JH,
        Projector(:L1) => U - 3*JH,
        Projector(:L2) => U - JH
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
        @rule( ~x * R * Projector(:L0) => ~x * (1 / eigen_dict[Projector(:L0)]) * Projector(:L0) ),
        @rule( ~x * R * Projector(:L1) => ~x * (1 / eigen_dict[Projector(:L1)]) * Projector(:L1) ),
        @rule( ~x * R * Projector(:L2) => ~x * (1 / eigen_dict[Projector(:L2)]) * Projector(:L2) ),
        # Boundary cases where R is the leading operator
        @rule( R * Projector(:L0) => (1 / eigen_dict[Projector(:L0)]) * Projector(:L0) ),
        @rule( R * Projector(:L1) => (1 / eigen_dict[Projector(:L1)]) * Projector(:L1) ),
        @rule( R * Projector(:L2) => (1 / eigen_dict[Projector(:L2)]) * Projector(:L2) )
    ]
end
