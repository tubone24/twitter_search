import json
import os
import boto3
import base64
import logging
import traceback
from botocore.exceptions import ClientError
from requests_oauthlib import OAuth1Session
import requests

from datetime import datetime, timedelta, timezone

JST = timezone(timedelta(hours=+9), 'JST')

SECRET_NAME = os.environ.get('SECRET_NAME')
level = os.environ.get('LOG_LEVEL', 'ERROR')
keyword = os.environ.get('KEYWORD', 'test')
slack_webhook_url = os.environ.get('SLACK_WEBHOOK_URL', '')
logger = logging.getLogger()


def logger_level():
    if level == 'CRITICAL':
        return 50
    elif level == 'ERROR':
        return 40
    elif level == 'WARNING':
        return 30
    elif level == 'INFO':
        return 20
    elif level == 'DEBUG':
        return 10
    else:
        return 0


def _search_tweet(target_word, twitter, exclude=""):
    now = datetime.now(JST).strftime("%Y-%m-%d_%H:00:00_JST")
    one_hour_ago = (datetime.now(JST) - timedelta(hours=1)).strftime("%Y-%m-%d_%H:00:00_JST")
    if exclude != "":
        exclude_account = f" -from:{exclude}"
    else:
        exclude_account = ""

    params = {
        "q": target_word + " -RT" + exclude_account,
        "since": one_hour_ago,
        "until": now,
        "count": 100,
        "lang": "ja"
    }
    twitter_search_url = 'https://api.twitter.com/1.1/search/tweets.json'
    req = twitter.get(twitter_search_url, params=params)

    if req.status_code == 200:
        tweets = req.json()['statuses']
        return tweets
    else:
        logger.error(req.status_code, req.text)
        return ["error"]


def push_notify_to_slack(web_hook_url, text):
    payload = json.dumps({
        "text": text
    })
    requests.post(web_hook_url, data=payload)


def get_secret():
    session = boto3.session.Session()
    client = session.client(
        service_name="secretsmanager"
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=SECRET_NAME
        )
    except ClientError as e:
        raise e
    else:
        if "SecretString" in get_secret_value_response:
            secret = get_secret_value_response["SecretString"]
        else:
            secret = base64.b64decode(get_secret_value_response["SecretBinary"])

    return secret


def get_title():
    return (datetime.now(JST) - timedelta(hours=1)).strftime("%Y-%m-%d_%H:00:00_JST") + "～" + datetime.now(
        JST).strftime("%Y-%m-%d_%H:00:00_JST") + "の「" + keyword + "」Twitter検索結果です"


def create_format_text(tweet):
    logger.debug(tweet)
    tweet_text = tweet["text"]
    tweet_user_name = tweet["user"]["name"]
    tweet_user_screen_name = tweet["user"]["screen_name"]
    tweet_created_at = datetime.strptime(tweet["created_at"], '%a %b %d %H:%M:%S +0000 %Y').astimezone(
        JST).strftime("%Y-%m-%d %H:%M:%S")
    tweet_user_id = tweet["user"]["id_str"]
    tweet_status_id = tweet["id_str"]
    tweet_full_link = f"http://twitter.com/{tweet_user_id}/status/{tweet_status_id}"
    return f"```{tweet_created_at} @{tweet_user_screen_name}({tweet_user_name})\n{tweet_text}\n{tweet_full_link}```"


def lambda_handler(event, _):
    logger.setLevel(logger_level())

    logger.debug(event)

    try:
        secret = json.loads(get_secret())
        logger.debug(secret)

        twitter = OAuth1Session(
            secret["api_key"],
            secret["api_secret"],
            secret["access_token"],
            secret["access_token_secret"]
        )
        keyword_tweets = _search_tweet(keyword, twitter)
        first_text = get_title()
        push_notify_to_slack(slack_webhook_url, first_text)
        for tweet in keyword_tweets:
            format_text = create_format_text(tweet)
            push_notify_to_slack(slack_webhook_url, format_text)

    except Exception as e:
        logger.error(traceback.format_exc())
        raise e
