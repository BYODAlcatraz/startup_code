import re
from mitmproxy import http
from mitmproxy import ctx

class Whitelist:
    def __init__(self):
        self.urls = []

        for re_url in open('/root/.mitmproxy/whitelist.txt'):
            self.urls.append(re_url.strip())

        with open('/root/.mitmproxy/access_denied.html', 'rb') as file:
            self.html_content = file.read()

    def response(self, flow):
        block = True
        for url in self.urls:
            if url in flow.request.pretty_host:
                block = False
        if block:
            flow.response = http.Response.make(403, self.html_content)

addons = [
    Whitelist(),
]
