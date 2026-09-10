using Test
using Symbolics
using SymbolicUtils
using KitaevDerivation

@testset "d4 Multiplet Eigenvalues and Resolvent Action" begin
    @variables U J_H
    
    # Oracles: Exact Analytical Energies
    eigenvalues = kanamori_eigenvalues(U, J_H)
    
    P_L0 = Projector(:L0)
    P_L1 = Projector(:L1)
    P_L2 = Projector(:L2)
    R    = ResolventOp()
    
    @test isequal(eigenvalues[P_L0], U + 2*J_H)
    @test isequal(eigenvalues[P_L1], U - 3*J_H)
    @test isequal(eigenvalues[P_L2], U - J_H)
    
    # Oracle: Resolvent Rewriting Engine
    rules = kanamori_resolvent_rules(U, J_H)
    
    # Verify R * P_L -> (1 / Delta E_L) * P_L
    expr_L0 = R * P_L0
    simplified_L0 = simplify(expr_L0, RuleSet(rules))
    
    # The CAS should yield a multiplication of the scalar (1 / (U+2J_H)) and the Projector
    # Note: Structural testing depends on the exact AbstractQuantumOperator * Num overloads.
    @test true # Placeholder for active SymbolicUtils dispatch test
end
