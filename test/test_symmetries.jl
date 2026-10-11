# test/test_symmetries.jl
# [SYMMETRY] Point-Group Symmetry Oracles for the z-Bond Exchange Tensor
#
# Declared Provenance:
#   Jackeli & Khaliullin, PRL 102, 017205 (2009), Section II & III.
#   formal_derivation.tex §Effective Hamiltonian.
#   AGENTS.md §5 Point-group symmetry.
#
# For the z-bond with symmetric nearest-neighbor hopping (t'=0),
# the C2 rotation about the z-axis exchanges x <-> y.
# Under C2: sigma^x <-> sigma^y, sigma^z -> sigma^z
# The exchange Hamiltonian must be invariant, which forces:
#     J_xx = J_yy  (both equal the isotropic Heisenberg coefficient J)
#     J_zz = J_xx + K  (Kitaev interaction only along the bond axis)
#
# For t'=0 (no direct hopping), the isotropic Heisenberg term vanishes:
#     J_xx = J_yy = 0
#     K = J_zz - J_xx = J_zz
#
# Category: SYMMETRY, PHYSICAL_ORACLE

using Test
using Symbolics
using KitaevDerivation

@testset "[SYMMETRY] C2 Point-Group: J_xx = J_yy on z-bond (t'=0)" begin
    # Declared Provenance:
    # For the z-bond, the hopping matrix (formal_derivation.tex eq. for T_z) is:
    #     T_z = t * [[0,1,0],[1,0,0],[0,0,0]]
    # This is symmetric under exchange of x <-> y orbitals (orbital permutation),
    # which corresponds to the C2 rotation about the z axis in the cubic setting.
    # Hence the resulting exchange tensor must satisfy J_xx = J_yy.
    #
    # At t'=0, J_xx = J_yy = 0 (L=0 channel cancels on j_eff=1/2, remaining is Kitaev only).
    @variables U::Real J_H::Real t::Real t_prime::Real

    T1  = build_T1_operator(:z, t, t_prime, :i, :j)
    Tm1 = build_Tm1_operator(:z, t, t_prime, :j, :i)
    H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    H_pseudo = project_to_pseudospin(H_eff; site_i=:i, site_j=:j, bond=:z)
    tensors = extract_exchange_tensors(H_pseudo, :z; site_i=:i, site_j=:j)

    J_xx = tensors[:J_xx]
    J_yy = tensors[:J_yy]
    J_zz = tensors[:J_zz]

    # -----------------------------------------------------------------------
    # Invariant 1: J_xx = J_yy  (C2 symmetry constraint)
    # The difference must vanish identically as a symbolic expression.
    # This is an algebraic identity, not a numerical check.
    # -----------------------------------------------------------------------
    diff_xy = Symbolics.simplify(J_xx - J_yy, expand=true)
    @test isequal(diff_xy, 0)

    # -----------------------------------------------------------------------
    # Invariant 2: At t'=0, isotropic Heisenberg exchange vanishes
    # J = J_xx|_{t'=0} = 0
    # Physical reasoning: with only orbital-selective hopping (T_z mixes only xy channels),
    # the L=0 singlet channel contribution cancels after j_eff=1/2 projection (see tex eq.),
    # and the remaining contributions from L=1, L=2 produce only Kitaev (bond-selective) term.
    # -----------------------------------------------------------------------
    J_xx_tprime0 = Symbolics.substitute(J_xx, Dict(t_prime => 0))
    J_xx_simplified = Symbolics.simplify(J_xx_tprime0, expand=true)

    J_yy_tprime0 = Symbolics.substitute(J_yy, Dict(t_prime => 0))
    J_yy_simplified = Symbolics.simplify(J_yy_tprime0, expand=true)

    @test isequal(J_xx_simplified, 0)
    @test isequal(J_yy_simplified, 0)

    # -----------------------------------------------------------------------
    # Invariant 3: K = J_zz - J_xx is the Kitaev coupling definition
    # Verify the relation holds symbolically.
    # -----------------------------------------------------------------------
    K_defined = tensors[:K]
    K_from_diagonal = Symbolics.simplify(J_zz - J_xx, expand=true)
    diff_K = Symbolics.simplify(K_defined - K_from_diagonal, expand=true)
    @test isequal(diff_K, 0)
end

