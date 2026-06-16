#include <iostream>

extern "C"
{
    #include "lua.h"
    #include "lauxlib.h"
    #include "lualib.h"
}

#include <luabind/luabind.hpp>
#include <luabind/class.hpp>
#include <luabind/function.hpp>
#include <luabind/object.hpp>
#include <luabind/operator.hpp>

#include <AL/al.h>
#include <AL/alc.h>
#include <AL/alut.h>

namespace OpenALBindings
{
    struct al_constants {};
    struct alc_constants {};

    typedef std::vector<ALuint> vector_uint;

    void alGenBuffers_( ALsizei n, luabind::object table )
    {
        assert( luabind::type(table) == LUA_TTABLE );

        vector_uint tmp( n );
        alGenBuffers( n, &tmp[0] );

        for ( int i = 0; i < n; ++i )
            table[ i+1 ] = tmp[ i ];
    }

    void alDeleteBuffers_( ALsizei n, luabind::object table )
    {
        assert( luabind::type(table) == LUA_TTABLE );

        vector_uint data;
        for ( luabind::iterator it( table ), end; it != end; ++it )
            data.push_back( luabind::object_cast<ALuint>(*it) );

        alDeleteBuffers( n, &data[0] );
    }

    void alGenSources_( ALsizei n, luabind::object table )
    {
        assert( luabind::type(table) == LUA_TTABLE );

        vector_uint tmp( n );
        alGenSources( n, &tmp[0] );

        for ( int i = 0; i < n; ++i )
            table[ i+1 ] = tmp[ i ];
    }

    void alDeleteSources_( ALsizei n, luabind::object sources )
    {
        vector_uint data;

        if( luabind::type(sources) == LUA_TTABLE )
        {
            for ( luabind::iterator it( sources ), end; it != end; ++it )
                data.push_back( luabind::object_cast<ALuint>(*it) );
        }
        else if( luabind::type(sources) == LUA_TNUMBER )
            data.push_back( luabind::object_cast<ALuint>( sources ) );

        alDeleteSources( n, &data[0] );
    }

    class DataBuffer
    {
    public:
        DataBuffer()
            : format( 0 )
            , data( 0 )
            , size( 0 )
            , freq( 0 )
            , loop( 0 )
        {}

        bool isInitialized() const
        { return data; }

    private:
        ALenum format;
        ALvoid *data;
        ALsizei size;
        ALsizei freq;
        ALboolean loop;

        friend DataBuffer alutLoadWAVFile_( std::string fname );
        friend void alutUnloadWAV_( DataBuffer& buffer );
        friend void alBufferData_( ALuint buffer, DataBuffer& data );
    };

    struct ALCdevice_
    {
        ALCdevice *pImpl;
        ALCdevice_( ALCdevice *dev ) : pImpl( dev ) {}
    };

    struct ALCcontext_
    {
        ALCcontext *pImpl;
        operator ALCcontext*() { return pImpl; }
        ALCcontext_( ALCcontext *dev ) : pImpl( dev ) {}
    };

    DataBuffer alutLoadWAVFile_( std::string fname )
    {
        DataBuffer buffer;
        alutLoadWAVFile(
                reinterpret_cast<ALbyte*>( const_cast<char*>(fname.c_str()) ),
                &buffer.format,
                &buffer.data,
                &buffer.size,
                &buffer.freq,
                &buffer.loop );
        return buffer;
    }

    void alutUnloadWAV_( DataBuffer& buffer )
    {
        alutUnloadWAV(
                buffer.format,
                buffer.data,
                buffer.size,
                buffer.freq );

        buffer.format = 0;
        buffer.data = NULL;
        buffer.size = 0;
        buffer.freq = 0;
        buffer.loop = 0;
    }

    void alBufferData_( ALuint buffer, DataBuffer& data )
    {
        alBufferData(
                buffer,
                data.format,
                data.data,
                data.size,
                data.freq );
    }

    std::string ALAPIENTRY alGetString_( ALenum param )
    {
        const ALubyte *pResult = alGetString( param );
        return std::string( pResult ? reinterpret_cast<const char*>(pResult) : "" );
    }

    void alSourcefv_( ALuint source, ALenum param, const luabind::object& table )
    {
        using namespace luabind;
        assert( type(table) == LUA_TTABLE );
        ALfloat v[3];
        boost::optional<ALfloat> value;

        value = object_cast_nothrow<ALfloat>( table[1] );
        v[0] = value ? *value : 0.0f;
        value = object_cast_nothrow<ALfloat>( table[2] );
        v[1] = value ? *value : 0.0f;
        value = object_cast_nothrow<ALfloat>( table[3] );
        v[2] = value ? *value : 0.0f;
        alSourcefv( source, param, v );
    }

    void alListenerfv_( ALenum param, const luabind::object& table )
    {
        using namespace luabind;
        assert( type(table) == LUA_TTABLE );
        ALfloat v[3];
        boost::optional<ALfloat> value;

        value = object_cast_nothrow<ALfloat>( table[1] );
        v[0] = value ? *value : 0.0f;
        value = object_cast_nothrow<ALfloat>( table[2] );
        v[1] = value ? *value : 0.0f;
        value = object_cast_nothrow<ALfloat>( table[3] );
        v[2] = value ? *value : 0.0f;
        alListenerfv( param, v );
    }

    ALint alGetSourcei_( ALuint sid, ALenum pname )
    {
        ALint value;
        alGetSourcei( sid, pname, &value );
        return value;
    }

    // ALC FAKE FUNCTIONS
    ALCdevice_ alcOpenDevice_( const std::string& tokstr )
    {
        return ALCdevice_( alcOpenDevice( reinterpret_cast< const ALCubyte*>( tokstr.c_str() ) ) );
    }

