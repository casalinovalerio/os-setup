# os-setup
Setup the OS I use with the tools I use. Maybe it will become a wizard-ish 
repository... 🧙‍♂️🔧

## Quick deploy

Ubuntu WSL:

```bash
sudo su
curl -sSLf "https://github.com/casalinovalerio/os-setup/raw/master/wsl.sh" | sh
```

Pop!\_OS:

```bash
sudo su
curl -sSLf "https://github.com/casalinovalerio/os-setup/raw/master/pop-os.sh" | sh
```

Windows 10:

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/casalinovalerio/os-setup/raw/master/windows.ps1'))
```
