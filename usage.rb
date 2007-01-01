
require 'rubygems'
require 'id3lib'

# Load a tag from a file
tag = ID3Lib::Tag.new("talk.mp3")

# Get and set text frames
tag.text(:title)  #=> "Talk"
tag.set_text(:album, "X&Y")
tag.set_text(:track, '5/13')

# Get MP3 header information
tag.header_info.bitrate  #=> 128000

# Tag is a subclass of Array and holds Frame objects
p tag[0]
#=> #<ID3Lib::Frame:TPE1 textenc=0, text="Coldplay">

# Get the number of frames
tag.length  #=> 7

# Remove all comment frames
tag.remove_frame(:comment)

# Create new APIC frame and find out which fields are allowed
apic = ID3Lib::Frame.new(:APIC)
p apic.allowed_fields
#=> [:textenc, :mimetype, :picturetype, :description, :data]

# Set the fields and append to tag
apic.description = "A pretty picture"
apic.textenc     = 0
apic.data        = File.read("cover.jpg")
apic.mimetype    = 'image/jpeg'
apic.picturetype = 3
tag << apic

# Last but not least, apply changes
tag.update!
