reftype := "branch"
ref := "2.4"

clean:
	@rm -rf satis.json
	@rm -rf repository

# packages
.PHONY: packages/
packages/: packages/inventory/ packages/magento2/ packages/security-package/

.PHONY: packages/inventory/
packages/inventory/: splitsh-lite/splitsh-lite sources/inventory/
	@mkdir -p packages/inventory/
	@bash scripts/split-inventory.sh "$(reftype)" "$(ref)"

.PHONY: packages/magento2/
packages/magento2/: splitsh-lite/splitsh-lite sources/magento2/
	@mkdir -p packages/magento2/
	@bash scripts/split-magento2.sh "$(reftype)" "$(ref)"

.PHONY: packages/security-package/
packages/security-package/: splitsh-lite/splitsh-lite sources/security-package/
	@mkdir -p packages/security-package/
	@bash scripts/split-security.sh "$(reftype)" "$(ref)"

# repository
repository: repository/

repository/: satis.json
	@COMPOSER_HOME=$(PWD)/satis-composer-home/ php satis/bin/satis build satis.json

satis/:
	@composer create-project composer/satis:dev-main satis/

satis.json: satis/
	@echo Generating satis.json
	@php scripts/generate-satis-json.php > satis.json

# sources
sources/:
	@mkdir -p sources/

sources/inventory/: sources/
	@git clone https://github.com/magento/inventory.git sources/inventory

sources/magento2/: sources/
	@git clone https://github.com/magento/magento2.git sources/magento2

sources/security-package/: sources/
	@git clone https://github.com/magento/security-package.git sources/security-package

# splitsh-lite
splitsh-lite/:
	@git clone https://github.com/magefm/splitsh-lite.git

splitsh-lite/splitsh-lite: splitsh-lite/
	@(cd splitsh-lite; make build)

# splitsh-cache
sources/inventory/.git/splitsh.db: splitsh-cache/inventory.db
	@cp splitsh-cache/inventory.db sources/inventory/.git/splitsh.db

sources/magento2/.git/splitsh.db: splitsh-cache/magento2.db
	@cp splitsh-cache/magento2.db sources/magento2/.git/splitsh.db

sources/security-package/.git/splitsh.db: splitsh-cache/security-package.db
	@cp splitsh-cache/security-package.db sources/security-package/.git/splitsh.db

splitsh-cache/:
	@mkdir splitsh-cache/

splitsh-cache/inventory.db: splitsh-cache/
	@curl https://magefm-splitsh-cache.kassner.com.br/inventory.db.gz | gzip -d > splitsh-cache/inventory.db

splitsh-cache/magento2.db: splitsh-cache/
	@curl https://magefm-splitsh-cache.kassner.com.br/magento2.db.gz | gzip -d > splitsh-cache/magento2.db

splitsh-cache/security-package.db: splitsh-cache/
	@curl https://magefm-splitsh-cache.kassner.com.br/security-package.db.gz | gzip -d > splitsh-cache/security-package.db
