# Spin-Orbit Coupling and T-P Equivalence

export t_p_equivalence_rules, spin_orbit_coupling, project_jeff_half

function t_p_equivalence_rules()::Vector{Any}
    # TODO: Define rewriting rules mapping L to -l_eff
    return []
end

function spin_orbit_coupling(lambda::Num)::AbstractQuantumOperator
    # TODO: Construct H_so = -lambda (S_i \cdot L_i)
end

function project_jeff_half(op::AbstractQuantumOperator)::AbstractQuantumOperator
    # TODO: Apply j_eff = 1/2 projection
end
