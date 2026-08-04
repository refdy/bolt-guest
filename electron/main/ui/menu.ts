import { BrowserWindow, Menu } from 'electron';

export function setupMenu(win: BrowserWindow): void {
  const template: Electron.MenuItemConstructorOptions[] = [
    {
      label: 'File',
      submenu: [{ role: 'close' }, { role: 'quit' }],
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' },
        { role: 'selectAll' },
      ],
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' },
      ],
    },
    {
      label: 'Build',
      submenu: [
        {
          label: 'Build Project',
          click: () => win.webContents.send('menu-build'),
        },
      ],
    },
    {
      label: 'Preview',
      submenu: [
        {
          label: 'Refresh Preview',
          accelerator: 'F5',
          click: () => win.webContents.reload(),
        },
      ],
    },
    {
      label: 'Go',
      submenu: [
        {
          label: 'Back',
          accelerator: 'CmdOrCtrl+[',
          click: () => {
            if (win.webContents.navigationHistory.canGoBack()) {
              win.webContents.navigationHistory.goBack();
            }
          },
        },
        {
          label: 'Forward',
          accelerator: 'CmdOrCtrl+]',
          click: () => {
            if (win.webContents.navigationHistory.canGoForward()) {
              win.webContents.navigationHistory.goForward();
            }
          },
        },
      ],
    },
    {
      role: 'windowMenu',
    },
    {
      role: 'help',
      submenu: [
        {
          label: 'About',
          click: () => {},
        },
      ],
    },
  ];

  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}
