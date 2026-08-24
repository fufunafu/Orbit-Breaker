class_name CosmeticCatalog
extends RefCounted

# `hint` is the written unlock condition shown on locked loadout options.
const SHIP_COLORS := [
	{"id": "ion", "name": "ION", "color": Color("e9feff"), "accent": Color("72faff"), "hint": ""},
	{"id": "nova", "name": "NOVA", "color": Color("fff0fb"), "accent": Color("ff64dc"), "hint": "10 PERFECT LANDINGS"},
	{"id": "solar", "name": "SOLAR", "color": Color("fff7d6"), "accent": Color("ffd166"), "hint": "REACH A 5X COMBO"},
]
const TRAILS := [
	{"id": "ion", "name": "ION", "color": Color("6ffcff"), "hint": ""},
	{"id": "plasma", "name": "PLASMA", "color": Color("ff5bd8"), "hint": "10 PERFECT LANDINGS"},
	{"id": "comet", "name": "COMET", "color": Color("ffd166"), "hint": "SCORE 25 IN ONE RUN"},
]
const PLANET_THEMES := [
	{"id": "cosmic", "name": "COSMIC", "zone": 0, "hint": ""},
	{"id": "nebula", "name": "NOVA DRIFT", "zone": 1, "hint": "25 TOTAL LANDINGS"},
	{"id": "sunforge", "name": "SUNFORGE", "zone": 2, "hint": "50 TOTAL LANDINGS"},
]
const CATEGORY_TITLES := {"ship": "SHIP", "trail": "TRAIL", "theme": "PLANETS"}


static func refresh_unlocks(profile: Dictionary) -> PackedStringArray:
	var newly_unlocked := PackedStringArray()
	_unlock_if(profile, "unlocked_ship_colors", "nova", int(profile.total_perfect_landings) >= 10, newly_unlocked)
	_unlock_if(profile, "unlocked_ship_colors", "solar", int(profile.highest_combo) >= 5, newly_unlocked)
	_unlock_if(profile, "unlocked_trails", "plasma", int(profile.total_perfect_landings) >= 10, newly_unlocked)
	_unlock_if(profile, "unlocked_trails", "comet", int(profile.best_score) >= 25, newly_unlocked)
	_unlock_if(profile, "unlocked_planet_themes", "nebula", int(profile.total_landings) >= 25, newly_unlocked)
	_unlock_if(profile, "unlocked_planet_themes", "sunforge", int(profile.total_landings) >= 50, newly_unlocked)
	return newly_unlocked


static func _unlock_if(profile: Dictionary, key: String, id: String, condition: bool, newly_unlocked: PackedStringArray) -> void:
	if not condition:
		return
	var values: PackedStringArray = profile[key]
	if not values.has(id):
		values.append(id)
		profile[key] = values
		newly_unlocked.append(id)


## Groups newly unlocked ids by category using their display names, for example
## {"ship": ["SOLAR"], "trail": ["COMET"]}. Unknown ids are ignored.
static func describe_unlocks(ids: PackedStringArray) -> Dictionary:
	var grouped := {}
	for category_items in [["ship", SHIP_COLORS], ["trail", TRAILS], ["theme", PLANET_THEMES]]:
		var category := String(category_items[0])
		var names := PackedStringArray()
		for item in category_items[1]:
			if ids.has(String(item.id)) and not String(item.hint).is_empty():
				names.append(String(item.name))
		if not names.is_empty():
			grouped[category] = names
	return grouped


static func find_item(items: Array, id: String) -> Dictionary:
	for item in items:
		if String(item.id) == id:
			return item
	return items[0]


static func next_unlocked(items: Array, unlocked: PackedStringArray, current_id: String) -> Dictionary:
	var available: Array[Dictionary] = []
	for item in items:
		if unlocked.has(String(item.id)):
			available.append(item)
	if available.is_empty():
		return items[0]
	for index in available.size():
		if String(available[index].id) == current_id:
			return available[(index + 1) % available.size()]
	return available[0]
