---@meta

---@alias FireTargetCategory string

---@alias WeaponCategory
---| "Anti Air"
---| "Anti Navy"
---| "Artillery"
---| "Bomb"
---| "Death"
---| "Defense"
---| "Direct Fire"
---| "Experimental"
---| "Indirect Fire"
---| "Kamikaze"
---| "Missile"
---| "Teleport"


-- read more here: https://wiki.faforever.com/en/Blueprints

---@class WeaponBlueprint: Blueprint
--- if this weapon will only fire if it is above water
---@field AboveWaterFireOnly? boolean
--- if this weapon will only fire at targets above water
---@field AboveWaterTargetsOnly? boolean
--- If a turret, sets the aim control precedence of the manipulators. See
--- `moho.manipulator_methods:SetPrecedence(precedence)`. Treated as `10` when absent.
---@field AimControlPrecedence? number
--- this weapon will aim straight ahead when disabled
---@field AimsStraightOnDisable boolean
--- always recheck for better target regardless of whether you already have one or not
---@field AlwaysRecheckTarget boolean
--- used by the Omen's script
---@field AnimationOpen? FileName
--- animation played by the weapon's Rack Salvo Reload Sequence
---@field AnimationReload? FileName
--- if an anti-artillery shield will block this projectile
---@field ArtilleryShieldBlocks? boolean
--- information about the audio files used by the weapon
---@field Audio WeaponBlueprintAudio
--- How many times the engine calls OnFire for the weapon when attacking ground before moving on to the next ground attack order. Defaults to 3
---@field AttackGroundTries? number
--- if the unit has no issued commands and has a weapon that has `AutoInitiateAttackCommand` set,
--- then if it finds a suitable target it will issue an attack command to go after the target
---@field AutoInitiateAttackCommand? boolean
--- Ballistic arcs that should be used on the projectile
---@field BallisticArc? WeaponBallisticArc
--- Interval in seconds between beam collision checks (which take 1 tick) - using `0` will cause beams to damage every tick
---@field BeamCollisionDelay number
--- the amount of time the beam exists
---@field BeamLifetime number
--- if the weapon will only fire when underwater
---@field BelowWaterFireOnly? boolean
--- Distance from bomb firing solution's position to the target's position within which the weapon will fire 
---@field BombDropThreshold? number
--- information about the bonuses added to the weapon when it reaches a specific veterancy level
---@field Buffs BlueprintBuff[]
--- used by the Lobo script to pass the lifetime of the vision marker created upon landing
---@field CameraLifetime? number
--- time to maintain the camera shake
---@field CameraShakeDuration? number
--- maximum size of the camera shake
---@field CameraShakeMax? number
--- minimum size of the camera shake
---@field CameraShakeMin? number
--- used by the Lobo script to pass the radius of the vision marker created upon landing
---@field CameraVisionRadius? number
--- how far from the unit should the camera shake
---@field CameraShakeRadius number
--- if the weapon cannot attack ground positions
---@field CannotAttackGround? boolean
--- should the unit collide against friendly meshes
---@field CollideFriendly boolean
--- beams fire without stopping - overrides `RateOfFire`
---@field ContinuousBeam boolean
--- this projectile needs to be built and stored before the weapon can fire
---@field CountedProjectile? boolean
--- damage value of the projectile fired from the weapon
---@field Damage number
--- if friendly units collide with and are damaged by this weapon's projectile
---@field DamageFriendly boolean
--- blast radius
---@field DamageRadius number
--- how much additional damage is dealt to shields using the "FAF_AntiShield" damagetype
---@field DamageToShields? number
--- the type of damage the unit will do
---@field DamageType DamageType
--- used by some projectile scripts to pass depth charge information
---@field DepthCharge? WeaponBlueprintDepthCharge
--- If true, will set the projectile launched from this weapon to detonate once it pass the height
--- of the target it was launched at.
--- See `moho.projectile_methods:ChangeDetonateAboveHeight(height)`
---@field DetonatesAtTargetHeight? boolean
--- Disables the weapon while it is reloading
---@field DisableWhileReloading boolean
--- Name of the weapon. Used for lobby restrictions and for debugging:
--- `dbg weapons` in the console shows the weapon names.
---@field DisplayName string
--- number of times the Damage over Time damage will be dealt
---@field DoTPulses number
--- duration that the Damage over Time will last in seconds
---@field DoTTime number
--- If `FixBombTrajectory` is set, then bombs dropped with this weapon will be aimed at the position
--- this fraction of the distance between the target and where it dropped. This may only be useful
--- for torpedo bombers.
---@field DropBombShort? number
--- This instructs the engine not to create a C++ weapon object that is usually linked with the
--- script object. This is for purely script driven weapons (like death weapons).
---@field DummyWeapon boolean
--- the effective range that this weapon really has
---@field EffectiveRadius number
--- if defined, will make this weapon not contribute to the automatically generated threat levels
---@field EnabledByEnhancement? Enhancement
--- if `false`, the first shot out of this weapon will not create an economy drain event
---@field EnergyChargeForFirstShot? false
--- how much power this weapon consumes when fired, until it meets its goal of `EnergyRequired`
---@field EnergyDrainPerSecond? number
--- how much energy is required to fire this weapon, drained according to `EnergyDrainPerSecond`
---@field EnergyRequired? number
--- If the weapon has the label `"DeathWeapon"`, then this flag determines if the death weapon is
--- fired as a weapon rather than being applied as a damage area using its stats as a dummy weapon
---@field FireOnDeath? boolean
--- allows you to pick which layers you can target in relation to the layer that you are currently at
---@field FireTargetLayerCapsTable? table<Layer, FireTargetCategory>
--- how much random inaccuracy should we be from the target
---@field FiringRandomness? number
--- the firing randomness that this weapon has while the unit is moving
---@field FiringRandomnessWhileMoving? number
--- How much misaligned can the barrel be before starting to fire. Used when you are trying to
--- target ammo that does not require lots of accuracy due to the size of their damage radius or
--- because the ammo does automatic targeting
---@field FiringTolerance? number
--- if the ballistic trajectory of the bomb is precisely calculated in Lua rather than being handled
--- by the engine
---@field FixBombTrajectory? boolean
--- if present, firing randomness will not scale with distance but have a fixed spread radius of
--- this value
---@field FixedSpreadRadius? number
--- flares that this weapons launches
---@field Flare WeaponBlueprintFlare
--- used to force packing up a weapon before being able to fire again
---@field ForceSingleFire? boolean
--- controls what the weapon is allowed to target in reference to the heading of the unit
---@field HeadingArcCenter number
--- controls what the weapon is allowed to target in reference to the arc center,
--- this is degrees on either side
---@field HeadingArcRange number
--- does not consider the weapon when attacking targets if it is disabled
---@field IgnoreIfDisabled? boolean
--- the intial damage done on impact for a Damage over Time weapon
--- (where `Damage` is applied every pulse)
---@field InitialDamage? number
--- the number of counted projectiles the unit starts with
--- (is clamped to the max projectile storage)
---@field InitialProjectileStorage? number
--- `Label` links the blueprints (<unitid>_unit.bp) weapon information with the script
--- (<unitid>_script.lua) weapon information. For example:
--- blueprint: `Weapon { Label = 'FrontTurret01', }`
--- script: `Weapons = { FrontTurret01 = Class(TDFGaussCannonWeapon) {} }`
--- If the Label does not match the weapon will not be workable. Defaults to `"Unlabelled"`.
---@field Label string
--- for weapons without a tracking projectile, if the weapon should lead its target when aiming
---@field LeadTarget? boolean
--- if set, requires a player to directly issue an attack / launch order for the unit to fire. Is set for all SMLs and 
--- stationary TMLs. Requires _some_ kind of delay between the firing (such as a charge delay) or queued orders are not 
--- registered properly by the engine and the unit will remain stuck on the first order, never firing again until the
--- player clears the command queue and re-issues the order
---@field ManualFire? boolean
--- The maximum height difference upon which the weapon can fire at targets (cylindrical range).
--- Defaults to nil, which gives infinite vertical range.
---@field MaxHeightDiff? number
--- this weapon can only hold this many counted projectiles
---@field MaxProjectileStorage number
--- how far the target needs to be before we start firing
---@field MaxRadius number
--- the beam will cut off at this distance from the weapon
---@field MaximumBeamLength? number
---@field MetaImpactAmount any unused
---@field MetaImpactRadius any unused
--- the minimum range we must be to fire at our target
---@field MinRadius number
--- The time that the muzzle will wait between playing the FxMuzzleFlash table and the creation of
--- the projectile. Note: This will delay the firing of the projectile. So if you set the rate of
--- fire to fire quickly, this will throttle it.
---@field MuzzleChargeDelay number
--- Time in between muzzles firing. Setting to 0 means all muzzles fire together. This time,
--- multiplied by the number of muzzles minus 1, must not exceed the inverse of the rate of fire.
---@field MuzzleSalvoDelay number
--- Number of times the muzzle will fire during a rack firing
---@field MuzzleSalvoSize number
--- Speed at which the projectile comes out of the muzzle. This speed is used in the ballistics
--- calculations. If you weapon doesn't fire at its max radius, this may be too low.
---@field MuzzleChargeStart? number
--- used by the Galactic Colossus
---@field MuzzleSpecial? number
--- the exit velocity of the projectile once created at the muzzle of the barrel 
---@field MuzzleVelocity number
--- random variation in the weapon's muzzle velocity (gaussian)
---@field MuzzleVelocityRandom number
--- Target distance at which the weapon will start reducing muzzle velocity to maintain a higher
--- firing arc. This was put there so weapons that have a high muzzle velocity (because they have
--- a huge range, like an artillery piece), wouldn't point right at something that's close,
--- it'll slow down its shot to still have a nice arc to it.
---@field MuzzleVelocityReduceDistance number
--- if `NeedProp` is true then whenever the unit aquires a new target and is ready to attack it, it
--- will first run the `OnGotTarget` script on the weapon
---@field NeedPrep? boolean
--- sets `AlwaysRecheckTarget = false` and prevents automatic target resetting
--- so that bombers don't retarget halfway through a bombing run
---@field NeedToComputeBombDrop? boolean
--- if the unit is set as "busy" while the weapon charges
---@field NotExclusive? boolean
---@field NoPause any unused
--- The damage that the inner ring of the nuke does in each segment. The outer damage will also end
--- up being applied to units in the inner ring.
---@field NukeInnerRingDamage? number
--- the radius of the inner damage ring of the nuke 
---@field NukeInnerRingRadius? number
--- How many damage ticks the inner damage ring of the nuke will be applied over to get from the
--- epicenter to the inner ring radius. The ring will be broken up into this many disks.
---@field NukeInnerRingTicks? number
--- The total time in seconds it takes the inner damage ring to apply its damage from the epicenter
--- of the nuke to its inner ring radius. If `0` or `1`, this behaves as a damage area.
---@field NukeInnerRingTotalTime? number
--- The damage that the outer ring of the nuke does in each segment. Note that the inner damage ring
--- overlaps with some of the units as well.
---@field NukeOuterRingDamage? number
--- the radius of the outer damage ring of the nuke 
---@field NukeOuterRingRadius? number
--- How many damage ticks the outer damage ring of the nuke will be applied over to get from the
--- epicenter to the outer ring radius. The ring will be broken up into this many disks.
---@field NukeOuterRingTicks? number
--- The total time in seconds it takes the outer damage ring to apply its damage from the epicenter
--- of the nuke to its outer ring radius. If `0` or `1`, this behaves as a damage area.
---@field NukeOuterRingTotalTime? number
--- nuke weapon flag
---@field NukeWeapon? boolean
---@field Overcharge? WeaponBlueprintOvercharge
--- overcharge weapon flag
---@field OverchargeWeapon? boolean
--- flag that specifies if the weapon prefers to target what the primary weapon is currently
--- targeting
---@field PrefersPrimaryWeaponTarget? boolean
--- blueprint of the projectile to fire
---@field ProjectileId FileName
--- Lifetime for projectile in seconds.
--- If 0, the projectile will use the lifetime from its own blueprint.
---@field ProjectileLifetime number
--- Sets the lifetime for the projectile to use the lifetime equation of
--- `ProjectileLifetimeUsesMultiplier * MaxRadius / MuzzleVelocity`
---@field ProjectileLifetimeUsesMultiplier? number
--- list of weapon racks this weapon uses
---@field RackBones WeaponRacksBlueprint
--- if all racks fire simultaneously
---@field RackFireTogether boolean
--- Distance racks will recoil along the weapon's z-axis (local coords).
--- `MuzzleSalvoDelay` cannot be 0, so that there's time to return the racks.
---@field RackRecoilDistance? number
--- How fast the recoil bone returns from its telecoped distance. If absent, treated as
--- the number that makes the rack return when 80% ready to fire again.
---@field RackRecoilReturnSpeed? number
--- seconds before the weapon will reload when it didn't go through all its racks
---@field RackReloadTimeout? number
--- time before the racks start firing
---@field RackSalvoChargeTime? number
--- if the racks immediately fire when done charging or if they wait until next `OnFire` event
---@field RackSalvoFiresAfterCharge boolean
--- time the racks will reload before starting its next charge/salve cycle
---@field RackSalvoReloadTime number
--- if all rack bones are "slaved" to the turret pitch bone
---@field RackSlavedToTurret boolean
--- the range category this weapon satisfies
---@field RangeCategory? WeaponRangeCategory
--- Rack firings per second. You can use decimals for fire rates that are longer than a second.
---@field RateOfFire number
--- if this weapon will find new target on miss events
---@field ReTargetOnMiss? boolean
--- if `true`, will set the orange work progress bar to display the reload progress of this weapon
---@field RenderFireClock? boolean
--- used by the Othuy ("lighting storm") to define the time to re-aquire a new target before going
--- through the next lighting strike process
---@field RequireTime? number
--- the number of projectiles in the firing salvo
---@field SalvoSize? number
--- if the weapon goes directly from its `IdleState` to its `RackSalvoFiringState` without
--- going through its `RackSalvoFireReadyState` first
---@field SkipReadyState? boolean
--- if the weapon is "slaved" to the unit's body, thus requiring it to face its target to fire
---@field SlavedToBody? boolean
--- Range of arc in both directions to be considered "slaved" to a target. With multiple weapons, 
--- the first weapon in the blueprint that currently has a target is used for turning.
---@field SlavedToBodyArcRange? number
--- flag to specify to not make the weapon active if the primary weapon has a current target
---@field StopOnPrimaryWeaponBusy? boolean
--- interval of time between looking for a target
---@field TargetCheckInterval number
--- issues a `ResetTarget` half way the firing sequence
---@field TargetResetWhenReady boolean
--- table of category strings that define the targetting order of this weapon
---@field TargetPriorities UnparsedCategory[]
--- comma separated list of category names that are always invalid targets
---@field TargetRestrictDisallow UnparsedCategory
--- comma separated list of category names that are the only valid targets
---@field TargetRestrictOnlyAllow UnparsedCategory
--- the type of entity this unit can target
---@field TargetType WeaponTargetType
--- Lets the AI know that this weapon is one of two weapon definitions on a weapon bone that gets
--- used when toggling between ground and anti-air. Which weapon is which is determined by which
--- weapon has a `FireTargetLayerCapsTable` layer containing `"Air"`. The string should be the label
--- of the corresponding weapon.
---@field ToggleWeapon? string
--- The radius at which the weapon starts tracking the target. This does not mean that the weapon
--- will fire. The weapon will only fire when a target enters the maxradius. This is a multiplier of
--- the weapon's `MaxRadius`.
---@field TrackingRadius? number
--- the second muzzle bone for a turret, used for arms on bots as weapons
---@field TurretBoneDualMuzzle? Bone
--- the second pitch bone for a turret, used for arms on bots as weapons
---@field TurretBoneDualPitch? Bone
--- The second yaw bone for a turret, used for the torso of the Loyalist's secondary weapon that is on a turret connected to the torso.
---@field TurretBoneDualYaw? Bone
--- The bone used as the muzzle bone for turrets. This is used for aiming as where the projectile
--- would come out
---@field TurretBoneMuzzle? Bone
--- bone name that will determine the pitch rotation (rotation along the X axis)
---@field TurretBonePitch? Bone
--- bone name that will determine the yaw rotation (rotation along the Y axis)
---@field TurretBoneYaw? Bone
--- If two manipulators are needed for this weapon. Used for bots with arms.
---@field TurretDualManipulators? boolean
--- if this weapon has a turret
---@field Turreted boolean
--- the center angle for determining pitch, based off the rest pose of the model
---@field TurretPitch number
--- the angle +/- off the pitch that is a valid angle to turn to
---@field TurretPitchRange number
--- the speed at which the turret can pitch
---@field TurretPitchSpeed number
--- the center angle for determining yaw, based off the rest pose of the model
---@field TurretYaw number
--- the angle +/- off the yaw that is a valid angle to turn to
---@field TurretYawRange number
--- the speed at which the turret can turn in its yaw direction
---@field TurretYawSpeed number
--- the center angle for determining secondary yaw, based off the rest pose of the model
---@field TurretDualYaw number
--- the angle +/- off the secondary yaw that is a valid angle to turn to
---@field TurretDualYawRange number
--- the speed at which the secondary turret can turn in its yaw direction
---@field TurretDualYawSpeed number
--- if this weapon uses the recent firing solution to create projectile instead of the
--- aim bone transform when it fires.
---@field UseFiringSolutionInsteadOfAimBone? boolean
--- the kind of weapon this is
---@field WeaponCategory WeaponCategory
--- amount of time after the unit has lost its target that it will wait before repacking the weapon
---@field WeaponRepackTimeout? number
--- path of the unpack animation
---@field WeaponUnpackAnimation? FileName
--- how fast the unpack animation runs
---@field WeaponUnpackAnimationRate? number
--- The animation precedence for the unpack manipulator. Treated as `0` if absent.
---@field WeaponUnpackAnimatorPrecedence? number
--- If all unit motion is halted while this weapon is active and all other weapons not flagged with
--- `NotExclusive = true` are locked out. This is useful when a unit must be stationary to fire such
--- as a moble artillery unit or when a unit is required to be stationary during an unpack / repack
--- sequence.
---@field WeaponUnpackLocksMotion? boolean
--- time the unit will take to unpack the weapon
---@field WeaponUnpackTimeout? number
--- if the weapon must unpack before it's ready to fire
---@field WeaponUnpacks? boolean
--- this weapon is considered on target if the yaw is facing the target
---@field YawOnlyOnTarget? boolean
---
--- auto-generated by `unit.BlueprintId .. "-" .. <weapon index> .. "-" .. weapon.Label`
---@field BlueprintId BlueprintId
--- auto-generated from `MuzzleSalvoSize` to keep backwards compatibility
---@field ProjectilesPerOnFire number
--- auto-generated to `1` to keep backwards compatibility
---@field RackSalvoSize number

