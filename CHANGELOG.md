# WorldWeaver Changelog - Version 0.10.1

All notable changes to WorldWeaver are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [0.10.1] - 2026-08-29

### Major Features

#### Complete Procedural Terrain Pipeline
- **`Generator` module** — fully functional terrain generation system with:
  - `generateHeight` — seeded `math.noise` with configurable frequency and scale, output clamped and shifted to `[0, 1]`
  - `generateDensity` — 3D cave density noise support
  - `genereateGRID_Division` — multi-threaded height grid computation with biome assignment, falloff, interpolation, and blending
  - `generateDivision` — part/terrain rendering from the height grid with height-difference-aware gap-filling
  - `generateTerrain` — top-level orchestrator for map division and sequencing
  - `blendColorSimple` — configurable-step color averaging across biome boundaries

#### Biome Painting System
- **`Painting` module** — `SetBiome` classifies cells using penalty-distance scoring across all four noise axes, always returning the closest-matching biome and a normalized inverse-penalty score

#### Advanced Configuration Surface
- **`Settings` module** — complete configuration with:
  - Map dimensions (`MapWidth`, `MapBreadth`, `startX`, `startZ`)
  - `Center` and `maxDistanceFromCenter` pre-computed for falloff
  - `VoxelSize`, `ChunkSize`, `GridDIV`, `CaveDisabledMapDIV`
  - `Seed`, `Scale`, `smoothifyScale`, `Persistance`
  - `smoothify` — smooth vs. blocky terrain toggle
  - `useInBuiltTerrain` — `workspace.Terrain:FillBlock` vs. Parts
  - `implementBiomeScoring` — score-weighted height variation
  - `fallOff`, `fallOffStart`, `fallOffEnd` — smoothstep island falloff
  - `blendOn`, `fastBlend`, `blendThresh`, `fastBlendThresh`, `blendColorThresh`
  - `GridCAP`, `RenderThreadCap`, `breathingTime`
  - `Biomes` list and `BiomeDetails` table with noise axis `NumberRange` values

#### Five Default Noise Layers
- **Continentalness** — base terrain shape (Priority 1)
- **Peaks & Valleys (PV)** — mountain detail (Priority 4)
- **Erosion** — terrain smoothing/roughness (Priority 2)
- **Temperature** — climate influence (Priority 5)
- **Humidity** — moisture patterns (Priority 3)

#### Four Default Biomes
- **Plains** — green, grassy terrain
- **Mountains** — rocky, elevated terrain
- **Desert** — sandy, flat terrain
- **Ice** — frozen, white terrain

#### Settings Features
- **`Settings.Name`** — named settings objects for identifying multiple terrain instances
- **`Settings.gridLoadedEvent` / `Settings.terrainRenderedEvent`** — `BindableEvent` hooks for external scripts
- **`sharperBiomes` / `sharpnessBiomeDefactor`** — optional post-biome amplitude multiplier for distinct biome boundaries
- **Noise priority system** — `NoiseNames` entries carry `{Name, Priority}` for ordered noise layers
- **`_noiseCache`** — sorted priority-to-nickname lookup for guaranteed iteration order
- **Persistence-weighted noise accumulation** — `noise * amp * (Persistence ^ layerIndex)` for hierarchical terrain influence

### New Modules
- `Generator` — procedural terrain generation
- `Painting` — biome classification
- `Settings` — configuration system

### Enhancements

#### Rendering Improvements
- **Chunk system** — terrain parts grouped into atomic `Model` instances for Roblox streaming compatibility
- **Gap-filling** — height-difference-aware single fill, stacked fills, and double fill modes
- **`n_chunk` guarded by `useInBuiltTerrain`** — chunk allocation skipped when using built-in terrain

#### Code Quality
- **`BuildInterpolationCache()` renamed to `BuildCache()`** — builds both interpolation and noise caches in one call
- **`BuildCache()` pre-sorts keys** — `GetInterpolatedAmpValue` uses sorted `ipairs` for linear interpolation
- **`setAttributes` updated** — reads `v[1]` from new `NoiseNames` table format
- **`div_no` moved inside thread-cap branch** — accurate division count printing
- **`fallOff` now applied to `c_Y_`** — consistent falloff across both height values

#### Performance
- **Multi-threaded generation** — `GridCAP` and `RenderThreadCap` controls
- **Yielding between divisions** — prevents frame freezing
- **Interpolation caching** — pre-sorted keys for faster lookups

### Bug Fixes
- Voxel seam creases between adjacent fills — overlap on all three axes
- Concentric ring artifacts from stepped interpolation — linear interpolation between sorted keys
- `pairs` over numeric keys returning arbitrary order — `ipairs` over cached list
- Double `VoxelSize` multiply on `currX`/`currZ` — removed conditional multiply
- `c_Y -= c_Y % voxelSize` executing outside guard — fixed height snapping
- `n_chunk` allocated and unused with `useInBuiltTerrain = true` — skipped allocation

### Breaking Changes
- **`NoiseNames` format changed** — values are `{ActualName, Priority}` tables instead of strings
- **`BuildInterpolationCache()` removed** — use `settings:BuildCache()` instead
- **`smoothify` branch added back for if `blendOn = false`** — even if a blend doesn't occur, the snapping will happen if smoothify is off
- **Default values changed**:
  - `smoothificationFactor` = `VoxelSize - 0.001`
  - `implementBiomeScoring` = `false`
  - `useInBuiltTerrain` = `false`
  - `fastBlend` = `true`

### Deprecated
- **`smoothifyPartition` / `smoothifyIncrement`** — removed in favor of grid-level height smoothing
- **`Persistance` spelling** — use `Persistence` in documentation (field name remains `Persistance` for compatibility)

### Documentation
- Apache 2.0 license added
- README with getting-started guide and mode snapshots
- Inline comments for all configuration options
- Step-by-step guides for adding noise layers and biomes

---

*WorldWeaver is developed by chicken-ahm-12.*  
*Licensed under the [Apache License 2.0](./LICENSE.md).*