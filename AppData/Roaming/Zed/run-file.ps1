# Runs the current file based on its extension.
# Zed equivalent of VSCode's code-runner.executorMap, for Windows.
# Called by the "run file" task in tasks.json.

param(
    [Parameter(Mandatory = $true)]
    [string]$File
)

# Ensure UTF-8 output encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$dir  = Split-Path -Parent $File
$name = [System.IO.Path]::GetFileNameWithoutExtension($File)
$ext  = [System.IO.Path]::GetExtension($File).TrimStart('.').ToLower()

Push-Location $dir
try {
    switch ($ext) {
        # JavaScript / JSX / MJS / CJS
        { $_ -in "js", "mjs", "cjs", "jsx" } {
            if (Get-Command bun -ErrorAction SilentlyContinue) {
                bun $File
            } elseif (Get-Command node -ErrorAction SilentlyContinue) {
                node $File
            } else {
                Write-Host "Neither bun nor node found in PATH."
            }
        }

        # TypeScript / TSX
        { $_ -in "ts", "mts", "cts", "tsx" } {
            if (Get-Command bun -ErrorAction SilentlyContinue) {
                bun $File
            } elseif (Get-Command tsx -ErrorAction SilentlyContinue) {
                tsx $File
            } elseif (Get-Command deno -ErrorAction SilentlyContinue) {
                deno run -A $File
            } elseif (Get-Command ts-node -ErrorAction SilentlyContinue) {
                ts-node $File
            } else {
                npx tsx $File
            }
        }

        # Python
        "py" {
            if (Get-Command python -ErrorAction SilentlyContinue) {
                python -u $File
            } elseif (Get-Command py -ErrorAction SilentlyContinue) {
                py -3 -u $File
            } else {
                Write-Host "Python not found in PATH."
            }
        }

        # Rust
        "rs" {
            if ((Test-Path "Cargo.toml") -or (Test-Path "..\Cargo.toml") -or (Test-Path "..\..\Cargo.toml")) {
                cargo run
            } else {
                rustc $File -o "$name.exe"
                if ($LASTEXITCODE -eq 0) {
                    & ".\$name.exe"
                }
            }
        }

        # C
        "c" {
            if (Get-Command clang -ErrorAction SilentlyContinue) {
                clang -Wall -Wextra -O2 $File -o "$name.exe"
            } else {
                gcc -Wall -Wextra -O2 $File -o "$name.exe"
            }
            if ($LASTEXITCODE -eq 0) {
                & ".\$name.exe"
            }
        }

        # C++
        { $_ -in "cpp", "cc", "cxx", "c++" } {
            if (Get-Command clang++ -ErrorAction SilentlyContinue) {
                clang++ -std=c++20 -Wall -Wextra -O2 $File -o "$name.exe"
            } else {
                g++ -std=c++20 -Wall -Wextra -O2 $File -o "$name.exe"
            }
            if ($LASTEXITCODE -eq 0) {
                & ".\$name.exe"
            }
        }

        # Go
        "go" {
            if (Test-Path "go.mod") {
                go run .
            } else {
                go run $File
            }
        }

        # Java
        "java" {
            if (Test-Path "pom.xml") {
                mvn compile exec:java
            } elseif (Test-Path "build.gradle") {
                gradle run
            } else {
                java --enable-preview $File
            }
        }

        # C#
        "cs" {
            $csproj = Get-ChildItem -Filter *.csproj -Depth 2 | Select-Object -First 1
            if ($csproj) {
                dotnet run
            } elseif (Get-Command dotnet-script -ErrorAction SilentlyContinue) {
                dotnet-script $File
            } elseif (Get-Command scriptcs -ErrorAction SilentlyContinue) {
                scriptcs $File
            } else {
                csc -nologo -out:"$name.exe" $File
                if ($LASTEXITCODE -eq 0) { & ".\$name.exe" }
            }
        }

        # Lua
        "lua" {
            if (Get-Command luajit -ErrorAction SilentlyContinue) {
                luajit $File
            } else {
                lua $File
            }
        }

        # Zig
        "zig" {
            zig run $File
        }

        # Nim
        "nim" {
            nim r -d:release $File
        }

        # Haskell
        { $_ -in "hs", "lhs" } {
            if (Get-Command runhaskell -ErrorAction SilentlyContinue) {
                runhaskell $File
            } else {
                ghc -O2 $File -o "$name.exe"
                if ($LASTEXITCODE -eq 0) { & ".\$name.exe" }
            }
        }

        # Kotlin
        { $_ -in "kt", "kts" } {
            if ($ext -eq "kts") {
                kotlinc -script $File
            } else {
                kotlin $File
            }
        }

        # Ruby
        "rb" {
            ruby $File
        }

        # PHP
        "php" {
            php $File
        }

        # Dart
        "dart" {
            dart run $File
        }

        # Swift
        "swift" {
            swift $File
        }

        # R
        "r" {
            Rscript $File
        }

        # Shell / Bash
        { $_ -in "sh", "bash", "zsh" } {
            bash $File
        }

        # PowerShell
        "ps1" {
            powershell -NoProfile -ExecutionPolicy Bypass -File $File
        }

        # Batch / CMD
        { $_ -in "bat", "cmd" } {
            cmd /c $File
        }

        # HTML / HTM (Live Reloading Server)
        { $_ -in "html", "htm" } {
            if (Get-Command live-server -ErrorAction SilentlyContinue) {
                live-server --port=5500 --entry-file=$File $dir
            } elseif (Get-Command browser-sync -ErrorAction SilentlyContinue) {
                browser-sync start --server --files $dir --startPath (Split-Path -Leaf $File)
            } else {
                Start-Process $File
            }
        }

        default {
            Write-Host "No runner configured for .$ext files - add a case in run-file.ps1"
            exit 1
        }
    }
}
finally {
    Pop-Location
}
