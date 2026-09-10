using Test
using Symbolics
using KitaevDerivation

@testset "Kinetic Hopping and Hermiticity Oracle" begin
    @variables t t_prime

    # Oracle 1: Directional Matrix Integrity (z-bond)
    T_z = directional_hopping_matrix(:z, t, t_prime)
    @test isequal(T_z[1, 2], t) # |x><y|
    @test isequal(T_z[2, 1], t) # |y><x|
    @test isequal(T_z[3, 3], 0) # z-orbital is inactive on ideal z-bond

    # Oracle 2: Particle-Hole Conservation (Hermiticity)
    # T_1(site2 -> site1) creates d4 on site1.
    T1_forward = build_T1_operator(:z, t, t_prime, :site1, :site2)
    
    # 2 non-zero matrix elements * 2 spin states = 4 terms
    @test length(T1_forward.terms) == 4
    
    # Taking the dagger flips creation/annihilation and reverses the string:
    # (P^(2)_1 c^\dagger_1 c_2 P^(1)_2)^\dagger = P^(1)_2 c^\dagger_2 c_1 P^(2)_1
    # This precisely matches the definition of T_{-1} acting from site1 to site2.
    T1_dagger = dagger(T1_forward)
    Tm1_reverse = build_Tm1_operator(:z, t, t_prime, :site2, :site1)
    
    # The CAS must acknowledge absolute structural equivalence.
    @test T1_dagger == Tm1_reverse
end
