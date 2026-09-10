using Test
using Symbolics
using KitaevDerivation

@testset "[ALGEBRAIC] Canonical Anticommutation Relations (CAR)" begin
    # Define test fermion operators across sites, orbitals, and spins
    # Mode a: (site=:i, orbital=:xy, spin=:up)
    c_a     = FermionA(:i, :xy, :up)
    cdag_a  = FermionC(:i, :xy, :up)

    # Mode b: different site (:j != :i)
    c_b_site    = FermionA(:j, :xy, :up)
    cdag_b_site = FermionC(:j, :xy, :up)

    # Mode c: different orbital (:yz != :xy)
    c_c_orb    = FermionA(:i, :yz, :up)
    cdag_c_orb = FermionC(:i, :yz, :up)

    # Mode d: different spin (:down != :up)
    c_d_spin    = FermionA(:i, :xy, :down)
    cdag_d_spin = FermionC(:i, :xy, :down)

    # 1. Fundamental CAR identity: {c_a, c_b†} = δ_ab * IdentityOp()
    # Diagonal (a == b): {c_a, c_a†} = {c_a†, c_a} = IdentityOp()
    @test anticommutator(c_a, cdag_a) == IdentityOp()
    @test anticommutator(cdag_a, c_a) == IdentityOp()
    @test anticommutator(c_b_site, cdag_b_site) == IdentityOp()
    @test anticommutator(cdag_b_site, c_b_site) == IdentityOp()
    @test anticommutator(c_c_orb, cdag_c_orb) == IdentityOp()
    @test anticommutator(c_d_spin, cdag_d_spin) == IdentityOp()

    # Off-diagonal (a != b): {c_a, c_b†} = ZeroOp()
    # Different site
    @test anticommutator(c_a, cdag_b_site) == ZeroOp()
    @test anticommutator(cdag_b_site, c_a) == ZeroOp()
    # Different orbital
    @test anticommutator(c_a, cdag_c_orb) == ZeroOp()
    @test anticommutator(cdag_c_orb, c_a) == ZeroOp()
    # Different spin
    @test anticommutator(c_a, cdag_d_spin) == ZeroOp()
    @test anticommutator(cdag_d_spin, c_a) == ZeroOp()

    # 2. Annihilation anticommutation: {c_a, c_b} = ZeroOp()
    @test anticommutator(c_a, c_a) == ZeroOp()
    @test anticommutator(c_a, c_b_site) == ZeroOp()
    @test anticommutator(c_a, c_c_orb) == ZeroOp()
    @test anticommutator(c_a, c_d_spin) == ZeroOp()

    # 3. Creation anticommutation: {c_a†, c_b†} = ZeroOp()
    @test anticommutator(cdag_a, cdag_a) == ZeroOp()
    @test anticommutator(cdag_a, cdag_b_site) == ZeroOp()
    @test anticommutator(cdag_a, cdag_c_orb) == ZeroOp()
    @test anticommutator(cdag_a, cdag_d_spin) == ZeroOp()
end

@testset "[ALGEBRAIC] Fermion Nilpotency (Pauli Exclusion)" begin
    c_a    = FermionA(:i, :xy, :up)
    cdag_a = FermionC(:i, :xy, :up)
    c_b    = FermionA(:j, :yz, :down)
    cdag_b = FermionC(:j, :yz, :down)

    # 1. c_a * c_a = 0 and c_a† * c_a† = 0 via apply_algebraic_rules
    @test apply_algebraic_rules(AbstractQuantumOperator[c_a, c_a]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[cdag_a, cdag_a]) == [ZeroOp()]

    # 2. Embedded adjacent nilpotency in longer operator sequences
    @test apply_algebraic_rules(AbstractQuantumOperator[c_b, c_a, c_a, cdag_b]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[cdag_a, cdag_a, c_b]) == [ZeroOp()]

    # 3. sort_normal_order drops nilpotent states entirely (Pauli exclusion pruning)
    @test isempty(sort_normal_order(AbstractQuantumOperator[c_a, c_a]))
    @test isempty(sort_normal_order(AbstractQuantumOperator[cdag_a, cdag_a]))
    @test isempty(sort_normal_order(AbstractQuantumOperator[c_b, c_a, c_a]))
    @test isempty(sort_normal_order(AbstractQuantumOperator[cdag_a, cdag_a, c_b]))
