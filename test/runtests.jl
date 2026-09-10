using Test
using KitaevDerivation

@testset "KitaevDerivation.jl Framework Tests" begin
    include("test_algebra.jl")
    include("test_kinetic_hopping.jl")
    include("test_appendix_a.jl")
    include("test_soc.jl")
    include("test_kanamori.jl")
    include("test_schrieffer_wolff.jl")
    include("test_exchange.jl")
end
