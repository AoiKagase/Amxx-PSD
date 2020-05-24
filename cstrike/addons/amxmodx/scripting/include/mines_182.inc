#if AMXX_VERSION_NUM < 190
// =====================================
//	Mines Platform 1.8.2 Functions.
//
// 	by Aoi.Kagase
// =====================================

#if defined _mines_182_included
	#endinput
#endif
#define _mines_182_included

#include <cromchat>
#define MAX_PLAYERS					32
#define MAX_NAME_LENGTH 			32
#define MAX_AUTHID_LENGTH 			64
#define MAX_RESOURCE_PATH_LENGTH 	64
#define MAX_MENU_LENGTH 			512
#define HIT_SHIELD					8
#define Ham_CS_Player_ResetMaxSpeed Ham_Item_PreFrame

stock ArrayFindString(Array:which, const item[])
{
	new szValue[64], count = ArraySize(which);
	for (new i = 0; i < count; i++)
	{
		ArrayGetString(which, i, szValue, charsmax(szValue));
		if (equali(item, szValue))
			return i;
	}
	return -1;
}

stock register_event_ex(const event[], const function[], const flags[], const cond[] = "", ...)
{
	register_event(event, function, flags, cond);
}

stock create_cvar(const name[], const string[], flags = 0, const description[] = "", bool:has_min = false, Float:min_val = 0.0, bool:has_max = false, Float:max_val = 0.0)
{
	new temp[128];
	// Avoid Warning
	formatex(temp, charsmax(temp), "%s%s%s%s%s", description, has_min, min_val, has_max, max_val);
	log_amx(temp);
	return register_cvar(name, string, flags);
}

stock bind_pcvar_num(pointer, &value)
	value = get_pcvar_num(pointer);

stock bind_pcvar_float(pointer, &Float:value)
	value = get_pcvar_float(pointer);

stock bind_pcvar_string(pointer, any:value[], len)
	get_pcvar_string(pointer, value, len);

stock fmt(const szString[], any:...)
{
	new result[512];
	vformat(result, charsmax(result), szString, 2);
	return result;
}

stock split_string(const szSource[], const szDelim[], szParsed[], iMaxChars)
{
    new iPos = strfind(szSource, szDelim);
    return (iPos > -1) ? copy(szParsed, min(iPos, iMaxChars), szSource) + strlen(szDelim) : -1;
}

/**
 * Computes the distance between two vectors (points).
 *
 * @param vec1          First vector.
 * @param vec2          Second vector.
 *
 * @return              The distance between two vectors.
 */
stock Float:xs_vec_distance(const Float:vec1[], const Float:vec2[])
{
	return xs_sqrt((vec1[0]-vec2[0]) * (vec1[0]-vec2[0]) +
	               (vec1[1]-vec2[1]) * (vec1[1]-vec2[1]) +
	               (vec1[2]-vec2[2]) * (vec1[2]-vec2[2]));
}
#endif