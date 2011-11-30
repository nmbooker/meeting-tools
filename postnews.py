#! /usr/bin/env python

"""A program to post a news article to a USENET server.

TODO: Allow attachments.
TODO: Allow text encodings other than us-ascii
"""

import sys
import os
import pwd
import getpass
import argparse
import socket
from email.mime.text import MIMEText
import nntplib
from StringIO import StringIO

def main():
    """Main Program"""
    options = get_options()
    message = mime_format_article(options)
    if options.test_output:
        sys.stdout.write(message.as_string())
    else:
        _post_news(options, message)


def get_options():
    """Get the options."""
    parser = argparse.ArgumentParser(
            description="Post articles to a news server."
            )
    parser.add_argument('newsgroups', nargs='+',
            help='list of news groups to post to')
    parser.add_argument('-s', '--subject', dest='subject', required=True,
            metavar='SUBJECT', help='set subject line to SUBJECT')
    parser.add_argument('-t', '--test-output', dest='test_output',
            action='store_true', default=False,
            help="print message and headers on stdout instead of sending")
    parser.add_argument('-u', '--username', dest='username',
            default=None, metavar='USER', help='authenticate as USER',
            )
    parser.add_argument('-n', '--hostname', dest='hostname',
            default='localhost', metavar='NEWSHOST',
            help='post to NEWSHOST instead of localhost',
            )

    options = parser.parse_args()
    options.infile = sys.stdin
    options.from_address = os.getenv('POSTNEWS_FROM', get_local_email_address())
    options.authenticate = (options.username is not None)
    options.body = options.infile.read()
    return options


def mime_format_article(options):
    """Format the posting as a MIME message."""
    message = MIMEText(options.body)
    message['Subject'] = options.subject
    message['From'] = options.from_address
    message['Newsgroups'] = ','.join(options.newsgroups)
    return message

def _post_news(options, message):
    """Post formatted MIME message to the news server."""
    if options.authenticate:
        password = getpass.getpass('News password for %s: ' % options.username)
        server = nntplib.NNTP(options.hostname, user=options.username,
                password=password)
    else:
        server = nntplib.NNTP(options.hostname)
    try:
        sendfile = StringIO(message.as_string())
        server.post(sendfile)
    finally:
        server.quit()

def get_local_email_address():
    """Get the local machine email address."""
    username = getpass.getuser()
    fullname = pwd.getpwnam(getpass.getuser()).pw_gecos.split(',')[0]
    fqdn = socket.getfqdn()
    if '.' not in fqdn:
        fqdn += '.local'
    return '%s <%s@%s>' % (fullname, username, fqdn)

if __name__ == "__main__":
    main()
