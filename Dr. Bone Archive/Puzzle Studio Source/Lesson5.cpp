/*
 *		This Code Was Created By Jeff Molofee 2000
 *		A HUGE Thanks To Fredric Echols For Cleaning Up
 *		And Optimizing The Base Code, Making It More Flexible!
 *		If You've Found This Code Useful, Please Let Me Know.
 *		Visit My Site At nehe.gamedev.net
 */

#include <windows.h>		// Header File For Windows
#include <stdio.h>			// Header File For Standard Input/Output
#include <gl\gl.h>			// Header File For The OpenGL32 Library
#include <gl\glu.h>			// Header File For The GLu32 Library
#include <gl\glaux.h>		// Header File For The Glaux Library
#include <al\alut.h>
#include "glinterface.h"
#include "miDSound.h"
#include <direct.h>


extern "C" {
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
}

BOOL CreateGLWindow(char* title, int width, int height, int bits, bool fullscreenflag);
GLvoid KillGLWindow(GLvoid);

HDC			hDC=NULL;		// Private GDI Device Context
HGLRC		hRC=NULL;		// Permanent Rendering Context
HWND		hWnd=NULL;		// Holds Our Window Handle
HINSTANCE	hInstance;		// Holds The Instance Of The Application

bool	keys[256];			// Array Used For The Keyboard Routine
bool	active=TRUE;		// Window Active Flag Set To TRUE By Default
bool	fullscreen=TRUE;	// Fullscreen Flag Set To Fullscreen Mode By Default
bool quit=false;

lua_State* L;
FILE *tracefile=0;
bool tracestate=true;
UINT_PTR ptimer=0;
int gwidth,gheight;

GLuint	base;				// Base Display List For The Font Set
GLYPHMETRICSFLOAT gmf[256];	// Storage For Information About Our Outline Font Characters

LRESULT	CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);	// Declaration For WndProc


void output(const char *s)
{
	OutputDebugString(s);
	if(tracestate)
	{
		if(tracefile==false)
			tracefile=fopen("debug.txt","wt");
		fputs(s,tracefile);
	}
}

static void l_message (const char *pname, const char *msg) {
	if (pname){ 
	  output(pname);
	  output( ": ");
	}
  output(msg);
  output("\n");
}


static int report (lua_State *L, int status,char *progname) {
  if (status && !lua_isnil(L, -1)) {
    const char *msg = lua_tostring(L, -1);
    if (msg == NULL) msg = "(error object is not a string)";
    l_message(progname, msg);
    lua_pop(L, 1);
  }
  return status;
}

void LineReport(lua_State *L,char *call)
{
	int status=luaL_dostring(L,call);
	if(status)
	{
		report(L,status,call);
	}
}

static int GetSaveFileName(lua_State *L) 
{
	if(lua_gettop(L)==2)
	{
		char *title=(char*)lua_tostring(L, 1);
		char *filter=(char*)lua_tostring(L, 2);
		OPENFILENAME ofn;       // common dialog box structure
		char szFile[1024];       // buffer for file name

			strcpy(szFile,"");//map->filename);
		// Initialize OPENFILENAME
		ZeroMemory(&ofn, sizeof(ofn));
		ofn.lpstrTitle=title;
		ofn.lStructSize = sizeof(ofn);
		ofn.hwndOwner = hWnd;
		ofn.lpstrFile = szFile;
		ofn.nMaxFile = sizeof(szFile);
		ofn.lpstrFilter = filter; //	"All\0*.*\0psmap\0*.psmap\0";
		ofn.nFilterIndex = 1;
		ofn.lpstrFileTitle = NULL;
		ofn.nMaxFileTitle = 0;
		ofn.lpstrInitialDir = NULL;
		ofn.Flags = 0;
			szFile[0]=0;

		// Display the Open dialog box.
		if (GetSaveFileName(&ofn)==TRUE)
		{
				lua_pushstring(L,szFile);
				return 1;
		}
	}
   return 0;
}