@testset "[SYMMETRY] C2 Point-Group: J_xx = J_yy holds at finite t'" begin
    # C2 symmetry must hold for ALL values of t', not just t'=0.
    # The direct hopping t' (diagonal in orbital space) is also C2-symmetric
    # on the z-bond because the diagonal element T_z[3,3] = t' is invariant under
    # x <-> y exchange.
    # Provenance: formal_derivation.tex §Hopping matrices, T_z matrix.
    @variables U::Real J_H::Real t::Real t_prime::Real

    T1  = build_T1_operator(:z, t, t_prime, :i, :j)
    Tm1 = build_Tm1_operator(:z, t, t_prime, :j, :i)
    H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    H_pseudo = project_to_pseudospin(H_eff; site_i=:i, site_j=:j, bond=:z)
    tensors = extract_exchange_tensors(H_pseudo, :z; site_i=:i, site_j=:j)

    J_xx = tensors[:J_xx]
    J_yy = tensors[:J_yy]

    # This must hold symbolically (all t_prime dependence must be symmetric)
    diff_xy = Symbolics.simplify(J_xx - J_yy, expand=true)
    @test isequal(diff_xy, 0)
end

@testset "[SYMMETRY] Gamma term vanishes at t'=0" begin
    # Provenance: Jackeli-Khaliullin PRL (2009), Rau et al. PRL 112, 077204 (2014).
    # For the idealized symmetric nearest-neighbor hopping (t'=0),
    # there is no trigonal distortion. The off-diagonal symmetric exchange Gamma
    # must therefore vanish. Gamma is generated only by the asymmetry between
    # direct hopping (t') and ligand-mediated hopping (t).
    @variables U::Real J_H::Real t::Real t_prime::Real

    T1  = build_T1_operator(:z, t, t_prime, :i, :j)
    Tm1 = build_Tm1_operator(:z, t, t_prime, :j, :i)
    H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    H_pseudo = project_to_pseudospin(H_eff; site_i=:i, site_j=:j, bond=:z)
    tensors = extract_exchange_tensors(H_pseudo, :z; site_i=:i, site_j=:j)

    Gamma_tprime0 = Symbolics.substitute(tensors[:Gamma], Dict(t_prime => 0))
    Gamma_simplified = Symbolics.simplify(Gamma_tprime0, expand=true)

    @test isequal(Gamma_simplified, 0)
end

@testset "[NUMERICAL_CROSSCHECK] Exchange tensor values at RuCl3 parameters" begin
    # Physical parameters for alpha-RuCl3 (approximate):
    #   U ~ 4.0 eV, J_H ~ 0.6 eV, t ~ 0.2 eV, t' = 0
    # Expected from Jackeli-Khaliullin formula (formal_derivation.tex):
    #   K = -8*J_H*t^2 / (3*(U-3*J_H)*(U-J_H))
    #   J = 0  at t'=0
    #
    # Provenance: formal_derivation.tex final K formula (combining L=1 + L=2 channels)
    @variables U::Real J_H::Real t::Real t_prime::Real

    T1  = build_T1_operator(:z, t, t_prime, :i, :j)
    Tm1 = build_Tm1_operator(:z, t, t_prime, :j, :i)
    # The analytical formula includes BOTH i->j->i and j->i->j processes.
    # Our H_eff here only computes the j->i->j process (double occupancy on i).
    # Since they are symmetric on a z-bond with identical sites, we multiply by 2.
    H_eff_raw = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    H_eff_terms = [t isa ScaledOperator ? ScaledOperator(2 * t.scalar, t.op) : ScaledOperator(2, t) for t in H_eff_raw.terms]
    H_eff = OperatorSum(H_eff_terms)
    
    H_pseudo = project_to_pseudospin(H_eff; site_i=:i, site_j=:j, bond=:z)
    tensors = extract_exchange_tensors(H_pseudo, :z; site_i=:i, site_j=:j)

    params = Dict(U => 4.0, J_H => 0.6, t => 0.2, t_prime => 0.0)

    K_num = real(Symbolics.value(Symbolics.substitute(tensors[:K], params)))
    J_num = real(Symbolics.value(Symbolics.substitute(tensors[:J], params)))

    # tensors now correctly returns the physical spin exchange constants.
    U_val = 4.0; JH_val = 0.6; t_val = 0.2
    K_expected = -8 * JH_val * t_val^2 / (3 * (U_val - 3*JH_val) * (U_val - JH_val))

    # Check sign and rough magnitude (within 10% for the crosscheck)
    @test K_num < 0.0
    @test isapprox(K_num, K_expected; rtol=0.1)
    @test isapprox(J_num, 0.0; atol=1e-10)
end
