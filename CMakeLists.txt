cmake_minimum_required(VERSION 3.16)
project(Hyperion LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_OSX_DEPLOYMENT_TARGET "14.0")
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_standard_project_setup(REQUIRES 6.5)
qt_policy(SET QTP0004 NEW)

qt_add_executable(hyperion-app
    src/main.cpp
)

qt_add_qml_module(hyperion-app
    URI "Hyperion"
    VERSION 1.0
    QML_FILES src/Main.qml
)

add_library(hyperion-core
)

target_include_directories(hyperion-core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(hyperion-app PRIVATE
    hyperion-core
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick
)
