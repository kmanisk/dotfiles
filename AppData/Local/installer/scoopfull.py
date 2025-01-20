
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
    
    # Update existing fonts
    update_commands = [
        ["update", "-g", "nerd-fonts/FiraCode-NF"],
        ["update", "-g", "nerd-fonts/JetBrainsMono-NF-Mono"]
		# Add new fonts here, for example:
        # ["update", "-g", "nerd-fonts/Hack-NF"],
        # ["update", "-g", "nerd-fonts/CascadiaCode-NF"]
    ]
    
    print("Updating fonts...")
    for command in update_commands:
        try:
            subprocess.run([scoop_executable] + command, check=True)
        except subprocess.CalledProcessError:
            # If update fails, try fresh install
            try:
                install_command = ["install", "-g", command[2]]
                print(f"Installing font: {command[2]}")
                subprocess.run([scoop_executable] + install_command, check=True)
            except subprocess.CalledProcessError as e:
                print(f"Note: Font {command[2]} installation requires all applications using it to be closed.")

    
def main():
    install_scoop_packages()
    install_font()

if __name__ == "__main__":
    main()
