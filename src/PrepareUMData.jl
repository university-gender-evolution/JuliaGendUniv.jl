


function _load_univ_data(file_path::String, config::AbstractGendUnivDataConfiguration)
    dstructure = _setup_data(file_path, config)
    return dstructure
end;


function _setup_data(file_path::String, ::UM)
    df = DataFrame(StatFiles.load(file_path))
    disallowmissing!(df, error=false)
    d = UMData(file_path, df)
    d._all_department_names = unique(df.orgname)
    return d
end;


function preprocess_data(file_path::String, 
                        first_year::Integer, 
                        num_years::Integer, 
                        config::AbstractGendUnivDataConfiguration; 
                        audit_config::AbstractDataChecks=NoAudit())

    univ_data = _load_univ_data(file_path, config)
    # univ_data.first_year = first_year
    # univ_data.num_years = num_years
    # _get_departments_with_target_start_year!(univ_data, config)
    # _get_departments_with_professors!(univ_data, config)
    # _get_departments_with_sufficient_years!(univ_data, config) 
    # _process_each_dept!(univ_data, config, audit_config)
    # _postprocess_data_arrays!(univ_data, config)
    return univ_data
end;
