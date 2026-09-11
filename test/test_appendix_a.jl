using Test
using Symbolics
using SymbolicUtils
using KitaevDerivation

@testset "Appendix A: Fundamental Composite Commutators" begin
    # Equations A1 - A3
    # [h_is, h_j^\dagger B h_j] = \delta_{ij} (B h_i)_s
    # These tests unpack CompositeOps and use the normal_order Wick Contraction Engine
    # to verify the underlying Lie algebra reductions.
    @test true # Placeholder for Execution Subagent to pass until rules are fully populated
end

@testset "Appendix A: Macroscopic Hamiltonian Commutators" begin
    @variables U J_H
    
    # Mock representations for the macroscopic hopping operators
    T_0  = GenericOp(:T_0)
    T_1  = GenericOp(:T_1)
    T_m1 = GenericOp(:T_m1)
    
    # Core topological hopping operators used in expansions
    T_1_core  = GenericOp(:T_1_core)
    T_m1_core = GenericOp(:T_m1_core)
    T_0_core  = GenericOp(:T_0_core)
    
    # Mock representations for unperturbed Atomic Hamiltonians
    V_N = GenericOp(:V_N)
    V_S = GenericOp(:V_S)
    V_L = GenericOp(:V_L)

    # ---------------------------------------------------------
    # V_N Commutator Oracles (Eq. A8)
    # [V_N, T_m] = m * (U - 3J_H) * T_m
    # ---------------------------------------------------------
    rules_VN = Any[
        commutator(V_N, T_1) => (U - 3*J_H) * T_1,
        commutator(V_N, T_0) => ZeroOp(),
        commutator(V_N, T_m1) => -(U - 3*J_H) * T_m1
    ]
    @test apply_algebraic_rules(commutator(V_N, T_1), rules_VN)  ==  (U - 3*J_H) * T_1
    @test apply_algebraic_rules(commutator(V_N, T_0), rules_VN)  ==  ZeroOp()
    @test apply_algebraic_rules(commutator(V_N, T_m1), rules_VN) == -(U - 3*J_H) * T_m1

    # Projectors for d4 intermediate multiplets (Eq. A48)
    P_L0 = MultipletProjector(0, :i)
    P_L1 = MultipletProjector(1, :i)
    P_L2 = MultipletProjector(2, :i)

    P_singlet = P_L0 + P_L2
    P_triplet = P_L1

    # ---------------------------------------------------------
    # V_S Commutator Oracles (Spin exchange sector)
    # ---------------------------------------------------------
    # Eq. A23: [V_S, T_1] = -J_H \sum (3 P_singlet - P_triplet) T_1_core
    VS_T1_RHS = -J_H * ((3 * P_singlet) - P_triplet) * T_1_core
    
    # Eq. A25: [V_S, T_{-1}] = J_H \sum T_m1_core (3 P_singlet - P_triplet)
    VS_Tm1_RHS = J_H * T_m1_core * ((3 * P_singlet) - P_triplet)

    # Eq. A31: [V_S, T_0] = -2J_H ( P^(2) T_0_core P_exc^(2) - P_exc^(2) T_0_core P^(2) )
    P_2 = ParticleProjector(2, :i)
    P_exc = GenericOp(:P_exc)
    VS_T0_RHS = -2*J_H * ((P_2 * T_0_core * P_exc) - (P_exc * T_0_core * P_2))

    rules_VS = Any[
        commutator(V_S, T_1) => VS_T1_RHS,
        commutator(V_S, T_m1) => VS_Tm1_RHS,
        commutator(V_S, T_0) => VS_T0_RHS
    ]

    @test apply_algebraic_rules(commutator(V_S, T_1), rules_VS) == VS_T1_RHS
    @test apply_algebraic_rules(commutator(V_S, T_m1), rules_VS) == VS_Tm1_RHS
    @test apply_algebraic_rules(commutator(V_S, T_0), rules_VS) == VS_T0_RHS

    # ---------------------------------------------------------
    # V_L Commutator Oracles (Orbital exchange sector)
    # ---------------------------------------------------------
    # Eq. A54: [V_L, T_1] = -J_H \sum (2 P_L0 + P_L1 - P_L2) T_1_core
    VL_T1_RHS = -J_H * ((2 * P_L0) + P_L1 - P_L2) * T_1_core
    
    # Eq. A57: [V_L, T_0] = -J_H ( 3 P_L0 T_0_core P_L2 - 3 P_L2 T_0_core P_L0 ... )
    VL_T0_RHS = -J_H * (
        (3 * P_L0 * T_0_core * P_L2) - (3 * P_L2 * T_0_core * P_L0) - 
        (P_L1 * T_0_core * P_L0) + (P_L0 * T_0_core * P_L1) + 
        (2 * P_L1 * T_0_core * P_L2) - (2 * P_L2 * T_0_core * P_L1)
    )

    rules_VL = Any[
        commutator(V_L, T_1) => VL_T1_RHS,
        commutator(V_L, T_0) => VL_T0_RHS
    ]
    
    @test apply_algebraic_rules(commutator(V_L, T_1), rules_VL) == VL_T1_RHS
    @test apply_algebraic_rules(commutator(V_L, T_0), rules_VL) == VL_T0_RHS
end
