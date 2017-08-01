import glob
import argparse
import htmlentities
import os
import re
import urllib
import json
import requests

import xml.etree.ElementTree as ET
from pprint import pprint

import boto3
import botocore

from mightylib.persistence.kv.s3 import S3Dict
from mightylib.serializers import raw_serializer
bucket = S3Dict('ms-android-automation-outputs', serializer=raw_serializer)

s3_source_bucket = 'ms-android-automation-outputs'

#Advertiser regex
advertizer_regex = ('advertiser_name', re.compile(r"(?:One reason you're seeing this ad is that|You're seeing this ad because) (.*?) wants to reach"))

# Target regex
target_regex = ('target_audience', re.compile(r"wants to reach (?:people who )?(.*?)\."))
# You're seeing this ad because Your Answer Spot wants to reach men ages 18 to 64 who live or were recently in the United States .

# Alt target
alt_target_regex = ('alt_target', re.compile(r"There may be other reasons you're seeing this ad, including that .*? wants to reach (.*?)\."))

feature_regexes = [advertizer_regex, alt_target_regex, target_regex]

def in_order_traversal(node, visitor_func):
  visitor_func(node)
  for c in node:
    in_order_traversal(c, visitor_func)

def convert_fb_number(num_str):
  base = 1
  if num_str.endswith('k'):
    base = 1000
  elif num_str.endswith('million'):
    base = 10**6

  number = None
  try:
    number = int(num_str.strip('k').strip('million').replace(',', '').strip()) * base
  except:
    return number
  return number

def extract_suggested_app_node(ad_xml):
  suggested_node = {"value" : None}
  tree = ET.fromstring(ad_xml)
  def visit_node(e):
      if e.attrib.get('text', False):
        if e.attrib.get('text') == 'Suggested App':
            suggested_node["value"] = e
  in_order_traversal(tree, visit_node)
  return suggested_node["value"]

def extract_social_info(ad_text):
  out = {}
  text = " ".join(ad_text).lower()
  #Over 177 million people use this
  match = re.search(' ([0-9,k]*( million)?) people use this', text)
  if match:
    out['number_of_people_that_use'] = convert_fb_number(match.group(1))

  match = re.search(' ([0-9,k]*) likes?', text)
  if match:
    out['number_of_likes'] = convert_fb_number(match.group(1))

  match = re.search(' ([0-9,k]*) shares?', text)
  if match:
    out['number_of_shares'] = convert_fb_number(match.group(1))

  return out

def extract_fb_ad_text(ad_xml):
  tree = ET.fromstring(ad_xml)
  ad_text = []
  ad_info = {}

  def visit_node(e):
      if e.attrib.get('text', False):
          ad_text.append(e.attrib['text'].encode('utf8').replace('\xc2\xa0', ' ').strip())
  in_order_traversal(tree, visit_node)
  remove_preceeding = ['Sponsored\xe2\x80\xa2everyone']
  removable_prefixes = ['Search', 'Suggested Post', 'Like', 'Comment', 'Share']

  removable_suffixes = ['Like', 'Comment', 'Share']
  # Remove trailing numbers
  ad_info.update(extract_social_info(ad_text))

  for removable in remove_preceeding:
    if removable in ad_text:
      ad_text = ad_text[ad_text.index(removable)+1:]

  while ad_text[0] in removable_prefixes:
    ad_text.pop(0)

  end_index = None
  for i in range(len(ad_text) - 1, 0, -1):
    if ad_text[i] in removable_suffixes:
      end_index = i

  if end_index is not None:
    ad_text = ad_text[:end_index]

  ad_info['ad_text'] = " ".join(ad_text)

  return ad_info

def extract_fb_targeting_info(targeting_xml):
  if targeting_xml is None:
    return {}

  tree = ET.fromstring(targeting_xml)

  targeting_text = []
  def visit_node(e):
      if e.attrib.get('content-desc', False):
          targeting_text.append(e.attrib['content-desc'].encode('utf8').replace('\xc2\xa0', ' ').strip())

  in_order_traversal(tree, visit_node)

  cleaned_text = " ".join(targeting_text)
  info = {}
  for name, regex in feature_regexes:
    match = regex.search(cleaned_text)
    if match:
      info[name] = match.group(1).strip()
  return info

