#!/usr/bin/env bun

import { writeFile, mkdir, copyFile } from 'fs/promises';
import { existsSync } from 'fs';
import { join } from 'path';

interface PackageConfig {
  url: string;
  name?: string;
}

const READMES_TO_DOWNLOAD = [
  {
    url: "https://github.com/dfinitiv/mojo-offers/pkgs/npm/mojo-offers",
    name: "mojo-offers"
  },
  {
    url: "https://github.com/dfinitiv/savvy-metadata/pkgs/npm/savvy-metadata",
    name: "savvy-metadata"
  },
  {
    url: "https://github.com/dfinitiv/savvy-media/pkgs/npm/savvy-media",
    name: "savvy-media"
  },
  {
    url: "https://github.com/dfinitiv/savvy-geo/pkgs/npm/savvy-geo",
    name: "savvy-geo"
  },
  {
    url: "https://github.com/dfinitiv/savvy-guides/pkgs/npm/savvy-guides",
    name: "savvy-guides"
  },
  {
    url: "https://github.com/dfinitiv/mojo-users/pkgs/npm/mojo-users",
    name: "mojo-users"
  }
];

const COPY_TO_DIR = '/Users/via/Development/Dfinitiv/dfinitiv-docs/api-client-libraries';

// Additional project directories to copy READMEs to (updated periodically)
const PROJECT_COPY_DIRS = [
  '/Users/via/Development/Dfinitiv/mojo-browser-extension/docs/api-clients',
  '/Users/via/Development/Dfinitiv/mojo-offers/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-admin/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-analytics/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-chat/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-guides/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-media/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-media-2/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-metadata/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-publisher/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-rewards-network/docs/api-clients',
  '/Users/via/Development/Dfinitiv/savvy-webhooks/docs/api-clients'
];
// GITHUB_TOKEN must be set in environment (e.g. via ~/.secret_env_vars)
if (!process.env.GITHUB_TOKEN) {
  console.error('GITHUB_TOKEN not set. Add it to ~/.secret_env_vars');
  process.exit(1);
}


interface ReadmeResult {
  packageName: string;
  repoUrl: string;
  content?: string;
  error?: string;
  lastFetched: string;
}

class GitHubReadmeFetcher {
  private token: string;
  private outputDir: string;
  private quiet: boolean;

  constructor(token: string, outputDir: string = './readmes', quiet: boolean = false) {
    this.token = token;
    this.outputDir = outputDir;
    this.quiet = quiet;
  }

  private log(message: string): void {
    if (!this.quiet) {
      console.log(message);
    }
  }

  private parseUrl(url: string): { owner: string; repo: string; packageName: string } | null {
    // Handle GitHub package URLs
    const packageMatch = url.match(/github\.com\/([^\/]+)\/([^\/]+)\/pkgs\/npm\/([^\/]+)/);
    if (packageMatch) {
      return {
        owner: packageMatch[1],
        repo: packageMatch[2],
        packageName: packageMatch[3],
      };
    }

    // Handle regular GitHub repo URLs
    const repoMatch = url.match(/github\.com\/([^\/]+)\/([^\/]+)/);
    if (repoMatch) {
      const repo = repoMatch[2].replace('.git', '');
      return {
        owner: repoMatch[1],
        repo,
        packageName: repo,
      };
    }

    return null;
  }

  private async fetchReadme(owner: string, repo: string): Promise<string | null> {
    const readmeFiles = ['README.md', 'readme.md', 'Readme.md', 'README.MD'];
    const searchPaths = ['package/', '']; // Check package/ directory first, then root
    
    for (const path of searchPaths) {
      for (const filename of readmeFiles) {
        try {
          const response = await fetch(
            `https://api.github.com/repos/${owner}/${repo}/contents/${path}${filename}`,
            {
              headers: {
                'Authorization': `Bearer ${this.token}`,
                'Accept': 'application/vnd.github.v3+json',
                'User-Agent': 'readme-fetcher',
              },
            }
          );

          if (response.ok) {
            const data = await response.json();
            if (data.type === 'file' && data.content) {
              return Buffer.from(data.content, 'base64').toString('utf-8');
            }
          }
        } catch (error) {
          // Continue to next filename
        }
      }
    }

    return null;
  }

  async fetchPackageReadme(config: PackageConfig): Promise<ReadmeResult> {
    const parsed = this.parseUrl(config.url);
    
    if (!parsed) {
      return {
        packageName: config.name || config.url,
        repoUrl: config.url,
        error: 'Invalid GitHub URL',
        lastFetched: new Date().toISOString(),
      };
    }

    const { owner, repo, packageName } = parsed;
    const finalPackageName = config.name || packageName;
    const repoUrl = `https://github.com/${owner}/${repo}`;

    this.log(`📦 Fetching README for ${finalPackageName}...`);

    try {
      const content = await this.fetchReadme(owner, repo);
      
      if (!content) {
        return {
          packageName: finalPackageName,
          repoUrl,
          error: 'README.md not found',
          lastFetched: new Date().toISOString(),
        };
      }

      return {
        packageName: finalPackageName,
        repoUrl,
        content,
        lastFetched: new Date().toISOString(),
      };
    } catch (error) {
      return {
        packageName: finalPackageName,
        repoUrl,
        error: error instanceof Error ? error.message : 'Unknown error',
        lastFetched: new Date().toISOString(),
      };
    }
  }

