# Default opt dirs to help mkmf find id3lib
configure_args = "--with-opt-dir=/usr/local:/opt/local:/sw "
ENV['CONFIGURE_ARGS'] = configure_args + ENV.fetch('CONFIGURE_ARGS', "")

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

# This is only necessary for linking on Windows (don't ask me why).
have_library('iconv')

unless have_header('id3.h') and have_library('id3')
  error "You must have id3lib installed in order to use id3lib-ruby."
end

create_makefile('id3lib_api')
