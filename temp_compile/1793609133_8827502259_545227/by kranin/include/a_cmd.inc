#define MAX_GANGS 200
#define max_ping 300
#define MPH 0
#define MAX_STRING 255
new bool: aktivuotas[MAX_PLAYERS];
new bool: fi[MAX_PLAYERS][MAX_PLAYERS];
new afondas = 1000000;
new oruciklas[]={1,7,10,9,18,6,18},cikle,Float:gravitacijos[]={0.008,0.008,0.008,0.008,0.008,0.008,0.008};
//------------------------------------------//***** Spalvos *****
#define PG 				0x98FEB9FF          //***** Spalvos *****
#define RED             0xAA3333AA          //***** Spalvos *****
//------------------------------------------//***** Spalvos *****
// ================================================== Taxi.txt ==================================================
enum titem{taksistas,Float:Start[3],bool:imti,}
new taxiDB[MAX_PLAYERS][titem];
new keleivis[MAX_PLAYERS];
stock GetDriver(vehicleid){
for(new playerid = 0; playerid<MAX_PLAYERS;playerid++){
if(IsPlayerConnected(playerid)){
if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER){
if(IsPlayerInVehicle(playerid,vehicleid)) return playerid;}}}
return INVALID_PLAYER_ID;}
// ================================================== Taxi.txt ==================================================
// ================================================== bussnesDB.txt ==================================================
enum bitem
{
	moka,
	bizkaina,
	pavadinimas[128],
	bpinigai,
	own_name[MAX_PLAYER_NAME]
}

new bussinesDB[400][bitem];
// ================================================== bussnesDB.txt ==================================================
// ================================================== gangs.txt ==================================================
enum giitem
{
	ganame[128],
	leader[MAX_PLAYER_NAME],
	members,
	gfondas,
	Float:bustine[3],
	bool:invited[MAX_PLAYERS],
	bool:isgang
}

new gangDB[MAX_GANGS][giitem];

enum gitems
{
	pgang,
	bool:islead
}

new gplayerDB[MAX_PLAYERS][gitems];
// ================================================== gangs.txt ==================================================
// ================================================== Autobusas.txt ==================================================
#define STATIONS 36
#define STATION_SIZE 20

new Float:autoarray[36][3]={
{-2709.4453,-100.2124,4.0501},
{-2497.3523,-177.5426,25.3371},
{-2498.0027,-13.5279,25.4858},
{-2316.3071,-73.8864,35.0346},
{-2232.4878,-426.3727,50.7376},
{-1990.8539,-1025.8350,31.8957},
{-1858.2362,-587.3728,22.2363},
{-1437.2701,-286.9417,13.8682},
{-1784.4010,-572.3199,16.2050},
{-1795.7850,-137.5948,5.9575},
{-1554.4420,660.4615,6.9094},
{-1638.5032,1260.1272,6.9163},
{-2082.0774,1330.8474,6.9083},
{-2605.0308,1334.9498,6.9127},
{-2754.3430,766.7238,54.1043},
{-2628.5757,706.0731,27.6725},
{-2447.9565,704.9347,34.8861},
{-2292.8474,560.8641,34.8837},
{-2009.7634,467.7260,34.8826},
{-2009.6497,174.7309,27.4042},
{-2052.1235,-66.5369,35.0389},
{-2660.9282,-66.9728,4.0496},
{-2747.0938,372.9547,4.0175},
{-2748.3767,699.4398,40.9973},
{-2747.6985,793.2289,53.1791},
{-2696.2417,1213.7371,55.0374},
{-2722.9431,2348.6455,71.7326},
{-2566.3174,2311.1367,4.7040},
{-2463.3826,2280.3257,4.6883},
{-2348.1450,2408.0002,6.2208},
{-2739.0305,2420.2346,74.3088},
{-1917.1079,2384.1887,49.2343},
{-1254.2062,1666.1505,9.5156},
{-1102.9108,1201.9138,39.0827},
{-2164.6973,-86.4933,35.0458},
{-2649.0210,-41.8369,4.2030}
};

enum citem
{
	currentCP,
	CPnumber
}
new autoDB[MAX_PLAYERS][citem];

#define STATIONS85 85
#define STATION_SIZE1 1

