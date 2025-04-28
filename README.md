# Tshark Protocol Hierarchy Statistics Batch Processor (Windows)

## Description

This Windows Batch script (`.bat`/`.cmd`) automates the process of generating Protocol Hierarchy Statistics for packet capture files (e.g., `.pcap`, `.pcapng`) located in specific subdirectories within a base network directory.

It iterates through a predefined set of numbered subdirectories (typically `1` through `7`) within the configured base path. For each packet capture file found directly within these subdirectories, the script executes `tshark.exe` to extract protocol hierarchy statistics (`io,phs`). The resulting statistics are saved to a corresponding text file (e.g., `capture.pcap` -> `capture.pcap.txt`) in the same directory as the original capture file.

## Prerequisites

1.  **Windows Operating System:** The script is designed for native Windows environments.
2.  **`tshark.exe`:** The command-line utility for Wireshark must be installed.
    * **Crucially**, the directory containing `tshark.exe` (usually `C:\Program Files\Wireshark`) must be added to your system's **`PATH` environment variable**. You can verify this by opening Command Prompt (`cmd.exe`) and simply typing `tshark -v`. If it shows the version, you are likely set. If not, you need to add Wireshark to your PATH.
3.  **Network Access:** You need read/write access to the network share and subdirectories specified in the script's configuration.

## Configuration

Before running the script, you **must** configure the following variable(s) by editing the `.bat`/`.cmd` file:

1.  **`BASE_DIR`** (or similar variable name used in your specific batch script):
    * **Purpose:** Sets the path to the base directory containing the numbered subdirectories (`1`, `2`, etc.) with packet capture files. This should typically be a network path.
    * **Action Required:** **Verify and update this path!** It needs to be the correct path accessible from your Windows machine. Use either a UNC path or a mapped drive letter.
        * **UNC Path Example:** `SET BASE_DIR=\\your-server-name\share-name\pcaps`
        * **Mapped Drive Example:** `SET BASE_DIR=Z:\pcaps` (Assuming `Z:` is mapped to `\\your-server-name\share-name`)
    * **Important:** Replace `\\your-server-name\share-name\pcaps` or `Z:\pcaps` with the *actual* path to the target `pcaps` folder on your network share.

2.  **Subdirectory Processing Logic**:
    * **Purpose:** The script contains logic (likely a `FOR /L` loop in Batch) to process specific numbered subdirectories (e.g., `1` through `7`) inside the `BASE_DIR`.
    * **Action Required (Optional):** If you need to process different subdirectories (e.g., only `1`, `3`, `5` or `8` through `10`), you will need to modify the loop parameters within the Batch script file according to Batch syntax.

## Usage

1.  **Save the script:** Save the Batch script content to a file with a `.bat` or `.cmd` extension (e.g., `process_pcaps.bat`).
2.  **Configure:** Edit the script file (`process_pcaps.bat`) using a text editor (like Notepad) and set the `BASE_DIR` variable (and potentially modify the subdirectory loop) correctly for your environment (see Configuration section above).
3.  **Run the script:**
    * **Option A (Double-Click):** Navigate to the script in File Explorer and double-click it. A command prompt window will appear and show the script's progress.
    * **Option B (Command Prompt):** Open Command Prompt (`cmd.exe`), navigate (`cd`) to the directory where you saved the script, and type the script's name:
        ```cmd
        process_pcaps.bat
        ```
4.  **Monitor Output:** The command window will display messages indicating which directory and file it is currently processing. It should also report any errors encountered (e.g., directory not found, `tshark.exe` issues).

## Functionality Details

* **Directory Iteration:** The script loops through the configured range of numbered subdirectories within the `BASE_DIR`.
* **File Discovery:** For each specified subdirectory, it searches for files (likely using a `FOR` loop in Batch, e.g., `FOR %%F IN (*.*)` or specific extensions like `*.pcap*`). It generally processes files *directly* within that subdirectory and does **not** recurse into further sub-subdirectories (based on the logic translated from the original Bash script).
* **`tshark.exe` Command:** For each discovered packet capture file (`input_file`), it typically runs a command similar to:
    ```cmd
    tshark.exe -r "input_file" -q -z io,phs > "output_file.txt"
    ```
    * `-r "input_file"`: Reads packet data from the specified input file.
    * `-q`: Quiet mode (suppresses per-packet summary output).
    * `-z io,phs`: Calculates and prints Protocol Hierarchy Statistics.
    * `> "output_file.txt"`: Redirects the command's output (the statistics table) to the output text file.
* **Output Files:** The output text file is named based on the original filename, usually by appending `.txt` (e.g., `input.pcap` becomes `input.pcap.txt`). The output file is created in the **same directory** as the input file.
* **Overwriting:** If an output `.txt` file with the target name already exists, it will likely be **overwritten** by the redirection `>`.
* **Error Handling:** A well-written Batch script should include checks:
    * Verify if `BASE_DIR` exists (`IF EXIST %BASE_DIR%\ ...`).
    * Potentially check if `tshark.exe` is findable (`WHERE tshark.exe`).
    * Check the `%ERRORLEVEL%` after the `tshark.exe` command to see if it executed successfully (`IF ERRORLEVEL NEQ 0 ECHO Error processing %%F`). The script should report warnings or errors encountered during processing.