end

@testset "[ALGEBRAIC] Wick Contractions and Canonical Normal Ordering" begin
    # Lexicographical ordering: :i < :j, :alpha < :beta, :down < :up
    cdag_i = FermionC(:i, :alpha, :up)
    c_i    = FermionA(:i, :alpha, :up)
    cdag_j = FermionC(:j, :alpha, :up)
    c_j    = FermionA(:j, :alpha, :up)

    # Test 1: Out-of-order distinct creation operators: c_j† c_i† (i < j) -> - c_i† c_j†
    seq1 = AbstractQuantumOperator[cdag_j, cdag_i]
    res1 = sort_normal_order(seq1)
    @test length(res1) == 1
    @test res1[1].first == [cdag_i, cdag_j]
    @test res1[1].second == -1

    # Test 2: The Wick Contraction: c_i c_i† -> IdentityOp() - c_i† c_i
    seq2 = AbstractQuantumOperator[c_i, cdag_i]
    res2 = sort_normal_order(seq2)
    @test length(res2) == 2
    @test ([IdentityOp()] => 1) in res2
    @test ([cdag_i, c_i] => -1) in res2

    # Test 3: Normal ordering nilpotency pruning: c_i c_i c_j† -> vanishes (empty result)
    seq3 = AbstractQuantumOperator[c_i, c_i, cdag_j]
    res3 = sort_normal_order(seq3)
    @test isempty(res3)

    # Test 4: Already normal ordered pair c_i† c_j remains unchanged with sign +1
    seq4 = AbstractQuantumOperator[cdag_i, c_j]
    res4 = sort_normal_order(seq4)
    @test length(res4) == 1
    @test res4[1].first == [cdag_i, c_j]
    @test res4[1].second == 1

    # Test 5: Out-of-order annihilation operators: c_j c_i (i < j) -> - c_i c_j
    seq5 = AbstractQuantumOperator[c_j, c_i]
    res5 = sort_normal_order(seq5)
    @test length(res5) == 1
    @test res5[1].first == [c_i, c_j]
    @test res5[1].second == -1

    # Test 6: Orbital reordering: :alpha < :beta -> c_beta† c_alpha† -> - c_alpha† c_beta†
    cdag_alpha = FermionC(:i, :alpha, :up)
    cdag_beta  = FermionC(:i, :beta, :up)
    res_orb = sort_normal_order(AbstractQuantumOperator[cdag_beta, cdag_alpha])
    @test length(res_orb) == 1
    @test res_orb[1].first == [cdag_alpha, cdag_beta]
    @test res_orb[1].second == -1

    # Test 7: Spin reordering: :down < :up -> c_up† c_down† -> - c_down† c_up†
    cdag_up = FermionC(:i, :alpha, :up)
    cdag_dn = FermionC(:i, :alpha, :down)
    res_spin = sort_normal_order(AbstractQuantumOperator[cdag_up, cdag_dn])
    @test length(res_spin) == 1
    @test res_spin[1].first == [cdag_dn, cdag_up]
    @test res_spin[1].second == -1
end

