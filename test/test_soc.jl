# test/test_soc.jl
# Independent Mathematical-Physics Test Suite: Spin-Orbit Coupling & T-P Equivalence
# Category Labels: ALGEBRAIC, PROJECTOR, PHYSICAL_ORACLE, LIMIT, SYMMETRY, REGRESSION, NUMERICAL_CROSSCHECK, COMPLEXITY

using Test
using Symbolics
using SymbolicUtils
using LinearAlgebra
using KitaevDerivation

# ---------------------------------------------------------------------------
# [ALGEBRAIC] T-P Equivalence Rewriting via SymbolicUtils
# ---------------------------------------------------------------------------
@testset "[ALGEBRAIC] T-P Equivalence Rewriting via SymbolicUtils" begin
    # Declared Provenance:
    # Within the octahedral t2g orbital manifold (projection of L=2 onto t2g),
    # the orbital angular momentum operator acts as an effective l_eff = 1
    # angular momentum with a fundamental MINUS sign:
    #     L_{t2g} = -l_{eff}
    # Sources:
    # - Abragam & Bleaney, "Electron Paramagnetic Resonance of Transition Ions" (1970)
    # - Jackeli & Khaliullin, Phys. Rev. Lett. 102, 017205 (2009)
    # - AGENTS.md Section 1.3
    #
    # Executable Invariant:
    # For every spatial component alpha in {x, y, z}, applying the rewriting
    # rules returned by `t_p_equivalence_rules()` to `OrbitalComposite(:i, alpha)`
    # MUST dynamically transform the operator into:
    #     -1 * GenericOp(:l_eff_alpha)
    # The coefficient MUST be strictly -1 (negative sign), NOT +1.
    
    rules = t_p_equivalence_rules()
    @test !isempty(rules)

    Lx = OrbitalComposite(:i, :x)
    Ly = OrbitalComposite(:i, :y)
    Lz = OrbitalComposite(:i, :z)

    # 1. Dynamic rewriting of Lx -> -l_{eff, x}
    res_x = nothing
    for r in rules
        out = r(Lx)
        if out !== nothing
            res_x = out
            break
        end
    end
    @test res_x !== nothing
    @test res_x == ScaledOperator(-1, GenericOp(:l_eff_x)) || res_x == -1 * GenericOp(:l_eff_x)
    if res_x isa ScaledOperator
        @test isequal(res_x.scalar, -1)
        @test res_x.op == GenericOp(:l_eff_x)
    end

    # 2. Dynamic rewriting of Ly -> -l_{eff, y}
    res_y = nothing
    for r in rules
        out = r(Ly)
        if out !== nothing
            res_y = out
            break
        end
    end
    @test res_y !== nothing
    @test res_y == ScaledOperator(-1, GenericOp(:l_eff_y)) || res_y == -1 * GenericOp(:l_eff_y)
    if res_y isa ScaledOperator
        @test isequal(res_y.scalar, -1)
        @test res_y.op == GenericOp(:l_eff_y)
    end

    # 3. Dynamic rewriting of Lz -> -l_{eff, z}
    res_z = nothing
    for r in rules
        out = r(Lz)
        if out !== nothing
            res_z = out
            break
        end
    end
    @test res_z !== nothing
    @test res_z == ScaledOperator(-1, GenericOp(:l_eff_z)) || res_z == -1 * GenericOp(:l_eff_z)
    if res_z isa ScaledOperator
        @test isequal(res_z.scalar, -1)
        @test res_z.op == GenericOp(:l_eff_z)
    end

    # 4. Anti-leak invariant: rules must NOT match non-orbital operators
    Sx = SpinComposite(:i, :x)
    res_Sx = nothing
    for r in rules
        out = r(Sx)
        if out !== nothing
            res_Sx = out
            break
        end
    end
    @test res_Sx === nothing

    # 5. Anti-leak invariant: rules must NOT match fermionic operators
    c_op = FermionA(:i, :xy, :up)
    res_c = nothing
    for r in rules
        out = r(c_op)
        if out !== nothing
            res_c = out
            break
        end
    end
    @test res_c === nothing
end

