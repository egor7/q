#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
import sys
from pprint import pprint
from oauth2client import client
from googleapiclient import sample_tools
import argparse
import os.path

def main(argv):
  service,flags=sample_tools.init('','blogger','v3',__doc__,__file__,scope='https://www.googleapis.com/auth/blogger')
  try:
    parser = argparse.ArgumentParser()
    parser.add_argument("blog", help="blog folder")
    parser.add_argument("post", help="post file")
    args = parser.parse_args()
    blogpost = os.path.join(args.blog,args.post)
    print(blogpost)

    with open(args.blog+".id", "r") as f: blog_id = int(f.read())
    with open(blogpost,        "r") as f: content = f.read()
    with open(blogpost+".tag", "r") as f: labels = f.read().splitlines()
    d = {'title': args.post.replace("-", " "), 'content': content, 'labels': labels}
    h = blogpost+".id"
    if os.path.isfile(h):
        with open(h, "r") as f: (service.posts().patch(blogId=blog_id, postId=int(f.read()), body=d).execute())
    else:
        with open(h, "w") as f: f.write(str(service.posts().insert(blogId=blog_id, body=d).execute()["id"]))

  except client.AccessTokenRefreshError:
    print ('The credentials have been revoked or expired, please re-run the application to re-authorize')
if __name__ == '__main__':
  main(sys.argv)
