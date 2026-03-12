#!/usr/bin/env bun

import { SecretsManagerClient, CreateSecretCommand, UpdateSecretCommand, ResourceExistsException } from '@aws-sdk/client-secrets-manager';
import * as readline from 'readline';
import chalk from 'chalk';

/**
 * Prompt for input with optional hidden mode for sensitive data
 */
function prompt(question: string, hidden: boolean = false): Promise<string> {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    if (hidden) {
      // Hide input for sensitive data
      const stdin = process.stdin;
      (stdin as any).setRawMode(true);

      process.stdout.write(question);
      let input = '';

      stdin.on('data', (char) => {
        const c = char.toString('utf8');

        switch (c) {
          case '\n':
          case '\r':
          case '\u0004': // Ctrl-D
            (stdin as any).setRawMode(false);
            stdin.pause();
            process.stdout.write('\n');
            rl.close();
            resolve(input);
            break;
          case '\u0003': // Ctrl-C
            process.stdout.write('\n');
            process.exit(0);
            break;
          case '\u007f': // Backspace
          case '\b':
            if (input.length > 0) {
              input = input.slice(0, -1);
              process.stdout.write('\b \b');
            }
            break;
          default:
            input += c;
            process.stdout.write('*');
            break;
        }
      });
    } else {
      rl.question(question, (answer) => {
        rl.close();
        resolve(answer);
      });
    }
  });
}

async function addSecret() {
  try {
    // Get the secret name
    const secretName = await prompt(chalk.cyan('Secret name: '));
    if (!secretName.trim()) {
      console.error(chalk.red('Error: Secret name cannot be empty'));
      process.exit(1);
    }

    // Get the secret value (hidden input)
    const secretValue = await prompt(chalk.cyan('Secret value: '), true);
    if (!secretValue.trim()) {
      console.error(chalk.red('Error: Secret value cannot be empty'));
      process.exit(1);
    }

    // Optional description
    const description = await prompt(chalk.cyan('Description (optional): '));

    // Initialize AWS Secrets Manager client
    const client = new SecretsManagerClient({});

    try {
      // Try to create the secret
      const createCommand = new CreateSecretCommand({
        Name: secretName,
        SecretString: secretValue,
        Description: description || undefined,
      });

      await client.send(createCommand);
      console.log(chalk.green(`✓ Secret '${secretName}' created successfully`));
    } catch (error) {
      if (error instanceof ResourceExistsException) {
        // Secret already exists, update it instead
        console.log(chalk.yellow(`Secret '${secretName}' already exists. Updating...`));

        const updateCommand = new UpdateSecretCommand({
          SecretId: secretName,
          SecretString: secretValue,
          Description: description || undefined,
        });

        await client.send(updateCommand);
        console.log(chalk.green(`✓ Secret '${secretName}' updated successfully`));
      } else {
        throw error;
      }
    }
  } catch (error) {
    console.error(chalk.red('Error adding secret:'), error);
    process.exit(1);
  }
}

addSecret();
