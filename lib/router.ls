@currentID=-> last split \/, Router.current!originalUrl

Router.configure do
	templateNameConverter: \upperCamelCase
	routeControllerNameConverter: \upperCamelCase
	layoutTemplate:   \layout
	loadingTemplate:  \loading 
	notFoundTemplate: \notFound

Router.route(\/admin/users, where: \server).get ->
	@response.writeHead 301 Location: \/admin/users/1
	@response.end!