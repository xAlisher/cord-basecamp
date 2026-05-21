# Install script for directory: /home/alisher/basecamp/modules/cord-basecamp

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  
    set(_modules_dir "\/home/alisher/.local/share/Logos/LogosBasecamp/modules")
    file(GLOB _old "${_modules_dir}/logos_cord*")
    foreach(_dir ${_old})
        file(REMOVE_RECURSE "${_dir}")
    endforeach()

endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so"
         RPATH "$ORIGIN:$ORIGIN/../lib")
  endif()
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord" TYPE MODULE FILES "/home/alisher/basecamp/modules/cord-basecamp/build/cord_plugin.so")
  if(EXISTS "$ENV{DESTDIR}/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so"
         OLD_RPATH "/home/alisher/Qt/6.9.3/gcc_64/lib:"
         NEW_RPATH "$ORIGIN:$ORIGIN/../lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/manifest.json;/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/metadata.json;/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/plugin_metadata.json;/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/variant")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord" TYPE FILE FILES
    "/home/alisher/basecamp/modules/cord-basecamp/modules/logos_cord/manifest.json"
    "/home/alisher/basecamp/modules/cord-basecamp/modules/logos_cord/metadata.json"
    "/home/alisher/basecamp/modules/cord-basecamp/modules/logos_cord/plugin_metadata.json"
    "/home/alisher/basecamp/modules/cord-basecamp/modules/logos_cord/variant"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/alisher/.local/share/Logos/LogosBasecamp/plugins/cord_ui/manifest.json;/home/alisher/.local/share/Logos/LogosBasecamp/plugins/cord_ui/metadata.json;/home/alisher/.local/share/Logos/LogosBasecamp/plugins/cord_ui/Main.qml;/home/alisher/.local/share/Logos/LogosBasecamp/plugins/cord_ui/variant")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/alisher/.local/share/Logos/LogosBasecamp/plugins/cord_ui" TYPE FILE FILES
    "/home/alisher/basecamp/modules/cord-basecamp/plugins/cord_ui/manifest.json"
    "/home/alisher/basecamp/modules/cord-basecamp/plugins/cord_ui/metadata.json"
    "/home/alisher/basecamp/modules/cord-basecamp/plugins/cord_ui/Main.qml"
    "/home/alisher/basecamp/modules/cord-basecamp/plugins/cord_ui/variant"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/home/alisher/.local/share/Logos/LogosBasecamp/plugins/cord_ui/icons/Cord_sidebar.png")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/home/alisher/.local/share/Logos/LogosBasecamp/plugins/cord_ui/icons" TYPE FILE RENAME "Cord_sidebar.png" FILES "/home/alisher/basecamp/modules/cord-basecamp/assets/icons/cord.png")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  
        set(_plugin "/home/alisher/.local/share/Logos/LogosBasecamp/modules/logos_cord/cord_plugin.so")
        set(_build_so "/home/alisher/basecamp/modules/cord-basecamp/build/cord_plugin.so")
        if(EXISTS "${_plugin}")
            execute_process(
                COMMAND bash -c "ldd '${_build_so}' | grep nix/store | awk '{print \$3}' | xargs -I{} dirname {} | sort -u | tr '\n' ':' | sed 's/:$//'"
                OUTPUT_VARIABLE _nix_paths
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            set(_qt_lib "$ENV{HOME}/Qt/6.9.3/gcc_64/lib")
            set(_rpath "\$ORIGIN:${_nix_paths}:${_qt_lib}:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu")
            execute_process(
                COMMAND /usr/bin/patchelf --set-rpath "${_rpath}" "${_plugin}"
            )
            message(STATUS "Patched RUNPATH on cord_plugin.so")
        endif()
    
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/alisher/basecamp/modules/cord-basecamp/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
