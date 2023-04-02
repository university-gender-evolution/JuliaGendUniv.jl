

function _load_univ_data(file_path::String, config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration)
    dstructure = _setup_data(file_path, config)
    return dstructure
end;


function _setup_data(file_path::String, config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration)

    df = DataFrame(StatFiles.load(file_path))
    disallowmissing!(df, error=false)
    d = UMData(file_path, df)
    _set_department_summaries!(d, config)
    return d
end;


function _set_department_summaries!(univ_data::JuliaGendUniv_Types.GendUnivData, ::UM)

    depts_prof = subset(univ_data._raw_df, :jobdes => ByRow(contains("PROF")))
    dept_prof_unique = unique(depts_prof.orgname)
    newdf = @rsubset(univ_data._raw_df, :orgname ∈ dept_prof_unique)
    df2 = combine(groupby(newdf, [:orgname]), :year => minimum => :first_year,
                                    :year => maximum => :last_year, 
                                    groupindices)

    df2[!, "nyears"] = df2.last_year .- df2.first_year .+ 1

    df2[!, :first_year] = convert.(Int64, df2[!, :first_year])
    df2[!, :last_year] = convert.(Int64, df2[!, :last_year])

    univ_data._valid_dept_summary = df2
end;



function _get_departments!(univdata::JuliaGendUniv_Types.GendUnivData, ::UM)

    # First filter by departments that start in the target year and have 
    # sufficient subsequent years
    df = subset(univdata._valid_dept_summary, 
                    :first_year => ByRow(==(univdata.first_year)), 
                    :nyears => ByRow(>=(univdata.num_years)))

    univdata.processed_df = subset(univdata._raw_df, :orgname => x -> x .∈ [df.orgname])
    univdata.department_names = df.orgname
end;


function _get_departments!(univdata::JuliaGendUniv_Types.GendUnivData, dept_index::Integer, ::UM)
    dept_name =  univdata._valid_dept_summary[(univdata._valid_dept_summary.groupindices .== dept_index), :].orgname
    univdata.processed_df = subset(univdata._raw_df, :orgname => ByRow(==(dept_name[1])))
    univdata.department_names = dept_name
end;

