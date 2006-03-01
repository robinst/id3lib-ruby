
require 'test/unit'
require 'id3lib'


class Reading < Test::Unit::TestCase

  def setup
    @tag = ID3Lib::Tag.new('sample/sample.mp3')
  end
  
  def test_array
    assert_equal 'Dummy Title',     @tag.shift[:text]
    assert_equal 'Dummy Artist',    @tag.shift[:text]
    assert_equal 'Dummy Album',     @tag.shift[:text]
    assert_equal '1/10',            @tag.shift[:text]
    assert_equal '2000',            @tag.shift[:text]
    assert_equal 'Dummy Comment',   @tag.shift[:text]
    assert_equal 'Dummy Comment 2', @tag.shift[:text]
    assert_equal 'Pop',             @tag.shift[:text]
  end

  def test_direct_access
    assert_equal 'Dummy Title', @tag.title
    assert_equal 'Dummy Artist', @tag.artist
    assert_equal 'Dummy Artist', @tag.performer
    assert_equal 'Dummy Album', @tag.album
    assert_equal [1,10], @tag.track
    assert_equal 2000, @tag.year
    assert_equal 'Dummy Comment', @tag.comment
    assert_equal 'Pop', @tag.genre
  end

  def test_comments
    comments = @tag.comment_frames
    one, two = *comments
    assert_not_nil one
    assert_not_nil two
    assert_equal 'Dummy Comment', one[:text]
    assert_equal 'Dummy Comment 2', two[:text]
  end
  
  def test_unicode
    @tag = ID3Lib::Tag.new('sample/unicode.mp3', ID3Lib::V2)
    assert_equal "\x4f\x60\x59\x7d", @tag.title
  end
  
end
