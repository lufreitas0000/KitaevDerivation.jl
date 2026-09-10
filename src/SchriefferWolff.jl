# Generalized Perturbation Theory and Resolvent Operator

export compute_generator, compute_effective_hamiltonian

"""
    compute_generator(order::Int, V::AbstractQuantumOperator, T_terms::Dict{Int, AbstractQuantumOperator})

Recursively solves the Lie algebra constraint for the canonical transformation generator S_n:
[S_n, V] + \\sum_{k=1}^{n-1} [S_k, T] + T^{(n)} = 0

For order 1: [S_1, V] = T_1 + T_{-1}
For order 2: [S_2, V] + [S_1, T_0] = 0
"""
function compute_generator(order::Int, V::AbstractQuantumOperator, T_terms::Dict{Int, AbstractQuantumOperator})::AbstractQuantumOperator
    # TODO: Implement recursive abstract commutator resolution utilizing the
    # Delta E_L eigenvalue mappings and Projector orthogonality rules.
end

"""
    compute_effective_hamiltonian(order::Int, S_generators::Vector{AbstractQuantumOperator}, T_terms::Dict{Int, AbstractQuantumOperator})

Evaluates the Baker-Campbell-Hausdorff (BCH) expansion projected onto the low-energy manifold \\mathcal{P}_{low}.
"""
function compute_effective_hamiltonian(order::Int, S_generators::Vector{AbstractQuantumOperator}, T_terms::Dict{Int, AbstractQuantumOperator})::AbstractQuantumOperator
    # TODO: Implement normal-ordered commutator expansions up to `order`.
    # E.g., H_eff^(2) = -1/2 P_low (T_{-1} S_1^{(+)} + S_1^{(-)} T_1) P_low
end
