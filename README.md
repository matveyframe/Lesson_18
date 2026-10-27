1) Запустить master-slave кластер postgresql (вручную или через repmgr)
 ```

```
![](https://github.com/matveyframe/Lesson_18/blob/main/Master_base.PNG "Logo Title Text 1")
![](https://github.com/matveyframe/Lesson_18/blob/main/Connect_slave__base.PNG "Logo Title Text 1")
![](https://github.com/matveyframe/Lesson_18/blob/main/show_cluster.PNG "Logo Title Text 1")

2)Запустить приложение https://github.com/anestesia001/notes_api_db_replicated/tree/main
 ```
[Unit]
Description= notes_api_py
After=network-online.target

[Service]
User=matvey
Group=matvey
WorkingDirectory=/home/matvey/home_works/lesson_18/notes_api_db_replicated
ExecStart=/home/matvey/home_works/lesson_18/notes_api_db_replicated/venv/bin/python3 -m flask --app notes_api run
Restart=always

Environment="PRIMARY_DSN=host=10.127.17.30 port=5432 dbname=repmgr user=repmgr password=secret"
Environment="REPLICA_DSN=host=10.127.17.31 port=5432 dbname=repmgr user=repmgr password=secret"

Environment="FLASK_RUN_HOST=0.0.0.0"
Environment="FLASK_RUN_PORT=8001"

[Install]
WantedBy=multi-user.target
```
![](https://github.com/matveyframe/Lesson_18/blob/main/notes_status.PNG "Logo Title Text 1")

3)Настроить nginx в качестве reverse proxy для приложения

```
server {
    listen 80;
    server_name 10.127.17.30;

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
![](https://github.com/matveyframe/Lesson_18/blob/main/nginx_status_health.PNG "Logo Title Text 1")

4)Написать скрипт для проверки состояния primary, replica
```
#!/bin/bash

NOTES_APP="http://10.127.17.30:8001"
OUTPUT=$(curl -s "$NOTES_APP/health")
STATUS_CLUSTER=$( sudo -u postgres repmgr -f /etc/repmgr.conf cluster show)

  if echo "${OUTPUT}" | grep -q '"primary":"up"' && echo "${OUTPUT}" | grep -q '"replica":"up"'; then
     echo "$STATUS_CLUSTER" && echo -e "\n\nMaster and Slave is working!"
  else
     echo "$STATUS_CLUSTER" && echo -e "\n\nMaster or Slave not a working!"
  fi
```
![](https://github.com/matveyframe/Lesson_18/blob/main/script_status.PNG "Logo Title Text 1")
