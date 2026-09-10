# Perturbation Theory and Resolvent

"""
    hopping_hamiltonian(bond::Symbol, t::Num, t_prime::Num)::AbstractQuantumOperator

Constructs the kinetic hopping operator T dependent on the geometric bond (x, y, z).
"""
function hopping_hamiltonian(bond::Symbol, t::Num, t_prime::Num)::AbstractQuantumOperator end

"""
    apply_resolvent_action(op_sequence::Vector{AbstractQuantumOperator})::AbstractQuantumOperator

Applies the operator sequence right-to-left on the ground state, preventatively pruning null terms to avoid AST combinatorial explosion.
"""
function apply_resolvent_action(op_sequence::Vector{AbstractQuantumOperator})::AbstractQuantumOperator end

"""
    schrieffer_wolff_expansion(H0::AbstractQuantumOperator, Ht::AbstractQuantumOperator, order::Int)::AbstractQuantumOperator

Generates the effective Hamiltonian via canonical transformation up to the specified order.
"""
function schrieffer_wolff_expansion(H0::AbstractQuantumOperator, Ht::AbstractQuantumOperator, order::Int)::AbstractQuantumOperator end
