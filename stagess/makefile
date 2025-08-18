.PHONY: main tutorial

OUT_DIR := build
ZIP := zip -r

all: main tutorial

# Generic rule: build/NAME.zip with DEV_DB flag
.FORCE:
build/%.zip: .FORCE
	rm -rf $(OUT_DIR)/$*
	flutter build web --base-href=/$*/ \
		--dart-define=STAGESS_WEB_USE_LOCAL_DB=false \
		--dart-define=STAGESS_WEB_USE_SSL=false \
		--dart-define=STAGESS_WEB_USE_DEV_DB=$(DEV_DB)
	mv $(OUT_DIR)/web $(OUT_DIR)/$*
	cd $(OUT_DIR) && $(ZIP) $*.zip $*

# Named targets
main: DEV_DB=false
main: build/stagess.zip

tutorial: DEV_DB=true
tutorial: build/tutoriel-stagess.zip
