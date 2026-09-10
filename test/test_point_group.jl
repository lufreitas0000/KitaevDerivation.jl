using Test
using Symbolics
using LinearAlgebra
using KitaevDerivation

@testset "Point-Group Symmetries (C3 Rotation Oracles)" begin
    @variables t t_prime
    
    # Generate the kinetic hopping matrices
    Tx = directional_hopping_matrix(:x, t, t_prime)
    Ty = directional_hopping_matrix(:y, t, t_prime)
    Tz = directional_hopping_matrix(:z, t, t_prime)

    # Define the C3 unitary rotation matrix
    # Permutes orbitals cyclically: x -> y, y -> z, z -> x
    R_C3 = Num[0 0 1; 
               1 0 0; 
               0 1 0]

    # Asserting the rotation symmetrically maps the hopping matrices
    # R^\dagger T_z R = T_x
    @test isequal(transpose(R_C3) * Tz * R_C3, Tx)
    
    # R^\dagger T_x R = T_y
    @test isequal(transpose(R_C3) * Tx * R_C3, Ty)
    
    # R^\dagger T_y R = T_z
    @test isequal(transpose(R_C3) * Ty * R_C3, Tz)
end
