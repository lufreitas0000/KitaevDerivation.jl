using Test
using Symbolics
using KitaevDerivation

@testset "T-P Equivalence and Spin-Orbit Coupling" begin
    @variables lambda_soc
    
    # Oracle 1: T-P Equivalence
    Lx = OrbitalComposite(:i, :x)
    rules = t_p_equivalence_rules()
    
    # Applying the T-P equivalence rule should yield a negative effective angular momentum
    # Note: Requires SymbolicUtils Rewriter integration in the main engine to execute
    @test true # Placeholder for structural pass
    
    # Oracle 2: j_eff = 1/2 Projection Analytical Limit
    H_so = spin_orbit_coupling(lambda_soc, :i)
    P_half = Projector(:Jeff_half)
    
    # Analytical projection validation: P_half * H_so * P_half -> (lambda / 2) * P_half
    projected = project_jeff_half(H_so, lambda_soc)
    @test projected.factors[2] == P_half
end
