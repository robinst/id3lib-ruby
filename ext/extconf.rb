
require 'mkmf'

# TODO: Check the C++ stuff, not C... How?
if have_header('id3.h') and have_library('id3', 'ID3Tag_New')
  create_makefile 'id3lib_api'
end
