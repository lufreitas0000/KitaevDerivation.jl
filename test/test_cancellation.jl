# test/test_cancellation.jl
# [PHYSICAL_ORACLE] Jackeli-Khaliullin Cancellation Oracle
#
# Declared Provenance:
#   Jackeli & Khaliullin, Phys. Rev. Lett. 102, 017205 (2009), Section III.
#   formal_derivation.tex, §Effective Hamiltonian (eqs. for H_{L=0,1,2}).
#
# At J_H = 0:
#   Delta E_0 = Delta E_1 = Delta E_2 = U  (all multiplet energies degenerate)
#   => Kanamori resolvent denominators are all equal => sum cancels.
#   => J = 0, K = 0 exactly.
#
# This is independent of lambda_SOC (strong-SOC limit assumed throughout).
#
# Category: PHYSICAL_ORACLE, LIMIT

using Test
using Symbolics
using KitaevDerivation

@testset "[PHYSICAL_ORACLE] Jackeli-Khaliullin Cancellation: J_H=0 => J=K=0" begin
    @variables U::Real J_H::Real t::Real t_prime::Real

    # Build hopping operators for a z-bond (t'=0 case: pure nearest-neighbor)
    # T_{-1} is the reverse hop, so j -> i (meaning hole moves from i to j).
    T1  = build_T1_operator(:z, t, t_prime, :i, :j)
    Tm1 = build_Tm1_operator(:z, t, t_prime, :j, :i)

    # Compute the j->i->j intermediate processes, multiply by 2 to account for identical i->j->i process.
    H_eff_raw = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    H_eff_terms = [t isa ScaledOperator ? ScaledOperator(2 * t.scalar, t.op) : ScaledOperator(2, t) for t in H_eff_raw.terms]
    H_eff = OperatorSum(H_eff_terms)

    # Project to the j_eff=1/2 pseudospin basis
    H_pseudo = project_to_pseudospin(H_eff; site_i=:i, site_j=:j, bond=:z)

    # Extract exchange tensors
    tensors = extract_exchange_tensors(H_pseudo, :z; site_i=:i, site_j=:j)

    # -----------------------------------------------------------------------
    # Oracle 1: At J_H=0, t'=0 => K must vanish exactly
    #
    # Physical reasoning (independent of implementation):
    #   K = J_zz - J_xx  on a z-bond.
    #   At J_H=0: Delta E_L = U for all L => (U-3J_H)^{-1} = (U-J_H)^{-1} = U^{-1}
    #   The Kitaev interaction arises from the difference between the L=1 and L=2
    #   resolvent denominators. When they are equal, K cancels exactly.
    # -----------------------------------------------------------------------
    K_sym = tensors[:K]
    K_at_JH0_tprime0 = Symbolics.substitute(K_sym, Dict(J_H => 0, t_prime => 0))
    K_simplified = Symbolics.simplify(K_at_JH0_tprime0, expand=true)

    @test isequal(K_simplified, 0) ||
          isapprox(Symbolics.value(Symbolics.substitute(K_simplified,
                   Dict(U => 4.0, t => 1.0))), 0.0; atol=1e-10)

    # -----------------------------------------------------------------------
    # Oracle 2: At J_H=0, t'=0 => J must vanish exactly
    #
    # Physical reasoning:
    #   J = J_xx  on a z-bond (isotropic Heisenberg component).
    #   The L=0 channel projection vanishes onto j_eff=1/2 by symmetry.
    #   The L=1 and L=2 channels contribute with opposite signs to J, and at J_H=0
    #   their combined weight sums to zero.
    # -----------------------------------------------------------------------
    J_sym = tensors[:J]
    J_at_JH0_tprime0 = Symbolics.substitute(J_sym, Dict(J_H => 0, t_prime => 0))
    J_simplified = Symbolics.simplify(J_at_JH0_tprime0, expand=true)

    @test isequal(J_simplified, 0) ||
          isapprox(Symbolics.value(Symbolics.substitute(J_simplified,
                   Dict(U => 4.0, t => 1.0))), 0.0; atol=1e-10)

    # -----------------------------------------------------------------------
    # Oracle 3: Non-zero oracle — K must be non-zero at finite J_H
    #
    # Physical reasoning:
    #   At J_H > 0 the L=1 and L=2 denominators differ, producing net Kitaev exchange.
    #   If K is identically zero for all J_H, the implementation is a mock.
    #   Using RuCl3-like parameters: U=4.0, J_H=0.6, t=1.0, t'=0
    # -----------------------------------------------------------------------
    K_finite = Symbolics.substitute(K_sym,
                   Dict(J_H => 0.6, U => 4.0, t => 1.0, t_prime => 0.0))
    K_val = Symbolics.value(K_finite)

    @test abs(real(K_val)) > 1e-6
