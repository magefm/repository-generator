<?php

class SatisJsonGenerator
{
    private $baseUrl;

    private $repositories = [];
    private $require = [];

    public function __construct(string $baseUrl)
    {
        $this->baseUrl = $baseUrl;
    }

    public function generate(): void
    {
        $this->collectMagento2Packages();
        $this->collectSecurityPackages();

        $template = [
            'name' => 'magefm/repository',
            'homepage' => $this->baseUrl,
            'output-dir' => 'repository',
            'archive' => [
                'directory' => 'dist',
                'rearchive' => true,
                'skip-dev' => true,
            ],
            'require-dev-dependencies' => false,
            'require' => $this->require,
            'repositories' => $this->repositories,
        ];
        
        echo json_encode($template, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    }

    private function collectMagento2Packages(): void
    {
        $folders = glob('packages/magento2/*/*');

        foreach ($folders as $folder) {
            $this->require[$this->extractComposerNameFromPath($folder)] = '*';
            $this->repositories[] = [
                'type' => 'vcs',
                'url' => sprintf('%s/%s', getcwd(), $folder),
            ];
        }
    }

    private function collectSecurityPackages(): void
    {
        $folders = glob('packages/security-package/*/*');

        foreach ($folders as $folder) {
            $this->require[$this->extractComposerNameFromPath($folder)] = '*';
            $this->repositories[] = [
                'type' => 'vcs',
                'url' => sprintf('%s/%s', getcwd(), $folder),
            ];
        }
    }

    private function extractComposerNameFromPath(string $path): string
    {
        $name = rtrim($path, '/');
        $name = explode('/', $name);
        $name = implode('/', array_reverse([array_pop($name), array_pop($name)]));
        return $name;
    }
}

$config = json_decode(file_get_contents('config.json'));

(new SatisJsonGenerator($config->baseUrl))->generate();
