# Atomic Hamiltonian and d4 Multiplets

"""
    atomic_hamiltonian(U::Num, JH::Num)::AbstractQuantumOperator

Constructs the local Hubbard-Kanamori Hamiltonian.
"""
function atomic_hamiltonian(U::Num, JH::Num)::AbstractQuantumOperator end

"""
    d4_multiplet_projectors()::Tuple{ProjectorOp, ProjectorOp, ProjectorOp}

Returns the projectors for the angular momentum channels L=0, L=1, and L=2.
"""
function d4_multiplet_projectors()::Tuple{ProjectorOp, ProjectorOp, ProjectorOp} end

"""
    kanamori_eigenvalues(U::Num, JH::Num)::Dict{ProjectorOp, Num}

Maps each d4 projector to its respective exact analytical energy (Delta E_L).
"""
function kanamori_eigenvalues(U::Num, JH::Num)::Dict{ProjectorOp, Num} end
