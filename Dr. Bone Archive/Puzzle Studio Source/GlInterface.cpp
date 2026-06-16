#include "glinterface.h"


extern "C" {
	#include "lua.h"
	#include "lualib.h"
	#include "lauxlib.h"
}

AUX_RGBImageRec *LoadBMP(char *Filename)				// Loads A Bitmap Image
{
	FILE *File=NULL;									// File Handle

	if (!Filename)										// Make Sure A Filename Was Given
	{
		return NULL;									// If Not Return NULL
	}

	File=fopen(Filename,"r");							// Check To See If The File Exists

	if (File)											// Does The File Exist?
	{
		fclose(File);									// Close The Handle
		return auxDIBImageLoad(Filename);				// Load The Bitmap And Return A Pointer
	}

	return NULL;										// If Load Failed Return NULL
}

int LoadGLTexture(lua_State *L)									// Load Bitmaps And Convert To Textures
{
	if(lua_gettop(L)==1)
	{
		GLuint	texture[1];			// Storage For One Texture ( NEW )
		int Status=FALSE;									// Status Indicator

		AUX_RGBImageRec *TextureImage[1];					// Create Storage Space For The Texture

		memset(TextureImage,0,sizeof(void *)*1);           	// Set The Pointer To NULL

		// Load The Bitmap, Check For Errors, If Bitmap's Not Found Quit
		char *filename=(char*)lua_tolstring(L, 1,0);
		if (TextureImage[0]=LoadBMP(filename))
		{
			Status=TRUE;									// Set The Status To TRUE

			glGenTextures(1, &texture[0]);					// Create The Texture

			// Typical Texture Generation Using Data From The Bitmap
			glBindTexture(GL_TEXTURE_2D, texture[0]);
			glTexImage2D(GL_TEXTURE_2D, 0, 3, TextureImage[0]->sizeX, TextureImage[0]->sizeY, 0, GL_RGB, GL_UNSIGNED_BYTE, TextureImage[0]->data);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
			glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
		}

		if (TextureImage[0])									// If Texture Exists
		{
			if (TextureImage[0]->data)							// If Texture Image Exists
			{
				free(TextureImage[0]->data);					// Free The Texture Image Memory
			}

			free(TextureImage[0]);								// Free The Image Structure
		}

		if(Status)
		{
			lua_Number sum = texture[0];
			lua_pushnumber(L, sum);         /* second result */
			return 1;
		}
	}
	return 0;										// Return The Status
}

static int lua_glBegin(lua_State *L)
{
	if(lua_gettop(L)==1)
		glBegin((int)lua_tonumber(L, 1));
	return 0;
}

static int lua_glBlendFunc(lua_State *L)
{
	if(lua_gettop(L)==2)
		glBlendFunc((int)lua_tonumber(L, 1), (int)lua_tonumber(L,2));	
	return 0;
}

static int lua_glBindTexture(lua_State *L)
{
	if(lua_gettop(L)==2)
		glBindTexture((int)lua_tonumber(L, 1),(int)lua_tonumber(L, 2));	
	return 0;
}

static int lua_glCallList(lua_State *L)
{
	if(lua_gettop(L)==1)
		glCallList((int)lua_tonumber(L, 1));
	return 0;
}

static int lua_glClear(lua_State *L)
{
	if(lua_gettop(L)==1)
		glClear((int)lua_tonumber(L, 1));	
	return 0;
}

static int lua_glClearColor(lua_State *L)
{
	if(lua_gettop(L)==4)
		glClearColor((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2), (GLfloat)lua_tonumber(L, 3), (GLfloat)lua_tonumber(L, 4));	
	return 0;
}

static int lua_glClearDepth(lua_State *L)
{
	if(lua_gettop(L)==1)
		glClearDepth(lua_tonumber(L, 1));	
	return 0;
}

static int lua_glColor3f(lua_State *L)
{
	if(lua_gettop(L)==3)
		glColor3f((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2),(GLfloat)lua_tonumber(L, 3));
	return 0;
}

static int lua_glColor4f(lua_State *L)
{
	if(lua_gettop(L)==4)
		glColor4f((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2),(GLfloat)lua_tonumber(L, 3),(GLfloat)lua_tonumber(L, 4));
	return 0;
}

static int lua_glColorMaterial(lua_State *L)
{
  if(lua_gettop(L)==2)
    glColorMaterial((int)lua_tonumber(L, 1),(int)lua_tonumber(L,2));
  return 0;
}

static int lua_glDepthFunc(lua_State *L)
{
	if(lua_gettop(L)==1)
		glDepthFunc((int)lua_tonumber(L, 1));	
	return 0;
}

