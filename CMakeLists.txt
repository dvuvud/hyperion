cmake_minimum_required(VERSION 3.16)
project(Hyperion LANGUAGES CXX)

# --- settings
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_AUTOMOC ON)

# --- qt setup
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

# --- libraries
add_library(hyperion-core STATIC
    src/core/Macro.hpp
    src/core/MacroAction.hpp
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
    ${CMAKE_CURRENT_SOURCE_DIR}/src/core
)

target_compile_definitions(hyperion-app PRIVATE
    PROJECT_ROOT="${CMAKE_SOURCE_DIR}"
)

# --- qml module
qt_add_qml_module(hyperion-app
    URI Hyperion
    VERSION 1.0

    QML_FILES
        src/ui/Main.qml

        # screens
        src/ui/screens/HomeScreen.qml
        src/ui/screens/CreateMacroScreen.qml
        src/ui/screens/LibraryScreen.qml

        # components
        src/ui/components/MacroCard.qml
        src/ui/components/Logo.qml
        src/ui/components/TitleBar.qml
        src/ui/components/StatusBar.qml
        src/ui/components/MacroToolbar.qml
        src/ui/components/MacroItem.qml

    SOURCES
        src/core/MacroListModel.hpp
        src/core/MacroListModel.cpp
        src/core/MacroEngineHost.hpp
        src/core/MacroEngineHost.cpp
        src/core/MacroEngine.hpp
        src/core/MacroEngine.cpp

    RESOURCES
        src/ui/icons/back.svg
        src/ui/icons/save.svg
        src/ui/icons/run.svg
        src/ui/icons/keyboard.svg
        src/ui/icons/mouse.svg
        src/ui/icons/delay.svg
        src/ui/icons/loop.svg
        src/ui/icons/macro-create.svg
        src/ui/icons/macro-browse.svg
)

# --- linking
target_link_libraries(hyperion-app PRIVATE
    hyperion-core
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)
