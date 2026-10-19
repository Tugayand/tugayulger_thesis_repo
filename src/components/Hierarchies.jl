using Glob

struct PHNHierarchy <: Hierarchy
    data::DataFrame

    PHNHierarchy(filepath) = begin
        df = DataFrame(CSV.File(filepath))
        new(df)
    end
end

struct WORDHierarchy <: Hierarchy
    data::DataFrame 
    phn_hierarchy::PHNHierarchy 
    phn_to_wrd::Vector{Union{Int,Missing}}

    function WORDHierarchy(word_path, phn::PHNHierarchy)
        words_df = CSV.File(word_path) |> DataFrame

        word_bounds = [(i, words_df[i, :onset_start], words_df[i, :onset_stop]) for i in 1:nrow(words_df)]

        n_phn = nrow(phn.data)
        phn_to_word = Vector{Union{Int,Missing}}(undef, n_phn)

        for p in 1:n_phn
            phn_start = phn.data[p, :onset_start]  
            phn_stop  = phn.data[p, :onset_stop]
            matched = nothing
            
            for (wordId, word_start, word_stop) in word_bounds
                if word_start <= phn_start <= word_stop || (phn_start >= word_start && phn_stop <= word_stop) 
                    matched = wordId
                    break
                end
            end
           
            if matched === nothing 
                phn_to_word[p] = missing 
            else 
                phn_to_word[p] = matched 
            end 
            
        end

        return new(words_df, phn, phn_to_word)
    end

end

struct SENTHierarchy <: Hierarchy
    data::DataFrame
    word_hierarchy::Union{WORDHierarchy,Nothing}
    phn_hierarchy::PHNHierarchy

    function SENTHierarchy(txt_path, wrd_path, phn_path)
        lines = readlines(txt_path)
        header = strip(lines[1])
        lines = lines[2:end]
        rows = [split(line, ',', limit=3) for line in lines if !isempty(strip(line))]
        col1 = parse.(Int, strip.(getindex.(rows, 1)))
        col2 = parse.(Int, strip.(getindex.(rows, 2)))
        col3 = strip.(getindex.(rows, 3))
        df = DataFrame(onset_start = col1, onset_stop = col2, label = col3)

        phn = PHNHierarchy(phn_path)
        wh = WORDHierarchy(wrd_path, phn)
        
        return new(df, wh, phn)
    end
end

# captures all sentences, creates a SENTHierarchy for each sentence
# this struct can be used to index all sentences and can be use for instance in Idyoms
struct TIMITHierarchy <: Hierarchy
    folder::String
    sentences::Vector{SENTHierarchy}        
    sentence_map::Dict{String,Int}

    function TIMITHierarchy(folderpath)
        phn_files = sort(Glob.glob("$(folderpath)/S*_PHN.csv"))

        sentences = SENTHierarchy[]
        sentence_map = Dict{String,Int}()

        for (i, phn_path) in enumerate(phn_files)
            m = match(r"(\w+)_PHN\.csv$", basename(phn_path))
            id = (m === nothing) ? basename(phn_path) : m.captures[1]
            wrd_path = replace(phn_path, r"_PHN\.csv$" => "_WRD.csv")
            txt_path = replace(phn_path, r"_PHN\.csv$" => "_TXT.csv")

            sent = SENTHierarchy(txt_path, wrd_path, phn_path)
            push!(sentences, sent)
            sentence_map[id] = length(sentences)
        end

        new(folderpath, sentences, sentence_map)
    end

end