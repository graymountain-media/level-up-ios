# Level Up Fitness - System Overview

## Table of Contents
- [App Overview](#app-overview)
- [Authentication System](#authentication-system)
- [User Profile & Data](#user-profile--data)
- [Level & XP System](#level--xp-system)
- [Hero Path System](#hero-path-system)
- [Faction System](#faction-system)
- [Mission System](#mission-system)
- [Item Shop & Equipment System](#item-shop--equipment-system)
- [Workout System](#workout-system)
- [Leaderboards](#leaderboards)
- [Architecture & Patterns](#architecture--patterns)
- [Database Schema](#database-schema)

## App Overview

Level Up Fitness is a gamified fitness app that transforms workouts into RPG-style progression. Users level up, choose factions, unlock hero paths, complete missions, and purchase equipment to enhance their fitness journey.

**Core Concept**: 1 XP per minute of workout (capped at 60 minutes per session), with equipment bonuses and RPG-style progression mechanics.

## Authentication System

### Supabase Integration
- **Provider**: Supabase Auth
- **Flow**: Email/password signup → Email verification → Profile creation
- **Components**: 
  - `AuthView.swift` - Login/signup UI
  - `OnboardingView.swift` - Profile setup after signup
  - `UserDataService.swift` - Auth state management

### Authentication States
```swift
enum AuthState {
    case loading
    case authenticated(hasCompletedOnboarding: Bool)
    case unauthenticated
    case error(Error)
}
```

### Session Management
- Persistent session handling with timeout protection
- Auth state observation with real-time updates
- Automatic session refresh

## User Profile & Data

### Profile Model
```swift
class Profile: Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var avatarName: String
    var avatarUrl: String?
    var credits: Int
    var faction: Faction?
    var path: HeroPath?
}
```

### Data Management
- **AppState.swift**: Centralized data store using `@Observable`
- **UserAccountData**: Aggregate model combining profile, XP, level, and streak data
- **Real-time Updates**: Automatic refresh after workouts and purchases

## Level & XP System

### Level Calculation
- **XP Source**: 1 XP per minute of workout (max 60 per session)
- **Equipment Bonus**: Percentage multiplier from equipped items
- **Formula**: `baseXP * (1 + equipmentBonus/100)`
- **Database**: `level_info` table with cumulative XP thresholds

### Level Manager
- **LevelManager.swift**: Handles level calculations and unlocks
- **Level Up Detection**: Compares current XP against level thresholds
- **Content Unlocking**: Missions (level 2), Factions (level 3), Paths (level 4)
- **Notifications**: Level up popups with unlock announcements

### Unlockable Content
```swift
enum UnlockableContent {
    case missions           // Level 2
    case factions          // Level 3
    case factionLeaderboards // Level 3
    case paths             // Level 4
}
```

## Hero Path System

### Path Types
Seven RPG-style classes based on workout preferences:

```swift
enum HeroPath: String, CaseIterable {
    case brute      // Strength-focused (80%+ strength workouts)
    case ranger     // Cardio-focused (80%+ cardio workouts)
    case sentinel   // Functional-focused (80%+ functional workouts)
    case hunter     // Strength + Cardio hybrid
    case juggernaut // Strength + Functional hybrid  
    case strider    // Cardio + Functional hybrid
    case champion   // Balanced (33% each type)
}
```

### Path Assignment Logic
- **Trigger**: Level 4, then recalculated every 5 levels (9, 14, 19...)
- **Data Source**: Database function `get_user_workout_type_stats`
- **Calculation**: 
  - Champion: 33-34% distribution across all three workout types
  - Solo paths: ≥80% of one workout type
  - Hybrid paths: Dominant combinations
  - Tie-breaking: Random selection for balanced scenarios

### Path Calculator Service
- **PathCalculator.swift**: Determines path from workout statistics
- **WorkoutTypeStats.swift**: Model for workout type percentages
- **Database Integration**: Real-time calculation from user's workout history

## Faction System

### Faction Types
```swift
enum Faction: String, CaseIterable {
    case echoCorps = "echo_corps"
    case nexusGuard = "nexus_guard"  
    case vanguardSyndicate = "vanguard_syndicate"
}
```

### Faction Features
- **Unlock**: Level 3
- **Selection**: One-time choice with faction-specific benefits
- **Leaderboards**: Faction-based XP competition
- **Visual Identity**: Faction icons and colors throughout UI

### Faction Leaderboard System
- **Database Function**: `get_faction_leaderboard`
- **Metrics**: Total XP, member count, average XP, top player
- **UI**: Competitive ranking display in leaderboards

## Mission System

### Mission Structure
```swift
struct Mission {
    let title: String
    let description: String
    let levelRequirement: Int
    let successChances: SuccessChances // Path-specific success rates
    let duration: Int // hours
    let successMessage: String
    let failMessage: String?
    let reward: Int // credits
}
```

### Success Rate System
- **Base Rate**: Default success percentage
- **Path Bonuses**: Higher success rates for compatible hero paths
- **Display Logic**: Shows user's path-specific success rate
- **Completion Logic**: Uses path-specific rate for success/fail rolls

### Mission Flow
1. **Available**: Unlocked by level, shown in mission board
2. **Active**: Started by user, timer begins
3. **Ready**: Timer expired, can be completed
4. **Completed**: Success/fail roll, rewards distributed

### Mission Manager
- **MissionManager.swift**: Handles mission state, timers, and completion
- **Timer System**: Real-time countdown with automatic ready notifications
- **Mission Board**: Tabbed interface (Available, Active, Completed)

## Item Shop & Equipment System

### Item Structure
```swift
struct Item {
    let id: UUID
    let name: String
    let description: String
    let xpBonus: Double        // Percentage XP bonus
    let price: Int             // Credit cost
    let itemSlot: ItemSlot     // Equipment slot
    let requiredPaths: [HeroPath] // Path restrictions
    let requiredLevel: Int     // Level requirement
}
```

### Equipment Slots
```swift
enum ItemSlot: String {
    case weapon
    case helmet
    case chest
    case pants
    case boots
    case gloves
}
```

### Inventory System
- **Two-Table Approach**: 
  - `user_items`: Purchased items
  - `user_equipped_items`: Currently equipped items
- **UserInventory Model**: Combines owned and equipped items
- **Database Functions**: `purchase_item`, `equip_item` for atomic operations

### Shop Features
- **Smart Filtering**: Level requirements, path compatibility, ownership status
- **Auto-scrolling**: Positions view at first buyable item
- **Upgrade System**: Auto-equip on purchase with upgrade popup
- **Path Restrictions**: Items limited to specific hero paths

### Equipment Bonuses
- **XP Bonus**: Stacking percentage bonuses from all equipped items
- **Workout Integration**: Applied automatically during XP calculation
- **Avatar Display**: Equipped weapons shown on avatar view

## Workout System

### Workout Model
```swift
struct Workout {
    let id: String?
    let userId: String
    let duration: Int
    let workoutTypes: [String]
    let date: Date
    let xpEarned: Int
}
```

### Workout Types
```swift
enum WorkoutType: String, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case functional = "Functional"
}
```

### XP Calculation with Equipment
```swift
private func calculateXP(duration: Int) async -> Int {
    let baseXP = min(duration, 60) // 1 XP per minute, max 60
    let equipmentBonus = appState.userInventory?.totalXPBonus ?? 0.0
    let bonusMultiplier = 1.0 + (equipmentBonus / 100.0)
    let totalXP = Double(baseXP) * bonusMultiplier
    return Int(round(totalXP))
}
```

### Workout Features
- **LogWorkoutView.swift**: Workout entry interface
- **Duration Tracking**: Minutes input with XP preview
- **Type Selection**: Multiple workout types per session
- **Streak Calculation**: Daily workout streak tracking
- **XP Integration**: Automatic level-up detection

## Leaderboards

### Leaderboard Types
1. **XP Leaderboard**: Individual user XP rankings
2. **Streak Leaderboard**: Workout streak rankings  
3. **Faction Leaderboard**: Faction-based competition

### Leaderboard Models
```swift
protocol LeaderboardEntry: Identifiable, Decodable {
    var userId: UUID { get }
    var value: Int { get }
    var avatarName: String? { get }
    var rank: Int { get }
}
```

### Database Functions
- `get_xp_leaderboard`: Top users by XP
- `get_streak_leaderboard`: Top users by streak
- `get_faction_leaderboard`: Faction rankings

## Architecture & Patterns

### Dependency Injection
- **FactoryKit**: Dependency injection framework
- **Container+Registration.swift**: Service registration
- **Protocol-based**: All services implement protocols for testability

### State Management
- **AppState**: `@Observable` centralized state store
- **Reactive UI**: SwiftUI automatically updates on state changes
- **Data Flow**: Unidirectional data flow from services to AppState to UI

### Service Layer
```
UserDataService    -> User profiles, auth
WorkoutService     -> Workout logging, XP calculation  
MissionService     -> Mission data, completion
ItemService        -> Item shop, inventory
LeaderboardService -> Rankings and leaderboards
AvatarService      -> Avatar management
```

### Key Architectural Patterns
- **MVVM**: ViewModels manage UI state and business logic
- **Repository Pattern**: Services abstract database operations
- **Observer Pattern**: Real-time UI updates via @Observable
- **Factory Pattern**: Dependency injection for services

## Database Schema

### Core Tables
- **profiles**: User profile data including faction and hero path
- **workouts**: Individual workout sessions with XP earned
- **level_info**: Level progression thresholds
- **streaks**: User workout streak tracking
- **items**: Available items in shop
- **user_items**: User-owned items
- **user_equipped_items**: Currently equipped items

### Key Database Functions
- `get_user_workout_type_stats`: Calculate workout type percentages
- `purchase_item`: Atomic item purchase with credit deduction
- `equip_item`: Handle item equipping with slot management
- `get_xp_leaderboard`: User XP rankings
- `get_streak_leaderboard`: User streak rankings  
- `get_faction_leaderboard`: Faction competition data

### Views
- `xp_levels`: Real-time user XP and level calculation

---

*This overview reflects the current state of Level Up Fitness as of the conversation. The app combines fitness tracking with RPG mechanics to create an engaging, gamified workout experience.*