new Float:autoarray85[85][3]={
{-2052.9944,112.7697,28.7036},
{-2143.5908,194.2876,34.9439},
{-2238.4583,324.1640,34.8969},
{-2266.0164,54.0735,34.8908},
{-2549.3735,-9.5616,16.1469},
{-2641.9929,-206.5193,3.9086},
{-2804.2839,-476.8771,6.9127},
{-2340.1018,-421.0925,79.2658},
{-2456.8755,-421.9256,83.6588},
{-2432.9973,-600.9542,132.0820},
{-2342.7310,-793.7720,93.2307},
{-2198.5168,-788.1387,60.8721},
{-2134.5310,-1059.4545,30.4510},
{-1909.9081,-1365.6093,40.0038},
{-1815.7540,-1185.4379,37.4810},
{-1975.3983,-1118.0669,30.9191},
{-1924.7295,-1004.7222,31.6938},
{-1922.9407,-715.9247,31.6973},
{-2156.3647,-713.5787,31.6942},
{-2159.9604,-1002.1909,31.6939},
{-1984.6188,-991.8585,31.7485},
{-1984.6595,-662.3668,32.2762},
{-2234.1682,-400.3908,50.5923},
{-2240.6313,-193.8103,34.8970},
{-2152.7734,-72.5671,34.8969},
{-2084.1023,17.9753,34.8970},
{-2009.9861,-57.9197,34.8907},
{-1850.6870,-119.1393,5.3968},
{-1839.2709,-223.7871,17.9455},
{-1796.0034,-210.4607,16.3405},
{-1760.2108,-105.4531,3.4378},
{-1764.4685,181.6444,6.7486},
{-1755.5790,290.2229,7.2179},
{-1675.4873,410.8356,6.9048},
{-1688.2136,418.3975,6.9049},
{-1561.8770,490.9318,6.7564},
{-1536.9545,768.2720,6.7642},
{-1554.5951,999.1546,6.7642},
{-1664.6885,1292.5706,6.7641},
{-1638.6274,1289.0164,6.7633},
{-1666.5723,1298.3811,6.7639},
{-1821.1370,1385.8060,6.7720},
{-2083.2388,1331.4005,6.7642},
{-2280.0708,1343.9203,6.7642},
{-2370.4360,1364.8724,6.8511},
{-2369.9097,1187.9985,40.2479},
{-2277.9724,1169.7974,55.3785},
{-2251.8218,1257.8451,41.7701},
{-2030.9153,1284.7551,6.8271},
{-1916.8228,1288.0944,6.7641},
{-1799.1249,1352.5040,6.7719},
{-1634.1400,1209.1938,6.7643},
{-1658.2998,1213.7896,6.9751},
{-1703.5986,1191.9521,24.7878},
{-1889.6307,1161.6312,45.0220},
{-1964.1356,1092.2590,55.2954},
{-1990.7396,1183.9645,45.0220},
{-2148.2644,1102.4631,79.5762},
{-2153.9587,1021.3848,79.5701},
{-2126.6680,916.7907,79.6469},
{-2095.3975,947.7461,71.1899},
{-2080.5696,912.4325,65.5635},
{-2065.9353,946.0437,60.2204},
{-2048.9705,911.9540,54.2641},
{-2036.9847,944.5585,49.4551},
{-2009.2970,869.7337,45.0220},
{-1986.3153,727.1429,45.0220},
{-1904.0305,620.2593,34.7408},
{-1822.4761,495.5050,27.1403},
{-1851.5673,434.0807,16.7335},
{-1988.9281,350.8881,34.6427},
{-2009.4623,308.6865,34.6830},
{-1919.7428,224.5054,34.5881},
{-1993.8701,232.8282,28.4210},
{-2019.8610,178.6441,28.1353},
{-2029.8513,156.2313,28.5611},
{-2018.2808,136.8443,27.7836},
{-1981.7474,104.1451,27.4086},
{-1994.4142,93.4385,27.4127},
{-1991.0955,135.7511,27.2642},
{-1976.0214,127.0657,27.4192},
{-1964.5620,157.9677,27.4175},
{-1958.5973,139.1376,27.4189},
{-1989.7375,193.8739,27.2642},
{-2010.0619,120.3065,27.2643}
};

enum citem85
{
	currentCP85,
	CPnumber85
}
new autoDB85[MAX_PLAYERS][citem85];

#define STATIONS25 25
#define STATION_SIZE2 1

new Float:autoarray25[25][3]={
{-2056.0796,328.4632,35.7108},
{-1912.9557,217.1251,35.7156},
{-2123.1384,-5.0904,35.8645},
{-2192.5781,31.7388,35.8600},
{-2449.0847,-84.5306,34.5546},
{-2746.5581,-5.5458,6.4926},
{-2758.6047,-51.3111,7.5557},
{-2756.8132,-177.3165,7.4408},
{-2757.0342,-97.6611,7.4796},
{-2748.8945,-5.7419,6.9841},
{-2724.6418,76.5235,4.8674},
{-1671.5659,436.9625,7.7413},
{-2081.0415,1329.2512,7.5890},
{-2712.0168,972.4628,55.0737},
{-2671.8782,988.5152,65.3762},
{-2630.8174,924.7055,71.0958},
{-2660.3076,909.6727,80.1608},
{-2724.4700,870.6857,70.7092},
{-2725.0054,913.1862,68.1461},
{-2402.3062,953.1191,45.8522},
{-2555.4001,864.0156,59.3824},
{-2213.1746,414.9100,35.7201},
{-2180.0977,605.6363,35.6920},
{-2097.7571,651.7468,52.9074},
{-2672.3901,703.2495,28.5779}
};

enum citem25
{
	currentCP25,
	CPnumber25
}
new autoDB25[MAX_PLAYERS][citem25];
// ================================================== Autobusas.txt ==================================================
// ================================================== lobis.txt ==================================================
enum loitem
{
	Lobis,
	bool:IsPicked
}

new LobiuDB[loitem];

