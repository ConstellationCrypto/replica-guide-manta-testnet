up:
	@bash ./up.sh
.PHONY: up

down:
	@(docker-compose -f docker-compose.yml down)
.PHONY: down

clean: down
	docker image ls 'replica*' --format='{{.Repository}}' | xargs -r docker rmi
	docker volume ls --filter name='replica-guide' --format='{{.Name}}' | xargs -r docker volume rm
.PHONY: clean
