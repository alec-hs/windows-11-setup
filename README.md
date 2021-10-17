# Windows 11 Setup Script

Setup scripts for Windows 11 PC.

How to use:

1 - Install Windows
2 - Setup User Account
3 - Rename PC to wanted name
2 - Login
3 - Run Powershell as Admin
4 - Execute
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
5 - Run the script
    iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alec-hs/windows-11-setup/maininfrastructure@seraph.ai/setup.ps1'))
