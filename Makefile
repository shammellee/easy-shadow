.PHONY: all clean dev prod $(DEV.CONFIGS) $(PROD.CONFIGS) $(DEV_DEPS) $(PROD_DEPS)

# CONFIG
SHELL        := /bin/bash

DEV.CONFIGS  := dev.config.jade
DEV.CONFIGS  += dev.config.glue
PROD.CONFIGS  = $(DEV.CONFIGS:dev.%=prod.%)
PROJECT_NAME := Easy Shadow

DEV_MODE := false
ifeq ($(firstword $(MAKECMDGOALS)),dev)
# MAKEFLAGS = -j $(words $(DEV_DEPS))
DEV_MODE := true
endif

# TEMPLATES
JADE.CONFIG_FILE_NAME   := config.jade
SPRITE.CONFIG_FILE_NAME := sprite.conf

# COLORS
COLORS.RED     := \033[31m
COLORS.GREEN   := \033[32m
COLORS.YELLOW  := \033[33m
COLORS.BLUE    := \033[34m
COLORS.MAGENTA := \033[35m
COLORS.CYAN    := \033[36m
COLORS.NORMAL  := \033[0m

# PATHS
SRC.DIR                := src
BUILD.DIR              := build
SUPPORT.DIR            := support
SCRIPT.DIR             := $(SUPPORT.DIR)/scripts

SRC.IMG_DIR            := $(SRC.DIR)/img
SRC.JADE_DIR           := $(SRC.DIR)/jade
SRC.JADE_INC_DIR        = $(SRC.JADE_DIR)/inc
SRC.JINJA_DIR          := $(SRC.DIR)/jinja
SRC.SPRITE_DIR          = $(SRC.IMG_DIR)/sprites
SRC.STYLUS_DIR         := $(SRC.DIR)/styl
SRC.STYLUS_INC_DIR      = $(SRC.STYLUS_DIR)/inc
SRC.TEMPLATE_DIR       := $(SRC.DIR)/templates
SRC.JADE_TEMPLATE_DIR   = $(SRC.TEMPLATE_DIR)/jade
SRC.SPRITE_TEMPLATE_DIR = $(SRC.TEMPLATE_DIR)/sprites

BUILD.CSS_NAME         := css
BUILD.IMG_NAME         := img
BUILD.CSS_DIR          := $(BUILD.DIR)/$(BUILD.CSS_NAME)
BUILD.IMG_DIR          := $(BUILD.DIR)/$(BUILD.IMG_NAME)
BUILD.DIRS              = $(BUILD.CSS_DIR)
BUILD.DIRS             += $(BUILD.IMG_DIR)

GENERATED_FILES         = $(BUILD.DIR)
GENERATED_FILES        += $(SRC.STYLUS_INC_DIR)/sprites/*.css
GENERATED_FILES        += $(SRC.JADE_INC_DIR)/$(JADE.CONFIG_FILE_NAME)
GENERATED_FILES        += $(SRC.SPRITE_DIR)/$(SPRITE.CONFIG_FILE_NAME)
GENERATED_FILES        += $(SRC.TEMPLATE_DIR)/**/*.sh

# DEPENDENCIES
DEV_DEPS := dev.dirs
DEV_DEPS += dev.img
DEV_DEPS += dev.config
DEV_DEPS += dev.glue
DEV_DEPS += dev.jade
DEV_DEPS += dev.styl
PROD_DEPS = $(DEV_DEPS:dev.%=prod.%)

# COMMANDS
CLEAN.CMD            = rm $(CLEAN.FLAGS)
CLEAN.FLAGS         := -rf
                  
GLUE.CMD             = glue $(GLUE.FLAGS)
GLUE.FLAGS           = --source $(SRC.SPRITE_DIR)
GLUE.FLAGS          += --css $(BUILD.CSS_DIR)
GLUE.FLAGS          += --img $(BUILD.IMG_DIR)
GLUE.FLAGS          += --project

IMG.CMD              = $(SCRIPT.DIR)/copy_images

JADE.CMD             = jade $(JADE.FLAGS)
JADE.FLAGS          := 

MKDIRS.CMD           = mkdir $(MKDIRS.FLAGS)
MKDIRS.FLAGS        := -p

STYLUS.CMD           = stylus $(STYLUS.FLAGS)
STYLUS.FLAGS        := --use 'nib'
STYLUS.FLAGS        += --include-css

TEMPLATE_ENGINE.CMD  = $(SCRIPT.DIR)/template_engine "$(1)" "$(2)"

# RULES
all: prod

dev: | $(DEV_DEPS)

dev.dirs:
	$(MKDIRS.CMD) $(BUILD.DIRS)

dev.img:
	$(IMG.CMD) $(SRC.IMG_DIR) $(BUILD.IMG_DIR)

dev.config: $(DEV.CONFIGS)

dev.config.jade:
	echo "\
	DEV_MODE='$(DEV_MODE)';\
	PROJECT_NAME='$(PROJECT_NAME)';\
	"\
	> $(SRC.JADE_TEMPLATE_DIR)/$(JADE.CONFIG_FILE_NAME:.jade=.sh)
	$(call TEMPLATE_ENGINE.CMD,$(SRC.JADE_TEMPLATE_DIR)/$(JADE.CONFIG_FILE_NAME),$(SRC.JADE_INC_DIR)/$(JADE.CONFIG_FILE_NAME))

dev.config.glue:
	echo "\
	CSS_DIR='$(SRC.STYLUS_INC_DIR)/sprites';\
	CSS_TEMPLATE='$(SRC.JINJA_DIR)/css.jinja';\
	SRC_DIR='$(SRC.IMG_DIR)/sprites';\
	IMG_DIR_NAME='$(BUILD.IMG_NAME)';\
	"\
	> $(SRC.SPRITE_TEMPLATE_DIR)/global.sh
	$(call TEMPLATE_ENGINE.CMD,$(SRC.SPRITE_TEMPLATE_DIR)/global.conf,$(SRC.SPRITE_DIR)/$(SPRITE.CONFIG_FILE_NAME))

dev.glue:
	$(GLUE.CMD)

dev.jade:
	$(JADE.CMD) --pretty $(SRC.JADE_DIR)/*.jade --out $(BUILD.DIR)

dev.styl:
	$(STYLUS.CMD) $(SRC.STYLUS_DIR) --out $(BUILD.CSS_DIR)

prod: | $(PROD_DEPS)
	@echo -e '$(COLORS.GREEN)Build Complete!$(COLORS.NORMAL)'

prod.dirs:
	@$(MKDIRS.CMD) $(BUILD.DIRS)

prod.img:
	@echo -e '$(COLORS.YELLOW)Copying Images...$(COLORS.NORMAL)'
	@$(IMG.CMD) $(SRC.IMG_DIR) $(BUILD.IMG_DIR)

prod.config: $(PROD.CONFIGS)

prod.config.jade:
	@echo "\
	DEV_MODE='$(DEV_MODE)';\
	PROJECT_NAME='$(PROJECT_NAME)';\
	"\
	> $(SRC.JADE_TEMPLATE_DIR)/$(JADE.CONFIG_FILE_NAME:.jade=.sh)
	@$(call TEMPLATE_ENGINE.CMD,$(SRC.JADE_TEMPLATE_DIR)/$(JADE.CONFIG_FILE_NAME),$(SRC.JADE_INC_DIR)/$(JADE.CONFIG_FILE_NAME))

prod.config.glue:
	@echo "\
	CSS_DIR='$(SRC.STYLUS_INC_DIR)/sprites';\
	CSS_TEMPLATE='$(SRC.JINJA_DIR)/css.jinja';\
	SRC_DIR='$(SRC.IMG_DIR)/sprites';\
	IMG_DIR_NAME='$(BUILD.IMG_NAME)';\
	"\
	> $(SRC.SPRITE_TEMPLATE_DIR)/global.sh
	@$(call TEMPLATE_ENGINE.CMD,$(SRC.SPRITE_TEMPLATE_DIR)/global.conf,$(SRC.SPRITE_DIR)/$(SPRITE.CONFIG_FILE_NAME))

prod.glue:
	@echo -e '$(COLORS.YELLOW)Generating Sprites...$(COLORS.NORMAL)'
	@$(GLUE.CMD) > /dev/null

prod.jade:
	@echo -e '$(COLORS.YELLOW)Compiling Jade...$(COLORS.NORMAL)'
	@$(JADE.CMD) $(SRC.JADE_DIR)/*.jade --out $(BUILD.DIR) > /dev/null

prod.styl:
	@echo -e '$(COLORS.YELLOW)Compiling Stylus...$(COLORS.NORMAL)'
	@$(STYLUS.CMD) --compress $(SRC.STYLUS_DIR) --out $(BUILD.CSS_DIR) > /dev/null

clean:
	@echo -e '$(COLORS.YELLOW)Cleaning Project...$(COLORS.NORMAL)'
	@$(CLEAN.CMD) $(GENERATED_FILES)
	@echo -e '$(COLORS.GREEN)Project Clean!$(COLORS.NORMAL)'
