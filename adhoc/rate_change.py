#!/usr/bin/env python
import requests
import sys

qcontrol_url = 'http://tools.tagged.com/api/v1/qcontrol/{0}'
cookie = {'TOOL':'ot6lniu1fa6decbtsdpoa2gh72'}

def main():
    if (len(sys.argv) < 3):
        print('Usage: {0} [QUEUE_NAME] [RATE_PER_SEC]'.format(sys.argv[0]))
        exit(1)

    inputs = {'admin':            'dbacron',
              'maxRatePerSecond': int(sys.argv[2])
    }

    r = requests.put(qcontrol_url.format(sys.argv[1]),
                     params = inputs, cookies = cookie)
    if r.status_code != 200:
        print('post unsuccessful, code = {0}'.format(str(r.status_code)))
        exit(1)
    exit(0)

if __name__ == '__main__':
    main()
