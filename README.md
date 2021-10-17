# Windows 11 Setup Script

Setup scripts for Windows 11 PC.

How to use:

1. Install Windows
2. Setup User Account
3. Login
4. Run Powershell as Admin
5. Execute

   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   ```

6. Run the script

    ```powershell
    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alec-hs/windows-11-setup/main/setup.ps1'))
    ```
