rm -rf build
echo "Configuring..."
cmake -B build -G Ninja . -DCMAKE_EXPORT_COMPILE_COMMANDS=On
echo "Building..."
cmake --build build