/* Custom Tune Include
 * (c) Copyright 2023
 * This file is provided as is (no warranties).
 */

#if defined _customtune_included
  #endinput
#endif
#define _customtune_included

// Базовые функции для тюнинга (если у тебя специфический мод, 
// функции могут отличаться, но компилятор их пропустит)

native IsValidVehicle(vehicleid);
native GetVehicleModel(vehicleid);
native AddVehicleComponent(vehicleid, componentid);
native RemoveVehicleComponent(vehicleid, componentid);
native ChangeVehicleColor(vehicleid, color1, color2);
native ChangeVehiclePaintjob(vehicleid, paintjobid);
native SetVehicleNumberPlate(vehicleid, numberplate[]);
native GetVehicleComponentInSlot(vehicleid, slot);
native GetVehicleComponentType(component);
native UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);