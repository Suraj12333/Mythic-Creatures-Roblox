# Roblox Boss Chase + Mythic Pets integration kit

## Included source files
- `robloxsea_BOSS_CHASE.rbxl`: the original Roblox place supplied by the user, unchanged.
- `Mythic_Pets_NEW_RIGS_440_Animations.zip`: the complete original rig/animation archive, unchanged.
- `Install_Mythic_Bosses.server.lua`: additive Studio installer for imported rig Models and end-of-biome anchors; also raises owner/marker BillboardGuis.
- `BossChaseOptimization_Module.lua`: target-scan and path-recompute throttling helper intended to be called by the existing BossCombatService.
- `asset_manifest.json`: species and animation clip manifest extracted from the supplied archive.

## Important: this is a merge-ready integration kit, not a falsely claimed finished `.rbxl`
The source archive contains Blender and FBX exports, not Roblox-published animation assets. The 440 FBX clips do not have Roblox animation asset IDs. Roblox Studio must import/publish the rig animations under the experience owner's account before they can play in a live place. The local runtime here does not include Roblox Studio's FBX importer or publishing service, so it cannot safely bake those assets into the binary place file or generate valid animation IDs.

The original place already contains `BiomeBosses`, `BossConfig`, and `BossCombatService`. The installer deliberately does not replace the existing chase service, because doing so without editing and testing its actual source would risk duplicate controllers or breaking the current boss behavior.

## Studio integration steps
1. Open `robloxsea_BOSS_CHASE.rbxl` in Roblox Studio and save a working copy.
2. Extract the pet archive. Import the 12 `*_NEW_RIG.fbx` files as rigged Models. Keep each imported Model named exactly as its species (for example `Storm_Dragon`).
3. Import/publish the animation FBX files for each rig in Studio's Animation Editor. Record the returned IDs in an animation-ID table. Do not use placeholder IDs.
4. Put the 12 imported Models under `ServerStorage/MythicBossAssets`.
5. Create `Workspace/BiomeBossAnchors`. Add one invisible, anchored Part per biome, with the exact biome name, positioned near the far end of that biome. The supplied place's embedded strings indicate biome identifiers including `ThornwoodJungle`, `CrystalCaverns`, `Volcano`, `Ice`, and `Desert`; confirm exact names against the live `BiomeConfig` before running.
6. Run `Install_Mythic_Bosses.server.lua` once from Studio's Command Bar. It clones the rigs into `Workspace/IntegratedMythicBosses`, sets biome attributes, and raises owner/marker BillboardGuis by 5 studs.
7. Wire `BossChaseOptimization_Module.lua` into the existing `BossCombatService` target scan and pathfinding loop. Use `GetTarget(boss, bossRoot.Position)` instead of scanning all players every frame, and call `ShouldRepath(boss, targetRoot.Position)` before recomputing a path. Keep one movement controller per boss.
8. Test in Studio with one player first, then with multiple players. Check collision, root part/PrimaryPart, animation ownership, pathfinding around biome boundaries, respawn, and server performance before publishing.

## Default biome suggestions
The installer uses a theme-based starting assignment. Verify against your actual biome layout and change `BOSS_ASSIGNMENTS` if needed:
- ThornwoodJungle: Blossom_Wolf, Thorn_Rhino
- CrystalCaverns: Crystal_Turtle, Celestial_Mantis, Abyss_Serpent
- Volcano: Ember_Lion, Magma_Golem, Solar_Phoenix
- Ice: Glacier_Stag, Lunar_Fox
- Desert: Royal_Griffin, Storm_Dragon

The boss placement anchors are deliberately explicit rather than guessing which direction is the end of each biome. Place each anchor where the boss should stand.
