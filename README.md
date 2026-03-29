# Merger

> A polished merge-puzzle game built entirely with **Flutter — no game engine**. Inspired by top titles like Merge Mansion and Gossip Harbour, every mechanic from the drag system to particle effects to grid state is built from scratch using Flutter's widget and animation primitives.

Proving that you don't need Unity or Flame to ship a compelling merge game.

---

## Gameplay

<!-- Drop your gameplay GIF here -->
<p align="center">
  <img src="assets/gameplay.gif" alt="Merger Gameplay" width="320"/>
</p>

---

## Features

- **6 merge chains** — Plant, Pebble, Tool, Gem, Food, and Magic, each with 6 tiers
- **6 generators** — Unlock new ones as you level up (Camp → Mine → Workshop → Gem Grotto → Farm → Alchemy Lab)
- **10-level progression** — Growing energy cap, generator unlocks, and a fresh order pool at each level
- **18 unlockable map zones** — Spend coins to expand your grid and reveal new generators
- **Live order progress** — Order cards show a real-time `have / need` counter and turn green when you're ready to deliver
- **Fireworks celebration** — Order completion triggers a full-screen fireworks burst

---

## Architecture

```
lib/
├── models/          # Isar-persisted data models (TileData, PlayerStats, Order, ZoneMeta)
├── providers/       # Riverpod StateNotifiers (grid, player, orders, expansion)
├── persistence/     # GameService — atomic Isar save/load with full validation
├── widgets/         # UI components (grid, HUD, orders, map, drag layer, effects)
├── screens/         # Top-level screens (map, splash)
├── services/        # Audio (MergeAudio)
└── debug/           # Debug panel (kDebugMode only, zero production footprint)
```

### State Management — Riverpod

All state flows through **Riverpod `StateNotifier`** providers:

| Provider | Responsibility |
|----------|---------------|
| `gridProvider` | 9×7 tile grid — merges, spawns, generator activation, zone unlocks |
| `playerStatsProvider` | Energy, coins, gems, XP, level, infrastructure, zone unlock IDs |
| `orderProvider` | 3 active order slots, level-specific pool, delivery and reward logic |
| `expansionProvider` | Zone definitions, unlock status, available unlocks |

Derived reads use `.select()` to prevent unnecessary widget rebuilds. No widget touches raw state — everything goes through a provider.

### Persistence — Isar

Game state is persisted to a local **Isar** database across three collections:

- `PlayerStats` (single record, `id = 1`)
- `TileData` (one record per grid cell — 63 total)
- `Order` (up to 3 active orders)

`saveGame()` is triggered on `AppLifecycleState.paused` so progress survives backgrounding. All fields are validated on load — corrupt or out-of-range records fall back to safe defaults rather than crashing.

### Atomic Operations

Critical mutations follow a strict **validate-then-execute** pattern:

1. **Phase 1 — read-only:** Check energy, count required items, find a free spawn tile
2. **Phase 2 — mutations:** Apply everything atomically — spend energy, consume items, grant rewards, update state

Energy is never spent if no spawn tile exists. Items are never consumed unless the full order count is present. Zone coins and unlock ID are written in a single `copyWith()` — no partial state.

---

## Engineering Practices

### Invariant Checking

`_assertValidGrid()` and `_assertValidState()` run on every state write in debug builds using Dart `assert()`. They verify grid dimensions, per-tile row/col metadata, generator configuration, and order slot limits — catching programmer errors at the earliest possible point, with zero overhead in release builds.

### Load Validation

Every field of a loaded `PlayerStats` is checked before it touches provider state. Out-of-range levels, negative coins, and impossible energy values are all caught with a warning log and a safe default fallback — the game never silently starts in a corrupt state.

### Robustness Hardening

The codebase went through **nine systematic audit passes**, each targeting new areas:

- Atomic energy-spend + spawn (no energy lost when grid is full)
- Generator placement retry after zone unlock (generators in locked zones now placed on zone open)
- Corrupt save recovery — partial grids, null `generatesItemPath`, wrong Isar record ID
- Dead code removal — 5 unused `StateProvider`s, stale special-case merge rules
- `Isar.autoIncrement` → `get(1)` fix (saves were silently never loading)
- Level-specific order pools — no old-level orders bleeding through on level-up
- Drop-onto-generator blocked in drag validation (prevented silent generator overwrite)
- Navigation index clamped against out-of-bounds crash
- `availableUnlocksProvider` fixed to watch live player level (was frozen at level 1)

---

## Testing

```bash
flutter test
```

**45 unit tests** covering all critical game paths:

| Group | What's covered |
|-------|---------------|
| Merge Tree Logic | Sequence lookup, terminal detection, chain boundaries |
| Player Stats | Energy, coins, level-up thresholds, XP, order progression |
| Grid Mechanics | `updateTile`, `mergeTiles`, `activateGenerator`, atomicity |
| Order System | Delivery success/failure, partial delivery rejection, reward grants, slot refill, level-specific pool |
| Full Game Loop | Generate → merge → deliver → level-up, end-to-end |

Tests use **`ProviderContainer`** to exercise real Riverpod providers without a widget tree — no mocks, no brittle UI tests. Game logic is tested against its actual implementation.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3 / Dart 3 |
| State management | flutter_riverpod 2 + riverpod_generator |
| Local persistence | Isar 3 (embedded NoSQL, offline-first) |
| Audio | audioplayers |
| Particle effects | flutter_fireworks |
| Linting | flutter_lints + riverpod_lint + custom_lint |
| Code generation | build_runner + isar_generator |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (Isar schemas + Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Run on simulator / device
flutter run

# Run all tests
flutter test
```

> Requires Flutter 3.x and Dart 3.x. iOS simulator or physical device recommended.

---

## Roadmap

- [ ] Onboarding tutorial
- [ ] Daily login rewards + push notifications
- [ ] Offline energy catch-up on resume
- [ ] Narrative hooks per zone
- [ ] Monetization — gem store, chest / bubble system
- [ ] Inventory / item storage chest
