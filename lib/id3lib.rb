
require 'id3lib_api'
require 'id3lib/info'
require 'id3lib/accessors'


#
# This module includes all the classes and constants of id3lib-ruby.
# Have a look at ID3Lib::Tag for an introduction on how to use this library.
#
module ID3Lib
  VERSION = '0.5.0'

  # ID3 version 1. All V constants can be used with the methods
  # new, update! or strip! of ID3Lib::Tag. 
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

  #
  # This class is the main frontend of the library.
  # Use it to read and write ID3 tag data of files.
  #
  # === Example of use
  #
  #    tag = ID3Lib::Tag.new('shy_boy.mp3')
  #
  #    # Remove comments
  #    tag.delete_if{ |frame| frame[:id] == :COMM }
  #
  #    # Set year
  #    tag.year   #=> 2000
  #    tag.year = 2005
  #
  #    # Apply changes
  #    tag.update!
  #
  # === Working with tags
  #
  # You can use a ID3Lib::Tag object like an array. In fact, it is a subclass
  # of Array. An ID3Lib::Tag contains frames which are stored as hashes,
  # with field IDs as keys and field values as values. The frame IDs like TIT2
  # are the ones specified by the ID3 standard. If you don't know these IDs,
  # you probably want to use the accessor methods described afterwards, which
  # have a more natural naming.
  #
  #    tag.each do |frame|
  #      p frame
  #    end
  #    #=> {:id => :TIT2, :text => "Shy Boy", :textenc => 0}
  #    #=> {:id => :TPE1, :text => "Katie Melua", :textenc => 0}
  #    #=> {:id => :TALB, :text => "Piece By Piece", :textenc => 0}
  #    #=> {:id => :TRCK, :text => "1/12", :textenc => 0}
  #    #=> {:id => :TYER, :text => "2005", :textenc => 0}
  #    #=> {:id => :TCON, :text => "Jazz/Blues", :textenc => 0}
  #
  # === Get and set frames
  #
  # There are a number of accessors for text frames like
  # title, performer, album, track, year, comment and genre. Have a look
  # at ID3Lib::Accessors for a complete list.
  #
  #    tag.title    #=> "Shy Boi"
  #
  #    tag.title = 'Shy Boy'
  #    tag.title    #=> "Shy Boy"
  #
  #    tag.track    #=> [1,12]
  #    tag.year     #=> 2005
  #
  # You can always read and write the raw text if you want. You just have
  # to use the "manual access". It is generally encouraged to use the
  # #frame_text method where possible, because the other two result in
  # an exception when the frame isn't found.
  #
  #    tag.frame_text(:TRCK)                  #=> "1/12"
  #    tag.frame_text(:TLAN)                  #=> nil
  #
  #    tag.frame(:TRCK)[:text]                #=> "1/12"
  #    # Raises an exception, because nil[:text] isn't possible:
  #    tag.frame(:TLAN)[:text]
  #
  #    tag.find{ |f| f[:id] == :TRCK }[:text] #=> "1/12"
  #    # Also raises an exception:
  #    tag.find{ |f| f[:id] == :TLAN }[:text]
  #
  # Because only text frames can be set with accessors, you have to add
  # special frames by hand.
  #
  #    # Add two comments
  #    tag << {:id => :COMM, :text => 'chunky bacon'}
  #    tag << {:id => :COMM, :text => 'really.'}
  #
  #    # Add an attached picture
  #    cover = {
  #      :id          => :APIC,
  #      :mimetype    => 'image/jpeg',
  #      :picturetype => 3,
  #      :description => 'A pretty picture',
  #      :textenc     => 0,
  #      :data        => File.read('cover.jpg')
  #    }
  #    tag << cover
  #
  # === Get information about frames
  #
  # In the last example we added an APIC frame. How can we know what data
  # we have to store in the APIC hash?
  #
  #    ID3Lib::Info.frame(:APIC)[3]
  #    #=> [:textenc, :mimetype, :picturetype, :description, :data]
  #
  # We see, the last element of the info array obtained through
  # ID3Lib::Info.frame is an array of field IDs needed by APIC.
  #
  # Have a look at the ID3Lib::Info module for detailed information.
  #
  # === Write changes to file
  #
  # When you've finished modifying a tag, don't forget to call #update! to
  # write the modifications back to the file. You have to check the return
  # value of update!, it returns nil on failure. This probably means that
  # the file is not writeable or cannot be created.
  #
  #    tag.update!
  #
  # === Getting rid of a tag
  #
  # Use the #strip! method to completely remove a tag from a file.
  #
  #    tag.strip!
  #
  class Tag < Array

    include Accessors

    attr_accessor :padding

    #
    # Create a new Tag. When a _filename_ is supplied, the tag of the file
    # is read. _tagtype_ specifies the tag type to read and defaults to
    # V_ALL.
    # Use one of ID3Lib::V1, ID3Lib::V2, ID3Lib::V_BOTH or ID3Lib::V_ALL.
    #
    #    tag = ID3Lib::Tag.new('shy_boy.mp3')
    # 
    # Only read ID3v1 tag:
    #
    #    id3v1_tag = ID3Lib::Tag.new('piece_by_piece.mp3', ID3Lib::V1)
    #
    def initialize(filename, readtype=V_ALL)
      @filename = filename
      @readtype = readtype
      @padding = true

      @tag = API::Tag.new
      @tag.link(@filename, @readtype)
      read_frames
    end

    #
    # Returns an estimate of the number of bytes required to store the tag
    # data.
    #
    def size
      @tag.size
    end

    #
    # Simple shortcut for getting a frame by its _id_.
    #
    #    tag.frame(:TIT2)
    #    #=> {:id => :TIT2, :text => "Shy Boy", :textenc => 0}
    #
    # is the same as:
    #
    #    tag.find{ |f| f[:id] == :TIT2 }
    #
    def frame(id)
      find{ |f| f[:id] == id }
    end

    #
    # Get the text of a frame specified by _id_. Returns nil if the
    # frame can't be found.
    #
    #    tag.find{ |f| f[:id] == :TIT2 }[:text]  #=> "Shy Boy"
    #    tag.frame_text(:TIT2)                   #=> "Shy Boy"
    #
    #    tag.find{ |f| f[:id] == :TLAN }         #=> nil
    #    tag.frame_text(:TLAN)                   #=> nil
    #
    def frame_text(id)
      f = frame(id)
      f ? f[:text] : nil
    end

    #
    # Set the text of a frame. First, all frames with the specified _id_ are
    # deleted and then a new frame with _text_ is appended.
    #
    #    tag.set_frame_text(:TLAN, 'eng')
    #
    def set_frame_text(id, text)
      remove_frame(id)
      if text
        self << { :id => id, :text => text.to_s }
      end
    end

    #
    # Remove all frames with the specified _id_.
    #
    def remove_frame(id)
      delete_if{ |f| f[:id] == id }
    end

    #
    # Updates the tag. This change can't be undone. _writetype_ specifies
    # which tag type to write and defaults to _readtype_ (see #new).
    #
    # Invalid frames or frame data is ignored. Use #invalid_frames before
    # update! if you want to know if you have invalid data.
    #
    # Returns a number corresponding to the written tag type(s) or nil if
    # the update failed.
    #
    #    tag.update!
    #    id3v1_tag.update!(ID3Lib::V1)
    #
    def update!(writetype=@readtype)
      @tag.strip(writetype)
      # The following two lines are necessary because of the weird
      # behaviour of id3lib.
      @tag.clear
      @tag.link(@filename, writetype)

      delete_if do |frame|
        frame_info = Info.frame(frame[:id])
        next true if not frame_info
        libframe = API::Frame.new(frame_info[NUM])
        Frame.write(frame, libframe)
        @tag.add_frame(libframe)
        false
      end

      @tag.set_padding(@padding)
      tags = @tag.update(writetype)
      return tags == 0 ? nil : tags
    end

    #
    # Strip tag from file. This is dangerous because you lose all tag
    # information. Specify _striptag_ to only strip a certain tag type.
    # You don't have to call #update! after #strip!.
    #
    #    tag.strip!
    #    another_tag.strip!(ID3Lib::V1)
    #
    def strip!(striptype=V_ALL)
      clear
      tags = @tag.strip(striptype)
      @tag.clear
      @tag.link(@filename, @readtype)
      tags
    end

    #
    # Check if there is a tag of type _type_.
    # 
    def has_tag?(type=V2)
      @tag.link(@filename, V_ALL)
      @tag.has_tag_type(type)
    end

    #
    # Returns an Array of invalid frames and fields. If a frame ID is
    # invalid, it alone is in the resulting array. If a frame ID is valid
    # but has invalid fields, the frame ID and the invalid field IDs are
    # included.
    #
    #    tag.invalid_frames
    #    #=> [ [:TITS], [:TALB, :invalid] ]
    #
    def invalid_frames
      invalid = []
      each do |frame|
        if not info = Info.frame(frame[:id])
          # Frame ID doesn't exist.
          invalid << [frame[:id]]
          next
        end
        # Frame ID is ok, but are all fields ok?
        invalid_fields = frame.keys.reject { |id|
          info[FIELDS].include?(id) or id == :id
        }
        if not invalid_fields.empty?
          invalid << [frame[:id], *invalid_fields]
        end
      end
      invalid.empty? ? nil : invalid
    end

    private

    def read_frames
      iterator = @tag.create_iterator
      while libframe = iterator.get_next
        self << Frame.read(libframe)
      end
    end

  end


  module Frame #:nodoc:

    def self.read(libframe)
      frame = {}
      info = Info.frame_num(libframe.get_id)
      frame[:id] = info[ID]

      info[FIELDS].each do |field_id|
        libfield = field(libframe, field_id)
        unless libfield
          warn "id3lib-ruby: Invalid field #{field_id.inspect} in " \
               "#{frame[:id].inspect}, please report this as a bug."
          next
        end
        frame[field_id] =
          case Info::FieldType[libfield.get_type]
          when :integer
            libfield.get_integer
          when :binary
            libfield.get_binary
          when :text
            if libfield.get_encoding > 0
              libfield.get_unicode
            else
              libfield.get_ascii
            end
          end
      end

      frame
    end

    def self.write(frame, libframe)
      if textenc = frame[:textenc]
        field(libframe, :textenc).set_integer(textenc)
      end

      frame.each do |field_id, value|
        next if field_id == :textenc
        unless Info.frame(frame[:id])[FIELDS].include?(field_id)
          # Ignore invalid fields
          next
        end

        libfield = field(libframe, field_id)
        next unless libfield
        case Info::FieldType[libfield.get_type]
        when :integer
          libfield.set_integer(value)
        when :binary
          libfield.set_binary(value)
        when :text
          if textenc and textenc > 0 and
             [:text, :description, :filename].include?(field_id)
            # Special treatment for Unicode
            libfield.set_encoding(textenc)
            libfield.set_unicode(value)
          else
            libfield.set_ascii(value)
          end
        end
      end
    end

    def self.field(libframe, id)
      libframe.get_field(Info.field(id)[NUM])
    end

  end


end
