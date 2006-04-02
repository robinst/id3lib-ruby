
require 'id3lib_api'
require 'id3lib/info'
require 'id3lib/accessors'


#
# This module includes all the classes and constants of id3lib-ruby.
# Have a look at ID3Lib::Tag for an introduction on how to use this library.
#
module ID3Lib
  
  # ID3 version 1. All V constants can be used with the methods
  # initialize, update or strip of ID3Lib::Tag. 
  V1    = 1
  # ID3 version 2
  V2    = 2
  # All tag types
  Vall  = -1
  # Both ID3 versions
  Vboth = V1 | V2
    
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
  #    tag = ID3Lib::Tag.new('hungriges_herz.mp3')
  #
  #    # Remove comments
  #    tag.delete_if{ |frame| frame[:id] == :COMM }
  #
  #    # Set year
  #    tag.year   #=> 2001
  #    tag.year = 2004
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
  #    #=> {:id=>:TIT2, :text=>"Hungriges Herz", :textenc=>0}
  #    #=> {:id=>:TPE1, :text=>"MIA.", :textenc=>0}
  #    #=> {:id=>:TALB, :text=>"Stille Post", :textenc=>0}
  #    #=> {:id=>:TRCK, :text=>"3/11", :textenc=>0}
  #    #=> {:id=>:TYER, :text=>"2004", :textenc=>0}
  #    #=> {:id=>:TCON, :text=>"Pop", :textenc=>0}
  #
  # === Get and set frames
  #
  # There are a number of accessors for text frames like
  # title, performer, album, track, year, comment and genre. Have a look
  # at ID3Lib::Accessors for a complete list.
  #
  #    tag.title    #=> Hungriges Herz
  #
  #    tag.title = 'Hungry Heart'
  #    tag.title    #=> Hungry Heart
  #
  #    tag.track    #=> [3,11]
  #    tag.year     #=> 2004
  #
  # You can always read and write the raw text if you want. You just have
  # to use the "manual access". It is generally encouraged to use the
  # #frame_text method where possible, because the other two result in
  # an exception when the frame isn't found.
  #
  #    tag.frame_text(:TRCK)                  #=> "3/11"
  #    tag.frame_text(:TLAN)                  #=> nil
  #
  #    tag.frame(:TRCK)[:text]                #=> "3/11"
  #    # Raises an exception, because nil[:text] isn't possible:
  #    tag.frame(:TLAN)[:text]
  #
  #    tag.find{ |f| f[:id] == :TRCK }[:text] #=> "3/11"
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
  # write the modifications back to the file.
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
    
    #
    # Create a new Tag. When a _filename_ is supplied, the tag of the file
    # is read. _tagtype_ specifies the tag type to read and defaults to Vall.
    # Use one of ID3Lib::V1, ID3Lib::V2, ID3Lib::Vboth or ID3Lib::Vall.
    #
    #    tag = ID3Lib::Tag.new('hungriges_herz.mp3')
    # 
    # Only read ID3v1 tag:
    #
    #    id3v1_tag = ID3Lib::Tag.new('factory_city.mp3', ID3Lib::V1)
    #
    def initialize(filename, readtype=Vall)
      @filename = filename
      @readtype = readtype
      @tag = API::Tag.new
      @tag.link(@filename, @readtype)
      read_frames
    end
    
    #
    # Simple shortcut for getting a frame by its _id_.
    #
    #    tag.frame(:TIT2)  #=> {:id => :TIT2, :text => "Was Es Ist", :textenc => 0}
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
    #    tag.find{ |f| f[:id] == :TIT2 }[:text]  #=> "Was Es Ist"
    #    tag.frame_text(:TIT2)                   #=> "Was Es Ist"
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
    #    tag.set_frame_text(:TLAN, 'zho')
    #
    def set_frame_text(id, text)
      remove_frame(id)
      self << { :id => id, :text => text }
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
    #    tag.update!
    #    id3v1_tag.update!(ID3Lib::V1)
    #
    def update!(writetype=@readtype)
      @tag.strip(writetype)
      # The following two lines are necessary because of the weird
      # behaviour of id3lib.
      @tag.clear
      @tag.link(@filename, writetype)
      
      written_frames = []
      each do |frame|
        frame_info = Info.frame(frame[:id])
        next unless frame_info
        libframe = API::Frame.new(frame_info[NUM])
        Frame.write(frame, libframe)
        @tag.add_frame(libframe)
        written_frames << frame
      end
      replace(written_frames)
      
      @tag.update(writetype)
    end
    
    #
    # Strip tag from file. This is dangerous because you lose all tag
    # information. Specify _striptag_ to only strip a certain tag type.
    # You do _not_ have to call #update! after #strip!.
    #
    #    tag.strip!
    #    another_tag.strip!(ID3Lib::V1)
    #
    def strip!(striptype=Vall)
      clear
      @tag.strip(striptype)
      @tag.clear
      @tag.link(@filename, @readtype)
    end
    
    private
    
    def read_frames
      iterator = @tag.iterator_new
      while libframe = @tag.iterator_next_frame(iterator)
        self << Frame.read(libframe)
      end
    end
    
  end
  
  
  module Frame #:nodoc:

    def self.read(libframe)
      frame = {}
      info = Info.frame(libframe.num)
      frame[:id] = info[ID]
      if info[FIELDS].include?(:textenc)
        textenc = field(libframe, :textenc).integer
        frame[:textenc] = textenc
      end
      info[FIELDS].each do |field_id|
        next if field_id == :textenc
        libfield = field(libframe, field_id)
        frame[field_id] = if textenc and textenc > 0
          libfield.unicode
        else
          case Info::FieldType[libfield.type]
          when :integer : libfield.integer
          when :binary  : libfield.binary
          when :text    : libfield.ascii
          end
        end
      end
      frame
    end
    
    def self.write(frame, libframe)
      textenc = frame[:textenc]
      field(libframe, :textenc).set_integer(textenc) if textenc
      frame.each do |field_id, value|
        unless Info.frame(frame[:id])[FIELDS].include?(field_id)
          # TODO: Add method to check if frames are valid.
          next
        end
        next if field_id == :textenc
        libfield = field(libframe, field_id)
        if textenc and textenc > 0
          libfield.set_encoding(textenc)
          libfield.set_unicode(value)
        else
          case Info::FieldType[libfield.type]
          when :integer : libfield.set_integer(value)
          when :binary  : libfield.set_binary(value)
          when :text    : libfield.set_ascii(value)
          end
        end
      end
    end
    
    def self.field(libframe, id)
      libframe.field(Info.field(id)[NUM])
    end
            
  end
  
  
end
