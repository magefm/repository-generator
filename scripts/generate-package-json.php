<?php

if (empty($_SERVER['argv'][1])) {
    echo sprintf("%s needs prefix as argument", $_SERVER['argv'][0]), PHP_EOL;
    exit(1);
}

$config = json_decode(file_get_contents('config.json'));

$prefix = $_SERVER['argv'][1];
$prefix = rtrim($prefix, '/');

$directory = new RecursiveDirectoryIterator($prefix);
$iterator = new RecursiveIteratorIterator($directory);
$regex = new RegexIterator($iterator, '/^.+\/composer\.json$/i', RecursiveRegexIterator::GET_MATCH);
$packages = [];

foreach ($regex as $dir) {
    $path = $dir[0];
    $pathNormalized = substr($path, strlen($prefix) + 1);

    // @TODO ignore magento/magento2ce
    // temporarily: ignore root composer.json
    if ($prefix === dirname($path)) {
        continue;
    }

    if (substr($pathNormalized, 0, 4) === sprintf('dev/', $prefix)) {
        continue;
    }

    if (strpos($path, '/Test/Unit/_files/') !== false) {
        continue;
    }

    if (strpos($path, '/Test/Mftf/') !== false) {
        continue;
    }

    $json = json_decode(file_get_contents($path), true);

    if (!isset($json['name'])) {
        echo "Package at '$path' has no name", PHP_EOL;
        exit(1);
    }

    $packages[] = [
        'name' => $json['name'],
        'path' => dirname($pathNormalized),
        'repository' => getRepository($json['name']),
    ];
}

echo json_encode($packages, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);

function getRepository(string $name): string {
    global $config;

    $parts = explode('/', $name);

    if (empty($parts[1])) {
        throw new \Exception(sprintf('cannot determine repository for %s', $name));
    }

    return sprintf($config->githubRemoteTemplate, $parts[1]);
}
