package mid

import (
	"context"
	"net/http"

	"github.com/weitecklee/ardanlabs-service/app/api/mid"
	"github.com/weitecklee/ardanlabs-service/business/api/auth"
	"github.com/weitecklee/ardanlabs-service/foundation/web"
)

// Authorization validates authentication via the auth service.
func Authorization(auth *auth.Auth) web.MidHandler {
	m := func(handler web.Handler) web.Handler {
		h := func(ctx context.Context, w http.ResponseWriter, r *http.Request) error {
			hdl := func(ctx context.Context) error {
				return handler(ctx, w, r)
			}

			return mid.Authorization(ctx, auth, r.Header.Get("authorization"), hdl)
		}

		return h
	}

	return m
}
