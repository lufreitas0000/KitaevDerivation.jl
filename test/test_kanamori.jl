using Test
using Symbolics
using KitaevDerivation

@testset "d4 Multiplet Eigenvalues" begin
    @syms U J_H
    
    # Oracle 1: Exact Analytical Energies
    eigenvalues = kanamori_eigenvalues(U, J_H)
    
    P_L0 = Projector(:L0)
    P_L1 = Projector(:L1)
    P_L2 = Projector(:L2)
    
    @test eigenvalues[P_L0] == U + 2*J_H
    @test eigenvalues[P_L1] == U - 3*J_H
    @test eigenvalues[P_L2] == U - J_H
    
    # Oracle 2: Orthogonality of Multiplet Projectors
    P_singlet, P_triplet = d4_multiplet_projectors()
    
    # P_singlet corresponds to L=0 and L=2
    # P_triplet corresponds to L=1
    @test isempty(apply_algebraic_rules([P_singlet, P_triplet]))
end
