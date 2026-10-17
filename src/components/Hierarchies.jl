using Glob

struct PHNHierarchy <: Hierarchy
    data::DataFrame

    PHNHierarchy(filepath) = begin
        df = DataFrame(CSV.File(filepath))
        #print(filepath)
        #println(df)
        if !("id" in names(df))
            df[!, :id] = collect(1:nrow(df))
        end
        new(df)
    end
end

struct SENTHierarchy <: Hierarchy
    data::DataFrame

    function SENTHierarchy(folderpath)
        sentence_files = glob("$(folderpath)/S*_PHN.csv")
        
        dfs = DataFrame[]
        sentence_ids = Int[]
        phoneme_ids = Int[]

        total_phonemes = 0
        for (n, file_path) in enumerate(sentence_files)
            hierarchy = PHNHierarchy(file_path)
            sub_df = hierarchy.data 
            
            phoneme_amount = nrow(sub_df)
            current_sentence_id = n - 1  

            append!(sentence_ids, fill(current_sentence_id, phoneme_amount))
            append!(phoneme_ids, total_phonemes:(total_phonemes + phoneme_amount - 1))
            
            total_phonemes += phoneme_amount

            push!(dfs, sub_df)
        end

        df = vcat(dfs...)
        
        df[!, :sentence_id] = sentence_ids
        df[!, :phoneme_id] = phoneme_ids

        #println(df)
        new(df)
    end
end