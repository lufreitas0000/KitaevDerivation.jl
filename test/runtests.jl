using Test
using KitaevDerivation

@testset "KitaevDerivation TDD Oracles" begin
    include("test_algebra.jl")
    include("test_soc.jl")
    include("test_cancellation.jl")
    include("test_symmetries.jl")
end
