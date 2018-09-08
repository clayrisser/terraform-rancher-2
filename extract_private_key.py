#!/usr/bin/python3

import json, sys, os

class ExtractPrivateKey():
    def main(self, argv):
        self.write_private_key()
        self.wipe_private_key()
        print('extracted private key for ' + self.name)

    @property
    def tfstate(self):
        tfstate_path = os.path.abspath('terraform.tfstate')
        tfstate = None
        with open(tfstate_path, 'r') as f:
            tfstate = json.load(f)
        return tfstate

    @property
    def private_key(self):
        private_key_pem = None
        tls_private_key = self.tfstate['modules'][0]['resources']['tls_private_key.' + self.name]
        private_key_pem = tls_private_key['primary']['attributes']['private_key_pem']
        return private_key_pem

    @property
    def domain(self):
        cloudconfig = self.tfstate['modules'][0]['resources']['data.template_file.cloudconfig']
        return cloudconfig['primary']['attributes']['vars.domain']

    @property
    def name(self):
        cloudconfig = self.tfstate['modules'][0]['resources']['data.template_file.cloudconfig']
        return cloudconfig['primary']['attributes']['vars.name']

    def write_private_key(self):
        rsa_path = os.path.abspath(
            self.name + '_' + self.domain.replace('.', '_') + '_rsa'
        )
        with open(rsa_path, 'w') as f:
            f.writelines(self.private_key)
        os.chmod(rsa_path, 0o600)

    def wipe_private_key(self):
        tfstate = self.tfstate
        tls_private_key = tfstate['modules'][0]['resources']['tls_private_key.' + self.name]
        tls_private_key['primary']['attributes']['private_key_pem'] = ''
        tfstate_path = os.path.abspath('terraform.tfstate')
        with open(tfstate_path, 'w') as f:
            json.dump(tfstate, f, indent=4)

ExtractPrivateKey().main(sys.argv)
