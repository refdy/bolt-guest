#!/usr/bin/env node

import { spawn } from 'node:child_process';
import path from 'node:path';
import fs from 'node:fs';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CHECK_INTERVAL = 1000;
const MAX_RETRIES = 60;

process.env.NODE_ENV = 'development';

let electronProcess = null;
let remixProcess = null;

function cleanup() {
  console.log('\nStopping...');

  if (electronProcess) {
    electronProcess.kill('SIGTERM');
  }

  if (remixProcess) {
    remixProcess.kill('SIGTERM');
  }

  process.exit(0);
}

process.on('SIGINT', cleanup);
process.on('SIGTERM', cleanup);

async function buildElectronDeps() {
  return new Promise((resolve, reject) => {
    const p = spawn('pnpm', ['electron:build:deps'], {
      stdio: 'inherit',
      env: process.env,
    });

    p.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`electron:build:deps exited ${code}`));
      }
    });

    p.on('error', reject);
  });
}

async function waitForServer(proc) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error('Timed out waiting for Vite URL'));
    }, MAX_RETRIES * CHECK_INTERVAL);

    function onData(data) {
      const text = data.toString();

      process.stdout.write(text);

      const m = text.match(/Local:\s+(http:\/\/localhost:\d+)/);

      if (m) {
        clearTimeout(timeout);
        proc.stdout.off('data', onData);
        resolve(m[1]);
      }
    }

    proc.stdout.on('data', onData);

    proc.stderr.on('data', (d) => process.stderr.write(d));
  });
}

async function main() {
  console.log('Building Electron...');

  await buildElectronDeps();

  console.log('Starting Remix...');

  remixProcess = spawn('pnpm', ['dev'], {
    stdio: 'pipe',
    env: process.env,
  });

  const url = await waitForServer(remixProcess);

  process.env.VITE_DEV_SERVER_URL = url;

  console.log('');
  console.log('===================================');
  console.log('Using Remix URL :', url);
  console.log('DISPLAY         :', process.env.DISPLAY || ':0');
  console.log(
    'XAUTHORITY      :',
    process.env.XAUTHORITY || `${process.env.HOME}/.Xauthority`
  );
  console.log('===================================');
  console.log('');

  const electronPath = path.join(
    __dirname,
    '..',
    'node_modules',
    '.bin',
    'electron'
  );

  const mainFile = path.join(
    __dirname,
    '..',
    'build',
    'electron',
    'main',
    'index.mjs'
  );

  if (!fs.existsSync(mainFile)) {
    throw new Error(`Missing ${mainFile}`);
  }

  electronProcess = spawn(electronPath, [mainFile], {
    stdio: 'inherit',
    env: {
      ...process.env,

      DISPLAY: process.env.DISPLAY || ':0',
      XAUTHORITY:
        process.env.XAUTHORITY ||
        `${process.env.HOME}/.Xauthority`,

      NODE_ENV: 'development',
      ELECTRON_IS_DEV: '1',
      VITE_DEV_SERVER_URL: url,
    },
  });

  electronProcess.on('exit', (code) => {
    console.log('Electron exited:', code);
    cleanup();
  });

  electronProcess.on('error', (err) => {
    console.error(err);
    cleanup();
  });
}

main().catch((e) => {
  console.error(e);
  cleanup();
});
