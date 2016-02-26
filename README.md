# itsh - iTerm Shell Extensions helper tools

## CLI

### Installation

```
% npm install --global itsh
```

### Usage

```
% itsh send some-file.log other-file.log third-file.log
% head -20 file.txt | itsh send -f 'file header.txt'
% itsh img --width 20 --height 10 --no-preserve-aspect-ratio cat.jpg dog.jpg
% itsh img < cat.jpg
```

## Library

### Installation

```
% npm install --save itsh
```

### Usage

```coffee
iterm2 = require 'itsh'
fs     = require 'fs'

# opens file stream, sets name and size, returns stream
iterm2.sendFile('/etc/motd').pipe(process.stdout)

# accepts already open stream, name, and size, returns stream
iterm2.sendFile(fs.createReadStream('/etc/motd'), name: 'motd', size: 1234).pipe(process.stdout)

# reads whole file into buffer, writes whole buffer to stdout
buf = iterm2.sendFile(fs.readFileSync('/etc/motd'), name: 'motd', size: 1234)
process.stdout.write(buf)
