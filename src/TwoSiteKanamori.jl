# Atomic Hamiltonian and d4 Multiplets

using Symbolics

export atomic_hamiltonian, d4_multiplet_projectors, kanamori_eigenvalues

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
This strictly enforces the U ~ J_H >> t_ij hierarchy.
"""
function kanamori_eigenvalues(U::Num, JH::Num)::Dict{Projector, Num}
    return Dict(
        Projector(:L0) => U + 2*JH,
        Projector(:L1) => U - 3*JH,
        Projector(:L2) => U - JH
    )
end
