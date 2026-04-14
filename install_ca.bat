@echo off
echo ============================================
echo   Installing Squid CA Certificate
echo   This must be run as Administrator
echo ============================================
echo.

:: Check admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Please run as Administrator
    pause
    exit /b 1
)

:: Find the cert file
set CERT_FILE=squid-ca.crt
if not exist "%CERT_FILE%" (
    echo ERROR: squid-ca.crt not found in current directory
    echo Place squid-ca.crt in the same folder as this script
    pause
    exit /b 1
)

echo Installing certificate to Trusted Root CA store...
certutil -addstore -f "ROOT" "%CERT_FILE%"

if %errorLevel% equ 0 (
    echo.
    echo ✅ Certificate installed successfully!
    echo.
    echo Next steps:
    echo   1. Set proxy in Windows: 192.168.88.110:3128
    echo   2. Restart your browser
    echo   3. Visit https://example.com to test
) else (
    echo.
    echo ❌ Certificate installation failed
    echo Try running this script as Administrator
)

pause