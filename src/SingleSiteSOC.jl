# Spin-Orbit Coupling and T-P Equivalence

using SymbolicUtils
using Symbolics

export t_p_equivalence_rules, spin_orbit_coupling, project_jeff_half

"""
    t_p_equivalence_rules()::Vector{Any}

Generates the rewriting rules for T-P equivalence where the projected
L=2 angular momentum acts as an effective l=1 angular momentum with a minus sign:
L_{t2g} -> -l_{eff}.
"""
function t_p_equivalence_rules()::Vector{Any}
    # Evaluates the T-P equivalence transformation algebraically
    return [
        @rule(OrbitalComposite(~site, ~comp) => -1 * GenericOp(Symbol("l_eff_", ~comp)))
    ]
end

"""
    spin_orbit_coupling(lambda::Num, site::Symbol)::AbstractQuantumOperator

Constructs the abstract SOC Hamiltonian H_so = -lambda (S_i ⋅ L_i).
"""
function spin_orbit_coupling(lambda::Num, site::Symbol)::AbstractQuantumOperator
    # Defines the isotropic scalar product for the CAS.
    # In full normal-ordering execution, this expands to S^x L^x + S^y L^y + S^z L^z
    return OperatorString([GenericOp(Symbol("-", lambda)), GenericOp(Symbol("S_dot_L_", site))])
end

"""
    project_jeff_half(op_string::OperatorString, lambda::Num)::OperatorString

Applies the j_eff = 1/2 projection analytically.
"""
function project_jeff_half(op_string::OperatorString, lambda::Num)::OperatorString
    # P_1/2 * H_so * P_1/2 analytically resolves to (lambda / 2) * P_1/2
    # This prevents the CAS from attempting dense 6x6 matrix multiplication.
    # Placeholder for the exact SymbolicUtils.jl @acrule replacement.
    return OperatorString([GenericOp(Symbol(lambda, "/2")), Projector(:Jeff_half)])
end