new Float:lobiai[][3]={
{-349.9794,2210.2563,42.4844},
{-369.7008,2219.2476,42.4844},
{-414.3536,2258.2263,42.9105},
{-421.8358,2250.9036,42.4297},
{-411.9254,2220.9927,42.4297},
{-382.4557,2212.7607,42.4251},
{-360.5771,2210.4421,42.4844},
{-458.4447,2225.3665,42.4297},
{-376.1234,2244.5654,42.0938},
{-314.9018,2216.1589,44.1285},
{-356.1910,2213.4634,42.4253},
{-463.9580,2210.7083,42.8394},
{-426.2009,2206.4409,42.4297},
{-363.0255,2247.4248,42.4844},
{-320.5193,2252.5056,42.4844},
{-378.5850,2260.0701,41.8908},
{-426.3846,2216.2239,42.4297},
{-356.2260,2242.4260,42.4844},
{-345.3765,2240.9236,43.7211},
{-332.9117,2201.7161,42.4844},
{-360.8770,2211.1731,42.4844},
{-354.0304,2229.9426,42.4844},
{-376.6750,2209.4751,42.4844},
{-388.1872,2197.9121,42.4258},
{-420.8264,2222.7114,42.4297},
{-383.1534,2223.0754,42.4297},
{-447.1372,2218.1096,42.4297},
{-426.2820,2245.2136,42.4297},
{-417.1837,2243.3887,42.4297},
{-377.3651,2271.2834,42.0064},
{-349.7275,2217.3064,42.4831},
{-391.6609,2206.4014,42.3951},
{-420.8615,2218.9016,42.4297},
{-475.9012,2213.2031,45.7727},
{-414.8027,2239.6414,42.6703},
{-426.2653,2269.8398,42.2689},
{-428.6180,2305.1428,41.9627},
{-434.8948,2217.4482,42.6858},
{-460.8394,2195.1755,46.1954},
{-415.7751,2241.8237,42.4297},
{-437.7232,2246.6040,42.4297},
{-423.1989,2252.8799,42.4297},
{-422.5089,2257.3374,42.4297},
{-370.8014,2232.8662,42.4297},
{-388.2273,2234.5229,42.4353},
{-350.1987,2224.0046,42.4844},
{-359.0059,2222.8054,42.4912},
{-325.3898,2224.8738,42.4874},
{-329.0994,2226.1865,42.4856},
{-326.3737,2215.3633,42.4841},
{-350.1706,2208.9065,46.5967},
{-375.1824,2206.3245,47.4162},
{-362.7261,2202.0745,42.4225},
{-383.0354,2136.1328,57.5010},
{-428.2497,2246.1797,42.4297},
{-456.4738,2229.1687,42.4297},
{-399.9366,2202.4048,42.4005},
{-426.4088,2202.6733,42.4297},
{-455.7542,2221.9902,42.4297},
{-476.7353,2239.6895,42.4297},
{-446.7761,2248.4927,42.4297},
{-426.2125,2260.0298,42.4297},
{-368.7484,2250.3567,42.4297},
{-356.7481,2257.9814,43.0547},
{-341.7611,2243.2449,42.4844},
{-334.5697,2227.2126,41.7866},
{-322.9232,2230.0166,42.4886},
{-348.9229,2214.8274,42.7778},
{-359.1022,2234.6091,42.4844},
{-373.6335,2228.6455,42.4844},
{-358.0310,2212.4763,42.4844},
{-371.8059,2214.8870,42.2932},
{-384.1774,2239.2517,42.4297},
{-426.0262,2240.2644,42.4297},
{-442.6657,2223.3850,42.4297},
{-440.1763,2215.0112,42.4297},
{-453.4329,2214.9304,42.4297},
{-415.9657,2209.6699,42.4297},
{-446.1168,2237.4883,42.4297},
{-429.6402,2209.0037,42.4297},
{-427.0947,2207.0908,42.4297},
{-436.6154,2204.4080,42.4297},
{-378.2067,2196.8657,42.4258},
{-367.0029,2198.8389,42.4230},
{-348.4998,2221.8672,42.9199},
{-312.8122,2224.6602,42.4886},
{-358.1790,2229.1831,43.0277},
{-360.0800,2218.1621,42.4900},
{-339.5407,2215.7280,42.5703},
{-356.1126,2215.7000,43.7218},
{-313.1295,2222.5730,42.4885},
{-375.1145,2227.1995,41.7772},
{-367.4664,2225.4294,42.4297},
{-430.7340,2222.4626,42.4297},
{-416.3041,2240.0461,42.4297},
{-437.1641,2248.9829,42.4297},
{-368.9486,2250.6917,42.4844},
{-385.6465,2266.7996,42.4844},
{-340.7784,2229.2717,42.4912},
{-338.6106,2224.5872,42.4912},
{-358.6202,2220.7798,42.4912},
{-329.0648,2218.4949,42.4912},
{-366.5795,2212.5840,42.4844},
{-426.9229,2246.9749,42.4297},
{-362.8100,2242.4573,42.4844},
{-347.7649,2225.6799,42.4912},
{-424.4871,2273.3838,42.0984},
{-442.9844,2250.9060,42.5992}};
// ================================================== lobis.txt ==================================================
// ================================================== houseDB.txt ==================================================
enum hitem
{
	setting,
	nkaina,
	owner_name[MAX_PLAYER_NAME],
	krumeliai,
	bukle,
	dregme,
	amzius,
	namehash
}
new houseDB[256][hitem];

