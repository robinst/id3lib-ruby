
module ID3Lib

  #
  # This class is the main frontend of the library.
  # Use it to read and write ID3 tag data of files.
  #
  # == Example of use
  #
  #   tag = ID3Lib::Tag.new("shy_boy.mp3")
  #
  #   # Get title
  #   tag.text(:title)  #=> "Shy Boy"
  #
  #   # Set year
  #   tag.text(:year)   #=> "2000"
  #   tag.set_text(:year, "2005")
  #
  #   # Remove comment
  #   tag.remove_frame(:comment)
  #
  #   # Apply changes
  #   tag.update!
  #
  # == Working with tags
  #
  # You can use an ID3Lib::Tag object like an array. In fact, it is a subclass
  # of Array. A Tag contains ID3Lib::Frame objects. Each Frame object has an ID
  # and holds field data. The frame IDs (e.g. TIT2) are the ones specified by
  # the ID3 standard. You don't have to know these IDs, we will soon see that
  # it is also possible to adress frames with their name.
  #
  #   tag.each do |frame|
  #     p frame
  #   end
  #
  #   # Prints:
  #
  #   #<ID3Lib::Frame:TIT2 textenc=0, text="Shy Boy">
  #   #<ID3Lib::Frame:TPE1 textenc=0, text="Katie Melua">
  #   #<ID3Lib::Frame:TALB textenc=0, text="Piece By Piece">
  #   #<ID3Lib::Frame:TRCK textenc=0, text="1/12">
  #   #<ID3Lib::Frame:TYER textenc=0, text="2005">
  #   #<ID3Lib::Frame:TCON textenc=0, text="Jazz/Blues">
  #
  # == Get, set and remove frames
  #
  # The methods to do this are:
  # * text
  # * set_text
  # * frame
  # * set_frame
  # * remove_frame
  #
  # === Text frames
  #
  # The easiest type of frames to work with are text frames (whose IDs all
  # begin with T). Here are some examples:
  #
  #   tag.text(:title)  #=> "Shai Boi"
  #
  #   tag.set_text(:title, "Shy Boy")
  #   tag.text(:title)  #=> "Shy Boy"
  #
  #   tag.text(:track)  #=> "1/12"
  #   tag.text(:year)   #=> "2005"
  #
  # Of course it is also possible to use IDs instead of names:
  # 
  #   tag.text(:TIT2)  #=> "Shy Boy"
  #
  # === Removing frames
  #
  # To remove a frame from a tag, use remove_frame as follows. Note that all
  # frames with the specified ID or name are removed.
  #
  #   tag.remove_frame(:title)
  #   tag.remove_frame(:APIC)
  #
  # === Other frames
  #
  # There are other frames like APIC or SYLT which don't contain text. Or
  # maybe you want to set the textenc field of a text frame. In these cases,
  # use the methods frame and set_frame. Again, some examples:
  #
  #   # Set textenc
  #   tag.frame(:title).textenc = 1
  #
  #   # Set an attached picture frame
  #   tag.set_frame(:APIC) do |f|
  #     f.description = "A pretty picture"
  #     f.textenc     = 0
  #     f.data        = File.read("cover.jpg")
  #     f.mimetype    = "image/jpeg"
  #     f.picturetype = 3
  #   end
  #
  #   # Another way to do the same
  #   apic_frame = ID3Lib::Frame.new(:APIC)
  #   apic_frame.description = "A pretty picture"
  #   # ... (set the rest of the fields)
  #   tag.remove_frame(:APIC)
  #   tag << apic_frame
  #
  # Note that set_frame removes all other frames with the same ID or name
  # and then appends the frame.
  #
  # === What fields can be set?
  #
  # In the last example, we added an APIC frame. But how can we know what
  # fields we can set? Like this:
  #
  #   apic_frame = ID3Lib::Frame.new(:APIC)
  #   apic_frame.allowed_fields
  #   #=> [:textenc, :mimetype, :picturetype, :description, :data]
  #
  # === What frames can be set?
  #
  # A similar question is what frames can be set on a tag. Have a look at
  # ID3Lib::Info.
  #
  # == Writing changes to file
  #
  # When you've finished modifying a tag, don't forget to call #update! to
  # write the modifications back to the file. You have to check the return
  # value of update!, it returns nil on failure. This probably means that
  # the file is not writeable or cannot be created.
  #
  #  tag.update!
  #
  # == Getting rid of a tag
  #
  # Use the strip! class method to completely remove a tag from a file.
  #
  #   ID3Lib::Tag.strip!("urami_bushi.mp3")
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


    #
    # Add padding to the file? Padding is free space (up to 2 KiB) after the
    # tag data, which enables minimal file write times for future updates.
    # Padding is on by default.
    #
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
    # Simple shortcut for getting a frame by its id or name.
    #
    #   tag.frame(:TIT2)
    #   #=> {:id => :TIT2, :text => "Shy Boy", :textenc => 0}
    #   tag.frame(:title)
    #   #=> {:id => :TIT2, :text => "Shy Boy", :textenc => 0}
    #
    def frame(id_or_name)
      id = check_id(id_or_name)
      find{ |f| f.id == id }
    end

    #
    # Removes frames with _id_or_name_ and then creates and appends a new
    # one.
    #
    # If a block is given, the new frame is yielded. This is very convenient
    # for setting the frame's fields.
    #
    # Returns the appended frame.
    #
    #   tag.set_frame(:PCNT) do |f|
    #     f.counter = 7
    #   end
    #
    # ... is the same as:
    #
    #   tag.remove_frame(:PCNT)
    #   frame = ID3Lib::Frame.new(:PCNT)
    #   frame.counter = 7
    #   tag << frame
    #
    def set_frame(id_or_name)
      id = check_id(id_or_name)
      delete_if{ |f| f.id == id }
      frame = Frame.new(id)
      yield frame if block_given?
      self << frame
      frame
    end

    #
    # Returns the text of a frame specified by _id_or_name_, or nil if the
    # frame can't be found.
    #
    #   tag.frame(:title).text  #=> "Shy Boy"
    #   tag.text(:title)        #=> "Shy Boy"
    #
    #   tag.frame(:TLAN).text   # raises NoMethodError (nil.text)
    #   tag.text(:TLAN)         #=> nil
    #
    def text(id_or_name)
      f = frame(id_or_name)
      f ? f.text : nil
    end

    #
    # Sets the text of a frame. First, all frames with the specified
    # _id_or_name_ are deleted and then a new frame with _text_ is appended.
    #
    #   tag.set_text(:title, "Mad World")
    #   tag.set_text(:TLAN, "eng")
    #
    def set_text(id_or_name, text)
      set_frame(id_or_name) do |f|
        f.text = text.to_s
      end
    end

    #
    # Removes all frames with the specified _id_or_name_.
    #
    #   tag.remove_frame(:comment)
    #
    def remove_frame(id_or_name)
      id = check_id(id_or_name)
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

    def check_id(id_or_name)
      info = Info::FramesByID[id_or_name]
      return info[ID] if info
      info = Info::FramesByName[id_or_name]
      return info[ID] if info
      raise ArgumentError, "Invalid frame ID or name #{id_or_name.inspect}."
    end

  end

end
