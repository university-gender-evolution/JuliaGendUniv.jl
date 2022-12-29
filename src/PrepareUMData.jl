
FILEPATH_UM_DEPTINDEX = "../data/umdepts.csv" 


function _load_univ_data(file_path::String, config::AbstractGendUnivDataConfiguration)
    dstructure = _setup_data(file_path, config)
    return dstructure
end;


function _setup_data(file_path::String, ::UM)
    df = DataFrame(StatFiles.load(file_path))
    disallowmissing!(df, error=false)
    d = UMData(file_path, df)
    df_depts = DataFrame(CSV.File(FILEPATH_UM_DEPTINDEX))
    d._all_department_names = df_depts
    return d
end;


function _get_departments_with_target_start_year!(univdata::GendUnivData, ::UM)
    outdf = subset(univdata._raw_df, :year => ByRow(==(univdata.first_year)))
    univdata.department_names = unique(outdf.orgname)
    univdata.processed_df = @rsubset(univdata._raw_df, :orgname ∈ univdata.department_names)
end;


function _get_departments_with_professors!(univdata::GendUnivData, ::UM)
    univdata.processed_df = filter(:jobdes => contains("PROF"), univdata.processed_df)
    univdata.department_names = unique(univdata.processed_df.orgname)
end;


function _get_departments_with_sufficient_years!(univdata::GendUnivData, ::UM)
    outdf = unique(univdata.processed_df, [:orgname, :year])
    gdf = groupby(outdf, [:orgname])
    cdf = combine(gdf, nrow )
    res = filter(:nrow => >=(univdata.num_years), cdf)
    univdata.processed_df = subset(univdata.processed_df, :orgname => x -> x .∈ [res.orgname])
    univdata.department_names = res.orgname
end;
function preprocess_data(file_path::String, 
                        first_year::Integer, 
                        num_years::Integer, 
                        config::AbstractGendUnivDataConfiguration; 
                        audit_config::AbstractDataChecks=NoAudit())

    univ_data = _load_univ_data(file_path, config)
    univ_data.first_year = first_year
    univ_data.num_years = num_years
    _get_departments_with_target_start_year!(univ_data, config)
    _get_departments_with_professors!(univ_data, config)
    _get_departments_with_sufficient_years!(univ_data, config) 
    # _process_each_dept!(univ_data, config, audit_config)
    # _postprocess_data_arrays!(univ_data, config)
    return univ_data
end;