    std::string alcGetString_( ALCdevice_& deviceHandle, ALCenum token )
    {
        return reinterpret_cast<const char*>( alcGetString( deviceHandle.pImpl, token ) );
    }

    ALCcontext_ alcCreateContext_( ALCdevice_& dev, const luabind::object& table )
    {
        using namespace luabind;
        std::vector< ALCint > attrlist;

        if( type(table) == LUA_TTABLE )
        {
            for ( iterator it( table ), end; it != end; ++it )
                attrlist.push_back( object_cast<ALCint>(*it) );
        }

        return ALCcontext_( alcCreateContext( dev.pImpl, attrlist.empty() ? NULL : &attrlist[0] ) );
    }

    bool alcMakeContextCurrent_( ALCcontext_ *context )
    {
        return alcMakeContextCurrent( context ? context->pImpl : NULL );
    }

    ALCenum alcGetError_( ALCdevice_& dev )
    {
        return alcGetError( dev.pImpl );
    }

    ALCcontext_ alcGetCurrentContext_()
    {
        return ALCcontext_( alcGetCurrentContext() );
    }

    ALCdevice_ alcGetContextsDevice_( ALCcontext_ *context )
    {
        return ALCdevice_( alcGetContextsDevice( context ? context->pImpl : NULL ) );
    }

    void alcDestroyContext_( ALCcontext_ *context )
    {
        alcDestroyContext( context ? context->pImpl : NULL );
    }

    void alcCloseDevice_( ALCdevice_ *device )
    {
        alcCloseDevice( device ? device->pImpl : NULL );
    }
}

void bind_openal(lua_State* L)
{
    using namespace luabind;
    using namespace OpenALBindings;

    open(L);

    module(L)
    [
        class_<al_constants>("al")
            .enum_("constants")
            [
                value( "AL_NO_ERROR", AL_NO_ERROR ),
                value( "AL_FALSE", AL_FALSE ),
                value( "AL_TRUE", AL_TRUE ),
                value( "AL_BUFFER", AL_BUFFER ),
                value( "AL_PITCH", AL_PITCH ),
                value( "AL_GAIN", AL_GAIN ),
                value( "AL_POSITION", AL_POSITION ),
                value( "AL_VELOCITY", AL_VELOCITY ),
                value( "AL_ORIENTATION", AL_ORIENTATION ),
                value( "AL_LOOPING", AL_LOOPING ),
                value( "AL_PLAYING", AL_PLAYING ),
                value( "AL_SOURCE_STATE", AL_SOURCE_STATE )
            ],

        class_< DataBuffer >("DataBuffer")
            .property( "initialized", &DataBuffer::isInitialized ),

        def( "alGenBuffers", &alGenBuffers_ ),
        def( "alDeleteBuffers", &alDeleteBuffers_ ),
        def( "alGenSources", &alGenSources_ ),
        def( "alDeleteSources", &alDeleteSources_ ),

        def( "alBufferData", &alBufferData_ ),

        def( "alSourcei", &alSourcei ),
        def( "alSourcef", &alSourcef ),
        def( "alSourcefv", &alSourcefv_ ),

        def( "alSourcePlay", &alSourcePlay ),
        def( "alSourceStop", &alSourceStop ),
        def( "alSourcePause", &alSourcePause ),

        def( "alListenerfv", &alListenerfv_ ),

        def( "alGetError", &alGetError ),
        def( "alGetString", &alGetString_ ),
        def( "alGetSourcei", &alGetSourcei_ ),

        // ALUT BINDS
        def( "alutInit", &alutInit ),
        def( "alutExit", &alutExit ),
        def( "alutLoadWAVFile", &alutLoadWAVFile_ ),
        def( "alutUnloadWAV", &alutUnloadWAV_ ),

        // ALC BINDS
        class_<alc_constants>("alc")
            .enum_("constants")
            [
                value( "ALC_NO_ERROR", ALC_NO_ERROR ),
                value( "ALC_DEVICE_SPECIFIER", ALC_DEVICE_SPECIFIER )
            ],
        class_< ALCdevice_ >("ALCdevice"),
        class_< ALCcontext_ >("ALCcontext"),

        def( "alcOpenDevice", &alcOpenDevice_ ),
        def( "alcGetString", &alcGetString_ ),
        def( "alcCreateContext", &alcCreateContext_ ),
        def( "alcMakeContextCurrent", &alcMakeContextCurrent_ ),
        def( "alcGetError", &alcGetError_ ),
        def( "alcGetCurrentContext", &alcGetCurrentContext_ ),
        def( "alcGetContextsDevice", &alcGetContextsDevice_ ),
        def( "alcDestroyContext", &alcDestroyContext_ ),
        def( "alcCloseDevice", &alcCloseDevice_ )
    ];
}

extern "C" int luaopen_openal(lua_State *L)
{
    bind_openal(L);
/*
    lua_pushliteral (L, "_COPYRIGHT");
    lua_pushliteral (L, "Copyright (C) 2006 Alexander Artemenko");
    lua_settable (L, -3);
    lua_pushliteral (L, "_DESCRIPTION");
    lua_pushliteral (L, "OpenAL -> LUA bindings.");
    lua_settable (L, -3);
    lua_pushliteral (L, "_NAME");
    lua_pushliteral (L, "LuaOpenAL");
    lua_settable (L, -3);
    lua_pushliteral (L, "_VERSION");
    lua_pushliteral (L, "0.1.0");
    lua_settable (L, -3);
    */
    return 1;
}

