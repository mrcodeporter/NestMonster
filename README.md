# NestMonster Help & Documentation

## Introduction

**NestMonster** is your go-to creature for creating organized and structured directory habitats for your projects. Initially tailored for Python enthusiasts, NestMonster's adaptability ensures that any project, irrespective of language or type, finds its perfect nesting ground. Created by **Mr. Code Porter**, this tool is currently in its **Alpha Beta** phase.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Custom Configuration](#custom-configuration)
- [Troubleshooting](#troubleshooting)
- [Feedback & Support](#feedback--support)
- [Credits](#credits)

## Features

- **Interactive GUI Menu**: A user-friendly menu system that guides you seamlessly through NestMonster's capabilities.
- **Config-Driven Approach**: Offers the flexibility to craft custom directory layouts using a simple JSON configuration.
- **Directory Verification**: Swiftly confirms if an existing directory aligns with the desired structure.
- **Adaptability**: While initially designed with Python in mind, NestMonster can be tailored for any project type.

## Getting Started

- **Installation**: Ensure you have PowerShell installed. Download `NestMonster.ps1` and `NestMonsterConfig.json` to your preferred location.
- **Permissions**: Ensure that the script has the necessary permissions to run. You might need to modify the execution policy in PowerShell using `Set-ExecutionPolicy`.

## Usage

1. **Launching the Tool**: Navigate to the directory containing `NestMonster.ps1` and execute it either by double-clicking or running it from the PowerShell terminal.
2. **Interactive Menu**: The tool will present an interactive menu. Choose the desired action and follow the on-screen prompts.
3. **Choosing a Directory**: For actions that require directory selection, a dialog box will appear. Navigate to the desired location and select the folder.

## Custom Configuration

1. **Open Config File**: Navigate to `NestMonsterConfig.json` using any text editor.
2. **Modify Structure**: The JSON file has two main sections: "directories" and "files".
   - `directories`: List all directories you wish to create.
   - `files`: For each directory, specify the files you wish to generate.
3. **Save & Close**: After making your modifications, save and close the file. NestMonster will now utilize this new configuration the next time it's run.

## Troubleshooting

- **Script Doesn't Run**: Ensure the execution policy in PowerShell allows the script to run.
- **Directory Creation Issues**: Check for sufficient permissions in the target location. Ensure the drive has enough space.
- **Config Issues**: If NestMonster behaves unexpectedly, ensure the `NestMonsterConfig.json` file's format is correct and that it's in the same location as the script.

## Feedback & Support

For any questions, feedback, or if you encounter issues, please reach out. We appreciate your feedback and strive to improve NestMonster with your valuable insights.

## Credits

NestMonster is developed and maintained by **Mr. Code Porter**. The tool is currently in its **Alpha Beta** stage and is evolving continuously. All feedback and contributions are welcomed!

