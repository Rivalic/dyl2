#!/usr/bin/env python3
"""
Script to inject DeviceRotation.dylib into Swiggy app binary
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

# Configuration
APP_PATH = "swiggy-extracted"
BINARY_NAME = "swiggy"
DYLIB_NAME = "DeviceRotation.dylib"
OUTPUT_APP = "Swiggy-Modified.app"

def run_command(cmd, cwd=None):
    """Run shell command and return output"""
    print(f"[CMD] {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"[ERROR] Command failed: {result.stderr}")
        return None
    return result.stdout

def check_dependencies():
    """Check if required tools are installed"""
    tools = {
        'insert_dylib': 'https://github.com/Tyilo/insert_dylib',
        'optool': 'https://github.com/alexzielenski/optool',
        'ldid': 'Install via: brew install ldid'
    }
    
    # Try to find at least one injection tool
    has_insert_dylib = shutil.which('insert_dylib') is not None
    has_optool = shutil.which('optool') is not None
    has_ldid = shutil.which('ldid') is not None
    
    if not has_insert_dylib and not has_optool:
        print("[ERROR] Neither insert_dylib nor optool found!")
        print("Please install one of:")
        for tool, url in tools.items():
            print(f"  - {tool}: {url}")
        return False
    
    if not has_ldid:
        print("[WARNING] ldid not found. Signing might fail.")
        print(f"  Install: {tools['ldid']}")
    
    return True

def inject_dylib():
    """Inject dylib into app binary"""
    print("\n=== Injecting DeviceRotation.dylib ===\n")
    
    # Paths
    binary_path = os.path.join(APP_PATH, BINARY_NAME)
    dylib_path = f"@executable_path/Frameworks/{DYLIB_NAME}"
    
    if not os.path.exists(binary_path):
        print(f"[ERROR] Binary not found: {binary_path}")
        return False
    
    # Backup original binary
    backup_path = f"{binary_path}.backup"
    if not os.path.exists(backup_path):
        print(f"[INFO] Backing up original binary...")
        shutil.copy2(binary_path, backup_path)
    
    # Try insert_dylib first
    if shutil.which('insert_dylib'):
        print(f"[INFO] Using insert_dylib to inject {DYLIB_NAME}...")
        cmd = [
            'insert_dylib',
            '--inplace',
            '--all-yes',
            dylib_path,
            binary_path
        ]
        result = run_command(cmd)
        if result is None:
            print("[ERROR] insert_dylib failed!")
            return False
        print("[SUCCESS] Dylib injected successfully!")
        
    # Fallback to optool
    elif shutil.which('optool'):
        print(f"[INFO] Using optool to inject {DYLIB_NAME}...")
        cmd = [
            'optool',
            'install',
            '-c',
            'load',
            '-p',
            dylib_path,
            '-t',
            binary_path
        ]
        result = run_command(cmd)
        if result is None:
            print("[ERROR] optool failed!")
            return False
        print("[SUCCESS] Dylib injected successfully!")
    
    return True

def copy_dylib():
    """Copy dylib to Frameworks directory"""
    print("\n=== Copying DeviceRotation.dylib ===\n")
    
    frameworks_dir = os.path.join(APP_PATH, "Frameworks")
    os.makedirs(frameworks_dir, exist_ok=True)
    
    # For now, we'll note that the dylib needs to be compiled on macOS/Linux
    # or via GitHub Actions
    dylib_source = os.path.join("DeviceRotation", ".theos", "obj", "debug", f"{DYLIB_NAME}")
    dylib_dest = os.path.join(frameworks_dir, DYLIB_NAME)
    
    if not os.path.exists(dylib_source):
        print(f"[WARNING] Dylib not found at {dylib_source}")
        print("[INFO] You need to compile the dylib first using Theos on macOS/Linux")
        print("[INFO] Or use GitHub Actions to build it automatically")
        
        # Create a placeholder file
        print(f"[INFO] Creating placeholder at {dylib_dest}")
        Path(dylib_dest).touch()
        return False
    
    print(f"[INFO] Copying {DYLIB_NAME} to Frameworks/")
    shutil.copy2(dylib_source, dylib_dest)
    print("[SUCCESS] Dylib copied!")
    return True

def resign_app():
    """Re-sign the app for sideloading"""
    print("\n=== Re-signing App ===\n")
    
    if shutil.which('ldid'):
        print("[INFO] Signing with ldid...")
        binary_path = os.path.join(APP_PATH, BINARY_NAME)
        
        # Remove existing signature
        cmd = ['ldid', '-S', binary_path]
        result = run_command(cmd)
        
        if result is None:
            print("[WARNING] Signing failed, but app might still work")
        else:
            print("[SUCCESS] App re-signed!")
    else:
        print("[WARNING] ldid not found. Skipping signing.")
        print("[INFO] App will need to be signed during IPA installation")
    
    return True

def create_modified_app():
    """Create modified app directory"""
    print("\n=== Creating Modified App ===\n")
    
    if os.path.exists(OUTPUT_APP):
        print(f"[INFO] Removing existing {OUTPUT_APP}...")
        shutil.rmtree(OUTPUT_APP)
    
    print(f"[INFO] Copying app to {OUTPUT_APP}...")
    shutil.copytree(APP_PATH, OUTPUT_APP)
    print("[SUCCESS] Modified app created!")
    
    return True

def main():
    print("=" * 60)
    print("Swiggy Device Rotation - Dylib Injector")
    print("=" * 60)
    
    # Check dependencies
    if not check_dependencies():
        print("\n[ERROR] Missing required dependencies!")
        sys.exit(1)
    
    # Copy dylib (will warn if not compiled)
    copy_dylib()
    
    # Inject dylib
    if not inject_dylib():
        print("\n[ERROR] Dylib injection failed!")
        sys.exit(1)
    
    # Re-sign app
    resign_app()
    
    # Create modified app
    create_modified_app()
    
    print("\n" + "=" * 60)
    print("✅ SUCCESS! Modified app ready!")
    print("=" * 60)
    print(f"\nNext steps:")
    print(f"1. Compile the dylib using Theos (or use GitHub Actions)")
    print(f"2. Run build_ipa.py to package as IPA")
    print(f"3. Install using AltStore/Sideloadly")
    print()

if __name__ == "__main__":
    main()
