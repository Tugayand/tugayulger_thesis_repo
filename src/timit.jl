module Timit

using Main.Chakra
using DataFrames
using CSV
using Glob
push!(LOAD_PATH, ".")

abstract type Id <: Chakra.Id end
abstract type Constituent <: Chakra.Constituent end
abstract type Hierarchy <: Chakra.Hierarchy end

struct PhonemeAttribute <: Chakra.Attribute{:phoneme, String} end
Chakra.__attributes__(::Val{:phoneme}) = PhonemeAttribute()
Chakra.__attributes__(n::Symbol) = Chakra.__attributes__(Val{n}()) 

include("components/Ids.jl")
include("components/Hierarchies.jl")
include("components/Constituents.jl")

dir = @__DIR__
folderpath = joinpath(dir, "..", "data", "output")

__data__ = TIMITHierarchy(folderpath)

function Chakra.geta(::Chakra.Attribute{a,T}, p::Phoneme) where {a, T} 
    label = p.data[:label]
    return convert(T, String(label))  
end

Chakra.pts(x::Phoneme)::Vector{Id} = Id[]

# should return the phonemes in my senthierarchy
Chakra.pts(x::Sentence)::Vector{Id} = phonemeId.(x.sentenceId.value, 0:(nrow(x.sent.phn_hierarchy.data)-1))

Chakra.fnd(x::SentenceId, m::Module) = Sentence(x, m.__data__)
Chakra.fnd(x::WordId, m::Module) = Word(x, m.__data__)
Chakra.fnd(x::PhonemeId, m::Module) = Phoneme(x, m.__data__)

Chakra.fnd(x::PhonemeId, h::TIMITHierarchy) = Phoneme(x, h)
Chakra.fnd(x::SentenceId, h::TIMITHierarchy) = Sentence(x, h)
Chakra.fnd(x::WordId, h::TIMITHierarchy) = Word(x, h)

Chakra.pts(x::PHNHierarchy, m::Module) = Chakra.pts(x)
Chakra.pts(x::SENTHierarchy, m::Module) = Chakra.pts(x)
Chakra.pts(x::WORDHierarchy, m::Module) = Chakra.pts(x)
Chakra.pts(x::Sentence, m::Module) = Chakra.pts(x)

end 