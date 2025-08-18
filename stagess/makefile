.PHONY: main tutorial

OUT_DIR := build
ZIP := zip -r

main: build/stagess.zip
tutorial: build/tutoriel-stagess.zip

build/%.zip:
	flutter build web --base-href=/$*/ 
	mv $(OUT_DIR)/web $(OUT_DIR)/$*
	cd $(OUT_DIR) && $(ZIP) $*.zip $*
