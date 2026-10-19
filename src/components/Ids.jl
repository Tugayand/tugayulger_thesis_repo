struct PhonemeId <: Id
    sentence::Int
    index::Int
end

struct SentenceId <: Id
    value::Int
end

struct WordId <: Id
    sentence::Int
    index::Int
end

phonemeId(s::Int, i::Int) = PhonemeId(s, i)
sentenceId(i::Int) = SentenceId(i)
wordId(s::Int, i::Int) = WordId(s, i)