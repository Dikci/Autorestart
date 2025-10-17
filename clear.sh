#!/bin/bash

docker stop fizz-node
docker rm fizz-node
docker volume ls
docker volume prune -f          # автоответ "y"
docker volume rm node-storage
docker system prune -a -f       # автоответ "y"
rm -rf multipleNEW.sh.1 multipleforlinux multiple.sh Ocean.sh.2 Ocean.sh.3 Ocean.sh.4 Ocean.sh.5 pop privasea .spheron
rm -rf clear.sh
