abstract type PhonemeSet end
abstract type SentSet end

struct Phoneme <: Constituent
    phonemeId::PhonemeId
    data::DataFrame
    
    Phoneme(phonemeId::PhonemeId, dataset::SENTHierarchy) = begin
        df = filter(row -> (row[:sentence_id] == phonemeId.sentence) && (row[:phoneme_id] == phonemeId.index), dataset.data)
        return isempty(df) ? none : new(phonemeId, df)
    end 
end

struct Sentence <: Constituent
    sentenceId::SentenceId
    data::DataFrame

    Sentence(sentenceId::SentenceId, dataset::SENTHierarchy) = begin
        df = dataset.data
        #println(df)
        df = filter(:sentence_id => o -> o == sentenceId.value, dataset.data)
        return isempty(df) ? none : new(sentenceId, df)
    end
end
