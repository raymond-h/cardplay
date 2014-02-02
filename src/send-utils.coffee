exports.delim = '\r\n'

exports.sendableJson = (data, delim = exports.delim) ->
	if typeof data isnt 'string'
		data = JSON.stringify data

	length = Buffer.byteLength data, 'utf-8'

	"#{length}#{delim}#{data}"

exports.parseSendableJson = (data, delim = exports.delim) ->
	if (delimPos = data.indexOf delim) < 0 then return []

	length = Number(data.substring 0, delimPos)
	data = data.substring delimPos + delim.length

	if (Buffer.byteLength data, 'utf-8') < length then return []

	dataBuf = new Buffer data, 'utf-8'
	startOfNext = delimPos + delim.length + length
	json = dataBuf.toString('utf-8').substring 0, length
	try
		[(JSON.parse json), startOfNext]
	catch e
		console.log e.stack
		return []