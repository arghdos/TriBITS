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


########################################################################
# TribitsSimpleExampleApp
########################################################################


function(TribitsSimpleExampleApp_ALL_ST_test sharedOrStatic)

  if (sharedOrStatic STREQUAL "SHARED")
    set(buildSharedLibsArg -DBUILD_SHARED_LIBS=ON)
  elseif (sharedOrStatic STREQUAL "STATIC")
    set(buildSharedLibsArg -DBUILD_SHARED_LIBS=OFF)
  else()
    message(FATAL_ERROR "Invaid value for sharedOrStatic='${sharedOrStatic}'!")
  endif()

  set(testBaseName TribitsSimpleExampleApp_ALL_ST_${sharedOrStatic})
  set(testName ${PACKAGE_NAME}_${testBaseName})
  set(testDir ${CMAKE_CURRENT_BINARY_DIR}/${testName})

  tribits_add_advanced_test( ${testBaseName}
    OVERALL_WORKING_DIRECTORY TEST_NAME
    OVERALL_NUM_MPI_PROCS 1
    EXCLUDE_IF_NOT_TRUE ${PROJECT_NAME}_ENABLE_Fortran
    XHOSTTYPE Darwin

    TEST_0
      MESSAGE "Copy source for TribitsExampleProject"
      CMND ${CMAKE_COMMAND}
      ARGS -E copy_directory
        ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsExampleProject .
      WORKING_DIRECTORY TribitsExampleProject

    TEST_1
      MESSAGE "Do the configure of TribitsExampleProject"
      WORKING_DIRECTORY BUILD
      CMND ${CMAKE_COMMAND}
      ARGS
        ${TribitsExampleProject_COMMON_CONFIG_ARGS}
        -DTribitsExProj_TRIBITS_DIR=${${PROJECT_NAME}_TRIBITS_DIR}
        -DTribitsExProj_ENABLE_Fortran=ON
        -DTribitsExProj_ENABLE_ALL_PACKAGES=ON
        -DTribitsExProj_ENABLE_SECONDARY_TESTED_CODE=ON
        -DTribitsExProj_ENABLE_INSTALL_CMAKE_CONFIG_FILES=ON
        -DTPL_ENABLE_SimpleTpl=ON
        -DSimpleTpl_INCLUDE_DIRS=${SimpleTpl_install_${sharedOrStatic}_DIR}/install/include
        -DSimpleTpl_LIBRARY_DIRS=${SimpleTpl_install_${sharedOrStatic}_DIR}/install/lib
        ${buildSharedLibsArg}
        -DCMAKE_INSTALL_PREFIX=${testDir}/install
        ${testDir}/TribitsExampleProject

    TEST_2
      MESSAGE "Build and install TribitsExampleProject locally"
      WORKING_DIRECTORY BUILD
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND make ARGS ${CTEST_BUILD_FLAGS} install

    TEST_3
      MESSAGE "Delete source and build directory for TribitsExampleProject"
      CMND ${CMAKE_COMMAND} ARGS -E rm -rf TribitsExampleProject BUILD

    TEST_4
      MESSAGE "Configure TribitsSimpleExampleApp locally"
      WORKING_DIRECTORY app_build
      CMND ${CMAKE_COMMAND} ARGS
        -DCMAKE_PREFIX_PATH=${testDir}/install
        ${${PROJECT_NAME}_TRIBITS_DIR}/examples/TribitsSimpleExampleApp
      PASS_REGULAR_EXPRESSION_ALL
        "${foundProjectOrPackageStr}"
        "-- Configuring done"
        "-- Generating done"
        "-- Build files have been written to: .*/${testName}/app_build"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_5
      MESSAGE "Build TribitsSimpleExampleApp"
      WORKING_DIRECTORY app_build
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND make ARGS ${CTEST_BUILD_FLAGS}
      PASS_REGULAR_EXPRESSION_ALL
        "Built target app"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    TEST_6
      MESSAGE "Test TribitsSimpleExampleApp"
      WORKING_DIRECTORY app_build
      SKIP_CLEAN_WORKING_DIRECTORY
      CMND ${CMAKE_CTEST_COMMAND} ARGS -VV
      PASS_REGULAR_EXPRESSION_ALL
        "Full Deps: WithSubpackages:B A simpletpl headeronlytpl simpletpl headeronlytpl[;] MixedLang:Mixed Language[;] SimpleCxx:simpletpl headeronlytpl"
        "app_test [.]+   Passed"
        "100% tests passed, 0 tests failed out of 1"
      ALWAYS_FAIL_ON_NONZERO_RETURN

    ${LD_LIBRARY_PATH_HACK_FOR_SIMPLETPL_${sharedOrStatic}_ENVIRONMENT_ARG}

    ADDED_TEST_NAME_OUT ${testNameBase}_NAME
    )

  if (${testNameBase}_NAME)
    set_tests_properties(${${testNameBase}_NAME}
      PROPERTIES DEPENDS ${SimpleTpl_install_${sharedOrStatic}_NAME} )
  endif()

endfunction()


TribitsSimpleExampleApp_ALL_ST_test(STATIC)
TribitsSimpleExampleApp_ALL_ST_test(SHARED)