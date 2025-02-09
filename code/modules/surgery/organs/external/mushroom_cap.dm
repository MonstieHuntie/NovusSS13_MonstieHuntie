/// The cap of a mushroomperson
/obj/item/organ/mushroom_cap
	name = "mushroom cap"
	desc = "The cap of a suspiciously large mushroom. It's hard to tell if it's poisonous to eat or not."

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_MUSHROOM_CAP

	visual = TRUE
	process_life = FALSE
	process_death = FALSE

	use_mob_sprite_as_obj_sprite = TRUE
	dna_block = DNA_MUSHROOM_CAPS_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_PLANT //i know mushrooms are not plants but whatever, close enough

	bodypart_overlay = /datum/bodypart_overlay/mutant/mushroom_cap

/datum/bodypart_overlay/mutant/mushroom_cap
	layers = EXTERNAL_ADJACENT
	feature_key = "mushroom_caps"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/mushroom_cap/get_global_feature_list()
	return GLOB.mushroom_caps_list

/datum/bodypart_overlay/mutant/mushroom_cap/can_draw_on_body(obj/item/bodypart/ownerlimb, mob/living/carbon/human/owner)
	if((owner.head?.flags_inv & HIDEHAIR) || (owner.wear_mask?.flags_inv & HIDEHAIR))
		return FALSE

	return TRUE
