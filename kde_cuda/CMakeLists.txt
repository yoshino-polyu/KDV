# Minimum version of CMake required.
cmake_minimum_required(VERSION 3.18)

# 设置项目名称和支持的语言
project(KDEPROJECT LANGUAGES CXX CUDA)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置 CUDA 标准
set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# 指定 CUDA 架构 (对应 sm_86)
set(CMAKE_CUDA_ARCHITECTURES 86)

# 指定 CUDA 编译器路径
set(CMAKE_CUDA_COMPILER /usr/local/cuda/bin/nvcc)

# 设置可执行文件的输出目录为 bin/
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# 包含 CUDA 的头文件目录
include_directories(/usr/local/cuda/include ${CUDA_INCLUDE_DIRS})

# 包含 ParallelUtils.cmake 文件
include(ParallelUtils.cmake)

##########################################################
# 配置构建类型
##########################################################
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Release" "Debug" "RelWithDebugInfo" "MinSizeRel")

##########################################################
# 启用 CUDA 支持并配置相关选项
##########################################################

# 覆盖 CUDA_DEVICE_VERSION 以匹配当前架构
# 确保 ParallelUtils.cmake 中的 CUDA_DEVICE_VERSION 列表包含 "86"
set(CUDA_DEVICE_VERSION "86" CACHE STRING "CUDA Device Version" FORCE)
set_property(CACHE CUDA_DEVICE_VERSION PROPERTY STRINGS "10" "11" "12" "13" "20" "21" "30" "32" "35" "37" "50" "52" "86")

##########################################################
# 添加 CUDA 可执行文件
##########################################################

# 1. 无优化
add_executable(kde_cuda_old kde_cuda_old.cu)

# 2. 部分优化（避免重新计算边缘修正因子）
add_executable(kde_cuda kde_cuda.cu)

# 3. 完全优化（避免重新计算边缘修正因子和 kd-tree 索引）
add_executable(kde_cuda_kdtr kde_cuda_kdtr.cu KDtree.cu CUDA_KDtree.cu)

##########################################################
# 设置目标属性和编译选项
##########################################################

# 为所有 CUDA 可执行文件设置编译标志和 CUDA 标准
foreach(target kde_cuda_old kde_cuda kde_cuda_kdtr)
    set_target_properties(${target} PROPERTIES
        CUDA_STANDARD 20
        CUDA_STANDARD_REQUIRED ON
        CUDA_ARCHITECTURES 86
        COMPILE_FLAGS "-O3"
        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    )
endforeach()


# 如果需要，可以添加其他编译定义或链接库
# 例如：
# target_compile_definitions(kde_cuda PRIVATE SOME_DEFINE)
# target_link_libraries(kde_cuda PRIVATE some_library)