# QA Automatizado — Guía de Configuración de Entornos por Proyecto

Esta guía explica cómo crear entornos de desarrollo reproducibles para cada
proyecto de pruebas automatizadas usando Nix flakes y direnv.

Tu sistema ya provee: IntelliJ IDEA Community, JDK 21, Maven, ChromeDriver
y ADB. Cada proyecto agrega únicamente lo que necesita encima de eso.

---

## Pruebas Web (Selenium + Java)

Para pruebas de interfaz en navegador con Selenium WebDriver.

### 1. Crear el proyecto e inicializar el flake

```bash
mkdir mis-pruebas-web && cd mis-pruebas-web
git init
```

Crear `flake.nix`:

```nix
{
  description = "Automatización de Pruebas Web con Selenium";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          jdk21
          maven
          chromedriver
          google-chrome
        ];

        shellHook = ''
          export JAVA_HOME="${pkgs.jdk21}/lib/openjdk"
          export CHROME_BINARY="${pkgs.google-chrome}/bin/google-chrome-stable"
          export CHROMEDRIVER_BINARY="${pkgs.chromedriver}/bin/chromedriver"
          echo "Shell de QA Web listo — Java $(java --version 2>&1 | head -1)"
        '';
      };
    };
}
```

### 2. Habilitar direnv

```bash
echo "use flake" > .envrc
direnv allow
```

### 3. Crear el proyecto Maven

```bash
mvn archetype:generate \
  -DgroupId=com.ejemplo.pruebas \
  -DartifactId=pruebas-web \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false
```

Agregar dependencias de Selenium y TestNG al `pom.xml`:

```xml
<dependencies>
  <dependency>
    <groupId>org.seleniumhq.selenium</groupId>
    <artifactId>selenium-java</artifactId>
    <version>4.27.0</version>
  </dependency>
  <dependency>
    <groupId>org.testng</groupId>
    <artifactId>testng</artifactId>
    <version>7.10.2</version>
    <scope>test</scope>
  </dependency>
</dependencies>
```

### 4. Abrir en IntelliJ

```bash
idea-community .
```

IntelliJ detectará el proyecto Maven y lo importará automáticamente.

### 5. Ejecutar pruebas

```bash
mvn test
```

---

## Pruebas Móviles (Appium + Java)

Para pruebas de interfaz en Android con Appium.

### 1. Crear el proyecto e inicializar el flake

```bash
mkdir mis-pruebas-moviles && cd mis-pruebas-moviles
git init
```

Crear `flake.nix`:

```nix
{
  description = "Automatización de Pruebas Móviles con Appium";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          jdk21
          maven
          nodejs_22
          android-tools   # adb, fastboot
        ];

        shellHook = ''
          export JAVA_HOME="${pkgs.jdk21}/lib/openjdk"
          export ANDROID_HOME="$HOME/Android/Sdk"
          export PATH="$ANDROID_HOME/platform-tools:$PATH"

          # Instalar Appium globalmente si no está presente
          if ! command -v appium &> /dev/null; then
            echo "Instalando servidor Appium..."
            npm install -g appium
          fi

          echo "Shell de QA Móvil listo — Java $(java --version 2>&1 | head -1)"
          echo "Appium: $(appium --version 2>/dev/null || echo 'ejecutar: npm install -g appium')"
        '';
      };
    };
}
```

### 2. Habilitar direnv

```bash
echo "use flake" > .envrc
direnv allow
```

### 3. Crear el proyecto Maven

```bash
mvn archetype:generate \
  -DgroupId=com.ejemplo.pruebas \
  -DartifactId=pruebas-moviles \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false
```

Agregar dependencias de Appium y TestNG al `pom.xml`:

```xml
<dependencies>
  <dependency>
    <groupId>io.appium</groupId>
    <artifactId>java-client</artifactId>
    <version>9.3.0</version>
  </dependency>
  <dependency>
    <groupId>org.seleniumhq.selenium</groupId>
    <artifactId>selenium-java</artifactId>
    <version>4.27.0</version>
  </dependency>
  <dependency>
    <groupId>org.testng</groupId>
    <artifactId>testng</artifactId>
    <version>7.10.2</version>
    <scope>test</scope>
  </dependency>
</dependencies>
```

### 4. Instalar el driver de Android para Appium

```bash
appium driver install uiautomator2
```

### 5. Iniciar el servidor Appium (en otra terminal)

```bash
appium
```

### 6. Conectar tu dispositivo

```bash
adb devices   # debería listar tu dispositivo Android
```

### 7. Abrir en IntelliJ y ejecutar pruebas

```bash
idea-community .
mvn test
```

---

## Consejos

- **Fijar versiones**: hacer commit de `flake.lock` en Git para que todo el
  equipo use exactamente las mismas versiones de herramientas.
- **direnv + IntelliJ**: instalar el plugin "Direnv Integration" en IntelliJ
  para que el IDE tome automáticamente el entorno del flake.
- **Múltiples versiones de Java**: cambiar `jdk21` por `jdk17` en el flake
  del proyecto si se requiere otro JDK — no afecta tu sistema.
- **CI/CD**: estos mismos flakes funcionan en CI con
  `nix develop --command mvn test`.
