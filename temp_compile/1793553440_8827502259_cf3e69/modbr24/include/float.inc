/* Float functions
 * (c) Copyright 1998-2005, ITB CompuPhase
 */
#if defined _float_included
  #endinput
#endif
#define _float_included
#pragma library Float

native Float:float(value);
native Float:floatstr(const string[]);
native Float:floatmul(Float:oper1, Float:oper2);
native Float:floatdiv(Float:dividend, Float:divisor);
native Float:floatadd(Float:oper1, Float:oper2);
native Float:floatsub(Float:oper1, Float:oper2);
native Float:floatfract(Float:value);
native Float:floatround(Float:value, method=floatround_round);
native Float:floatcmp(Float:oper1, Float:oper2);
native Float:floatsqroot(Float:value);
native Float:floatpower(Float:value, Float:exponent);
native Float:floatlog(Float:value, Float:base=10.0);
native Float:floattan(Float:value, anglemode:mode=radian);
native Float:floatsin(Float:value, anglemode:mode=radian);
native Float:floatcos(Float:value, anglemode:mode=radian);
native Float:floatabs(Float:value);