static int lua_glDisable(lua_State *L)
{
	if(lua_gettop(L)==1)
		glDisable((int)lua_tonumber(L, 1));	
	return 0;
}

static int lua_glEnable(lua_State *L)
{
	if(lua_gettop(L)==1)
		glEnable((int)lua_tonumber(L, 1));	
	return 0;
}

static int lua_glEnd(lua_State *L)
{
	if(lua_gettop(L)==0)
		glEnd();
	return 0;
}

static int lua_glEndList(lua_State *L)
{
	if(lua_gettop(L)==0)
		glEndList();
	return 1;
}

static int lua_glGenLists(lua_State *L)
{
	if(lua_gettop(L)==1)
		lua_pushnumber(L,glGenLists((int)lua_tonumber(L, 1)));
	return 1;
}

static int lua_glHint(lua_State *L)
{
	if(lua_gettop(L)==2)
		glHint((int)lua_tonumber(L, 1),(int)lua_tonumber(L, 2));	
	return 0;
}

static int lua_glLightfv(lua_State *L)
{
	if(lua_gettop(L)==6)
	{
		GLfloat params[4];
		params[0]=(GLfloat)lua_tonumber(L, 3);
		params[1]=(GLfloat)lua_tonumber(L, 4);
		params[2]=(GLfloat)lua_tonumber(L, 5);
		params[3]=(GLfloat)lua_tonumber(L, 6);
		glLightfv((int)lua_tonumber(L, 1),(int)lua_tonumber(L, 2),params);
	}
	return 0;
}

static int lua_glLineWidth(lua_State *L)
{
	if(lua_gettop(L)==1)
		glLineWidth((GLfloat)lua_tonumber(L, 1));	
	return 0;
}

static int lua_glLoadIdentity(lua_State *L)
{
	if(lua_gettop(L)==0)
		glLoadIdentity();	
	return 0;
}

static int lua_glMatrixMode(lua_State *L)
{
	if(lua_gettop(L)==1)
		glMatrixMode((int)lua_tonumber(L, 1));
	return 0;
}

static int lua_glNewList(lua_State *L)
{
	if(lua_gettop(L)==2)
		glNewList((int)lua_tonumber(L, 1),(int)lua_tonumber(L, 2));
	return 0;
}

static int lua_glNormal3f(lua_State *L)
{
	if(lua_gettop(L)==3)
	{
		glNormal3f((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2),(GLfloat)lua_tonumber(L, 3));
	}
	return 0;
}

static int lua_glOrtho(lua_State *L)
{
	if(lua_gettop(L)==6)
		glOrtho(
		(int)lua_tonumber(L, 1),
		(int)lua_tonumber(L, 2),
		(int)lua_tonumber(L, 3),
		(int)lua_tonumber(L, 4),
		(int)lua_tonumber(L, 5),
		(int)lua_tonumber(L, 6)
		);
	return 0;
}

static int lua_glPopMatrix(lua_State *L)
{
	if(lua_gettop(L)==0)
		glPopMatrix();	
	return 0;
}

static int lua_glPushMatrix(lua_State *L)
{
	if(lua_gettop(L)==0)
		glPushMatrix();	
	return 0;
}

static int lua_glRasterPos2f(lua_State *L)
{
	if(lua_gettop(L)==2)
		glRasterPos2f((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2));	
	return 0;
}

static int lua_glRotatef(lua_State *L)
{
	if(lua_gettop(L)==4)
		glRotatef((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2),(GLfloat)lua_tonumber(L, 3),(GLfloat)lua_tonumber(L, 4));	
	return 0;
}

static int lua_glScalef(lua_State *L)
{
	if(lua_gettop(L)==3)
		glScalef((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2),(GLfloat)lua_tonumber(L, 3));	
	return 0;
}

static int lua_glShadeModel(lua_State *L)
{
	if(lua_gettop(L)==1)
		glShadeModel((int)lua_tonumber(L, 1));	
	return 0;
}

static int lua_glTexCoord2f(lua_State *L)
{
	if(lua_gettop(L)==2)
		glTexCoord2f((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2));	
	return 0;
}

static int lua_glTranslatef(lua_State *L)
{
	if(lua_gettop(L)==3)
		glTranslatef((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2),(GLfloat)lua_tonumber(L, 3));	
	return 0;
}

static int lua_glVertex2f (lua_State *L)
{
	if(lua_gettop(L)==2)
		glVertex2f((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2));	
	return 0;
}

static int lua_glVertex3f (lua_State *L)
{
	if(lua_gettop(L)==3)
		glVertex3f((GLfloat)lua_tonumber(L, 1),(GLfloat)lua_tonumber(L, 2), (GLfloat)lua_tonumber(L, 3));	
	return 0;
}

