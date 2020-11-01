#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

#pragma newdecls required

#define REPLAY_PAUSE "replay/enterperformancemode.wav"
#define REPLAY_RESUME "replay/exitperformancemode.wav"

#define PLUGIN_VERSION "1.0.2"

ConVar hCvarEnable;
int iCvarEnable;

public Plugin myinfo = {
    name = "[TF2] Focus Harder",
    author = "FlaminSarge",
    description = "Adds some fancy sound effects to the Hitman's Heatmaker Focus buff",
    version = PLUGIN_VERSION,
    url = "https://forums.alliedmods.net/showthread.php?t=189790"
};
public void OnMapStart() {
    PrecacheSound(REPLAY_PAUSE, true);
    PrecacheSound(REPLAY_RESUME, true);
}
public void OnPluginStart() {
    CreateConVar("focusharder_version", PLUGIN_VERSION, "[TF2] Focus Harder version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
    hCvarEnable = CreateConVar("focusharder_enable", "3", "1 - Sound effect on start/stop, 2 - Volume fade when scoped, 3 - Both", _, true, 0.0, true, 3.0);
    iCvarEnable = hCvarEnable.IntValue;
    hCvarEnable.AddChangeHook(ConVarChange_Enable);
}
public void ConVarChange_Enable(ConVar convar, const char[] oldValue, const char[] newValue) {
    int oldVal = StringToInt(oldValue);
    int newVal = StringToInt(newValue);
    iCvarEnable = newVal;
    // remove the volume fade if cvar is changed to disable it midway
    if ((oldVal & 2) && !(newVal & 2)) {
        for (int i = 1; i < MaxClients; i++) {
            if (IsClientInGame(i) && !IsFakeClient(i) && TF2_IsPlayerInCondition(i, TFCond_FocusBuff)) {
                FadeClientVolume(i, 0.0, 0.2, 0.0, 0.2);
            }
        }
    }
}
public void TF2_OnConditionAdded(int client, TFCond cond) {
    if (IsFakeClient(client)) {
        return;
    }
    if (cond == TFCond_FocusBuff && TF2_IsPlayerInCondition(client, TFCond_Zoomed)) {
        if (iCvarEnable & 1) {
            EmitSoundToClient(client, REPLAY_PAUSE);
            EmitSoundToClient(client, REPLAY_PAUSE);
        }
        if (iCvarEnable & 2) {
            FadeClientVolume(client, 80.0, 2.2, 200.0, 2.2);
        }
    }
    else if (cond == TFCond_Zoomed && TF2_IsPlayerInCondition(client, TFCond_FocusBuff) && (iCvarEnable & 2)) {
        FadeClientVolume(client, 80.0, 0.2, 200.0, 0.2);
    }
}
public void TF2_OnConditionRemoved(int client, TFCond cond) {
    if (IsFakeClient(client)) {
        return;
    }
    if (cond == TFCond_FocusBuff) {
        if (iCvarEnable & 2) {
            FadeClientVolume(client, 0.0, 0.8, 200.0, 0.8);
        }
        if (IsPlayerAlive(client) && (iCvarEnable & 1)) {
            EmitSoundToClient(client, REPLAY_RESUME);
            EmitSoundToClient(client, REPLAY_RESUME);
        }
    }
    else if (cond == TFCond_Zoomed && TF2_IsPlayerInCondition(client, TFCond_FocusBuff) && (iCvarEnable & 2)) {
        FadeClientVolume(client, 0.0, 0.2, 0.0, 0.2);
    }
}