@testset "[ALGEBRAIC] Operator Arithmetic and AST Simplification" begin
    A = FermionC(:i, :xy, :up)
    B = FermionA(:j, :yz, :down)
    C = FermionC(:k, :zx, :up)
    D = FermionA(:l, :xy, :up)

    # 1. Associative flattening of OperatorString: (A * B) * C == A * (B * C) == A * B * C
    prod_left  = (A * B) * C
    prod_right = A * (B * C)
    prod_chain = A * B * C
    @test prod_left == prod_right
    @test prod_left == prod_chain
    @test prod_left == OperatorString([A, B, C])

    # 4-factor associativity
    prod4_left  = ((A * B) * C) * D
    prod4_split = (A * B) * (C * D)
    @test prod4_left == prod4_split
    @test prod4_left == OperatorString([A, B, C, D])

    # Associative flattening of OperatorSum: (A + B) + C == A + (B + C)
    sum_left  = (A + B) + C
    sum_right = A + (B + C)
    @test sum_left == sum_right
    @test sum_left == OperatorSum([A, B, C])

    # 2. Zero absorption: ZeroOp() * A == ZeroOp(), 0 * A == ZeroOp()
    @test ZeroOp() * A == ZeroOp()
    @test A * ZeroOp() == ZeroOp()
    @test 0 * A == ZeroOp()
    @test ZeroOp() * ZeroOp() == ZeroOp()
    @test 0 * ZeroOp() == ZeroOp()
    @test ZeroOp() + A == A
    @test A + ZeroOp() == A

    # 3. Identity absorption: IdentityOp() * A == A, 1 * A == A
    @test IdentityOp() * A == A
    @test A * IdentityOp() == A
    @test 1 * A == A
    @test IdentityOp() * IdentityOp() == IdentityOp()
    @test 1 * IdentityOp() == IdentityOp()
    @test apply_algebraic_rules(AbstractQuantumOperator[IdentityOp(), A]) == [A]
    @test apply_algebraic_rules(AbstractQuantumOperator[A, IdentityOp()]) == [A]
    @test apply_algebraic_rules(AbstractQuantumOperator[IdentityOp()]) == [IdentityOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[]) == [IdentityOp()]

    # 4. ScaledOperator scalar factoring: (2 * A) * (3 * B) == 6 * (A * B)
    scaled_ab = (2 * A) * (3 * B)
    @test scaled_ab == ScaledOperator(6, OperatorString([A, B]))
    @test scaled_ab == 6 * (A * B)
    @test (-1 * A) * (4 * B) == -4 * (A * B)
    @test (2 * A) * B == ScaledOperator(2, OperatorString([A, B]))
    @test A * (3 * B) == ScaledOperator(3, OperatorString([A, B]))

    # Symbolic scalar factoring
    @variables alpha beta
    sym_scaled = (alpha * A) * (beta * B)
    @test sym_scaled isa ScaledOperator
    @test isequal(sym_scaled.scalar, alpha * beta)
    @test sym_scaled.op == A * B

    # 5. Dagger (Hermitian conjugation) AST algebra
    @test dagger(A) == FermionA(:i, :xy, :up)
    @test dagger(B) == FermionC(:j, :yz, :down)
    @test dagger(dagger(A)) == A
    @test dagger(IdentityOp()) == IdentityOp()
    @test dagger(ZeroOp()) == ZeroOp()
    @test dagger(A * B) == dagger(B) * dagger(A)
    @test dagger(OperatorString([A, B, C])) == OperatorString([dagger(C), dagger(B), dagger(A)])
    @test dagger(2 * A) == 2 * dagger(A)
    @test dagger(A + B) == OperatorSum([dagger(A), dagger(B)])
end