def transform_targeting_info(info):
  def age_min(x):
    match = re.search('ages ([0-9].*?)[ ,\.]', x)
    if match:
      return int(match.group(1))
  def max_age(x):
    match = re.search('ages (?:[0-9].*?) to ([0-9].*?)[ ,\.]', x)
    if match:
      return int(match.group(1))
  def live_in(x):
    match = re.search('(?:live|are) (?:near|in) (.*?)$', x)
    if match:
      return match.group(1)
  def were_near(x):
    match = re.search('live or were recently (?:near|in) (.*?)$', x)
    if match:
      return match.group(1)
  def education(x):
    match = re.search('the education level "(.*?)"', x)
    if match:
      return match.group(1)
  def customer_sim(x):
    return True if 'may be similar to their customers' in x else None
  def customer_engagement(x):
    match = 'have visited their website or used one of their apps' in x
    if match:
      return True
  def fb_audience(x):
    match = re.search('are part of an audience called "(.*?)"', x)
    if match:
      return match.group(1)
  def language(x):
    match = re.search('speak "(.*?)"', x)
    if match:
      return match.group(1)
  def relationship_status(x):
    match = re.search('people with relationship status "(.*?)"', x)
    if match:
      return match.group(1)
  def interested_in(x):
    match = re.search('people interested in (.*)$', x)
    if match:
      return map(lambda x: x.strip().lower(), match.group(1).split("and"))
  def proximity_to_business(x):
    return True if 'were recently near their business' in x else None

  identifiers = [
    ('gender', lambda x: 'men' if x.startswith('men') else None),
    ('gender', lambda x: 'female' if x.startswith('female') else None),
    ('min_age', age_min),
    ('max_age', max_age),
    ('location', live_in),
    ('location', were_near),
    ('similar_to_existing_users', customer_sim),
    ('education', education),
    ('existing_users', customer_engagement),
    ('facebook_audience', fb_audience),
    ('language', language),
    ('relationship_status', relationship_status),
    ('interests', interested_in),
    ('proximity_to_business', proximity_to_business),

  ]
  target = {}
  audiencies = []
  if 'target_audience' in info:
    audiencies.append(info['target_audience'])
  if 'alt_target' in info:
    audiencies.append(info['alt_target'])

  for audience in audiencies:
    for key, func in identifiers:
      r = func(audience)
      if r is not None:
        target[key] = r
  return target

def get_ad_file(ad_id, file_name, loc):
  content = None
  full_path = os.path.join(ad_id, file_name)
  if loc == "local":
    if os.path.isfile(full_path):
      with open(full_path, 'rb') as f:
        content = f.read()
  else:
    try:
      bucket = boto3.resource('s3').Bucket(s3_source_bucket)
      content = bucket.Object('{}/{}'.format(ad_id, file_name)).get()['Body'].read()
    except botocore.exceptions.ClientError:
      pass

  return content.strip() if content else None

def pull_in_text_field(ad, ad_id, loc, field, as_field=None):
  if as_field is None:
    as_field = field
  value = get_ad_file(ad_id, field, loc)
  if value:
    ad[as_field] = value

def bounds(bounds):
  return map(int, filter(lambda x: x, re.split('\,|\]|\[', bounds)))

def get_bounds(ad_xml):
    suggested_node = extract_suggested_app_node(ad_xml)
    if not hasattr(suggested_node, 'attrib'):
        return None
    ad_bounds=bounds(suggested_node.attrib['bounds'])
    return ad_bounds

def extract_suggested_app_node(ad_xml):
  suggested_node = {"value" : None}
  tree = ET.fromstring(ad_xml)
  def visit_node(e):
      if e.attrib.get('text', False):
        if e.attrib.get('text') == 'Suggested App':
            suggested_node["value"] = e
  in_order_traversal(tree, visit_node)
  return suggested_node["value"]

