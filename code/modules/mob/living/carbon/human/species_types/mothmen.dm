/datum/species/moth
	name = "\improper Mothman"
	plural_form = "Mothmen"
	id = SPECIES_MOTH
	chat_color = COLOR_BEIGE
	inherent_traits = list(
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_TACKLING_WINGED_ATTACKER,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG

	cosmetic_organs = list(
		/obj/item/organ/wings/moth = "Plain",
		/obj/item/organ/antennae = "Plain",

		/obj/item/organ/genital/penis = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/genital/testicles = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/genital/breasts = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/genital/vagina = SPRITE_ACCESSORY_NONE,
		/obj/item/organ/genital/anus = SPRITE_ACCESSORY_NONE,
	)
	body_marking_sets = list(
		"Reddish",
		"Royal",
		"White Fly",
		"Lovers",
		"Firewatch",
		"Deathshead",
		"Poison",
		"Ragged",
		"Moon Fly",
		"Oak Worm",
		"Jungle",
		"Witch Wing",
	)
	meat = /obj/item/food/meat/slab/human/mutant/moth
	mutanttongue = /obj/item/organ/tongue/moth
	mutanteyes = /obj/item/organ/eyes/moth
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/moth
	wing_types = list(/obj/item/organ/wings/functional/moth/megamoth, /obj/item/organ/wings/functional/moth/mothra)
	family_heirlooms = list(/obj/item/flashlight/lantern/heirloom_moth)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/moth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/moth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/moth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/moth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/moth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/moth,
	)

	voice_pack = /datum/voice/moth

/datum/species/moth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name()

	var/randname = moth_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/moth/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 10 //flyswatters deal 10x damage to moths
	return 1

/datum/species/moth/randomize_features(mob/living/carbon/human/human_mob)
	. = ..()
	randomize_cosmetic_organs(human_mob)
	randomize_markings(human_mob)

/datum/species/moth/get_species_description()
	return "Hailing from a planet that was lost long ago, the moths travel \
		the galaxy as a nomadic people aboard a colossal fleet of ships, seeking a new homeland."

/datum/species/moth/get_species_lore()
	return list(
		"Their homeworld lost to the ages, the moths live aboard the Grand Nomad Fleet. \
		Made up of what could be found, bartered, repaired, or stolen the armada is a colossal patchwork \
		built on a history of politely flagging travelers down and taking their things. Occasionally a moth \
		will decide to leave the fleet, usually to strike out for fortunes to send back home.",

		"Nomadic life produces a tight-knit culture, with moths valuing their friends, family, and vessels highly. \
		Moths are gregarious by nature and do best in communal spaces. This has served them well on the galactic stage, \
		maintaining a friendly and personable reputation even in the face of hostile encounters. \
		It seems that the galaxy has come to accept these former pirates.",

		"Surprisingly, living together in a giant fleet hasn't flattened variance in dialect and culture. \
		These differences are welcomed and encouraged within the fleet for the variety that they bring.",
	)

/datum/species/moth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Precious Wings",
			SPECIES_PERK_DESC = "Moths can fly in pressurized, zero-g environments and safely land short falls using their wings.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Meal Plan",
			SPECIES_PERK_DESC = "Moths can eat clothes for temporary nourishment.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Ablazed Wings",
			SPECIES_PERK_DESC = "Moth wings are fragile, and can be easily burnt off.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Bright Lights",
			SPECIES_PERK_DESC = "Moths need an extra layer of flash protection to protect \
				themselves, such as against security officers or when welding. Welding \
				masks will work.",
		),
	)

	return to_add