enum settings
{
	interior,
	Float:enter_pos[3]
}
new houseSETTINGS[15][settings];
// ================================================== houseDB.txt ==================================================
// ================================================== vehicles.txt ==================================================
//--------------------------------------------------------//--------------------------------------------------------//--------------------------------------------------------
enum vitem{gas,bool:locked,bool:parduodama,spalva1,spalva2,bool:registruota,bagazaz,bool:technikine,remont,padpakelis,lastuser,Float:lastpos[4],Float:respawnpos[4],Float:prav,Float:respawnrot,owner_name[MAX_PLAYER_NAME],col1,col2,paintjob}
new vehicleDB[MAX_VEHICLES][vitem];
new maxvehicles=-1;
new aVehicleNames[212][] = {{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},{"Firetruck"},{"Trashmaster"},{"Stretch"},{"Manana"},{"Infernus"},
{"Voodoo"},{"Pony"},{"Mule"},{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},{"Taxi"},{"Washington"},{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},
{"Banshee"},{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},{"Romero"},{"Packer"},{"Monster"},
{"Admiral"},{"Squalo"},{"Seasparrow"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},{"Speeder"},{"Reefer"},{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},
{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},{"Glendale"},{"Oceanic"},{"Sanchez"},{"Sparrow"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},{"Rustler"},{"ZR-350"},
{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},{"Baggage"},{"Dozer"},{"Maverick"},{"News Chopper"},{"Rancher"},{"FBI Rancher"},{"Virgo"},{"Greenwood"},{"Jetmax"},{"Hotring"},{"Sandking"},
{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},{"Mesa"},{"RC Goblin"},{"Hotring Racer A"},{"Hotring Racer B"},{"Bloodring Banger"},{"Rancher"},{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},
{"Mountain Bike"},{"Beagle"},{"Cropdust"},{"Stunt"},{"Tanker"},{"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},{"NRG-500"},{"HPV1000"},{"Cement Truck"},{"Tow Truck"},{"Fortune"},
{"Cadrona"},{"FBI Truck"},{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},{"Blade"},{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},
{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},{"Sunrise"},{"Merit"},{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},
{"Sultan"},{"Stratum"},{"Elegy"},{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},{"Broadway"},
{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},{"Club"},{"Freight Carriage"},{"Trailer 3"},{"Andromada"},
{"Dodo"},{"RC Cam"},{"Launch"},{"Police Car (LSPD)"},{"Police Car (SFPD)"},{"Police Car (LVPD)"},{"Police Ranger"},{"Picador"},{"S.W.A.T. Van"},{"Alpha"},{"Phoenix"},{"Glendale"},{"Sadler"},
{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},{"Utility Trailer"}};
new aBakai[212] = { 98,87,90,130,75,98,130,110,120,120,80,100,100,120,120,100,120,140,125,95,107,90,90,100,100,100,100,100,100,120,120,120,380,100,120,150,95,130,50,92,95,20,95,150,150,152,120,
95,50,0,92,96,85,95,95,135,95,92,95,95,96,60,57,86,20,20,95,95,95,122,120,56,95,95,95,97,90,59,90,90,60,0,125,99,55,40,190,190,180,98,98,128,122,125,75,75,95,190,190,90,115,10,80,85,88,92,95,92,
122,0,0,160,90,87,150,190,120,100,98,170,190,90,87,82,90,95,90,90,130,130,45,80,130,95,96,115,115,132,122,55,96,98,98,98,128,90,90,90,122,126,96,105,98,190,128,94,150,160,94,95,125,90,92,92,20,
92,92,95,80,0,0,70,50,90,85,122,98,700,122,96,95,70,98,50,10040,96,71,94,129,70,0,120,282,95,0,95,122,125,122,122,95,121,91,123,92,112,0,0,0,125,0,0};
new aEda[212] = {  1,1,2,2,1,1,3,3,3,2,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,3,1,3,3,1,1,3,3,3,1,0,1,2,1,1,1,0,1,3,3,1,1,3,1,0,0,2,2,2,2,4,4,1,1,1,1,1,1,1,1,1,1,1,1,3,3,1,1,1,1,1,3,1,1,1,1,0,1,1,1,1,
3,3,3,1,1,1,1,1,1,3,1,3,1,1,1,1,1,1,1,1,1,1,1,0,0,3,3,3,3,3,1,1,1,3,2,1,1,1,4,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,4,1,1,1,1,1,1,1,1,4,1,1,3,2,1,1,1,1,1,2,1,1,1,1,1,0,0,1,1,2,1,1,1,4,1,1,1,
1,1,1,0,1,1,1,1,1,0,0,1,4,1,4,1,1,1,1,1,1,1,1,1,1,0,0,0,1,0,0};
stock Vehicle(model,Float:x,Float:y,Float:z,Float:a,color,color2){
AddStaticVehicleEx(model,x,y,z,a,color,color2,172800);
maxvehicles++;
vehicleDB[maxvehicles][gas]=random(aEda[model-400]);
if(IsTurgus(x,y)) vehicleDB[maxvehicles][parduodama]=false; else vehicleDB[maxvehicles][parduodama]=true;
return maxvehicles;}
// Vehicles.txt
new BankasCP;
new gSession,Float:vairpos[MAX_PLAYERS][3],zaidimast[MAX_PLAYERS];




new banfailas[128]="ban.ini";
enum Params
{
	o,
	l
}

new Vehiclez[2000][MAX_PLAYERS][Params];
// ================================================== vehicles.txt ==================================================
public IsAtMot(carid)
{
	new model = GetVehicleModel(carid);
	if((model>=461&&model<=463)||model==608||(model>=521&&model<=523)||model==581||model==586) return 1;
	return 0;
}
public KickPing(playerid)
{
if(GetPlayerPing(playerid) >= max_ping)
{
new pName[64];
GetPlayerName(playerid, pName, sizeof(pName));
new str[256];
format(str, sizeof(str), " Serveris: Þaidëjas %s Virðijo leistina pinga {FF0000}%d", pName, max_ping);
SendClientMessageToAll(PG, str);
Kick(playerid);
}
}
public ValomChata()
{
SendClientMessageToAll(0xFFFFFFFF," ");
return 1;
}
public Buspay(playerid,Float:x,Float:y,Float:z)
{
    if(PlayerToPoint(20,playerid,x,y,z))
    {
        GivePlayerMoneyA(playerid,random(10));
        GameTextForPlayer(playerid,"Galite vaziuoti",1000,5);
    }
}
public Buspay85(playerid,Float:x,Float:y,Float:z)
{
    if(PlayerToPoint(20,playerid,x,y,z))
    {
        GivePlayerMoneyA(playerid,random(5));
        //GameTextForPlayer(playerid,"Galite vaziuoti",1000,5);
    }
}
public Buspay25(playerid,Float:x,Float:y,Float:z)
{
    if(PlayerToPoint(20,playerid,x,y,z))
    {
        GivePlayerMoneyA(playerid,random(7));
        GameTextForPlayer(playerid,"Galite vaziuoti",1000,5);
    }
}
forward freez(playerid);
public freez(playerid)
{
TogglePlayerControllable(playerid,false);
}
forward CheckS(playerid);
forward Unfi(i,id);
public Unfi(i,id)
{

	fi[i][id] = false;
	return 1;
}
public CheckS(playerid)
{

	new id = s_GetClosestPlayer(playerid,50.0),estr[128];
	if(!IsPlayerConnected(id) || !aktivuotas[playerid] || fi[playerid][id] || GetPlayerState(id) != 2 ||!GetSpeed(id)) return SetTimerEx("CheckS",100,0,"i",playerid),1;
	format(estr,128,"Zaidejas:%s pravaziavo %d KM/H greièiu.",GET_PLAYER_NAME(id),GetSpeed(id));
	fi[playerid][id] = true;
	SendClientMessage(playerid,RED,estr);
 	if(GetSpeed(id) >= 100)
 	{

		SetPlayerWantedLevel(id,GetPlayerWantedLevel(id)+8);
		format(estr,128,"* Policininko matuoklis:Virsijai Greiti 100 KM/H tavo greitis %d KM/H.",GetSpeed(id));
		SendClientMessage(id,RED,estr);
 	}
	SetTimerEx("Unfi",7*700,0,"ii",playerid,id);
	SetTimerEx("CheckS",100,0,"i",playerid);
	return 1;
}
Float:GetPos(playerid,posid) { new Float:id[3]; if(IsPlayerInAnyVehicle(playerid)) GetVehiclePos(GetPlayerVehicleID(playerid),id[0],id[1],id[2]); else GetPlayerPos(playerid,id[0],id[1],id[2]); return id[posid-1]; }
GetSpeed(id) { new Float:s[4]; GetVehicleVelocity(GetPlayerVehicleID(id),s[0],s[1],s[2]); return floatround((2.00-MPH)*floatsqroot(floatabs(floatpower(s[0]+s[1]+s[2],2)))*100); }
GET_PLAYER_NAME( id ) { new x[  MAX_PLAYER_NAME  ]; if( IsPlayerConnected( id ) ) GetPlayerName( id , x , sizeof(x) ); return x; }
s_GetClosestPlayer(except,Float: radius = 99999.9999)
{
	new Float:dis[2],e[2];
	e[0] = INVALID_PLAYER_ID;
	dis[0] = radius;
	for (e[1]=0;e[1]<MAX_PLAYERS;e[1]++) if(IsPlayerConnected(e[1]) && e[1] != except && !fi[except][e[1]])
	{
		dis[1] = floatsqroot(floatpower(floatabs(floatsub(GetPos(e[1],1),GetPos(except,1))),2)+floatpower(floatabs(floatsub(GetPos(e[1],2),GetPos(except,2))),2)+floatpower(floatabs(floatsub(GetPos(e[1],3),GetPos(except,3))),2));
		if(dis[1]< dis[0])
		{
			dis[0] = dis[1];
			e[0] = e[1];
		}
	}
	return e[0];
}
public OnRconCommand(cmd[])
{
	print("Nieko...");
	return 1;
}
public Putimas(playerid)
{
print("Putimas");
new Float:giv, girtas;
girtas=GetPlayerDrunkLevel(playerid) - 5000;
if(girtas <0){girtas = 0;}
GetPlayerHealth(playerid, giv);
SetPlayerHealth(playerid, giv += 50);
SetPlayerDrunkLevel(playerid, girtas);
return 1;
}
// ================================================== lobiai.txt ==================================================
public UpdateLobiai()
{
	LobiuDB[Lobis] = random(sizeof(lobiai));
	LobiuDB[IsPicked] = false;
}

stock SearchLobis(playerid)
{
	if(GetPlayerWeapon(playerid)!= 6)
	{
		SendClientMessage(playerid,TEXTCOL_BLUE,"Kasimui jums prireiks kastuvo.");
		return 1;
	}

	ApplyAnimation(playerid, "MISC", "pickup_box", 4.000000, 0, 0, 0, 0, -1);

	if(!LobiuDB[IsPicked] && PlayerToPoint(3,playerid,lobiai[LobiuDB[Lobis]][0],lobiai[LobiuDB[Lobis]][1],lobiai[LobiuDB[Lobis]][2]))
	{
		FindLobis(playerid);
		return 1;
	}

	SendClientMessage(playerid,TEXTCOL_BLUE,"Cia lobio nera.");
	return 1;
}
stock FindLobis(playerid)
{
	new muny, exp, msg[128];
	muny = 8000+random(4000);
	exp = 600+random(400);
	format(msg, sizeof(msg), "Suradai lobi! Jame buvo %i LT. Taip pat igyjai %i xp jo ieskodamas(a)!",muny, exp);
	SendClientMessage(playerid,TEXTCOL_BLUE,msg);

	GivePlayerMoneyA(playerid,muny);
	SetPlayerScore(playerid,GetPlayerScore(playerid)+exp);
	LobiuDB[IsPicked]=true;
}

stock EnableLobiai()
{
	SetTimer("UpdateLobiai",3600000*24,true);
	UpdateLobiai();
}
// ================================================== lobiai.txt ==================================================
// ================================================== gangs.txt ==================================================
public UnInvite(gang,playerid)
{
	gangDB[gang][invited][playerid]=false;
}

stock SendMessageToGM(gang,color,text[])
{
	for(new i=0; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(gplayerDB[i][pgang]==gang)
			{
				SendClientMessage(i,color,text);
			}
		}
	}
}
// ================================================== gangs.txt ==================================================
// ================================================== bussnesDB.txt ==================================================
stock CreateBussiness(bmoka,bkaina,bpavadinimas[],Float:x,Float:y,Float:z)
{
	new busid = CreatePickupA(1318 , 2,x,y,z);
	bussinesDB[busid][moka]=bmoka*4;
	bussinesDB[busid][bizkaina]=bkaina;
	strmid(bussinesDB[busid][pavadinimas],bpavadinimas,0,128,128);
	return busid;
}
// ================================================== bussnesDB.txt ==================================================
// ================================================== global.txt ==================================================
stock GlobalSystem()
{
	EnableTirePopping(1);
	AllowInteriorWeapons(1);
	EnableZoneNames(1);

	SendRconCommand("mapname San Fierro");
	SendRconCommand("reloadfs UPDATE");
	new tmp[256];
	format(tmp,256,"%s",VERSIJA);
	SetGameModeText(tmp);
	EnableStuntBonusForAll(false);
	GlobalUpdate();
	SetNameTagDrawDistance(15);
	LimitGlobalChatRadius(20);
}

