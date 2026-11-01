/* File functions
 *
 * (c) Copyright 1998-2005, ITB CompuPhase
 * This file is provided as is (no warranties).
 */

#if defined _file_included
  #endinput
#endif
#define _file_included

#pragma library File

native fopen(const name[], filemode:mode = io_readwrite);
native fclose(File:handle);
native fwrite(File:handle, const string[]);
native fread(File:handle, string[], size = sizeof string, bool:pack = false);
native fputchar(File:handle, value, bool:utf8 = true);
native fgetchar(File:handle, bool:utf8 = true);
native fblockwrite(File:handle, const buffer[], size = sizeof buffer);
native fblockread(File:handle, buffer[], size = sizeof buffer);
native fseek(File:handle, position = 0, seek_whence:whence = seek_start);
native flength(File:handle);
native fexist(const pattern[]);
native filemode:fmode(File:handle);
native fremove(const name[]);
native funlink(const name[]);
native fcopy(const name[], const newname[]);
native frename(const oldname[], const newname[]);