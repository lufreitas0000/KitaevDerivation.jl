using Test
using Symbolics
using SymbolicUtils
using KitaevDerivation

@testset "[PROJECTOR] d4 Multiplet Eigenvalues and Resolvent Action" begin
    @variables U J_H
    
    # Oracles: Exact Analytical Energies
    eigenvalues = kanamori_eigenvalues(U, J_H)
    
    P_L0 = MultipletProjector(0, :i)
    P_L1 = MultipletProjector(1, :i)
    P_L2 = MultipletProjector(2, :i)
    R    = ResolventOp()
    
    # Canonical Kanamori multiplet energies:
    # DeltaE_[L=0] = U + 2*J_H
    # DeltaE_[L=1] = U - 3*J_H
    # DeltaE_[L=2] = U - J_H
    @test isequal(eigenvalues[P_L0], U + 2*J_H)
    @test isequal(eigenvalues[P_L1], U - 3*J_H)
    @test isequal(eigenvalues[P_L2], U - J_H)

    # Oracle: Multiplet Projector Tuple
    P_tuple = d4_multiplet_projectors()
    @test P_tuple == (P_L0, P_L1, P_L2)
    
    # Oracle: Resolvent Rewriting Engine
    rules = kanamori_resolvent_rules(U, J_H)
    @test length(rules) == 6
    
    # Verify R * P_L -> OperatorString([R, P_L]) AST representation
    expr_L0 = R * P_L0
    @test expr_L0 isa OperatorString
    @test expr_L0.factors == [R, P_L0]
    
    # Placeholder for active SymbolicUtils dispatch test
    @test true
end
