
require 'test/unit'
require 'id3lib'


class TestReading < Test::Unit::TestCase

  def setup
    @tag = ID3Lib::Tag.new('test/data/sample.mp3')
  end

  def test_array
    assert_equal 'Dummy Title',     @tag[0].text
    assert_equal 'Dummy Artist',    @tag[1].text
    assert_equal 'Dummy Album',     @tag[2].text
    assert_equal '1/10',            @tag[3].text
    assert_equal '2000',            @tag[4].text
    assert_equal 'Dummy Comment',   @tag[5].text
    assert_equal 'Dummy Comment 2', @tag[6].text
    assert_equal 'Pop',             @tag[7].text
  end

  def test_text
    assert_equal 'Dummy Title',   @tag.text(:title)
    assert_equal 'Dummy Artist',  @tag.text(:artist)
    assert_equal 'Dummy Artist',  @tag.text(:performer)
    assert_equal 'Dummy Album',   @tag.text(:album)
    assert_equal '1/10',          @tag.text(:track)
    assert_equal '2000',          @tag.text(:year)
    assert_equal 'Dummy Comment', @tag.text(:comment)
    assert_equal 'Pop',           @tag.text(:genre)
  end

  def test_frame
    assert_equal 'Dummy Title',   @tag.frame(:title).text
    assert_equal 'Dummy Artist',  @tag.frame(:artist).text
    assert_equal 'Dummy Artist',  @tag.frame(:performer).text
    assert_equal 'Dummy Album',   @tag.frame(:album).text
    assert_equal '1/10',          @tag.frame(:track).text
    assert_equal '2000',          @tag.frame(:year).text
    assert_equal 'Dummy Comment', @tag.frame(:comment).text
    assert_equal 'Pop',           @tag.frame(:genre).text
  end

  def test_comments
    one, two = @tag.select{ |f| f.id == :COMM }
    assert_not_nil one
    assert_not_nil two
    assert_equal 'Dummy Comment',   one.text
    assert_equal 'Dummy Comment 2', two.text
  end

  def test_has_tag
    assert @tag.has_tag_type?(ID3Lib::V1)
    assert @tag.has_tag_type?(ID3Lib::V2)
    assert @tag.has_tag?
  end

  def test_size
    assert_equal 2038, @tag.size
  end

  def test_num_frames
    assert_equal 9, @tag.length
    assert_equal 9, @tag.instance_variable_get(:@tag).num_frames
  end

  def test_header_info
    assert_nil @tag.header_info

    tag = ID3Lib::Tag.new('test/data/unicode.mp3')
    info = tag.header_info
    assert_equal  3, info.layer
    assert_equal  3, info.version
    assert_equal  0, info.bitrate
    assert_equal  0, info.channelmode
    assert_equal -1, info.modeext
    assert_equal  1, info.emphasis
    assert_equal  0, info.crc
    assert_equal  0, info.vbr_bitrate
    assert_equal  0, info.framesize
    assert_equal  0, info.frames
    assert_equal  0, info.time
    assert_equal 48000, info.frequency
    assert_equal  true, info.privatebit
    assert_equal false, info.copyrighted
    assert_equal  true, info.original
  end

end
