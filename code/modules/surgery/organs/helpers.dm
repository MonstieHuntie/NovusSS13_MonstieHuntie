/**
 * Get the organ object from the mob matching the passed in typepath
 *
 * Arguments:
 * * typepath The typepath of the organ to get
 */
/mob/proc/get_organ_by_type(typepath)
	return

/**
 * Get organ objects by zone
 *
 * This will return a list of all the organs that are relevant to the zone that is passedin
 *
 * Arguments:
 * * zone [a BODY_ZONE_X define](https://github.com/tgstation/tgstation/blob/master/code/__DEFINES/combat.dm#L187-L200)
 */
/mob/proc/get_organs_for_zone(zone)
	return

/**
 * Returns a list of all organs in specified slot
 *
 * Arguments:
 * * slot Slot to get the organs from
 */
/mob/proc/get_organ_slot(slot)
	return

/mob/living/carbon/get_organ_by_type(typepath)
	return (locate(typepath) in organs)

/mob/living/carbon/get_organs_for_zone(zone, include_children = FALSE)
	var/valid_organs = list()
	for(var/obj/item/organ/organ as anything in organs)
		if(zone == organ.zone || (include_children && zone == check_zone(organ.zone)))
			valid_organs += organ
	return valid_organs

/mob/living/carbon/get_organ_slot(slot)
	. = organs_slot[slot]

/// Checks if the organ should reasonably apply to the target, when being applied via species change
/proc/should_organ_apply_to(obj/item/organ/organpath, mob/living/carbon/target, datum/species/species)
	if(isnull(organpath) || isnull(target))
		stack_trace("passed a null path or target to 'should_organ_apply_to'")
		return FALSE

	var/datum/bodypart_overlay/mutant/bodypart_overlay = initial(organpath.bodypart_overlay)
	if(isnull(bodypart_overlay))
		return TRUE

	var/feature_key = initial(bodypart_overlay.feature_key)
	if(isnull(feature_key))
		return TRUE

	//Snowflake check for when a species will try to apply an organ that ignores dna features
	if(species?.cosmetic_organs[organpath] && (species.cosmetic_organs[organpath] != SPRITE_ACCESSORY_NONE))
		return TRUE
	else if(!isnull(target.dna.features[feature_key]) && (target.dna.features[feature_key] != SPRITE_ACCESSORY_NONE))
		return TRUE
	return FALSE
