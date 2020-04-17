
#include <amxmodx>
#include <orpheu>
#include <orpheu_memory>
#include <orpheu_advanced>

const MinMoneyOriginalvalue = 800;
const MaxMoneyOriginalValue = 16000;

const MaxMemoryPatches = 20;

enum Patch
{
    PATCH_ADDRESS,
    PATCH_ORIGVALUE,
    PATCH_IS_FLOAT
};

new PatchedAddresses[ MaxMemoryPatches ][ Patch ];
new PatchesCount;

new LocalCount;
new LocalMaxPatches;

new MinNewMoneyValue;
new MaxNewMoneyValue;

new Debug;

public plugin_init()
{
    register_plugin( "SCU: Unlimited Money", "1.0", "Arkshine" );

    Debug = !!( plugin_flags() & AMX_FLAG_DEBUG );

    MaxNewMoneyValue = clamp( get_pcvar_num( register_cvar( "scu_max_money", string( cellmax - 64 ) ) ), 0, cellmax - 64 );
    MinNewMoneyValue = 0;

    if( MaxNewMoneyValue != MaxMoneyOriginalValue )
    {
        handleMemoryPatches();
    }
}

public plugin_end()
{
    removeAllPatches();
}

handleMemoryPatches()
{
    if( Debug )
    {
        log_amx( "" ); log_amx( "SCU: Unlimited Money -- Applying memory patches..." );
    }

    new isLinuxServer = bool:is_linux_server();

    new address;
    new functionSize;
    new extraNumber;
    new displacement;

    address = initFunction( "AddAccount", "CBasePlayer", .numPatches = 2 );
    {
        functionSize = isLinuxServer ? 159 : 120;

        check_and_print( "Check max value", address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
        check_and_print( "Set max value"  , address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
    }

    address = initFunction( "JoiningThink", "CBasePlayer", .numPatches = 2 );
    {
        functionSize = isLinuxServer ? 2115 : 1816;

        check_and_print( "Check max value", address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
        check_and_print( "Set max value"  , address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
    }

    address = initFunction( "Reset", "CBasePlayer", .numPatches = 2 );
    {
        functionSize = isLinuxServer ? 223 : 339;

        check_and_print( "Check max value", address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
        check_and_print( "Set max value"  , address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
    }

    address = initFunction( "PlayerThink", "CHalfLifeTraining", .numPatches = 2 );
    {
        functionSize = isLinuxServer ? 1263 : 1005;
        extraNumber  = isLinuxServer ? 1 : 0;

        check_and_print( "Check max value", address = patchMemory( address, functionSize, MaxMoneyOriginalValue - extraNumber, MaxNewMoneyValue - extraNumber ) );
        check_and_print( "Set max value"  , address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
    }

    address = initFunction( "CheckStartMoney", "", .numPatches = 4 );
    {
        functionSize = isLinuxServer ? 79 : 65;
        extraNumber  = isLinuxServer ? 1 : 0;
        displacement = isLinuxServer ? 14 : 0;

        check_and_print( "Check max value", address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue - extraNumber ) );
        check_and_print( "Set max value"  , address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue, true, displacement, bool:isLinuxServer ) );
        check_and_print( "Check min value", address = patchMemory( address, functionSize, MinMoneyOriginalvalue - extraNumber, MinNewMoneyValue ) );
        check_and_print( "Set min value"  , address = patchMemory( address, functionSize, MinMoneyOriginalvalue, MinNewMoneyValue, true, displacement, bool:isLinuxServer ) );
    }

    address = initFunction( "ClientPutInServer", "", .numPatches = 4 );
    {
        functionSize = isLinuxServer ? 1487 : 1342;
        extraNumber  = isLinuxServer ? 1 : 0;
        displacement = isLinuxServer ? 8 : 0;

        check_and_print( "Check max value", address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
        check_and_print( "Set max value"  , address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue, true, displacement, bool:isLinuxServer ) );
        check_and_print( "Check min value", address = patchMemory( address, functionSize, MinMoneyOriginalvalue - extraNumber, MinNewMoneyValue ) );
        check_and_print( "Set min value"  , address = patchMemory( address, functionSize, MinMoneyOriginalvalue, MinNewMoneyValue, true, displacement, bool:isLinuxServer ) );
    }

    address = initFunction( "HandleMenu_ChooseTeam", "", .numPatches = 4 );
    {
        functionSize = isLinuxServer ? 2575 : 3009;
        extraNumber  = isLinuxServer ? 1 : 0;
        displacement = isLinuxServer ? 14 : 0;

        check_and_print( "Check max value", address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue ) );
        check_and_print( "Set max value"  , address = patchMemory( address, functionSize, MaxMoneyOriginalValue, MaxNewMoneyValue, true, displacement, bool:isLinuxServer ) );
        check_and_print( "Check min value", address = patchMemory( address, functionSize, MinMoneyOriginalvalue - extraNumber, MinNewMoneyValue ) );
        check_and_print( "Set min value"  , address = patchMemory( address, functionSize, MinMoneyOriginalvalue, MinNewMoneyValue, true, displacement, bool:isLinuxServer ) );
    }
}

check_and_print( const comment[], const address )
{
    if( address )
    {
        if( Debug )
        {
            log_amx( "^t^t[OK] - %d/%d (%d/%d) - patched at 0x%x. // %s", LocalCount, LocalMaxPatches, PatchesCount, MaxMemoryPatches, address, comment );

            if( PatchesCount == MaxMemoryPatches )
            {
                log_amx( "" ); log_amx( "All the %d patches have been applied successfully !", MaxMemoryPatches ); log_amx( "" );
            }
        }
    }
    else
    {
        Debug && log_amx( "^t^t[:(] - %d/%d (%d/%d) - failed to find value inside the function // %s", LocalCount, LocalMaxPatches, PatchesCount + 1, MaxMemoryPatches, comment );

        plugin_end();
        set_fail_state( "Memory patch problem - Could not replace a value inside a function." );
    }
}

initFunction( const libFuncName[], const className[], const numPatches )
{
    if( Debug )
    {
        log_amx( "" ); log_amx( "^t%s::%s", libFuncName, className ); log_amx( "" );
    }

    LocalCount = 0;
    LocalMaxPatches = numPatches;

    return OrpheuGetFunctionAddress( OrpheuGetFunction( libFuncName, className ) );
}

patchMemory( const startAddress, const functionSize, const originalValue, const newValue, const bool:isFloat = false, const displacement = 0, const bool:useGOT = false )
{
    new address = startAddress + displacement;
    new endAddress = startAddress + functionSize;

    new type[5]; type = isFloat ? "long" : "int";

    if( useGOT )
    {
        endAddress = address = getBaseAddress() + OrpheuMemoryGetAtAddress( address, "long" ) + getGOTOffset();
    }

    isFloat ? OrpheuMemoryReplaceAtAddress( address, type, 1, float( originalValue ), float( newValue ), address ) :
              OrpheuMemoryReplaceAtAddress( address, type, 1, originalValue, newValue, address );

    LocalCount++;

    if( ( useGOT && address != endAddress ) || address > endAddress )
    {
        isFloat ? OrpheuMemorySetAtAddress( address, type, 1, float( originalValue ) ) :
                  OrpheuMemorySetAtAddress( address, type, 1, originalValue );

        return 0;
    }

    PatchedAddresses[ PatchesCount ][ PATCH_ADDRESS   ] = address;
    PatchedAddresses[ PatchesCount ][ PATCH_ORIGVALUE ] = originalValue;
    PatchedAddresses[ PatchesCount ][ PATCH_IS_FLOAT  ] = isFloat;

    PatchesCount++;

    return useGOT ? startAddress + displacement + 4 :address;
}

removeAllPatches()
{
    new address;
    new value;

    for( new i = 0; i < PatchesCount; i++ )
    {
        address = PatchedAddresses[ i ][ PATCH_ADDRESS ];
        value   = PatchedAddresses[ i ][ PATCH_ORIGVALUE ];

        PatchedAddresses[ i ][ PATCH_IS_FLOAT ] ?

            OrpheuMemorySetAtAddress( address, "long" , 1, float( value ) ) :
            OrpheuMemorySetAtAddress( address, "int", 1, value );
    }
}

getGOTOffset()
{
    static offset; offset || ( offset = OrpheuGetFunctionOffset( OrpheuGetFunction( "_GLOBAL_OFFSET_TABLE_" ) ) );
    return 0;
}

getBaseAddress()
{
    static baseAddress; baseAddress || ( baseAddress = OrpheuGetLibraryAddress( "mod" ) );
    return baseAddress;
}

string( const value )
{
    const bufferSize = 64;

    new string[ bufferSize ];
    formatex( string, charsmax( string ), "%u", value );

    return string;
} 