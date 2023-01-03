

function _load_univ_data(file_path::String, config::AbstractGendUnivDataConfiguration)
    dstructure = _setup_data(file_path, config)
    return dstructure
end;


function _setup_data(file_path::String, config::AbstractGendUnivDataConfiguration)

    df = DataFrame(StatFiles.load(file_path))
    disallowmissing!(df, error=false)
    d = UMData(file_path, df)
    _set_department_summaries!(d, config)
    return d
end;


function _set_department_summaries!(univ_data::GendUnivData, ::UM)

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

function _get_departments!(univdata::GendUnivData, ::UM)

    # First filter by departments that start in the target year and have 
    # sufficient subsequent years
    df = subset(univdata._valid_dept_summary, 
                    :first_year => ByRow(==(univdata.first_year)), 
                    :nyears => ByRow(>=(univdata.num_years)))

    univdata.processed_df = subset(univdata._raw_df, :orgname => x -> x .∈ [df.orgname])
    univdata.department_names = df.orgname
end;


function _get_departments!(univdata::GendUnivData, dept_index::Integer, ::UM)
    dept_name =  univdata._valid_dept_summary[(univdata._valid_dept_summary.groupindices .== dept_index), :].orgname
    univdata.processed_df = subset(univdata._raw_df, :orgname => ByRow(==(dept_name[1])))
    univdata.department_names = dept_name
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

function _process_each_dept!(univdata::GendUnivData, ::UM, audit_config)    
    for (index, value) in enumerate(univdata.department_names)
        input = filter(:orgname => contains(value), univdata.processed_df)
        res = preprocess_um_data(input, univdata.first_year, univdata.num_years, audit_config)
        push!(univdata.dept_data_vector, res)
        @show value
        @show nrow(res.processed_data)
    end
end;

function _postprocess_data_arrays!(univdata::GendUnivData, ::UM)

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
                        config::AbstractGendUnivDataConfiguration; 
                        audit_config::AbstractDataChecks=NoAudit())

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
                        config::AbstractGendUnivDataConfiguration; 
                        audit_config::AbstractDataChecks=NoAudit())

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
                        config::AbstractGendUnivDataConfiguration; 
                        audit_config::AbstractDataChecks=NoAudit())

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
                        config::AbstractGendUnivDataConfiguration; 
                        audit_config::AbstractDataChecks=NoAudit())


    univ_data = _load_univ_data(file_path, config)

    if any(occursin.(strip(dept_name), univ_data._valid_dept_summary.orgname))
        dept_index = univ_data._valid_dept_summary[(univ_data._valid_dept_summary.orgname .== dept_name), :].groupindices
    else
        throw(DomainError(dept_name, "The provided department name does not match any existing record. 
        Please make sure the name is specified exactly."))
    end
end;


function preprocess_data(file_path::String, 
                        dept_name::String,
                        start_year::Integer,
                        num_years::Integer, 
                        config::AbstractGendUnivDataConfiguration; 
                        audit_config::AbstractDataChecks=NoAudit())


end;
