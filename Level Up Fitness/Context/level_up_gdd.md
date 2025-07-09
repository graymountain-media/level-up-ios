# Level Up Fitness App  
## Game Design Document (GDD)

---

## App Overview

- **Title**: Level Up Fitness  
- **Genre**: Fitness Companion / Gamified RPG  
- **Platform**: iOS, Android (mobile only)  
- **Target Audience**: Ages 16–35.  
  - Fitness enthusiasts who game  
  - Fitness enthusiasts disengaged by traditional gyms  
  - Gamers who want to get fit  
  - Streamers/content creators  
- **Core Concept**: A real-world gym experience enhanced through RPG-style leveling, missions, and avatar customization driven by real workout behavior.

---

## Engagement Loop Between App & Gym

1. Enter the gym and work out  
2. Earn XP and receive a class designation ("Path")  
3. Level up your avatar  
4. Complete level-gated missions  
5. Earn in-app rewards from missions  
6. Return to the gym to claim rewards  
7. Purchase gear for your avatar through the shop  

**Rewards Cycle**  
- Missions completed passively during the day  
- Rewards (Flux & Credits) must be claimed within 7 days by returning to the gym

---

## Feature Funnel

### 3.1 XP & Leveling

- XP is earned from workouts:
  - 30 XP for first 30 minutes, 1 XP/minute after, max 60 XP/day  
  - Only one workout per day grants XP  
- Streak system for consistency:
  - “Pulse Meter” fills with 7 check-ins in a row → +10% XP bonus  
  - 2 rest days allowed; lose streak on 3rd day with no check-in  
  - Cooldown: 5 more workouts required to regain XP bonus  
- Max Level: 50  
  - Nonlinear XP curve  
  - Special titles/gear at level 50 and milestones  

---

### 3.2 Paths & Workout Zones

Your avatar reflects your real gym activity:

- **Zones**: Weight Lifting, Cardio, Themed Classes, Obstacle Course  
- **Paths**:
  - **Single-Zone Paths** (>75% in one zone):  
    - Brute (Weight Lifting)  
    - Scout (Cardio)  
    - Martialist (Themed Classes)  
    - Strider (Obstacle Course)  
  - **Hybrid Paths** (<75% in any one zone):  
    - Hunter (Weight + Cardio)  
    - Dragoon (Weight + Classes)  
    - Reaver (Weight + Obstacle)  

- Assigned at Level 5  
- Re-evaluated every 10 levels

---

### 3.3 Missions

- **Mission Board**: In-app and physical kiosk  
- **Mission Rules**:
  - Text-based, narrative-driven  
  - Up to 3 missions/day  
  - Level requirements  
  - Grouping improves success chance  
- **Completion**: Passive; app notifies when mission completes  
- **Claiming Rewards**: Must return to gym next day  

---

### 3.4 Mission Rewards

**Types**:

- **Flux**:
  - Currency used to craft avatar gear  
  - Higher missions = more flux  
  - Used in Arena betting (Phase 2)

- **Credits**:
  - Used to buy real items (e.g., snacks, drinks, apparel)

| Mission Level | Gold Reward | Days to Protein Drink ($5) | Days to Snack ($4) | Days to Apparel ($50) |
|---------------|-------------|-----------------------------|---------------------|------------------------|
| 1–4           | 2           | 100                         | 80                  | 1000                   |
| 5–6           | 3           | 67                          | 54                  | 667                    |
| 50            | 10          | 20                          | 16                  | 200                    |

[Full reward chart here](https://docs.google.com/spreadsheets/d/1f45BgWuqr7LOsmGRFQQPlMO8XRZ1OBwOjjHCzCjgYbE)

---

### 3.5 Avatar Customization

- **6 Gear Slots**: Helmet, Chestguard, Gloves, Pants, Boots, Weapon  
- **Acquired via shop and missions**  
- **Level requirements & bonuses**  
- **Unique gear aesthetics per path**

---

### 3.6 Leaderboards

- Top streaks shown in-app and throughout the gym  
- Can filter by path or view all members  

---

## 4. Narrative & Theme

- **Ethos**: Deep immersion in both app and gym  
- **Setting**: Cyberpunk city powered by "pulsefire" magic  
- **Aesthetic**: Neon + magic fusion  
- **Narrative**:  
  - Missions further the story  
  - Worldbuilding via gear flavor text and UI  

---

## 5. UI/UX Design

### Wireframes

- Character Panel  
- Inventory  
- Shop  
- Mission Board  
- Friends List  
- Profile  
- Login Screen  
- Splash Screen  

### Direction & Inspiration

- **Games**: Diablo 4, Cyberpunk 2077, Dark Lands  
- **Color Scheme**: Neon orange, green, purple, blue  
- **Design Tools**: Figma, Sketch, Adobe XD  

---

## 7. Monetization

- **In-app purchases**:
  - Avatar animations (check-in)  
  - Custom backgrounds  
  - Cosmetics (tattoos, piercings)  
- **No Gear Sales** (avoiding pay-to-win)

---

## 8. Technical Requirements

- Indoor positioning system (track zone time)  
- Backend:
  - Session tracking  
  - Daily XP + Path calculations  
  - Mission timers  
- Avatar and gear systems  
- Cloud-based save system  
- Scalable database  

---

## 9. Skills Needed for Development

### Core Mobile Development

- React Native / Flutter  
- Swift, Kotlin, Java  
- iOS/Android SDK  
- Firebase, REST/GraphQL  

### Game-Like Systems

- Unity  
- XP & mission systems  
- RPG gamification  
- Leaderboards  

### UI/UX Design

- Game-inspired mobile design  
- Cyberpunk themes  
- Dark mode  

### Cloud & Backend

- Firebase (auth, DB, analytics)  
- AWS Amplify / Supabase  
- Notifications  

### Fitness Background (Bonus)

- Apple HealthKit, Google Fit  
- Gym check-in system  
- IPS (Indoor Positioning Systems)

### Monetization & Analytics

- In-App Purchases  
- AdMob, AppLovin  
- Mixpanel, Amplitude, Firebase Analytics  

---

## 10. Social Mechanics

> *Suggested to remove from final GDD, but included for completeness.*

- Avatars flash on-screen during gym check-in  
- Leaderboards in prominent gym locations  
- Studio: record gym content  
- Friends list: group up for missions  
- Apparel gated by level  
- New member grouping bonuses  
- Phase 2: Factions and Arena events