end

@testset "[PHYSICAL_ORACLE] Denominator Structure at J_H=0" begin
    # Independent check: verify that the Kanamori energy denominators
    # become degenerate at J_H=0, which is the mathematical cause of cancellation.
    # Provenance: formal_derivation.tex eq. (Delta E_0, Delta E_1, Delta E_2)
    @variables U::Real J_H::Real

    var"P_[L=0]" = MultipletProjector("P_[L=0]", :i)
    var"P_[L=1]" = MultipletProjector("P_[L=1]", :i)
    var"P_[L=2]" = MultipletProjector("P_[L=2]", :i)
    eigenvalues = kanamori_eigenvalues(U, J_H, :i)

    E0 = eigenvalues[var"P_[L=0]"]
    E1 = eigenvalues[var"P_[L=1]"]
    E2 = eigenvalues[var"P_[L=2]"]

    # At J_H=0: all three energies become U
    @test isequal(Symbolics.substitute(E0, Dict(J_H => 0)), U)
    @test isequal(Symbolics.substitute(E1, Dict(J_H => 0)), U)
    @test isequal(Symbolics.substitute(E2, Dict(J_H => 0)), U)

    # The K-channel denominator structure: (U-3J_H) vs (U-J_H)
    # At J_H=0: 1/(U-3J_H) - 1/(U-J_H) = 1/U - 1/U = 0
    diff_resolvent = Symbolics.simplify(1/(E1) - 1/(E2), expand=true)
    diff_at_JH0 = Symbolics.substitute(diff_resolvent, Dict(J_H => 0))
    @test isequal(Symbolics.simplify(diff_at_JH0), 0)
end

@testset "[LIMIT] Hund's Coupling J_H=0 Kanamori Eigenvalue Degeneracy" begin
    # This is the underlying algebraic reason for the Jackeli-Khaliullin cancellation.
    # When J_H=0, all three multiplet sectors have the same excitation energy U,
    # so the Schrieffer-Wolff resolvent is proportional to the identity on the d4 space.
    # A uniform resolvent cannot generate anisotropic exchange.
    # Provenance: Kanamori (1963), Georges et al. Rev. Condens. Matter (2013)
    @variables U::Real J_H::Real

    eigenvalues = kanamori_eigenvalues(U, J_H, :i)
    var"P_[L=0]" = MultipletProjector("P_[L=0]", :i)
    var"P_[L=1]" = MultipletProjector("P_[L=1]", :i)
    var"P_[L=2]" = MultipletProjector("P_[L=2]", :i)

    for P in [var"P_[L=0]", var"P_[L=1]", var"P_[L=2]"]
        E_at_0 = Symbolics.substitute(eigenvalues[P], Dict(J_H => 0))
        @test isequal(E_at_0, U)
    end

    # Energy splittings are proportional to J_H (first order)
    # Delta E_0 - Delta E_1 = 5*J_H
    # Delta E_2 - Delta E_1 = 2*J_H
    diff_01 = Symbolics.simplify(eigenvalues[var"P_[L=0]"] - eigenvalues[var"P_[L=1]"])
    diff_21 = Symbolics.simplify(eigenvalues[var"P_[L=2]"] - eigenvalues[var"P_[L=1]"])
    @test isequal(diff_01, 5*J_H)
    @test isequal(diff_21, 2*J_H)
end