function get_department_data(file_path::String, dept_name::String,
                            config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration)

    univ_data = _load_univ_data(file_path, config)

    if any(occursin.(strip(dept_name), univ_data._valid_dept_summary.orgname))
        dept_data = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.orgname .== dept_name), :]
        dept_index = dept_data.groupindices[1] 
    else
        throw(DomainError(dept_name, "The provided department name does not match any existing record. 
        Please make sure the name is specified exactly."))
    end
    return (dept_data, dept_index)
end;
# function _get_departments_with_target_start_year!(univdata::GendUnivData, ::UM)
#     outdf = subset(univdata._raw_df, :year => ByRow(==(univdata.first_year)))
#     univdata.department_names = unique(outdf.orgname)
#     univdata.processed_df = @rsubset(univdata._raw_df, :orgname ∈ univdata.department_names)
# end;


# function _get_departments_with_professors!(univdata::GendUnivData, ::UM)
#     univdata.processed_df = filter(:jobdes => contains("PROF"), univdata.processed_df)
#     univdata.department_names = unique(univdata.processed_df.orgname)
# end;


# function _get_departments_with_sufficient_years!(univdata::GendUnivData, ::UM)
#     outdf = unique(univdata.processed_df, [:orgname, :year])
#     gdf = groupby(outdf, [:orgname])
#     cdf = combine(gdf, nrow )
#     res = filter(:nrow => >=(univdata.num_years), cdf)
#     univdata.processed_df = subset(univdata.processed_df, :orgname => x -> x .∈ [res.orgname])
#     univdata.department_names = res.orgname
# end;

function _process_each_dept!(univdata::JuliaGendUniv_Types.GendUnivData, ::UM, audit_config)    
    for (index, value) in enumerate(univdata.department_names)
        input = filter(:orgname => contains(value), univdata.processed_df)
        res = preprocess_um_data(input, univdata.first_year, univdata.num_years, audit_config)
        push!(univdata.dept_data_vector, res)
        @show value
        @show nrow(res.processed_data)
    end
end;

function _postprocess_data_arrays!(univdata::JuliaGendUniv_Types.GendUnivData, ::UM)

    t1 = [univdata.dept_data_vector[i].processed_data for i in 1:length(univdata.dept_data_vector)]
    t2 = [univdata.dept_data_vector[i].cluster_vector[1:univdata.num_years*6] for i in 1:length(univdata.dept_data_vector)]
    t3 = [univdata.dept_data_vector[i].sindy_matrix[1:univdata.num_years, :] for i in 1:length(univdata.dept_data_vector)]
    t4 = [univdata.dept_data_vector[i].bootstrap_df[1:univdata.num_years, :] for i in 1:length(univdata.dept_data_vector)]
    univdata.processed_df = reduce(vcat, t1)
    univdata.univ_cluster_matrix = reduce(hcat, t2)
    univdata.univ_sindy_matrix = reduce(hcat, t3)
    univdata.univ_bootstrap_df = reduce(vcat, t4)
end;


function preprocess_data(file_path::String, 
                        first_year::Integer, 
                        num_years::Integer, 
                        config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration; 
                        audit_config::JuliaGendUniv_Types.AbstractDataChecks=NoAudit())

    univ_data = _load_univ_data(file_path, config)
    univ_data.first_year = first_year
    univ_data.num_years = num_years
    _get_departments!(univ_data, config)
    #_get_departments_with_target_start_year!(univ_data, config)
    #_get_departments_with_professors!(univ_data, config)
    #_get_departments_with_sufficient_years!(univ_data, config) 
    _process_each_dept!(univ_data, config, audit_config)
    _postprocess_data_arrays!(univ_data, config)
    return univ_data
end;


function preprocess_data(file_path::String, 
                        dept_name::String, 
                        config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration; 
                        audit_config::JuliaGendUniv_Types.AbstractDataChecks=NoAudit())

    univ_data = _load_univ_data(file_path, config)

    if any(occursin.(strip(dept_name), univ_data._valid_dept_summary.orgname))
        dept_index = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.orgname .== dept_name), :].groupindices[1]
    else
        throw(DomainError(dept_name, "The provided department name does not match any existing record. 
        Please make sure the name is specified exactly."))
    end
    
    univ_data.first_year = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.groupindices .== dept_index), :].first_year[1]
    univ_data.num_years = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.groupindices .== dept_index), :].nyears[1]
    _get_departments!(univ_data, dept_index, config)
    _process_each_dept!(univ_data, config, audit_config)
    _postprocess_data_arrays!(univ_data, config)
    return univ_data
end;


function preprocess_data(file_path::String, 
                        dept_index::Integer, 
                        config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration; 
                        audit_config::JuliaGendUniv_Types.AbstractDataChecks=NoAudit())

    univ_data = _load_univ_data(file_path, config)

    if dept_index ∈ univ_data._valid_dept_summary.groupindices

    else
        throw(DomainError(dept_name, "The provided department index does not match any existing record. 
        Please make sure the index is specified correctly."))
    end

    univ_data.first_year = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.groupindices .== dept_index), :].first_year[1]
    univ_data.num_years = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.groupindices .== dept_index), :].nyears[1]
    _get_departments!(univ_data, dept_index, config)
    _process_each_dept!(univ_data, config, audit_config)
    _postprocess_data_arrays!(univ_data, config)
    return univ_data
end;


