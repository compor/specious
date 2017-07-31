#.rst:
# FindLLVMPolly
# --------
#
# Find LLVM Polly
#
# Find LLVM Polly headers and libraries.
#
# ::
#
#   LLVMPOLLY_INCLUDE_DIR    - Where to find polly/*.h
#   LLVMPOLLY_SHARED_LIBRARY - Location of LLVM Polly shared library
#   LLVMPOLLY_STATIC_LIBRARY - Location of LLVM Polly static library
#   LLVMPOLLY_FOUND          - True if LLVM Polly found.

#=============================================================================

if(LLVMPOLLY_ROOT)
  find_path(_LLVMPOLLY_INCLUDE_DIR NAMES ScopInfo.h
    PATHS ${LLVMPOLLY_ROOT}/include/polly
    NO_DEFAULT_PATH)

  find_library(_LLVMPOLLY_SHARED_LIBRARY NAMES LLVMPolly.so
    PATHS ${LLVMPOLLY_ROOT}/lib
    NO_DEFAULT_PATH)

  find_library(_LLVMPOLLY_STATIC_LIBRARY NAMES libPolly.a
    PATHS ${LLVMPOLLY_ROOT}/lib
    NO_DEFAULT_PATH)
endif()

find_path(_LLVMPOLLY_INCLUDE_DIR NAMES polly/ScopInfo.h)
find_library(_LLVMPOLLY_SHARED_LIBRARY NAMES LLVMPolly*.so)
find_library(_LLVMPOLLY_STATIC_LIBRARY NAMES libPolly.a)

mark_as_advanced(_LLVMPOLLY_INCLUDE_DIR)
mark_as_advanced(_LLVMPOLLY_SHARED_LIBRARY)
mark_as_advanced(_LLVMPOLLY_STATIC_LIBRARY)


# handle the QUIETLY and REQUIRED arguments and set LLVMPOLLY_FOUND to TRUE
# if all listed variables are TRUE
include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(LLVMPOLLY
  REQUIRED_VARS
  _LLVMPOLLY_SHARED_LIBRARY _LLVMPOLLY_STATIC_LIBRARY _LLVMPOLLY_INCLUDE_DIR)

if(LLVMPOLLY_FOUND)
  set(LLVMPOLLY_INCLUDE_DIR ${_LLVMPOLLY_INCLUDE_DIR})
  set(LLVMPOLLY_SHARED_LIBRARY ${_LLVMPOLLY_SHARED_LIBRARY})
  set(LLVMPOLLY_STATIC_LIBRARY ${_LLVMPOLLY_STATIC_LIBRARY})
endif()

