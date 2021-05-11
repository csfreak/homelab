FROM python:alpine

WORKDIR /update
COPY requirements.txt .
COPY update.py .

RUN pip install -r requirements.txt

ENTRYPOINT [ "python", "update.py" ]
CMD ["wordpress-base"]