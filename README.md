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

### Atomic Mutations — No Partial State

Every game action that can fail follows a strict two-phase contract: **validate first, commit second**. Energy availability, item counts, and free spawn tiles are all confirmed before a single value changes. If anything is missing, the operation aborts cleanly — energy is never deducted on a full grid, items are never consumed for an order that can't be filled, and a zone unlock writes both the coin deduction and the unlock ID in a single `copyWith()`. Partial state is structurally impossible.

Persistence follows the same rule — all three Isar collections are written inside one `writeTxn`. A failure at any point rolls back the entire transaction.

### Defensive Load, Safe Defaults

The game never trusts what's on disk. Every field of a persisted `PlayerStats` is range-checked before it touches provider state — negative coins, impossible energy, out-of-range levels, corrupt generator records. Each violation logs a warning and falls back to a safe default rather than propagating bad state into the session. Players never see a crash from a corrupt save; they get a clean start.

### Debug Assertions, Zero Production Overhead

`_assertValidGrid()` and `_assertValidState()` run on every state mutation in debug builds, catching grid dimension mismatches, broken tile coordinates, and invalid generator config at the earliest possible moment. Dart `assert()` is a compile-time no-op in release — no cost, no risk, no feature flags needed. The debug panel follows the same principle: scoped to `kDebugMode`, stripped entirely in production builds.

### Unidirectional State — No Widget Owns Data

No widget reads or writes game state directly. Every interaction goes through a `StateNotifier` provider, and derived reads use `.select()` to rebuild only on the specific fields a widget depends on. The boundary is strict: widgets render, providers mutate. This makes the entire game loop independently testable without a widget tree and prevents the class of bugs where UI and data fall out of sync.

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
