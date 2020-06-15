# Find the Pytorch root and use the provided cmake module
#
# The following variables will be set:
# - Pytorch_FOUND
# - Pytorch_VERSION
# - Pytorch_ROOT
# - Pytorch_DEFINITIONS
#
# This script will call find_package( Torch ) which will define:
# - TORCH_FOUND
# - TORCH_INCLUDE_DIRS
# - TORCH_LIBRARIES
# - TORCH_CXX_FLAGS
#
# and import the target 'torch'.

if(NOT Pytorch_FOUND)
    # Searching for pytorch requires the python executable
    find_package(PythonExecutable REQUIRED)

    message(STATUS "Getting Pytorch properties ...")

    # Get Pytorch_VERSION
    execute_process(
        COMMAND ${PYTHON_EXECUTABLE} "-c"
                "import torch; print(torch.__version__, end='')"
        OUTPUT_VARIABLE Pytorch_VERSION)

    # Get Pytorch_ROOT
    execute_process(
        COMMAND
            ${PYTHON_EXECUTABLE} "-c"
            "import os; import torch; print(os.path.dirname(torch.__file__), end='')"
        OUTPUT_VARIABLE Pytorch_ROOT)

    # Use the cmake config provided by torch
    find_package(Torch REQUIRED PATHS "${Pytorch_ROOT}/share/cmake/Torch"
                 NO_DEFAULT_PATH)

    # Note: older versions of Pytorch have hard-coded cuda library paths, see:
    # https://github.com/pytorch/pytorch/issues/15476. For PyTorch version >=
    # 1.4.0 this has been addressed.

    # Get Pytorch_CXX11_ABI: True/False
    execute_process(
        COMMAND
            ${PYTHON_EXECUTABLE} "-c"
            "import torch; print(torch._C._GLIBCXX_USE_CXX11_ABI, end='')"
        OUTPUT_VARIABLE Pytorch_CXX11_ABI
    )
endif()

message(STATUS "Pytorch         version: ${Pytorch_VERSION}")
message(STATUS "               root dir: ${Pytorch_ROOT}")
message(STATUS "          compile flags: ${TORCH_CXX_FLAGS}")
message(STATUS "          use cxx11 abi: ${Pytorch_CXX11_ABI}")
foreach(idir ${TORCH_INCLUDE_DIRS})
    message(STATUS "           include dirs: ${idir}")
endforeach(idir)
foreach(lib ${TORCH_LIBRARIES})
    message(STATUS "              libraries: ${lib}")
endforeach(lib)

# Check if the c++11 ABI is compatible
if((Pytorch_CXX11_ABI AND (NOT GLIBCXX_USE_CXX11_ABI)) OR
   (NOT Pytorch_CXX11_ABI AND GLIBCXX_USE_CXX11_ABI))
    message(FATAL_ERROR "PyTorch and Open3D ABI mismatch: ${Pytorch_CXX11_ABI} != ${GLIBCXX_USE_CXX11_ABI}")
else()
    message(STATUS "PyTorch matches Open3D ABI: ${Pytorch_CXX11_ABI} == ${GLIBCXX_USE_CXX11_ABI}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pytorch DEFAULT_MSG Pytorch_VERSION
                                  Pytorch_ROOT)
