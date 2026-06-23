// Simulation/NpcData.cs
using Godot;

public struct NpcData
{
    public StringName Id;
    public StringName CurrentRoom;
    public float Health;
    public float Lust;
    public float AffectionToPlayer;
    public int CurrentActionId;
    public bool IsActive;
}
