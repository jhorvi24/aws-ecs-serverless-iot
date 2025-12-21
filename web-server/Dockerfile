FROM python:3.14-slim
WORKDIR /webserver-IoT
COPY requirements.txt /webserver-IoT/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY . /webserver-IoT
CMD ["python", "./server-iot.py"]

