#!/bin/bash
#
#   swift2asm
#   ~~~~~~~~~
#
#   @(#)Compiles Swift sources to assembly
#
#   Project:            Developer Tools
#
#   File encoding:      UTF-8
#
#   Created 2021-03-22: Ulrich Singer
#


set -u
umask 022

self=$(basename "$0")


Usage ()
{
    what "$0" >&2
    cat <<___ >&2
Usage: ${self} [-A <architecture>] [-P <platform>] [-V <version>]
            [-B <objc-bridging-header>] [-C <is-mac-catalyst>]
            [-H <header-search-paths>]
            <file-or-folder> ...

    <architecture> : arm64 (default), x86_64.
    <platform>     : ios (default), mac, tv, watch.
    <version>      : <number>.<digit>, e.g. 14.4
___

    exit 1

}   # Usage


archArg='arm'
platArg='iOS'
versArg='14.4'
objcArg=
hdrsArg=
isMacCatalyst=
while getopts 'A:B:C:H:P:V:X' opt
do
    case $opt in
    (X)
        set -x
        ;;
    (A)
        archArg=$OPTARG
        ;;
    (B)
        objcArg=$OPTARG
        ;;
    (C)
        isMacCatalyst=$OPTARG
        ;;
    (H)
        hdrsArg=$OPTARG
        ;;
    (P)
        platArg=$OPTARG
        ;;
    (V)
        versArg=$OPTARG
        ;;
    (*)
        Usage
        ;;
    esac
done
shift $((OPTIND - 1))


case "$archArg" in
(arm|arm64)
    archVal='arm64'
    ;;
(x86|x86_64)
    archVal='x86_64'
    ;;
(*)
    echo "${self}: Invalid architecture '${archArg}'.  Stop." >&2
    Usage
    ;;
esac

simPlat=
[ "$archVal" != 'arm64' ] && simPlat='-simulator'
case "$platArg" in
(ios|iOS)
    platKey='iOS'
    [ "$archVal" != 'arm64' ] && platKey="Simulator - ${platKey}"
    platLwr='ios'
    ;;
(mac|macOS)
    platKey='macOS'
    platLwr='macos'
    simPlat=
    ;;
(tv|tvOS)
    platKey='tvOS'
    [ "$archVal" != 'arm64' ] && platKey="Simulator - ${platKey}"
    platLwr='tvos'
    ;;
(watch|watchOS)
    platKey='watchOS'
    [ "$archVal" != 'arm64' ] && platKey="Simulator - ${platKey}"
    platLwr='watchos'
    ;;
(*)
    echo "${self}: Invalid platform '${platArg}'.  Stop." >&2
    Usage
    ;;
esac

versVal=$versArg

target3="${archVal}-apple-${platLwr}${versVal}${simPlat}"
# Mac Catalyst has an irregular target triple.
[[ "${isMacCatalyst}" = 'YES' ]] && target3=x86_64-apple-ios13.1-macabi

sdkName=$(xcodebuild -showsdks | sed -Ene 's/^[[:space:]]'"${platKey}"'.* ([^ ]+)$/\1/p' | head -n 1)
sdkPath=$(xcrun --show-sdk-path --sdk "${sdkName}")

# Mac Catalyst framework search path.
macCatalystFraneworkPath="${sdkPath}/System/iOSSupport/System/Library/Frameworks"


optArgs=(-v)
if [ -n "${objcArg}" ]
then
    optArgs+=(-import-objc-header "${objcArg}")
fi
for path in $hdrsArg
do
    optArgs+=(-Xcc "-I${path}")
done

for fsp
do
    if [ -d "${fsp}" ]
    then
        cwd=$(pwd)
        cd "${fsp}" || exit $?
        srcs=()
        ifs=$IFS; IFS=$'\n'
        # shellcheck disable=SC2044
        for src in $(find -Hsx . -type 'f' -name '*.swift')
        do
            srcs+=("${src}")
        done
        IFS=$ifs
        mod=$(basename "${fsp}")
        # swiftc(1) writes this output to stderr?!
        xcrun -sdk "${sdkPath}" swiftc -target "${target3}" \
            -O -S -L /usr/lib/swift -F "${macCatalystFraneworkPath}" \
            "${optArgs[@]}" -working-directory "${fsp}" -module-name "${mod}" \
            "${srcs[@]}" &> "${fsp}/${mod}.s" || exit $?
        cd "${cwd}" || exit $?
    else
        dir=$(dirname "${fsp}")
        src=$(basename "${fsp}")
        out="${src%.swift}.s"
        xcrun -sdk "${sdkPath}" swiftc -target "${target3}" \
            -O -S -L /usr/lib/swift -F "${macCatalystFraneworkPath}" \
            "${optArgs[@]}" -working-directory "${dir}" -o "${out}" "${src}" || exit $?
    fi
done


# ~ swift2asm ~ #
