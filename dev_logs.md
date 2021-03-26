Setting up Docker

Needed to turn off default Apache server on linux install already: 
`sudo service apache2 stop`
Binding the correct ports:
  use "ports", each entry corresponds to "host_port:child_port", for example 8080:80 means 8080 on the host, e.g. actual server will map to port 80 on the docker service.

Things to do when installing..
Use certbot: `sudo certbot certonly --standalone -d julianyang.org`
Some notes:
	docker automatically generates DNS entry to the container name, e.g. http://mycontainername:8000
     *  https://docs.docker.com/compose/networking/
     *  https://www.digitalocean.com/community/questions/what-value-should-i-use-for-nginx-proxy_pass-running-in-docker 