public GlobalUpdate()
{
	new Hour;
	gettime(Hour);
	SetWorldTime(Hour);

	if(random(5)==3) cikle++; if(cikle > sizeof(oruciklas) || cikle > sizeof(gravitacijos)) cikle=0;

	SetWeather(oruciklas[cikle]);
	SetGravity(gravitacijos[cikle]);

	afondas+=20000000;

}
// ================================================== global.txt ==================================================
// ================================================== Dini.txt ==================================================
stock  dini_Exists(filename[]) {
	if (fexist(filename)) return true;
	return false;
}

stock  dini_Remove(filename[]) {
	if (!fexist(filename)) return false;
	fremove(filename);
	return true;
}

stock  dini_Create(filename[]) {
	new File:fhnd;
	if (fexist(filename)) return false;
	fhnd=fopen(filename,io_write);
	fclose(fhnd);
	return true;
}

stock  dini_PRIVATE_ExtractKey(line[]) {
	new tmp[MAX_STRING];
	tmp[0]=0;
	if (strfind(line,"=",true)==-1) return tmp;
	set(tmp,strlower(ret_memcpy(line,0,strfind(line,"=",true))));
	return tmp;
}

stock  dini_PRIVATE_ExtractValue(line[]) {
    new tmp[MAX_STRING];
    tmp[0]=0;
    if (strfind(line,"=",true)==-1) {
        return tmp;
    }
    set(tmp,ret_memcpy(line,strfind(line,"=",true)+1,strlen(line)));
    return tmp;
}

