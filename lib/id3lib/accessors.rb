
module ID3Lib
  
  #
  # The Accessors module defines accessor methods for ID3 text frames.
  #
  # Have a look at the source code to see the ID3 frame ID behind an accessor.
  #
  # === Most used accessors
  #
  # Here's a list of the probably most used accessors:
  #
  # * #title
  # * #performer or #artist
  # * #album
  # * #genre
  # * #year
  # * #track
  # * #part_of_set or #disc
  # * #comment or #comment_frames
  # * #composer
  # * #bpm
  #
  # === Automatic conversion
  #
  # Some accessors automatically convert the raw text to a more
  # suitable type (when reading) and back (when writing). For example,
  # the track information is converted to an array of one or two items.
  #
  #    tag.track    #=> [1,12]
  #
  # and the year is an integer.
  #
  #    tag.year     #=> 2005
  #
  # Use the Tag#frame_text method to get the raw text.
  #
  #    tag.frame_text(:TRCK)  #=> "1/12"
  #
  module Accessors
    
    def title()       frame_text(:TIT2) end
    def title=(v) set_frame_text(:TIT2, v) end
    
    def performer()       frame_text(:TPE1) end
    def performer=(v) set_frame_text(:TPE1, v) end
    alias_method :artist, :performer
    alias_method :artist=, :performer=
    
    def album()       frame_text(:TALB) end
    def album=(v) set_frame_text(:TALB, v) end
    
    def comment()       frame_text(:COMM) end
    def comment=(v) set_frame_text(:COMM, v) end
    
    def genre()       frame_text(:TCON) end
    def genre=(v) set_frame_text(:TCON, v) end
    alias_method :content_type, :genre
    alias_method :content_type=, :genre=
    
    def bpm()       frame_text(:TBPM) end
    def bpm=(v) set_frame_text(:TBPM, v.to_s) end
    
    def composer()       frame_text(:TCOM) end
    def composer=(v) set_frame_text(:TCOM, v) end
    
    def copyright()       frame_text(:TCOP) end
    def copyright=(v) set_frame_text(:TCOP, v) end
    
    def date()       frame_text(:TDAT) end
    def date=(v) set_frame_text(:TDAT, v) end
    
    def encoding_time()       frame_text(:TDEN) end
    def encoding_time=(v) set_frame_text(:TDEN, v) end
    
    def playlist_delay()       frame_text(:TDLY) end
    def playlist_delay=(v) set_frame_text(:TDLY, v) end
    
    def original_release_time()       frame_text(:TDOR) end
    def original_release_time=(v) set_frame_text(:TDOR, v) end
    
    def recording_time()       frame_text(:TDRC) end
    def recording_time=(v) set_frame_text(:TDRC, v) end
    
    def release_time()       frame_text(:TDRL) end
    def release_time=(v) set_frame_text(:TDRL, v) end
    
    def tagging_time()       frame_text(:TDTG) end
    def tagging_time=(v) set_frame_text(:TDTG, v) end
    
    def involved_people()       frame_text(:TIPL) end
    def involved_people=(v) set_frame_text(:TIPL, v) end
    
    def encoded_by()       frame_text(:TENC) end
    def encoded_by=(v) set_frame_text(:TENC, v) end
    
    def lyricist()       frame_text(:TEXT) end
    def lyricist=(v) set_frame_text(:TEXT, v) end
    
    def file_type()       frame_text(:TFLT) end
    def file_type=(v) set_frame_text(:TFLT, v) end
    
    def time()       frame_text(:TIME) end
    def time=(v) set_frame_text(:TIME, v) end
    
    def content_group()       frame_text(:TIT1) end
    def content_group=(v) set_frame_text(:TIT1, v) end
    
    def subtitle()       frame_text(:TIT3) end
    def subtitle=(v) set_frame_text(:TIT3, v) end
    
    def initial_key()       frame_text(:TKEY) end
    def initial_key=(v) set_frame_text(:TKEY, v) end
    
    def language()       frame_text(:TLAN) end
    def language=(v) set_frame_text(:TLAN, v) end
    
    def audio_length()       frame_text(:TLEN) end
    def audio_length=(v) set_frame_text(:TLEN, v) end
    
    def musician_credits()       frame_text(:TMCL) end
    def musician_credits=(v) set_frame_text(:TMCL, v) end
    
    def media_type()       frame_text(:TMED) end
    def media_type=(v) set_frame_text(:TMED, v) end
    
    def mood()       frame_text(:TMOO) end
    def mood=(v) set_frame_text(:TMOO, v) end
    
    def original_title()       frame_text(:TOAL) end
    def original_title=(v) set_frame_text(:TOAL, v) end
    
    def original_filename()       frame_text(:TOFN) end
    def original_filename=(v) set_frame_text(:TOFN, v) end
    
    def original_lyricist()       frame_text(:TOLY) end
    def original_lyricist=(v) set_frame_text(:TOLY, v) end
    
    def original_performer()       frame_text(:TOPE) end
    def original_performer=(v) set_frame_text(:TOPE, v) end
    
    def file_owner()       frame_text(:TOWN) end
    def file_owner=(v) set_frame_text(:TOWN, v) end
    
    def band()       frame_text(:TPE2) end
    def band=(v) set_frame_text(:TPE2, v) end
    
    def conductor()       frame_text(:TPE3) end
    def conductor=(v) set_frame_text(:TPE3, v) end
    
    def produced_notice()       frame_text(:TPRO) end
    def produced_notice=(v) set_frame_text(:TPRO, v) end
    
    def publisher()       frame_text(:TPUB) end
    def publisher=(v) set_frame_text(:TPUB, v) end
    
    def internet_radio_station()       frame_text(:TRSN) end
    def internet_radio_station=(v) set_frame_text(:TRSN, v) end
    
    def internet_radio_owner()       frame_text(:TRSO) end
    def internet_radio_owner=(v) set_frame_text(:TRSO, v) end
    
    def album_sort_order()       frame_text(:TSOA) end
    def album_sort_order=(v) set_frame_text(:TSOA, v) end
    
    def performer_sort_order()       frame_text(:TSOP) end
    def performer_sort_order=(v) set_frame_text(:TSOP, v) end
    
    def title_sort_order()       frame_text(:TSOT) end
    def title_sort_order=(v) set_frame_text(:TSOT, v) end
    
    def isrc()       frame_text(:TSRC) end
    def isrc=(v) set_frame_text(:TSRC, v) end
    
    def encoder_settings()       frame_text(:TSSE) end
    def encoder_settings=(v) set_frame_text(:TSSE, v) end
    
    def set_subtitle()       frame_text(:TSST) end
    def set_subtitle=(v) set_frame_text(:TSST, v) end
    
    def terms_of_use()       frame_text(:TPE2) end
    def terms_of_use=(v) set_frame_text(:TPE2, v) end
    
    def commercial_url()       frame_text(:WCOM) end
    def commercial_url=(v) set_frame_text(:WCOM, v) end
    
    def copyright_url()       frame_text(:WCOP) end
    def copyright_url=(v) set_frame_text(:WCOP, v) end
    
    def audio_file_url()       frame_text(:WOAF) end
    def audio_file_url=(v) set_frame_text(:WOAF, v) end
    
    def performer_url()       frame_text(:WOAR) end
    def performer_url=(v) set_frame_text(:WOAR, v) end
    
    def audio_source_url()       frame_text(:WOAS) end
    def audio_source_url=(v) set_frame_text(:WOAS, v) end
    
    def internet_radio_url()       frame_text(:WORS) end
    def internet_radio_url=(v) set_frame_text(:WORS, v) end
    
    def payment_url()       frame_text(:WPAY) end
    def payment_url=(v) set_frame_text(:WPAY, v) end
    
    def publisher_url()       frame_text(:WPUB) end
    def publisher_url=(v) set_frame_text(:WPUB, v) end
    
    # Returns an array of comment frames.
    def comment_frames() select{ |f| f[:id] == :COMM } end
    
    #
    # Returns an array of one or two numbers.
    #
    #    tag.track                #=> [3,11]
    #    tag.frame_text(:TRCK)    #=> "3/11"
    #
    #    tag_2.track              #=> [5]
    #    tag_2.frame_text(:TRCK)  #=> "5"
    #
    def track() frame_text(:TRCK).split('/').collect{ |s| s.to_i } end
    
    #
    # Assign either an array or a string.
    #
    #    tag.track = [4,11]
    #    tag.track = [5]
    #    tag.track = "4/11"
    #
    def track=(v) set_frame_text(:TRCK, (v.join('/') rescue v.to_s)) end
    
    #
    # Returns an array of one or two numbers like #track.
    #
    def part_of_set() frame_text(:TPOS).split('/').collect{ |s| s.to_i } end
    alias_method :disc, :part_of_set
    
    #
    # Assign either an array or a string like #track=.
    #
    def part_of_set=(v) set_frame_text(:TPOS, (v.join('/') rescue v.to_s)) end
    alias_method :disc=, :part_of_set=
        
    #
    # Returns a number.
    #
    #    tag.year   #=> 2004
    #
    def year() frame_text(:TYER).to_i end
    
    #
    # Assign a number or a string.
    #
    #    tag.year = 2005
    #    tag.year = "2005"
    #
    def year=(v) set_frame_text(:TYER, v.to_s) end
            
  end
  
end
