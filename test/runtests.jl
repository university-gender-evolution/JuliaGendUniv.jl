using JuliaGendUniv
using Test

# pwd() = "/home/runner/work/JuliaGendUniv.jl/JuliaGendUniv.jl/test"
@show pwd()
#urldownload("https://github.com/university-gender-evolution/JuliaGendUniv.jl/releases/download/0.1.0/michigan1979to2009_wGender.dta")

@testset "JuliaGendUniv.jl" begin
    # Write your tests here.
    @test 1 + 1 == 2
end
