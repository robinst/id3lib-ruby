
module ID3Lib

  #
  # The Accessors module defines accessor methods for ID3 text frames.
  #
  # === Most used accessors
  #
  # Here's a list of the most used accessors:
  #
  # * #title
  # * #performer or #artist
  # * #album
  # * #genre or #content_type
  # * #year
  # * #track
  # * #part_of_set or #disc
  # * #comment or #comment_frames
  # * #composer
  # * #bpm
  #
  module Accessors

    def title()       frame_text(:TIT2) end
    def title=(v) set_frame_text(:TIT2, v) end

    def performer()       frame_text(:TPE1) end
    def performer=(v) set_frame_text(:TPE1, v) end
    alias artist  performer
    alias artist= performer=

    def album()       frame_text(:TALB) end
    def album=(v) set_frame_text(:TALB, v) end

    def genre()       frame_text(:TCON) end
    def genre=(v) set_frame_text(:TCON, v) end
    alias content_type  genre
    alias content_type= genre=

    def year() frame_text(:TYER) end
    def year=(v) set_frame_text(:TYER, v) end

    def track() frame_text(:TRCK) end
    def track=(v) set_frame_text(:TRCK, v) end

    def part_of_set() frame_text(:TPOS) end
    def part_of_set=(v) set_frame_text(:TPOS, v) end
    alias disc  part_of_set
    alias disc= part_of_set=

    def comment()       frame_text(:COMM) end
    def comment=(v) set_frame_text(:COMM, v) end

    # Returns an array of comment frames.
    def comment_frames() select{ |f| f[:id] == :COMM } end

    def composer()       frame_text(:TCOM) end
    def composer=(v) set_frame_text(:TCOM, v) end

    def grouping()       frame_text(:TIT1) end
    def grouping=(v) set_frame_text(:TIT1, v) end

    def bpm()       frame_text(:TBPM) end
    def bpm=(v) set_frame_text(:TBPM, v.to_s) end

    def subtitle()       frame_text(:TIT3) end
    def subtitle=(v) set_frame_text(:TIT3, v) end

    def date()       frame_text(:TDAT) end
    def date=(v) set_frame_text(:TDAT, v) end

    def time()       frame_text(:TIME) end
    def time=(v) set_frame_text(:TIME, v) end

    def language()       frame_text(:TLAN) end
    def language=(v) set_frame_text(:TLAN, v) end

    def lyrics()       frame_text(:USLT) end
    def lyrics=(v) set_frame_text(:USLT, v) end

    def lyricist()       frame_text(:TEXT) end
    def lyricist=(v) set_frame_text(:TEXT, v) end

    def band()       frame_text(:TPE2) end
    def band=(v) set_frame_text(:TPE2, v) end

    def conductor()       frame_text(:TPE3) end
    def conductor=(v) set_frame_text(:TPE3, v) end

    def interpreted_by()       frame_text(:TPE4) end
    def interpreted_by=(v) set_frame_text(:TPE4, v) end
    alias remixed_by  interpreted_by
    alias remixed_by= interpreted_by=

    def publisher()       frame_text(:TPUB) end
    def publisher=(v) set_frame_text(:TPUB, v) end

    def encoded_by()       frame_text(:TENC) end
    def encoded_by=(v) set_frame_text(:TENC, v) end

  end

end
