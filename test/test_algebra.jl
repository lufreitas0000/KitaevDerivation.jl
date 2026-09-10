using Test
using KitaevDerivation

@testset "Canonical Anticommutation Relations (CAR)" begin
    c_dag_i = FermionC(:i, :alpha, :up)
    c_j     = FermionA(:j, :beta, :down)
    c_dag_j = FermionC(:j, :beta, :down)
    c_i     = FermionA(:i, :alpha, :up)

    @test anticommutator(c_dag_i, c_dag_j) == 0
    @test anticommutator(c_i, c_j) == 0
    @test anticommutator(c_dag_i, c_i) == 1
    @test anticommutator(c_i, c_dag_i) == 1
end

@testset "d4 Subspace Projector Algebra" begin
    P_L0 = Projector(:L0)
    P_L1 = Projector(:L1)
    P_L2 = Projector(:L2)
    P_singlet = Projector(:Singlet)
    P_triplet = Projector(:Triplet)

    @test apply_algebraic_rules([P_L0, P_L0]) == [P_L0]
    @test isempty(apply_algebraic_rules([P_L0, P_L1]))
    @test isempty(apply_algebraic_rules([P_singlet, P_triplet]))
end

@testset "Wick Contractions and Normal Ordering" begin
    c_dag_i = FermionC(:i, :alpha, :up)
    c_i     = FermionA(:i, :alpha, :up)
    c_dag_j = FermionC(:j, :beta, :down)
    
    # Test 1: Out of order distinct fermions (c_j^\dagger c_i^\dagger) -> - c_i^\dagger c_j^\dagger
    # Assuming lexicographical sorting where :i < :j
    seq1 = AbstractQuantumOperator[c_dag_j, c_dag_i]
    res1 = sort_normal_order(seq1)
    @test length(res1) == 1
    @test res1[1].first == [c_dag_i, c_dag_j]
    @test res1[1].second == -1

    # Test 2: The Contraction (c_i c_i^\dagger) -> 1 - c_i^\dagger c_i
    seq2 = AbstractQuantumOperator[c_i, c_dag_i]
    res2 = sort_normal_order(seq2)
    @test length(res2) == 2
    # The identity term (empty array) has coefficient +1
    @test (AbstractQuantumOperator[] => 1) in res2
    # The normal ordered term has coefficient -1
    @test ([c_dag_i, c_i] => -1) in res2
    
    # Test 3: Normal Ordering Pruning (c_i c_i c_dag_j) -> evaluates to 0 due to Pauli exclusion
    seq3 = AbstractQuantumOperator[c_i, c_i, c_dag_j]
    res3 = sort_normal_order(seq3)
    @test isempty(res3) # The AST branch vanishes completely
end
