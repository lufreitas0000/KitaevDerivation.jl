# Tensor Extraction and Magnetic Coefficients

using Symbolics
using SymbolicUtils

export project_to_pseudospin, extract_exchange_tensors, evaluate_pauli_trace
export get_doublet_coeff, pseudospin_ket, d4_basis

const d4_basis = Dict{String, Vector{Dict{Tuple{Tuple{Symbol,Symbol}, Tuple{Symbol,Symbol}}, ComplexF64}}}()

# ---------------------------------------------------------------------------
# d4 Two-Hole Basis States: Clebsch-Gordan decomposition
# ---------------------------------------------------------------------------
# Provenance: formal_derivation.tex §Commutators (eqs. for <s_i'|h_s2 P_{L}^{(2)} h_s3†|s_i>).
# Also: Georges et al., Annu. Rev. Condens. Matter Phys. 4, 137 (2013).
#
# In the t2g manifold (3 orbitals x, y, z; spin up/down => 6 modes), the
# 15 two-hole states decompose under orbital angular momentum L as:
#
#   L=0, S=0 (1 state, "^1S"): singlet in orbital AND spin
#     |L=0⟩ = (1/√3)(|x↓x↑⟩ + |y↓y↑⟩ + |z↓z↑⟩)
#
#   L=1, S=1 (9 states, "^3P"): triplet in orbital; triplet in spin
#     Three orbital pairs (xy, xz, yz) × three spin combinations (↑↑, ↑↓+↓↑, ↓↓)
#
#   L=2, S=0 (5 states, "^1D"): quintet orbital; singlet spin
#     Five traceless symmetric combinations in orbital space
#
# The pair notation p(o1,s1, o2,s2, coeff) encodes the two-hole state
# |o1,s1; o2,s2⟩ as an antisymmetrized combination (lexicographic order).
#
# VALIDATION: These coefficients must satisfy:
#   1. Orthonormality within each multiplet
#   2. H_K |ψ_L⟩ = ΔE_L |ψ_L⟩ where ΔE_L = kanamori_eigenvalues(U,J_H)[L]
#   3. Total dimension: dim(L=0) + dim(L=1) + dim(L=2) = 1 + 9 + 5 = 15
# See test/test_kanamori.jl [NUMERICAL_CROSSCHECK] for validation tests.
# ---------------------------------------------------------------------------

function _make_d4()
    L0 = []
    L1 = []
    L2 = []
    
    p(o1,s1, o2,s2, coeff) = (o1,s1) < (o2,s2) ? (((o1,s1), (o2,s2)) => coeff) : (((o2,s2), (o1,s1)) => -coeff)
    
    # L=0 (^1S): fully antisymmetric orbital singlet
    push!(L0, Dict(p(:x,:down, :x,:up, 1/sqrt(3)), p(:y,:down, :y,:up, 1/sqrt(3)), p(:z,:down, :z,:up, 1/sqrt(3))))
    
    # L=1 (^3P): 9 states = 3 orbital pairs × 3 spin configurations
    for (o1, o2) in [(:x, :y), (:x, :z), (:y, :z)]
        push!(L1, Dict(p(o1,:up, o2,:up, 1.0)))                                           # Sz=+1
        push!(L1, Dict(p(o1,:down, o2,:down, 1.0)))                                        # Sz=-1
        push!(L1, Dict(p(o1,:up, o2,:down, 1/sqrt(2)), p(o1,:down, o2,:up, 1/sqrt(2))))   # Sz=0, triplet
        push!(L2, Dict(p(o1,:up, o2,:down, 1/sqrt(2)), p(o1,:down, o2,:up, -1/sqrt(2))))  # Sz=0, singlet
    end
    
    # L=2 (^1D): 5 states; traceless symmetric combinations in orbital, spin singlet
    push!(L2, Dict(p(:x,:down, :x,:up, 1/sqrt(2)), p(:y,:down, :y,:up, -1/sqrt(2))))
    push!(L2, Dict(p(:x,:down, :x,:up, 1/sqrt(6)), p(:y,:down, :y,:up, 1/sqrt(6)), p(:z,:down, :z,:up, -2/sqrt(6))))
    
    d4_basis["P_[L=0]"] = L0
    d4_basis["P_[L=1]"] = L1
    d4_basis["P_[L=2]"] = L2
end
_make_d4()


function apply_fermion_c(state, f)
    new_state = Dict{Vector{Tuple{Symbol, Symbol, Symbol}}, ComplexF64}()
    for (kets, coeff) in state
        if f in kets continue end
        num_less = count(x -> x < f, kets)
        sign = (-1)^num_less
        new_kets = copy(kets)
        push!(new_kets, f)
        sort!(new_kets)
        new_state[new_kets] = get(new_state, new_kets, 0.0) + coeff * sign
    end
    return new_state
end

function apply_fermion_a(state, f)
    new_state = Dict{Vector{Tuple{Symbol, Symbol, Symbol}}, ComplexF64}()
    for (kets, coeff) in state
        idx = findfirst(==(f), kets)
        if idx !== nothing
            sign = (-1)^(idx - 1)
            new_kets = copy(kets)
            deleteat!(new_kets, idx)
            new_state[new_kets] = get(new_state, new_kets, 0.0) + coeff * sign
        end
    end
    return new_state
