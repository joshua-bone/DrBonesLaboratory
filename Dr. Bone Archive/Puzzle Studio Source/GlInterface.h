#include <windows.h>		// Header File For Windows
#include <stdio.h>			// Header File For Standard Input/Output
#include <stdarg.h>			// Header File For Variable Argument Routines

#include <gl\gl.h>			// Header File For The OpenGL32 Library
#include <gl\glu.h>			// Header File For The GLu32 Library
#include <gl\glaux.h>		// Header File For The Glaux Library

extern "C" {
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
}

void LuaGlRegister(lua_State* L);
void set(lua_State* L,char *s,int v);
