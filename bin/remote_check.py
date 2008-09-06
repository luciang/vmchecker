#! /usr/bin/python
# -*- coding: UTF-8 -*-
# vim: set expandtab :


__author__ = 'Alexandru Mosoi, brtzsnr@gmail.com'

import sys
import os
import subprocess
import ConfigParser

import misc


def main():
    if len(sys.argv) == 1:
        print >> sys.stderr, 'Usage: %s homework_config_file' % sys.argv[0]
        sys.exit(1)

    config_file = misc.find_config_file('vmchecker.ini')

    homework = ConfigParser.RawConfigParser()
    homework.read(sys.argv[1])

    config = ConfigParser.RawConfigParser()
    config.read(config_file)

    job = homework.get('DEFAULT', 'Job')

    remote_ip = misc.get_option(config, job, 'RemoteIP')
    assert remote_ip, 'No ip for remote machine'

    remote_queue = misc.get_option(config, job, 'RemoteQueue')
    assert remote_queue, 'No queue on remote machine'

    remote_user = misc.get_option(config, job, 'RemoteUser')
    assert remote_user, 'No remote user supplied'

    remote_notifier = misc.get_option(config, job, 'RemoteNotifier')
    assert remote_notifier, 'No notifier supplied'

    return_code = subprocess.call([
        'scp',           # program to invoke
        sys.argv[1],     # config file to copy 
        '%s@%s:%s' % (remote_user, remote_ip, remote_queue)])
    if return_code != 0:
        print >> sys.stderr, 'Eroare la copierea temei pe masina de testare'
        sys.exit(1)

    return_code = subprocess.call([
        'ssh',
        '%s@%s' % (remote_user, remote_ip),
        os.path.join(remote_queue, remote_notifier)])
    if return_code != 0:
        print >> sys.stderr, 'Nu am putut invoca programul de notificare'
        sys.exit(1)

    print >> sys.stderr, 'Tema a fost copiata cu succes'


if __name__ == '__main__':
    main()