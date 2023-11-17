/obj/item/bodypart/proc/can_dismember(damage_source)
	if(bodypart_flags & BODYPART_UNREMOVABLE)
		return FALSE
	return TRUE

/// Remove target limb from it's owner, with side effects.
/obj/item/bodypart/proc/dismember(dam_type = BRUTE, silent = TRUE)
	if(!owner || (bodypart_flags & BODYPART_UNREMOVABLE))
		return FALSE
	var/mob/living/carbon/limb_owner = owner
	if(limb_owner.status_flags & GODMODE)
		return FALSE
	if(HAS_TRAIT(limb_owner, TRAIT_NODISMEMBER))
		return FALSE

	var/obj/item/bodypart/affecting = limb_owner.get_bodypart(BODY_ZONE_CHEST)
	affecting.receive_damage(clamp(brute_dam/2 * affecting.body_damage_coeff, 15, 50), clamp(burn_dam/2 * affecting.body_damage_coeff, 0, 50), wound_bonus = CANT_WOUND) //Damage the chest based on limb's existing damage
	if(!silent)
		limb_owner.visible_message(span_danger("<B>[limb_owner]'s [name] is violently dismembered!</B>"))
	INVOKE_ASYNC(limb_owner, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(get_turf(limb_owner), 'sound/effects/dismember.ogg', 80, TRUE)
	limb_owner.add_mood_event("dismembered", /datum/mood_event/dismembered)
	limb_owner.add_mob_memory(/datum/memory/was_dismembered, lost_limb = src)
	drop_limb()

	limb_owner.update_equipment_speed_mods() // Update in case speed affecting item unequipped by dismemberment
	limb_owner.bleed(rand(20, 40))

	if(QDELETED(src)) //Could have dropped into lava/explosion/chasm/whatever
		return TRUE
	if(dam_type == BURN)
		burn()
		return TRUE
	transfer_mob_blood_dna(limb_owner)
	fly_away(limb_owner.drop_location())
	return TRUE

/// Proc called to initialize movable physics when a bodypart gets dismembered
/obj/item/bodypart/proc/fly_away(turf/open/owner_location, fly_angle = rand(0, 360), horizontal_multiplier = 1, vertical_multiplier = 1)
	if(!istype(owner_location))
		return
	pixel_x = -px_x
	pixel_y = -px_y
	return AddComponent(/datum/component/movable_physics, \
		physics_flags = MPHYSICS_QDEL_WHEN_NO_MOVEMENT, \
		angle = fly_angle, \
		horizontal_velocity = rand(2.5 * 100, 6 * 100) * horizontal_multiplier * 0.01, \
		vertical_velocity = rand(4 * 100, 4.5 * 100) * vertical_multiplier * 0.01, \
		horizontal_friction = rand(0.24 * 100, 0.3 * 100) * 0.01, \
		vertical_friction = 10 * 0.05, \
		horizontal_conservation_of_momentum = 0.5, \
		vertical_conservation_of_momentum = 0.5, \
		z_floor = 0, \
	)

/obj/item/bodypart/chest/dismember()
	if(!owner || (bodypart_flags & BODYPART_UNREMOVABLE))
		return FALSE
	if(owner.status_flags & GODMODE)
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NODISMEMBER))
		return FALSE
	return drop_organs(violent_removal = TRUE)

/**
 * Standard limb removal.
 * The "special" argument is used for swapping a limb with a new one without the effects of losing a limb kicking in.
 */