end

function apply_particle_projector(state, p)
    new_state = Dict{Vector{Tuple{Symbol, Symbol, Symbol}}, ComplexF64}()
    for (kets, coeff) in state
        if count(x -> x[1] == p.site, kets) == p.holes
            new_state[kets] = coeff
        end
    end
    return new_state
end

function apply_multiplet_projector(state, p)
    new_state = Dict{Vector{Tuple{Symbol, Symbol, Symbol}}, ComplexF64}()
    for (kets, coeff) in state
        site_particles = filter(x -> x[1] == p.site, kets)
        if length(site_particles) != 2 continue end
        
        pair = ((site_particles[1][2], site_particles[1][3]), (site_particles[2][2], site_particles[2][3]))
        
        for basis_state in d4_basis[p.L]
            overlap = conj(get(basis_state, pair, 0.0))
            if overlap != 0.0
                for (basis_pair, b_coeff) in basis_state
                    new_kets = filter(x -> x[1] != p.site, kets)
                    push!(new_kets, (p.site, basis_pair[1][1], basis_pair[1][2]))
                    push!(new_kets, (p.site, basis_pair[2][1], basis_pair[2][2]))
                    # Assuming other particles are empty for Kitaev intermediate states
                    # Or we just sort and compute sign properly:
                    sign = 1
                    n = length(new_kets)
                    for idx_i in 1:n
                        for idx_j in 1:(n-idx_i)
                            if new_kets[idx_j+1] < new_kets[idx_j]
                                new_kets[idx_j], new_kets[idx_j+1] = new_kets[idx_j+1], new_kets[idx_j]
                                sign *= -1
                            end
                        end
                    end
                    new_state[new_kets] = get(new_state, new_kets, 0.0) + coeff * overlap * b_coeff * sign
                end
            end
        end
    end
    return new_state
end

function evaluate_string(op_string, ket)
    state = ket
    for op in reverse(op_string.factors)
        if op isa FermionC; state = apply_fermion_c(state, (op.site, op.orbital, op.spin))
        elseif op isa FermionA; state = apply_fermion_a(state, (op.site, op.orbital, op.spin))
        elseif op isa ParticleProjector; state = apply_particle_projector(state, op)
        elseif op isa MultipletProjector; state = apply_multiplet_projector(state, op)
        end
    end
    return state
end

function get_doublet_coeff(pspin::Symbol, orb::Symbol, rspin::Symbol)
    # Kramers doublet coefficients from formal_derivation.tex, eq. (lines 129-132):
    #
    #   |+⟩ ≡ |j_eff=1/2, m=+1/2⟩ = (1/√3)(-|z,↑⟩ - i|y,↓⟩ - |x,↓⟩)
    #   |-⟩ ≡ |j_eff=1/2, m=-1/2⟩ = (1/√3)(|z,↓⟩ + i|y,↑⟩ - |x,↑⟩)
    #
    # Convention: hole picture, T-P equivalence L_{t2g} = -l_eff applied.
    # Normalization factor 1/√3 absorbed into pseudospin_ket via /3.0 (two-site product).
    if pspin == :up
        (orb == :z && rspin == :up)   && return -1.0    # -|z,↑⟩
        (orb == :x && rspin == :down) && return -1.0    # -|x,↓⟩
        (orb == :y && rspin == :down) && return -1im    # -i|y,↓⟩
    elseif pspin == :down
        (orb == :z && rspin == :down) && return 1.0     # +|z,↓⟩
        (orb == :x && rspin == :up)   && return -1.0    # -|x,↑⟩
        (orb == :y && rspin == :up)   && return 1im     # +i|y,↑⟩
    end
    return 0.0
end

function pseudospin_ket(site_i, s_i, site_j, s_j)
    ket = Dict{Vector{Tuple{Symbol, Symbol, Symbol}}, ComplexF64}()
    for orb_i in [:x, :y, :z], spin_i in [:up, :down]
        c_i = get_doublet_coeff(s_i, orb_i, spin_i)
        if c_i == 0 continue end
        for orb_j in [:x, :y, :z], spin_j in [:up, :down]
            c_j = get_doublet_coeff(s_j, orb_j, spin_j)
            if c_j == 0 continue end
            f1 = (site_i, orb_i, spin_i)
            f2 = (site_j, orb_j, spin_j)
            k = f1 < f2 ? [f1, f2] : [f2, f1]
            sgn = f1 < f2 ? 1 : -1
            ket[k] = get(ket, k, 0.0) + (c_i * c_j * sgn) / 3.0
        end
    end
    return ket
end

function pauli(mu::Symbol, s1::Symbol, s2::Symbol)
    if mu == :I; return s1 == s2 ? 1.0 : 0.0
    elseif mu == :x; return s1 != s2 ? 1.0 : 0.0
    elseif mu == :y; return (s1 == :up && s2 == :down) ? -1im : ((s1 == :down && s2 == :up) ? 1im : 0.0)
    elseif mu == :z; return (s1 == :up && s2 == :up) ? 1.0 : ((s1 == :down && s2 == :down) ? -1.0 : 0.0)
    end
