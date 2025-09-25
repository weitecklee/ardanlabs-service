package checkapi

import (
	"github.com/jmoiron/sqlx"
	"github.com/weitecklee/ardanlabs-service/api/services/api/mid"
	"github.com/weitecklee/ardanlabs-service/app/api/authclient"
	"github.com/weitecklee/ardanlabs-service/business/api/auth"
	"github.com/weitecklee/ardanlabs-service/foundation/logger"
	"github.com/weitecklee/ardanlabs-service/foundation/web"
)

// Routes adds specific routes for this group.
func Routes(build string, app *web.App, log *logger.Logger, db *sqlx.DB, authClient *authclient.Client) {
	authen := mid.AuthenticateService(log, authClient)
	authAdminOnly := mid.AuthorizeService(log, authClient, auth.RuleAdminOnly)

	api := newAPI(build, log, db)
	app.HandleFuncNoMiddleware("GET /liveness", api.liveness)
	app.HandleFuncNoMiddleware("GET /readiness", api.readiness)
	app.HandleFunc("GET /testerror", api.testError)
	app.HandleFunc("GET /testpanic", api.testPanic)
	app.HandleFunc("GET /testauth", api.liveness, authen, authAdminOnly)

}
