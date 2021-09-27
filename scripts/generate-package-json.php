<?php

if (empty($_SERVER['argv'][1])) {
    echo sprintf("%s needs prefix as argument", $_SERVER['argv'][0]), PHP_EOL;
    exit(1);
}

$prefix = $_SERVER['argv'][1];

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
    ];
}

echo json_encode($packages, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
