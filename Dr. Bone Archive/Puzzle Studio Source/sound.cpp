// This example was written by Andrew Heinlein (Mouse)
// I needed a class to play multiple files, so i downloaded the
// DirectX7 SDK and rearranged it into one easy class called "miDSound"
// What this example will do is load up 20 classes, and play upto 20 sounds asynchronously!
// I also added in: 
// PANNING   (left/right channel selection)
// FREQUENCY (basically Play speed)
// VOLUME	 (control the volume of a sound)
// reach these options by using:
// miDSound::SetBufferOptions(Frequency, Pan, Volume)

#include <windows.h>
#include "include/miDSound.h"

int WINAPI WinMain(	HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow){
	
	if(strlen(lpCmdLine) == 0){ /* make sure there is a command line sent */
		MessageBox(NULL, "ERROR!\nDrag and drop multiple sounds onto this program's icon","DX7Sound", MB_OK);
		return -1;
	}

	miDSound m_Sound[20];	 /* create 20 classes.. can handle 20 sounds at one time (max is 32) */
	int TOTAL_SOUNDS = 1;	 /* init the total amount of sounds */
	int CURRENT_SOUND = 0;	 /* for keeping track of the index */
	HWND AVALIBLE_WND = ::GetForegroundWindow(); /* need the foremost window */
	if(AVALIBLE_WND == NULL){AVALIBLE_WND = ::GetDesktopWindow();}
	bool IS_DONE = false, IS_PLAYING = false; /* Used for making sure we dont close before sounds are done playing */

							 /* count the number of files dropped */
	for(int i = 0; i < (int)strlen(lpCmdLine); i++){
		if(strncmp(lpCmdLine + i, " ", 1) == 0){
			TOTAL_SOUNDS++;
		}
	}
							 /* tokenize the command line */
	char* TOKEN = strtok(lpCmdLine, " ");
	while(TOKEN != NULL){
		if(FAILED(m_Sound[CURRENT_SOUND].InitDirectSound(AVALIBLE_WND))){/* init dx7 sound */
			MessageBox(NULL, "Invalid Sound File!", "DX7Sound", MB_OK);
			break;
		}
		m_Sound[CURRENT_SOUND].LoadWaveFile(AVALIBLE_WND, TOKEN); /* load in the current wave */
		m_Sound[CURRENT_SOUND++].PlayBuffer(FALSE);				  /* Play (FALSE = play once, TRUE = loop) */
		TOKEN = strtok( NULL, " ");
	}
							 /* make sure we dont quit until the sounds are done playing */
	while(IS_DONE == false){
		for(i = 0; i < TOTAL_SOUNDS; i++){
			IS_PLAYING = false;
			if(m_Sound[i].IsSoundPlaying()){
				IS_PLAYING = true;
				break;
			}
		}
		if(!IS_PLAYING){
			IS_DONE = true;
		}
	}

	return 0x0;
}