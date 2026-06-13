# Plantilla para inicializar un Proyecto Clasp local

Esta es una plantilla automatizada para configurar un entorno de desarrollo local profesional para Google Apps Script utilizando `clasp` en Windows.

Al instalar este entorno, obtendrás un comando global en PowerShell (`newclasp`) que te permitirá descargar cualquier proyecto de Apps Script, configurar el autocompletado inteligente de código en VS Code y adaptar las extensiones automáticamente.

## ✨ Características

- Instalación automática de **Node.js** (vía winget) y **Clasp**.
- Autenticación de Google automática si no hay sesión activa.
- Configuración de autocompletado inteligente para VS Code (`jsconfig.json`).
- Ignorado seguro de archivos innecesarios al subir código (`.claspignore`).

## 🛠️ Requisitos Previos

- Windows 10 o superior.
- PowerShell 5.1 o superior.
- Git instalado.

## 🚀 Instalación

**Paso 1: Clonar el repositorio**  
Clona este repositorio en cualquier lugar de tu computadora (puedes borrar la carpeta después de la instalación).

**Paso 2: Habilitar la ejecución de scripts en PowerShell**  
Por defecto, Windows bloquea la ejecución de scripts no firmados. Para permitir que el instalador se ejecute, abre PowerShell como Administrador y ejecuta el siguiente comando:

```PowerShell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

> (Presiona S o Y para confirmar si te lo pregunta).

**Paso 3: Ejecutar el instalador**  
Abre una terminal de PowerShell dentro de la carpeta clonada y ejecuta:

```PowerShell
.\install.ps1
```

Sigue las instrucciones en pantalla. Si el script instala Node.js por primera vez, te pedirá reiniciar la terminal y volver a ejecutar `.\install.ps1`.

## 💻 Uso

Una vez finalizada la instalación, puedes crear un nuevo proyecto de Apps Script en cualquier carpeta de tu computadora.

Abre tu terminal y ejecuta el nuevo comando global seguido del ID de tu proyecto de Apps Script (lo encuentras en la URL del editor web de Google o en la configuración del proyecto de Apps Script):

```PowerShell
newclasp ID_DEL_PROYECTO
```

¿Qué hace este comando?

1. Crea los archivos base de configuración en tu carpeta actual.

2. Descarga el código fuente desde Google Apps Script.

3. Convierte todos los archivos .gs a .js para habilitar las validaciones nativas de JavaScript.

4. Instala las definiciones de tipos (@types/google-apps-script) para VS Code de forma silenciosa.
