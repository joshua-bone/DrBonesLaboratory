// Rearranged by Andrew Heinlein (Mouse)
// Original contents found in the DirectX7 SDK
// <8O~ mouseindustries ~O8> http://www.theblackhand.net
// mouse@theblackhand.net
// include these libs! dsound.lib winmm.lib 

#include "miDSound.h"

miDSound::miDSound(){
	m_pwfx			 = NULL;
	g_pDS            = NULL;
	g_pDSBuffer      = NULL;
	g_pDSNotify      = NULL;

}

miDSound::~miDSound(){
    Close();
	SAFE_DELETE(m_pwfx);
	StopBuffer(TRUE);
	FreeDirectSound();
}

/************************ WAVE FUNCTIONS ******************************/
HRESULT ReadMMIO( HMMIO hmmioIn, MMCKINFO* pckInRIFF, WAVEFORMATEX** ppwfxInfo ){
	MMCKINFO        ckIn;
	PCMWAVEFORMAT   pcmWaveFormat;      
	*ppwfxInfo = NULL;

	if((0 != mmioDescend(hmmioIn, pckInRIFF, NULL, 0))){return E_FAIL;}
	if((pckInRIFF->ckid != FOURCC_RIFF) || (pckInRIFF->fccType != mmioFOURCC('W', 'A', 'V', 'E') ) ){return E_FAIL;}
	ckIn.ckid = mmioFOURCC('f', 'm', 't', ' ');
	if(0 != mmioDescend(hmmioIn, &ckIn, pckInRIFF, MMIO_FINDCHUNK)){return E_FAIL;}
	if(ckIn.cksize < (LONG)sizeof(PCMWAVEFORMAT)){return E_FAIL;}
	if(mmioRead(hmmioIn, (HPSTR) &pcmWaveFormat, sizeof(pcmWaveFormat)) != sizeof(pcmWaveFormat)){return E_FAIL;}
	if( pcmWaveFormat.wf.wFormatTag == WAVE_FORMAT_PCM ){
		if(NULL == (*ppwfxInfo = new WAVEFORMATEX)){return E_FAIL;}
		memcpy( *ppwfxInfo, &pcmWaveFormat, sizeof(pcmWaveFormat));
		(*ppwfxInfo)->cbSize = 0;
	}else{
		WORD cbExtraBytes = 0L;
		if(mmioRead(hmmioIn, (CHAR*)&cbExtraBytes, sizeof(WORD)) != sizeof(WORD)){return E_FAIL;}
		*ppwfxInfo = (WAVEFORMATEX*) new CHAR[ sizeof(WAVEFORMATEX) + cbExtraBytes ];
		if(NULL == *ppwfxInfo){return E_FAIL;}
		memcpy(*ppwfxInfo, &pcmWaveFormat, sizeof(pcmWaveFormat));
		(*ppwfxInfo)->cbSize = cbExtraBytes;
		if(mmioRead(hmmioIn, (CHAR*)(((BYTE*)&((*ppwfxInfo)->cbSize))+sizeof(WORD)), cbExtraBytes ) != cbExtraBytes ){
			delete *ppwfxInfo;
			*ppwfxInfo = NULL;
			return E_FAIL;
		}
	}
	if(0 != mmioAscend( hmmioIn, &ckIn, 0)){
		delete *ppwfxInfo;
		*ppwfxInfo = NULL;
		return E_FAIL;
	}
	return S_OK;
}

HRESULT WaveOpenFile( CHAR* strFileName, HMMIO* phmmioIn, WAVEFORMATEX** ppwfxInfo, MMCKINFO* pckInRIFF ){
    HRESULT hr;
    HMMIO   hmmioIn = NULL;
    if(NULL == (hmmioIn = mmioOpen( strFileName, NULL, MMIO_ALLOCBUF|MMIO_READ))){return E_FAIL;}
	if(FAILED(hr = ReadMMIO(hmmioIn, pckInRIFF, ppwfxInfo))){
		mmioClose( hmmioIn, 0 );
		return hr;
    }
	*phmmioIn = hmmioIn;
	return S_OK;
}

HRESULT WaveStartDataRead(HMMIO* phmmioIn, MMCKINFO* pckIn, MMCKINFO* pckInRIFF){
    if( -1 == mmioSeek( *phmmioIn, pckInRIFF->dwDataOffset + sizeof(FOURCC), SEEK_SET )){return E_FAIL;}
    pckIn->ckid = mmioFOURCC('d', 'a', 't', 'a');
    if(0 != mmioDescend(*phmmioIn, pckIn, pckInRIFF, MMIO_FINDCHUNK)){return E_FAIL;}
    return S_OK;
}

