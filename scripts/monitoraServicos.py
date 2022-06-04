# Instalar flask e flask_restful
from flask import Flask
from flask_restful import Resource, Api, reqparse
import subprocess

app = Flask(__name__)
api = Api(app)
 
# Define parser and request args
parser = reqparse.RequestParser()
parser.add_argument('service_name', type=str)

class Service(Resource):
   def post(self):
        args = parser.parse_args()
        service_name = args['service_name']

        if service_name == 'servico1':

            service = "servico1.service"
            p =  subprocess.Popen(["systemctl", "is-active",  service], stdout=subprocess.PIPE)
            (output, err) = p.communicate()
            output = output.decode('utf-8').strip()

            if 'active' ==  output:
                return '1'
            else:
                return '0'

        if service_name == 'servico2':

            service = "servico2.service"
            p =  subprocess.Popen(["systemctl", "is-active",  service], stdout=subprocess.PIPE)
            (output, err) = p.communicate()
            output = output.decode('utf-8').strip()

            if 'active' ==  output:
                return '1'
            else:
                return '0'

api.add_resource(Service, '/status')

if __name__ == '__main__':
     app.run(host='',port='')
