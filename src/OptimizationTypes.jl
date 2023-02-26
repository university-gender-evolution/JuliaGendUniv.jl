using DataFrames



abstract type AbstractGendUnivModel end;
abstract type AbstractModelOptSettings end;


mutable struct GendUnivOdeModel <: AbstractGendUnivModel
    processed_data::UMDeptData
    boot_spline_data::DataFrame
    first_year::Integer
    num_years::Integer
    timespan::Tuple{Integer, Integer}
    initial_values::DataFrame # change this. 
    params::DataFrame # change this
end;

function GendUnivOdeModel(dept::UMDeptData, 
                            modelfunc::Function, 
                            first_year, 
                            num_years,
                            initial_values,
                            params)



end;