HRESULT WaveReadFile(HMMIO hmmioIn, UINT cbRead, BYTE* pbDest, MMCKINFO* pckIn, UINT* cbActualRead ){
    MMIOINFO mmioinfoIn;

    *cbActualRead = 0;
	if(0 != mmioGetInfo(hmmioIn, &mmioinfoIn, 0)){return E_FAIL;}
                
	UINT cbDataIn = cbRead;
	if(cbDataIn > pckIn->cksize){cbDataIn = pckIn->cksize;}
    pckIn->cksize -= cbDataIn;
    for( DWORD cT = 0; cT < cbDataIn; cT++ ){
        if( mmioinfoIn.pchNext == mmioinfoIn.pchEndRead ){
            if(0 != mmioAdvance(hmmioIn, &mmioinfoIn, MMIO_READ)){return E_FAIL;}
            if(mmioinfoIn.pchNext == mmioinfoIn.pchEndRead){return E_FAIL;}
        }
		*((BYTE*)pbDest+cT) = *((BYTE*)mmioinfoIn.pchNext);
		mmioinfoIn.pchNext++;
    }
	if(0 != mmioSetInfo(hmmioIn, &mmioinfoIn, 0)){return E_FAIL;}
    *cbActualRead = cbDataIn;
    return S_OK;
}

////////////////////// access ///////////////////////
HRESULT miDSound::Open( CHAR* strFilename ){
    delete m_pwfx; m_pwfx = NULL;
    HRESULT  hr;
    if(FAILED(hr = WaveOpenFile(strFilename, &m_hmmioIn, &m_pwfx, &m_ckInRiff))){return hr;}
    if(FAILED(hr = Reset())){return hr;}
    return hr;
}

HRESULT miDSound::Reset(){
	return WaveStartDataRead(&m_hmmioIn, &m_ckIn, &m_ckInRiff);
}

HRESULT miDSound::Read( UINT nSizeToRead, BYTE* pbData, UINT* pnSizeRead ){
	return WaveReadFile(m_hmmioIn, nSizeToRead, pbData, &m_ckIn, pnSizeRead);
}

HRESULT miDSound::Close(){
	mmioClose(m_hmmioIn, 0);
	return S_OK;
}
///////////////////////////////////////////////////


/****************************** DSOUND FUNCTIONS *****************************/

HRESULT miDSound::InitDirectSound( HWND hDlg ){
	HRESULT             hr;
	LPDIRECTSOUNDBUFFER pDSBPrimary = NULL;
	DSBUFFERDESC dsbd;
	WAVEFORMATEX wfx;

	ZeroMemory(&dsbd, sizeof(DSBUFFERDESC));
	ZeroMemory(&wfx,  sizeof(WAVEFORMATEX));
	
	CoInitialize(NULL);
	if(FAILED(hr = DirectSoundCreate(NULL, &g_pDS, NULL))){return hr;}
    if(FAILED(hr = g_pDS->SetCooperativeLevel(hDlg, DSSCL_PRIORITY))){return hr;}
	
	dsbd.dwSize        = sizeof(DSBUFFERDESC);
	dsbd.dwFlags       = DSBCAPS_PRIMARYBUFFER;
	dsbd.dwBufferBytes = 0;
	dsbd.lpwfxFormat   = NULL;
	if(FAILED(hr = g_pDS->CreateSoundBuffer(&dsbd, &pDSBPrimary, NULL))){return hr;}
	
	wfx.wFormatTag      = WAVE_FORMAT_PCM; 
	wfx.nChannels       = 2; 
	wfx.nSamplesPerSec  = 22050; 
	wfx.wBitsPerSample  = 16; 
	wfx.nBlockAlign     = wfx.wBitsPerSample / 8 * wfx.nChannels;
	wfx.nAvgBytesPerSec = wfx.nSamplesPerSec * wfx.nBlockAlign;
	if(FAILED(hr = pDSBPrimary->SetFormat(&wfx))){return hr;}
	pDSBPrimary->Release();
	pDSBPrimary = NULL;
	return S_OK;
}

HRESULT miDSound::FreeDirectSound(){
    SAFE_RELEASE(g_pDSBuffer);
    SAFE_RELEASE(g_pDS); 
    CoUninitialize();
    return S_OK;
}

BOOL miDSound::LoadWaveFile(HWND hDlg, TCHAR* strFileName){
	if(FAILED(CreateStaticBuffer(hDlg, strFileName))){
		return FALSE;
	}else{
        FillBuffer();
		return TRUE;
    }
}

