using Test
using Symbolics
using KitaevDerivation

@testset "Intertwining Algebra Oracles" begin
    # Defines the creation and annihilation operators on a target site
    c_dag = FermionC(:i, :z, :up)
    c_ann = FermionA(:i, :z, :up)
    
    # Defines the dimensional particle projectors for the d5 (1-hole) and d4 (2-hole) manifolds
    P1 = ParticleProjector(1, :i)
    P2 = ParticleProjector(2, :i)

    # Oracle 1: Fermionic creation commutes through the projector by shifting the particle number +1
    # h^\dagger |1> = |2>  ==>  h^\dagger P^{(1)} = P^{(2)} h^\dagger
    @test apply_algebraic_rules([c_dag, P1]) == [P2, c_dag]

    # Oracle 2: Fermionic annihilation commutes through the projector by shifting the particle number -1
    # h |2> = |1>  ==>  h P^{(2)} = P^{(1)} h
    @test apply_algebraic_rules([c_ann, P2]) == [P1, c_ann]

    # Oracle 3: Incorrect intertwining evaluating to ZeroOp (e.g., trying to create a particle beyond the d4 subspace limit)
    @test apply_algebraic_rules([c_dag, P2]) == [ZeroOp()]
    
    # Oracle 4: Annihilating a state that does not exist
    @test apply_algebraic_rules([c_ann, P1]) == [ZeroOp()]
end
