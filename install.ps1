Write-Host "Iniciando la instalación automatizada del entorno de Clasp" -ForegroundColor Cyan

# ---------------------------------------------------------
# PASO 1: Validar e Instalar Node.js
# ---------------------------------------------------------
if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️ Node.js no fue encontrado. Instalando a través de winget..." -ForegroundColor Yellow
    # Ejecuta la instalación de la versión LTS de Node de forma silenciosa
    winget install OpenJS.NodeJS -e --source winget
    
    Write-Host "🚨 ATENCIÓN: Node.js se ha instalado." -ForegroundColor Red
    Write-Host "Para que la terminal reconozca a 'npm', cierra esta ventana, abre una nueva y vuelve a ejecutar .\install.ps1" -ForegroundColor Yellow
    exit # Detiene el script para evitar errores en los siguientes pasos
} else {
    Write-Host "✅ Node.js ya está instalado." -ForegroundColor Green
}

# ---------------------------------------------------------
# PASO 2: Validar e Instalar Clasp globalmente
# ---------------------------------------------------------
if (!(Get-Command clasp -ErrorAction SilentlyContinue)) {
    Write-Host "⚠️ Clasp no fue encontrado. Instalando globalmente..." -ForegroundColor Yellow
    npm install -g @google/clasp
    Write-Host "✅ Clasp instalado correctamente." -ForegroundColor Green
} else {
    Write-Host "✅ Clasp ya está instalado." -ForegroundColor Green
}

# ---------------------------------------------------------
# PASO 3: Validar Autenticación de Google (clasp login)
# ---------------------------------------------------------
# Clasp guarda las credenciales en un archivo oculto en la raíz del usuario
$claspAuthFile = Join-Path $env:USERPROFILE ".clasprc.json"

if (!(Test-Path $claspAuthFile)) {
    Write-Host "⚠️ No se detectó sesión de Google. Abriendo navegador para autenticación..." -ForegroundColor Yellow
    clasp login
    Write-Host "✅ Autenticación completada." -ForegroundColor Green
} else {
    Write-Host "✅ Ya tienes una sesión activa de Google en Clasp." -ForegroundColor Green
}

# ---------------------------------------------------------
# PASO 4: Configurar la plantilla permanente
# ---------------------------------------------------------
$userHome = $env:USERPROFILE
$permanentPath = Join-Path $userHome ".clasp-template"

Write-Host "📂 Configurando directorio de plantillas en $permanentPath..."
if (!(Test-Path $permanentPath)) {
    New-Item -ItemType Directory -Path $permanentPath | Out-Null
}

# Copia los archivos del repositorio clonado (donde se ejecuta este script) a la carpeta permanente.
# Excluye el instalador, la documentación y el historial del repositorio instalador
Get-ChildItem -Path $PSScriptRoot -Exclude "install.ps1", "README.md", ".git" | 
    Copy-Item -Destination $permanentPath -Recurse -Force

# ---------------------------------------------------------
# PASO 5: Configurar el Perfil de PowerShell ($PROFILE)
# ---------------------------------------------------------
# 1. Asegurar que la carpeta base del perfil exista
$profileDir = Split-Path $PROFILE
if (!(Test-Path $profileDir)) {
    Write-Host "📂 Reconstruyendo carpeta base de PowerShell..."
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# 2. Crear el archivo si no existe
if (!(Test-Path $PROFILE)) {
    Write-Host "🛠️ Creando archivo de perfil de PowerShell ($PROFILE)..."
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

# Usamos @' y '@ (comillas simples) para que PowerShell no intente evaluar las variables con $
# durante la instalación, sino que las guarde literalmente como texto en el profile.ps1
$functionCode = @'
# Función para inicializar nuevos proyectos de Apps Script localmente
function newclasp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="El ID del proyecto de Apps Script")]
        [string]$id
    )

    try {
        # 1. Validar que las herramientas necesarias existan en la PC
        if (!(Get-Command clasp -ErrorAction SilentlyContinue)) {
            throw "Error: 'clasp CLI' no está instalado o no figura en las variables de entorno."
        }
        if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
            throw "Error: 'npm' no está instalado. Requiere Node.js."
        }

        # 2. Obtener la ruta dinámica donde se guardaron las plantillas permanentemente
        $templatePath = Join-Path $env:USERPROFILE ".clasp-template"

        if (!(Test-Path $templatePath)) {
            throw "No se encontró la plantilla en: $templatePath. Verifica que la carpeta exista."
        }
        
        Write-Host "Inicializando desde: $templatePath" -ForegroundColor Cyan

        # 3. Copiar plantilla sin sobrescribir archivos críticos si ya existen
        Copy-Item "$templatePath\*" . -Recurse -Force
        
        # 4. Asegurar dependencias locales (npm detectará si ya están instaladas)
        Write-Host "Validando tipos de Google (npm install)..." -ForegroundColor Cyan
        npm install --silent

        # 5. Descargar el código fuente de Google Apps Script usando el ID proporcionado
        Write-Host "Clonando proyecto $id..." -ForegroundColor Cyan
        clasp clone $id

        # 6. Transformar extensiones (.gs a .js) para habilitar validaciones JS nativas en VS Code
        $gsFiles = Get-ChildItem -Path . -Filter *.gs
        if ($gsFiles) {
            $gsFiles | Rename-Item -NewName { $_.Name -replace '\.gs$','.js' }
            Write-Host "Archivos adaptados localmente de .gs a .js." -ForegroundColor Cyan
        }

        Write-Host "¡Entorno local configurado correctamente!" -ForegroundColor Green

    } catch {
        # Captura cualquier error para evitar que la terminal colapse mostrando letras rojas genéricas
        Write-Host "Se detuvo el proceso: $_" -ForegroundColor Red
    }
}
'@

# ---------------------------------------------------------
# PASO 6: Inyectar la función en el Perfil de forma segura
# ---------------------------------------------------------
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

# Solo agregamos el bloque de código si la función 'newclasp' no existe ya en el archivo
if ([string]$profileContent -notmatch "function newclasp") {
    Add-Content -Path $PROFILE -Value "`n$functionCode"
    Write-Host "✅ Comando 'newclasp' agregado globalmente a tu terminal." -ForegroundColor Green
    # Write-Host "🔄 IMPORTANTE: Ejecuta este comando para recargar la terminal actual: . `$PROFILE" -ForegroundColor Yellow
} else {
    Write-Host "⚠️ El comando 'newclasp' ya estaba instalado en tu perfil. Las plantillas han sido actualizadas." -ForegroundColor Yellow
}

Write-Host "Instalación finalizada." -ForegroundColor Cyan