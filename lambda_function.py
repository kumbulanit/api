import json
import boto3
import uuid
from confluent_kafka import Producer


def lambda_handler(event, context):

    AWS_BUCKET_NAME = 'sandbox-event-ingest'
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(AWS_BUCKET_NAME)
    
    if event.get('rawPath') == '/v1/stock-update':
        path = f'stock-updates/{str(uuid.uuid4())}.json'

        print('writing stock update to s3')
        write_data_to_s3(
            data=event.get('body', {}),
            bucket=bucket,
            path=path
        )
        print('done')
        
        print('publishing to kafka')
        post_data_to_kafka_topic(
            data=event.get('body', {}),
            kafka_topic='stock-update'
        )
        print('done')
        body = {
            "uploaded": "true",
            "bucket": AWS_BUCKET_NAME,
            "path": path,
        }
        
        return {
            "statusCode": 200,
            "body": json.dumps(body)
        }
        
    if event.get('rawPath') == '/v1/price-update':
        path = f'price-updates/{str(uuid.uuid4())}.json'
        
        print('writing price update to s3')
        write_data_to_s3(
            data=event.get('body', {}),
            bucket=bucket,
            path=path
        )
        print('done')

        print('publishing to kafka')
        post_data_to_kafka_topic(
            data=event.get('body', {}),
            kafka_topic='price-update'
        )
        print('done')
        
        body = {
            "uploaded": "true",
            "bucket": AWS_BUCKET_NAME,
            "path": path,
        }
        
        return {
            "statusCode": 200,
            "body": json.dumps(body)
        }

    raise Exception('Something went wrong')

def delivery_report(err, msg):
    """ Called once for each message produced to indicate delivery result.
        Triggered by poll() or flush(). """
    if err is not None:
        print('Message delivery failed: {}'.format(err))
    else:
        print('Message delivered to {} [{}]'.format(msg.topic(), msg.partition()))


def write_data_to_s3(data, bucket, path):
    bucket.put_object(
        ContentType='application/json',
        Key=path,
        Body=data,
    )
    
def post_data_to_kafka_topic(data, kafka_topic):
    
    # This is not good.
    # plain text username and password is a no go
    # this is for POC purposes only
    # ideally, secrets should be read from AWS secret manager
    producer = Producer({
        'bootstrap.servers': 'pkc-e8mp5.eu-west-1.aws.confluent.cloud:9092',
        'sasl.mechanisms': 'PLAIN',
        'security.protocol': 'SASL_SSL',
        'sasl.username': 'OCWFZ3P3UHH4UU5V',
        'sasl.password': 'HjCGeyDQmst4kG/im8W/4Z/fGxj9wDtzxGDkHIWpYK/UfICC2lu6UGKnhD2atEGd'
    })
    producer.produce(kafka_topic, data, callback=delivery_report)
    producer.flush()
