/datum/preference/choiced/mutant/breasts
	savefile_key = "feature_breasts"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_cosmetic_organ = /obj/item/organ/genital/breasts
	modified_feature = "breasts"
	supplemental_feature_key = "feature_breasts_color"
	randomize_by_default = FALSE

/datum/preference/choiced/mutant/breasts/init_possible_values()
	return assoc_to_keys_features(GLOB.breasts_list)

/datum/preference/choiced/mutant/breasts/included_in_randomization_flags(randomize_flags)
	return ..() && !!(randomize_flags & RANDOMIZE_GENITALS)

/datum/preference/choiced/mutant/breasts/create_default_value(datum/preferences/preferences)
	return SPRITE_ACCESSORY_NONE
	/*
	if(preferences?.read_preference(/datum/preference/choiced/gender) != FEMALE)
		return SPRITE_ACCESSORY_NONE

	var/datum/sprite_accessory/genital/breasts/boring_human_breasts = /datum/sprite_accessory/genital/breasts/pair
	return initial(boring_human_breasts.name)
	*/


/datum/preference/choiced/mutant/breasts_size
	savefile_key = "feature_breasts_size"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_cosmetic_organ = /obj/item/organ/genital/breasts
	modified_feature = "breasts_size"
	randomize_by_default = FALSE

/datum/preference/choiced/mutant/breasts_size/init_possible_values()
	return assoc_to_keys(GLOB.breasts_size_names)

/datum/preference/choiced/mutant/breasts_size/included_in_randomization_flags(randomize_flags)
	return ..() && !!(randomize_flags & RANDOMIZE_GENITALS)

/datum/preference/choiced/mutant/breasts_size/compile_constant_data()
	var/list/data = ..()

	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = GLOB.breasts_size_names

	return data

/datum/preference/choiced/mutant/breasts_size/is_accessible(datum/preferences/preferences)
	return ..() && preferences.read_preference(/datum/preference/choiced/mutant/breasts) != SPRITE_ACCESSORY_NONE

/datum/preference/choiced/mutant/breasts_size/create_default_value(datum/preferences/preferences)
	return "2"


/datum/preference/tricolor/mutant/breasts
	savefile_key = "feature_breasts_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_cosmetic_organ = /obj/item/organ/genital/breasts
	modified_feature = "breasts_color"
	primary_feature_key = "feature_breasts"
	randomize_by_default = FALSE

/datum/preference/tricolor/mutant/breasts/is_accessible(datum/preferences/preferences)
	if(preferences.read_preference(/datum/preference/choiced/mutant/breasts) == SPRITE_ACCESSORY_NONE)
		return FALSE
	/*
	if(preferences.read_preference(/datum/preference/toggle/breasts_uses_skintone))
		return FALSE
	*/
	return ..()

/datum/preference/tricolor/mutant/breasts/included_in_randomization_flags(randomize_flags)
	return ..() && !!(randomize_flags & RANDOMIZE_GENITALS)

/datum/preference/tricolor/mutant/breasts/get_global_feature_list()
	return GLOB.breasts_list


/datum/preference/toggle/breasts_uses_skintone
	savefile_key = "feature_breasts_skintone"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODYPARTS
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = TRAIT_USES_SKINTONES
	relevant_cosmetic_organ = /obj/item/organ/genital/breasts
	randomize_by_default = FALSE
	priority = PREFERENCE_PRIORITY_BODYPARTS

/datum/preference/toggle/breasts_uses_skintone/included_in_randomization_flags(randomize_flags)
	return !!(randomize_flags & RANDOMIZE_GENITALS)

/datum/preference/toggle/breasts_uses_skintone/is_accessible(datum/preferences/preferences)
	return ..() && preferences.read_preference(/datum/preference/choiced/mutant/breasts) != SPRITE_ACCESSORY_NONE

/datum/preference/toggle/breasts_uses_skintone/create_default_value(datum/preferences/preferences)
	if(!preferences)
		return TRUE

	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return (TRAIT_USES_SKINTONES in species.get_all_traits())

/datum/preference/toggle/breasts_uses_skintone/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/prefs)
	var/obj/item/organ/genital/breasts = target.get_organ_slot(ORGAN_SLOT_BREASTS)
	if(isnull(breasts) || !HAS_TRAIT_FROM(target, TRAIT_USES_SKINTONES, SPECIES_TRAIT))
		return

	var/datum/bodypart_overlay/mutant/genital/overlay = breasts?.bodypart_overlay
	overlay.uses_skintone = value
