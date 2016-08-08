#include "ofMain.h"
#include "ofApp.h"

//========================================================================
int main( ){
#if 1
	ofSetupOpenGL(1024,768,OF_WINDOW);			// <-------- setup the GL context

	// this kicks off the running of my app
	// can be OF_WINDOW or OF_FULLSCREEN
	// pass in width and height too:
	ofRunApp(new ofApp());
#else
    
    ofSetLogLevel(OF_LOG_VERBOSE);
    ofGLFWWindowSettings settings;
    settings.setGLVersion(4, 1);
    settings.width = 1280;
    settings.height = 720;
    ofCreateWindow(settings);
    ofRunApp(new ofApp());
#endif

}
