package authapi

import (
	"github.com/weitecklee/ardanlabs-service/api/services/api/mid"
	"github.com/weitecklee/ardanlabs-service/business/api/auth"
	"github.com/weitecklee/ardanlabs-service/foundation/web"
)

// Routes adds specific routes for this group.
func Routes(app *web.App, a *auth.Auth) {
	authen := mid.Authorization(a)

	api := newAPI(a)

	app.HandleFunc("GET /auth/token/{kid}", api.token, authen)
	app.HandleFunc("GET /auth/authenticate", api.authenticate, authen)
	app.HandleFunc("POST /auth/authorize", api.authorize)

}