stock  dini_Set(filename[],key[],value[]) {
	new File:fohnd, File:fwhnd;
	new bool:wasset=false;
	new tmpres[MAX_STRING];
	if (key[0]==0) return false; /* If we have no sign in key, it can't be set*/
	format(tmpres,sizeof(tmpres),"%s.part",filename);
	fohnd=fopen(filename,io_read);
	if (!fohnd) return false;
	fremove(tmpres);
	fwhnd=fopen(tmpres,io_write);
	//  if (!fwhnd) return false;
	while (fread(fohnd,tmpres)) {
		StripNewLine(tmpres);
		if ((!wasset)&&(equal(dini_PRIVATE_ExtractKey(tmpres),key,true))) {
			/* We've got what needs to be replaced! */
			format(tmpres,sizeof(tmpres),"%s=%s",key,value);
			wasset=true;
		}
		fwrite(fwhnd,tmpres);
		fwrite(fwhnd,"\r\n");
	}

	if (!wasset) {
		format(tmpres,sizeof(tmpres),"%s=%s",key,value);
		fwrite(fwhnd,tmpres);
		fwrite(fwhnd,"\r\n");
	}

	fclose(fohnd);
	fclose(fwhnd);

	format(tmpres,sizeof(tmpres),"%s.part",filename);
	if (fcopytextfile(tmpres,filename)) {
		return fremove(tmpres);
	}
	return false;
}


stock  dini_IntSet(filename[],key[],value) {
   new valuestring[MAX_STRING];
   format(valuestring,sizeof(valuestring),"%d",value);
   return dini_Set(filename,key,valuestring);
}

stock  dini_Int(filename[],key[]) {
   return strval(dini_Get(filename,key));
}

stock  dini_FloatSet(filename[],key[],Float:value) {
   new valuestring[MAX_STRING];
   format(valuestring,sizeof(valuestring),"%f",value);
   return dini_Set(filename,key,valuestring);
}

stock  Float:dini_Float(filename[],key[]) {
   return floatstr(dini_Get(filename,key));
}

stock  dini_Bool(filename[],key[]) {
   return strval(dini_Get(filename,key));
}

stock  dini_BoolSet(filename[],key[],value) {
   new valuestring[MAX_STRING];
   format(valuestring,sizeof(valuestring),"%d",value);
   return dini_Set(filename,key,valuestring);
}

stock  dini_Unset(filename[],key[]) {
	new File:fohnd, File:fwhnd;
	new tmpres[MAX_STRING];
	format(tmpres,sizeof(tmpres),"%s.part",filename);
	fohnd=fopen(filename,io_read);
	if (!fohnd) return false;
	fremove(tmpres);
	fwhnd=fopen(tmpres,io_write);
	//  if (!fwhnd) return false;
	while (fread(fohnd,tmpres)) {
		StripNewLine(tmpres);
		if (equal(dini_PRIVATE_ExtractKey(tmpres),key,true)) {
			/* We've got what needs to be removed! */
		} else {
			format(tmpres,sizeof(tmpres),"%s",tmpres);
			fwrite(fwhnd,tmpres);
			fwrite(fwhnd,"\r\n");
		}
	}

	fclose(fohnd);
	fclose(fwhnd);

	format(tmpres,sizeof(tmpres),"%s.part",filename);
	if (fcopytextfile(tmpres,filename)) {
		return fremove(tmpres);
	}
	return false;
}

stock  dini_Get(filename[],key[]) {
	new File:fohnd;
	new tmpres[MAX_STRING];
	new tmpres2[MAX_STRING];
	tmpres[0]=0;
	fohnd=fopen(filename,io_read);
	if (!fohnd) return tmpres;
	while (fread(fohnd,tmpres)) {
		StripNewLine(tmpres);
		if (equal(dini_PRIVATE_ExtractKey(tmpres),key,true)) {
			/* We've got what we need */
			tmpres2[0]=0;
			strcat(tmpres2,dini_PRIVATE_ExtractValue(tmpres));
			fclose(fohnd);
			return tmpres2;
		}
	}
	fclose(fohnd);
	return tmpres;
}


stock  dini_Isset(filename[],key[]) {
	new File:fohnd;
	new tmpres[MAX_STRING];
	fohnd=fopen(filename,io_read);
	if (!fohnd) return false;
	while (fread(fohnd,tmpres)) {
		StripNewLine(tmpres);
		if (equal(dini_PRIVATE_ExtractKey(tmpres),key,true)) {
			/* We've got what we need */
			fclose(fohnd);
			return true;
		}
	}
	fclose(fohnd);
	return false;
}
// ================================================== Dini.txt ==================================================
// ================================================== Dutils.txt ==================================================
stock isNumeric(const string[]) {
	new length=strlen(string);
	if (length==0) return false;
	for (new i = 0; i < length; i++) {
		if (
		(string[i] > '9' || string[i] < '0' && string[i]!='-' && string[i]!='+') // Not a number,'+' or '-'
		|| (string[i]=='-' && i!=0)                                             // A '-' but not at first.
		|| (string[i]=='+' && i!=0)                                             // A '+' but not at first.
		) return false;
	}
	if (length==1 && (string[0]=='-' || string[0]=='+')) return false;
	return true;
}

