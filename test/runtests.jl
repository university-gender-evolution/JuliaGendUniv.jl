using JuliaGendUniv
using Test


@testset "JuliaGendUniv.jl" begin
    # Write your tests here.
    @test 1 + 1 == 2
    @test isFile("michigan1979to2009_wGender.dta")
end
