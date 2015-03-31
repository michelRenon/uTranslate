file(GLOB GRAPHICS_FILES *.png *.jpg *.svg)

# make the files visible in the qtcreator tree
if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
  add_custom_target(utranslate_graphics_ext_PNGFiles ALL SOURCES ${IMAGES_PNG_FILES})
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")

install(FILES ${GRAPHICS_FILES} DESTINATION ${UTRANSLATE_DIR}/graphics/ext)

