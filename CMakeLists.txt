cmake_minimum_required(VERSION 3.14)
project(CordPlugin LANGUAGES CXX)

# ── Nix builder path ──────────────────────────────────────────────────────────
# When built via logos-module-builder (nix build .#packages.x86_64-linux.lgx-portable),
# LOGOS_MODULE_BUILDER_ROOT is set. logos_module() registers the target so the
# builder can locate cord_plugin.so.
if(DEFINED ENV{LOGOS_MODULE_BUILDER_ROOT})
    include($ENV{LOGOS_MODULE_BUILDER_ROOT}/cmake/LogosModule.cmake)

    logos_module(
        NAME logos_cord
        SOURCES
            src/plugin/CordPlugin.h
            src/plugin/CordPlugin.cpp
        INCLUDE_DIRS
            src
    )

else()
# ── Local dev path ────────────────────────────────────────────────────────────
# Used by: cmake -B build && cmake --build build && cmake --install build

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# ── Qt ────────────────────────────────────────────────────────────────────────
list(PREPEND CMAKE_PREFIX_PATH "$ENV{HOME}/Qt/6.9.3/gcc_64")
find_package(Qt6 REQUIRED COMPONENTS Core Qml)
qt_standard_project_setup()

# ── Nix store paths ───────────────────────────────────────────────────────────
if(DEFINED ENV{LOGOS_LIBLOGOS_HEADERS})
    set(LOGOS_LIBLOGOS_HEADERS "$ENV{LOGOS_LIBLOGOS_HEADERS}")
else()
    set(LOGOS_LIBLOGOS_HEADERS
        "/nix/store/lkr4jwcdh7k1yw5lisvpvaya4pq8qiv4-logos-liblogos-headers-0.1.0/include")
endif()

if(DEFINED ENV{LOGOS_CPP_SDK_ROOT})
    set(LOGOS_CPP_SDK "$ENV{LOGOS_CPP_SDK_ROOT}")
else()
    set(LOGOS_CPP_SDK
        "/nix/store/c23ijr4km1wc2jixw4siqmbw3yaqf4z2-logos-cpp-sdk")
endif()

# ── Plugin ────────────────────────────────────────────────────────────────────
add_library(logos_cord_plugin MODULE
    src/plugin/CordPlugin.h
    src/plugin/CordPlugin.cpp
)

set_target_properties(logos_cord_plugin PROPERTIES
    PREFIX ""
    OUTPUT_NAME "cord_plugin"
)

target_include_directories(logos_cord_plugin PRIVATE
    src
    "${LOGOS_LIBLOGOS_HEADERS}"
    "${LOGOS_CPP_SDK}/include"
    "${LOGOS_CPP_SDK}/include/cpp"
    "${LOGOS_CPP_SDK}/include/core"
)

# Note: Do NOT add --whole-archive around liblogos_sdk.a — it pulls in
# QRemoteObjectRegistryHost(QUrl,QObject*) which was removed in Qt 6.9.3,
# causing load failure outside the AppImage.
# (whole-archive-module-proxy-strip skill — Qt 6.9.3 exception applies here)
target_link_libraries(logos_cord_plugin PRIVATE
    Qt6::Core
    Qt6::Qml
    "${LOGOS_CPP_SDK}/lib/liblogos_sdk.a"
    dl pthread
)

configure_file(
    src/plugin/plugin_metadata.json
    ${CMAKE_CURRENT_BINARY_DIR}/src/plugin/plugin_metadata.json
    COPYONLY
)

# ── Tests ─────────────────────────────────────────────────────────────────────
enable_testing()
find_package(Qt6 REQUIRED COMPONENTS Test)

add_executable(test_cord_plugin
    tests/test_cord_plugin.cpp
    tests/logos_api_stub.cpp
    src/plugin/CordPlugin.h
    src/plugin/CordPlugin.cpp
    "${LOGOS_CPP_SDK}/include/cpp/logos_api.h"
)

target_include_directories(test_cord_plugin PRIVATE
    src
    "${LOGOS_LIBLOGOS_HEADERS}"
    "${LOGOS_CPP_SDK}/include"
    "${LOGOS_CPP_SDK}/include/cpp"
    "${LOGOS_CPP_SDK}/include/core"
)

target_link_libraries(test_cord_plugin PRIVATE
    Qt6::Core
    Qt6::Test
    dl pthread
)

add_test(NAME test_cord_plugin COMMAND test_cord_plugin)

# ── Install paths ─────────────────────────────────────────────────────────────
set(LOGOS_BASECAMP_DATA "$ENV{HOME}/.local/share/Logos/LogosBasecamp")
set(CORD_MODULE_DIR "${LOGOS_BASECAMP_DATA}/modules/logos_cord")
set(CORD_UI_DIR     "${LOGOS_BASECAMP_DATA}/plugins/cord_ui")

# Clean old module dir on reinstall
install(CODE "
    set(_modules_dir \"\\$ENV{DESTDIR}${LOGOS_BASECAMP_DATA}/modules\")
    file(GLOB _old \"\${_modules_dir}/logos_cord*\")
    foreach(_dir \${_old})
        file(REMOVE_RECURSE \"\${_dir}\")
    endforeach()
")

install(TARGETS logos_cord_plugin LIBRARY DESTINATION "${CORD_MODULE_DIR}")
install(FILES
    modules/logos_cord/manifest.json
    modules/logos_cord/metadata.json
    modules/logos_cord/plugin_metadata.json
    modules/logos_cord/variant
    DESTINATION "${CORD_MODULE_DIR}"
)
install(FILES
    plugins/cord_ui/manifest.json
    plugins/cord_ui/metadata.json
    plugins/cord_ui/Main.qml
    plugins/cord_ui/variant
    DESTINATION "${CORD_UI_DIR}"
)
install(FILES
    assets/icons/cord.png
    DESTINATION "${CORD_UI_DIR}/icons"
    RENAME Cord_sidebar.png
)

# Patch RUNPATH so Qt libs resolve correctly when loaded from Basecamp AppImage
find_program(PATCHELF_EXECUTABLE patchelf)
if(PATCHELF_EXECUTABLE)
    install(CODE "
        set(_plugin \"${CORD_MODULE_DIR}/cord_plugin.so\")
        set(_build_so \"${CMAKE_BINARY_DIR}/cord_plugin.so\")
        if(EXISTS \"\${_plugin}\")
            execute_process(
                COMMAND bash -c \"ldd '\${_build_so}' | grep nix/store | awk '{print \\\$3}' | xargs -I{} dirname {} | sort -u | tr '\\n' ':' | sed 's/:$//'\"
                OUTPUT_VARIABLE _nix_paths
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            set(_qt_lib \"\$ENV{HOME}/Qt/6.9.3/gcc_64/lib\")
            set(_rpath \"\\\$ORIGIN:\${_nix_paths}:\${_qt_lib}:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu\")
            execute_process(
                COMMAND ${PATCHELF_EXECUTABLE} --set-rpath \"\${_rpath}\" \"\${_plugin}\"
            )
            message(STATUS \"Patched RUNPATH on cord_plugin.so\")
        endif()
    ")
endif()

endif() # LOGOS_MODULE_BUILDER_ROOT
