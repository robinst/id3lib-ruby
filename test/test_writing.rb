
require 'test/unit'
require 'fileutils'
require 'id3lib'


class TestWriting < Test::Unit::TestCase

  Sample = 'test/data/sample.mp3'
  Temp   = 'test/data/tmp.sample.mp3'

  def setup
    FileUtils.cp Sample, Temp
    reload!
  end

  def teardown
    FileUtils.rm Temp
  end

  def reload!(*args)
    @tag = ID3Lib::Tag.new(Temp, *args)
  end

  # Test the title direct access. The others like performer or album
  # work alike
  def test_title
    @tag.title = 'New Title'
    assert_equal 'New Title', @tag.title
    @tag.update!
    assert_equal 'New Title', @tag.title
    reload!
    assert_equal 'New Title', @tag.title
  end

  def test_genre
    @tag.genre = 'Rock'
    assert_equal 'Rock', @tag.genre
    @tag.update!
    assert_equal 'Rock', @tag.genre
    reload!
    assert_equal 'Rock', @tag.genre
  end

  def test_id3v1_genre
    @tag.strip!(ID3Lib::V2)
    genre_id = '(' + ID3Lib::Info::Genres.index('Rock').to_s + ')'
    @tag.genre = genre_id
    assert_equal genre_id, @tag.genre
    @tag.update!(ID3Lib::V1)
    assert_equal genre_id, @tag.genre
    reload!(ID3Lib::V1)
    assert_equal genre_id, @tag.genre
  end

  def test_track
    @tag.track = '4'
    assert_equal '4', @tag.track
    @tag.update!
    assert_equal '4', @tag.track
    reload!
    assert_equal '4', @tag.track

    @tag.track = '5/12'
    assert_equal '5/12', @tag.track
    @tag.update!
    assert_equal '5/12', @tag.track
    reload!
    assert_equal '5/12', @tag.track

    @tag.track = 6
    assert_equal '6', @tag.track
    @tag.update!
    assert_equal '6', @tag.track
    reload!
    assert_equal '6', @tag.track
  end

  def test_year
    @tag.year = '2001'
    assert_equal '2001', @tag.year
    @tag.update!
    assert_equal '2001', @tag.year
    reload!
    assert_equal '2001', @tag.year

    @tag.year = 2002
    assert_equal '2002', @tag.year
    @tag.update!
    assert_equal '2002', @tag.year
    reload!
    assert_equal '2002', @tag.year
  end

  def test_comments
    @tag.comment = 'New Comment'
    assert_equal 'New Comment', @tag.comment
    assert_equal 1, @tag.comment_frames.length
    one = @tag.comment_frames.first
    assert_equal 'New Comment', one[:text]
    
    @tag.update!
    assert_equal 'New Comment', @tag.comment
    
    reload!
    assert_equal 'New Comment', @tag.comment
  end

  def test_manual_frame
    @tag << {:id => :TLAN, :text => 'zho'}
    assert_equal 'zho', @tag.frame_text(:TLAN)
    @tag.update!
    assert_equal 'zho', @tag.frame_text(:TLAN)
    reload!
    assert_equal 'zho', @tag.frame_text(:TLAN)
  end

  def test_apic
    pic = {
      :id           => :APIC,
      :mimetype     => 'image/jpeg',
      :imageformat  => '',
      :picturetype  => 3,
      :description  => 'A pretty picture.',
      :textenc      => 0,
      :data         => File.read('test/data/cover.jpg')
    }
    @tag << pic
    @tag.update!
    assert_equal pic, @tag.frame(:APIC)
    reload!
    assert_equal pic, @tag.frame(:APIC)
  end

  def test_remove_frame
    @tag.remove_frame(:TIT2)
    assert_nil @tag.frame(:TIT2)
  end

  def test_remove_frame_with_direct_access
    @tag.title = nil
    assert_nil @tag.frame(:TIT2)
  end

  def test_wrong_frame
    l = @tag.length
    @tag << {:id => :WRONG, :text => "Test"}
    @tag.update!
    assert_equal l, @tag.length
    reload!
    assert_equal l, @tag.length
  end

  def test_strip
    @tag.strip!
    assert @tag.empty?
    reload!
    assert @tag.empty?
  end

  def test_tagtype
    @tag.strip!(ID3Lib::V1)
    reload!(ID3Lib::V1)
    assert @tag.empty?
    reload!
    assert !@tag.empty?
    @tag.strip!(ID3Lib::V2)
    reload!(ID3Lib::V2)
    assert @tag.empty?
    reload!
    assert @tag.empty?
  end

  def test_padding
    assert_equal 2176, File.size(Temp)
    @tag.padding = false
    @tag.update!
    assert_equal 348, File.size(Temp)
  end

  def test_failing_update
    # Note filename which is a directory -> update! should fail
    @tag = ID3Lib::Tag.new("test/data/")
    @tag.performer = "Nobody"
    assert_equal nil, @tag.update!
  end

  def test_accessors
    accessors = %w[
      title performer album genre year track part_of_set comment composer
      grouping bpm subtitle date time language lyrics lyricist band
      conductor interpreted_by publisher encoded_by
    ]
    do_tests_for_accessors(accessors)
  end

  def test_accessor_aliases
    aliases = %w[ artist content_type disc remixed_by ]
    do_tests_for_accessors(aliases)
  end

  def do_tests_for_accessors(accessors)
    accessors.each do |m|
      @tag.send("#{m}=", "#{m} test")
      assert_equal "#{m} test", @tag.send(m)
    end

    @tag.update!

    accessors.each do |m|
      assert_equal "#{m} test", @tag.send(m)
    end

    reload!

    accessors.each do |m|
      assert_equal "#{m} test", @tag.send(m)
    end
  end

end
