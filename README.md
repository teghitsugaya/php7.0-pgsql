#php7.0-pgsql
--------------
app for display databases from postgresql db using php language



#listingfile folder
-------------------
-rw-r--r--  1 root root  314 Oct 26 22:37 apache-config.conf
-rw-r--r--  1 root root  856 Oct 26 23:33 Dockerfile
-rw-r--r--  1 root root  908 Oct 26 18:40 index.php


#apache-config
--------------
```sh
apache-config.conf 
<VirtualHost *:80>
 DocumentRoot /var/www/site
  <Directory /var/www/site/>
      Options Indexes FollowSymLinks MultiViews
      AllowOverride All
      Order deny,allow
      Allow from all
  </Directory>

  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
```

#index.php
----------
<?php

$host = '10.102.36.138';
$port = '5432';
$database = 'testing';
$user = 'testing';
$password = 'prismalink';

$connectString = 'host=' . $host . ' port=' . $port . ' dbname=' . $database . 
	' user=' . $user . ' password=' . $password;

$link = pg_connect($connectString);
if (!$link)
{
	die('Error: Could not connect: ' . pg_last_error());
}

$query = 'select * from test01';

$result = pg_query($query);

$i = 0;
echo '<html><body><table><tr>';
while ($i < pg_num_fields($result))
{
	$fieldName = pg_field_name($result, $i);
	echo '<td>' . $fieldName . '</td>';
	$i = $i + 1;
}
echo '</tr>';
$i = 0;

while ($row = pg_fetch_row($result)) 
{
	echo '<tr>';
	$count = count($row);
	$y = 0;
	while ($y < $count)
	{
		$c_row = current($row);
		echo '<td>' . $c_row . '</td>';
		next($row);
		$y = $y + 1;
	}
	echo '</tr>';
	$i = $i + 1;
}
pg_free_result($result);

echo '</table></body></html>';
?>




#Dockerfile
------------
FROM php:7.1-apache
RUN apt-get update \
  && apt-get install --no-install-recommends -y libpq-dev \
  && docker-php-ext-install pgsql \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV APACHE_RUN_USER www-data 
ENV APACHE_RUN_GROUP www-data 

EXPOSE 80 
ADD index.php /var/www/site/index.php
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

COPY . /usr/src/myapp
WORKDIR /usr/src/myapp



#executions
----------
docker build -t php-pgsql:latest
docker run -d --name=php-pgsql -p 8090:80 php-pgsql




#testing
--------
curl localhost:8090


#push to dockerhub account
--------------------------
docker push teghitsugaya/php-pgsql:latest
docker tag php-pgsql:latest teghitsugaya/php-pgsql:latest

#onboard to kubernetes
##deployment
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pgsql
spec: 
  replicas: 1
  template:
    metadata:
      labels:
        app: pgsql
    spec:
      containers:
      - name: pgsql-app
        image: teghitsugaya/php-pgsql
        ports:
        - containerPort: 80
          name: web-port
          
##service
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pgsql
spec: 
  replicas: 1
  template:
    metadata:
      labels:
        app: pgsql
    spec:
      containers:
      - name: pgsql-app
        image: teghitsugaya/php-pgsql
        ports:
        - containerPort: 80
          name: web-port