@testset "[ALGEBRAIC] Anticommutator Bilinearity and ScaledOperator Handling" begin
    c_a    = FermionA(:i, :xy, :up)
    cdag_a = FermionC(:i, :xy, :up)
    c_b    = FermionA(:j, :yz, :down)
    cdag_b = FermionC(:j, :yz, :down)

    # 1. Bilinearity with numerical scalars: {α*A, β*B} == (α*β)*{A, B}
    # Diagonal pair: {c_a, c_a†} = IdentityOp()
    @test anticommutator(2 * c_a, 3 * cdag_a) == 6 * anticommutator(c_a, cdag_a)
    @test anticommutator(2 * c_a, 3 * cdag_a) == 6 * IdentityOp()
    @test anticommutator(3 * cdag_a, 2 * c_a) == 6 * anticommutator(cdag_a, c_a)
    @test anticommutator(3 * cdag_a, 2 * c_a) == 6 * IdentityOp()

    # Left-only scaling: {α*A, B} == α*{A, B}
    @test anticommutator(2 * c_a, cdag_a) == 2 * anticommutator(c_a, cdag_a)
    @test anticommutator(2 * c_a, cdag_a) == 2 * IdentityOp()
    @test anticommutator(4 * cdag_a, c_a) == 4 * IdentityOp()

    # Right-only scaling: {A, β*B} == β*{A, B}
    @test anticommutator(c_a, 3 * cdag_a) == 3 * anticommutator(c_a, cdag_a)
    @test anticommutator(c_a, 3 * cdag_a) == 3 * IdentityOp()
    @test anticommutator(cdag_a, 5 * c_a) == 5 * IdentityOp()

    # Negative scalar factors
    @test anticommutator(-1 * c_a, 4 * cdag_a) == -4 * anticommutator(c_a, cdag_a)
    @test anticommutator(-2 * c_a, -3 * cdag_a) == 6 * IdentityOp()

    # 2. Orthogonal fermion modes: {c_a, c_b†} = ZeroOp()
    @test anticommutator(2 * c_a, 3 * cdag_b) == 6 * anticommutator(c_a, cdag_b)
    @test anticommutator(2 * c_a, 3 * cdag_b) == ZeroOp()
    @test anticommutator(2 * c_a, cdag_b) == ZeroOp()
    @test anticommutator(c_a, 3 * cdag_b) == ZeroOp()

    # Nilpotent pairs: {c_a, c_b} = ZeroOp(), {c_a†, c_b†} = ZeroOp()
    @test anticommutator(2 * c_a, 3 * c_b) == 6 * anticommutator(c_a, c_b)
    @test anticommutator(2 * c_a, 3 * c_b) == ZeroOp()
    @test anticommutator(2 * cdag_a, 3 * cdag_b) == ZeroOp()
    @test anticommutator(2 * c_a, 3 * c_a) == ZeroOp()
    @test anticommutator(2 * cdag_a, 3 * cdag_a) == ZeroOp()

    # 3. Bilinearity with symbolic scalars
    @variables alpha beta
    sym_anticomm = anticommutator(alpha * c_a, beta * cdag_a)
    @test sym_anticomm isa ScaledOperator
    @test isequal(sym_anticomm.scalar, alpha * beta)
    @test sym_anticomm.op == IdentityOp()
    @test anticommutator(alpha * c_a, beta * cdag_a) == (alpha * beta) * anticommutator(c_a, cdag_a)

    sym_left = anticommutator(alpha * c_a, cdag_a)
    @test sym_left isa ScaledOperator
    @test isequal(sym_left.scalar, alpha)
    @test sym_left.op == IdentityOp()

    sym_right = anticommutator(c_a, beta * cdag_a)
    @test sym_right isa ScaledOperator
    @test isequal(sym_right.scalar, beta)
    @test sym_right.op == IdentityOp()

    # Symbolic orthogonal pair vanishes
    @test anticommutator(alpha * c_a, beta * cdag_b) == ZeroOp()

    # 4. General operators (composite OperatorString)
    A = cdag_a * c_a
    B = cdag_b * c_b
    @test anticommutator(2 * A, 3 * B) == 6 * anticommutator(A, B)
end

