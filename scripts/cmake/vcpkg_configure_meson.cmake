function(vcpkg_configure_meson)
    cmake_parse_arguments(_vcm "" "SOURCE_PATH" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})
    
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    
    # use the same compiler options as in vcpkg_configure_cmake
    set(MESON_COMMON_CFLAGS "${MESON_COMMON_CFLAGS} /DWIN32 /D_WINDOWS /W3 /utf-8")
    set(MESON_COMMON_CXXFLAGS "${MESON_COMMON_CXXFLAGS} /DWIN32 /D_WINDOWS /W3 /utf-8 /GR /EHsc")
    
    if(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL dynamic)
        set(MESON_DEBUG_CFLAGS "${MESON_DEBUG_CFLAGS} /D_DEBUG /MDd /Zi /Ob0 /Od /RTC1")
        set(MESON_DEBUG_CXXFLAGS "${MESON_DEBUG_CXXFLAGS} /D_DEBUG /MDd /Zi /Ob0 /Od /RTC1")
        
        set(MESON_RELEASE_CFLAGS "${MESON_RELEASE_CFLAGS} /MD /O2 /Oi /Gy /DNDEBUG /Zi")
        set(MESON_RELEASE_CXXFLAGS "${MESON_RELEASE_CXXFLAGS} /MD /O2 /Oi /Gy /DNDEBUG /Zi")
    elseif(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL static)
        set(MESON_DEBUG_CFLAGS "${MESON_DEBUG_CFLAGS} /D_DEBUG /MTd /Zi /Ob0 /Od /RTC1")
        set(MESON_DEBUG_CXXFLAGS "${MESON_DEBUG_CXXFLAGS} /D_DEBUG /MTd /Zi /Ob0 /Od /RTC1")
        
        set(MESON_RELEASE_CFLAGS "${MESON_RELEASE_CFLAGS} /MT /O2 /Oi /Gy /DNDEBUG /Zi")
        set(MESON_RELEASE_CXXFLAGS "${MESON_RELEASE_CXXFLAGS} /MT /O2 /Oi /Gy /DNDEBUG /Zi")
    endif()
    
    set(MESON_COMMON_LDFLAGS "${MESON_COMMON_LDFLAGS} /DEBUG")
    set(MESON_RELEASE_LDFLAGS "${MESON_RELEASE_LDFLAGS} /INCREMENTAL:NO /OPT:REF /OPT:ICF")
    
    # select meson cmd-line options
    list(APPEND _vcm_OPTIONS --buildtype plain --backend ninja)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        list(APPEND _vcm_OPTIONS --default-library shared)
    else()
        list(APPEND _vcm_OPTIONS --default-library static)
    endif()
    
    list(APPEND _vcm_OPTIONS_DEBUG --prefix ${CURRENT_PACKAGES_DIR}/debug --includedir ../include)
    list(APPEND _vcm_OPTIONS_RELEASE --prefix  ${CURRENT_PACKAGES_DIR})
    
    vcpkg_find_acquire_program(MESON)
    vcpkg_find_acquire_program(NINJA)
    get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NINJA_PATH}")

    # configure release
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    set(ENV{CFLAGS} "${MESON_COMMON_CFLAGS} ${MESON_RELEASE_CFLAGS}")
    set(ENV{CXXFLAGS} "${MESON_COMMON_CXXFLAGS} ${MESON_RELEASE_CXXFLAGS}")
    set(ENV{LDFLAGS} "${MESON_COMMON_LDFLAGS} ${MESON_RELEASE_LDFLAGS}")
    set(ENV{CPPFLAGS} "${MESON_COMMON_CPPFLAGS} ${MESON_RELEASE_CPPFLAGS}")
    vcpkg_execute_required_process(
        COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_RELEASE} ${_vcm_SOURCE_PATH}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME config-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done")
    
    # configure debug
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    set(ENV{CFLAGS} "${MESON_COMMON_CFLAGS} ${MESON_DEBUG_CFLAGS}")
    set(ENV{CXXFLAGS} "${MESON_COMMON_CXXFLAGS} ${MESON_DEBUG_CXXFLAGS}")
    set(ENV{LDFLAGS} "${MESON_COMMON_LDFLAGS} ${MESON_DEBUG_LDFLAGS}")
    set(ENV{CPPFLAGS} "${MESON_COMMON_CPPFLAGS} ${MESON_DEBUG_CPPFLAGS}")
    vcpkg_execute_required_process(
        COMMAND ${MESON} ${_vcm_OPTIONS} ${_vcm_OPTIONS_DEBUG} ${_vcm_SOURCE_PATH}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME config-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done")

endfunction()
