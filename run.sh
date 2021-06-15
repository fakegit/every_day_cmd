START_CMD="uvicorn server:app --port 12308"
PYTHON_PATH="python3"
VENV_PATH="venv"
LOG_PATH="/tmp/every_day_cmd.log"
SOFT="wkhtmltopdf"

echo 'Setup virtual environment'
$PYTHON_PATH -m venv venv
if [ ! -d $VENV_PATH ]; then
	source venv/bin/activate
	$PYTHON_PATH -m pip install -r requirements
fi

echo 'Installing '$SOFT
if [[ "$OSTYPE" =~ ^darwin ]]; then
	if [[ ! $(brew list | grep $SOFT) ]]; then
		brew install --cask $SOFT
	fi
elif [[ "$OSTYPE" =~ ^linux ]]; then
	SYSTYPE=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

	if [[ $SYSTYPE == '"CentOS Linux"' ]]; then
		if [[ ! $(sudo yum list | grep $SOFT) ]]; then
			sudo yum -y install $SOFT
		fi
	elif [[ $SYSTYPE == '"Ubuntu"' ]]; then
		if [[ ! $(sudo apt-get list | grep $SOFT) ]]; then
			sudo apt-get -y install $SOFT
		fi
	else
		echo 'unknown linux system?'
		exit
	fi
else
	echo 'unknown system?'
	exit
fi

echo 'Ready'
ps -ef | grep "$START_CMD" | grep -v grep | awk '{print $2}' | xargs kill -9
echo 'Starting'
nohup $START_CMD >$LOG_PATH 2>&1 &
sleep 3
cat $LOG_PATH
