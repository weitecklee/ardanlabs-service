# Check to see if we can use ash, in Alpine images, or default to BASH.
SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)

# RSA Keys
# 	To generate a private/public key PEM file.
# 	$ openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048
# 	$ openssl rsa -pubout -in private.pem -out public.pem

run:
	go run api/services/sales/main.go | go run api/tooling/logfmt/main.go

help:
	go run api/services/sales/main.go --help

version:
	go run api/services/sales/main.go --version

curl-test:
	curl -il -X GET http://localhost:3000/test

curl-live:
	curl -il -X GET http://localhost:3000/liveness

curl-ready:
	curl -il -X GET http://localhost:3000/readiness

curl-error:
	curl -il -X GET http://localhost:3000/testerror

curl-panic:
	curl -il -X GET http://localhost:3000/testpanic

admin:
	go run api/tooling/admin/main.go

# admin token
# export TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IjU0YmIyMTY1LTcxZTEtNDFhNi1hZjNlLTdkYTRhMGUxZTJjMSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzZXJ2aWNlIHByb2plY3QiLCJzdWIiOiIwMWNhNDg4MS0yMWUwLTRjYTUtYTJkNy1lZmRjMTc4ODY0ZDIiLCJleHAiOjE3ODkwODQyMjIsImlhdCI6MTc1NzU0ODIyMiwiUm9sZXMiOlsiQURNSU4iXX0.Pw6CbfdPRQXw-lB3KQfAbMMJn0ym62f8lAQ9XpprODPmdrOPcaZPakUp9OcwAdPR1IpwDVWC0RzsoHWfvsYQgmb4YF5S0cGMaJu2fVNDuhQCGzuJV1R_XLjLc-53sUBvx2bpmNqLfl1ELpQndrRYhG7wogYukUmxwGyLwKN5Q1DlxRxpNNt6d0mXWqK2SGVpx6UEyk_JZS1bEtlPFkQH21LUto9ALbop7i6GWUOiVsXlKq2bEpWfXM4WSKd1tnXcanWYy09ZdL1-BJQIM0GeE8l2RjxlyYwJfuaRYWpDx0Bik1uwVliDoA01dBOmMqMt-wM-3a6kivBBorkc9vI7VQ

# user token
# export TOKEN=eyJhbGciOiJSUzI1NiIsImtpZCI6IjU0YmIyMTY1LTcxZTEtNDFhNi1hZjNlLTdkYTRhMGUxZTJjMSIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzZXJ2aWNlIHByb2plY3QiLCJzdWIiOiIwMWNhNDg4MS0yMWUwLTRjYTUtYTJkNy1lZmRjMTc4ODY0ZDIiLCJleHAiOjE3ODkwODQzNDAsImlhdCI6MTc1NzU0ODM0MCwiUm9sZXMiOlsiVVNFUiJdfQ.Qz6W4SDknXQjxpnNMD_NfIX1BqR0yEtGR-yBrvMADzbYzUJLtgm3Wj3X4lzZPZB4_6Zl8N_f-xykTdMx02-q1t-P9ud-BypFudlrgrCqk7xtq4n3fcBOJQCOZ0Gl5ahUFkjFLnCWYb_qKXYs-gwgB2foYk4u8qWn4_HheM7Gfnz3qRz5_KlXFkti34f3iZJTr9Jbve6sOnb6UYbMb8ojiVkqCKe7FrvpmOtMjFoWE9Ys7ZJB3to5voaE_tqUMILLhnkfKm7gyNFMqZ-NraPg71cVw7bRAuh0RiHrSitDDsJfYu6HLEtEJ3iqgX88MJ4e7Ue2zr1Bv7haoOD8N-gTvQ

curl-auth:
	curl -il \
	-H "Authorization: Bearer ${TOKEN}" "http://localhost:3000/testauth"

token:
	curl -il \
	--user "admin@example.com:gophers" http://localhost:6000/auth/token/54bb2165-71e1-41a6-af3e-7da4a0e1e2c1

users:
	curl -il \
	-H "Authorization: Bearer ${TOKEN}" "http://localhost:3000/users?page=1&rows=2"

curl-auth2:
	curl -il \
	-H "Authorization: Bearer ${TOKEN}" "http://localhost:6000/auth/authenticate"

# ==============================================================================
# Define dependencies

GOLANG          := golang:1.24
ALPINE          := alpine:3.22
KIND            := kindest/node:v1.33.1
POSTGRES        := postgres:17.5
GRAFANA         := grafana/grafana:12.1.0
PROMETHEUS      := prom/prometheus:v3.5.0
TEMPO           := grafana/tempo:2.8.1
LOKI            := grafana/loki:3.5.0
PROMTAIL        := grafana/promtail:3.5.0

