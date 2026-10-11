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
    rule_func = function(op)
        if op isa OrbitalComposite
            return ScaledOperator(-1, GenericOp(Symbol("l_eff_", op.component)))
        end
        return nothing
    end
    return [rule_func]
end

"""
    spin_orbit_coupling(lambda::Num, site::Symbol)::AbstractQuantumOperator

Constructs the abstract SOC Hamiltonian H_so = lambda (L_i ⋅ S_i).
"""
function spin_orbit_coupling(lambda::Num, site::Symbol=:i)::AbstractQuantumOperator
    L_dot_S = OperatorSum([
        OperatorString([OrbitalComposite(site, :x), SpinComposite(site, :x)]),
        OperatorString([OrbitalComposite(site, :y), SpinComposite(site, :y)]),
        OperatorString([OrbitalComposite(site, :z), SpinComposite(site, :z)])
    ])
    return ScaledOperator(lambda, L_dot_S)
end

"""
    soc_projection_rules(H_so::AbstractQuantumOperator, lambda::Num, site::Symbol=:i)::Vector{Any}

Rules to analytically evaluate the projection of H_SOC into the j_eff basis.
"""
function soc_projection_rules(H_so::AbstractQuantumOperator, lambda::Num, site::Symbol=:i)::Vector{Any}
    P_half = LowEnergyProjector("1/2", site)
    P_three_half = LowEnergyProjector("3/2", site)
    return [
        (P_half * H_so * P_half) => ScaledOperator(lambda, P_half),
        (P_three_half * H_so * P_three_half) => ScaledOperator(-lambda / 2, P_three_half)
    ]
end

"""
    project_jeff_half(op_string::AbstractQuantumOperator, lambda::Num; site::Symbol=:i)::AbstractQuantumOperator

Applies the j_eff = 1/2 projection analytically, returning P_1/2 * op * P_1/2.
Evaluates immediately if the operator is H_SOC.
"""
function project_jeff_half(op_string::AbstractQuantumOperator, lambda::Num; site::Symbol=:i)::AbstractQuantumOperator
    P_half = LowEnergyProjector("1/2", site)
    H_so = spin_orbit_coupling(lambda, site)
    
    # Initial algebraic projection
    projected_op = P_half * op_string * P_half
    
    # First, simplify projector algebra (P^2 = P, P_orth * P = 0)
    if projected_op isa OperatorString
        projected_seq = apply_algebraic_rules(projected_op.factors)
        projected_op = length(projected_seq) == 1 ? projected_seq[1] : OperatorString(projected_seq)
    end
    
    # Apply SOC projection rules via the generalized engine
    rules = soc_projection_rules(H_so, lambda, site)
    return apply_algebraic_rules(projected_op, rules)
end
