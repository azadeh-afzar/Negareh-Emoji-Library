#!/usr/bin/env python3

# Python Standard Library
import os
import glob
import subprocess

# Custom modules
from json_generator import generate_negarmoji_json

# configure path variables.
file_path = os.path.abspath(os.path.dirname(__file__))
base_path = os.path.abspath(os.path.dirname(file_path))
temp_path = os.path.join(file_path, "temp")
gemoji_json_file = os.path.join(temp_path, "gemoji.json")
openmoji_json_file = os.path.join(temp_path, "openmoji.json")
negarmoji_json_file = os.path.join(base_path, "db", "negarmoji.json")
filenames_json_file = os.path.join(base_path, "db", "filenames.json")

# download latest files from gemoji and openmoji repositories.
process = subprocess.run(["./downloader.sh"], stdout=subprocess.PIPE)

# generate negarmoji json.
generate_negarmoji_json(gemoji_json_file, openmoji_json_file, negarmoji_json_file)

# generate emoji filenames json.
process = subprocess.run(["./filename_generator.rb", f"{filenames_json_file}"], stdout=subprocess.PIPE)

# delete temp folder.
process = subprocess.run(["rm", "-rf", f"{temp_path}"], stdout=subprocess.PIPE)