/*
 * Originally created by mabako, tuned by DracoBlue
 */



/**
 *  Return if a Email is valid or not
 *  @param   value
 */
stock ValidEmail(email[]) {
  new len=strlen(email);
  new cstate=0;
  new i;
  for(i=0;i<len;i++) {
    if ((cstate==0 || cstate==1) && (email[i]>='A' && email[i]<='Z') || (email[i]>='a' && email[i]<='z')  || (email[i]=='.')  || (email[i]=='-')  || (email[i]=='_'))
    {
    } else {
       // Ok no A..Z,a..z,_,.,-
       if ((cstate==0) &&(email[i]=='@')) {
          // its an @ after the name, ok state=1;
          cstate=1;
       } else {
          // Its stuff which is not allowed
          return false;
       }
    }
  }
  if (cstate<1) return false;
  if (len<6) return false;
  // A toplevel domain has only 3 to 4 signs :-)
  if ((email[len-3]=='.') || (email[len-4]=='.') || (email[len-5]=='.')) return true;
  return false;
}

/**
 *  Return a timestamp
 */



/**
 *  Return a timestamp
 */


/**
 *  Return the value of an hex-string
 *  @param string
 */
stock HexToInt(string[]) {
  if (string[0]==0) return 0;
  new i;
  new cur=1;
  new res=0;
  for (i=strlen(string);i>0;i--) {
    if (string[i-1]<58) res=res+cur*(string[i-1]-48); else res=res+cur*(string[i-1]-65+10);
    cur=cur*16;
  }
  return res;
}

/**
 *  Return the int as string
 *  @param   number
 */
stock IntToHex(number)
{
	new m=1;
	new depth=0;
	while (number>=m) {
		m = m*16;
		depth++;
	}
	depth--;
	new str[MAX_STRING];
	for (new i = depth; i >= 0; i--)
	{
		str[i] = ( number & 0x0F) + 0x30; // + (tmp > 9 ? 0x07 : 0x00)
		str[i] += (str[i] > '9') ? 0x07 : 0x00;
		number >>= 4;
	}
	str[8] = '\0';
	return str;
}

/**
 *  Return the string as int
 *  @param   string
 */
stock StrToInt(string[]) {
  return strval(string);
}

/**
 *  Return the value as string
 *  @param   value
 */
stock IntToStr(value) {
  new tmp[MAX_STRING];
  valstr(tmp, value);
  return tmp;
}

/**
 *  Return the truncated value
 *  @param   Float:value
 */
stock trunc(Float:value) {
	return floatround(value,floatround_floor);
}

/**
 *  Sets money for player
 *  @param   playerid
 *           howmuch
 */
stock SetPlayerMoney(playerid,howmuch) {
  PRIVATE_Last_Money[playerid]=howmuch;
  GivePlayerMoney(playerid,howmuch-GetPlayerMoney(playerid));
}

/**
 *  Copies a file (Source file won't be deleted!)
 *  @param   oldname
 *           newname
 *  @requires WINDOWS
 */
stock fcopy(oldname[],newname[]) {
	new File:ohnd,File:nhnd;
	if (!fexist(oldname)) return false;
	ohnd=fopen(oldname,io_read);
	nhnd=fopen(newname,io_write);
	new buf2[1];
	new i;
	for (i=flength(ohnd);i>0;i--) {
		fputchar(nhnd, fgetchar(ohnd, buf2[0],false),false);
	}
	fclose(ohnd);
	fclose(nhnd);
	return true;
}


/**
 *  Copies a textfile (Source file won't be deleted!)
 *  @param   oldname
 *           newname
 */
stock fcopytextfile(oldname[],newname[]) {
	new File:ohnd,File:nhnd;
	if (!fexist(oldname)) return false;
	ohnd=fopen(oldname,io_read);
	nhnd=fopen(newname,io_write);
	new tmpres[MAX_STRING];
	while (fread(ohnd,tmpres)) {
		StripNewLine(tmpres);
		format(tmpres,sizeof(tmpres),"%s\r\n",tmpres);
		fwrite(nhnd,tmpres);
	}
	fclose(ohnd);
	fclose(nhnd);
	return true;
}


/**
 *  Renames a file (Source file will be deleted!)
 *  @param   oldname
 *           newname
 *  @requires WINDOWS (because fcopy does)
 */
stock frename(oldname[],newname[]) {
    if (!fexist(oldname)) return false;
    fremove(newname);
    if (!fcopy(oldname,newname)) return false;
    fremove(oldname);
    return true;
}

/**
 *  Renames a file (Source file will be deleted!)
 *  @param   oldname
 *           newname
 */
stock frenametextfile(oldname[],newname[]) {
    if (!fexist(oldname)) return false;
    fremove(newname);
    if (!fcopytextfile(oldname,newname)) return false;
    fremove(oldname);
    return true;
}

/**
 *  Strips Newline from the end of a string.
 *  Idea: Y_Less, Bugfixing (when length=1) by DracoBlue
 *  @param   string
 */
stock StripNewLine(string[])
{
	new len = strlen(string);
	if (string[0]==0) return ;
	if ((string[len - 1] == '\n') || (string[len - 1] == '\r')) {
		string[len - 1] = 0;
		if (string[0]==0) return ;
		if ((string[len - 2] == '\n') || (string[len - 2] == '\r')) string[len - 2] = 0;
	}
}

/**
 *  Copies items from one array/string into return.
 *  @param   source
 *           index (where to start, 0 is first)
 *           numbytes (how much)
 */
ret_memcpy(source[],index=0,numbytes) {
	new tmp[MAX_STRING];
	new i=0;
	tmp[0]=0;
	if (index>=strlen(source)) return tmp;
	if (numbytes+index>=strlen(source)) numbytes=strlen(source)-index;
	if (numbytes<=0) return tmp;
	for (i=index;i<numbytes+index;i++) {
		tmp[i-index]=source[i];
		if (source[i]==0) return tmp;
	}
	tmp[numbytes]=0;
	return tmp;
}