static int lua_int(lua_State *L)
{
	if(lua_gettop(L)==1)
		lua_pushnumber(L,(float)((int)lua_tonumber(L, 1)));
	return 1;
}

void set(lua_State* L,char *s,int v)
{
	char c[100];
	sprintf(c,"%s=%d",s,v);
	luaL_dostring(L,c);
}

void LuaGlRegister(lua_State* L)
{
	lua_register( L, "glBegin",lua_glBegin );
	lua_register( L, "glBindTexture",lua_glBindTexture );
	lua_register( L, "glBlendFunc",lua_glBlendFunc );
	lua_register( L, "glCallList",lua_glCallList);
	lua_register( L, "glClear",lua_glClear );
	lua_register( L, "glClearColor",lua_glClearColor );
	lua_register( L, "glClearDepth",lua_glClearDepth );
	lua_register( L, "glColor3f",lua_glColor3f );
	lua_register( L, "glColor4f",lua_glColor4f );
	lua_register( L, "glDepthFunc",lua_glDepthFunc );
	lua_register( L, "glColorMaterial",lua_glColorMaterial );
	lua_register( L, "glDisable",lua_glDisable );
	lua_register( L, "glEnable",lua_glEnable );
	lua_register( L, "glEnd",lua_glEnd );
	lua_register( L, "glEndList",lua_glEndList);
	lua_register( L, "glGenLists",lua_glGenLists);
	lua_register( L, "glHint",lua_glHint );
	lua_register( L, "glLightfv",lua_glLightfv);
	lua_register( L, "glLineWidth",lua_glLineWidth);
	lua_register( L, "glLoadIdentity",lua_glLoadIdentity );  
	lua_register( L, "glMatrixMode",lua_glMatrixMode);
	lua_register( L, "glNewList",lua_glNewList);
	lua_register( L, "glNormal3f",lua_glNormal3f);  
	lua_register( L, "glOrtho",lua_glOrtho);
	lua_register( L, "glPopMatrix",lua_glPopMatrix );
	lua_register( L, "glPushMatrix",lua_glPushMatrix );
	lua_register( L, "glRasterPos2f",lua_glRasterPos2f);
	lua_register( L, "glRotatef",lua_glRotatef );
	lua_register( L, "glScalef",lua_glScalef );
	lua_register( L, "glShadeModel",lua_glShadeModel );
	lua_register( L, "glTexCoord2f",lua_glTexCoord2f );
	lua_register( L, "glTranslatef",lua_glTranslatef );
	lua_register( L, "glVertex2f",lua_glVertex2f );
	lua_register( L, "glVertex3f",lua_glVertex3f );
  
	lua_register( L, "int",lua_int);
	lua_register( L, "LoadTexture",LoadGLTexture );

//glBegin() & glEnd()
	set(L,"GL_POINTS",GL_POINTS);
	set(L,"GL_LINES",GL_LINES);
	set(L,"GL_LINE_STRIP",GL_LINE_STRIP);
	set(L,"GL_LINE_LOOP",GL_LINE_LOOP);
	set(L,"GL_TRIANGLES",GL_TRIANGLES);
	set(L,"GL_TRIANGLE_STRIP",GL_TRIANGLE_STRIP);
	set(L,"GL_TRIANGLE_FAN",GL_TRIANGLE_FAN);
	set(L,"GL_QUADS",GL_QUADS);
	set(L,"GL_QUAD_STRIP",GL_QUAD_STRIP);
  set(L,"GL_POLYGON",GL_POLYGON);

//glBindTexture()
  set(L,"GL_TEXTURE_1D",GL_TEXTURE_1D);
  set(L,"GL_TEXTURE_2D",GL_TEXTURE_2D);
  //set(L,"GL_TEXTURE_3D",GL_TEXTURE_3D);
  //set(L,"GL_TEXTURE_CUBE_MAP",GL_TEXTURE_CUBE_MAP);

//glBlendFunc()
  set(L,"GL_ZERO",GL_ZERO);
  set(L,"GL_ONE",GL_ONE);
  set(L,"GL_SRC_COLOR",GL_SRC_COLOR);
  set(L,"GL_ONE_MINUS_SRC_COLOR",GL_ONE_MINUS_SRC_COLOR);
  set(L,"GL_DST_COLOR",GL_DST_COLOR);
  set(L,"GL_ONE_MINUS_DST_COLOR",GL_ONE_MINUS_DST_COLOR);
  set(L,"GL_SRC_ALPHA",GL_SRC_ALPHA);
  set(L,"GL_ONE_MINUS_SRC_ALPHA",GL_ONE_MINUS_SRC_ALPHA);
  set(L,"GL_DST_ALPHA",GL_DST_ALPHA);
  set(L,"GL_ONE_MINUS_DST_ALPHA",GL_ONE_MINUS_DST_ALPHA);
  /*
  set(L,"GL_CONSTANT_COLOR",GL_CONSTANT_COLOR);
  set(L,"GL_ONE_MINUS_CONSTANT_COLOR",GL_ONE_MINUS_CONSTANT_COLOR);
  set(L,"GL_CONSTANT_ALPHA",GL_CONSTANT_ALPHA);
  set(L,"GL_ONE_MINUS_CONSTANT_ALPHA",GL_ONE_MINUS_CONSTANT_ALPHA);
  */
  set(L,"GL_SRC_ALPHA_SATURATE",GL_SRC_ALPHA_SATURATE);

//glCallList()
//glClear()
  set(L,"GL_COLOR_BUFFER_BIT",GL_COLOR_BUFFER_BIT);
  set(L,"GL_DEPTH_BUFFER_BIT",GL_DEPTH_BUFFER_BIT);
  set(L,"GL_ACCUM_BUFFER_BIT",GL_ACCUM_BUFFER_BIT);
  set(L,"GL_STENCIL_BUFFER_BIT",GL_STENCIL_BUFFER_BIT);
//glClearColor(), glClearDepth(), glColor3f, glColor4f
//glColorMaterial()
  set(L,"GL_FRONT",GL_FRONT);
  set(L,"GL_BACK",GL_BACK);
  set(L,"GL_FRONT_AND_BACK",GL_FRONT_AND_BACK);
  set(L,"GL_EMISSION",GL_EMISSION);
  set(L,"GL_AMBIENT_AND_DIFFUSE",GL_AMBIENT_AND_DIFFUSE);
//glDepthFunc()
	set(L,"GL_NEVER",GL_NEVER);
	set(L,"GL_LESS",GL_LESS);
	set(L,"GL_EQUAL",GL_EQUAL);
	set(L,"GL_LEQUAL",GL_LEQUAL);
	set(L,"GL_GREATER",GL_GREATER);
	set(L,"GL_NOTEQUAL",GL_NOTEQUAL);
	set(L,"GL_GEQUAL",GL_GEQUAL);
	set(L,"GL_ALWAYS ",GL_ALWAYS);
//glDisable() & glEnable()              //INCOMPLETE OF COURSE, ADD AS NEEDED
	set(L,"GL_BLEND",GL_BLEND);
	set(L,"GL_DEPTH_TEST",GL_DEPTH_TEST);
	set(L,"GL_LIGHT1",GL_LIGHT1);
  set(L,"GL_LIGHTING",GL_LIGHTING);
  set(L,"GL_COLOR_MATERIAL",GL_COLOR_MATERIAL);
//glGenLists()
//glHint()
	set(L,"GL_PERSPECTIVE_CORRECTION_HINT",GL_PERSPECTIVE_CORRECTION_HINT);
	set(L,"GL_NICEST",GL_NICEST);
  set(L,"GL_FASTEST",GL_FASTEST);
  set(L,"GL_DONT_CARE",GL_DONT_CARE);
//glLightfv()
	set(L,"GL_AMBIENT",GL_AMBIENT);
	set(L,"GL_DIFFUSE",GL_DIFFUSE);
	set(L,"GL_SPECULAR",GL_SPECULAR);
  set(L,"GL_POSITION",GL_POSITION);
	set(L,"GL_SPOT_CUTOFF",GL_SPOT_CUTOFF);
	set(L,"GL_SPOT_DIRECTION",GL_SPOT_DIRECTION);
  set(L,"GL_SPOT_EXPONENT",GL_SPOT_EXPONENT);
	set(L,"GL_CONSTANT_ATTENUATION",GL_CONSTANT_ATTENUATION);
	set(L,"GL_LINEAR_ATTENUATION",GL_LINEAR_ATTENUATION);
  set(L,"GL_QUADRATIC_ATTENUATION",GL_QUADRATIC_ATTENUATION);
//glMatrixMode
	set(L,"GL_MODELVIEW",GL_MODELVIEW);
	set(L,"GL_PROJECTION",GL_PROJECTION);
	set(L,"GL_TEXTURE",GL_TEXTURE);
  set(L,"GL_COLOR",GL_COLOR);
//glNewList()
	set(L,"GL_COMPILE",GL_COMPILE);
  set(L,"GL_COMPILE_AND_EXECUTE",GL_COMPILE_AND_EXECUTE);
//glShadeModel()
	set(L,"GL_SMOOTH",GL_SMOOTH);
  set(L,"GL_FLAT",GL_FLAT);

	luaL_dostring(L,"PLATFORM='gl3d'");
}