static int GetOpenFileName(lua_State *L) 
{
	if(lua_gettop(L)==2)
	{
		char *title=(char*)lua_tostring(L, 1);
		char *filter=(char*)lua_tostring(L, 2);
		OPENFILENAME ofn;       // common dialog box structure
		char szFile[260];       // buffer for file name

		// Initialize OPENFILENAME
		ZeroMemory(&ofn, sizeof(ofn));
		ofn.lpstrTitle=title;
		ofn.lStructSize = sizeof(ofn);
		ofn.hwndOwner = hWnd;
		ofn.lpstrFile = szFile;
		ofn.nMaxFile = sizeof(szFile);
		ofn.lpstrFilter = filter; //"All\0*.*\0psmap\0*.psmap\0";
		ofn.nFilterIndex = 1;
		ofn.lpstrFileTitle = NULL;
		ofn.nMaxFileTitle = 0;
		ofn.lpstrInitialDir = NULL;
		ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

		// Display the Open dialog box.
		szFile[0]=0;

		if (GetOpenFileName(&ofn)==TRUE)
		{
				lua_pushstring(L,szFile);
				return 1;
		}
	}
   return 0;
}

static int GetWorkingDirectory(lua_State *L) 
{
	char working[2048];
	getcwd(working,sizeof(working));
	lua_pushstring(L,working);
	return 1;
}


GLvoid ReSizeGLScene(GLsizei width, GLsizei height)		// Resize And Initialize The GL Window
{
	if (height==0)										// Prevent A Divide By Zero By
	{
		height=1;										// Making Height Equal One
	}

	glViewport(0,0,width,height);						// Reset The Current Viewport

	glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
	glLoadIdentity();									// Reset The Projection Matrix

	// Calculate The Aspect Ratio Of The Window
	gluPerspective(45.0f,(GLfloat)width/(GLfloat)height,0.1f,100.0f);

	glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
	glLoadIdentity();									// Reset The Modelview Matrix
	gwidth=width;
	gheight=height;
	if(L)
	{
		char buffer[100];
		sprintf(buffer,"ResizeScreen(%d,%d)",width,height);
		LineReport(L,buffer);
	}
} 

void GetCameraScreenRay(float *pt,int rx,int ry)
{
  GLint viewport[4];
  GLdouble modelview[16],projection[16];
  GLfloat wx=(float)rx;
  GLfloat wy,wz;
  double ox,oy,oz;
  wz=1.0f;

  glGetIntegerv(GL_VIEWPORT,viewport);
  ry=viewport[3]-ry;
  wy=(float)ry;
  glGetDoublev(GL_MODELVIEW_MATRIX,modelview);
  glGetDoublev(GL_PROJECTION_MATRIX,projection);
  gluUnProject(wx,wy,wz,modelview,projection,viewport,&ox,&oy,&oz);
  pt[0]=(float)ox;
  pt[1]=(float)oy;
  pt[2]=(float)oz;
}

bool Line_Plane(float *pt3,float *plane, float *pt1, float *pt2)
{
	float denom,num,mu;
	num=plane[3] + plane[0] * pt1[0] + plane[1] * pt1[1] + plane[2] * pt1[2];
	denom=plane[0] * (pt2[0] - pt1[0]) + plane[1] * (pt2[1] - pt1[1]) + plane[2] * (pt2[2] - pt1[2]);
	if((denom<0.000001f)&&(denom>-0.000001f))
		return false;
	mu=-num/denom;
   pt3[0] = pt1[0] + mu * (pt2[0] - pt1[0]);
   pt3[1] = pt1[1] + mu * (pt2[1] - pt1[1]);
   pt3[2] = pt1[2] + mu * (pt2[2] - pt1[2]);
//   if (mu < 0 || mu > 1)   // Intersection not along line segment 
//      return false;
	return true;
}

static int GetPlanePoint(lua_State* L)
{
	if(lua_gettop(L)==3)
	{
		int mx=(int)lua_tonumber(L, 1);
		int my=(int)lua_tonumber(L, 2);
		float point[3];
		float edit_plane[4];
		float camera[3];
		camera[0]=(float)0;
		camera[1]=(float)0;
		camera[2]=(float)0;
		
		GetCameraScreenRay(point,mx,my);
		edit_plane[0]=0.0f;
		edit_plane[1]=0.0f;
		edit_plane[2]=1.0f;
		edit_plane[3]=(float)lua_tonumber(L, 3);
		bool result=Line_Plane(point,edit_plane, point, camera);
		if(result)
		{
			lua_pushnumber(L, point[0]);        
			lua_pushnumber(L, point[1]);        
			return 2;
		}
	}
	return 0;
}


int InitGL(GLvoid)										// All Setup For OpenGL Goes Here
{
	return TRUE;										// Initialization Went OK
}

