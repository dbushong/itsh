itsh = require '../'

die = (msg...) ->
  console.error "#{prog._name}:", msg...
  process.exit 1

sendMultiple = (paths, opts) ->
  res = itsh.sendFile(paths[0], opts)
  if paths.length > 1
    res.on 'end', -> sendMultiple(paths[1..], opts)
    res.pipe(process.stdout, end: false)
  else
    res.pipe(process.stdout)

prog = require 'commander'
prog.version(require('../package.json').version)

prog.command('send [file...]')
    .description('send file or stdin to iTerm')
    .option('-f, --fname <name>', 'Provide name for stdin')
    .option('-s, --size <bytes>', 'Specify final size for stdin')
    .action (paths, cmdOpts) ->
      opts = {}
      opts[k] = cmdOpts[ck] for ck,k of { fname: 'name', size: 'size' }
      if paths.length
        die "don't supply --size for !stdin" if opts.size?
        if opts.name? and paths.length > 1
          die "can't supply --fname for multiple files"
      else
        opts.name ?= 'stdin.txt'
        paths = [process.stdin]
      sendMultiple(paths, opts)

prog.command('img [file...]')
    .description('display img file(s) or stdin in iTerm')
    .option('-w, --width <w>',                'N cells, Npx, N%, or auto')
    .option('-h, --height <h>',               'N cells, Npx, N%, or auto')
    .option('-P, --no-preserve-aspect-ratio', 'allows stretching')
    .action (paths, cmdOpts) ->
      opts = {}
      opts[k] = cmdOpts[k] for k in ['width', 'height', 'preserveAspectRatio']
      opts.inline = true
      paths[0] ?= process.stdin
      sendMultiple(paths, opts)

prog.parse(process.argv)

# remaining args are prog.args

