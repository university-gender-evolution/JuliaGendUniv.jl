



function _process_clusterpoint_vector!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.processed_data.act_normf1, 
                        umdata.processed_data.act_normf2, 
                        umdata.processed_data.act_normf3, 
                        umdata.processed_data.act_normm1, 
                        umdata.processed_data.act_normm2, 
                        umdata.processed_data.act_normm3)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_vector = cluster_pt
end;


function _process_cluster_vector_agg_norm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.processed_data.act_norm_f,
                        umdata.processed_data.act_norm_m)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_agg_norm = cluster_pt
end;


function _process_cluster_vector_agg_ynorm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.processed_data.act_ynorm_f,
                        umdata.processed_data.act_ynorm_m)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_agg_ynorm = cluster_pt
end;


function _process_cluster_vector_detail_norm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.processed_data.act_normf1, 
                        umdata.processed_data.act_normf2, 
                        umdata.processed_data.act_normf3, 
                        umdata.processed_data.act_normm1, 
                        umdata.processed_data.act_normm2, 
                        umdata.processed_data.act_normm3)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_detail_norm = cluster_pt
end;


function _process_cluster_vector_detail_ynorm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.processed_data.act_ynorm_f1, 
                        umdata.processed_data.act_ynorm_f2, 
                        umdata.processed_data.act_ynorm_f3, 
                        umdata.processed_data.act_ynorm_m1, 
                        umdata.processed_data.act_ynorm_m2, 
                        umdata.processed_data.act_ynorm_m3)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_detail_ynorm = cluster_pt
end;



function _process_cluster_vector_spline_agg_norm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.bootstrap_df.spline_norm_f,
                        umdata.bootstrap_df.spline_norm_m)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_spline_agg_norm = cluster_pt
end;



function _process_cluster_vector_spline_agg_ynorm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.bootstrap_df.spline_ynorm_f,
                        umdata.bootstrap_df.spline_ynorm_m)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_spline_agg_ynorm = cluster_pt
end;



function _process_cluster_vector_spline_detail_norm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.bootstrap_df.spline_norm_f1,
                        umdata.bootstrap_df.spline_norm_f2,
                        umdata.bootstrap_df.spline_norm_f3,
                        umdata.bootstrap_df.spline_norm_m1,
                        umdata.bootstrap_df.spline_norm_m2,
                        umdata.bootstrap_df.spline_norm_m3)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_spline_detail_norm = cluster_pt
end;


function _process_cluster_vector_spline_detail_ynorm!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = vcat(umdata.bootstrap_df.spline_ynorm_f1,
                        umdata.bootstrap_df.spline_ynorm_f2,
                        umdata.bootstrap_df.spline_ynorm_f3,
                        umdata.bootstrap_df.spline_ynorm_m1,
                        umdata.bootstrap_df.spline_ynorm_m2,
                        umdata.bootstrap_df.spline_ynorm_m3)
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_spline_detail_ynorm = cluster_pt
end;


function _process_cluster_vector_act_norm_deptn!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = umdata.processed_data.act_norm_deptn
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_act_norm_deptn = cluster_pt
end;


function _process_cluster_vector_spline_norm_deptn!(umdata::UMDeptData)
    # stack data for clustering                         
    cluster_pt = umdata.bootstrap_df.spline_norm_deptn
    cluster_pt .= ifelse.(isnan.(cluster_pt), 0, cluster_pt)
    umdata.cluster_data.cluster_vector_spline_norm_deptn = cluster_pt
end;


function _process_cluster_vectors!(umdata::UMDeptData)
    _process_cluster_vector_agg_norm!(umdata)
    _process_cluster_vector_agg_ynorm!(umdata)
    _process_cluster_vector_detail_norm!(umdata)
    _process_cluster_vector_detail_ynorm!(umdata)
    _process_cluster_vector_spline_agg_norm!(umdata)
    _process_cluster_vector_spline_agg_ynorm!(umdata)
    _process_cluster_vector_spline_detail_norm!(umdata)
    _process_cluster_vector_spline_detail_ynorm!(umdata)
    _process_cluster_vector_act_norm_deptn!(umdata)
    _process_cluster_vector_spline_norm_deptn!(umdata)
end;
    


# t2 = [univdata.dept_data_vector[i].cluster_vector[1:univdata.num_years*6] for i in 1:length(univdata.dept_data_vector)]
#     univdata.univ_cluster_matrix = reduce(hcat, t2)

function aggregate_cluster_vectors_to_matrix(univdata::JuliaGendUniv_Types.GendUnivData)
    d_agg_norm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_agg_norm for i in 1:length(univdata.dept_data_vector)]
    d_agg_ynorm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_agg_ynorm for i in 1:length(univdata.dept_data_vector)]
    d_detail_norm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_detail_norm for i in 1:length(univdata.dept_data_vector)]
    d_detail_ynorm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_detail_ynorm for i in 1:length(univdata.dept_data_vector)]
    d_spline_agg_norm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_spline_agg_norm for i in 1:length(univdata.dept_data_vector)]
    d_spline_agg_ynorm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_spline_agg_ynorm for i in 1:length(univdata.dept_data_vector)]
    d_spline_detail_norm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_spline_detail_norm for i in 1:length(univdata.dept_data_vector)]
    d_spline_detail_ynorm = [univdata.dept_data_vector[i].cluster_data.cluster_vector_spline_detail_ynorm for i in 1:length(univdata.dept_data_vector)]
    d_act_norm_deptn = [univdata.dept_data_vector[i].cluster_data.cluster_vector_act_norm_deptn for i in 1:length(univdata.dept_data_vector)]
    d_spline_norm_deptn = [univdata.dept_data_vector[i].cluster_data.cluster_vector_spline_norm_deptn for i in 1:length(univdata.dept_data_vector)]

    univdata.clustering_data.cluster_matrix_agg_norm = reduce(hcat, d_agg_norm)
    univdata.clustering_data.cluster_matrix_agg_ynorm = reduce(hcat, d_agg_ynorm)
    univdata.clustering_data.cluster_matrix_detail_norm = reduce(hcat, d_detail_norm)
    univdata.clustering_data.cluster_matrix_detail_ynorm = reduce(hcat, d_detail_ynorm)
    univdata.clustering_data.cluster_matrix_spline_agg_norm = reduce(hcat, d_spline_agg_norm)
    univdata.clustering_data.cluster_matrix_spline_agg_ynorm = reduce(hcat, d_spline_agg_ynorm)
    univdata.clustering_data.cluster_matrix_spline_detail_norm = reduce(hcat, d_spline_detail_norm)
    univdata.clustering_data.cluster_matrix_spline_detail_ynorm = reduce(hcat, d_spline_detail_ynorm)
    univdata.clustering_data.cluster_matrix_act_norm_deptn = reduce(hcat, d_act_norm_deptn)
    univdata.clustering_data.cluster_matrix_spline_norm_deptn = reduce(hcat, d_spline_norm_deptn)

end;