/obj/item/bodypart/proc/drop_limb(special, dismembered)
	if(!owner)
		return
	var/atom/drop_loc = owner.drop_location()
	SEND_SIGNAL(owner, COMSIG_CARBON_REMOVE_LIMB, src, special, dismembered)
	SEND_SIGNAL(src, COMSIG_BODYPART_REMOVED, owner, special, dismembered)
	update_limb(dropping_limb = TRUE)
	bodypart_flags &= ~BODYPART_IMPLANTED //limb is out and about, it can't really be considered an implant
	owner.remove_bodypart(src)

	for(var/datum/wound/wound as anything in wounds)
		wound.remove_wound(TRUE)

	for(var/datum/scar/scar as anything in scars)
		scar.victim = null
		LAZYREMOVE(owner.all_scars, scar)

	for(var/obj/item/organ/organ as anything in organs)
		organ.transfer_to_limb(src, special)

	var/mob/living/carbon/phantom_owner = set_owner(null) // so we can still refer to the guy who lost their limb after said limb forgets 'em

	for(var/datum/surgery/surgery as anything in phantom_owner.surgeries) //if we had an ongoing surgery on that limb, we stop it.
		if(surgery.operated_bodypart == src)
			phantom_owner.surgeries -= surgery
			qdel(surgery)
			break

	for(var/obj/item/embedded in embedded_objects)
		embedded.forceMove(src) // It'll self remove via signal reaction, just need to move it
	if(!phantom_owner.has_embedded_objects())
		phantom_owner.clear_alert(ALERT_EMBEDDED_OBJECT)
		phantom_owner.clear_mood_event("embedded")

	if(!special)
		if(phantom_owner.dna)
			for(var/datum/mutation/human/mutation as anything in phantom_owner.dna.mutations) //some mutations require having specific limbs to be kept.
				if(mutation.limb_req && (mutation.limb_req == body_zone))
					to_chat(phantom_owner, span_warning("You feel your [mutation] deactivating from the loss of your [body_zone]!"))
					phantom_owner.dna.force_lose(mutation)

	update_icon_dropped()
	phantom_owner.update_health_hud() //update the healthdoll
	phantom_owner.update_body()
	phantom_owner.update_body_parts()

	SEND_SIGNAL(phantom_owner, COMSIG_CARBON_POST_REMOVE_LIMB, src, special, dismembered)
	// drop_loc = null happens when a "dummy human" used for rendering icons on prefs screen gets its limbs replaced.
	if(!drop_loc)
		qdel(src)
		return
	// pseudoparts should always be qdel'd, they're not real
	if(bodypart_flags & BODYPART_PSEUDOPART)
		drop_organs(phantom_owner) //pseudoparts shouldn't have organs, but just in case they do, we drop them
		qdel(src)
		return
	forceMove(drop_loc)

/**
 * Eviscerates the bodypart, dropping all organs and items inside of it
 * Arguments:
 * * violent_removal: If TRUE, organs will be thrown out using proc/fly_away() and a splort sound is played
 */
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	var/atom/drop_loc = drop_location()
	if(IS_ORGANIC_LIMB(src) && violent_removal)
		playsound(drop_loc, 'sound/misc/splort.ogg', 50, TRUE, -1)
	seep_gauze(9999) // destroy any existing gauze if any exists
	for(var/obj/item/organ/organ as anything in organs)
		if(owner)
			organ.Remove(owner)
		else
			organ.remove_from_limb(src)
		organ.forceMove(drop_loc)
		if(violent_removal)
			organ.fly_away(drop_loc)
	for(var/obj/item/item_in_bodypart in src)
		item_in_bodypart.forceMove(drop_loc)
		if(violent_removal && owner)
			item_in_bodypart.transfer_mob_blood_dna(owner)

	if(owner)
		owner.update_body_parts()
	else
		update_icon_dropped()

/**
 * get_mangled_state() is relevant for flesh and bone bodyparts, and returns whether this bodypart has mangled skin, mangled bone, or both (or neither i guess)
 *
 * Dismemberment for flesh and bone requires the victim to have the skin on their bodypart destroyed (either a critical cut or piercing wound), and at least a hairline fracture
 * (severe bone), at which point we can start rolling for dismembering. The attack must also deal at least 10 damage, and must be a brute attack of some kind (sorry for now, cakehat, maybe later)
 *
 * Returns: BODYPART_MANGLED_NONE if we're fine, BODYPART_MANGLED_FLESH if our skin is broken, BODYPART_MANGLED_BONE if our bone is broken, or BODYPART_MANGLED_BOTH if both are broken and we're up for dismembering
 */
/obj/item/bodypart/proc/get_mangled_state()
	. = BODYPART_MANGLED_NONE
	for(var/datum/wound/iter_wound as anything in wounds)
		if(iter_wound.wound_flags & MANGLES_BONE)
			. |= BODYPART_MANGLED_BONE
		if(iter_wound.wound_flags & MANGLES_FLESH)
			. |= BODYPART_MANGLED_FLESH

/**
 * try_dismember() is used, once we've confirmed that a flesh and bone bodypart has both the skin and bone mangled, to actually roll for it
 *
 * Mangling is described in the above proc, [/obj/item/bodypart/proc/get_mangled_state]. This simply makes the roll for whether we actually dismember or not
 * using how damaged the limb already is, and how much damage this blow was for. If we have a critical bone wound instead of just a severe, we add +10% to the roll.
 * Lastly, we choose which kind of dismember we want based on the wounding type we hit with. Note we don't care about all the normal mods or armor for this
 *
 * Arguments:
 * * wounding_type: Either WOUND_BLUNT, WOUND_SLASH, or WOUND_PIERCE, basically only matters for the dismember message
 * * wounding_dmg: The damage of the strike that prompted this roll, higher damage = higher chance
 * * wound_bonus: Not actually used right now, but maybe someday
 * * bare_wound_bonus: ditto above
 */
