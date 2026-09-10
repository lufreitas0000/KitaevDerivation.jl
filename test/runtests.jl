using Test
using KitaevDerivation

@testset "KitaevDerivation.jl Framework Tests" begin
    include("test_algebra.jl")
    # Future inclusions:
    # include("test_soc.jl")
    # include("test_kanamori.jl")
    # include("test_schrieffer_wolff.jl")
end
