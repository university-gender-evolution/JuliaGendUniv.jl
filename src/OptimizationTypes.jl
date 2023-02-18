using DataFrames



abstract type AbstractGendUnivModel end;
abstract type AbstractModelOptSettings end;


mutable struct 
    raw_df::DataFrame
    processed_data::DataFrame
    first_year::Integer
    num_years::Integer