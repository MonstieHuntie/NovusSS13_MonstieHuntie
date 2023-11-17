//////////////////////////
/////Initial Building/////
//////////////////////////

/proc/init_sprite_accessories()
	//hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/hair, GLOB.hairstyles_list, GLOB.hairstyles_male_list, GLOB.hairstyles_female_list)
	//facial hair
	init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hairstyles_list, GLOB.facial_hairstyles_male_list, GLOB.facial_hairstyles_female_list)
	//underwear
	init_sprite_accessory_subtypes(/datum/sprite_accessory/underwear, GLOB.underwear_list, GLOB.underwear_m, GLOB.underwear_f, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/undershirt, GLOB.undershirt_list, GLOB.undershirt_m, GLOB.undershirt_f, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/socks, GLOB.socks_list, add_blank = TRUE)
	//bodypart accessories (blizzard intensifies)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails, GLOB.tails_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/human, GLOB.tails_list_human, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/monkey, GLOB.tails_list_monkey, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/lizard, GLOB.tails_list_lizard, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/avali, GLOB.tails_list_avali)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts, GLOB.snouts_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/snouts/lizard, GLOB.snouts_list_lizard, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns, GLOB.horns_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/horns/lizard, GLOB.horns_list_lizard, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears, GLOB.ears_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears/human, GLOB.ears_list_human, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/ears/avali, GLOB.ears_list_avali)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills, GLOB.frills_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/frills/lizard, GLOB.frills_list_lizard, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines, GLOB.spines_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/spines/lizard, GLOB.spines_list_lizard, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings, GLOB.wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/wings_open, GLOB.wings_open_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/legs, GLOB.legs_list) //DO NOT ADD BLANK HERE YOU DUMB FUCK
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_wings, GLOB.moth_wings_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/moth_antennae, GLOB.moth_antennae_list)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/mushroom_caps, GLOB.mushroom_caps_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/pod_hair, GLOB.pod_hair_list, add_blank = TRUE)

	//genitals
	init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/penis, GLOB.penis_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/testicles, GLOB.testicles_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/breasts, GLOB.breasts_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/vagina, GLOB.vagina_list, add_blank = TRUE)
	init_sprite_accessory_subtypes(/datum/sprite_accessory/genital/anus, GLOB.anus_list, add_blank = TRUE)

	//markings are dumb
	init_body_markings()

/// Inits GLOB.body_marking_sets
/proc/init_body_markings()
	init_sprite_accessory_subtypes(/datum/sprite_accessory/body_markings, GLOB.body_markings)
	for(var/marking_name in GLOB.body_markings)
		var/datum/sprite_accessory/body_markings/body_marking = GLOB.body_markings[marking_name]
		for(var/zone in GLOB.marking_zones)
			var/bitflag = GLOB.marking_zone_to_bitflag[zone]
			if(body_marking.allowed_bodyparts & bitflag)
				LAZYADDASSOC(GLOB.body_markings_by_zone[zone], marking_name, body_marking)
	// Here we build the global list for all body markings sets
	for(var/marking_path in subtypesof(/datum/body_marking_set))
		var/datum/body_marking_set/marking_set = marking_path
		if(initial(marking_set.name))
			marking_set = new marking_path()
			GLOB.body_marking_sets[marking_set.name] = marking_set

/// Inits GLOB.species_list. Not using GLOBAL_LIST_INIT b/c it depends on GLOB.string_lists
/proc/init_species_list()
	for(var/species_path in subtypesof(/datum/species))
		var/datum/species/species = species_path
		GLOB.species_list[initial(species.id)] = species_path
	GLOB.species_list = sort_list(GLOB.species_list, GLOBAL_PROC_REF(cmp_typepaths_asc))

/// Inits GLOB.surgeries
/proc/init_surgeries()
	var/surgeries = list()
	for(var/path in subtypesof(/datum/surgery))
		surgeries += new path()
	sort_list(surgeries, GLOBAL_PROC_REF(cmp_typepaths_asc))
	return surgeries

/// Hair Gradients - Initialise all /datum/sprite_accessory/hair_gradient into an list indexed by gradient-style name
/proc/init_hair_gradients()
	for(var/path in subtypesof(/datum/sprite_accessory/gradient))
		var/datum/sprite_accessory/gradient/gradient = new path()
		if(gradient.gradient_category  & GRADIENT_APPLIES_TO_HAIR)
			GLOB.hair_gradients_list[gradient.name] = gradient
		if(gradient.gradient_category & GRADIENT_APPLIES_TO_FACIAL_HAIR)
			GLOB.facial_hair_gradients_list[gradient.name] = gradient

/// Legacy procs that really should be replaced with proper _INIT macros
/proc/make_datum_reference_lists()
	// I tried to eliminate this proc but I couldn't untangle their init-order interdependencies -Dominion/Cyberboss
	init_sprite_accessories()
	init_hair_gradients()
	init_species_list()
	init_voice_packs()
	init_keybindings()
	init_emote_list() // WHY DOES THIS NEED TO GO HERE? IT JUST INITS DATUMS
	init_interactions()
	init_crafting_recipes()
	init_crafting_recipes_atoms()

