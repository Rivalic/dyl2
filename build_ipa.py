#!/usr/bin/env python3
"""
Script to build IPA file from modified Swiggy app
"""

import os
import sys
import shutil
import zipfile
from pathlib import Path

# Configuration
MODIFIED_APP = "Swiggy-Modified.app"
EXTRACTED_APP = "swiggy-extracted"
PAYLOAD_DIR = "Payload"
OUTPUT_IPA = "Swiggy-DeviceRotation.ipa"

def create_payload_structure():
    """Create Payload directory structure"""
    print("\n=== Creating Payload Structure ===\n")
    
    # Remove existing Payload directory
    if os.path.exists(PAYLOAD_DIR):
        print(f"[INFO] Removing existing {PAYLOAD_DIR}...")
        shutil.rmtree(PAYLOAD_DIR)
    
    # Create Payload directory
    print(f"[INFO] Creating {PAYLOAD_DIR} directory...")
    os.makedirs(PAYLOAD_DIR, exist_ok=True)
    
    # Determine which app to use
    app_source = MODIFIED_APP if os.path.exists(MODIFIED_APP) else EXTRACTED_APP
    app_dest = os.path.join(PAYLOAD_DIR, "Swiggy.app")
    
    print(f"[INFO] Copying {app_source} to {app_dest}...")
    shutil.copytree(app_source, app_dest)
    
    print("[SUCCESS] Payload structure created!")
    return True

def verify_app_structure():
    """Verify app has all required components"""
    print("\n=== Verifying App Structure ===\n")
    
    app_path = os.path.join(PAYLOAD_DIR, "Swiggy.app")
    
    required_files = [
        "swiggy",  # Main binary
        "Info.plist",
        "PkgInfo"
    ]
    
    for file in required_files:
        file_path = os.path.join(app_path, file)
        if os.path.exists(file_path):
            print(f"[OK] {file}")
        else:
            print(f"[WARNING] {file} not found!")
    
    # Check for dylib
    dylib_path = os.path.join(app_path, "Frameworks", "DeviceRotation.dylib")
    if os.path.exists(dylib_path):
        size = os.path.getsize(dylib_path)
        if size > 100:  # More than placeholder
            print(f"[OK] DeviceRotation.dylib ({size} bytes)")
        else:
            print(f"[WARNING] DeviceRotation.dylib is a placeholder (needs compilation)")
    else:
        print(f"[WARNING] DeviceRotation.dylib not found!")
    
    return True

def create_ipa():
    """Create IPA file (ZIP archive)"""
    print("\n=== Creating IPA File ===\n")
    
    # Remove existing IPA
    if os.path.exists(OUTPUT_IPA):
        print(f"[INFO] Removing existing {OUTPUT_IPA}...")
        os.remove(OUTPUT_IPA)
    
    print(f"[INFO] Creating {OUTPUT_IPA}...")
    
    # Create ZIP file
    with zipfile.ZipFile(OUTPUT_IPA, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Walk through Payload directory
        for root, dirs, files in os.walk(PAYLOAD_DIR):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, '.')
                print(f"  Adding: {arcname}")
                zipf.write(file_path, arcname)
    
    # Get file size
    ipa_size = os.path.getsize(OUTPUT_IPA)
    ipa_size_mb = ipa_size / (1024 * 1024)
    
    print(f"[SUCCESS] IPA created! Size: {ipa_size_mb:.2f} MB")
    return True

def cleanup():
    """Clean up temporary files"""
    print("\n=== Cleanup ===\n")
    
    if os.path.exists(PAYLOAD_DIR):
        print(f"[INFO] Removing {PAYLOAD_DIR}...")
        shutil.rmtree(PAYLOAD_DIR)
        print("[SUCCESS] Cleanup complete!")

def main():
    print("=" * 60)
    print("Swiggy Device Rotation - IPA Builder")
    print("=" * 60)
    
    try:
        # Create Payload structure
        if not create_payload_structure():
            print("\n[ERROR] Failed to create Payload structure!")
            sys.exit(1)
        
        # Verify app structure
        verify_app_structure()
        
        # Create IPA
        if not create_ipa():
            print("\n[ERROR] Failed to create IPA!")
            sys.exit(1)
        
        # Cleanup
        cleanup()
        
        print("\n" + "=" * 60)
        print("✅ SUCCESS! IPA ready for installation!")
        print("=" * 60)
        print(f"\nOutput: {OUTPUT_IPA}")
        print(f"\nInstallation options:")
        print(f"1. AltStore: https://altstore.io")
        print(f"2. Sideloadly: https://sideloadly.io")
        print(f"3. TrollStore: https://github.com/opa334/TrollStore (if jailbroken)")
        print()
        
    except Exception as e:
        print(f"\n[ERROR] {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
