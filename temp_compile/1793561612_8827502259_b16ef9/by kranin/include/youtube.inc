//==============================================================================
//                         Youtube Stream Function By Snakeman
//			Youtube Includesi,Snakeman tarafindan derlenmistir
//                     http://forum.sa-mp.com/member.php?u=79457
//			http://www.gtaturk.com/forum/profile/?u=29759
//                      native YoutubeStream(playerid,vlink[]);
//                      native YoutubeStopStream(playerid);
//==============================================================================
#pragma tabsize 0
#define YoutubeStopStreamForPlayer(%1) StopAudioStreamForPlayer(%1)
stock YoutubeStreamForPlayer(playerid, vlink[])
{
	new videoid[128], mp3link[128];
	strmid(videoid,vlink,strfind(vlink,"v=")+2,strfind(vlink,"v=")+15);
	format(mp3link,128,"http://element-samp.net/youtube.php?videoid=%s",videoid);
	PlayAudioStreamForPlayer(playerid,mp3link);
return 1;
}
stock YoutubeStreamForAll(vlink[])
{
new videoid[128], mp3link[128];
	strmid(videoid,vlink,strfind(vlink,"v=")+2,strfind(vlink,"v=")+15);
	format(mp3link,128,"http://element-samp.net/youtube.php?videoid=%s",videoid);
for(new i=0;i<MAX_PLAYERS;i++) PlayAudioStreamForPlayer(i,mp3link);
return 1;
}
stock YoutubeStopStreamForAll()
{
for(new i=0;i<MAX_PLAYERS;i++) StopAudioStreamForPlayer(i);
return 1;
}