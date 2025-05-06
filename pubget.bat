# This script navigates all the subdirectories of the project
# and runs the command "pub get" in each of them.

# Currently translating the script from bash to batch
# Usage: pubget.bat
# This script is intended to be run from the root directory of the project.

# Check if the script is being run from the root directory 
# of the project by checking for the presence of the "backend" and "app" directory
if not exist "backend" (
    echo "This script must be run from the root directory of the project."
    exit /b 1
)

# Pub get in the common directory
pushd common
echo "Running pub get in common directory..."
dart pub get
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