static int HashFile(lua_State* L)
{
	if(lua_gettop(L)==1)
	{
		char buffer[50];
		char *s=(char *)lua_tolstring(L, 1,0);
		FILE *f=fopen(s,"rb");
		unsigned __int64 seed=14695981039346656037;
		if(f)
		{
			unsigned char v;
			while(fread(&v,1,1,f))
			{
				seed^=v;
				seed*=1099511628211;
			}
			fclose(f);
		}
		sprintf(buffer,"%016I64x",seed);
		lua_pushstring(L,buffer);
		return 1;
	}
	return 0;
}

static int luaB_print (lua_State *L) {
  int n = lua_gettop(L);  /* number of arguments */
  int i;
  lua_getglobal(L, "tostring");
  for (i=1; i<=n; i++) {
    const char *s;
    lua_pushvalue(L, -1);  /* function to be called */
    lua_pushvalue(L, i);   /* value to print */
    lua_call(L, 1, 1);
    s = lua_tostring(L, -1);  /* get result */
    if (s == NULL)
      return luaL_error(L, LUA_QL("tostring") " must return a string to "
                           LUA_QL("print"));
	if (i>1) output("\t");
    output(s);
    lua_pop(L, 1);  /* pop result */
  }
  output("\n");
  return 0;
}

static int SetTitle (lua_State *L) {
	if(lua_gettop(L)==1)
	{
		SendMessage(hWnd,WM_SETTEXT,0,(LPARAM)lua_tostring(L, 1));
	}
	return 0;
}

static int DoLine (lua_State *L) {
	if(lua_gettop(L)==1)
	{
		luaL_dostring(L,lua_tostring(L, 1));
	}
	return 0;
}

static int Quit(lua_State *L) {
	if(lua_gettop(L)==0)
	{
	  quit=true;
	}
	return 0;
}


GLvoid BuildFont(GLvoid)								// Build Our Bitmap Font
{
	HFONT	font;										// Windows Font ID

	base = glGenLists(256);								// Storage For 256 Characters

	font = CreateFont(	-12,							// Height Of Font
						0,								// Width Of Font
						0,								// Angle Of Escapement
						0,								// Orientation Angle
						FW_THIN,						// Font Weight
						FALSE,							// Italic
						FALSE,							// Underline
						FALSE,							// Strikeout
						ANSI_CHARSET,					// Character Set Identifier
						OUT_TT_PRECIS,					// Output Precision
						CLIP_DEFAULT_PRECIS,			// Clipping Precision
						NONANTIALIASED_QUALITY,			// Output Quality
						FF_DONTCARE|DEFAULT_PITCH,		// Family And Pitch
						"Lucida Console");		// Font Name

	SelectObject(hDC, font);							// Selects The Font We Created

	wglUseFontOutlines(	hDC,							// Select The Current DC
						0,								// Starting Character
						255,							// Number Of Display Lists To Build
						base,							// Starting Display Lists
						0.0f,							// Deviation From The True Outlines
						0.0f,							// Font Thickness In The Z Direction
						WGL_FONT_POLYGONS,				// Use Polygons, Not Lines
						gmf);							// Address Of Buffer To Recieve Data
}

GLvoid KillFont(GLvoid)									// Delete The Font List
{
	glDeleteLists(base, 256);							// Delete All 96 Characters
}

static int glDrawText(lua_State *L) 
{
	if(lua_gettop(L)==1)
	{
		char *text=(char*)lua_tostring(L, 1);
		glPushAttrib(GL_LIST_BIT);							// Pushes The Display List Bits
		glListBase(base);									// Sets The Base Character to 0
		glCallLists(strlen(text), GL_UNSIGNED_BYTE, text);	// Draws The Display List Text
		glPopAttrib();										// Pops The Display List Bits
	}
	return 0;
}

static int lua_ShowCursor(lua_State *L)
{
	if (lua_gettop(L)==1)
	{
		ShowCursor((BOOL)lua_toboolean(L,1));
	}
	return 0;
}


static int glMeasureText(lua_State *L) 
{
	if(lua_gettop(L)==1)
	{
		char *text=(char*)lua_tostring(L, 1);
		float		length=0;								// Used To Find The Length Of The Text
		for (unsigned int loop=0;loop<(strlen(text));loop++)	// Loop To Find Text Length
		{
			length+=gmf[text[loop]].gmfCellIncX;			// Increase Length By Each Characters Width
		}
		lua_pushnumber(L,length);
		lua_pushnumber(L,gmf['|'].gmfBlackBoxY);
		lua_pushnumber(L,gmf['b'].gmfBlackBoxY);
		return 3;
	}
	return 0;
}

