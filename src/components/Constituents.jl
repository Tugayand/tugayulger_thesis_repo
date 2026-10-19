struct Phoneme <: Constituent
    phonemeId::PhonemeId
    data::DataFrameRow
    #
    Phoneme(phonemeId::PhonemeId, dataset::TIMITHierarchy) = begin 
        sent = dataset.sentences[phonemeId.sentence]
        return new(phonemeId, sent.phn_hierarchy.data[phonemeId.index + 1, :])
    end
end

struct Word <: Constituent
    wordId::WordId
    row::DataFrameRow
    phoneme_indices::Vector{Int}

    Word(wordId::WordId, dataset::TIMITHierarchy) = begin
        sentence_id = wordId.sentence
        sent = dataset.sentences[sentence_id]
        wh = sent.word_hierarchy
        row = wh.data[wordId.index, :]
        pds = findall(x -> x === wordId.index, wh.phn_to_wrd)
        return new(wordId, row, pds)
    end
end

struct Sentence <: Constituent
    sentenceId::SentenceId
    sent::SENTHierarchy

    Sentence(sentenceId::SentenceId, dataset::TIMITHierarchy) = begin
        return new(sentenceId, dataset.sentences[sentenceId.value])
    end 
end