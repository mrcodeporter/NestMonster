# Load necessary assemblies
Add-Type -AssemblyName System.Windows.Forms

# Define path to the configuration file and log file
$configPath = 'NestMonsterConfig.json'
$logPath = 'NestMonsterLog.txt'

# Logging function
function LogAction($message) {
    "$((Get-Date).ToString()): $message" | Out-File $logPath -Append
}

function LoadConfiguration() {
    if (-Not (Test-Path $configPath)) {
        [System.Windows.Forms.MessageBox]::Show("Configuration file not found. Exiting.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }

    try {
        $script:config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to load configuration. Ensure the JSON is valid. Exiting.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }
}

function CreateStructureFromConfig($path, $category) {
    # Clear previous summary
    $global:summary.Clear()

    foreach ($dir in $config.directories.$category) {
        $dirPath = Join-Path $path $dir
        New-Item -Path $dirPath -ItemType Directory -Force
        $global:summary += "Created directory: $dirPath"

        foreach ($file in $config.files.$category.$dir) {
            $filePath = Join-Path $dirPath $file
            New-Item -Path $filePath -ItemType File -Force
            $global:summary += "Created file: $filePath"
        }
    }

    ShowSummaryReport
}

function VerifyStructure($path) {
    # Clear previous summary
    $global:summary.Clear()

    $allExists = $true

    foreach ($dir in $config.directories) {
        $dirPath = Join-Path $path $dir
        if (-Not (Test-Path $dirPath -PathType Container)) {
            $global:summary += "Missing directory: $dirPath"
            $allExists = $false
            continue
        }

        foreach ($file in $config.files.$dir) {
            $filePath = Join-Path $dirPath $file
            if (-Not (Test-Path $filePath -PathType Leaf)) {
                $global:summary += "Missing file: $filePath in directory $dirPath"
                $allExists = $false
            }
        }
    }

    if ($allExists) {
        $global:summary += "All directories and files are present!"
    }

    ShowSummaryReport
}

# Function to delete folder structure and update the summary
function DeleteStructure($path) {
   $confirm = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to delete the specified structure? This action cannot be undone!", "Confirm Deletion", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
   
   if ($confirm -eq [System.Windows.Forms.DialogResult]::No) {
       return
   }

   function DeleteItem($itemPath) {
       try {
           if (Test-Path $itemPath -PathType Leaf) {
               Remove-Item $itemPath -Force -ErrorAction SilentlyContinue
               LogAction "Deleted file: $itemPath"
           } elseif (Test-Path $itemPath -PathType Container) {
               Remove-Item $itemPath -Force -Recurse -ErrorAction SilentlyContinue
               LogAction "Deleted directory: $itemPath"
           }
       } catch {
           LogAction "Failed to delete item: $itemPath, $_.Exception.Message"
       }
   }

   foreach ($dir in $config.directories) {
       $dirPath = Join-Path $path $dir

       foreach ($file in $config.files.$dir) {
           $filePath = Join-Path $dirPath $file
           DeleteItem $filePath
       }

       # Delete the directory after deleting all files
       DeleteItem $dirPath
   }

   [System.Windows.Forms.MessageBox]::Show("Structure deleted successfully!", "Success")
   ShowSummaryReport
}


# Backup logic
function BackupProject($sourcePath) {
    # Define the backup directory
    $backupDir = "$sourcePath-backup-$(Get-Date -Format "yyyyMMddHHmmss")"

    # Copy items from source to backup directory
    Copy-Item -Path $sourcePath -Destination $backupDir -Recurse

    # Return the backup directory path
    return $backupDir
}

# Main GUI execution starts here
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "NestMonster Main Menu"
$mainForm.Size = New-Object System.Drawing.Size(300, 400)  # Adjusted for more space

# Create buttons for different actions
$createPythonButton = New-Object System.Windows.Forms.Button
$createPythonButton.Location = New-Object System.Drawing.Point(10, 10)
$createPythonButton.Size = New-Object System.Drawing.Size(260, 40)
$createPythonButton.Text = "Create Python Folder Structure"
$createPythonButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a location for the new Python folder structure"
    $result = $folderBrowser.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowser.SelectedPath
        CreateStructureFromConfig $selectedPath "python"
        [System.Windows.Forms.MessageBox]::Show("Python folder structure created at $selectedPath!", "Creation Successful")
    }
})

