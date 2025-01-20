
import os
import json
import subprocess

def get_installed_packages():
    scoop_executable = os.path.join(os.getenv("USERPROFILE"), "scoop", "shims", "scoop.cmd")
    # Get regular installations
    regular_result = subprocess.run([scoop_executable, "list"], capture_output=True, text=True)
    # Get global installations
    global_result = subprocess.run([scoop_executable, "list", "--global"], capture_output=True, text=True)
    
    installed = {
        'regular': [],
        'global': []
    }
    
    # Parse regular installations
    for line in regular_result.stdout.splitlines():
        if line.strip():
            package = line.split()[0]
            if '/' in package:
                package = package.split('/')[-1]
            installed['regular'].append(package)
            
    # Parse global installations
    for line in global_result.stdout.splitlines():
        if line.strip():
            package = line.split()[0]
            if '/' in package:
                package = package.split('/')[-1]
            installed['global'].append(package)
            
    return installed


def install_scoop_packages():
    config_path = os.path.join(os.getenv("USERPROFILE"), ".local/share/chezmoi/AppData/Local/installer/packages.json")
    with open(config_path, "r") as f:
        config = json.load(f)

    packages = config["scoop"]["full"]
    global_packages = config["scoop"]["global"]
    installed_packages = get_installed_packages()
    scoop_executable = os.path.join(os.getenv("USERPROFILE"), "scoop", "shims", "scoop.cmd")

    # Install regular packages
    for package in packages:
        package_name = package.split('/')[-1] if '/' in package else package
        if package_name not in installed_packages:
            try:
                print(f"Installing package: {package}")
                subprocess.run([scoop_executable, "install", package], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Failed to install package: {package}. Error: {e}")
        else:
            print(f"Package already installed: {package_name}")

    # Install global packages
    for package in global_packages:
        package_name = package.split('/')[-1] if '/' in package else package
        if package_name not in installed_packages:
            try:
                print(f"Installing global package: {package}")
                subprocess.run([scoop_executable, "install", package, "--global"], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Failed to install global package: {package}. Error: {e}")
        else:
            print(f"Global package already installed: {package_name}")

    
def main():
    install_scoop_packages()

if __name__ == "__main__":
    main()