static int Band(lua_State *L) 
{
	if(lua_gettop(L)==2)
	{
		int mx=(int)lua_tonumber(L, 1);
		int my=(int)lua_tonumber(L, 2);
		mx&=my;
		lua_pushnumber(L, mx);        
		return 1;
	}
	return 0;
}
static int Bor(lua_State *L) 
{
	if(lua_gettop(L)==2)
	{
		int mx=(int)lua_tonumber(L, 1);
		int my=(int)lua_tonumber(L, 2);
		mx|=my;
		lua_pushnumber(L, mx);        
		return 1;
	}
	return 0;
}
static int Bxor(lua_State *L) 
{
	if(lua_gettop(L)==2)
	{
		int mx=(int)lua_tonumber(L, 1);
		int my=(int)lua_tonumber(L, 2);
		mx^=my;
		lua_pushnumber(L, mx);        
		return 1;
	}
	return 0;
}

static int LuaMessageBox(lua_State *L)
{
	if(lua_gettop(L)==3)
	{
		char *text=(char*)lua_tostring(L, 1);
		char *caption=(char*)lua_tostring(L, 2);
		int type=(int)lua_tonumber(L, 3);
		int result=MessageBox(NULL,text,caption,type);
		lua_pushnumber(L, result);        
		return 1;
	}
	return 0;
}

static int lua_LoadSound(lua_State *L)
{
	if(lua_gettop(L)==1)
	{
		char *fname=(char*)lua_tostring(L,1);
		miDSound* newSound=new miDSound;
		newSound->InitDirectSound(hWnd);
		newSound->LoadWaveFile(hWnd,fname);
		lua_pushlightuserdata(L,newSound);
	}
	return 1;
}

static int lua_SetVolume(lua_State *L)
{
	if (lua_gettop(L)==2)
	{
		miDSound* p;
		LONG vol;
		if(lua_isuserdata(L,1) && lua_isnumber(L,2))
		{
			p=(miDSound*)lua_topointer(L,1);
			vol=(LONG)lua_tonumber(L,2);
			p->SetVolumeOnly(vol);
			return 1;
		}
	}
	return 0;
}

static int lua_PlaySound(lua_State *L)
{
	miDSound* p;
	if(lua_isuserdata(L,1))
	{
		p=(miDSound*)lua_topointer(L,1);
		if (p->IsBufferPlaying())
		{
			p->StopBuffer(TRUE);
		}
		p->PlayBuffer(FALSE);
	}
	return 0;
}

static int lua_LoopSound(lua_State *L)
{
	if(lua_isuserdata(L,1))
	{
		((miDSound*)lua_topointer(L,1))->PlayBuffer(TRUE);
	}
	return 0;
}

static int lua_StopSound(lua_State *L)
{
	miDSound* p;
	if(lua_isuserdata(L,1))
	{
		p=(miDSound*)lua_topointer(L,1);
		if (p->IsBufferPlaying())
		{
			p->StopBuffer(TRUE);
		}
	}
	return 0;
}

static int lua_FlipScreen(lua_State *L)
{
	SwapBuffers(hDC);
	return 0;
}

void winregister(lua_State *L)
{
	set(L,"MB_ABORTRETRYIGNORE",MB_ABORTRETRYIGNORE); 
	set(L,"MB_OK",MB_OK);
	set(L,"MB_OKCANCEL",MB_OKCANCEL);
	set(L,"MB_RETRYCANCEL",MB_RETRYCANCEL);
	set(L,"MB_YESNO",MB_YESNO);
	set(L,"MB_YESNOCANCEL",MB_YESNOCANCEL);
	set(L,"MB_ICONEXCLAMATION",MB_ICONEXCLAMATION);
	set(L,"MB_ICONINFORMATION",MB_ICONINFORMATION);
	set(L,"MB_ICONQUESTION",MB_ICONQUESTION);
	set(L,"MB_ICONSTOP",MB_ICONSTOP);
	set(L,"MB_DEFBUTTON1",MB_DEFBUTTON1);
	set(L,"MB_DEFBUTTON2",MB_DEFBUTTON2);
	set(L,"MB_DEFBUTTON3",MB_DEFBUTTON3);
	set(L,"IDYES",IDYES);
	set(L,"IDNO",IDNO);
	set(L,"IDRETRY",IDRETRY);
	set(L,"IDOK",IDOK);
}


