using Test
using Symbolics
using KitaevDerivation

@testset "Resolvent Execution Engine and Subspace Pruning" begin
    @variables U::Real J_H::Real t::Real scalar_val::Real

    # Mock T1 term representing a hop that creates a double occupancy
    # -t * P^(2)_i c^dag_i c_j P^(1)_j
    P2_i = ParticleProjector(2, :i)
    c_dag = FermionC(:i, :z, :up)
    c_ann = FermionA(:j, :z, :up)
    P1_j = ParticleProjector(1, :j)
    
    t1_term = ScaledOperator(-t, OperatorString([P2_i, c_dag, c_ann, P1_j]))
    T1 = OperatorSum([t1_term])

    # Oracle 1: Denominator Injection
    # The resolvent must split the P^(2) into 3 channels and inject -1 / \Delta E_L
    R_T1 = apply_resolvent(T1, U, J_H)
    @test length(R_T1.terms) == 3
    
    # Check the L=1 channel energy denominator injection
    # \Delta E_1 = U - 3J_H -> scalar should be (-t) * (-1 / (U - 3J_H)) = t / (U - 3J_H)
    term_L1 = R_T1.terms[2] # Assuming ordered 0, 1, 2
    @test isequal(term_L1.scalar, (-t) * (-1 / (U - 3*J_H)))
    @test term_L1.op.factors[1] == MultipletProjector("P_[L=1]", :i)

    # Oracle 2: Orthogonal Pruning
    # Create a mock T_{-1} that strictly filters for the L=0 channel
    # If it meets the L=1 or L=2 channels from R_T1, the product must vanish algebraically.
    P_L0 = MultipletProjector("P_[L=0]", :i)
    tm1_term = ScaledOperator(-t, OperatorString([P1_j, dagger(c_ann), dagger(c_dag), P_L0]))
    Tm1 = OperatorSum([tm1_term])

    H_eff = compute_effective_hamiltonian(Tm1, T1, U, J_H)
    
    # Out of the 3 channels in R_T1, they all survive algebraically in the operator string
    @test length(H_eff.terms) == 3
    
    # We find the term corresponding to L=0 (which has the denominator U + 2J_H)
    l0_terms = filter(term -> isequal(Symbolics.simplify(term.scalar), Symbolics.simplify(-t^2 / (U + 2*J_H))), H_eff.terms)
    @test length(l0_terms) == 1
    
    surviving_term = l0_terms[1]
    # Scalar should be (-t) * (-t) * (-1 / (U + 2J_H)) = -t^2 / (U + 2J_H)
    @test isequal(Symbolics.simplify(surviving_term.scalar), Symbolics.simplify((-t) * (-t) * (-1 / (U + 2*J_H))))
end