/// Inits crafting recipe lists
/proc/init_crafting_recipes(list/crafting_recipes)
	for(var/path in subtypesof(/datum/crafting_recipe))
		if(ispath(path, /datum/crafting_recipe/stack))
			continue
		var/datum/crafting_recipe/recipe = new path()
		var/is_cooking = (recipe.category in GLOB.crafting_category_food)
		recipe.reqs = sort_list(recipe.reqs, GLOBAL_PROC_REF(cmp_crafting_req_priority))
		if(recipe.name != "" && recipe.result)
			if(is_cooking)
				GLOB.cooking_recipes += recipe
			else
				GLOB.crafting_recipes += recipe

	var/static/list/global_stack_recipes = list(
		/obj/item/stack/sheet/glass = GLOB.glass_recipes,
		/obj/item/stack/sheet/plasmaglass = GLOB.pglass_recipes,
		/obj/item/stack/sheet/rglass = GLOB.reinforced_glass_recipes,
		/obj/item/stack/sheet/plasmarglass = GLOB.prglass_recipes,
		/obj/item/stack/sheet/animalhide/gondola = GLOB.gondola_recipes,
		/obj/item/stack/sheet/animalhide/corgi = GLOB.corgi_recipes,
		/obj/item/stack/sheet/animalhide/monkey = GLOB.monkey_recipes,
		/obj/item/stack/sheet/animalhide/xeno = GLOB.xeno_recipes,
		/obj/item/stack/sheet/leather = GLOB.leather_recipes,
		/obj/item/stack/sheet/sinew = GLOB.sinew_recipes,
		/obj/item/stack/sheet/animalhide/carp = GLOB.carp_recipes,
		/obj/item/stack/sheet/mineral/sandstone = GLOB.sandstone_recipes,
		/obj/item/stack/sheet/mineral/sandbags = GLOB.sandbag_recipes,
		/obj/item/stack/sheet/mineral/diamond = GLOB.diamond_recipes,
		/obj/item/stack/sheet/mineral/uranium = GLOB.uranium_recipes,
		/obj/item/stack/sheet/mineral/plasma = GLOB.plasma_recipes,
		/obj/item/stack/sheet/mineral/gold = GLOB.gold_recipes,
		/obj/item/stack/sheet/mineral/silver = GLOB.silver_recipes,
		/obj/item/stack/sheet/mineral/bananium = GLOB.bananium_recipes,
		/obj/item/stack/sheet/mineral/titanium = GLOB.titanium_recipes,
		/obj/item/stack/sheet/mineral/plastitanium = GLOB.plastitanium_recipes,
		/obj/item/stack/sheet/mineral/snow = GLOB.snow_recipes,
		/obj/item/stack/sheet/mineral/adamantine = GLOB.adamantine_recipes,
		/obj/item/stack/sheet/mineral/abductor = GLOB.abductor_recipes,
		/obj/item/stack/sheet/iron = GLOB.metal_recipes,
		/obj/item/stack/sheet/plasteel = GLOB.plasteel_recipes,
		/obj/item/stack/sheet/mineral/wood = GLOB.wood_recipes,
		/obj/item/stack/sheet/mineral/bamboo = GLOB.bamboo_recipes,
		/obj/item/stack/sheet/cloth = GLOB.cloth_recipes,
		/obj/item/stack/sheet/durathread = GLOB.durathread_recipes,
		/obj/item/stack/sheet/cardboard = GLOB.cardboard_recipes,
		/obj/item/stack/sheet/bronze = GLOB.bronze_recipes,
		/obj/item/stack/sheet/plastic = GLOB.plastic_recipes,
		/obj/item/stack/ore/glass = GLOB.sand_recipes,
		/obj/item/stack/rods = GLOB.rod_recipes,
		/obj/item/stack/sheet/runed_metal = GLOB.runed_metal_recipes,
	)

	for(var/stack in global_stack_recipes)
		for(var/stack_recipe in global_stack_recipes[stack])
			if(istype(stack_recipe, /datum/stack_recipe_list))
				var/datum/stack_recipe_list/stack_recipe_list = stack_recipe
				for(var/nested_recipe in stack_recipe_list.recipes)
					if(!nested_recipe)
						continue
					var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, nested_recipe)
					if(recipe.name != "" && recipe.result)
						GLOB.crafting_recipes += recipe
			else
				if(!stack_recipe)
					continue
				var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, stack_recipe)
				if(recipe.name != "" && recipe.result)
					GLOB.crafting_recipes += recipe

	var/list/material_stack_recipes = list(
		SSmaterials.base_stack_recipes,
		SSmaterials.rigid_stack_recipes,
	)

	for(var/list/recipe_list in material_stack_recipes)
		for(var/stack_recipe in recipe_list)
			var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(/obj/item/stack/sheet/iron, stack_recipe)
			recipe.steps = list("Use different materials in hand to make an item of that material")
			GLOB.crafting_recipes += recipe

