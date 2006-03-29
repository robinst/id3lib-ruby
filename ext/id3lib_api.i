
%module "ID3Lib::API"

%{
#include <id3/tag.h>
%}


enum ID3_FrameID;
enum ID3_FieldID;
enum ID3_FieldType;
enum ID3_TextEnc;

typedef unsigned int flags_t;


%rename (Tag) ID3_Tag;
class ID3_Tag
{
  public:
  
  ID3_Tag(const char *name = NULL);
  ~ID3_Tag();
  
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
  
  %rename (filename) GetFileName;
  const char * GetFileName() const;
  
  %rename (find) Find;
  ID3_Frame * Find(ID3_FrameID name) const;
  
  %rename (iterator_new) CreateIterator;
  ID3_Tag::Iterator * CreateIterator();
  
  // Needed because SWIG does not support nested classes yet.
  %extend {
    ID3_Frame * iterator_next_frame(ID3_Tag::Iterator *iterator) {
      return iterator->GetNext();
    }
  }
};


%rename (Frame) ID3_Frame;
class ID3_Frame
{
  public:
  
  ID3_Frame(ID3_FrameID id = ID3FID_NOFRAME);
  ~ID3_Frame();
  
  %rename (field) GetField;
  ID3_Field * GetField(ID3_FieldID name) const;
  
  %rename (num) GetID;
  ID3_FrameID GetID() const;
};


%rename (Field) ID3_Field;
class ID3_Field
{
  public:
  
  // Getters
  
  %rename (type) GetType;
  ID3_FieldType GetType() const;
  
  %rename (integer) Get;
  unsigned long Get() const;
  
  %extend {
    VALUE binary() {
      return rb_str_new((const char *)self->GetRawBinary(), self->Size());
    }
  }
    
  %rename (ascii) GetRawText;
  const char * GetRawText() const;
  
  %extend {
    VALUE unicode() {
      const char *string = (const char *)self->GetRawUnicodeText();
      long size = self->Size();
      if (size < 2) {
        size = 0;
      } else if (string[size-2] == '\0' && string[size-1] == '\0') {
        // id3lib seems to be inconsistent: the unicode strings
        // don't always end in 0x0000. If they do, we don't want these
        // trailing bytes.
        size -= 2;
      }
      return rb_str_new(string, size);
    }
  }
  
  // Setters
  
  %rename (set_integer) Set(unsigned long);
  void Set(unsigned long i);
  
  %extend {
    size_t set_binary(VALUE data) {
      StringValue(data);
      return self->Set( (const unsigned char *)RSTRING(data)->ptr, 
        RSTRING(data)->len );
    }
  }
    
  %rename (set_ascii) Set(const char *);
  size_t Set(const char *string);
  
  %rename (set_encoding) SetEncoding(ID3_TextEnc);
  bool SetEncoding(ID3_TextEnc enc);
  
  %extend {
    size_t set_unicode(VALUE data) {
      StringValue(data);

      long len;
      unicode_t *unicode;

      len = RSTRING(data)->len / sizeof(unicode_t);
      unicode = (unicode_t *)malloc(sizeof(unicode_t) * (len+1));
      
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

// vim: filetype=cpp
