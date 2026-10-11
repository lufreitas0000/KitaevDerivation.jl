using Test
using Symbolics
using KitaevDerivation

@testset "Physical Limit Oracles (Jackeli-Khaliullin)" begin
    @variables J_H lambda_soc t U t_prime
    
    # Construct T_1 and T_{-1} for a Z-bond
    T1 = build_T1_operator(:z, t, t_prime, :i, :j)
    Tm1 = build_Tm1_operator(:z, t, t_prime, :j, :i)
    
    # Compute effective Hamiltonian
    H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    
    # Project to pseudospin 1/2 subspace
    H_pseudo = project_to_pseudospin(H_eff; site_i=:i, site_j=:j, bond=:z)
    
    # Extract tensors
    tensors = extract_exchange_tensors(H_pseudo, :z; site_i=:i, site_j=:j)
    
    # Oracle 1: Non-Zero Oracle for finite J_H
    # For a realistic model (J_H > 0), the Kitaev interaction must be non-zero.
    K_finite = Symbolics.substitute(tensors[:K], Dict(J_H => 1.0, U => 10.0, t => 1.0, t_prime => 0.0))
    @test abs(Symbolics.value(K_finite)) > 1e-6
    
    # In the JK limit, isotropic Heisenberg and off-diagonal exchange vanishes.
    # Note: t_prime must be explicitly substituted to 0 since it induces isotropic exchange.
    J_xx_val = Symbolics.substitute(tensors[:J_xx], Dict(t_prime => 0.0))
    @test isequal(Symbolics.simplify(J_xx_val), 0.0)
    J_yy_val = Symbolics.substitute(tensors[:J_yy], Dict(t_prime => 0.0))
    @test isequal(Symbolics.simplify(J_yy_val), 0.0)
    Gamma_val = Symbolics.substitute(tensors[:Gamma], Dict(t_prime => 0.0))
    @test isequal(Symbolics.simplify(Gamma_val), 0.0)
end
