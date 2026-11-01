/* Datagram functions
 *
 * (c) Copyright 1998-2005, ITB CompuPhase
 * This file is provided as is (no warranties).
 */

#if defined _datagram_included
  #endinput
#endif
#define _datagram_included

#pragma library Datagram

native sendpacket(const ip[], port, const data[], size = sizeof data);