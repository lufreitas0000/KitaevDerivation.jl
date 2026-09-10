# Atomic Hamiltonian and d4 Multiplets

export atomic_hamiltonian, d4_multiplet_projectors, kanamori_eigenvalues

function atomic_hamiltonian(U::Num, JH::Num)::AbstractQuantumOperator
    # TODO: Construct V = V_N + V_S + V_L
end

function d4_multiplet_projectors()::Tuple{Projector, Projector}
    return (Projector(:Singlet), Projector(:Triplet))
end

function kanamori_eigenvalues(U::Num, JH::Num)::Dict{Projector, Num}
    return Dict(
        Projector(:L0) => U + 2*JH,
        Projector(:L1) => U - 3*JH,
        Projector(:L2) => U - JH
    )
end
