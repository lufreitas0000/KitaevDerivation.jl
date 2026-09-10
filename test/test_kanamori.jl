using Test
using Symbolics
using KitaevDerivation

@testset "d4 Multiplet Eigenvalues" begin
    @variables U J_H
    
    # Oracle 1: Exact Analytical Energies
    eigenvalues = kanamori_eigenvalues(U, J_H)
    
    P_L0 = Projector(:L0)
    P_L1 = Projector(:L1)
    P_L2 = Projector(:L2)
    
    @test isequal(eigenvalues[P_L0], U + 2*J_H)
    @test isequal(eigenvalues[P_L1], U - 3*J_H)
    @test isequal(eigenvalues[P_L2], U - J_H)
    
    # Oracle 2: Subspace Routing
    P_singlet, P_triplet = d4_multiplet_projectors()
    @test P_singlet.channel == :Singlet
    @test P_triplet.channel == :Triplet
end