  private createMarkdownWithFrontmatter(result: ReadmeResult): string {
    const frontmatter = [
      '---',
      `title: "${result.packageName}"`,
      `source: "${result.repoUrl}"`,
      `last_fetched: "${result.lastFetched}"`,
      result.error ? `error: "${result.error}"` : null,
      '---',
      '',
    ].filter(Boolean).join('\n');

    if (result.error) {
      return frontmatter + `# ${result.packageName}\n\n**Error:** ${result.error}\n\nSource: [${result.repoUrl}](${result.repoUrl})\n`;
    }

    return frontmatter + (result.content || '');
  }

  async saveReadme(result: ReadmeResult): Promise<void> {
    if (!existsSync(this.outputDir)) {
      await mkdir(this.outputDir, { recursive: true });
    }

    const filename = `${result.packageName.replace(/[^a-zA-Z0-9-_]/g, '-')}.md`;
    const filepath = join(this.outputDir, filename);
    const markdown = this.createMarkdownWithFrontmatter(result);
    
    await writeFile(filepath, markdown);
    
    if (result.error) {
      this.log(`  ❌ ${filename} - ${result.error}`);
    } else {
      this.log(`  ✅ ${filename}`);
    }
  }

  async copyToDocs(result: ReadmeResult): Promise<void> {
    if (result.error) return;

    if (!existsSync(COPY_TO_DIR)) {
      await mkdir(COPY_TO_DIR, { recursive: true });
    }

    const filename = `${result.packageName.replace(/[^a-zA-Z0-9-_]/g, '-')}.md`;
    const sourcePath = join(this.outputDir, filename);
    const destPath = join(COPY_TO_DIR, filename);

    try {
      await copyFile(sourcePath, destPath);
      this.log(`  📋 Copied to docs: ${filename}`);
    } catch (error) {
      this.log(`  ❌ Failed to copy ${filename}: ${error}`);
    }
  }

  async copyToProjectDirs(result: ReadmeResult): Promise<void> {
    if (result.error) return;

    const filename = `${result.packageName.replace(/[^a-zA-Z0-9-_]/g, '-')}.md`;
    const sourcePath = join(this.outputDir, filename);

    for (const projectDir of PROJECT_COPY_DIRS) {
      if (!existsSync(projectDir)) {
        await mkdir(projectDir, { recursive: true });
      }

      const destPath = join(projectDir, filename);
      
      try {
        await copyFile(sourcePath, destPath);
        this.log(`  📂 Copied to ${projectDir.split('/').slice(-3).join('/')}: ${filename}`);
      } catch (error) {
        this.log(`  ❌ Failed to copy to ${projectDir.split('/').slice(-3).join('/')}: ${error}`);
      }
    }
  }

  async fetchAllReadmes(packages: PackageConfig[]): Promise<ReadmeResult[]> {
    this.log(`🚀 Fetching READMEs for ${packages.length} packages...\n`);

    const results: ReadmeResult[] = [];
    
    for (let i = 0; i < packages.length; i++) {
      const pkg = packages[i];
      
      const result = await this.fetchPackageReadme(pkg);
      results.push(result);
      
      await this.saveReadme(result);
      await this.copyToDocs(result);
      await this.copyToProjectDirs(result);
      
      // Rate limiting - be nice to GitHub API
      if (i < packages.length - 1) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }

    return results;
  }
}


async function main() {
  const args = process.argv.slice(2);
  
  if (args.includes('--help') || args.includes('-h')) {
    console.log(`
📚 GitHub README Fetcher

Usage:
  bun fetch-readme.ts [options]

Options:
  --output, -o    Output directory (default: ./readmes)
  --quiet, -q     Quiet mode (minimal output)
  --help, -h      Show this help

Environment Variables:
  GITHUB_TOKEN    Required GitHub personal access token

Examples:
  bun fetch-readme.ts
  bun fetch-readme.ts --output ./docs --quiet
  GITHUB_TOKEN=xxx bun fetch-readme.ts
`);
    process.exit(0);
  }

  // Parse arguments
  let outputDir = './readmes';
  let quiet = false;
  const token = process.env.GITHUB_TOKEN || '';

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--output':
      case '-o':
        outputDir = args[++i];
        break;
      case '--quiet':
      case '-q':
        quiet = true;
        break;
    }
  }

  if (!token) {
    console.error('❌ GitHub token required. Set GITHUB_TOKEN environment variable');
    process.exit(1);
  }

  const packages = READMES_TO_DOWNLOAD;
  
  if (packages.length === 0) {
    console.error('❌ No packages configured');
    process.exit(1);
  }

  const fetcher = new GitHubReadmeFetcher(token, outputDir, quiet);
  const results = await fetcher.fetchAllReadmes(packages);
  
  // Summary
  const successful = results.filter(r => !r.error);
  const failed = results.filter(r => r.error);
  
  if (!quiet) {
    console.log('\n📊 Summary:');
    console.log(`✅ Successful: ${successful.length}`);
    console.log(`❌ Failed: ${failed.length}`);
    console.log(`📁 Output: ${outputDir}`);
  }
  
  if (failed.length > 0) {
    if (!quiet) {
      console.log('\n❌ Failed packages:');
      failed.forEach(pkg => {
        console.log(`  • ${pkg.packageName}: ${pkg.error}`);
      });
    }
    process.exit(1); // Exit with error code for cron monitoring
  }

  process.exit(0);
}

if (import.meta.main) {
  main().catch((error) => {
    console.error('💥 Fatal error:', error);
    process.exit(1);
  });
}