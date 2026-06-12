#pragma semicolon 1

#include <sourcemod>
#include <SteamWorks>

#define PLUGIN_VERSION "1.1"

new Handle:descriptionCvar = INVALID_HANDLE;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max) { 
	MarkNativeAsOptional("Updater_AddPlugin"); 
	return APLRes_Success;
} 

public OnPluginStart() {
	descriptionCvar = CreateConVar("sw_gamedesc_override", "Bhop Server", "What to override your game description to");
	decl String:description[128];
	GetConVarString(descriptionCvar, description, sizeof(description));
	HookConVarChange(descriptionCvar, CvarChanged);
	SteamWorks_SetGameDescription(description);
}

public CvarChanged(Handle:cvar, const String:oldVal[], const String:newVal[]) {
	decl String:description[128];
	GetConVarString(descriptionCvar, description, sizeof(description));
	SteamWorks_SetGameDescription(description);
}

public OnAllPluginsLoaded() {
	new Handle:buffer;
        buffer = CreateConVar("sw_gamedesc_override_version", PLUGIN_VERSION, "SteamWorks Game Description Override Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_CHEAT);
	HookConVarChange(buffer, Callback_VersionConVarChanged);
}

public Callback_VersionConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[]) {
	ResetConVar(convar);
}
