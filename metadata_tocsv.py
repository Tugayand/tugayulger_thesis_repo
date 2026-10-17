import os
import csv
import sys

# Default arguments
base_dir = os.path.dirname(os.path.abspath(__file__))
data_path = os.path.join(base_dir, "data")
output_path = os.path.join(data_path, "output")

def collect_sentence_names(current_folder):
    files = os.listdir(current_folder)
    files = [f for f in files if os.path.isfile(current_folder+'/'+f)]
    sentences = [f.rsplit('.', 1)[0] for f in files]
    sentences = list(set(sentences))
    return sentences

def recurse_over_sentences(speaker_folder):
    convert_metadata_to_csv(speaker_folder, output_path)

def recurse_over_speakers(region_folder):
    speakers = os.listdir(region_folder)
    for speaker in speakers:
        speaker_path = os.path.join(region_folder, speaker)
        recurse_over_sentences(speaker_path)

def recurse_over_regions(current_folder):
    regions = os.listdir(current_folder) 
    for region in regions:
        region_path = os.path.join(current_folder, region)
        recurse_over_speakers(region_path)

def file_to_csv(file_path, output_path):
    with open(file_path, "r") as f:
        lines = f.readlines()
        lines = [line.split() for line in lines]

        filename = os.path.basename(file_path)
        base_name = os.path.splitext(filename)[0]
        extension = filename.split(".")[-1]
        csv_filename = f"{base_name}_{extension}.csv"

        file_output = os.path.join(output_path, csv_filename)

        with open(file_output, "w", newline="") as csvfile:
            header = ["onset_start", "onset_stop", "label"]
            writer = csv.writer(csvfile)
            writer.writerow(header)
            writer.writerows(lines)

def convert_metadata_to_csv(current_folder, output_folder=output_path):
    files = os.listdir(current_folder)
    files = [f for f in files if os.path.isfile(current_folder+'/'+f)]
    for file in files:
        print(file)
        if not file.endswith(".WAV"):
            path = os.path.join(current_folder, file)
            file_to_csv(path, output_folder)

# Main 

# Check for supplied arguments in command line 
if (len(sys.argv[1:]) != 0):
    print("Arguments:", sys.argv[1:])
    print("Data Folder: ", sys.argv[1])
    data_path = sys.argv[1]
    print("Output Folder:", sys.argv[2])
    output_path = sys.argv[2]
else:
    print("No Arguments Supplied, using default options")
    print("Data Folder: ", data_path)
    print("Output Folder:", output_path)

# Prompt user if they want to proceed
prompt_loop = True
while prompt_loop:
    if input('Do You Want To Continue with these options?') != 'y':
        print("Abort")
        prompt_loop = False
        break
    else:
        print("Proceeding to convertion")
        prompt_loop = False
        break

# Assume that the provided path is to a folder with the regions in TIMIT
# Output can be any path

# The default options are ./data for input (manually placed there)
# and ./data/output for output
recurse_over_regions(data_path)