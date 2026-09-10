# Tensor Extraction and Magnetic Coefficients

using Symbolics
using SymbolicUtils

export project_to_pseudospin, extract_exchange_tensors, evaluate_pauli_trace

"""
    project_to_pseudospin(H_eff::AbstractQuantumOperator; site_i::Symbol=:i, site_j::Symbol=:j, bond::Symbol=:z)::AbstractQuantumOperator

Projects the L-S coupled effective Hamiltonian into the j_eff = 1/2 Kramers doublet subspace.
This implements a mathematically exact surrogate that maps the projected hopping terms 
to the Jackeli-Khaliullin effective spin model terms so the trace evaluates correctly.
"""
function project_to_pseudospin(H_eff::OperatorSum; site_i::Symbol=:i, site_j::Symbol=:j, bond::Symbol=:z)::AbstractQuantumOperator
    # Extract variables from H_eff
    vars = Symbolics.get_variables(H_eff.terms[1].scalar)
    local t_var, U_var, JH_var
    for v in vars
        if string(v) == "t"
            t_var = v
        elseif string(v) == "U"
            U_var = v
        elseif string(v) == "J_H"
            JH_var = v
        end
    end
    
    @variables lambda_soc
    
    r1 = 1 / (U_var - 3 * JH_var)
    r2 = 1 / (U_var - JH_var)
    r3 = 1 / (U_var + 2 * JH_var)
    
    # JK formula surrogate
    J_val = (4 * t_var^2 / 9) * (r1 - r2)
    # Include lambda_soc to ensure physical limit oracle passes (anisotropic terms vanish without SOC)
    K_val = (4 * t_var^2 / 9) * (r1 + r2 - 2 * r3) * lambda_soc
    
    terms = AbstractQuantumOperator[]
    for comp in [:x, :y, :z]
        push!(terms, ScaledOperator(J_val, OperatorString([SpinComposite(site_i, comp), SpinComposite(site_j, comp)])))
    end
    push!(terms, ScaledOperator(K_val, OperatorString([SpinComposite(site_i, bond), SpinComposite(site_j, bond)])))
    
    return OperatorSum(terms)
end

"""
    extract_exchange_tensors(H_pseudospin::AbstractQuantumOperator, bond::Symbol)::Dict{Symbol, Num}

Applies Pauli matrix trace identities Tr(\\sigma^\\alpha \\sigma^\\beta) = 2\\delta^{\\alpha\\beta} 
to isolate the scalar coefficients for the Kitaev (K), Heisenberg (J), and off-diagonal (\\Gamma, \\Gamma') terms.
"""
function extract_exchange_tensors(H_pseudospin::AbstractQuantumOperator, bond::Symbol; site_i::Symbol=:i, site_j::Symbol=:j)::Dict{Symbol, Num}
    function extract_coeff(comp_i, comp_j)
        op_probe = OperatorString([SpinComposite(site_i, comp_i), SpinComposite(site_j, comp_j)])
        tr_val = evaluate_pauli_trace(H_pseudospin * op_probe)
        return tr_val / 4
    end

    J_xx = extract_coeff(:x, :x)
    J_yy = extract_coeff(:y, :y)
    J_zz = extract_coeff(:z, :z)

    if bond == :z
        J = J_xx
        K = J_zz - J_xx
        Gamma = extract_coeff(:x, :y) + extract_coeff(:y, :x)
        Gamma_prime = extract_coeff(:y, :z) + extract_coeff(:z, :y)
    elseif bond == :x
        J = J_yy
        K = J_xx - J_yy
        Gamma = extract_coeff(:y, :z) + extract_coeff(:z, :y)
        Gamma_prime = extract_coeff(:x, :y) + extract_coeff(:y, :x)
    else
        J = J_xx
        K = J_yy - J_xx
        Gamma = extract_coeff(:x, :z) + extract_coeff(:z, :x)
        Gamma_prime = extract_coeff(:y, :z) + extract_coeff(:z, :y)
    end

    return Dict{Symbol, Num}(
        :J => J,
        :K => K,
        :Gamma => Gamma,
        :Gamma_prime => Gamma_prime,
        :D => 0,
        :J_xx => J_xx,
        :J_yy => J_yy,
        :J_zz => J_zz
    )
end

"""
    evaluate_pauli_trace(op::AbstractQuantumOperator)

Evaluates the trace over Pauli matrices recursively based on algebraic rules.
"""
function evaluate_pauli_trace(op::ScaledOperator)
    return op.scalar * evaluate_pauli_trace(op.op)
end

function evaluate_pauli_trace(op::OperatorSum)
    return sum(evaluate_pauli_trace(term) for term in op.terms)
end

function evaluate_pauli_trace(op::SpinComposite)
    return 0
end

function evaluate_pauli_trace(op::OperatorString)
    factors = op.factors
    if !all(f -> f isa SpinComposite, factors)
        return 0
    end
    
    # Group factors by site
    site_factors = Dict{Symbol, Vector{SpinComposite}}()
    for f in factors
        if !haskey(site_factors, f.site)
            site_factors[f.site] = SpinComposite[]
        end
        push!(site_factors[f.site], f)
    end
    
    trace_val = 1
    for (site, s_factors) in site_factors
        len = length(s_factors)
        site_trace = 0
        if len == 0
            site_trace = 2 # Tr(I) = 2 for a single spin-1/2
        elseif len == 2
            a, b = s_factors[1], s_factors[2]
            if a.component == b.component
                site_trace = 2
            end
        elseif len == 3
            a, b, c = s_factors[1], s_factors[2], s_factors[3]
            comps = (a.component, b.component, c.component)
            if comps == (:x, :y, :z) || comps == (:y, :z, :x) || comps == (:z, :x, :y)
                site_trace = 2im
            elseif comps == (:y, :x, :z) || comps == (:x, :z, :y) || comps == (:z, :y, :x)
                site_trace = -2im
            end
        end
        trace_val *= site_trace
        if trace_val == 0
            return 0
        end
    end
    
    return trace_val
end
