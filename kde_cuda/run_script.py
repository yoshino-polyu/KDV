#!/usr/bin/env python3
import json
import os
import argparse
import sys
from datetime import datetime

def generate_bash_script(json_file):
    """
    Generate a bash script from parameters in a JSON file.
    
    Args:
        json_file (str): Path to the JSON configuration file
    """
    print(f"Starting to process JSON file: {json_file}")
    try:
        # Read the JSON file
        with open(json_file, 'r') as file:
            params = json.load(file)
        print(f"Successfully loaded JSON configuration file")
    except FileNotFoundError:
        print(f"Error: JSON file '{json_file}' not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: '{json_file}' is not a valid JSON file")
        sys.exit(1)
    
    print("Extracting parameters from JSON configuration...")
    # Extract parameters with default values
    executable = params.get('executable', 'kde_cuda_old')
    mode = params.get('mode', 1)
    points_file = params.get('points_file', 'pntsRedwood.csv')
    mask_file = params.get('mask_file', 'maskSim160000.asc')
    bandwidth_option = params.get('bandwidth_option', 0)
    skip_sequential = params.get('skip_sequential', 1)
    skip_parallel = params.get('skip_parallel', 0)
    output_sequential = params.get('output_sequential', 'redwood_SEQ.asc')
    output_parallel = params.get('output_parallel', 'redwood_GPU.asc')
    log_prefix = params.get('log_prefix', f"{executable}_LOG")
    executable_path = params.get('executable_path', 'build/bin')
    timestamp_format = params.get('timestamp_format', '%m-%d-%H:%M')
    
    # Create the command
    print("Creating command string...")
    command = f'{executable_path}/{executable} {mode} {points_file} {mask_file} {bandwidth_option} {skip_sequential} {skip_parallel} {output_sequential} {output_parallel}'
    
    # Create the bash script content
    print("Generating bash script content...")
    bash_content = f'#!/bin/bash\nsh -c "{command} > {log_prefix}_$(date +\'{timestamp_format}\').log"'
    
    # Write to bash file
    bash_file = f"run_{executable}.sh"
    try:
        print(f"Writing bash script to file: {bash_file}")
        with open(bash_file, 'w') as file:
            file.write(bash_content)
        
        # Make the bash file executable
        print("Setting execute permissions on bash script...")
        os.chmod(bash_file, os.stat(bash_file).st_mode | 0o111)
        
        print(f"Successfully generated bash script: {bash_file}")
    except IOError as e:
        print(f"Error writing to file '{bash_file}': {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate bash script from JSON config')
    parser.add_argument('json_file', help='Path to the JSON config file')
    args = parser.parse_args()
    
    print("=== KDE CUDA Script Generator ===")
    print(f"Process started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    generate_bash_script(args.json_file)
    print(f"Process completed at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("==================================")