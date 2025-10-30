# Prueba de Automatización Móvil - Aplicación Mercado Libre (Android)

## Objetivo
Automatizar una prueba funcional para la aplicación móvil de **Mercado Libre** en **Android**, utilizando **Ruby** y **Appium**.

El propósito del proyecto es validar el flujo de búsqueda y filtros dentro de la aplicación buscando el término "PlayStation 5", filtrando por condición "Nuevo", ubicaciones en "CDMX", y ordenando los resultados por "Mayor a menor precio". Finalmente se extrae la información de los primeros cinco resultados mostrados. 

---

## Requisitos

### Herramientas y entorno necesarios
- Android Studio (para ejecutar y administrar emuladores Android)
- Appium Server (para la comunicación entre Ruby y el dispositivo Android)
- Ruby (lenguaje de programación utilizado)
- RSpec (framework de pruebas)
- Appium Ruby bindings

---

## Instalación y configuración

--- 
### 1. Clonar el repositorio
```bash
git clone https://github.com/LChristian992/mercadolibre-appium-tests.git
cd mercadolibre-appium-tests
```
### 2. Instalar las gems necesarias
gem install appmium_lim rspec

### 3. Configurar appium.txt 
[caps]
platformName = Android
deviceName = Pixel_3a_API_30 "Depende del emulador o dispositivo fisico"
appPackage = com.mercadolibre
appActivity = com.mercadolibre.splash.SplashActivity "Verificar con Appium Inspector"
automationName = UiAutomator2

### 4. Ejecucion de la prueba
```bash
bundle exec rspec mercprueba.rb
```

### Notas
Los XPaths y resource-ids pueden cambiar según la versión de la app. Verificar con Appium Inspector si hay fallos.








