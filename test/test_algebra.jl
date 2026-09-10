using Test
using KitaevDerivation

@testset "Canonical Anticommutation Relations (CAR)" begin
    c_dag_i = FermionC(:i, :alpha, :up)
    c_j     = FermionA(:j, :beta, :down)
    c_dag_j = FermionC(:j, :beta, :down)
    c_i     = FermionA(:i, :alpha, :up)

    # Trivial Cases: Same type operators anticommute to 0
    @test anticommutator(c_dag_i, c_dag_j) == 0
    @test anticommutator(c_i, c_j) == 0
    
    # Edge Case: Same state creation/annihilation must yield identity (1)
    @test anticommutator(c_dag_i, c_i) == 1
    @test anticommutator(c_i, c_dag_i) == 1
end

@testset "d4 Subspace Projector Algebra" begin
    P_L0 = Projector(:L0)
    P_L1 = Projector(:L1)
    P_L2 = Projector(:L2)
    P_singlet = Projector(:Singlet)
    P_triplet = Projector(:Triplet)

    # 1. Idempotency: P^2 = P
    @test apply_algebraic_rules([P_L0, P_L0]) == [P_L0]
    @test apply_algebraic_rules([P_L1, P_L1]) == [P_L1]
    
    # 2. Orthogonality: P_L * P_L' = 0
    @test isempty(apply_algebraic_rules([P_L0, P_L1]))
    @test isempty(apply_algebraic_rules([P_L1, P_L2]))
    @test isempty(apply_algebraic_rules([P_L2, P_L0]))

    # 3. Cross-channel orthogonality
    @test isempty(apply_algebraic_rules([P_singlet, P_triplet]))
end

@testset "Fermion Nilpotency" begin
    c_dag_i = FermionC(:i, :alpha, :up)
    c_i     = FermionA(:i, :alpha, :up)
    
    # c^dag c^dag = 0
    @test isempty(apply_algebraic_rules([c_dag_i, c_dag_i]))
    # c c = 0
    @test isempty(apply_algebraic_rules([c_i, c_i]))
end
