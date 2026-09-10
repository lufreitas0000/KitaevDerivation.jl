using Test
using KitaevDerivation

@testset "KitaevDerivation.jl Framework Tests" begin
    include("test_algebra.jl")
    include("test_soc.jl")
    include("test_kanamori.jl")
end