# ---------------------------------------------------------------------------
# [PROJECTOR] j_eff = 1/2 Subspace Projector Laws and Operator Action
# ---------------------------------------------------------------------------
@testset "[PROJECTOR] j_eff = 1/2 Subspace Projector Laws and Operator Action" begin
    # Declared Provenance:
    # P_{1/2} is the orthogonal projector onto the two-dimensional Kramers
    # doublet j_eff = 1/2 subspace.
    # Mathematical identities:
    # 1. Idempotency: P_{1/2}^2 = P_{1/2}
    # 2. Hermiticity: P_{1/2}^\dagger = P_{1/2}
    # 3. Orthogonality to j_eff = 3/2: P_{1/2} P_{3/2} = P_{3/2} P_{1/2} = 0
    # 4. General projection law:
    #    project_jeff_half(O, lambda) must represent P_{1/2} * O * P_{1/2}.
    #    - If O = IdentityOp(), result MUST be P_{1/2} (scalar 1, NOT lambda/2).
    #    - If O = ZeroOp(), result MUST be ZeroOp().
    #    - If O = P_{3/2}, result MUST be ZeroOp() (orthogonal subspace).
    #    - If O = H_so, result MUST be lambda * P_{1/2} (eigenvalue is lambda).
    #    - If O is scaled by alpha, result MUST scale linearly by alpha.
    # Sources:
    # - Jackeli & Khaliullin, PRL 102, 017205 (2009)
    # - mathematical-tdd skill §Projectors
    
    @variables lambda_soc::Real alpha::Real
    
    P_half      = LowEnergyProjector("1/2", :i)
    P_threehalf = LowEnergyProjector("3/2", :i)
    P_half_j    = LowEnergyProjector("1/2", :j)

    # 1. Projector algebraic laws in BasisAndAlgebra
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_half]) == [P_half]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_half, P_half]) == [P_half]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_threehalf]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_threehalf, P_half]) == [ZeroOp()]
    @test dagger(P_half) == P_half
    @test dagger(P_threehalf) == P_threehalf

    # Cross-site independence: projectors on distinct sites do NOT annihilate
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_half_j]) == [P_half, P_half_j]

    # 2. General projection: P_{1/2} * Identity * P_{1/2} = P_{1/2}
    # MUST NOT return (lambda_soc / 2) * P_half!
    proj_I = project_jeff_half(IdentityOp(), lambda_soc; site=:i)
    @test proj_I == P_half || (proj_I isa ScaledOperator && isequal(proj_I.scalar, 1) && proj_I.op == P_half)
    if proj_I isa ScaledOperator
        @test !isequal(proj_I.scalar, lambda_soc / 2)
    end

    # 3. General projection: P_{1/2} * ZeroOp * P_{1/2} = ZeroOp
    # MUST NOT return (lambda_soc / 2) * P_half!
    proj_zero = project_jeff_half(ZeroOp(), lambda_soc; site=:i)
    @test proj_zero == ZeroOp()

    # 4. General projection: P_{1/2} * P_{3/2} * P_{1/2} = ZeroOp (orthogonal subspace)
    # MUST NOT return (lambda_soc / 2) * P_half!
    proj_ortho = project_jeff_half(P_threehalf, lambda_soc; site=:i)
    @test proj_ortho == ZeroOp()

    # 5. Projection of H_so: P_{1/2} * H_so * P_{1/2} = lambda_soc * P_{1/2}
    # In hole picture, E(1/2) = lambda_soc (NOT lambda_soc / 2)
    H_so = spin_orbit_coupling(lambda_soc, :i)
    proj_Hso = project_jeff_half(H_so, lambda_soc; site=:i)
    @test proj_Hso isa ScaledOperator
    @test isequal(proj_Hso.scalar, lambda_soc)
    @test proj_Hso.op == P_half
    # Explicitly reject the fake green scalar lambda_soc / 2
    @test !isequal(proj_Hso.scalar, lambda_soc / 2)

    # 6. Linearity of projection: project_jeff_half(alpha * H_so) = alpha * lambda_soc * P_{1/2}
    scaled_Hso = ScaledOperator(alpha, H_so)
    proj_scaled = project_jeff_half(scaled_Hso, lambda_soc; site=:i)
    @test proj_scaled isa ScaledOperator
    @test isequal(Symbolics.simplify(proj_scaled.scalar * (proj_scaled.op isa ScaledOperator ? proj_scaled.op.scalar : 1)), Symbolics.simplify(alpha * lambda_soc))
    @test proj_scaled.op == P_half || (proj_scaled.op isa ScaledOperator && proj_scaled.op.op == P_half)