void init()
{
	BuildFont();
	L = lua_open();
	luaL_openlibs(L);		// gets out of the sand box
	lua_register( L, "GetCWD",GetWorkingDirectory);
	lua_register( L, "GetOpenFileName",GetOpenFileName);
	lua_register( L, "GetSaveFileName",GetSaveFileName);
	lua_register( L, "doline",DoLine);
	lua_register( L, "Quit",Quit);	// after luaL_openlibs() to hijack print function
	lua_register( L, "SetTitle",SetTitle);	// after luaL_openlibs() to hijack print function
	lua_register( L, "print",luaB_print);	// after luaL_openlibs() to hijack print function
	lua_register( L, "HashFile",HashFile);
	lua_register( L, "glDrawText",glDrawText);
	lua_register( L, "Band",Band);
	lua_register( L, "Bor",Bor);
	lua_register( L, "Bxor",Bxor);
	lua_register( L, "GetPlanePoint",GetPlanePoint);
	lua_register( L, "glMeasureText",glMeasureText);
	lua_register( L, "MessageBox",LuaMessageBox);
	lua_register( L, "LoadSound",lua_LoadSound);
	lua_register( L, "PlaySound",lua_PlaySound);
	lua_register( L, "LoopSound",lua_LoopSound);
	lua_register( L, "StopSound",lua_StopSound);
	lua_register( L, "FlipScreen",lua_FlipScreen);
	lua_register( L, "SetVolume",lua_SetVolume);
	lua_register( L, "ShowCursor",lua_ShowCursor);
	winregister(L);
	LuaGlRegister(L);
	int status=luaL_dofile(L, "main.lua");
	report(L,status,"main.lua");
	ReSizeGLScene(gwidth,gheight);
}

