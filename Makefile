all:
	mkdir -p $(HOME)/data/mariadb
	mkdir -p $(HOME)/data/wordpress
	
	sudo chown -R $(USER) $(HOME)/data/mariadb
	sudo chown -R $(USER) $(HOME)/data/wordpress
	cd srcs && docker compose up --build -d
down:
	cd srcs && docker compose down

clean:
	cd srcs && docker compose down --rmi all -v

fclean:
	cd srcs &&  docker compose down --rmi all -v
	sudo rm -rf $(HOME)/data/mariadb
	sudo rm -rf $(HOME)/data/wordpress

re: fclean all 

.PHONY: all down clean fclean re