/**
 *  Copies items from one array/string into another.
 *  @param   dest
 *           source
 *           count
 */
stock copy(dest[],source[],count) {
	dest[0]=0;
	if (count<0) return false;
	if (count>strlen(source)) count=strlen(source);
	new i=0;
	for (i=0;i<count;i++) {
		dest[i]=source[i];
		if (source[i]==0) return true;
	}
	dest[count]=0;
	return true;
}


/**
 *  Deletes the first 'count' items of a array/string
 *  @param   string[]
 *           count
 */
stock delete(string[],count) {
	new tmp[MAX_STRING];
	tmp[0]=0;
	if (count<=0) {
		format(tmp,sizeof(tmp),"%s",string);
		return tmp;
	}
	tmp=ret_memcpy(string,count,strlen(string));
	return tmp;
}

/**
 *  Sets a string's value to source.
 *  @param   dest
 *           source
 *           count
 */
stock set(dest[],source[]) {
	new count = strlen(source);
	new i=0;
	for (i=0;i<count;i++) {
		dest[i]=source[i];
	}
	dest[count]=0;
}

/**
 *  Checks wether two strings are equal (case insensetive)
 *  @param   str1
 *           str2
 */
stock equal(str1[],str2[],bool:ignorecase) {
    if (strlen(str1)!=strlen(str2)) return false;
    if (strcmp(str1,str2,ignorecase)==0) return true;
    return false;
}

/**
 *  Returns an element of a string splitted by ' ', default index is 0.
 *  @param   string
 *           index
 */
stock strtok(const string[], &index,seperator=' ')
{
	new length = strlen(string);
	new offset = index;
	new result[MAX_STRING];
	while ((index < length) && (string[index] != seperator) && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}

	result[index - offset] = EOS;
	if ((index < length) && (string[index] == seperator))
	{
		index++;
	}
	return result;
}

stock mod(up,down) {
  return up-(floatround((up/down),floatround_floor))*down;
}

stock div(up,down) {
  return (floatround((up/down),floatround_floor));
}

/**
 *  Returns a hashed value in adler32 as int
 *  @param   buf
 */
stock num_hash(buf[])
 {
	new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++) {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    return (s2 << 16) + s1;
 }

/**
 *  Returns a hashed value in adler32 as string
 *  @param   buf
 */
stock hash(str2[]) {
   new tmpdasdsa[MAX_STRING];
   tmpdasdsa[0]=0;
   valstr(tmpdasdsa,num_hash(str2));
   return tmpdasdsa;
}

/**
 *  Returns a string which has 'newstr' where 'trg' was before
 *  @param   trg
 *           newstr
 *           src
 */
stock strreplace(trg[],newstr[],src[]) {
    new f=0;
    new s1[MAX_STRING];
    new tmp[MAX_STRING];
    format(s1,sizeof(s1),"%s",src);
    f = strfind(s1,trg);
    tmp[0]=0;
    while (f>=0) {
        strcat(tmp,ret_memcpy(s1, 0, f));
        strcat(tmp,newstr);
        format(s1,sizeof(s1),"%s",ret_memcpy(s1, f+strlen(trg), strlen(s1)-f));
        f = strfind(s1,trg);
    }
    strcat(tmp,s1);
    return tmp;
}

/**
 *  Returns the string with lowercase
 *  @param   txt
 */
stock strlower(txt[]) {
	new tmp[MAX_STRING];
	tmp[0]=0;
	if (txt[0]==0) return tmp;
	new i=0;
	for (i=0;i<strlen(txt);i++) {
		tmp[i]=tolower(txt[i]);
	}
	tmp[strlen(txt)]=0;
	return tmp;
}

/**
 *  Returns the string with uppercase
 *  @param   txt
 */
stock strupper(txt[]) {
	new tmp[MAX_STRING];
	tmp[0]=0;
	if (txt[0]==0) return tmp;
	new i=0;
	for (i=0;i<atrlen(txt);i++) {
		tmp[i]=toupper(txt[i]);
	}
	tmp[strlen(txt)]=0;
	return tmp;
}
// ================================================== Dutils.txt ==================================================
// ================================================== cop-tools.txt ==================================================
RemoveItems(playerid)
{
	        if(IsPlayerAttachedObjectSlotUsed(playerid,1)) RemovePlayerAttachedObject(playerid,1);
	        if(IsPlayerAttachedObjectSlotUsed(playerid,2)) RemovePlayerAttachedObject(playerid,2);
}

PutRiotShieldOnBack(playerid)
{
	    if(IsPlayerAttachedObjectSlotUsed(playerid,1)) RemovePlayerAttachedObject(playerid,1);
		SetPlayerAttachedObject(playerid, 1 , 18637, 1, 0, -0.1, 0.18, 90, 0, 272, 1, 1, 1);
}

PutRiotShieldOnArm(playerid)
{
	    if(IsPlayerAttachedObjectSlotUsed(playerid,1)) RemovePlayerAttachedObject(playerid,1);
		SetPlayerAttachedObject(playerid, 1, 18637, 4, 0.3, 0, 0, 0, 170, 270, 1, 1, 1);
}

GiveFlashLight(playerid)
{
	    if(IsPlayerAttachedObjectSlotUsed(playerid,2)) RemovePlayerAttachedObject(playerid,2);
		SetPlayerAttachedObject(playerid, 2,18641, 5, 0.1, 0.02, -0.05, 0, 0, 0, 1, 1, 1);
}

GiveTazer(playerid)
{
	    if(IsPlayerAttachedObjectSlotUsed(playerid,2)) RemovePlayerAttachedObject(playerid,2);
		SetPlayerAttachedObject(playerid, 2,18642, 5, 0.12, 0.02, -0.05, 0, 0, 45,1,1,1);
}
// ================================================== cop-tools.txt ==================================================
