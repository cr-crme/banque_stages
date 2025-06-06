@REM This script navigates all the subdirectories of the project
@REM and runs the command "pub get" in each of them.

@REM Currently translating the script from bash to batch
@REM Usage: pubget.bat
@REM This script is intended to be run from the root directory of the project.

@REM Move to the script directory
cd /d "%~dp0"

@REM @REM Pub get in the common directory
pushd common
echo "Running pub get in common directory..."
dart pub get
popd

@REM @REM Pub get in the common_flutter directory
pushd common_flutter
echo "Running pub get in common_flutter directory..."
dart pub get
popd

@REM Pub get in the external directory
pushd external\crcrme_material_theme
echo "Running pub get in external\crcrme_material_theme directory..."
call flutter pub get
popd
pushd external\enhanced_containers
pushd plugins\enhanced_containers_foundation
echo "Running pub get in external\enhanced_containers\plugins\enhanced_containers_foundation directory..."
call dart pub get
popd
call flutter pub get
popd

@REM Pub get in the backend directory
pushd backend
echo "Running pub get in backend directory..."
call dart pub get
pushd resources\backend_gui
echo "Running pub get in backend_gui directory..."
call flutter pub get
popd
popd

@REM Pub get in the app directory
pushd app
echo "Running pub get in app directory..."
call flutter pub get
popd

@REM Pub get in the admin_app directory
pushd admin_app
echo "Running pub get in admin_app directory..."
call flutter pub get
popd