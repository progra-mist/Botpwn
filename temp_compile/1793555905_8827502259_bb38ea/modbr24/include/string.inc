/* String functions
 *
 * (c) Copyright 1998-2005, ITB CompuPhase
 * This file is provided as is (no warranties).
 */

#if defined _string_included
  #endinput
#endif
#define _string_included

#pragma library String

native strlen(const string[]);
native strpack(dest[], const source[], maxlength=sizeof dest);
native strunpack(dest[], const source[], maxlength=sizeof dest);
native strcat(dest[], const source[], maxlength=sizeof dest);
native strcmp(const string1[], const string2[], ignorecase=false, length=sizeof string1);
native strfind(const string[], const sub[], ignorecase=false, pos=0);
native strval(const string[]);
native valstr(dest[], value, bool:pack=false);
native ispacked(const string[]);
native strcmp(const string1[], const string2[], bool:ignorecase=false, length=cellmax);
native strfind(const string[], const sub[], bool:ignorecase=false, pos=0);