/// Inits atoms used in crafting recipes
/proc/init_crafting_recipes_atoms()
	var/list/recipe_lists = list(
		GLOB.crafting_recipes,
		GLOB.cooking_recipes,
	)
	var/list/atom_lists = list(
		GLOB.crafting_recipes_atoms,
		GLOB.cooking_recipes_atoms,
	)

	for(var/list_index in 1 to length(recipe_lists))
		var/list/recipe_list = recipe_lists[list_index]
		var/list/atom_list = atom_lists[list_index]
		for(var/datum/crafting_recipe/recipe as anything in recipe_list)
			// Result
			atom_list |= recipe.result
			// Ingredients
			for(var/atom/req_atom as anything in recipe.reqs)
				atom_list |= req_atom
			// Catalysts
			for(var/atom/req_atom as anything in recipe.chem_catalysts)
				atom_list |= req_atom
			// Reaction data - required container
			if(recipe.reaction)
				var/required_container = initial(recipe.reaction.required_container)
				if(required_container)
					atom_list |= required_container
			// Tools
			for(var/atom/req_atom as anything in recipe.tool_paths)
				atom_list |= req_atom
			// Machinery
			for(var/atom/req_atom as anything in recipe.machinery)
				atom_list |= req_atom
			// Structures
			for(var/atom/req_atom as anything in recipe.structures)
				atom_list |= req_atom

//creates every voice pack
/proc/init_voice_packs()
	for(var/datum/voice/voice_pack as anything in init_subtypes(/datum/voice))
		if(!voice_pack.name)
			continue
		GLOB.voice_packs[voice_pack.name] = voice_pack
		GLOB.voice_packs_by_type[voice_pack.type] = voice_pack

//creates every interaction datum and adds them to the correct lists
/proc/init_interactions()
	for(var/datum/interaction/interaction as anything in init_subtypes(/datum/interaction))
		//probably an abstract type
		if(!interaction.name)
			continue
		GLOB.interactions[interaction.type] = interaction
		if(interaction.category)
			LAZYADDASSOC(GLOB.interactions_by_category[interaction.category], interaction.type, interaction)
	sort_list(GLOB.interactions_by_category, GLOBAL_PROC_REF(cmp_interaction_categories_asc))

/proc/cmp_interaction_categories_asc(category_a, category_b)
	return GLOB.interaction_categories.Find(category_a) - GLOB.interaction_categories.Find(category_b)

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

//returns a list of paths to every subtype of prototype (excluding prototype)
//if no list/L is provided, one is created.
/proc/init_paths(prototype, list/L)
	if(!istype(L))
		L = list()
		for(var/path in subtypesof(prototype))
			L+= path
		return L

/// Functions like init_subtypes, but uses the subtype's path as a key for easy access
/proc/init_subtypes_w_path_keys(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path as anything in subtypesof(prototype))
		L[path] = new path()
	return L

/**
 * Checks if that loc and dir has an item on the wall
**/
// Wall mounted machinery which are visually on the wall.
GLOBAL_LIST_INIT(wallitems_interior, typecacheof(list(
	/obj/item/radio/intercom,
	/obj/item/storage/secure/safe,
	/obj/machinery/airalarm,
	/obj/machinery/bluespace_vendor,
	/obj/machinery/button,
	/obj/machinery/computer/security/telescreen,
	/obj/machinery/computer/security/telescreen/entertainment,
	/obj/machinery/defibrillator_mount,
	/obj/machinery/firealarm,
	/obj/machinery/flasher,
	/obj/machinery/keycard_auth,
	/obj/machinery/light_switch,
	/obj/machinery/newscaster,
	/obj/machinery/power/apc,
	/obj/machinery/requests_console,
	/obj/machinery/status_display,
	/obj/machinery/ticket_machine,
	/obj/machinery/turretid,
	/obj/machinery/barsign,
	/obj/structure/extinguisher_cabinet,
	/obj/structure/fireaxecabinet,
	/obj/structure/mirror,
	/obj/structure/noticeboard,
	/obj/structure/reagent_dispensers/wall,
	/obj/structure/sign,
	/obj/structure/sign/picture_frame,
	/obj/structure/sign/poster/contraband/random,
	/obj/structure/sign/poster/official/random,
	/obj/structure/sign/poster/random,
	/obj/structure/urinal,
)))

// Wall mounted machinery which are visually coming out of the wall.
// These do not conflict with machinery which are visually placed on the wall.
GLOBAL_LIST_INIT(wallitems_exterior, typecacheof(list(
	/obj/machinery/camera,
	/obj/machinery/light,
	/obj/structure/camera_assembly,
	/obj/structure/light_construct,
)))
