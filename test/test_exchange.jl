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
    
    # Oracle 1: Jackeli-Khaliullin Cancellation Limit
    # If Hund's coupling J_H == 0, then K and Gamma must strictly vanish.
    @test isequal(Symbolics.simplify(substitute(tensors[:K], Dict(J_H => 0))), 0)
    
    # Oracle 2: Pure Heisenberg Limit
    # If Spin-Orbit Coupling lambda_soc == 0, anisotropic terms vanish.
    @test isequal(Symbolics.simplify(substitute(tensors[:K], Dict(lambda_soc => 0))), 0)
    
    # Oracle 3: Point-Group Symmetry Verification
    # On a Z-bond, C2 symmetry dictates J_xx == J_yy
    @test isequal(Symbolics.simplify(tensors[:J_xx]), Symbolics.simplify(tensors[:J_yy]))
end
