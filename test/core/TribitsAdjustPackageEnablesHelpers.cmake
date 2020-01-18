# @HEADER
# ************************************************************************
#
#            TriBITS: Tribal Build, Integrate, and Test System
#                    Copyright 2013 Sandia Corporation
#
# Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
# the U.S. Government retains certain rights in this software.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the Corporation nor the names of the
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY SANDIA CORPORATION "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL SANDIA CORPORATION OR THE
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ************************************************************************
# @HEADER

MESSAGE("The outer project: PROJECT_NAME = ${PROJECT_NAME}")
MESSAGE("The outer project: ${PROJECT_NAME}_TRIBITS_DIR = ${${PROJECT_NAME}_TRIBITS_DIR}")

SET( CMAKE_MODULE_PATH
  "${${PROJECT_NAME}_TRIBITS_DIR}/core/utils"
  "${${PROJECT_NAME}_TRIBITS_DIR}/core/package_arch"
  )


INCLUDE(PrintVar)


#####################################################################
#
# Set common/base options
#
#####################################################################

SET(PROJECT_SOURCE_DIR "${${PROJECT_NAME}_TRIBITS_DIR}/examples/MockTrilinos")
PRINT_VAR(PROJECT_SOURCE_DIR)
SET(REPOSITORY_DIR ".")
PRINT_VAR(REPOSITORY_DIR)

# Before we change the project name, we have to set the TRIBITS_DIR so that it
# will point in the right place.  There is TriBITS code being called that must
# have this variable set!

SET(Trilinos_TRIBITS_DIR ${${PROJECT_NAME}_TRIBITS_DIR})

# Set the mock project name last to override the outer project
SET(PROJECT_NAME "Trilinos")
MESSAGE("The inner test project: PROJECT_NAME = ${PROJECT_NAME}")
MESSAGE("The inner tets project: ${PROJECT_NAME}_TRIBITS_DIR = ${${PROJECT_NAME}_TRIBITS_DIR}")

# Includes

INCLUDE(TribitsReadPackageProcessDepenenciesWriteXml)
INCLUDE(TribitsAdjustPackageEnables)
INCLUDE(TribitsProcessTplsLists)
INCLUDE(UnitTestHelpers)
INCLUDE(GlobalSet)

# For Running TRIBITS_READ_PACKAGES_PROCESS_DEPENDENCIES_WRITE_XML()

SET(${PROJECT_NAME}_NATIVE_REPOSITORIES .)

SET(${PROJECT_NAME}_PACKAGES_FILE_OVERRIDE
  ${CMAKE_CURRENT_LIST_DIR}/MiniMockTrilinosFiles/PackagesList.cmake)
SET(${PROJECT_NAME}_TPLS_FILE_OVERRIDE
  ${CMAKE_CURRENT_LIST_DIR}/MiniMockTrilinosFiles/TPLsList.cmake)

SET(${PROJECT_NAME}_EXTRA_REPOSITORIES extraRepoTwoPackages)

# For running other lower-level functions

SET(REPOSITORY_NAME "Trilinos")

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/MiniMockTrilinosFiles/PackagesList.cmake)
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/MiniMockTrilinosFiles/TPLsList.cmake)

SET(EXTRA_REPO_NAME extraRepoTwoPackages)
SET(EXTRA_REPO_DIR extraRepoTwoPackages)

SET(REPOSITORY_NAME ${EXTRA_REPO_NAME})
INCLUDE(${PROJECT_SOURCE_DIR}/${EXTRA_REPO_NAME}/PackagesList.cmake)

SET(${EXTRA_REPO_NAME}_TPLS_FINDMODS_CLASSIFICATIONS)

SET(${PROJECT_NAME}_ALL_REPOSITORIES "." "${EXTRA_REPO_NAME}")

SET( ${PROJECT_NAME}_ASSERT_MISSING_PACKAGES ON )


#####################################################################
#
# Helper macros for unit tests
#
#####################################################################


MACRO(UNITTEST_HELPER_READ_PACKAGES_AND_DEPENDENCIES)

  SET(${PROJECT_NAME}_ALL_REPOSITORIES)
  TRIBITS_READ_PACKAGES_PROCESS_DEPENDENCIES_WRITE_XML()

ENDMACRO()


MACRO(UNITTEST_HELPER_READ_AND_PROCESS_PACKAGES)

  TRIBITS_PROCESS_PACKAGES_AND_DIRS_LISTS(${PROJECT_NAME} ".")
  SET(${PROJECT_NAME}_TPLS_FILE "dummy")
  TRIBITS_PROCESS_TPLS_LISTS(${PROJECT_NAME} ".")
  TRIBITS_PROCESS_PACKAGES_AND_DIRS_LISTS(${EXTRA_REPO_NAME} ${EXTRA_REPO_DIR})
  SET(${EXTRA_REPO_NAME}_TPLS_FILE "dummy")
  TRIBITS_PROCESS_TPLS_LISTS(${EXTRA_REPO_NAME} ${EXTRA_REPO_DIR})
  TRIBITS_READ_PROJECT_AND_PACKAGE_DEPENDENCIES_CREATE_GRAPH_PRINT_DEPS()
  SET_DEFAULT(${PROJECT_NAME}_ENABLE_ALL_PACKAGES OFF)
  SET_DEFAULT(${PROJECT_NAME}_ENABLE_SECONDARY_TESTED_CODE OFF)
  SET(DO_PROCESS_MPI_ENABLES ON) # Should not be needed but CMake is not working!
  FOREACH(SE_PKG ${${PROJECT_NAME}_SE_PACKAGES})
    GLOBAL_SET(${SE_PKG}_FULL_ENABLED_DEP_PACKAGES)
  ENDFOREACH()
  TRIBITS_ADJUST_PACKAGE_ENABLES(TRUE)
  TRIBITS_SET_UP_ENABLED_ONLY_DEPENDENCIES()

ENDMACRO()
