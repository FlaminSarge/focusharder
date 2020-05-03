#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

#pragma newdecls required

#define REPLAY_PAUSE "replay/enterperformancemode.wav"
#define REPLAY_RESUME "replay/exitperformancemode.wav"

#define PLUGIN_NAME "TF2 Focus Harder"
#define PLUGIN_AUTHOR "FlaminSarge"
#define PLUGIN_VERSION "1.0.1"
#define PLUGIN_CONTACT "https://forums.alliedmods.net/showthread.php?t=189790"

public Plugin myinfo = {
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_NAME,
    version = PLUGIN_VERSION,
    url = PLUGIN_CONTACT
};
public void OnMapStart() {
    PrecacheSound(REPLAY_PAUSE, true);
    PrecacheSound(REPLAY_RESUME, true);
}
public void OnPluginStart() {
    CreateConVar("focusharder_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);
}
public void TF2_OnConditionAdded(int client, TFCond cond) {
    if (IsFakeClient(client)) return;
    if (cond == TFCond_FocusBuff && TF2_IsPlayerInCondition(client, TFCond_Zoomed)) {
        EmitSoundToClient(client, REPLAY_PAUSE);
        EmitSoundToClient(client, REPLAY_PAUSE);
        FadeClientVolume(client, 80.0, 2.2, 200.0, 2.2);
    }
    else if (cond == TFCond_Zoomed && TF2_IsPlayerInCondition(client, TFCond_FocusBuff)) {
        FadeClientVolume(client, 80.0, 0.2, 200.0, 0.2);
    }
}
public void TF2_OnConditionRemoved(int client, TFCond cond)
{
    if (IsFakeClient(client)) return;
    if (cond == TFCond_FocusBuff) {
        FadeClientVolume(client, 0.0, 0.8, 200.0, 0.8);
        if (IsPlayerAlive(client)) {
            EmitSoundToClient(client, REPLAY_RESUME);
            EmitSoundToClient(client, REPLAY_RESUME);
        }
    }
    else if (cond == TFCond_Zoomed && TF2_IsPlayerInCondition(client, TFCond_FocusBuff)) {
        FadeClientVolume(client, 0.0, 0.2, 0.0, 0.2);
    }
}