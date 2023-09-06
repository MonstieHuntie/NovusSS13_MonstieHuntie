/datum/preference/choiced/mutant/vagina
	savefile_key = "feature_vagina"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_cosmetic_organ = /obj/item/organ/genital/vagina
	relevant_feature = "vagina"
	supplemental_feature_key = "feature_vagina_color"

/datum/preference/choiced/mutant/vagina/init_possible_values()
	return assoc_to_keys_features(GLOB.vagina_list)

/datum/preference/choiced/mutant/vagina/create_informed_default_value(datum/preferences/preferences)
	if(preferences.read_preference(/datum/preference/choiced/gender) != FEMALE)
		return SPRITE_ACCESSORY_NONE

	var/datum/sprite_accessory/genital/vagina/boring_human_vagina = /datum/sprite_accessory/genital/vagina/human
	return initial(boring_human_vagina.name)

/datum/preference/tricolor/mutant/vagina
	savefile_key = "feature_vagina_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_cosmetic_organ = /obj/item/organ/genital/vagina
	relevant_feature = "vagina_color"
	primary_feature_key = "feature_vagina"

/datum/preference/tricolor/mutant/vagina/is_accessible(datum/preferences/preferences)
	return ..() && (preferences.read_preference(/datum/preference/choiced/mutant/vagina) != SPRITE_ACCESSORY_NONE) && !preferences.read_preference(/datum/preference/toggle/vagina_uses_skintone)

/datum/preference/tricolor/mutant/vagina/get_global_feature_list()
	return GLOB.vagina_list

/datum/preference/toggle/vagina_uses_skintone
	savefile_key = "feature_vagina_skintone"
	savefile_identifier = PREFERENCE_CHARACTER
	priority = PREFERENCE_PRIORITY_BODYPARTS
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	relevant_inherent_trait = TRAIT_USES_SKINTONES
	relevant_cosmetic_organ = /obj/item/organ/genital/vagina

/datum/preference/toggle/vagina_uses_skintone/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return
	if(preferences.read_preference(/datum/preference/choiced/mutant/vagina) == SPRITE_ACCESSORY_NONE)
		return FALSE
	if(preferences.read_preference(/datum/preference/toggle/vagina_uses_skintone))
		var/datum/preference/preference = GLOB.preference_entries[/datum/preference/toggle/vagina_uses_skintone]
		if(preference.is_accessible(preferences))
			return FALSE

/datum/preference/toggle/vagina_uses_skintone/create_informed_default_value(datum/preferences/preferences)
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return (TRAIT_USES_SKINTONES in species.inherent_traits)

/datum/preference/toggle/vagina_uses_skintone/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/prefs)
	var/obj/item/organ/genital/vagina = target.get_organ_slot(ORGAN_SLOT_VAGINA)
	if(isnull(vagina) || !HAS_TRAIT_FROM(target, TRAIT_USES_SKINTONES, SPECIES_TRAIT))
		return

	var/datum/bodypart_overlay/mutant/genital/overlay = vagina.bodypart_overlay
	overlay.uses_skintone = value
