
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

  def test_set_text
    assert_raise ArgumentError do
      @tag.set_text(:arrrtist, '2000')
    end
    @tag.set_text(:title, 'New Title')
    assert_equal 'New Title', @tag.text(:title)
    @tag.update!
    assert_equal 'New Title', @tag.text(:title)
    reload!
    assert_equal 'New Title', @tag.text(:title)
  end

  def test_set_text_with_number
    @tag.set_text(:track, 4)
    assert_equal '4', @tag.text(:track)
    @tag.update!
    assert_equal '4', @tag.text(:track)
    reload!
    assert_equal '4', @tag.text(:track)
  end

  def test_id3v1_genre
    ID3Lib::Tag.strip!(Temp, ID3Lib::V2)
    reload!
    genre_id = '(' + ID3Lib::Info::Genres.index('Rock').to_s + ')'
    @tag.set_text(:genre, genre_id)
    assert_equal genre_id, @tag.text(:genre)
    @tag.update!(ID3Lib::V1)
    assert_equal genre_id, @tag.text(:genre)
    reload!(ID3Lib::V1)
    assert_equal genre_id, @tag.text(:genre)
  end

  def test_set_frame
    assert_raise ArgumentError do
      @tag.set_frame(:yearrr)
    end
    @tag.set_frame(:TLAN) do |f|
      f.text = 'zho'
    end
    assert_equal 'zho', @tag.text(:TLAN)
    @tag.update!
    assert_equal 'zho', @tag.text(:TLAN)
    reload!
    assert_equal 'zho', @tag.text(:TLAN)
  end

  def test_apic
    pic = @tag.set_frame(:APIC) do |f|
      f.mimetype    = 'image/jpeg'
      f.imageformat = ''
      f.picturetype = 3
      f.description = 'A pretty picture.'
      f.textenc     = 0
      f.data        = File.read('test/data/cover.jpg')
    end
    assert_block "Long data field should be truncated on inspect." do
      pic.inspect.length < 160
    end
    @tag.update!
    assert_equal pic, @tag.frame(:APIC)
    reload!
    assert_equal pic, @tag.frame(:APIC)
  end

  def test_remove_frame
    @tag.remove_frame(:TIT2)
    assert_nil @tag.frame(:TIT2)
  end

  def test_strip
    ID3Lib::Tag.strip!(Temp)
    reload!
    assert !@tag.has_tag?
  end

  def test_strip_and_tag_type
    ID3Lib::Tag.strip!(Temp, ID3Lib::V1)
    reload!(ID3Lib::V1)
    assert !@tag.has_tag_type?(ID3Lib::V1)
    reload!
    assert @tag.has_tag?

    ID3Lib::Tag.strip!(Temp, ID3Lib::V2)
    reload!(ID3Lib::V2)
    assert !@tag.has_tag_type?(ID3Lib::V2)
    reload!
    assert !@tag.has_tag?
  end

  def test_padding
    assert_equal 2176, File.size(Temp)
    @tag.padding = false
    @tag.update!
    assert_equal 128, File.size(Temp)
  end

  def test_failing_update
    # Note filename which is a directory -> update! should fail
    @tag = ID3Lib::Tag.new("test/data/")
    @tag.set_text(:artist, "Nobody")
    assert_equal nil, @tag.update!
  end

  def test_frame_names
    names = %w[
      title performer album genre year track part_of_set comment composer
      grouping bpm subtitle date time language lyrics lyricist band
      conductor interpreted_by publisher encoded_by
    ]

    names.each do |n|
      @tag.set_text(n.to_sym, "#{n} test")
      assert_equal "#{n} test", @tag.text(n.to_sym)
    end

    @tag.update!

    names.each do |n|
      assert_equal "#{n} test", @tag.text(n.to_sym)
    end

    reload!

    names.each do |n|
      assert_equal "#{n} test", @tag.text(n.to_sym)
    end
  end

end
