fs         = require 'fs'
{basename} = require 'path'
stream     = require 'stream'

PRELUDE = new Buffer '\x1b]1337;File='
FINALE  = new Buffer '\x07'

# content may be a String (path), a Buffer (file contents), or a Stream
# iff it is a Buffer, the function will synchronously return a Buffer
# else it will return a Stream
#
# buf = itsh.sendFile(fs.readFileSync('/etc/motd'), name: 'motd')
# itsh.sendFile('/etc/motd').pipe(process.stdout)
# itsh.sendFile(fs.createReadStream('/etc/motd'), name: 'motd', size: 1234)
sendFile = (content, {name,width,height,inline,preserveAspectRatio,size}) ->
  if content instanceof Buffer
    isBuffer = true
    size    ?= content.length
    if size isnt content.length
      throw new Error(
        "opts.size (#{size}) != buffer.length (#{content.length})")
  else if 'string' is typeof content
    unless inline
      name ?= basename content
      size ?= fs.statSync(content).size
    content = fs.createReadStream content
  else unless content instanceof stream.Readable
    throw new Error 'file must be a String, Buffer, or Stream'

  attrs = {}
  attrs.name                = (new Buffer(name)).toString('base64') if name?
  attrs.width               = width  if width?
  attrs.height              = height if height?
  attrs.size                = size   if size?
  attrs.inline              = 1      if inline
  attrs.preserveAspectRatio = 0      if preserveAspectRatio is false

  prefix = Buffer.concat [
    PRELUDE, new Buffer(("#{k}=#{v}" for k,v of attrs).join(';') + ':')
  ]

  if isBuffer
    Buffer.concat [prefix, content.toString('base64'), FINALE]
  else
    # TODO: optimize for fewer buf slice ops
    encoder = new stream.Transform
      flush: (cb) ->
        @push new Buffer(@extra.toString('base64')) if @extra?
        @push FINALE
        cb()
      transform: (buf, enc, cb) ->
        if @extra
          buf = Buffer.concat [ @extra, buf ]
          @extra = null

        if (rem = buf.length % 3)
          @extra = buf.slice(buf.length - rem)
          buf = buf.slice(0, buf.length - rem)

        @push new Buffer(prefix + buf.toString('base64'))
        prefix = ''
        cb()
    content.pipe(encoder)

module.exports = { sendFile }
