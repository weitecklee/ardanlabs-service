// Package mux provides support to bind domain level routes
// to the application mux.
package mux

import (
	"os"

	"github.com/weitecklee/ardanlabs-service/api/services/api/mid"
	"github.com/weitecklee/ardanlabs-service/api/services/auth/route/authapi"
	"github.com/weitecklee/ardanlabs-service/api/services/auth/route/checkapi"
	"github.com/weitecklee/ardanlabs-service/business/api/auth"
	"github.com/weitecklee/ardanlabs-service/foundation/logger"
	"github.com/weitecklee/ardanlabs-service/foundation/web"
)

// WebAPI constructs a http.Handler with all application routes bound.
func WebAPI(log *logger.Logger, ath *auth.Auth, shutdown chan os.Signal) *web.App {
	app := web.NewApp(shutdown, mid.Logger(log), mid.Errors(log), mid.Metrics(), mid.Panics())

	checkapi.Routes(app, ath)
	authapi.Routes(app, ath)

	return app
}
