from flask import Flask, request, jsonify, render_template
import csv
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv
import pytz
from influxdb_client_3 import (
    InfluxDBClient3, InfluxDBError, Point, WritePrecision,
    WriteOptions, write_client_options, SYNCHRONOUS)

load_dotenv()  #load the env file

app = Flask(__name__)

INFLUX_HOST = os.getenv('INFLUX_HOST')
INFLUX_TOKEN = os.getenv('INFLUX_TOKEN')
INFLUX_DB = os.getenv('INFLUX_DB')


if INFLUX_TOKEN is None:
    raise ValueError("INFLUX_TOKEN environment variable is not set")


def save_to_csv(temperature, humidity):
    with open('data.csv', 'a', newline='') as csvfile:
        fieldnames = ['time','temperature', 'humidity']  
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)  

        # Check if the file is empty to write header  
        csvfile.seek(0, 2)  # Move the cursor to the end of the file  
        if csvfile.tell() == 0: # If file is empty, write header
            writer.writeheader()
        
        timezone = pytz.timezone("America/Bogota")
        now = datetime.now(timezone)
        formatted_time = now.strftime("%Y-%m-%d %H:%M:%S")
        
        writer.writerow({'time': formatted_time, 'temperature': temperature, 'humidity': humidity})

def save_to_influxdb(temperature, humidity):
    print("Testing the values types", flush=True)
    print(temperature, humidity)
    print(type(temperature), type(humidity))
   
    points = [
        Point("values_sensor")
        .tag("device", "esp32-home")
        .field("temperature", temperature)
        .field("humidity", humidity)
    ]

    try:
        with InfluxDBClient3(host=INFLUX_HOST, token=INFLUX_TOKEN, database=INFLUX_DB) as client:
            client.write(points, write_precision='s')
        print("✅ Data saved to InfluxDB successfully.")
    
    except Exception as e:
        print(f"❌ Error saving data to InfluxDB: {e}")


    


@app.route('/')
def index():
    print(f"connected to {INFLUX_DB}", flush=True)
    print(f"connected to {INFLUX_HOST}")
    return jsonify("main page"),200


@app.route('/data', methods=['POST'])
def data_received():
    print("request arrive", flush=True )
    data = request.get_json()
    humidity = data['humidity']
    temperature = data['temperature']
    
    print(f"Humidity: {humidity}%, temperature: {temperature}°C")
    save_to_csv(temperature,humidity)
    save_to_influxdb(temperature,humidity)

    return 'Data received', 200


if __name__ == '__main__':
    print("Starting server...")
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)