require 'mkmf'

if have_header('id3.h') and have_library('id3', 'ID3Tag_New')
  create_makefile('id3lib_api')
else
  message "You must have id3lib installed in order to use id3lib-ruby!\n"
end
