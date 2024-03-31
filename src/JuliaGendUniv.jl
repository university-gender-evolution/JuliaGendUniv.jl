module JuliaGendUniv


using DataFrames
using CSV
using FreqTables
using Plots
using StatsPlots
using StatFiles
using Pipe, StatsBase, Chain
using DataFramesMeta
using Clustering
using MultivariateStats
using RCall
using Distances
using Interpolations
using Zygote
using KernelDensity
using PDFmerger
using Dates
using ComponentArrays
using Combinatorics
using Logging, LoggingExtras
using JuliaGendUniv_Types



include("UMPrepareData.jl");
include("ClusterProcessing.jl");
include("UMDepartmentProcessing.jl");
include("ValidateProfJobCodesByDept.jl")


export preprocess_data, preprocess_dept_train_test_split,
        get_department_data






end
