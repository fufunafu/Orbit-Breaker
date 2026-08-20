class_name DailyChallenge
extends RefCounted


static func utc_date_key(unix_time: int = -1) -> String:
	var timestamp := unix_time if unix_time >= 0 else int(Time.get_unix_time_from_system())
	var date := Time.get_datetime_dict_from_unix_time(timestamp)
	return "%04d-%02d-%02d" % [int(date.year), int(date.month), int(date.day)]


static func seed_for_date(date_key: String) -> int:
	var hash_value: int = 2166136261
	for byte in date_key.to_utf8_buffer():
		hash_value = hash_value ^ int(byte)
		hash_value = int((hash_value * 16777619) & 0x7fffffff)
	return maxi(1, hash_value)
