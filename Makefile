up:
	@bash ./up.sh
.PHONY: up

down:
	@(docker compose down)
.PHONY: down
