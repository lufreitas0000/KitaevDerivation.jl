using Test
using Symbolics
using KitaevDerivation

@testset "Resolvent Execution Engine and Subspace Pruning" begin
    @variables U J_H t scalar_val

    # Mock T1 term representing a hop that creates a double occupancy
    # -t * P^(2)_i c^dag_i c_j P^(1)_j
    P2_i = ParticleProjector(2, :i)
    c_dag = FermionC(:i, :z, :up)
    c_ann = FermionA(:j, :z, :up)
    P1_j = ParticleProjector(1, :j)
    
    t1_term = ScaledOperator(-t, OperatorString([P2_i, c_dag, c_ann, P1_j]))
    T1 = OperatorSum([t1_term])

    # Oracle 1: Denominator Injection
    # The resolvent must split the P^(2) into 3 channels and inject -1 / \\Delta E_L
    R_T1 = apply_resolvent(T1, U, J_H)
    @test length(R_T1.terms) == 3
    
    # Check the L=1 channel energy denominator injection
    # \\Delta E_1 = U - 3J_H -> scalar should be (-t) * (-1 / (U - 3J_H)) = t / (U - 3J_H)
    term_L1 = R_T1.terms[2] # Assuming ordered 0, 1, 2
    @test isequal(term_L1.scalar, (-t) * (-1 / (U - 3*J_H)))
    @test term_L1.op.factors[1] == MultipletProjector(1)

    # Oracle 2: Orthogonal Pruning
    # Create a mock T_{-1} that strictly filters for the L=0 channel
    # If it meets the L=1 or L=2 channels from R_T1, the product must vanish algebraically.
    P_L0 = MultipletProjector(0)
    tm1_term = ScaledOperator(-t, OperatorString([P1_j, dagger(c_ann), dagger(c_dag), P_L0]))
    Tm1 = OperatorSum([tm1_term])

    H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    
    # Out of the 3 channels in R_T1, only the L=0 channel survives P_L0 * P_L = \\delta_{0,L}
    @test length(H_eff.terms) == 1
    
    surviving_term = H_eff.terms[1]
    # Scalar should be (-t) * (-t) * (-1 / (U + 2J_H)) = -t^2 / (U + 2J_H)
    @test isequal(surviving_term.scalar, (-t) * (-t) * (-1 / (U + 2*J_H)))
end
