################################################################################
#
# snes9x
#
################################################################################

SNES9X_VERSION = local
SNES9X_SITE = /home/oscarklee/dev/snes9x
SNES9X_SITE_METHOD = local
SNES9X_LICENSE = Custom
SNES9X_LICENSE_FILES = LICENSE
SNES9X_DEPENDENCIES = sdl2 sdl2_image zlib libpng alsa-lib libcurl
SNES9X_AUTORECONF = YES

# snes9x uses autotools in the sdl subdirectory
SNES9X_SUBDIR = sdl

SNES9X_CONF_OPTS = \
	--disable-netplay \
	--disable-debugger \
	--enable-zip \
	--enable-gzip \
	--enable-screenshot \
	--enable-neon

SNES9X_CONF_ENV = \
	CXXFLAGS="$(TARGET_CXXFLAGS) -DUNZIP_SUPPORT -DZLIB"

# Create patch to add menu objects to Makefile
define SNES9X_ADD_MENU_OBJECTS
	sed -i 's|OBJECTS    = \(.*\) logger.o sdlmain.o sdlvideo.o sdlinput.o|OBJECTS    = \1 menu/MenuCarousel.o menu/BoxartManager.o menu/StringMatcher.o logger.o sdlmain.o sdlvideo.o sdlinput.o|' \
		$(@D)/sdl/Makefile.in
	sed -i 's|-lm `pkg-config --libs sdl2 zlib libpng`|-lm `pkg-config --libs sdl2 zlib libpng SDL2_image` -lcurl -lz|' \
		$(@D)/sdl/Makefile.in
endef

SNES9X_PRE_CONFIGURE_HOOKS += SNES9X_ADD_MENU_OBJECTS

# Custom install command since there's no install target in Makefile
define SNES9X_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/sdl/snes9x $(TARGET_DIR)/usr/bin/snes9x
	mkdir -p $(TARGET_DIR)/root/.snes9x/{bios,cheat,log,patch,sat,screenshot,spc}
endef

$(eval $(autotools-package))
