// Rearranged by Andrew Heinlein (Mouse)
// Original contents found in the DirectX7 SDK
// <8O~ mouseindustries ~O8> http://www.theblackhand.net
// mouse@theblackhand.net
// include these libs! dsound.lib winmm.lib 

#ifndef __MIDSOUND_H__
#define __MIDSOUND_H__

#include <windows.h>
#include <dsound.h>
#include <mmreg.h>
#include <mmsystem.h>

#define SAFE_DELETE(p) {if(p){delete (p);     (p) = NULL;}}
#define SAFE_RELEASE(p){if(p){(p)->Release(); (p) = NULL;}}

class miDSound{
	public:


	public:
		miDSound();
		virtual ~miDSound();
		
		HRESULT InitDirectSound(HWND hDlg);
		BOOL LoadWaveFile(HWND hDlg, TCHAR* strFileName);
		HRESULT PlayBuffer(BOOL bLooped);
		BOOL IsBufferPlaying();
		VOID StopBuffer(BOOL bResetPosition);
		BOOL IsSoundPlaying();
		VOID SetBufferOptions(LONG lFrequency, LONG lPan, LONG lVolume);
		VOID SetVolumeOnly(LONG lVolume);

	protected:
		/* WAVE READ PROTOTYPTES */
		WAVEFORMATEX* m_pwfx;
		HMMIO         m_hmmioIn;
		MMCKINFO      m_ckIn;
		MMCKINFO      m_ckInRiff;

		HRESULT Open( CHAR* strFilename );
		HRESULT Reset();
		HRESULT Read( UINT nSizeToRead, BYTE* pbData, UINT* pnSizeRead );
		HRESULT Close();
		
		/* DSOUND PROTOTYPES */
		LPDIRECTSOUND       g_pDS;
		LPDIRECTSOUNDBUFFER g_pDSBuffer;
		LPDIRECTSOUNDNOTIFY g_pDSNotify;
		DWORD               g_dwBufferBytes;

		HRESULT CreateStaticBuffer( HWND hDlg, TCHAR* strFileName );
		HRESULT FillBuffer();
		HRESULT RestoreBuffers();
		HRESULT FreeDirectSound();
};

#endif /* __MIDSOUND_H__ */