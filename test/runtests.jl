using JuliaGendUniv
using Test


@testset "JuliaGendUniv environment setup" begin
    # Write your tests here.
    @test 1 + 1 == 2
    @test isfile("michigan1979to2009_wGender.dta")
end
