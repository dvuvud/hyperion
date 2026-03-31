cmake_minimum_required(VERSION 3.16)
project(Hyperion LANGUAGES CXX)

# --- settings
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")
set(CMAKE_AUTOMOC ON)

# --- qt setup
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

# --- libraries
add_library(hyperion-core STATIC
    src/core/Macro.hpp
    src/core/MacroAction.hpp
    src/core/MacroEngine.hpp
)

target_include_directories(hyperion-core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(hyperion-core PUBLIC
    Qt6::Core
)

# --- app executable
qt_add_executable(hyperion-app
    src/app/main.cpp
)

target_include_directories(hyperion-app PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ui
)

# --- qml module
qt_add_qml_module(hyperion-app
    URI Hyperion
    VERSION 1.0

    QML_FILES
    src/ui/Main.qml

    SOURCES
    src/ui/MacroListModel.hpp
    src/ui/MacroListModel.cpp
)

# --- linking
target_link_libraries(hyperion-app PRIVATE
    hyperion-core
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)
