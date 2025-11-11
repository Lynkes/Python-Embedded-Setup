## 🧩 Converter para EXE

### Instalação do compilador

No PowerShell (com permissões de admin):

```powershell
Install-Module -Name ps2exe -Force
```

### Compilação

Depois, na pasta do script:

```powershell
ps2exe.ps1 -inputFile ".\Python_Embedded_Setup.ps1" -outputFile ".\Python_Embedded_Setup.exe" -iconFile ".\python.ico" -title "Python Embedded Setup" -version "1.0.0.0" -requireAdmin
```

💡 **Dica**: coloque um ícone `.ico` (ex: `python.ico`) na mesma pasta.

---

## ✨ Extra (opcional)

Se quiser um **splash gráfico real** (com imagem `.png` ou `.jpg`), dá pra adicionar algo assim logo no início:

```powershell
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("Preparing Python Environment...", "Python Setup", 'OK', 'Information')
```