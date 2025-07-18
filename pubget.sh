#!/usr/bash

# This script navigates all the subdirectories of the project
# and runs the command "pub get" in each of them.

# Usage: ./pubget.sh
# Make sure to give execute permission to the script
# chmod +x pubget.sh

# Move to the directory of the script
cd "$(dirname "$0")"

# Pub get in the common directory
pushd common
echo "Running pub get in common directory..."
dart pub get
popd

# Pub get in the common_flutter directory
pushd common_flutter
echo "Running pub get in common_flutter directory..."
flutter pub get
popd

# Pub get in the external directory
pushd external/crcrme_material_theme
echo "Running pub get in external/crcrme_material_theme directory..."
flutter pub get
popd
pushd external/enhanced_containers
pushd plugins/enhanced_containers_foundation
echo "Running pub get in external/enhanced_containers/plugins/enhanced_containers_foundation directory..."
dart pub get
popd
flutter pub get
popd

# Pub get in the backend directory
pushd backend
echo "Running pub get in backend directory..."
dart pub get
pushd resources/backend_gui
echo "Running pub get in backend_gui directory..."
flutter pub get
popd
popd

# Pub get in the app directory
pushd app
echo "Running pub get in app directory..."
flutter pub get
popd

# Pub get in the admin_app directory
pushd admin_app
echo "Running pub get in admin_app directory..."
flutter pub get
popd