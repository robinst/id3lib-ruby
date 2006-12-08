
require 'id3lib_api'
require 'id3lib/tag'
require 'id3lib/frame'
require 'id3lib/info'


#
# This module includes all the classes and constants of id3lib-ruby and is
# the file to require.
# Have a look at ID3Lib::Tag for an introduction on how to use this library.
#
module ID3Lib
  VERSION = '0.5.0'

  # ID3 version 1. The V constants are used with the methods
  # new, update!, strip! and has_tag_type? of ID3Lib::Tag. 
  V1     = 1
  # ID3 version 2
  V2     = 2
  # No tag type
  V_NONE = 0
  # All tag types
  V_ALL  = 0xff
  # Both ID3 versions
  V_BOTH = V1 | V2

  NUM     = 0
  ID      = 1
  DESC    = 2
  FIELDS  = 3  

end
