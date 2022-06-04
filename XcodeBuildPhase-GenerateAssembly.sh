# Generates assembly for the selected architecture (Mac / iDevice / Simulator)
# Paste this into an Xcode Run Script build phase.

# Target's subfolder in project.
targetRoot="${SRCROOT}/${TARGET_NAME}"

# Dump the Xcode env to a file.
#printenv | sort > "${targetRoot}/xcode.${ACTION}.${TARGET_NAME}.${PLATFORM_NAME}.${CONFIGURATION}-env.sh"

# Generate assembly for target's Swift sources.
"${HOME}/bin/swift2asm" -P "${PLATFORM_FAMILY_NAME}" -A "${PLATFORM_PREFERRED_ARCH}" -V "${SDK_VERSION}" -B "${SWIFT_OBJC_BRIDGING_HEADER}" -C "${IS_MACCATALYST}" "${targetRoot}"

