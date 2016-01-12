Сервер создаю и настраиваю с помощью инструкций отсюда:
https://www.phusionpassenger.com/library/walkthroughs/deploy/python/aws/standalone/oss/trusty/deploy_app.html#login-to-your-server-create-a-user-for-the-app

На виртуальной машине пользователь, под которым будет работать программа создан командой
sudo adduser repetitor
пароль пользователя - 32167

установка SSH key

sudo mkdir -p ~repetitor/.ssh
sudo sh -c "cat $HOME/.ssh/authorized_keys >> ~repetitor/.ssh/authorized_keys"
sudo chown -R repetitor: ~repetitor/.ssh
sudo chmod 700 ~repetitor/.ssh
sudo sh -c "chmod 600 ~repetitor/.ssh/*"

установка git-а
sudo apt-get install -y git

создаем директорию для кода

sudo mkdir -p /var/www/repetitorapp
sudo chown repetitor: /var/www/repetitorapp

взял код у себя с git-а:
cd /var/www/repetitorapp
sudo -u repetitor -H git clone https://github.com/sergeimoiseev/repetitor.git code

Your app's code now lives on the server at /var/www/myapp/code

Install app dependencies
sudo pip install flask
(пришлось сначала поствить pip через apt-get)


Finally, fix the permissions on the file:
sudo chown repetitor: Passengerfile.json

# Install our PGP key and add HTTPS support for APT
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

sudo passenger-config validate-install

sudo apt-get update
sudo apt-get upgrade

# Install Passenger
sudo apt-get install -y passenger

Start Passenger Standalone
cd /var/www/myapp/code
sudo passenger start


По адресу 
http://.............../

теперь видна страничка, сгенерированная моим сервером
----
Deploying application updates
with Passenger in Standalone mode
(ssh -i your_ec2_key.pem repetitor@54.213.157.107)

мне придется каждый раз входить через java-приложение в firefox
и менять пользователя

 Prepare application

2.1 Install app dependencies
3 Restart application

Passenger may still be serving an old instance of your application. Now that all application updates have been prepared, tell Passenger to restart your application so that the updates take effect.

passenger-config restart-app $(pwd)

создаю свой главный репозиторий (рабочий репозиторий буду push-ать в него, а из него уже в git
а из git-а - на сервер)

Sergei@embedder-pc MINGW64 ~/Dropbox/Work/repetitor
$ cd repetitor.git/

Sergei@embedder-pc MINGW64 ~/Dropbox/Work/repetitor/repetitor.git
$ git --bare init
Initialized empty Git repository in C:/Users/Sergei/Dropbox/Work/repetitor/repetitor.git/

дальше добавляю в репозиторий файлы и использую GitGUI для работы с кодом

на гитхабе сделал репозиторий-обменник
https://github.com/sergeimoiseev/repetitor.git

на сервер в папке www code
создаю репозиторий, чтобы проще было использовать / передавать скрипты и т.д.

repetitor@ip-172-31-25-197:/var/www/repetitorapp/code$ git --bare init                                                          
Initialized empty Git repository in /var/www/repetitorapp/code/

добавляю новый ремоут - repetitor_github:
git remote add repetitor_github https://github.com/sergeimoiseev/repetitor.git

удалю все из папки repetitorapp
cd /var/www/repetitorapp
sudo -u repetitor -H git clone git://github.com/sergeimoiseev/repetitor.git

все заново
на github создал пустой репозиторий

в c:\Users\Sergei\Projects\repetitor\
скопировал пример архивом отсюда https://github.com/phusion/passenger-python-flask-demo
распаковал в c:\Users\Sergei\Projects\repetitor\
- там сделал репозиторий, изменения скоммитил, отправил https://github.com/sergeimoiseev/repetitor.git
-успешно

выполнил 
sudo -u repetitor -H git clone git://github.com/sergeimoiseev/repetitor.git
теперь все в папке
/var/www/repetitorapp/repetitor/repetitor$ ls
app.py  LICENSE.md  README.md  templates
/var/www/repetitorapp/repetitor/repetitor$ ls -a        
.  ..  app.py  .git  .gitignore  LICENSE.md  README.md  templates

----
при каждом обновлении нужно 
1. удалить весь код
ubuntu@ip-172-31-25-197:/var/www/repetitorapp$ sudo rm -rf repetitor/
2. склонировать новый код с гитхаба
ubuntu@ip-172-31-25-197:/var/www/repetitorapp/repetitor$ sudo -u repetitor -H git clone git://github.com/sergeimoiseev/repetitor.git

получаем:
ubuntu@ip-172-31-25-197:/var/www/repetitorapp/repetitor$ ls -a
.  ..  app.py  .git  .gitignore  LICENSE.md  passenger_wsgi.py  README.md  templates
 - все как должно быть

запускаем:
cd /var/www/repetitorapp/repetitor
sudo passenger start
-
ошибка
ubuntu@ip-172-31-25-197:/var/www/repetitorapp/repetitor$ sudo passenger start
=============== Phusion Passenger Standalone web server started ===============
PID file: /var/www/repetitorapp/repetitor/passenger.3000.pid
Log file: /var/www/repetitorapp/repetitor/passenger.3000.log
Environment: development
Accessible via: http://0.0.0.0:3000/

You can stop Phusion Passenger Standalone by pressing Ctrl-C.
Problems? Check https://www.phusionpassenger.com/library/admin/standalone/troubleshooting/
===============================================================================
App 5130 stderr: stdin: is not a tty
App 5130 stdout: 


и на странице http://54.213.157.107/ ничего не обновляется
(вероятно, названия папок не те)
файла Passengerfile.json просто нет


-----
все удалил, заново взял с гитхаба - уже с файлом Passengerfile.json
поменял права 
sudo chown repetitor: Passengerfile.json
и в папке с кодом запустил
sudo passenger start

- работает - страничка видна
------------------
-правки в коде--
редактирую локальный репозиторий
изменения пушнул в гитхабовский репозиторий
с сервера получаю изменения командой
sudo git fetch origin
sudo git reset --hard origin/master

(ubuntu@ip-172-31-25-197:/var/www/repetitorapp/repetitor$ sudo git reset --hard origin/master                                                                    
HEAD is now at 8641d6a editing html to test server code updating procedure)
-получилось вроде бы

перезапускаю веб-приложение командой

sudo passenger-config restart-app $(pwd)

(ubuntu@ip-172-31-25-197:/var/www/repetitorapp/repetitor$ sudo passenger-config restart-app $(pwd)
Restarting /var/www/repetitorapp/repetitor/public (production))
 - получилось - веб-страничка обновляется


03.01.2016
создал локальный репозиторий взяв с гита текущий
 командой
git clone --branch=master https://github.com/sergeimoiseev/repetitor.git code

файлы теперь в папке c:\Users\Sergei\Projects\repetitor\code\

настраиваю быстрый слив на Гитхаб

просто установил AutoHotkey и настроил "lll" на логин
а "ppp" на подстановку пароля к гитхабу - работает

по туториалу flask отредактировал app.py (старый - в app_old.py)
и еще несколько файлов - получился примитивный блог с одним пользователем.
отредактировал C:\Users\Sergei\Projects\repetitor\passenger_wsgi.py
работает и локально с flask и на амазоновском сервере 
(и там локально без passenger, и там на внешнем IP c passanger)

эту папку копирую в dropbox - как выжный этап.