end

"""
    project_to_pseudospin(H_eff::OperatorSum; site_i, site_j, bond)::AbstractQuantumOperator

Projects the effective Hamiltonian into the Kramers doublet pseudospin subspace
using exact right-to-left state evaluation.

**Architectural limit — strong-SOC approximation:**
This function operates in the λ_SOC → ∞ limit. The j_eff=1/2 Kramers doublet
basis states are the fixed analytical states from formal_derivation.tex §The model:

    |+⟩ = (1/√3)(-|z,↑⟩ - i|y,↓⟩ - |x,↓⟩)
    |-⟩ = (1/√3)(|z,↓⟩ + i|y,↑⟩ - |x,↑⟩)

Because the basis is fixed in the λ→∞ limit, taking λ_SOC → 0 *after* projection
is a mathematical contradiction. The non-relativistic limit oracle (K→0 at λ→0)
is architecturally excluded. See docs/critical_review_2026.md §Problem 2.

For finite-λ_SOC physics (Γ, Γ', DM interactions), a different basis implementation
working with the full 6×6 single-site Hilbert space is required.
"""
function project_to_pseudospin(H_eff::OperatorSum; site_i::Symbol=:i, site_j::Symbol=:j, bond::Symbol=:z)::AbstractQuantumOperator
    matrix_elements = Dict{Tuple{Symbol,Symbol,Symbol,Symbol}, Any}()
    spins = [:up, :down]
    
    for s_i in spins, s_j in spins, sp_i in spins, sp_j in spins
        bra = pseudospin_ket(site_i, sp_i, site_j, sp_j)
        ket = pseudospin_ket(site_i, s_i, site_j, s_j)
        
        element = 0.0
        for term in H_eff.terms
            if term isa ScaledOperator
                res_state = evaluate_string(term.op, ket)
                overlap = 0.0 + 0.0im
                for (k, v) in res_state
                    overlap += conj(get(bra, k, 0.0)) * v
                end
                if abs(overlap) > 1e-12
                    if abs(imag(overlap)) < 1e-12
                        overlap = complex(real(overlap), 0.0)
                    end
                    if abs(real(overlap)) < 1e-12
                        overlap = complex(0.0, imag(overlap))
                    end
                    element += term.scalar * overlap
                end
            end
        end
        matrix_elements[(sp_i, sp_j, s_i, s_j)] = element
    end
    
    terms = AbstractQuantumOperator[]
    for mu in [:x, :y, :z], nu in [:x, :y, :z]
        C = 0.0
        for s_i in spins, s_j in spins, sp_i in spins, sp_j in spins
            M = get(matrix_elements, (sp_i, sp_j, s_i, s_j), 0.0)
            if M isa Complex
                # Simplify real and imaginary parts to avoid symbolic artifacts
                M = complex(Symbolics.simplify(real(M)), Symbolics.simplify(imag(M)))
            else
                M = Symbolics.simplify(M)
            end
            if !Symbolics._iszero(M)
                P = pauli(mu, s_i, sp_i) * pauli(nu, s_j, sp_j)
                if P != 0.0
                    C += M * P / 4.0
                end
            end
        end
        
        if !Symbolics._iszero(C)
            push!(terms, ScaledOperator(Symbolics.simplify(C), OperatorString([SpinComposite(site_i, mu), SpinComposite(site_j, nu)])))
        end
    end
    
    return OperatorSum(terms)
end

"""
    extract_exchange_tensors(H_pseudospin::AbstractQuantumOperator, bond::Symbol)::Dict{Symbol, Num}

Applies Pauli matrix trace identities Tr(\\sigma^\\alpha \\sigma^\\beta) = 2\\delta^{\\alpha\\beta} 
to isolate the scalar coefficients for the Kitaev (K), Heisenberg (J), and off-diagonal (\\Gamma, \\Gamma') terms.
"""
function extract_exchange_tensors(H_pseudospin::AbstractQuantumOperator, bond::Symbol; site_i::Symbol=:i, site_j::Symbol=:j)::Dict{Symbol, Any}
    function extract_coeff(comp_i, comp_j)
        op_probe = OperatorString([SpinComposite(site_i, comp_i), SpinComposite(site_j, comp_j)])
        tr_val = 0
        for term in H_pseudospin.terms
            if term isa ScaledOperator
                tr_val += term.scalar * evaluate_pauli_trace(term.op * op_probe)
            end
        end
        tr_val = Symbolics.simplify(tr_val / 4)
        if tr_val isa Complex
            tr_val = Symbolics.simplify(real(tr_val))
        end
        # The pseudospin trace extracts coefficients of Pauli matrices (σ^μ σ^ν).
        # Since physical spin is S = σ / 2, the Hamiltonian term is J (σ/2)(σ/2) = (J/4) σ σ.
        # Thus the extracted coefficient C = J/4. We must multiply by 4 to return the physical J.
        return Symbolics.simplify(tr_val * 4)
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

    return Dict{Symbol, Any}(
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