HRESULT miDSound::CreateStaticBuffer(HWND hDlg, TCHAR* strFileName )
{
    HRESULT hr;
	DSBUFFERDESC dsbd;

    ZeroMemory( &dsbd, sizeof(DSBUFFERDESC) );

    SAFE_RELEASE( g_pDSBuffer );

    if(FAILED(Open(strFileName))){return -1;}

    dsbd.dwSize        = sizeof(DSBUFFERDESC);
    dsbd.dwFlags       = DSBCAPS_STATIC;
    dsbd.dwBufferBytes = m_ckIn.cksize;
    dsbd.lpwfxFormat   = m_pwfx;
	if(FAILED(hr = g_pDS->CreateSoundBuffer(&dsbd, &g_pDSBuffer, NULL))){return hr;}
	g_dwBufferBytes = dsbd.dwBufferBytes;
	return S_OK;
}

HRESULT miDSound::FillBuffer(){
    HRESULT hr; 
    BYTE*   pbWavData;
    UINT    cbWavSize;
    VOID*   pbData  = NULL;
    VOID*   pbData2 = NULL;
    DWORD   dwLength;
    DWORD   dwLength2;

	INT nWaveFileSize = m_ckIn.cksize;

    pbWavData = new BYTE[ nWaveFileSize ];
    if(NULL == pbWavData){return E_OUTOFMEMORY;}

    if(FAILED(hr = Read(nWaveFileSize, pbWavData, &cbWavSize))){return hr;}
	Reset();

    if(FAILED(hr = g_pDSBuffer->Lock(0, g_dwBufferBytes, &pbData, &dwLength, &pbData2, &dwLength2, 0L))){return hr;}

    memcpy( pbData, pbWavData, g_dwBufferBytes );
    g_pDSBuffer->Unlock( pbData, g_dwBufferBytes, NULL, 0 );
    pbData = NULL;
    SAFE_DELETE( pbWavData );

    return S_OK;
}

////////////// public access /////////////////

VOID miDSound::SetVolumeOnly(LONG lVolume)
{
	if(g_pDSBuffer){
		g_pDSBuffer->SetVolume(lVolume);
	}
}

VOID miDSound::SetBufferOptions( LONG lFrequency, LONG lPan, LONG lVolume ){
    if(g_pDSBuffer){
		g_pDSBuffer->SetFrequency(lFrequency);
		g_pDSBuffer->SetPan(lPan);
		g_pDSBuffer->SetVolume(lVolume);
	}
}

BOOL miDSound::IsBufferPlaying() {
	DWORD dwStatus = 0;
	if(NULL == g_pDSBuffer){return E_FAIL;}
	g_pDSBuffer->GetStatus( &dwStatus );
	return (dwStatus & DSBSTATUS_PLAYING);
}

HRESULT miDSound::PlayBuffer( BOOL bLooped ){
    HRESULT hr;
	if(NULL == g_pDSBuffer){return E_FAIL;}
	if(FAILED(hr = RestoreBuffers())){return hr;}
    DWORD dwLooped = bLooped ? DSBPLAY_LOOPING : 0L;
    if(FAILED(hr = g_pDSBuffer->Play(0,0,dwLooped))){return hr;}
    return S_OK;
}

VOID miDSound::StopBuffer(BOOL bResetPosition) {
    if(NULL == g_pDSBuffer){return;}
    g_pDSBuffer->Stop();
    if(bResetPosition){g_pDSBuffer->SetCurrentPosition( 0L );}    
}

BOOL miDSound::IsSoundPlaying(){
    if(g_pDSBuffer){
		DWORD dwStatus = 0;
		g_pDSBuffer->GetStatus( &dwStatus );
		return( ( dwStatus & DSBSTATUS_PLAYING ) != 0 );
	}else{
        return FALSE;
    }
}

HRESULT miDSound::RestoreBuffers(){
	HRESULT hr;
	if(NULL == g_pDSBuffer){return S_OK;}

	DWORD dwStatus;
	if(FAILED(hr = g_pDSBuffer->GetStatus(&dwStatus))){return hr;}

	if(dwStatus & DSBSTATUS_BUFFERLOST){
        do{
            hr = g_pDSBuffer->Restore();
            if(hr == DSERR_BUFFERLOST){Sleep( 10 );}
        }while(hr = g_pDSBuffer->Restore());
        if(FAILED(hr = FillBuffer())){return hr;}
    }
    return S_OK;
}