$createHTMLButton = New-Object System.Windows.Forms.Button
$createHTMLButton.Location = New-Object System.Drawing.Point(10, 60)
$createHTMLButton.Size = New-Object System.Drawing.Size(260, 40)
$createHTMLButton.Text = "Create HTML Folder Structure"
$createHTMLButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a location for the new HTML folder structure"
    $result = $folderBrowser.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowser.SelectedPath
        CreateStructureFromConfig $selectedPath "html"
        [System.Windows.Forms.MessageBox]::Show("HTML folder structure created at $selectedPath!", "Creation Successful")
    }
})

$verifyButton = New-Object System.Windows.Forms.Button
$verifyButton.Location = New-Object System.Drawing.Point(10, 110)
$verifyButton.Size = New-Object System.Drawing.Size(260, 40)
$verifyButton.Text = "Verify Folder Structure"
$verifyButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a project folder to verify"
    $result = $folderBrowser.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowser.SelectedPath
        VerifyStructure $selectedPath
    }
})

$deleteButton = New-Object System.Windows.Forms.Button
$deleteButton.Location = New-Object System.Drawing.Point(10, 160)
$deleteButton.Size = New-Object System.Drawing.Size(260, 40)
$deleteButton.Text = "Delete Folder Structure"
$deleteButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a project folder to delete"
    $result = $folderBrowser.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowser.SelectedPath
        DeleteStructure $selectedPath
    }
})

$backupButton = New-Object System.Windows.Forms.Button
$backupButton.Location = New-Object System.Drawing.Point(10, 210)
$backupButton.Size = New-Object System.Drawing.Size(260, 40)
$backupButton.Text = "Backup Project Structure"
$backupButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select a project folder to backup"
    $result = $folderBrowser.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedPath = $folderBrowser.SelectedPath
        $backupLocation = BackupProject $selectedPath
        [System.Windows.Forms.MessageBox]::Show("Project backed up successfully to $backupLocation!", "Backup Successful")
    }
})

$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Location = New-Object System.Drawing.Point(10, 260)
$refreshButton.Size = New-Object System.Drawing.Size(260, 40)
$refreshButton.Text = "Refresh Configuration"
$refreshButton.Add_Click({
    LoadConfiguration
    [System.Windows.Forms.MessageBox]::Show("Configuration reloaded!", "Success")
})

$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Location = New-Object System.Drawing.Point(10, 310)
$exitButton.Size = New-Object System.Drawing.Size(260, 40)
$exitButton.Text = "Exit"
$exitButton.Add_Click({$mainForm.Close()})

# Add buttons to the form
$mainForm.Controls.Add($createPythonButton)
$mainForm.Controls.Add($createHTMLButton)
$mainForm.Controls.Add($verifyButton)
$mainForm.Controls.Add($deleteButton)
$mainForm.Controls.Add($backupButton)
$mainForm.Controls.Add($refreshButton)
$mainForm.Controls.Add($exitButton)

# Initialize a summary list to capture actions
$global:summary = @()

function ShowSummaryReport() {
    $summaryForm = New-Object System.Windows.Forms.Form
    $summaryForm.Text = "NestMonster Summary Report"
    $summaryForm.Size = New-Object System.Drawing.Size(400, 400)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Dock = [System.Windows.Forms.DockStyle]::Fill

    foreach ($line in $global:summary) {
        if ($line -ne $null) {
            $listBox.Items.Add($line)
        }
    }

    $summaryForm.Controls.Add($listBox)
    $summaryForm.ShowDialog()
}

# ... (the rest of your script) ...

# Main GUI execution starts here
$mainForm.ShowDialog()
