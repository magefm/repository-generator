# magefm/repository-builder

> **This is a work in progress** and it is not yet functional. Do not use it for production systems.

Tooling to build a composer repository based on a magento2 git repository.

## Usage

1. Clone this repository;
2. Run `make packages/magento2/ reftype=tag ref=2.4.0`;
3. Run `make repository`;
4. Run `php -S 0.0.0.0:8080 -t repository/`;
5. Browse at http://localhost:8080;

## Dependencies

1. In your PATH: `bash`, `composer`, `cut`, `git`, `jq`, `php`;
2. `docker` for building the `splitsh-lite` binary;