/obj/item/bodypart/proc/try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	if(wounding_dmg < DISMEMBER_MINIMUM_DAMAGE)
		return

	var/base_chance = wounding_dmg
	base_chance += (get_damage() / max_damage * 50) // how much damage we dealt with this blow, + 50% of the damage percentage we already had on this bodypart

	if(locate(/datum/wound/blunt/critical) in wounds) // we only require a severe bone break, but if there's a critical bone break, we'll add 15% more
		base_chance += 15

	if(prob(base_chance))
		var/datum/wound/loss/dismembering = new
		return dismembering.apply_dismember(src, wounding_type)

/obj/item/bodypart/arm/drop_limb(special, dismembered)
	var/mob/living/carbon/arm_owner = owner
	. = ..()
	if(special || !arm_owner)
		return

	if(arm_owner.hand_bodyparts[held_index] == src)
		// We only want to do this if the limb being removed is the active hand part.
		// This catches situations where limbs are "hot-swapped" such as augmentations and roundstart prosthetics.
		arm_owner.dropItemToGround(arm_owner.get_item_for_held_index(held_index), 1)
	if(arm_owner.handcuffed)
		arm_owner.dropItemToGround(arm_owner.handcuffed, force = TRUE)
		arm_owner.set_handcuffed(null)
		arm_owner.update_handcuffed()
	if(arm_owner.hud_used)
		var/atom/movable/screen/inventory/hand/associated_hand = arm_owner.hud_used.hand_slots["[held_index]"]
		associated_hand?.update_appearance()
	if(arm_owner.gloves)
		arm_owner.dropItemToGround(arm_owner.gloves, force = TRUE)
	arm_owner.update_worn_gloves() //to remove the bloody hands overlay

/obj/item/bodypart/leg/drop_limb(special, dismembered)
	var/mob/living/carbon/leg_owner = owner
	. = ..()
	if(special || !leg_owner)
		return

	if(leg_owner.legcuffed)
		leg_owner.dropItemToGround(owner.legcuffed, force = TRUE)
		leg_owner.legcuffed = null
		leg_owner.update_worn_legcuffs()
	if(leg_owner.shoes)
		leg_owner.dropItemToGround(leg_owner.shoes, force = TRUE)

/// Try to attach this bodypart to a mob, while replacing one if it exists, does nothing if it fails
/obj/item/bodypart/proc/replace_limb(mob/living/carbon/limb_owner, special = FALSE, keep_old_organs = TRUE)
	if(!istype(limb_owner))
		return

	var/obj/item/bodypart/old_limb = limb_owner.get_bodypart(body_zone)
	var/list/fucking_organs
	if(old_limb)
		// We have to do this stupid goofy loop because guess what fucker,
		// the old limb might drop in nullspace therefore the organs get deleted (ugh)
		if(keep_old_organs)
			fucking_organs = list()
			for(var/obj/item/organ/organ as anything in old_limb.organs)
				organ.Remove(limb_owner, special = TRUE)
				organ.forceMove(src)
				fucking_organs += organ
		old_limb.drop_limb(special = TRUE) //always true, this limb is being replaced even if the new one isn't

	. = try_attach_limb(limb_owner, special)
	if(!.) //If it failed to replace, re-attach their old limb as if nothing happened.
		old_limb.try_attach_limb(limb_owner, special = TRUE) //always true, this limb is being replaced even if the new one isn't
	//god this is ass
	if(keep_old_organs)
		for(var/obj/item/organ/organ as anything in fucking_organs)
			organ.Insert(limb_owner, special = TRUE)

/// Checks if a limb qualifies as a BODYPART_IMPLANTED
/obj/item/bodypart/proc/check_for_frankenstein(mob/living/carbon/human/monster)
	if(!istype(monster))
		return FALSE
	var/obj/item/bodypart/original_type = monster.dna.species.bodypart_overrides[body_zone]
	if(!original_type || (limb_id != initial(original_type.limb_id)))
		return TRUE
	return FALSE

