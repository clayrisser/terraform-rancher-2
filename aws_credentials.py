from configparser import ConfigParser
import sys
import os

config = ConfigParser()
config.read(os.path.join(os.path.expanduser('~'), '.aws/credentials'))

aws_profile = os.environ.get('AWS_PROFILE')
aws_profile = aws_profile if aws_profile else 'default'

sys.stdout.write(config[aws_profile][sys.argv[1]])
