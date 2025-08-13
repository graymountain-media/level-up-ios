import Foundation
import SwiftUI

enum MissionStatus: String, Codable {
    case available, inProgress, completed, claimed
}


struct SuccessChances: Codable, Equatable {
    var base: Int?
    var brute: Int?
    var ranger: Int?
    var sentinel: Int?
    var hunter: Int?
    var juggernaut: Int?
    var strider: Int?
    var champion: Int?
    var display: Int?
    
    enum CodingKeys: String, CodingKey {
        case base = "Base"
        case brute = "Brute"
        case ranger = "Ranger"
        case sentinel = "Sentinel"
        case hunter = "Hunter"
        case juggernaut = "Juggernaut"
        case strider = "Strider"
        case champion = "Champion"
        case display = "Display"
    }
}

struct Mission: Identifiable, Codable, Equatable {
    static let testData: [Mission] = [
        Mission(
            id: UUID(uuidString: "06d4cc89-7379-4f7e-988a-42721dd8234d")!,
            title: "Tracking an Infestation",
            description: "It's time for another training simulation. This time recruits are being trained on how to track down suspected infestations before they turn into a full blown invasion of a city. That's how the enemy marks its targets—it sends scouts down from the stars, and those scouts race and skitter across the land in search of a proper landing site. But it takes time to send signals back to the swarm, and the scouts are fragile, which means that if someone is quick, they can eradicate an infestation before it signals the rest of the swarm to come.\n\nThe simulation stirs to life. A low hum fills your chest as the air around you flickers, the scent of ozone curling into the back of your throat. A crack of light, a rush of static, and then: the jungle.\nIt's dense and wet, the air thick with the smell of loam and crushed leaves. You can't see it, but you and the recruits training with you in today's simulation know that the infestation is out there, fast and quiet. They're slipping through the undergrowth in search of a landing site. Find them before it's too late.",
            levelRequirement: 7,
            successChances: SuccessChances(base: 100, brute: nil, ranger: 100, sentinel: nil, hunter: 90, juggernaut: 90, strider: 90, champion: 90, display: 80),
            duration: 4,
            successMessage: "Your boots sink into wet soil as you pound through the forest, hunting. The coming evening thickens the shadows under the canopy as solitary shafts of sunlight catch at patches of disturbed earth, slashed bark, and glistening threads left behind by the scouts. You've left your fellow recruits in the dust, and you wonder if that was a terribly stupid decision. You're almost on the infestation.\n\nYou crest a ridge, and there, you see them. Limbs that don't match, jointed wrong, skittering. Teeth where no mouth should be, light flickering across translucent surfaces, tendrils pulling at the earth. You pull out your weapon and launch yourself forward. You make short work on them, and soon they are little more than torn pieces at your feet.\n\nOverhead, you feel something. A gaze, ancient and colossal coming from the swarm, pressing into the atmosphere of the simulation. You remind yourself it's not real.",
            failMessage: nil,
            reward: 38
        ),
        Mission(
            id: UUID(uuidString: "608db5ba-0636-4e9c-835d-c89dd4d3c88c")!,
            title: "Flux vs Pulsefire",
            description: "You did well in your first simulation, better than most, but as you walk the Nexus halls, you can't help but feel the weight of how little you know. The others talk about flux technology, the history of the Invasion, the complex web of tech that surrounds everyone, and about the history of nearby Westhaven. But you're not a local. You still feel like an outsider, enough to pretend like you know what your peers are talking about so they think you belong. Sometimes you feel like you can't understand things that comes easily to everyone else.\n\nYour next lesson is on basic pulsefire application in technology. You ask the instructor, tentatively, about the soldiers you've seen in passing, the ones who can wield pulsefire with their bare hands, but that knowledge is still above your clearance. You settle with just learning the basics, and how pulsefire might pave the way for the future of mankind.",
            levelRequirement: 7,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "You leave the session with your head full of knowledge and questions. For centuries, mankind powered its civilization using high-energy mineral formations mined from the asteroid belt, called flux, which replaced the nuclear power that once defined an age. Flux is the backbone of modern technology — engines, weapons, shields, cities — all of it.\n\nBut now comes the discovery of pulsefire, and it's said pulsefire could be as revolutionary as flux once was. Your instructor, however, believes that flux has yet to reach its full potential, and that humanity is rushing to embrace a new technology they don't yet understand. Pulsefire has the ability to level the Nexus and Westhaven if handled improperly.\n\nStill, the facts remain: pulsefire is already powering the Nexus, lighting up its walls with purples and reds instead of the blues and greens of flux crystals. And in the hands of a few, pulsefire has become something else entirely. Something no one fully explains to recruits like you. Not yet.",
            failMessage: nil,
            reward: 38
        ),
        Mission(
            id: UUID(uuidString: "7ea62040-bf98-4a52-a18d-b7c27f854352")!,
            title: "Pulsefire",
            description: "Sleep didn't come easy last night. Every time you closed your eyes, you saw the shapes you glimpsed through the telescope at the observation post. Doubt creeps in at the edges. Are you cut out for this?\n\nAt the Nexus, doubt doesn't excuse you from duty. Today, you'll report to class, where recruits are introduced to pulsefire—the volatile energy source that powers the Nexus. It's what fuels the weapons you'll carry and the shields you'll trust. It's mankind's hope at stopping the Invasion.\n\nWhether you believe in yourself or not, the Nexus believes in your potential, so show up and start learning.",
            levelRequirement: 4,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 95),
            duration: 2,
            successMessage: "You show up, bleary-eyed but present. The instructor activates a pulsefire generator in the center of the room for everyone to see. It's the next generation of technology, she says, but as you watch the pulsefire energy coil and flicker, it feels like something older. Like magic. Pulsefire powers the Nexus' weapons, its armor, its walls—but for a select few, it's something they can channel. That is part of the reason every recruit is here. To learn how to wield pulsefire against the Invasion, or die trying.",
            failMessage: nil,
            reward: 18
        ),
        Mission(
            id: UUID(uuidString: "9c3d8393-8829-4800-af85-cb1d3718a528")!,
            title: "Trial by Fire",
            description: "Now that you've chosen your faction, it's time to prove you belong by sparring with a faction officer.\n\nAt first, you think the goal is to beat them, but as soon as you step into the ring, you realize that they're faster, sharper, and stronger. Victory isn't an option for you.\n\nShow them you have the grit, reflexes, and discipline to hold your ground under pressure. Show how you can stay on your feet, think on the fly, and endure.",
            levelRequirement: 3,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "You didn't win, but no one expected you to. You've earned your place for now. You realize how much you have to learn, and a fire burns inside you at the thought of finding a place here. Not only do you want to help the Nexus fight the Invasion, but you want to belong.\n\nYour sparring partner nods in approval as you limp out of the room.",
            failMessage: nil,
            reward: 14
        ),
        Mission(
            id: UUID(uuidString: "a1afb08d-9b50-41b7-bbe0-10f6a4e71308")!,
            title: "Welcome to the Nexus",
            description: "The Nexus isn't just a facility. It's humanity's answer to the Invasion, which has left us outmatched. Built beneath layers of concrete, steel, and secrecy, the Nexus exists to forge soldiers who can fight the existential threat outside its walls.\n\nYou're not here because you're the best, you're here because you someday might be. The survival rate here is low, and instructors can't promise safety. You'll either break or break through.\n\nYou stand at the gates, watching your fellow recruits. It's time for you to report for induction, get your ID, and remember the one truth that exists here: you're not special until you prove it.",
            levelRequirement: 2,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "You've taken your first steps into the Nexus. The air hums with tension—recruits murmur, steel doors slam shut, and somewhere beyond these walls, instructors are watching. Welcome to your first day.",
            failMessage: nil,
            reward: 10
        ),
        Mission(
            id: UUID(uuidString: "a572a880-be31-473e-8a80-1ef3f0451f11")!,
            title: "Behind the Walls",
            description: "The Nexus is bigger than you imagined. What little you see is just the beginning: chambers are locked behind levels of clearance, soldiers train on the other side of windows, and whispers fill the empty corridors.\n\nFollow the designated tour route and learn the terrain you'll be surviving in. Stay sharp. Watch everything. Take note of what's shown to you, or what isn't.",
            levelRequirement: 2,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "Your official tour takes you through mess halls, med bays, armories, simulation decks, and barracks. The operatives moving through off-limits doors with unfamiliar equipment make you uneasy. This place trains humanity's most elite soldiers, but it seems to hold something else, too.",
            failMessage: nil,
            reward: 10
        ),
        Mission(
            id: UUID(uuidString: "ab7056d9-fb17-4ff8-9197-001bbf284cc0")!,
            title: "A Lesson in Diplomacy",
            description: "You've been assigned to a protection detail accompanying one of your teachers into Westhaven, to negotiate trade terms with the company that supplies flux to the Nexus. Officially, you're there for security, but unofficially, your teacher says its a chance to test your combat skills in hostile territory.\n\nYou now understand why recruits don't travel into Westhaven more often. The city is ruled by private enterprise and their security forces. Agreements between these rival corporations hold during invasions, but outside that, safety is unpredictable when traveling the streets.",
            levelRequirement: 9,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "You navigate Westhaven's streets, driving your teacher and the rest of the group, and you approach a checkpoint manned by a private security force, twenty strong. For a moment, you brace for combat as you meet their threatening gazes, but they let you pass without incident.\n\nYou enter the flux supplier's headquarters and meet the new head of security. He singles you out. Your teacher warned you that people might want to prove themselves against a member of the Nexus, and this man is no exception. He steps up to you, threatening, your pulse spiking. His hand rests on the pistol at his side. You can't help but wonder, are you ready to take a life?\n\nYour new friend, the one you bonded with in the mess hall, steps between you two, calmly matching the security chief's aggression. The head of security hesitates, then backs down, reluctantly signaling for everyone to follow.\n\nAs you're escorted to the elevator leading to the top floor, you notice your friend's hand trembling.",
            failMessage: nil,
            reward: 54
        ),
        Mission(
            id: UUID(uuidString: "acffb398-9491-4454-b55f-efa921eca3d3")!,
            title: "Records of the Fallen",
            description: "You've started to notice the first empty bunks and unclaimed gear in the barracks. Recruits who were beside you when you first arrived at the Nexus have vanished, leaving everything behind. Rumors travel fast but answers are scarce. Dropping out isn't an option in the Nexus, as help against the Invasion is desperately needed, so then what happened to them? Did they desert into Westhaven, or is the explanation darker? While your instructors are helpful, they dodge your questions when you ask about the missing recruits.\n\nToday you will learn more about the cities ravaged by the Invasion. Study maps, mission reports, and firsthand accounts to understand the threat that you face.",
            levelRequirement: 5,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 3,
            successMessage: "When you learn leaves a hollow feeling in your chest. Cities that were once vibrant hubs of humanity have become ghost towns or smoldering craters, destroyed by the Invasion. The enemy, which swarms deep in space, appears to choose cities at random, and the inhabitants of those cities stand no chance once the onslaught starts. Humanity has yet to successfully defend a city once the Invasion picks its target.",
            failMessage: nil,
            reward: 24
        ),
        Mission(
            id: UUID(uuidString: "ae792154-e1c4-49d3-8267-3b0c5b8f74ec")!,
            title: "First Descent",
            description: "It's time for your first training simulation. A group of Nexus recruits stand around you in the simulation chamber, suited up and ready. Their faces are steady and their eyes focused straight ahead like they've done this a hundred times before. Apparently you're the only one who doesn't feel confident.\n\nThe simulation will drop you from a high-altitude airship into a city that was once a casualty of the Invasion. It's so you can learn to withstand the high g's of flight and the disorientation of combat insertion. Already, the screens around you have flickered on, placing you in the bowels of an airship with its rear hatch yawning open into a night sky. The ship leaves twin streaks of blue from its flux engines into the blackness. You can feel the cold metal floor under your boots and hear the shriek of wind clawing at the fuselage.\n\nYou know it isn't real, but your brain has trouble believing.",
            levelRequirement: 6,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: 100, hunter: nil, juggernaut: 90, strider: 90, champion: 90, display: 80),
            duration: 4,
            successMessage: "You jump into the night. Your earpiece blares with directions from the instructor, but the screaming wind is overwhelming. It's like you've jumped into a hurricane. You can't tell up from down. Your stomach lurches from the sensation of freefall, and you swear this is real.\n\nInstinct kicks in. The propulsion system in your grav boots kicks on, glowing white, slowing your descent. You're like a meteor. You land hard, pain shooting up your spine, and simulated concrete cracks beneath you. Your heart hammers in your chest.\n\nThe simulation dissolves, and once again you're in a room full of shivering and battered recruits. Realization dawns on you and triumph burns in your chest. You're the only one who survived the drop.",
            failMessage: nil,
            reward: 30
        ),
        Mission(
            id: UUID(uuidString: "ba59ca1c-2be9-45da-bbb6-75e77920f609")!,
            title: "Pulsefire Defense",
            description: "You can now measure your time at the Nexus in weeks instead of days, and the long hours you've put in makes your life before joining feel like a lifetime ago. While you're still trying to make friends, those around you don't feel like strangers anymore. They almost feel like your people. You realize that other recruits are ignoring you not because they don't like you, but because they don't want to fail. They're trying to focus.\n\nFor the next simulation, your instructors will be dropping you into another city that is in the middle of an invasion. They tell you that the massive pulsefire turrets that warded off the start of the swarm have fallen. They don't say it, but you know this is another lesson where survival isn't possible.\n\nYou're determined to find some way to show your instructors that survival is an option.",
            levelRequirement: 9,
            successChances: SuccessChances(base: 70, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 70),
            duration: 4,
            successMessage: "You drop into the simulation, disoriented by blaring alarms. Buildings burn, streets are barricaded, and the roads are blocked by swarming, tentacled enemies. The thirty-foot pulsefire turrets in the center plaza of the city lay dormant.\n\nYou stand in the center of an intersection. It's clear your instructors want you standing here learning how to fight in an exposed position. Ammo is limited. Panic sets in among your squadmates. Even though it's a simulation, dying is painful.\n\nYou command your team to follow. You run for the pulsefire turrets as they cove you. The swarm intensifies, but you find what you're looking for–the pulsefire core that powers one of the turrets. Its energy swirls and flares, unstable.\n\nThe turret can't be reactivated, and your teammates ask what you're doing, but you just ask for cover fire. You light your signal flare and toss it into the electromagnetic fire, and the explosion sends everyone to the ground, the light blinding you. Sound roars in your ears and searing heat washes over your skin.\n\nWhen its over, you help your team to their feet. The turret offered covered from the blast, but several blocks in every direction have been vaporized. The swarm is still out there, but it will take time for it to recover. Before you can prepare for the next wave, however, the simulation darkens and your instructor is standing there, smiling.",
            failMessage: "You drop into the simulation, disoriented by blaring alarms. Buildings burn, streets are barricaded, and the roads are blocked by swarming, tentacled enemies. The thirty-foot pulsefire turrets in the center plaza of the city lay dormant.\n\nYou try to think of a plan as you look past the burned-out skyline, but as the swarm closes in, panic takes hold. You set your sights on the nearest enemy and open fire. Your fireteam follows suit.\n\nOne by one, your teammates fall. You're the last one standing, as usual, but there is no satisfaction in this. Something hits you as pain lashes your body, and the simulation fades to black. When you're standing before your instructors once more, they say nothing.\n\nThis was how it was supposed to go, but it still feels like failure.",
            reward: 54
        ),
        Mission(
            id: UUID(uuidString: "c464a3f2-9121-4212-8631-6eded0dafd28")!,
            title: "Path of Purpose",
            description: "You've taken your first steps down your chosen path. Today, you'll dive deeper into what will be at your disposal, as well as what's available to other paths. You'll study the weapons, tactics, and mission types that will define your future. Listen carefully and learn quickly. Your choices going forward will shape your strengths and determine your place inside the Nexus.\n\nMore importantly, it will determine how you'll help to stop the Invasion.",
            levelRequirement: 4,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 95),
            duration: 5,
            successMessage: "You start to grasp the range of specializations within the Nexus. Some members become masters of range, striking enemies from afar. Others wield silent weapons to dismantle threats without being seen. Still others prefer breaking enemy lines with force and fury. Your unique strengths will make you invaluable to the Nexus.\n\nYou'll need to shore up your weaknesses, however. Meet others at the Nexus, whether they share your path or follow a different one. Those of other paths are strong where you are weak and may very well save your life someday.",
            failMessage: nil,
            reward: 18
        ),
        Mission(
            id: UUID(uuidString: "cc546c2c-3083-4828-9f3e-139cf7b01a02")!,
            title: "Promise of Teamwork",
            description: "You've felt lost in the Nexus, unable to relate to the recruits who grew up with stories of Westhaven and seem to slip from group to group like they were always meant to be here. But you've noticed you're not the only one who seems like an outsider. There's someone else you see at meals, in the barracks, and on the simulation floor. They're always quiet. They've failed the last two simulations, barely walking off the platform as they trembled from the weight of hard training, and you remember the instructors' words that no one survives here alone.\nYou could continue to stay in your own head, or you could extend a hand to this other recruit and make a friend.",
            levelRequirement: 8,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "You sit yourself across from them at the mess table and manage some small talk about the last simulation, making half-joking complaints about the instructors. The two of you eat, and by the time the trays are cleared, you've learned they're from a colony in the mountains; a mining station you've only ever seen on a map. They didn't come here for glory, but because they had nowhere else to go.\n\nBefore you both leave, you say it without ceremony. \"We watch each other's back, yeah? If it gets bad out there.\"\n\nThey nod. It's a small gesture, but as you walk away, it feels bigger.",
            failMessage: nil,
            reward: 46
        ),
        Mission(
            id: UUID(uuidString: "d45cbedc-9d6c-4c2a-99e3-25dfef38ed37")!,
            title: "Into the Enemy's Eyes",
            description: "Many can be trained to fight, but that isn't the only reason you were accepted to the Nexus. Few are prepared to face what's out there. Your next mission is to leave the grounds and head into the forest where an old observation post stands. There, some of the first sightings of the Invasion were logged. Reach the observation post, look through its battered telescope, and report what you see.",
            levelRequirement: 3,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "You step into the woods beyond the Nexus' hidden walls. Above the treeline sits the silhouette of Westhaven, the neighboring city, which has remained untouched by the Invasion. A mile away sits the observation post, its telescope pointing to the sky, its metal rusted and glass coated in dust. You wipe the lens and peer through.\n\nYou observe stars and colorful nebulae, and among the blackness of space, you see it–too many legs, too many eyes. The eyes look back at you. A hundred thousand enemies are swarming out there in the void. You turn away in disgust and head home.",
            failMessage: nil,
            reward: 14
        ),
        Mission(
            id: UUID(uuidString: "d9e083c6-6e9b-473d-bacd-7186c855eed9")!,
            title: "Resupply Rendezvous",
            description: "For the first time, you're being sent into Westhaven. The Nexus needs a resupply, and its new recruits are the ones assigned to carry out this task. Your assignment is to navigate the twisting sprawl of Westhaven's manufacturing district, reach an unmarked warehouse, and prepare a shipment of goods for transport back to the Nexus. You're not from around here—you've never been in Westhaven before and don't know what to expect.",
            levelRequirement: 6,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 100),
            duration: 4,
            successMessage: "You find the warehouse. There, the cargo doors creak open and figures emerge, hefting heavy, unlabeled crates. You feel the weight of their stares as they load your truck. Some look at you with hope; others like you're a threat they don't understand. They fear those who train in the Nexus, but they don't know you're just a recruit. They don't know how hard you're fighting to believe you belong there.",
            failMessage: nil,
            reward: 30
        ),
        Mission(
            id: UUID(uuidString: "dc77b3c8-2731-4992-b70c-8d3fb1e7cef9")!,
            title: "A Measure of Strength",
            description: "For today's simulation, you've been assigned as point on a defense mission: an invasion of a city has already begun, and your job is to hold out for as long as possible. You'll be sent into the thick of it, so be ready.\n\nYou tighten your gloves, check your gear, and the instructors give the signal before the simulation flares to life. A moment later, you're standing on the edge of a burning, nameless city at the head of your squad. You wonder if this is a hypothetical battlefield or a representation of a real city that was once burned. You think of all the mass casualties humanity has suffered since the Invasion appeared from the stars five years ago. Much of Earth has been left untouched, thankfully–the enemy attacks with surgical precision instead of spreading its destruction across the globe. It's not uncommon for small towns, untouched, to watch a neighboring city burn on the horizon.\n\nSomewhere in the wreckage nearby, shadows slip through the smoke. You launch forward before you can second guess yourself, hellbent on protecting your squadron.",
            levelRequirement: 8,
            successChances: SuccessChances(base: 100, brute: 100, ranger: nil, sentinel: nil, hunter: 90, juggernaut: 90, strider: nil, champion: 90, display: 80),
            duration: 4,
            successMessage: "You move through the ruins, the air thick with ash, and strike hard. They come fast, flickering at the edge of your sight, limbs bending wrong, moving like no human ever could. You don't think. You drive forward with your team, and soon fists and blades and bullets are biting through sinew and flesh. Your heart pounds like a war drum. You can sense the fear pulsing through your team, but all you feel is alive.\n\nWave after wave of chitin and death surge through the ruins, coming for you, and one by one your team falls. A moment ago you felt invincible, but now you feel the tide turn against you. Soon you're the last one standing, and then a dagger-like limb slashes at you, ending your simulated life. The screens darken, and you're surrounded by your team once more. Everyone struggles to catch their breath, surprised and dismayed..\n\nYou understand the lesson's purpose before anyone else. You weren't trying to survive, but to see how many of the enemy down before you fell. There is no victory once an invasion starts.",
            failMessage: nil,
            reward: 46
        ),
        Mission(
            id: UUID(uuidString: "fb11bf29-7aa4-42d0-9c79-0d1eb799145a")!,
            title: "Bonds Before Battle",
            description: "Word is spreading through the halls: Nexus recruits will soon be sent on training missions beyond the protection of the Nexus. You won't be going alone, though. You'll need friends, and who you bring with you will be up to you. It's time to step outside your comfort zone and make friends at the Nexus—strike up conversations in the mess hall, join sparring sessions, or help out in the armory. Figure out who you'd trust to have your back when the fighting begins.",
            levelRequirement: 5,
            successChances: SuccessChances(base: 100, brute: nil, ranger: nil, sentinel: nil, hunter: nil, juggernaut: nil, strider: nil, champion: nil, display: 90),
            duration: 8,
            successMessage: "By the end of the day, you've made some progress. A nod here, a shared laugh there. These moments matter, as small as they are. You're beginning to understand something about the Nexus, that those who fail or die are those who didn't have friends beside them when it counted.",
            failMessage: nil,
            reward: 24
        )
    ]

    var id: UUID
    let title: String
    let description: String
    let levelRequirement: Int
    let successChances: SuccessChances // Path name to chance, null means not available
    let duration: Int // hours
    let successMessage: String
    let failMessage: String?
    let reward: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case levelRequirement = "level_requirement"
        case successChances = "success_chances"
        case duration
        case successMessage = "success_message"
        case failMessage = "fail_message"
        case reward
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        levelRequirement: Int,
        successChances: SuccessChances,
        duration: Int,
        successMessage: String,
        failMessage: String? = nil,
        reward: Int
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.levelRequirement = levelRequirement
        self.successChances = successChances
        self.duration = duration
        self.successMessage = successMessage
        self.failMessage = failMessage
        self.reward = reward
    }
    
    /// Get the success rate for a specific hero path, falling back to base rate
    func successRate(for path: HeroPath?) -> Int {
        guard let path = path else {
            return successChances.base ?? 50
        }
        
        switch path {
        case .brute:
            return successChances.brute ?? successChances.base ?? 50
        case .ranger:
            return successChances.ranger ?? successChances.base ?? 50
        case .sentinel:
            return successChances.sentinel ?? successChances.base ?? 50
        case .hunter:
            return successChances.hunter ?? successChances.base ?? 50
        case .juggernaut:
            return successChances.juggernaut ?? successChances.base ?? 50
        case .strider:
            return successChances.strider ?? successChances.base ?? 50
        case .champion:
            return successChances.champion ?? successChances.base ?? 50
        }
    }
}
