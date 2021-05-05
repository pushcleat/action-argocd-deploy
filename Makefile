docker/build:
	docker build --target run  -t pushcleat/argocd-deploy:latest .
	docker build --target test -t pushcleat/argocd-deploy:test-latest .
