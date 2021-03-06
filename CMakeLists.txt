project (balumpa-greeter)
cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)

enable_testing ()

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (CONF_DIR "/etc/lightdm")
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (HTML_DIR "${CMAKE_INSTALL_PREFIX}/lib/balumpa-greeter")
set (PKGDATADIR "${DATADIR}/balumpa-greeter")
set (CMAKE_INSTALL_PREFIX /usr)
set (VERSION "2.0.0")

configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_BINARY_DIR}/src/config.vala)
add_definitions (-DGETTEXT_PACKAGE="balumpa-greeter")

# Comment this out to enable C compiler warnings
add_definitions (-w)

# Add 'make dist' command for creating release tarball
set (CPACK_PACKAGE_VERSION ${VERSION})
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set (CPACK_SOURCE_IGNORE_FILES "/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")

include (CPack)
add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

find_package (PkgConfig)
pkg_check_modules (DEPS REQUIRED liblightdm-gobject-1>=1.2.1 gdk-x11-3.0 gdk-pixbuf-2.0 webkitgtk-3.0)
add_definitions (${DEPS_CFLAGS})
link_libraries (${DEPS_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS})

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.26.0" MINIMUM)

file(GLOB_RECURSE sources src/*.vala)

include (ValaPrecompile)
vala_precompile (VALA_C
    ${sources}
    ${CMAKE_BINARY_DIR}/src/config.vala
PACKAGES
    liblightdm-gobject-1
    posix
    gdk-pixbuf-2.0
    gdk-x11-3.0
    x11
    webkit-1.0
    javascriptcore
OPTIONS
    --vapidir=${CMAKE_CURRENT_SOURCE_DIR}/vapi
)

add_subdirectory (po)

include (GSettings)

add_executable (balumpa-greeter ${VALA_C})
target_link_libraries(balumpa-greeter m)

install (TARGETS balumpa-greeter RUNTIME DESTINATION sbin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/balumpa-greeter.desktop DESTINATION share/xgreeters)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/balumpa-greeter.conf DESTINATION ${CONF_DIR})
install (DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/html/ DESTINATION ${HTML_DIR})
