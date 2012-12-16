
Factory = require '' 
class GTPFileFormat
	construtor:()->
		@factory

	@DEFAULT_TG_CHARTSET = "utf8"
	@DEFAULT_VERSION_CHARSET = "utf8"


	getFactory()
		unless @factory 
			@factory = new 
		return @factory

exports.GTPFileFormat = GTPFileFormat

