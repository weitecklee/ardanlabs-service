// Package mux provides support to bind domain level routes
// to the application mux.
package mux

import (
	"os"

	"github.com/weitecklee/ardanlabs-service/api/services/sales/route/sys/checkapi"
	"github.com/weitecklee/ardanlabs-service/foundation/web"
)

// WebAPI constructs a http.Handler with all application routes bound.
func WebAPI(shutdown chan os.Signal) *web.App {
	mux := web.NewApp(shutdown)

	checkapi.Routes(mux)

	return mux
}