function preprocess_data(file_path::String, 
                        dept_name::String,
                        start_year::Integer,
                        num_years::Integer, 
                        config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration; 
                        audit_config::JuliaGendUniv_Types.AbstractDataChecks=NoAudit())


    univ_data = _load_univ_data(file_path, config)

    if any(occursin.(strip(dept_name), univ_data._valid_dept_summary.orgname))
        dept_data = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.orgname .== dept_name), :]
        dept_index = dept_data.groupindices[1] 
    else
        throw(DomainError(dept_name, "The provided department name does not match any existing record. 
        Please make sure the name is specified exactly."))
    end

    if (start_year + num_years) < dept_data.last_year[1] && start_year >= dept_data.first_year[1]

    else
        throw(DomainError(dept_name, "The provided start_year and number of years falls outside of the 
        range of the data. Either the start year falls before the first year of data, or the 
        start year + number of years falls beyond the last year of data."))
    end

    univ_data.first_year = start_year
    univ_data.num_years = num_years
    _get_departments!(univ_data, dept_index, config)
    _process_each_dept!(univ_data, config, audit_config)
    _postprocess_data_arrays!(univ_data, config)
    return univ_data
end;


function preprocess_data(file_path::String, 
                        dept_index::Integer,
                        start_year::Integer,
                        num_years::Integer, 
                        config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration; 
                        audit_config::JuliaGendUniv_Types.AbstractDataChecks=NoAudit())

    univ_data = _load_univ_data(file_path, config)

    if dept_index ∈ univ_data._valid_dept_summary.groupindices
        dept_data = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.groupindices .== dept_index), :]
    else
        throw(DomainError(dept_data.orgname, "The provided department index does not match any existing record. 
        Please make sure the index is specified correctly."))
    end

    if (start_year + num_years) < dept_data.last_year[1] && start_year >= dept_data.first_year[1]

    else
        throw(DomainError(dept_data.orgname, "The provided start_year and number of years falls outside of the 
        range of the data. Either the start year falls before the first year of data, or the 
        start year + number of years falls beyond the last year of data."))
    end

    univ_data.first_year = start_year
    univ_data.num_years = num_years
    _get_departments!(univ_data, dept_index, config)
    _process_each_dept!(univ_data, config, audit_config)
    _postprocess_data_arrays!(univ_data, config)
    return univ_data
end;


function _validation_checks_train_test_split(dept_data::DataFrame,
                                            train_start_year::Integer,
                                            train_nyears::Integer,
                                            test_start_year::Integer,
                                            test_nyears::Integer)
    if train_start_year < test_start_year
        true
    else
        throw(DomainError(dept_data.orgname[1]. "The test start year must 
        come before the train start year."))
    end

    if (train_start_year + train_nyears) < dept_data.last_year[1] && train_start_year >= dept_data.first_year[1]
        true
    else
        throw(DomainError(dept_data.orgname[1], "The provided training start_year and number of years falls outside of the 
        range of the data. Either the start year falls before the first year of data, or the 
        start year + number of training years falls beyond the last year of data."))
    end

    if (test_start_year + test_nyears) < dept_data.last_year[1] && test_start_year >= dept_data.first_year[1]
        true
    else
        throw(DomainError(dept_data.orgname[1], "The provided testing start_year
        and number of years falls outside of the 
        range of the data. Either the start year falls before the first year of 
        data, or the start year + number of testing years falls beyond the last 
        year of data."))
    end
end;

function preprocess_dept_train_test_split(file_path::String, 
                                            dept_name::String,
                                            start_year::Integer,
                                            train_nyears::Integer,
                                            test_nyears::Integer, 
                                            config::JuliaGendUniv_Types.AbstractGendUnivDataConfiguration; 
                                            audit_config::JuliaGendUniv_Types.AbstractDataChecks=NoAudit())


    univ_data = _load_univ_data(file_path, config)

    if any(occursin.(strip(dept_name), univ_data._valid_dept_summary.orgname))
        dept_data = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.orgname .== dept_name), :]
        dept_index = dept_data.groupindices[1] 
    else
        throw(DomainError(dept_name, "The provided department name does not match any existing record. 
        Please make sure the name is specified exactly."))
    end


    train_start_year = start_year
    test_start_year = train_start_year + train_nyears
    test_end_year = test_start_year + test_nyears      

    _validation_checks_train_test_split(dept_data, train_start_year, 
                                        train_nyears, test_start_year, 
                                        test_nyears)

    univ_data_train = preprocess_data(file_path, dept_index, train_start_year,
                        train_nyears, config; audit_config)
    
    univ_data_test = preprocess_data(file_path, dept_index, test_start_year,
                        test_nyears, config; audit_config)

    return (univ_data_train, univ_data_test)
end;