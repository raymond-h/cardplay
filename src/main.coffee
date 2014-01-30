http = require 'http'
url = require 'url'
Router = require 'routes'

CardManager = require './card-manager'

CardManager.load './cards'

router = Router()

http.createServer (req, res) ->
	urlParts = url.parse req.url, true

	match = router.match urlParts.pathname
	match.fn req, res, urlParts, match if match?

.listen 80

router.addRoute '/test', (req, res, url, route) ->
	console.log "Got a test request"

	res.writeHead 200
	res.write "Testing does work!"
	res.end()