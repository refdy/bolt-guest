import { app, BrowserWindow } from 'electron';
import path from 'node:path';
import { isDev } from '../utils/constants';
import { store } from '../utils/store';

export function createWindow(rendererURL: string) {
  console.log('Creating window with URL:', rendererURL);

  const bounds = store.get('bounds');
  console.log('restored bounds:', bounds);

  // preload path
  const preloadPath = path.join(isDev ? process.cwd() : app.getAppPath(), 'build', 'electron', 'preload', 'index.cjs');

  const win = new BrowserWindow({
    ...{
      width: 1200,
      height: 800,
      ...bounds,
    },
    vibrancy: 'under-window',
    visualEffectState: 'active',
    webPreferences: {
      preload: preloadPath,
    },
  });

  console.log('Window created, loading URL...');
  win.loadURL(rendererURL).catch((err) => {
    console.log('Failed to load URL:', err);
  });

  win.webContents.on('did-fail-load', (_, errorCode, errorDescription) => {
    console.log('Failed to load:', errorCode, errorDescription);
  });

  win.webContents.on('did-finish-load', () => {
    console.log('Window finished loading');
  });

  win.webContents.on('console-message', (_, level, message, line, sourceId) => {
    console.log('[Renderer]', level, message, line, sourceId);
  });

  win.webContents.on('render-process-gone', (_, details) => {
    console.error('[Renderer Gone]', details);
  });

  win.webContents.on('unresponsive', () => {
    console.error('[Renderer] unresponsive');
  });

  // Open devtools in development
  if (isDev) {
    win.webContents.openDevTools();
  }

  const boundsListener = () => {
    const bounds = win.getBounds();
    store.set('bounds', bounds);
  };
  win.on('moved', boundsListener);
  win.on('resized', boundsListener);

  return win;
}
