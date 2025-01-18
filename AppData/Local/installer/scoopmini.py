# mini_scoop.py
import os
import json
import subprocess

def install_scoop_packages():
    config_path = os.path.join(os.getenv("USERPROFILE"), ".local/share/chezmoi/AppData/Local/installer/packages.json")
    with open(config_path, "r") as f:
        config = json.load(f)

    packages = config["scoop"]["mini"]
    scoop_executable = os.path.join(os.getenv("USERPROFILE"), "scoop", "shims", "scoop.cmd")
    for package in packages:
        try:
            print(f"Installing package: {package}")
            subprocess.run([scoop_executable, "install", package], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Failed to install package: {package}. Error: {e}")

def main():
    print("========================================")
    install_scoop_packages()
    print("========================================")

if __name__ == "__main__":
    main()
