package mid

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v4"
	"github.com/google/uuid"
	"github.com/weitecklee/ardanlabs-service/app/api/errs"
	"github.com/weitecklee/ardanlabs-service/business/api/auth"
)

// Authorization validates a JWT from the `Authorization` header.
func Authorization(ctx context.Context, auth *auth.Auth, authorization string, handler Handler) error {
	var err error
	parts := strings.Split(authorization, " ")

	switch parts[0] {
	case "Bearer":
		ctx, err = processJWT(ctx, auth, authorization)

	case "Basic":
		ctx, err = processBasic(ctx)
	}

	if err != nil {
		return err
	}

	return handler(ctx)
}

func processJWT(ctx context.Context, auth *auth.Auth, token string) (context.Context, error) {
	claims, err := auth.Authenticate(ctx, token)
	if err != nil {
		return ctx, errs.New(errs.Unauthenticated, err)
	}

	if claims.Subject == "" {
		return ctx, errs.Newf(errs.Unauthenticated, "authorize: you are not authorized for that action, no claims")
	}

	subjectID, err := uuid.Parse(claims.Subject)
	if err != nil {
		return ctx, errs.New(errs.Unauthenticated, fmt.Errorf("parsing subject: %w", err))
	}

	ctx = setUserId(ctx, subjectID)
	ctx = setClaims(ctx, claims)

	return ctx, nil
}

func processBasic(ctx context.Context) (context.Context, error) {
	claims := auth.Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   "38dc9d84-018b-4a15-b958-0b78af11c301",
			Issuer:    "service project",
			ExpiresAt: jwt.NewNumericDate(time.Now().UTC().Add(8760 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now().UTC()),
		},
		Roles: []string{"ADMIN"},
	}

	subjectID, err := uuid.Parse(claims.Subject)
	if err != nil {
		return ctx, errs.Newf(errs.Unauthenticated, "parsing subject: %s", err)
	}

	ctx = setUserId(ctx, subjectID)
	ctx = setClaims(ctx, claims)

	return ctx, nil
}
