module Phoneme

using Main.Chakra
using DataFrames
push!(LOAD_PATH, ".")
using CSV

abstract type Id <: Chakra.Id end
abstract type Constituent <: Chakra.Constituent end
abstract type Hierarchy <: Chakra.Hierarchy end

include("components/Ids.jl")
include("components/Hierarchies.jl")
include("components/Constituents.jl")

dir = @__DIR__
filename = "data/output/SA1_PHN.csv"
filepath = joinpath(dir, "..", filename)

__data__ = PHNHierarchy(filepath)

Chakra.fnd(x::PhonemeId, m::Module) = begin
    Phoneme(x, m.__data__)
    #Base.get(m.__data__.data.id,x,none)
end

Chakra.pts(x::Phoneme)::Vector{Id} = Id[]  
Chakra.pts(x::PHNHierarchy)::Vector{Id} = phonemeId.(x.data.id)

end 