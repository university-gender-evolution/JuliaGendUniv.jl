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


@testitem "[JuliaGendUniv] preprocess UM data No Audit" begin
    
    using JuliaGendUniv, Test
    
    cd(@__DIR__)
    @show pwd()

    t_preprocess_um_noaudit = preprocess_data("michigan1979to2009_wGender.dta", 
                                1979, 30, UM(); audit_config=NoAudit());
    
    t_preprocess_um_deptname = preprocess_data("michigan1979to2009_wGender.dta", 
                                "PEDIATRIC SURGERY SECTION", UM(); audit_config=NoAudit());

    t_preprocess_um_deptindex = preprocess_data("michigan1979to2009_wGender.dta", 
                                165, UM(); audit_config=NoAudit());

    t_preprocess_um_deptname_year = preprocess_data("michigan1979to2009_wGender.dta",
                                    "PEDIATRIC SURGERY SECTION", 1985, 20, UM(); 
                                    audit_config=NoAudit());

    t_preprocess_um_deptindex_year = preprocess_data("michigan1979to2009_wGender.dta", 
                                165, 1985, 20, UM(); audit_config=NoAudit());

    @test t_preprocess_um_noaudit isa JuliaGendUniv.UMData
    @test t_preprocess_um_noaudit.num_years == 30
    @test size(t_preprocess_um_noaudit._valid_dept_summary) == (525, 5)
    @test length(t_preprocess_um_noaudit.department_names) == 73
    @test t_preprocess_um_deptname.department_names[1] == "PEDIATRIC SURGERY SECTION"
    @test t_preprocess_um_deptindex.department_names[1] == "PEDIATRIC SURGERY SECTION"
    @test size(t_preprocess_um_deptname_year.processed_df) == (21, 36)
    @test minimum(t_preprocess_um_deptindex_year.processed_df.year) == t_preprocess_um_deptindex_year.first_year
    @test_throws DomainError preprocess_data("michigan1979to2009_wGender.dta", 165, 1985, 50, UM(); audit_config=NoAudit())
end


@testitem "[JuliaGendUniv] preprocess training/test split" begin
    
    using JuliaGendUniv, Test
    
    cd(@__DIR__)
    @show pwd()

    univ_data_train, univ_data_test = preprocess_dept_train_test_split("michigan1979to2009_wGender.dta",
                                    "PEDIATRIC SURGERY SECTION", 1979, 10, 10, UM(); 
                                    audit_config=NoAudit());

    @test univ_data_train.num_years == 10
    @test univ_data_test.num_years == 10
    @test size(univ_data_train._valid_dept_summary) == (525, 5)
    @test size(univ_data_test._valid_dept_summary) == (525, 5)
end

@testitem "[JuliaGendUniv] prepare UM data with Audit" begin
    using JuliaGendUniv, Test

    cd(@__DIR__)
    @show pwd()

    # t_preprocess_um_audit = preprocess_data("michigan1979to2009_wGender.dta", 
    #     1979, 30, UM(); audit_config=DataAudit());
    
    @test get_department_data("michigan1979to2009_wGender.dta", 
                                "PEDIATRIC SURGERY SECTION", UM())[2] == 165 
    @test 1 + 1 == 2

end


@testitem "[JuliaGendUniv] optimization module" begin
    using JuliaGendUniv, Test

    @test 1 + 1 == 2

end

