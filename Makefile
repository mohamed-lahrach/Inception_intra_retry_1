all:
	mkdir -p /home/mlahrach/data/mariadb
	mkdir -p /home/mlahrach/data/wordpress
	
	sudo chown -R mlahrach:mlahrach /home/mlahrach/data/mariadb
	sudo chown -R mlahrach:mlahrach /home/mlahrach/data/wordpress
	cd srcs && docker compose up --build -d
down:
	cd srcs && docker compose down

clean:
	cd srcs && docker compose down --rmi all -v

fclean:
	cd srcs &&  docker compose down --rmi all -v
	sudo rm -rf /home/mlahrach/data/mariadb
	sudo rm -rf /home/mlahrach/data/wordpress

re: fclean all 

.PHONY: all down clean fclean re