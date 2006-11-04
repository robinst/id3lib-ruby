
require 'id3lib_api'
require 'id3lib/info'
require 'id3lib/accessors'


#
# This module includes all the classes and constants of id3lib-ruby.
# Have a look at ID3Lib::Tag for an introduction on how to use this library.
#
module ID3Lib

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
  # Use Tag.strip! to completely remove a tag from a file.
  #
  #    ID3Lib::Tag.strip!("urami_bushi.mp3")
  #
  class Tag < Array

    #
    # Strips tag(s) from file. Use the second parameter _type_ to only
    # strip a certain tag type. Default is to strip all types.
    #
    # Returns a number (see the constants beginning with V in ID3Lib)
    # representing the tag type(s) actually stripped from the file.
    #
    #   ID3Lib::Tag.strip!("misirlou.mp3")  #=> 3 (1 and 2 were stripped)
    #   ID3Lib::Tag.strip!("misirlou.mp3")  #=> 0 (nothing stripped)
    #
    def self.strip!(filename, type=V_ALL)
      tag = API::Tag.new
      tag.link(filename, type)
      return tag.strip(type)
    end


    include Accessors

    attr_accessor :padding

    #
    # Returns a tag object and tries to read and parse _filename_.
    # _tagtype_ specifies the tag type to read and defaults to V_ALL.
    # Use one of ID3Lib::V1, ID3Lib::V2, ID3Lib::V_BOTH or ID3Lib::V_ALL.
    #
    #   tag_a = ID3Lib::Tag.new('shy_boy.mp3')
    #   tag_b = ID3Lib::Tag.new('piece_by_piece.mp3', ID3Lib::V1)
    #
    def initialize(filename, read_type=V_ALL)
      @filename = filename
      @read_type = read_type
      @padding = true

      @tag = API::Tag.new
      @tag.link(@filename, @read_type)
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
    #   tag.frame(:TIT2)
    #   #=> {:id => :TIT2, :text => "Shy Boy", :textenc => 0}
    #
    # is the same as:
    #
    #   tag.find{ |f| f[:id] == :TIT2 }
    #
    def frame(id)
      find{ |f| f.id == id }
    end

    #
    # Get the text of a frame specified by _id_. Returns nil if the
    # frame can't be found.
    #
    #   tag.find{ |f| f[:id] == :TIT2 }[:text]  #=> "Shy Boy"
    #   tag.frame_text(:TIT2)                   #=> "Shy Boy"
    #
    #   tag.find{ |f| f[:id] == :TLAN }         #=> nil
    #   tag.frame_text(:TLAN)                   #=> nil
    #
    def frame_text(id)
      f = frame(id)
      f ? f.text : nil
    end

    #
    # Set the text of a frame. First, all frames with the specified _id_ are
    # deleted and then a new frame with _text_ is appended.
    #
    #   tag.set_frame_text(:TLAN, 'eng')
    #
    def set_frame_text(id, text)
      remove_frame(id)
      if text
        f = Frame.new(id)
        f.text = text.to_s
        self << f
      end
    end

    #
    # Remove all frames with the specified _id_.
    #
    def remove_frame(id)
      delete_if{ |f| f.id == id }
    end

    #
    # Updates the tag. This change can't be undone. _write_type_ specifies
    # which tag type to write and defaults to _read_type_ (see #new).
    #
    # Returns a number corresponding to the written tag type(s) or nil if
    # the update failed.
    #
    #   tag.update!
    #   id3v1_tag.update!(ID3Lib::V1)
    #
    def update!(write_type=@read_type)
      remove_all_api_frames

      each do |frame|
        api_frame = frame.write_api_frame
        @tag.add_frame(api_frame)
      end

      @tag.set_padding(@padding)
      tags_written = @tag.update(write_type)
      return tags_written == 0 ? nil : tags_written
    end

    #
    # Checks if a V1 or V2 tag has been encountered when the file was read
    # during object initialisation.
    #
    #   ID3Lib::Tag.new("was_besonderes.mp3").has_tag?
    #   #=> true (there is a ID3v1 or v2 tag)
    #
    # The note at has_tag_type? applies here too.
    #
    def has_tag?
      @tag.has_tag_type(V1) or @tag.has_tag_type(V2)
    end

    #
    # Checks if a tag of type _type_ has been encountered when the file was
    # read during object initialisation. Use one of the constants beginning
    # with V in ID3Lib for _type_.
    #
    #   tag = ID3Lib::Tag.new("et_pourtant.mp3")
    #   tag.has_tag_type?(ID3Lib::V1)  #=> false
    #   tag.has_tag_type?(ID3Lib::V2)  #=> true
    # 
    # Note: The result of this method depends on the used read_type
    # parameter of #new at the creation of the Tag object. When #new was
    # called with a read_type of ID3Lib::V1, then only a call of has_tag?
    # with ID3Lib::V1 is meaningful.
    #
    #   tag = ID3Lib::Tag.new("et_pourtant.mp3", ID3Lib::V1)
    #   tag.has_tag_type?(ID3Lib::V2)  #=> false (but meaningless)
    #
    def has_tag_type?(type)
      @tag.has_tag_type(type)
    end

    private

    def read_frames
      iterator = @tag.iterator_new
      while api_frame = @tag.iterator_next_frame(iterator)
        frame = Frame.new(api_frame)
        self << frame
      end
    end

    def remove_all_api_frames
      iterator = @tag.iterator_new
      while api_frame = @tag.iterator_next_frame(iterator)
        @tag.remove_frame(api_frame)
      end
    end

  end


  class Frame

    # Frame ID
    attr_reader :id
    # Array of allowed fields for frame
    attr_reader :allowed_fields

    def initialize(id_or_frame)
      if id_or_frame.is_a? API::Frame
        @api_frame = id_or_frame
        info = Info.frame_num(@api_frame.get_id)
      else
        @api_frame = nil
        info = Info.frame(id_or_frame)
      end
      if not info
        raise ArgumentError, "invalid frame ID #{id_or_frame.inspect}"
      end

      @id = info[ID]
      @allowed_fields = info[FIELDS]
      @fields = {}

      if @api_frame
        read_api_frame
      end

      yield self if block_given?
    end

    def method_missing(meth, *args)
      m = meth.to_s
      assignment = m.chomp!('=')
      m = m.to_sym
      if @allowed_fields.include?(m)
        if assignment
          @fields[m] = args.first
        else
          @fields[m]
        end
      else
        super
      end
    end

    def field(name)
      @fields[name]
    end

    def set_field(name, val)
      if not @allowed_fields.include?(name)
        raise ArgumentError, "invalid field name #{name.inspect}"
      end
      @fields[name] = val
    end

    #
    # Returns the text of the frame or '' if there is no text.
    #
    def to_s
      @fields[:text] or ''
    end

    #
    # Returns a string containing a readable representation of the frame.
    #
    #   p title_frame
    #   #<ID3Lib::Frame:TIT2 textenc=0, text="Title">
    #
    def inspect
      [ "#<#{self.class}:#{@id} ",
        @allowed_fields.map{ |f|
          "#{f}=#{@fields[f].inspect}"
        }.join(', '),
        ">" ].join
    end

    def changed?
      if @fields_hashcode
        @fields_hashcode != @fields.to_a.hash
      else
        true
      end
    end

    def == other
      other.fields_equal?(@fields)
    end

    def fields_equal?(fields)
      @fields == fields
    end
    protected :fields_equal?

    def write_api_frame
      return unless changed?

      unless @api_frame
        @api_frame = API::Frame.new(Info.frame(@id)[NUM])
      end

      if textenc = @fields[:textenc]
        f = @api_frame.get_field(Info.field(:textenc)[NUM])
        f.set_integer(textenc)
      end

      @fields.each do |field_id, value|
        next if field_id == :textenc
        # Ignore invalid fields.
        next unless @allowed_fields.include? field_id

        api_field = @api_frame.get_field(Info.field(field_id)[NUM])
        next unless api_field

        case Info.field_type(api_field.get_type)
        when :integer
          api_field.set_integer(value)
        when :binary
          api_field.set_binary(value)
        when :text
          if textenc and textenc > 0 and
             [:text, :description, :filename].include?(field_id)
            # Special treatment for Unicode
            api_field.set_encoding(textenc)
            api_field.set_unicode(value)
          else
            api_field.set_ascii(value)
          end
        end
      end

      @fields_hashcode = @fields.to_a.hash
      @api_frame
    end

    private

    def read_api_frame
      info = Info.frame(@id)

      @allowed_fields.each do |field_name|
        api_field = @api_frame.get_field(Info.field(field_name)[NUM])
        next unless api_field
        @fields[field_name] =
          case Info::FieldType[api_field.get_type]
          when :integer
            api_field.get_integer
          when :binary
            api_field.get_binary
          when :text
            if api_field.get_encoding > 0
              api_field.get_unicode
            else
              api_field.get_ascii
            end
          end
      end

      @fields_hashcode = @fields.to_a.hash
      @fields
    end

  end


end
