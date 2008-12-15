require 'mkmf'

def error msg
  message msg + "\n"
  abort
end

unless have_library('stdc++')
  error "You must have libstdc++ installed."
end

unless have_library('z')
  error "You must have zlib installed."
end

unless have_header('id3.h') and have_library('id3', 'ID3Tag_New')
  error "You must have id3lib installed in order to use id3lib-ruby."
end

create_makefile('id3lib_api')
