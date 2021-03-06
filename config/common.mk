PRODUCT_BRAND ?= UltraAOST
AOST_BUILD_DATE := $(shell date -u +%Y%m%d-%H%M)

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    keyguard.no_require_sim=true

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),user)
# Thank you, please drive thru!
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.sys.dun.override=0
endif

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

ifeq ($(BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE),)
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/data/cache
else
  PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.device.cache_dir=/cache
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/aost/prebuilts/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/aost/prebuilts/bin/sysinit:system/bin/sysinit

# Backup Tool
PRODUCT_COPY_FILES += \
     vendor/aost/prebuilts/bin/backuptool.sh:system/bin/backuptool.sh \
     vendor/aost/prebuilts/bin/backuptool.functions:system/bin/backuptool.functions \
     vendor/aost/prebuilts/bin/blacklist:system/addon.d/blacklist \
     vendor/aost/prebuilts/bin/whitelist:system/addon.d/whitelist

# Apns
PRODUCT_COPY_FILES += \
    vendor/aost/prebuilts/etc/apns-conf.xml:system/etc/apns-conf.xml

# Extra tools
PRODUCT_PACKAGES += \
    7z \
    awk \
    bash \
    bzip2 \
    curl \
    gdbserver \
    htop \
    lib7z \
    libsepol \
    micro_bench \
    oprofiled \
    pigz \
    powertop \
    sqlite3 \
    strace \
    unrar \
    unzip \
    vim \
    wget \
    zip

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.exfat \
    fsck.ntfs \
    mke2fs \
    mkfs.exfat \
    mkfs.ntfs \
    mount.ntfs

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# UAOST Custom packages
PRODUCT_PACKAGES += \
    LatinIME \
    Phonograph \
    messaging \
    Jelly \
    SoundRecorder \
    Stk \
    WallpaperPicker \
    LiveWallpapersPicker \
    Gallery2 \
    LivePicker \
    TimeZoneUpdater

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# Media
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    media.recorder.show_manufacturer_and_model=true

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PACKAGES += \
    procmem \
    procrank
endif

# Prebuilt Packages
PRODUCT_PACKAGES += \
    MarkupGoogle

# Fonts
PRODUCT_COPY_FILES += \
    vendor/aost/prebuilts/fonts/GoogleSans-Regular.ttf:system/fonts/GoogleSans-Regular.ttf \
    vendor/aost/prebuilts/fonts/GoogleSans-Medium.ttf:system/fonts/GoogleSans-Medium.ttf \
    vendor/aost/prebuilts/fonts/GoogleSans-MediumItalic.ttf:system/fonts/GoogleSans-MediumItalic.ttf \
    vendor/aost/prebuilts/fonts/GoogleSans-Italic.ttf:system/fonts/GoogleSans-Italic.ttf \
    vendor/aost/prebuilts/fonts/GoogleSans-Bold.ttf:system/fonts/GoogleSans-Bold.ttf \
    vendor/aost/prebuilts/fonts/GoogleSans-BoldItalic.ttf:system/fonts/GoogleSans-BoldItalic.ttf


ifneq ($(filter arm64,$(TARGET_ARCH)),)
PRODUCT_COPY_FILES += \
        vendor/aost/prebuilts/lib/libsketchology_native.so:system/lib/libsketchology_native.so \
        vendor/aost/prebuilts/lib/libjni_latinime.so:system/lib/libjni_latinime.so
else
PRODUCT_COPY_FILES += \
        vendor/aost/prebuilts/lib64/libsketchology_native.so:system/lib64/libsketchology_native.so \
        vendor/aost/prebuilts/lib64/libjni_latinime.so:system/lib64/libjni_latinime.so
endif

# Include package overlays
DEVICE_PACKAGE_OVERLAYS += \
    vendor/aost/overlay/common/

BUILD_RRO_SYSTEM_PACKAGE := $(TOP)/vendor/aost/build/core/system_rro.mk

#Themes and Accent colors
include vendor/aost/themes/config.mk

PRODUCT_VERSION_MAJOR = 1
PRODUCT_VERSION_MINOR = 0

# Set AOST_BUILDTYPE from the env RELEASE_TYPE

ifndef AOST_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "AOST_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^AOST_||g')
        AOST_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(AOST_BUILDTYPE)),)
    AOST_BUILDTYPE :=
endif

ifdef AOST_BUILDTYPE
    ifneq ($(AOST_BUILDTYPE), SNAPSHOT)
        ifdef AOST_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            AOST_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from AOST_EXTRAVERSION
            AOST_EXTRAVERSION := $(shell echo $(AOST_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to AOST_EXTRAVERSION
            AOST_EXTRAVERSION := -$(AOST_EXTRAVERSION)
        endif
    else
        ifndef AOST_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            AOST_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from AOST_EXTRAVERSION
            AOST_EXTRAVERSION := $(shell echo $(AOST_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to AOST_EXTRAVERSION
            AOST_EXTRAVERSION := -$(AOST_EXTRAVERSION)
        endif
    endif
else
    # If AOST_BUILDTYPE is not defined, set to UNOFFICIAL
    AOST_BUILDTYPE := UNOFFICIAL
    AOST_EXTRAVERSION :=
endif

ifeq ($(AOST_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        AOST_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(AOST_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(AOST_BUILDTYPE)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            ifeq ($(AOST_VERSION_MAINTENANCE),0)
                AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(AOST_BUILDTYPE)
            else
                AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(AOST_BUILDTYPE)
            endif
        else
            AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(AOST_BUILDTYPE)
        endif
    endif
else
    ifeq ($(AOST_VERSION_MAINTENANCE),0)
        ifeq ($(AOST_BUILDTYPE), UNOFFICIAL)
            AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d_%H%M%S)-$(AOST_BUILDTYPE)
        else
            AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(AOST_BUILDTYPE)-$(AOST_BUILDTYPE)
        endif
    else
        ifeq ($(AOST_BUILDTYPE), UNOFFICIAL)
            AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d_%H%M%S)-$(AOST_BUILDTYPE)
        else
            AOST_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(AOST_BUILDTYPE)
        endif
    endif
endif

$(call prepend-product-if-exists, vendor/extra/product.mk)

PRODUCT_PROPERTY_OVERRIDES += \
  org.aost.version=$(AOST_VERSION) \
  org.aost.build_type=$(AOST_BUILDTYPE) \
  org.aost.build_date=$(AOST_BUILD_DATE)
