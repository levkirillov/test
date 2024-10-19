install = {
  title = 'Opus OS',
  version = '1.0',
  author = 'Kepler',
  description = [[
A user friendly operating system featuring multitasking, networking, and automation
]],
  license = [[
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.]],
  copyrightYear = 2018,
  copyrightHolders = 'Kepler',
  diskspace = 380000,
  rebootAfter = true,
  gitRepo = 'kepler155c/opus',
  gitBranch = 'develop-1.8',
  branches = {
    { branch = 'develop-1.8', description = '1.8+ Unstable' },
    { branch = 'master-1.8',  description = '1.8+ Stable'   },
    { branch = 'master',      description = '1.7x Stable'   },
    { branch = 'develop',     description = '1.7x Unstable' },
  },
  preCopy = function(mode)
    if mode == 'update' then
      fs.delete('sys')
    end
  end,
  steps = {
    install = {
      'splash',
      'license',
      'branch',
      'files',
      'review',
      'install',
    },
    update = {
      'branch',
      'review',
      'install',
    },
    automatic = {
      'install',
    },
    uninstall = {
      'review',
      'uninstall',
    },
  },
}

print('Downloading Installer...')

local url ='https://raw.githubusercontent.com/kepler155c/opus-installer/master/sys/apps/Installer.lua'
local h = _G.http.get(url)
if not h then
  error('Failed to download installer')
end

local contents = h.readAll()
if not contents then
  error('Failed to download installer')
end

local fn, msg = load(contents, 'Installer.lua', nil, _ENV)
if not fn then
  _G.printError(msg)
else
  local args = { ... }
  fn(args[1])
end