---@class WeaponBlueprintFlare
--- the category of projectiles this flare will attract
---@field Category UnparsedCategory
--- if `Stack` is set, then two additionals flares will be created on the Z axis
--- at an offset of this value multiplied by the `Radius`
---@field OffsetMult? number
--- the collision sphere radius, treated as `5` if absent
---@field Radius? number
--- if two additional flares should be created on the Z axis, each offset by
--- `OffsetMult * Radius` for its collision center
---@field Stack? boolean

---@class WeaponBlueprintDepthCharge
---@field Radius number
---@field ProjectilesToDeflect number

---@class WeaponBlueprintOvercharge
--- flat damage applied to commanders, regardless of energy storage
---@field commandDamage number
--- What fraction of current energy storage can be spent. This energy (shared among all
--- overcharging units) is what is converted to damage, and then clamped.
---@field energyMult number
--- minimum damage the energy can convert to
---@field maxDamage number
--- minimum damage the energy can convert to 
---@field minDamage number
--- flat damage applied to structures, regardless of energy storage
---@field structureDamage number

---@class WeaponRacksBlueprint : RackBoneBlueprint[]

---@class RackBoneBlueprint
--- the rack's bone that all of the child muzzle bones are attached to
---@field RackBone Bone
--- the list of muzzle bones that are attached to the rack
---@field MuzzleBones Bone[]
--- the bone on the rack to telescope from by the `TelescopeRecoilDistance`
---@field TelescopeBone? Bone
--- How much the rack slides back by (from `TelescopeBone`). Treated as the weapon's
--- `RackRecoilDistance` value if absent.
---@field TelescopeRecoilDistance? number
--- if the muzzle bone is only visible during the charge sequence
---@field HideMuzzle? boolean

---@class WeaponBlueprintAudio
---@field BarrelLoop? SoundHandle
---@field BarrelStart? SoundHandle
---@field BarrelStop? SoundHandle
---@field BeamLoop? SoundHandle
---@field BeamStart? SoundHandle
---@field BeamStop? SoundHandle
---@field ChargeStart? SoundHandle
---@field Fire? SoundHandle
---@field FireUnderWater? SoundHandle
---@field MuzzleChargeStart? SoundHandle
---@field Open? SoundHandle
---@field Unpack? SoundHandle
