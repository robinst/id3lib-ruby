%module "ID3Lib::API"
%{
#include <id3/tag.h>
%}


enum ID3_FrameID;
enum ID3_FieldID;
enum ID3_FieldType;
enum ID3_TextEnc;
enum ID3_TagType;

typedef unsigned int flags_t;


%rename (Tag) ID3_Tag;
class ID3_Tag
{
public:

	ID3_Tag(const char *name = NULL);
	~ID3_Tag();

	%rename (has_tag_type) HasTagType;
	bool HasTagType(ID3_TagType type) const;

	%rename (link) Link;
	size_t Link(const char *filename, flags_t flags = ID3TT_ALL);

	%rename (update) Update;
	flags_t Update(flags_t flags = ID3TT_ALL);

	%rename (strip) Strip;
	flags_t Strip(flags_t flags = ID3TT_ALL);

	%rename (clear) Clear;
	void Clear();

	%rename (remove_frame) RemoveFrame;
	ID3_Frame * RemoveFrame(const ID3_Frame *frame);

	%rename (add_frame) AddFrame;
	void AddFrame(const ID3_Frame *frame);

	%rename (get_filename) GetFileName;
	const char * GetFileName() const;

	%rename (set_padding) SetPadding;
	bool SetPadding(bool padding);

	%rename (size) Size;
	size_t Size() const;

	%rename (find) Find;
	ID3_Frame * Find(ID3_FrameID name) const;

	%rename (create_iterator) CreateIterator;
	%newobject CreateIterator;
	ID3_Tag::Iterator * CreateIterator();
};

%rename (Tag_Iterator) ID3_Tag::Iterator;
class ID3_Tag::Iterator
{
public:

	%rename (get_next) GetNext;
	virtual ID3_Frame * GetNext() = 0;
};


%rename (Frame) ID3_Frame;
class ID3_Frame
{
public:

	ID3_Frame(ID3_FrameID id = ID3FID_NOFRAME);
	~ID3_Frame();

	%rename (get_field) GetField;
	ID3_Field * GetField(ID3_FieldID name) const;

	%rename (get_id) GetID;
	ID3_FrameID GetID() const;
};


%rename (Field) ID3_Field;
class ID3_Field
{
public:

	// Getters

	%rename (get_type) GetType;
	ID3_FieldType GetType() const;

	%rename (get_encoding) GetEncoding;
	ID3_TextEnc GetEncoding() const;

	%rename (get_integer) Get;
	unsigned long Get() const;

	%rename (get_ascii) GetRawText;
	const char * GetRawText() const;

	%extend
	{
		VALUE get_binary()
		{
			return rb_str_new((const char *)self->GetRawBinary(), self->Size());
		}

		VALUE get_unicode()
		{
			const char *str = (const char *)self->GetRawUnicodeText();
			if (str == NULL) return rb_str_new("", 0);
			long size = self->Size();
			if (size >= 2 && str[size-2] == '\0' && str[size-1] == '\0') {
				// id3lib seems to be inconsistent: the Unicode strings
				// don't always end in 0x0000. If they do, we don't want these
				// trailing bytes.
				size -= 2;
			}
			return rb_str_new(str, size);
		}
	}

	// Setters

	%rename (set_encoding) SetEncoding(ID3_TextEnc);
	bool SetEncoding(ID3_TextEnc enc);

	%rename (set_integer) Set(unsigned long);
	void Set(unsigned long i);

	%rename (set_ascii) Set(const char *);
	size_t Set(const char *string);

	%extend
	{
		size_t set_binary(VALUE data)
		{
			StringValue(data);
			return self->Set((const unsigned char *)RSTRING(data)->ptr,
			                 RSTRING(data)->len);
		}

		size_t set_unicode(VALUE data)
		{
			StringValue(data);

			long len;
			unicode_t *unicode;

			len = RSTRING(data)->len / sizeof(unicode_t);
			unicode = (unicode_t *)malloc(sizeof(unicode_t) * (len+1));

			if (unicode == NULL) {
				rb_raise(rb_eNoMemError, "Couldn't allocate memory for Unicode data.");
			}

			memcpy(unicode, RSTRING(data)->ptr, sizeof(unicode_t) * len);
			// Unicode strings need 0x0000 at the end.
			unicode[len] = 0;
			size_t retval = self->Set(unicode);

			// Free Unicode! ;)
			free(unicode);
			return retval;
		}
	}

protected:

	ID3_Field();
	~ID3_Field();
};

// vim: set filetype=cpp sw=4 ts=4 noexpandtab:
