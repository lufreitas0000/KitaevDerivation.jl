# Spin-Orbit Coupling and T-P Equivalence

"""
    t_p_equivalence_rules()::Vector{Any}

Maps the orbital angular momentum L to the effective angular momentum -l_eff.
"""
function t_p_equivalence_rules()::Vector{Any} end

"""
    spin_orbit_coupling(lambda::Num)::AbstractQuantumOperator

Constructs the SOC Hamiltonian H_so = -lambda (S_i ⋅ L_i).
"""
function spin_orbit_coupling(lambda::Num)::AbstractQuantumOperator end

"""
    project_jeff_half(op::AbstractQuantumOperator)::AbstractQuantumOperator

Applies the projection operator isolating the j_eff = 1/2 subspace.
"""
function project_jeff_half(op::AbstractQuantumOperator)::AbstractQuantumOperator end
