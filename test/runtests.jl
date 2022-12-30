using JuliaGendUniv
using Test

@show pwd()

# Setup test fixtures
t_preprocess_um_noaudit  = preprocess_data("michigan1979to2009_wGender.dta", 
    1979, 30, UM(); audit_config=NoAudit());

t_preprocess_um_audit = preprocess_data("michigan1979to2009_wGender.dta", 
    1979, 30, UM(); audit_config=DataAudit());

# t_preprocess_um_deptid = get_dept_summary(deptid)

# // TODO setup optimization subpackage  
# t_optimize_um_params = optimize_parameters(preprocessed_data, model, optimizer_settings; audit_config)

# // TODO setup control subpackage 
# simulate_model_shocks(preprocessed_data, model, shocks, controls, settings)
# optimize_parameters(preprocessed_data, model, shocks, controls, settings)



@testset "JuliaGendUniv environment setup" begin
    @test isfile("michigan1979to2009_wGender.dta")
    @test UM() isa JuliaGendUniv.AbstractGendUnivDataConfiguration 
    @test DataAudit() isa JuliaGendUniv.AbstractDataChecks
    @test NoAudit() isa JuliaGendUniv.AbstractDataChecks
end

@testset "[JuliaGendUniv] prepare UM data" begin
    @test t_preprocess_um_noaudit isa JuliaGendUniv.UMData
    @test t_preprocess_um_audit isa JuliaGendUniv.UMData
    @test t_preprocess_um_noaudit.num_years == 30
    @test size(t_preprocess_um_audit._valid_dept_summary) == (525, 5)
    # @test t_preprocess_um_deptid.dept_name == "NOT YET IMPLEMENTED"
end

@testset "[JuliaGendUniv] optimization module" begin
    @test 1 + 1 == 2

end

