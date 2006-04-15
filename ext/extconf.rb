
require 'mkmf'

have_header('id3.h')
have_library('id3', 'ID3Tag_New')
create_makefile('id3lib_api')
