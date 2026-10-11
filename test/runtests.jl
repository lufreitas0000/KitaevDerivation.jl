using Test
using KitaevDerivation

@testset "KitaevDerivation.jl Framework Tests" begin
    include("test_intertwining.jl")
    include("test_point_group.jl")
    include("test_pauli_trace.jl")
    include("test_algebra.jl")
    include("test_kinetic_hopping.jl")
    include("test_appendix_a.jl")
    include("test_soc.jl")
    include("test_kanamori.jl")
    include("test_schrieffer_wolff.jl")
    include("test_exchange.jl")
    include("test_cancellation.jl")    # [PHYSICAL_ORACLE] Jackeli-Khaliullin: J_H=0 => J=K=0
    include("test_symmetries.jl")      # [SYMMETRY] C2 point-group: J_xx=J_yy on z-bond
end