KIND_CLUSTER    := ardan-starter-cluster
NAMESPACE       := sales-system
SALES_APP       := sales
AUTH_APP        := auth
BASE_IMAGE_NAME := localhost/ardanlabs
VERSION         := 0.0.1
SALES_IMAGE     := $(BASE_IMAGE_NAME)/$(SALES_APP):$(VERSION)
METRICS_IMAGE   := $(BASE_IMAGE_NAME)/metrics:$(VERSION)
AUTH_IMAGE      := $(BASE_IMAGE_NAME)/$(AUTH_APP):$(VERSION)

# VERSION       := "0.0.1-$(shell git rev-parse --short HEAD)"

# ==============================================================================
# Building containers

build: sales auth

sales:
	docker build \
		-f zarf/docker/dockerfile.sales \
		-t $(SALES_IMAGE) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
		.

auth:
	docker build \
		-f zarf/docker/dockerfile.auth \
		-t $(AUTH_IMAGE) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
		.

# ==============================================================================
# Running from within k8s/kind

dev-up:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/dev/kind-config.yaml

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

	kind load docker-image $(POSTGRES) --name $(KIND_CLUSTER)
# 	kind load docker-image $(GRAFANA) --name $(KIND_CLUSTER) & \
# 	kind load docker-image $(PROMETHEUS) --name $(KIND_CLUSTER) & \
# 	kind load docker-image $(TEMPO) --name $(KIND_CLUSTER) & \
# 	kind load docker-image $(LOKI) --name $(KIND_CLUSTER) & \
# 	kind load docker-image $(PROMTAIL) --name $(KIND_CLUSTER) & \
# 	wait;

dev-down:
	kind delete cluster --name $(KIND_CLUSTER)

dev-status-all:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

dev-status:
	watch -n 2 kubectl get pods -o wide --all-namespaces

# ------------------------------------------------------------------------------

dev-load-db:
	kind load docker-image $(POSTGRES) --name $(KIND_CLUSTER)

dev-load:
	kind load docker-image $(SALES_IMAGE) --name $(KIND_CLUSTER)
	kind load docker-image $(AUTH_IMAGE) --name $(KIND_CLUSTER)

dev-apply:
	kustomize build zarf/k8s/dev/database | kubectl apply -f -
	kubectl rollout status --namespace=$(NAMESPACE) --watch --timeout=120s sts/database

	kustomize build zarf/k8s/dev/auth | kubectl apply -f -
	kubectl wait pods --namespace=$(NAMESPACE) --selector app=$(AUTH_APP) --timeout=120s --for=condition=Ready

	kustomize build zarf/k8s/dev/sales | kubectl apply -f -
	kubectl wait pods --namespace=$(NAMESPACE) --selector app=$(SALES_APP) --timeout=120s --for=condition=Ready

dev-restart:
	kubectl rollout restart deployment $(AUTH_APP) --namespace=$(NAMESPACE)
	kubectl rollout restart deployment $(SALES_APP) --namespace=$(NAMESPACE)

dev-update: build dev-load dev-restart

dev-update-apply: build dev-load dev-apply

dev-logs:
	kubectl logs --namespace=$(NAMESPACE) -l app=$(SALES_APP) --all-containers=true -f --tail=100 --max-log-requests=6 | go run api/tooling/logfmt/main.go -service=$(SALES_APP)

dev-logs-auth:
	kubectl logs --namespace=$(NAMESPACE) -l app=$(AUTH_APP) --all-containers=true -f --tail=100 | go run api/tooling/logfmt/main.go

dev-logs-init:
	kubectl logs --namespace=$(NAMESPACE) -l app=$(SALES_APP) -f --tail=100 -c init-migrate-seed

# ------------------------------------------------------------------------------

dev-describe-deployment:
	kubectl describe deployment --namespace=$(NAMESPACE) $(SALES_APP)

dev-describe-sales:
	kubectl describe pod --namespace=$(NAMESPACE) -l app=$(SALES_APP)

dev-describe-auth:
	kubectl describe pod --namespace=$(NAMESPACE) -l app=$(AUTH_APP)

# ==============================================================================
# Metrics and Tracing

metrics:
	expvarmon -ports="localhost:3010" -vars="build,requests,goroutines,errors,panics,mem:memstats.HeapAlloc,mem:memstats.HeapSys,mem:memstats.Sys"

statsviz:
	open http://localhost:3010/debug/statsviz

# ==============================================================================
# Administration

pgcli:
	pgcli postgresql://postgres:postgres@localhost

# ==============================================================================
# Modules support

tidy:
	go mod tidy
	go mod vendor

# ==============================================================================
# Running tests within the local computer

test-r:
	CGO_ENABLED=1 go test -race -count=1 ./...

test-only:
	CGO_ENABLED=0 go test -count=1 ./...

lint:
	CGO_ENABLED=0 go vet ./...
	staticcheck -checks=all ./...

vuln-check:
	govulncheck ./...

test: test-only lint vuln-check

test-race: test-r lint vuln-check
