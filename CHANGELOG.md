# WorldWeaver Changelog

All notable changes to WorldWeaver are documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added
- **`Settings.Name`** — named settings objects for identifying multiple terrain
  instances in a single server.
- **`Settings.gridLoadedEvent` / `Settings.terrainRenderedEvent`** — `BindableEvent`
  hooks fired at the end of each generation phase so external scripts can react to
  grid completion and terrain render completion without polling.
- **`sharperBiomes` / `sharpnessBiomeDefactor`** — optional post-biome amplitude
  multiplier (`c_Y *= biomeDetails[biome].amp / sharpnessBiomeDefactor`) that makes
  biome height boundaries more visually distinct even when blending is enabled.
- **Noise priority system** — `NoiseNames` entries now carry a second value
  (`{Name, Priority}`) so noise layers can be ordered by priority rather than
  arbitrary table iteration order, driving the new persistence-weighted accumulation.
- **`_noiseCache`** — sorted priority-to-nickname lookup built once by `BuildCache()`
  so the grid loop iterates noise layers in a guaranteed priority order each time.
- **Persistence-weighted noise accumulation** — height now accumulated as
  `noise * amp * (Persistence ^ layerIndex)` and interpolated value as
  `interpolated * (Persistence ^ layerIndex) + c_Y_`, giving higher-priority noises
  more influence over the base terrain shape.
- **`n_chunk` guarded by `useInBuiltTerrain`** — chunk allocation in
  `generateDivision` is now skipped entirely when using built-in terrain, avoiding
  unnecessary `Model` creation overhead.
- **`div_no` increment moved inside the thread-cap branch** in `generateTerrain` grid
  loop so division count printing is accurate.

### Changed
- **`BuildInterpolationCache()` renamed to `BuildCache()`** — now builds both
  `_interpCache` (sorted interpolation keys) and `_noiseCache` (priority-sorted noise
  nickname lookup) in a single call. Callers must update to `settings:BuildCache()`.
- **`NoiseNames` format changed** — values are now `{ActualName, Priority}` tables
  instead of plain strings. `NoiseDetails` and `InterpolationValues` must be keyed by
  `NoiseNames.Cont[1]` (the name string) rather than `NoiseNames.Cont` directly.
- **`setAttributes` updated** — now reads `v[1]` (the name string) from the new
  `NoiseNames` table format when writing Part attributes.
- **`smoothificatonFactor` default changed** — now `VoxelSize - 0.001` (near-full
  overlap) instead of a fixed `3.9`, so the overlap scales correctly with any
  `VoxelSize` without manual tuning.
- **`smoothify` branch in `generateDivision` removed** — the separate
  `smoothifyPartition` / `smoothifyIncrement` path and its extra `t_parts` branching
  is gone; the loop now uses a single `VoxelSize`-stepped fill for all modes. Smooth
  appearance comes from the grid-level height values rather than render-time
  sub-stepping.
- **`implementBiomeScoring` default changed to `false`**.
- **`useInBuiltTerrain` default changed to `false`**.
- **`fastBlend` default changed to `true`**.
- **Interpolation table values retuned** — all five noise layers have revised height
  curves producing more believable continental shelves, mountain peaks, and flat
  plains with the new persistence-weighted accumulation.
- **`Persistance` (sic) renamed in comments to `Persistence`** — the field name in
  code remains `Persistance` for backwards compatibility but documentation now
  correctly labels its effect ("higher = more ragged/spiky, lower = flatter").
- **`fallOff` now also applied to `c_Y_`** in the grid pass (previously only `c_Y`
  was multiplied by `fallOffValue`).

### Fixed
- Voxel seam creases between adjacent `FillBlock` fills — `smoothificationSize` now
  adds overlap on all three axes (`VoxelSize - 0.001` per axis) rather than only Y.
- Concentric ring artifacts caused by stepped `GetInterpolatedAmpValue` lookup —
  now linearly interpolates between sorted table keys.
- `pairs` over numeric interpolation keys returning arbitrary order — `BuildCache()`
  pre-sorts keys and `GetInterpolatedAmpValue` uses `ipairs` over the cached list.
- Double `VoxelSize` multiply on `currX`/`currZ` in `generateDivision` — the
  conditional second multiply inside `if not smoothify` is removed; position is
  multiplied exactly once unconditionally.
- `c_Y -= c_Y % voxelSize` executing outside its `if not smoothify` guard, snapping
  heights in smooth mode and producing stepped geometry.
- `n_chunk` being allocated and then unused when `useInBuiltTerrain = true`.

---

### Added
- **`Generator` module** with full procedural terrain pipeline:
  - `generateHeight` — seeded `math.noise` with configurable frequency and scale,
    output clamped and shifted to `[0, 1]`
  - `generateDensity` — 3D cave density noise
  - `genereateGRID_Division` — multi-threaded height grid computation with biome
    assignment, falloff, interpolation, and optional blending
  - `generateDivision` — part/terrain rendering from the height grid with
    height-difference-aware gap-filling (single fill, stacked fills, double fill)
  - `generateTerrain` — top-level orchestrator dividing the map into grid and render
    chunks, managing thread caps, and sequencing the two passes
  - `blendColorSimple` — 4-directional configurable-step color averaging across biome
    boundaries
  - `createPart` / `setAttributes` / `createChunk` / `getChunk` — part-mode terrain
    helpers
- **`Settings` module** with full configuration surface:
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
  - `Biomes` list and `BiomeDetails` table (amplitude, color, material, four noise
    axis `NumberRange` values per biome)
  - `NoiseNames`, `NoiseDetails`, `InterpolationValues` — full noise layer
    configuration
  - `BuildCache()` / `GetInterpolatedAmpValue()` — sorted linear
    interpolation lookup
  - `fallOffFunction()` — smoothstep ramp between `fallOffStart` and `fallOffEnd`
  - `ValueInRange()` — penalty-distance range check used by biome scoring
  - `GetPartAttributes()` — reads noise attribute values back from a placed Part
- **`Painting` module** — `SetBiome` classifies a cell using penalty-distance scoring
  across all four noise axes, always returning the closest-matching biome and a
  normalised inverse-penalty score
- **Chunk system** — terrain parts grouped into named `Model` instances using
  `ModelStreamingMode.Atomic` for Roblox streaming compatibility
- **Five default noise layers:** Continentalness, PV (Peaks & Valleys), Erosion,
  Temperature, Humidity
- **Four default biomes:** Plains, Mountains, Desert, Ice — with non-overlapping
  noise ranges and distinct materials
- Apache 2.0 license, README with getting-started guide and mode snapshots

---

*WorldWeaver is developed by chicken-ahm-12.*  
*Licensed under the [Apache License 2.0](./LICENSE.md).*