@testset "[PROJECTOR] Projector Laws (Idempotency and Complete Orthogonality)" begin
    # Physical d^4 Kanamori multiplet projectors on site :i
    P_0 = MultipletProjector(0, :i)
    P_1 = MultipletProjector(1, :i)
    P_2 = MultipletProjector(2, :i)
    multiplets = [P_0, P_1, P_2]

    # 1. Idempotency: P_L^2 = P_L for all L in {0, 1, 2}
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_0]) == [P_0]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_1, P_1]) == [P_1]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_2, P_2]) == [P_2]

    # Higher powers: P_L^3 = P_L
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_0, P_0]) == [P_0]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_1, P_1, P_1]) == [P_1]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_2, P_2, P_2]) == [P_2]

    # 2. Complete pairwise orthogonality on the same site: P_i * P_j = ZeroOp() for all distinct pairs (i != j)
    for (i_idx, Pi) in enumerate(multiplets)
        for (j_idx, Pj) in enumerate(multiplets)
            if i_idx != j_idx
                @test apply_algebraic_rules(AbstractQuantumOperator[Pi, Pj]) == [ZeroOp()]
            else
                @test apply_algebraic_rules(AbstractQuantumOperator[Pi, Pj]) == [Pi]
            end
        end
    end

    # Explicit checks for all 6 directed pairs on site :i
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_1]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_1, P_0]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_2]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_2, P_0]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_1, P_2]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_2, P_1]) == [ZeroOp()]

    # 3. LowEnergyProjector laws (j_eff = 1/2 vs 3/2) on the same site
    P_half      = LowEnergyProjector("1/2", :i)
    P_threehalf = LowEnergyProjector("3/2", :i)

    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_half]) == [P_half]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_threehalf, P_threehalf]) == [P_threehalf]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_threehalf]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_threehalf, P_half]) == [ZeroOp()]

    # 4. ParticleProjector (hole occupancy) laws
    P1_i = ParticleProjector(1, :i)
    P2_i = ParticleProjector(2, :i)

    @test apply_algebraic_rules(AbstractQuantumOperator[P1_i, P1_i]) == [P1_i]
    @test apply_algebraic_rules(AbstractQuantumOperator[P2_i, P2_i]) == [P2_i]
    @test apply_algebraic_rules(AbstractQuantumOperator[P1_i, P2_i]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P2_i, P1_i]) == [ZeroOp()]

    # 5. Projector Hermiticity: P† = P (Projectors are self-adjoint)
    @test dagger(P_0) == P_0
    @test dagger(P_1) == P_1
    @test dagger(P_2) == P_2
    @test dagger(P_half) == P_half
    @test dagger(P_threehalf) == P_threehalf
    @test dagger(P1_i) == P1_i
    @test dagger(P2_i) == P2_i

    # 6. Projector absorption of IdentityOp and ZeroOp
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, ZeroOp()]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[ZeroOp(), P_0]) == [ZeroOp()]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, IdentityOp()]) == [P_0]
    @test apply_algebraic_rules(AbstractQuantumOperator[IdentityOp(), P_0]) == [P_0]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, IdentityOp(), P_0]) == [P_0]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, IdentityOp(), P_1]) == [ZeroOp()]

    # 7. Mixed projector non-collapse (MultipletProjector and LowEnergyProjector do not collapse)
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_half]) == [P_0, P_half]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_0]) == [P_half, P_0]

    # 8. Cross-site projector independence: projectors on distinct sites (:i != :j)
    # act on different Hilbert spaces and must NOT annihilate each other or collapse.
    P_0_j = MultipletProjector(0, :j)
    P_1_j = MultipletProjector(1, :j)
    P_2_j = MultipletProjector(2, :j)
    P_half_j      = LowEnergyProjector("1/2", :j)
    P_threehalf_j = LowEnergyProjector("3/2", :j)
    P1_j = ParticleProjector(1, :j)
    P2_j = ParticleProjector(2, :j)

    # MultipletProjectors across sites (:i != :j)
    for Li in 0:2
        for Lj in 0:2
            Pi = MultipletProjector(Li, :i)
            Pj = MultipletProjector(Lj, :j)
            @test apply_algebraic_rules(AbstractQuantumOperator[Pi, Pj]) == [Pi, Pj]
            @test apply_algebraic_rules(AbstractQuantumOperator[Pj, Pi]) == [Pj, Pi]
        end
    end
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_1_j]) == [P_0, P_1_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_1, P_0_j]) == [P_1, P_0_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_0_j]) == [P_0, P_0_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_2, P_2_j]) == [P_2, P_2_j]

    # LowEnergyProjectors across sites (:i != :j)
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_threehalf_j]) == [P_half, P_threehalf_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_threehalf, P_half_j]) == [P_threehalf, P_half_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_half_j]) == [P_half, P_half_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_threehalf, P_threehalf_j]) == [P_threehalf, P_threehalf_j]

    # ParticleProjectors across sites (:i != :j)
    @test apply_algebraic_rules(AbstractQuantumOperator[P1_i, P2_j]) == [P1_i, P2_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P1_i, P1_j]) == [P1_i, P1_j]

    # Cross-site mixed projectors
    @test apply_algebraic_rules(AbstractQuantumOperator[P_0, P_half_j]) == [P_0, P_half_j]
    @test apply_algebraic_rules(AbstractQuantumOperator[P_half, P_0_j]) == [P_half, P_0_j]
end
