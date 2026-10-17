module Sentence

using Main.Chakra
using DataFrames
push!(LOAD_PATH, ".")
using CSV

abstract type Id <: Chakra.Id end
abstract type Constituent <: Chakra.Constituent end
abstract type Hierarchy <: Chakra.Hierarchy end

struct PhonemeAttribute <: Chakra.Attribute{:phoneme,String} end
# define abstract type phoneme as subtype of chakra.attribute (usually singleton type struct - end)
Chakra.__attributes__(::Val{:phoneme}) = PhonemeAttribute()
Chakra.__attributes__(n::Symbol) = Chakra.__attributes__(Val{n}()) 


include("components/Ids.jl")
include("components/Hierarchies.jl")
include("components/Constituents.jl")

dir = @__DIR__
folderpath = joinpath(dir, "..", "data", "output")

__data__ = SENTHierarchy(folderpath)

function Chakra.geta(::Chakra.Attribute{a,T}, p::Phoneme) where {a,T}
    if :label in names(p.data)
        val = p.data[1, :label]
        return string(val)::T
    end
    return none
end

# Ensure Phoneme is considered to have no further particle-ids
# (you already had this but include for clarity)
Chakra.pts(x::Phoneme)::Vector{Id} = Id[]

# type specification (input(abstractin layer) -> output(low level side)) is important, the how is not unified
Chakra.fnd(x::SentenceId, m::Module) = Sentence(x, m.__data__)
Chakra.fnd(x::PhonemeId, m::Module) = Phoneme(x, m.__data__)

Chakra.fnd(x::SentenceId, h::SENTHierarchy) = Sentence(x, h)
Chakra.fnd(x::PhonemeId, h::SENTHierarchy) = Phoneme(x, h)

Chakra.pts(x::Phoneme)::Vector{Id} = Id[]  
Chakra.pts(x::PHNHierarchy)::Vector{Id} = phonemeId.(fill(0, nrow(x.data)), 0:(nrow(x.data)-1))

Chakra.pts(x::Sentence)::Vector{Id} = begin
    sid = x.sentenceId.value
    phon_ids = x.data.phoneme_id
    [phonemeId(sid, Int(i)) for i in phon_ids]
end
Chakra.pts(x::SENTHierarchy)::Vector{Id} = sentenceId.(unique(x.data.sentence_id))

Chakra.pts(x::PHNHierarchy, m::Module) = Chakra.pts(x)    
Chakra.pts(x::SENTHierarchy, m::Module) = Chakra.pts(x)   

# define Chakra.geta(??attribute)
# phoneme repr of chakra attribute (typed)

end