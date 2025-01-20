
import os
import json
import subprocess

def get_installed_packages():
    scoop_executable = os.path.join(os.getenv("USERPROFILE"), "scoop", "shims", "scoop.cmd")
    result = subprocess.run([scoop_executable, "list"], capture_output=True, text=True)
    installed = []
    for line in result.stdout.splitlines():
        if line.strip():
            package = line.split()[0]
            # Get just the package name without bucket
            if '/' in package:
                package = package.split('/')[-1]
            installed.append(package)
    return installed

def install_scoop_packages():
    config_path = os.path.join(os.getenv("USERPROFILE"), ".local/share/chezmoi/AppData/Local/installer/packages.json")
    with open(config_path, "r") as f:
        config = json.load(f)

    packages = config["scoop"]["full"]
    installed_packages = get_installed_packages()
    scoop_executable = os.path.join(os.getenv("USERPROFILE"), "scoop", "shims", "scoop.cmd")

    for package in packages:
        # Extract package name for comparison
        package_name = package.split('/')[-1] if '/' in package else package
        
        if package_name not in installed_packages:
            try:
                print(f"Installing package: {package}")
                subprocess.run([scoop_executable, "install", package], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Failed to install package: {package}. Error: {e}")
        else:
            print(f"Package already installed: {package_name}")


def install_font():
    scoop_executable = os.path.join(os.getenv("USERPROFILE"), "scoop", "shims", "scoop.cmd")
    font_commands = [
        ["install", "-g", "nerd-fonts/FiraCode-NF"],
        ["install", "-g", "nerd-fonts/JetBrainsMono-NF-Mono"]
    ]
    
    for command in font_commands:
        try:
            print(f"Installing font: {command[2]}")
            subprocess.run([scoop_executable] + command, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Failed to install font: {command[2]}. Error: {e}")

    
def main():
    install_scoop_packages()
    install_font()

if __name__ == "__main__":
    main()