GLvoid KillGLWindow(GLvoid)								// Properly Kill The Window
{
	if (fullscreen)										// Are We In Fullscreen Mode?
	{
		ChangeDisplaySettings(NULL,0);					// If So Switch Back To The Desktop
		ShowCursor(TRUE);								// Show Mouse Pointer
	}

	if (hRC)											// Do We Have A Rendering Context?
	{
		if (!wglMakeCurrent(NULL,NULL))					// Are We Able To Release The DC And RC Contexts?
		{
			MessageBox(NULL,"Release Of DC And RC Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		}

		if (!wglDeleteContext(hRC))						// Are We Able To Delete The RC?
		{
			MessageBox(NULL,"Release Rendering Context Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		}
		hRC=NULL;										// Set RC To NULL
	}

	if (hDC && !ReleaseDC(hWnd,hDC))					// Are We Able To Release The DC
	{
		MessageBox(NULL,"Release Device Context Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		hDC=NULL;										// Set DC To NULL
	}

	if (hWnd && !DestroyWindow(hWnd))					// Are We Able To Destroy The Window?
	{
		MessageBox(NULL,"Could Not Release hWnd.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		hWnd=NULL;										// Set hWnd To NULL
	}

	if (!UnregisterClass("OpenGL",hInstance))			// Are We Able To Unregister Class
	{
		MessageBox(NULL,"Could Not Unregister Class.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		hInstance=NULL;									// Set hInstance To NULL
	}
}

/*int DrawGLScene(GLvoid)									// Here's Where We Do All The Drawing
{
	LineReport(L,"Render()");
	return TRUE;										// Keep Going
}*/

/*	This Code Creates Our OpenGL Window.  Parameters Are:					*
 *	title			- Title To Appear At The Top Of The Window				*
 *	width			- Width Of The GL Window Or Fullscreen Mode				*
 *	height			- Height Of The GL Window Or Fullscreen Mode			*
 *	bits			- Number Of Bits To Use For Color (8/16/24/32)			*
 *	fullscreenflag	- Use Fullscreen Mode (TRUE) Or Windowed Mode (FALSE)	*/
 
BOOL CreateGLWindow(char* title, int width, int height, int bits, bool fullscreenflag)
{
	GLuint		PixelFormat;			// Holds The Results After Searching For A Match
	WNDCLASS	wc;						// Windows Class Structure
	DWORD		dwExStyle;				// Window Extended Style
	DWORD		dwStyle;				// Window Style
	RECT		WindowRect;				// Grabs Rectangle Upper Left / Lower Right Values
	WindowRect.left=(long)0;			// Set Left Value To 0
	WindowRect.right=(long)width;		// Set Right Value To Requested Width
	WindowRect.top=(long)0;				// Set Top Value To 0
	WindowRect.bottom=(long)height;		// Set Bottom Value To Requested Height

	fullscreen=fullscreenflag;			// Set The Global Fullscreen Flag

	hInstance			= GetModuleHandle(NULL);				// Grab An Instance For Our Window
	wc.style			= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;	// Redraw On Size, And Own DC For Window.
	wc.lpfnWndProc		= (WNDPROC) WndProc;					// WndProc Handles Messages
	wc.cbClsExtra		= 0;									// No Extra Window Data
	wc.cbWndExtra		= 0;									// No Extra Window Data
	wc.hInstance		= hInstance;							// Set The Instance
	wc.hIcon			= LoadIcon(NULL, IDI_WINLOGO);			// Load The Default Icon
	wc.hCursor			= LoadCursor(NULL, IDC_ARROW);			// Load The Arrow Pointer
	wc.hbrBackground	= NULL;									// No Background Required For GL
	wc.lpszMenuName		= NULL;									// We Don't Want A Menu
	wc.lpszClassName	= "OpenGL";								// Set The Class Name

	if (!RegisterClass(&wc))									// Attempt To Register The Window Class
	{
		MessageBox(NULL,"Failed To Register The Window Class.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;											// Return FALSE
	}
	
	if (fullscreen)												// Attempt Fullscreen Mode?
	{
		DEVMODE dmScreenSettings;								// Device Mode
		memset(&dmScreenSettings,0,sizeof(dmScreenSettings));	// Makes Sure Memory's Cleared
		dmScreenSettings.dmSize=sizeof(dmScreenSettings);		// Size Of The Devmode Structure
		dmScreenSettings.dmPelsWidth	= width;				// Selected Screen Width
		dmScreenSettings.dmPelsHeight	= height;				// Selected Screen Height
		dmScreenSettings.dmBitsPerPel	= bits;					// Selected Bits Per Pixel
		dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;

		// Try To Set Selected Mode And Get Results.  NOTE: CDS_FULLSCREEN Gets Rid Of Start Bar.
		if (ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN)!=DISP_CHANGE_SUCCESSFUL)
		{
			// If The Mode Fails, Offer Two Options.  Quit Or Use Windowed Mode.
			if (MessageBox(NULL,"The Requested Fullscreen Mode Is Not Supported By\nYour Video Card. Use Windowed Mode Instead?","NeHe GL",MB_YESNO|MB_ICONEXCLAMATION)==IDYES)
			{
				fullscreen=FALSE;		// Windowed Mode Selected.  Fullscreen = FALSE
			}
			else
			{
				// Pop Up A Message Box Letting User Know The Program Is Closing.
				MessageBox(NULL,"Program Will Now Close.","ERROR",MB_OK|MB_ICONSTOP);
				return FALSE;									// Return FALSE
			}
		}
	}

	if (fullscreen)												// Are We Still In Fullscreen Mode?
	{
		dwExStyle=WS_EX_APPWINDOW;								// Window Extended Style
		dwStyle=WS_POPUP;										// Windows Style
		ShowCursor(FALSE);										// Hide Mouse Pointer
	}
	else
	{
		dwExStyle=WS_EX_APPWINDOW| WS_EX_WINDOWEDGE;			// Window Extended Style
		dwStyle=WS_OVERLAPPED|WS_CAPTION|WS_SYSMENU|WS_MAXIMIZEBOX;							// Windows Style
		//ShowCursor(FALSE);										// Hide Mouse Pointer
	}

	AdjustWindowRectEx(&WindowRect, dwStyle, FALSE, dwExStyle);		// Adjust Window To True Requested Size

	// Create The Window
	if (!(hWnd=CreateWindowEx(	dwExStyle,							// Extended Style For The Window
								"OpenGL",							// Class Name
								title,								// Window Title
								dwStyle |							// Defined Window Style
								WS_CLIPSIBLINGS |					// Required Window Style
								WS_CLIPCHILDREN,					// Required Window Style
								0, 0,								// Window Position
								WindowRect.right-WindowRect.left,	// Calculate Window Width
								WindowRect.bottom-WindowRect.top,	// Calculate Window Height
								NULL,								// No Parent Window
								NULL,								// No Menu
								hInstance,							// Instance
								NULL)))								// Dont Pass Anything To WM_CREATE
	{
		KillGLWindow();								// Reset The Display
		MessageBox(NULL,"Window Creation Error.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	static	PIXELFORMATDESCRIPTOR pfd=				// pfd Tells Windows How We Want Things To Be
	{
		sizeof(PIXELFORMATDESCRIPTOR),				// Size Of This Pixel Format Descriptor
		1,											// Version Number
		PFD_DRAW_TO_WINDOW |						// Format Must Support Window
		PFD_SUPPORT_OPENGL |						// Format Must Support OpenGL
		PFD_DOUBLEBUFFER,							// Must Support Double Buffering
		PFD_TYPE_RGBA,								// Request An RGBA Format
		bits,										// Select Our Color Depth
		0, 0, 0, 0, 0, 0,							// Color Bits Ignored
		0,											// No Alpha Buffer
		0,											// Shift Bit Ignored
		0,											// No Accumulation Buffer
		0, 0, 0, 0,									// Accumulation Bits Ignored
		16,											// 16Bit Z-Buffer (Depth Buffer)  
		0,											// No Stencil Buffer
		0,											// No Auxiliary Buffer
		PFD_MAIN_PLANE,								// Main Drawing Layer
		0,											// Reserved
		0, 0, 0										// Layer Masks Ignored
	};
	
	if (!(hDC=GetDC(hWnd)))							// Did We Get A Device Context?
	{
		KillGLWindow();								// Reset The Display
		MessageBox(NULL,"Can't Create A GL Device Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if (!(PixelFormat=ChoosePixelFormat(hDC,&pfd)))	// Did Windows Find A Matching Pixel Format?
	{
		KillGLWindow();								// Reset The Display
		MessageBox(NULL,"Can't Find A Suitable PixelFormat.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if(!SetPixelFormat(hDC,PixelFormat,&pfd))		// Are We Able To Set The Pixel Format?
	{
		KillGLWindow();								// Reset The Display
		MessageBox(NULL,"Can't Set The PixelFormat.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if (!(hRC=wglCreateContext(hDC)))				// Are We Able To Get A Rendering Context?
	{
		KillGLWindow();								// Reset The Display
		MessageBox(NULL,"Can't Create A GL Rendering Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if(!wglMakeCurrent(hDC,hRC))					// Try To Activate The Rendering Context
	{
		KillGLWindow();								// Reset The Display
		MessageBox(NULL,"Can't Activate The GL Rendering Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	ShowWindow(hWnd,SW_SHOW);						// Show The Window
	SetForegroundWindow(hWnd);						// Slightly Higher Priority
	SetFocus(hWnd);									// Sets Keyboard Focus To The Window
	ReSizeGLScene(width, height);					// Set Up Our Perspective GL Screen

	if (!InitGL())									// Initialize Our Newly Created GL Window
	{
		KillGLWindow();								// Reset The Display
		MessageBox(NULL,"Initialization Failed.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	return TRUE;									// Success
}

LRESULT CALLBACK WndProc(	HWND	hWnd,			// Handle For This Window
							UINT	uMsg,			// Message For This Window
							WPARAM	wParam,			// Additional Message Information
							LPARAM	lParam)			// Additional Message Information
{
	switch (uMsg)									// Check For Windows Messages
	{
	case WM_LBUTTONDOWN:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnLButtonDown(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_LBUTTONUP:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnLButtonUp(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_RBUTTONDOWN:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnRButtonDown(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_RBUTTONUP:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnRButtonUp(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_MBUTTONDOWN:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnMButtonDown(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_MBUTTONUP:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnMButtonUp(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_LBUTTONDBLCLK:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnLButtonDblClk(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_RBUTTONDBLCLK:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnRButtonDblClk(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_MBUTTONDBLCLK:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnMButtonDblClk(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
	case WM_MOUSELEAVE:
		{
			if(L)
			{
				LineReport(L,"OnMouseLeave()");
			}
			return 0;
		}
		break;
	case WM_MOUSEMOVE:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnMouseMove(%d,%d,%d)",wParam,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
	case WM_MOUSEWHEEL:
		{
			if(L)
			{
				char buffer[100];
				sprintf(buffer,"OnMouseWheel(%d,%d,%d,%d)",wParam&0xffff,wParam>>16,lParam&0xffff,lParam>>16);
				LineReport(L,buffer);
			}
			return 0;
		}
		break;
		case WM_TIMER:
		{
			if(L)
			{
				LineReport(L,"OnTimer()");
				LineReport(L,"Render()");
			}
			return 0;								// Jump Back
		}
		case WM_ACTIVATE:							// Watch For Window Activate Message
		{
			if (!HIWORD(wParam))					// Check Minimization State
			{
				active=TRUE;						// Program Is Active
			}
			else
			{
				active=FALSE;						// Program Is No Longer Active
			}

			return 0;								// Return To The Message Loop
		}

		case WM_SYSCOMMAND:							// Intercept System Commands
		{
			switch (wParam)							// Check System Calls
			{
				case SC_SCREENSAVE:					// Screensaver Trying To Start?
				case SC_MONITORPOWER:				// Monitor Trying To Enter Powersave?
				return 0;							// Prevent From Happening
			}
			break;									// Exit
		}

		case WM_CLOSE:								// Did We Receive A Close Message?
		{
			lua_getfield(L, LUA_GLOBALSINDEX, "CloseProgram"); /* function to be called */
			lua_call(L, 0, 1);     /* call 'f' with 3 arguments and 1 result */
			lua_Number tmp = lua_tonumber(L, lua_gettop(L));
			lua_pop(L, 1);
			if(tmp)
				PostQuitMessage(0);						// Send A Quit Message
			return 0;								// Jump Back
		}

		case WM_KEYDOWN:							// Is A Key Being Held Down?
		{
			if(L)
			{
				char s[100];
				sprintf(s,"KeyDown(%d)",wParam);
				LineReport(L,s);
				keys[wParam] = TRUE;					// If So, Mark It As TRUE
				return 0;								// Jump Back
			}
		}

		case WM_KEYUP:								// Has A Key Been Released?
		{
			if(L)
			{
				char s[100];
				sprintf(s,"KeyUp(%d)",wParam);
				LineReport(L,s);
				keys[wParam] = FALSE;					// If So, Mark It As FALSE
			}
			return 0;								// Jump Back
		}

		case WM_SIZE:								// Resize The OpenGL Window
		{
			ReSizeGLScene(LOWORD(lParam),HIWORD(lParam));  // LoWord=Width, HiWord=Height
			return 0;								// Jump Back
		}
	}

	// Pass All Unhandled Messages To DefWindowProc
	return DefWindowProc(hWnd,uMsg,wParam,lParam);
}

int WINAPI WinMain(	HINSTANCE	hInstance,			// Instance
					HINSTANCE	hPrevInstance,		// Previous Instance
					LPSTR		lpCmdLine,			// Command Line Parameters
					int			nCmdShow)			// Window Show State
{
	MSG		msg;									// Windows Message Structure
	BOOL	done=FALSE;								// Bool Variable To Exit Loop

	// Ask The User Which Screen Mode They Prefer

//	if (MessageBox(NULL,"Would You Like To Run In Fullscreen Mode?", "Start FullScreen?",MB_YESNO|MB_ICONQUESTION)==IDNO)
	{
		fullscreen=FALSE;							// Windowed Mode
	}

	// Create Our OpenGL Window
	if (!CreateGLWindow("Dr. Bone",1024,768,32,fullscreen))
	{
		return 0;									// Quit If Window Was Not Created
	}

	init();

	ptimer=SetTimer(hWnd,1,10,0);		// appox 60 htz

	while(!done)									// Loop That Runs While done=FALSE
	{
		if (PeekMessage(&msg,NULL,0,0,PM_REMOVE))	// Is There A Message Waiting?
		{
			if (msg.message==WM_QUIT || quit)				// Have We Received A Quit Message?
			{
				done=TRUE;							// If So done=TRUE
			}
			else									// If Not, Deal With Window Messages
			{
				TranslateMessage(&msg);				// Translate The Message
				DispatchMessage(&msg);				// Dispatch The Message
			}
		}
	}

	// Shutdown
	KillFont();
	KillGLWindow();									// Kill The Window
	KillTimer(hWnd,ptimer);
	lua_close(L);
	if(tracefile)
		fclose(tracefile);
	return (msg.wParam);							// Exit The Program
}
