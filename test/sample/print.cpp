#include <iostream>
#include <id3/tag.h>


using namespace std;


int main( int argc, char ** argv ) {
	ID3_Tag tag;
	tag.Link(argv[1]);

	ID3_Tag::Iterator * iter = tag.CreateIterator();
	while (ID3_Frame * frame = iter->GetNext())
	{
		ID3_Field * text_field = frame->GetField(ID3FN_TEXT);
  	cout << text_field->GetRawText() << endl;
	}

	return 0;
}
