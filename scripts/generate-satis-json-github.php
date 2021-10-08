<?php

class SatisJsonGenerator
{
    private $baseUrl;
    private $githubToken;

    private $repositories = [];

    public function __construct(string $baseUrl, object $githubToken)
    {
        $this->baseUrl = $baseUrl;
        $this->githubToken = $githubToken;
    }

    public function generate(): void
    {
        $this->collectGithubUrls();

        $template = [
            'name' => 'magefm/repository',
            'homepage' => $this->baseUrl,
            'output-dir' => 'repository',
            'archive' => [
                'directory' => 'dist',
                'rearchive' => true,
                'skip-dev' => true,
            ],
            'minimum-stability' => 'stable',
            'require-all' => true,
            'require-dependencies' => false,
            'require-dev-dependencies' => false,
            'repositories' => $this->repositories,
        ];

        echo json_encode($template, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    }

    private function collectGithubUrls(): void
    {
        $githubToken = base64_encode(sprintf('%s:%s', $this->githubToken->user, $this->githubToken->token));

        $context = stream_context_create([
            'http' => [
                'header' => sprintf(
                    "User-Agent: magefm/repository-generator\r\nAccept: */*\r\nAuthorization: Basic %s\r\n",
                    $githubToken
                ),
            ],
        ]);

        $nextPage = 1;

        do {
            $content = file_get_contents(sprintf('https://api.github.com/orgs/%s/repos?page=%d', $this->githubToken->organization, $nextPage), null, $context);

            if ($content === false) {
                fwrite(STDERR, sprintf('Error downloading page %d', $nextPage) . PHP_EOL);
                exit(1);
            }

            $nextPage = $this->extractNextPage($http_response_header);
            $repositories = json_decode($content);

            foreach ($repositories as $repo) {
                $this->repositories[] = [
                    'type' => 'vcs',
                    'url' => $repo->ssh_url,
                ];
            }
        } while ($nextPage !== null);
    }

    private function extractNextPage(array $headers): ?int
    {
        foreach ($headers as $header) {
            if (!preg_match('/^Link\: (.*)/', $header, $matches)) {
                continue;
            }

            if (empty($matches[1])) {
                continue;
            }

            $content = $matches[1];
            $matchStatus = preg_match_all('#<([^>]+)page=(\d+)>; rel="([^"]+)"#', $content, $matches);

            if (!$matchStatus || $matchStatus < 1) {
                return false;
            }

            foreach ($matches[3] as $key => $value) {
                if ($value === 'next' && isset($matches[2][$key])) {
                    return (int) $matches[2][$key];
                }
            }
        }

        return null;
    }
}

$config = json_decode(file_get_contents('config.json'));
$githubToken = json_decode(file_get_contents('github-token.json'));

(new SatisJsonGenerator($config->baseUrl, $githubToken))->generate();
