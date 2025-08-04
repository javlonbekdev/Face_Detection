
# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html.
# For more examples on how to use CMake, see https://github.com/android/ndk-samples.

# Sets the minimum CMake version required for this project.
cmake_minimum_required(VERSION 3.22.1)


# Set the library name
set(LIB_NAME "ann_database")

# Add source files
file(GLOB SOURCE_FILES
        "VectorOperations.cpp"
        "HashFunction.cpp"
        "LSHTable.cpp"
        "ANNDatabase.cpp"
        "ImageUtilsNative.cpp"
        "jni_interface.cpp" # We'll create this file in a later step
)

# Create the native library
add_library(
        ${LIB_NAME}         # Name of the library
        SHARED              # Shared library
        ${SOURCE_FILES}
)

# Include directories
target_include_directories(${LIB_NAME} PRIVATE
        ${CMAKE_SOURCE_DIR}/include
)

# Find the log library
find_library(
        log-lib
        log
)

# Link the log library
target_link_libraries(
        ${LIB_NAME}
        ${log-lib}
)

