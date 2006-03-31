#include <iostream>
#include <id3/tag.h>


using namespace std;

void AddTextFrame( ID3_Tag & tag, ID3_FrameID frameid, char * text ) {
	ID3_Frame frame(frameid);
	frame.Field(ID3FN_TEXT).Set(text);
	tag.AddFrame(frame);
}

int main( int argc, char ** argv ) {
	ID3_Tag tag;	
	tag.Link( argv[1] );

	AddTextFrame(tag, ID3FID_TITLE, "Dummy Title");
	AddTextFrame(tag, ID3FID_LEADARTIST, "Dummy Artist");
	AddTextFrame(tag, ID3FID_ALBUM, "Dummy Album");
	AddTextFrame(tag, ID3FID_TRACKNUM, "1/10");
	AddTextFrame(tag, ID3FID_YEAR, "2000");
	AddTextFrame(tag, ID3FID_COMMENT, "Dummy Comment");
	AddTextFrame(tag, ID3FID_COMMENT, "Dummy Comment 2");
	AddTextFrame(tag, ID3FID_CONTENTTYPE, "Pop");
	
	tag.Update();
	return 0;
}
