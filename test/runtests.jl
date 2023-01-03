using JuliaGendUniv
using Test
using TestItems


@testitem "[JuliaGendUniv] environment setup" begin

    using JuliaGendUniv, Test
    cd(@__DIR__)
    @show pwd()
    
    @test isfile("michigan1979to2009_wGender.dta")
    @test UM() isa JuliaGendUniv.AbstractGendUnivDataConfiguration 
    @test DataAudit() isa JuliaGendUniv.AbstractDataChecks
    @test NoAudit() isa JuliaGendUniv.AbstractDataChecks
end


@testitem "[JuliaGendUniv] prepare UM data No Audit" begin
    
    using JuliaGendUniv, Test
    
    cd(@__DIR__)
    @show pwd()

    t_preprocess_um_noaudit = preprocess_data("michigan1979to2009_wGender.dta", 
                                1979, 30, UM(); audit_config=NoAudit());
    
    t_preprocess_um_deptname = preprocess_data("michigan1979to2009_wGender.dta", 
                                "PEDIATRIC SURGERY SECTION", UM(); audit_config=NoAudit());

    t_preprocess_um_deptindex = preprocess_data("michigan1979to2009_wGender.dta", 
                                165, UM(); audit_config=NoAudit());


    @test t_preprocess_um_noaudit isa JuliaGendUniv.UMData
    @test t_preprocess_um_noaudit.num_years == 30
    @test size(t_preprocess_um_noaudit._valid_dept_summary) == (525, 5)
    @test length(t_preprocess_um_noaudit.department_names) == 73
    @test t_preprocess_um_deptname.department_names[1] == "PEDIATRIC SURGERY SECTION"
    @test t_preprocess_um_deptindex.department_names[1] == "PEDIATRIC SURGERY SECTION"

end


@testitem "[JuliaGendUniv] prepare UM data with Audit" begin
    using JuliaGendUniv, Test

    cd(@__DIR__)
    @show pwd()

    t_preprocess_um_audit = preprocess_data("michigan1979to2009_wGender.dta", 
        1979, 30, UM(); audit_config=DataAudit());
    
    @test 1 + 1 == 2

end


@testitem "[JuliaGendUniv] optimization module" begin
    using JuliaGendUniv, Test

    @test 1 + 1 == 2

end

