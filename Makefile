VERSION := 2.4.0

clean:
	@rm -rf satis.json
	@rm -rf repository

.PHONY: packages/magento2/
packages/magento2/: splitsh-lite/splitsh-lite sources/magento2/
	@mkdir -p packages/magento2/
	@bash scripts/split-magento2.sh "$(VERSION)"

repository: repository/

repository/: satis.json
	@php satis/bin/satis build satis.json

satis/:
	@composer create-project composer/satis:dev-main satis/

satis.json: satis/
	@echo Generating satis.json
	@php scripts/generate-satis-json.php > satis.json

sources/magento2/:
	@mkdir -p sources/
	@git clone https://github.com/magento/magento2.git sources/magento2

splitsh-lite/:
	@git clone https://github.com/magefm/splitsh-lite.git

splitsh-lite/splitsh-lite: splitsh-lite/
	@(cd splitsh-lite; make build)
