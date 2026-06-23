// Simulation/SimulationEngine.cs
using Godot;
using System.Threading.Tasks;

public partial class SimulationEngine : Node
{
    public NpcData[] Npcs;
    private int _npcCount = 0;
    private readonly object _lockObj = new object();

    public override void _Ready()
    {
        Npcs = new NpcData[1000];
    }

    public void AddNpc(StringName id, StringName startingRoom)
    {
        lock (_lockObj)
        {
            if (_npcCount >= Npcs.Length) return;

            Npcs[_npcCount] = new NpcData
            {
                Id = id,
                CurrentRoom = startingRoom,
                Health = 100f,
                IsActive = true
            };
            _npcCount++;
        }
    }

    public void ProcessSimulationTick(float deltaMinutes)
    {
        if (_npcCount == 0) return;

        Parallel.For(0, _npcCount, i =>
        {
            if (!Npcs[i].IsActive) return;

            Npcs[i].Lust += deltaMinutes * 0.1f;

            if (Npcs[i].Lust > 100f) Npcs[i].Lust = 100f;

            // Future: pathfinding in RoomGraph and behavior trees
        });
    }
}