///Checks if you can attach a limb, returns TRUE if you can.
/obj/item/bodypart/proc/can_attach_limb(mob/living/carbon/new_limb_owner, special)
	if(SEND_SIGNAL(new_limb_owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, src, special) & COMPONENT_NO_ATTACH)
		return FALSE
	if(!special)
		var/obj/item/bodypart/chest/mob_chest = new_limb_owner.get_bodypart(BODY_ZONE_CHEST)
		if(mob_chest && !(mob_chest.acceptable_bodytype & bodytype))
			return FALSE
	return TRUE

/// Attach src to target mob if able, returns FALSE if it fails to.
/obj/item/bodypart/proc/try_attach_limb(mob/living/carbon/new_limb_owner, special = FALSE)
	SHOULD_NOT_SLEEP(TRUE)
	if(!can_attach_limb(new_limb_owner, special))
		return FALSE

	SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_ATTACH_LIMB, src, special)
	SEND_SIGNAL(src, COMSIG_BODYPART_ATTACHED, new_limb_owner, special)
	moveToNullspace()
	set_owner(new_limb_owner)
	new_limb_owner.add_bodypart(src)

	if(special) //non conventional limb attachment
		for(var/datum/surgery/attach_surgery as anything in new_limb_owner.surgeries) //if we had an ongoing surgery to attach a new limb, we stop it.
			var/surgery_zone = check_zone(attach_surgery.location)
			if(surgery_zone == body_zone)
				new_limb_owner.surgeries -= attach_surgery
				qdel(attach_surgery)
				break

	for(var/obj/item/organ/organ as anything in organs)
		organ.remove_from_limb(src) //fucking ass, but insert will set us as the bodypart again
		organ.Insert(new_limb_owner, special)

	for(var/datum/wound/wound as anything in wounds)
		// we have to remove the wound from the limb wound list first, so that we can reapply it fresh with the new person
		// otherwise the wound thinks it's trying to replace an existing wound of the same type (itself) and fails/deletes itself
		LAZYREMOVE(wounds, wound)
		wound.apply_wound(src, TRUE, wound_source = wound.wound_source)

	for(var/datum/scar/scar as anything in scars)
		if(scar in new_limb_owner.all_scars) // prevent double scars from happening for whatever reason
			continue
		scar.victim = new_limb_owner
		LAZYADD(new_limb_owner.all_scars, scar)

	update_bodypart_damage_state()
	if(can_be_disabled)
		update_disabled()

	// Bodyparts need to be sorted for leg masking to be done properly. It also will allow for some predictable
	// behavior within said bodyparts list. We sort it here, as it's the only place we make changes to bodyparts.
	new_limb_owner.bodyparts = sort_list(new_limb_owner.bodyparts, GLOBAL_PROC_REF(cmp_bodypart_by_body_part_asc))
	new_limb_owner.updatehealth()
	new_limb_owner.update_body()
	new_limb_owner.update_damage_overlays()
	SEND_SIGNAL(new_limb_owner, COMSIG_CARBON_POST_ATTACH_LIMB, src, special)
	return TRUE

/// Regenerates all missing limbs, except the ones in excluded_zones
/mob/living/carbon/proc/regenerate_limbs(list/excluded_zones)
	SEND_SIGNAL(src, COMSIG_CARBON_REGENERATE_LIMBS, excluded_zones)
	var/list/zone_list = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
	if(length(excluded_zones))
		zone_list -= excluded_zones
	for(var/limb_zone in zone_list)
		regenerate_limb(limb_zone)

/// Regenerates a specfic limb, if it's missing.
/mob/living/carbon/proc/regenerate_limb(limb_zone)
	var/obj/item/bodypart/limb
	if(get_bodypart(limb_zone))
		return FALSE

	limb = newBodyPart(limb_zone)
	if(limb)
		if(!limb.try_attach_limb(src, special = TRUE))
			qdel(limb)
			return FALSE
		limb.update_limb(is_creating = TRUE)
		var/datum/scar/scaries = new
		var/datum/wound/loss/phantom_loss = new // stolen valor, really
		scaries.generate(limb, phantom_loss)

		//Copied from /datum/species/proc/on_species_gain()
		//fucking stupid shit to be honest
		for(var/obj/item/organ/organ_path as anything in dna?.species.cosmetic_organs)
			//Load a persons preferences from DNA
			var/zone = check_zone(initial(organ_path.zone))
			if(zone != limb_zone)
				continue
			var/obj/item/organ/new_organ = SSwardrobe.provide_type(organ_path)
			new_organ.Insert(src, special = TRUE)

		update_body_parts()
		return TRUE
	return FALSE
