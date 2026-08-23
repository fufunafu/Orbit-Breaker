#!/bin/bash

set -euo pipefail

export_root="${1:-build/ios}"
product_name="${2:-Orbit Breaker}"
app_source_dir="${export_root}/${product_name}"
project_file="${export_root}/${product_name}.xcodeproj/project.pbxproj"
entitlements_file="${app_source_dir}/${product_name}.entitlements"
info_file="${app_source_dir}/${product_name}-Info.plist"

require_file() {
	if [ ! -f "$1" ]; then
		echo "Missing exported file: $1" >&2
		exit 1
	fi
}

remove_empty_key() {
	plist_file="$1"
	plist_key="$2"
	if /usr/libexec/PlistBuddy -c "Print :${plist_key}" "$plist_file" >/dev/null 2>&1; then
		plist_value="$(/usr/libexec/PlistBuddy -c "Print :${plist_key}" "$plist_file")"
		if [ -z "$plist_value" ]; then
			/usr/libexec/PlistBuddy -c "Delete :${plist_key}" "$plist_file"
		fi
	fi
}

require_file "$project_file"
require_file "$entitlements_file"
require_file "$info_file"

# Godot 4.7.2 writes the NS*UsageDescription keys unconditionally from its Info.plist
# template, so the empty strings from the preset must be removed. Empty purpose
# strings are invalid and do not describe this app's actual capabilities.
remove_empty_key "$info_file" "NSCameraUsageDescription"
remove_empty_key "$info_file" "NSMicrophoneUsageDescription"
remove_empty_key "$info_file" "NSPhotoLibraryUsageDescription"

plutil -lint "$entitlements_file" "$info_file" >/dev/null

# The preset sets entitlements/push_notifications="Disabled"; the exporter must not
# have written an aps-environment entitlement at all.
if /usr/libexec/PlistBuddy -c 'Print :aps-environment' "$entitlements_file" >/dev/null 2>&1; then
	echo "Unexpected aps-environment entitlement; set entitlements/push_notifications=\"Disabled\" in the preset." >&2
	exit 1
fi

if grep -q 'CODE_SIGN_IDENTITY = "Apple Distribution";' "$project_file"; then
	echo "The exported Xcode project hard-codes Apple Distribution signing." >&2
	exit 1
fi

# Every build configuration must carry the automatic development identity, not just Debug.
configuration_count="$(grep -c 'isa = XCBuildConfiguration;' "$project_file" || true)"
identity_count="$(grep -c 'CODE_SIGN_IDENTITY = "Apple Development";' "$project_file" || true)"
if [ "$configuration_count" -eq 0 ] || [ "$identity_count" -ne "$configuration_count" ]; then
	echo "Expected ${configuration_count} build configurations with Apple Development signing, found ${identity_count}." >&2
	exit 1
fi

if [ "$(/usr/libexec/PlistBuddy -c 'Print :com.apple.developer.game-center' "$entitlements_file")" != "true" ]; then
	echo "Game Center entitlement is missing." >&2
	exit 1
fi

# Both keys are required before iOS shows the app's Documents folder in Files.
for files_key in LSSupportsOpeningDocumentsInPlace UIFileSharingEnabled; do
	if [ "$(/usr/libexec/PlistBuddy -c "Print :${files_key}" "$info_file" 2>/dev/null || true)" != "true" ]; then
		echo "Files app document access is incomplete: ${files_key} must be true." >&2
		exit 1
	fi
done

if ! grep -q 'IPHONEOS_DEPLOYMENT_TARGET = 17.0;' "$project_file"; then
	echo "The exported Xcode project does not target iOS 17.0." >&2
	exit 1
fi

for framework_name in GodotApplePluginsGameCenter SwiftGodotRuntime; do
	if ! grep -q "${framework_name}.xcframework" "$project_file"; then
		echo "${framework_name}.xcframework is not referenced by the Xcode project." >&2
		exit 1
	fi
done

game_center_binary="${app_source_dir}/dylibs/addons/GodotApplePluginsGameCenter/bin/GodotApplePluginsGameCenter.xcframework/ios-arm64/GodotApplePluginsGameCenter.framework/GodotApplePluginsGameCenter"
runtime_binary="${app_source_dir}/dylibs/addons/GodotApplePluginsRuntime/bin/SwiftGodotRuntime.xcframework/ios-arm64/SwiftGodotRuntime.framework/SwiftGodotRuntime"

for framework_binary in "$game_center_binary" "$runtime_binary"; do
	require_file "$framework_binary"
	build_info="$(xcrun vtool -show-build "$framework_binary")"
	if ! printf '%s\n' "$build_info" | grep -q 'minos 17.0'; then
		echo "Framework deployment target is not iOS 17.0: $framework_binary" >&2
		exit 1
	fi
done

echo "ORBIT_BREAKER_IOS_EXPORT_READY"