def check_bounds(ad_id, ad_xml):
  """ Check ad bounds and remove screenshots if
  the ad isn't close to the center.
  """
  ad_bounds = get_bounds(ad_xml)
  if not ad_bounds or ad_bounds[1] >= 900:  #Screenshot not good
      print 'Oh no... bad ad'
      bucket = S3Dict('ms-android-automation-outputs', serializer=raw_serializer)
      screenshot_loc = '{}/screenshot.png'.format(ad_id)
      if screenshot_loc in bucket:
          bucket['{}/bad_screenshot.png'.format(ad_id)] = bucket[screenshot_loc]
          del bucket['{}/screenshot.png'.format(ad_id)]
      bucket['{}/bad_capture'.format(ad_id)] = ""
      return False
  else:
      print 'Good Ad!'
      #Continue and keep screenshot
      return True

def process_fb_add(ad_id, loc='local', store=True):
  ad = {'ad_id' : ad_id , 'ad_type': 'mobile_app', 'source_app_identifier' : 'com.facebook.katana'}
  if loc == 'local':
    day, ad_suffix = filename.split("/")[-2:]
    ad['ad_id'] = 'ads/{}/{}'.format(day, ad_suffix)

  ad_file = get_ad_file(ad_id, 'ad.xml', loc)
  if not ad_file:
    raise Exception("Ad xml not found")

  pkg = get_ad_file(ad_id, 'package', loc)
  if not pkg or pkg == 'com.facebook.orca':
    print "Skipping ad {} as it's not a mobile app ad.".format(ad_id)
    return

  pull_in_text_field(ad, ad_id, loc, 'fb_account', 'facebook_account')
  pull_in_text_field(ad, ad_id, loc, 'google_account')
  pull_in_text_field(ad, ad_id, loc, 'android_device', 'android_device_sn')

  ad['advertised_app_identifier'] = pkg
  ad_text_extract = extract_fb_ad_text(ad_file)

  ad.update(ad_text_extract)

  targeting_extract = extract_fb_targeting_info(get_ad_file(ad_id, 'targeting.xml', loc))
  for target, value in transform_targeting_info(targeting_extract).iteritems():
    ad['target_{}'.format(target)] = value

  if store:
    send_fb_ad_to_varys(ad)
    send_fb_ad_to_s3(ad)
  return ad

def send_fb_ad_to_s3(ad):
  bucket = boto3.resource('s3').Bucket(s3_source_bucket)
  bucket.Object('{}/{}'.format(ad['ad_id'], 'processed_ad.json')).put(Body=json.dumps(ad))

def send_fb_ad_to_varys(ad):
  print "Sending ad {} to varys".format(ad['ad_id'])
  end_point = 'https://mightysignal.com/android_ad'
  token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo4NzIsInJlZnJlc2hfdG9rZW4iOiIiLCJleHAiOiIyMDI3LTAyLTE1VDE4OjI0OjM5LjU3NS0wODowMCJ9.2hWgR3rKckiM6iHJBIB0Lll2IbaV2Z_LIj8zCgdDBM0'
  headers = {'Authorization': token}
  r = requests.put(end_point, data=ad, headers=headers)
  if r.status_code == 200:
    print "Varys processed ad {}.".format(ad['ad_id'])
  else:
    print "Varys failed to process ad {}.".format(ad['ad_id'])

def handle_s3_event(event, context):
    key = urllib.unquote_plus(event['Records'][0]['s3']['object']['key']).encode('utf8')
    key_parts = key.split('/')

    if key_parts[-1] in ['package', 'ad.xml', 'targeting.xml']:
      ad_id = '/'.join(key_parts[:-1])
      print "Processing ad {}".format(ad_id)
      process_fb_add(ad_id, loc='s3')


if __name__ == "__main__":
  parser = argparse.ArgumentParser(description='')
  parser.add_argument('--ad-folder', type=str, help='Ad folder (from s3)', required=True)
  parser.add_argument('--store', type=str, help='Send to varys', default=None)
  args = parser.parse_args()
  files = [f for f in glob.iglob('{}/*/*'.format(args.ad_folder))]
  files.sort(reverse=False)
  print 'processing', len(files), 'files'
  for filename in files:
    try:
      ad = process_fb_add(filename, store=args.store is not None)
      if ad:
        pprint(ad)
        print
    except Exception as e:
      print 'failed to process', filename, e
