#include <iostream>
#include <id3/tag.h>


using namespace std;

void AddTextFrame(ID3_Tag & tag, ID3_FrameID frameid, char * text) {
	ID3_Frame frame(frameid);
	frame.Field(ID3FN_TEXT).Set(text);
	tag.AddFrame(frame);
}

int main(int argc, char ** argv) {
	const char * filename;
	ID3_Tag tag;

	if (argc != 2) {
		cout << "usage: " << argv[0] << " output.mp3" << endl;
		return 1;
	}

	filename = argv[1];

	tag.Link(filename);

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