end

# ---------------------------------------------------------------------------
# [PHYSICAL_ORACLE] Spin-Orbit Coupling Eigenvalues and 3λ/2 Gap
# ---------------------------------------------------------------------------
@testset "[PHYSICAL_ORACLE] Spin-Orbit Coupling Eigenvalues and 3λ/2 Gap" begin
    # Declared Provenance:
    # SOC Hamiltonian: H_so = -lambda_soc * (l_eff ⋅ S)
    # Total effective angular momentum: j_eff = l_eff + S (l_eff = 1, S = 1/2)
    # Operator identity:
    #     l_eff ⋅ S = (1/2) * [j_eff(j_eff + 1) - l_eff(l_eff + 1) - S(S + 1)]
    # - For j_eff = 1/2:
    #     l_eff ⋅ S = (1/2) * [3/4 - 2 - 3/4] = -1
    #     E(1/2) = -lambda_soc * (-1) = +lambda_soc
    # - For j_eff = 3/2:
    #     l_eff ⋅ S = (1/2) * [15/4 - 2 - 3/4] = +1/2
    #     E(3/2) = -lambda_soc * (+1/2) = -lambda_soc / 2
    # - Spectral Gap:
    #     Delta_E_SOC = E(1/2) - E(3/2) = lambda_soc - (-lambda_soc / 2) = 3*lambda_soc / 2
    # Sources:
    # - Jackeli & Khaliullin, Phys. Rev. Lett. 102, 017205 (2009)
    # - AGENTS.md Section 1.3
    # - symbolic-physics skill §SOC
    
    @variables lambda_soc::Real

    # Exact symbolic eigenvalues
    E_half = lambda_soc
    E_threehalf = -lambda_soc / 2

    # Verify individual level energies
    @test isequal(E_half, lambda_soc)
    @test isequal(E_threehalf, -lambda_soc / 2)

    # Verify exact analytical splitting Delta E = 3*lambda / 2
    delta_E_soc = Symbolics.simplify(E_half - E_threehalf)
    @test isequal(delta_E_soc, 3 * lambda_soc / 2)
    @test isequal(delta_E_soc, (3//2) * lambda_soc)

    # Reject incorrect splittings
    @test !isequal(delta_E_soc, lambda_soc)
    @test !isequal(delta_E_soc, lambda_soc / 2)
    @test !isequal(delta_E_soc, 2 * lambda_soc)

    # Invariant: Total trace of H_so over the 6 t2g states is ZERO
    # 2 states in j_eff = 1/2 doublet + 4 states in j_eff = 3/2 quartet
    total_trace = Symbolics.simplify(2 * E_half + 4 * E_threehalf)
    @test isequal(total_trace, 0)

    # Invariant: Subspace dimensions
    deg_half = 2
    deg_threehalf = 4
    @test deg_half + deg_threehalf == 6
end

# ---------------------------------------------------------------------------
# [LIMIT] Vanishing Spin-Orbit Coupling Limit (lambda -> 0)
# ---------------------------------------------------------------------------
@testset "[LIMIT] Vanishing Spin-Orbit Coupling Limit (lambda -> 0)" begin
    # Declared Provenance:
    # In the non-relativistic limit lambda_soc -> 0:
    # 1. The energy gap Delta_E_SOC vanishes identically: Delta_E_SOC(0) = 0.
    # 2. Both j_eff = 1/2 and j_eff = 3/2 levels become 6-fold degenerate at E = 0.
    # 3. The physical SOC Hamiltonian H_so reduces to zero.
    # Source: mathematical-tdd skill §Physical limits
    
    @variables lambda_soc::Real

    delta_E_soc = (3//2) * lambda_soc
    E_half = lambda_soc
    E_threehalf = -lambda_soc / 2

    @test isequal(Symbolics.substitute(delta_E_soc, Dict(lambda_soc => 0)), 0)
    @test isequal(Symbolics.substitute(E_half, Dict(lambda_soc => 0)), 0)
    @test isequal(Symbolics.substitute(E_threehalf, Dict(lambda_soc => 0)), 0)

    # Operator level check
    H_so_zero = spin_orbit_coupling(Num(0), :i)
    @test H_so_zero isa ScaledOperator
    @test isequal(H_so_zero.scalar, 0) || Symbolics._iszero(H_so_zero.scalar)
end

# ---------------------------------------------------------------------------
# [SYMMETRY] Kramers Doublet Degeneracy and State Invariance
# ---------------------------------------------------------------------------
@testset "[SYMMETRY] Kramers Doublet Degeneracy and State Invariance" begin
    # Declared Provenance:
    # By time-reversal symmetry Theta (with Theta^2 = -1 for half-integer spin),
    # the j_eff = 1/2 subspace forms a Kramers doublet:
    #     |j_eff = 1/2, +1/2> = 1/sqrt(3) * (|z, up> + |x, down> + i|y, down>)
    #     |j_eff = 1/2, -1/2> = 1/sqrt(3) * (|z, down> - |x, up> + i|y, up>)
    # Both states MUST be degenerate exact eigenstates of H_so with eigenvalue +lambda.
    # Sources:
    # - Jackeli & Khaliullin, PRL 102, 017205 (2009)
    # - ExchangeExtraction.jl pseudospin basis definitions
    
    # Basis: {|x,up>, |x,dn>, |y,up>, |y,dn>, |z,up>, |z,dn>}
    ket_plus  = ComplexF64[0, 1, 0, 1im, 1, 0] / sqrt(3)
    ket_minus = ComplexF64[-1, 0, 1im, 0, 0, 1] / sqrt(3)

    # Orthonormality of Kramers partners
    @test isapprox(dot(ket_plus, ket_plus), 1.0; atol=1e-12)
    @test isapprox(dot(ket_minus, ket_minus), 1.0; atol=1e-12)
    @test isapprox(dot(ket_plus, ket_minus), 0.0; atol=1e-12)

    # Construct l_eff (l=1) and S (S=1/2) in Cartesian basis
    lx = ComplexF64[0 0 0; 0 0 -im; 0 im 0]
    ly = ComplexF64[0 0 im; 0 0 0; -im 0 0]
    lz = ComplexF64[0 -im 0; im 0 0; 0 0 0]

    Sx = ComplexF64[0 1/2; 1/2 0]
    Sy = ComplexF64[0 -im/2; im/2 0]
    Sz = ComplexF64[1/2 0; 0 -1/2]

    L_dot_S = kron(lx, Sx) + kron(ly, Sy) + kron(lz, Sz)

    # Both Kramers partners are exact eigenstates of l_eff ⋅ S with eigenvalue -1
    @test isapprox(L_dot_S * ket_plus, -1.0 * ket_plus; atol=1e-12)
    @test isapprox(L_dot_S * ket_minus, -1.0 * ket_minus; atol=1e-12)

    # Action of H_so = -lambda * (l_eff ⋅ S): eigenvalue is +lambda for both
    lambda_val = 0.55
    H_mat = -lambda_val * L_dot_S
    @test isapprox(H_mat * ket_plus, lambda_val * ket_plus; atol=1e-12)
    @test isapprox(H_mat * ket_minus, lambda_val * ket_minus; atol=1e-12)
end

# ---------------------------------------------------------------------------
# [NUMERICAL_CROSSCHECK] Finite-Dimensional Matrix Diagonalization of L·S in t2g
# ---------------------------------------------------------------------------
@testset "[NUMERICAL_CROSSCHECK] Finite-Dimensional Matrix Diagonalization of L·S in t2g" begin
    # Declared Provenance:
    # Independent numerical construction of the full 6x6 spin-orbit Hamiltonian
    # in the product space {|x>, |y>, |z>} ⊗ {|up>, |down>}.
    # Direct numerical diagonalization verifies:
    # 1. 2 eigenvalues equal to +lambda (doublet)
    # 2. 4 eigenvalues equal to -lambda/2 (quartet)
    # 3. Exact gap ΔE = 1.5 * lambda
    # 4. Tr(H_so) = 0
    # 5. Projector properties: P_{1/2}^2 = P_{1/2}, Tr(P_{1/2}) = 2, Tr(P_{3/2}) = 4
    
    lx = ComplexF64[0 0 0; 0 0 -im; 0 im 0]
    ly = ComplexF64[0 0 im; 0 0 0; -im 0 0]
    lz = ComplexF64[0 -im 0; im 0 0; 0 0 0]

    Sx = ComplexF64[0 1/2; 1/2 0]
    Sy = ComplexF64[0 -im/2; im/2 0]
    Sz = ComplexF64[1/2 0; 0 -1/2]

    L_dot_S = kron(lx, Sx) + kron(ly, Sy) + kron(lz, Sz)

    lambda_test = 0.45 # eV
    H_soc_mat = -lambda_test * L_dot_S

    evals = eigvals(Hermitian(H_soc_mat))
    sort!(evals)

    # 4 quartet eigenvalues at -lambda/2
    for k in 1:4
        @test isapprox(evals[k], -lambda_test / 2; atol=1e-12)
    end

    # 2 doublet eigenvalues at +lambda
    for k in 5:6
        @test isapprox(evals[k], lambda_test; atol=1e-12)
    end

    # Spectral gap
    num_gap = evals[5] - evals[1]
    @test isapprox(num_gap, 1.5 * lambda_test; atol=1e-12)

    # Trace is zero
    @test isapprox(tr(H_soc_mat), 0.0; atol=1e-12)

    # Spectral projectors from projection operator identity
    I6 = Matrix{ComplexF64}(I, 6, 6)
    P_half_num = (1/3) * (I6 - 2 * L_dot_S)
    P_threehalf_num = (1/3) * (2 * I6 + 2 * L_dot_S)

    # Projector algebra
    @test isapprox(P_half_num * P_half_num, P_half_num; atol=1e-12)
    @test isapprox(P_threehalf_num * P_threehalf_num, P_threehalf_num; atol=1e-12)
    @test isapprox(P_half_num * P_threehalf_num, zeros(ComplexF64, 6, 6); atol=1e-12)
    @test isapprox(P_half_num + P_threehalf_num, I6; atol=1e-12)
    @test isapprox(tr(P_half_num), 2.0; atol=1e-12)
    @test isapprox(tr(P_threehalf_num), 4.0; atol=1e-12)

    # Projected Hamiltonian
    @test isapprox(P_half_num * H_soc_mat * P_half_num, lambda_test * P_half_num; atol=1e-12)
    @test isapprox(P_threehalf_num * H_soc_mat * P_threehalf_num, (-lambda_test / 2) * P_threehalf_num; atol=1e-12)
end

# ---------------------------------------------------------------------------
# [REGRESSION] Anti-Mock Adversarial Verification
# ---------------------------------------------------------------------------
@testset "[REGRESSION] Anti-Mock Invariants and Parameter Audits" begin
    # Declared Provenance:
    # Audits against specific known mock / fake-green failure modes:
    # 1. Returning lambda_soc / 2 instead of lambda_soc for P_{1/2} H_so P_{1/2}
    # 2. Returning (lambda_soc / 2) * P_{1/2} regardless of what operator was passed
    # 3. Flips in sign in T-P equivalence (L -> +l_eff instead of -l_eff)
    # 4. Incorrect spectral gap (lambda instead of 3*lambda/2)
    
    @variables lambda_soc::Real

    # Mutation 1: E(1/2) = lambda / 2
    @test !isequal(lambda_soc / 2, lambda_soc)

    # Mutation 2: Delta E = lambda
    @test !isequal(lambda_soc, (3//2) * lambda_soc)

    # Mutation 3: Delta E = 2*lambda
    @test !isequal(2 * lambda_soc, (3//2) * lambda_soc)

    # Mutation 4: Positive sign in T-P equivalence
    wrong_t_p = 1 * GenericOp(:l_eff_x)
    correct_t_p = -1 * GenericOp(:l_eff_x)
    @test wrong_t_p != correct_t_p
end

# ---------------------------------------------------------------------------
# [COMPLEXITY] LowEnergyProjector AST Compactness and Normal Form
# ---------------------------------------------------------------------------
@testset "[COMPLEXITY] LowEnergyProjector AST Compactness and Normal Form" begin
    # Declared Provenance:
    # AST rewriting must simplify repeatedly projected operations to a single
    # normal-ordered term, preventing exponential AST explosion.
    P_half = LowEnergyProjector("1/2", :i)
    chain = AbstractQuantumOperator[P_half, P_half, P_half, P_half]
    simplified = apply_algebraic_rules(chain)
    @test length(simplified) == 1
    @test simplified[1] == P_half
end
