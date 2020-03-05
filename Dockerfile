FROM python:alpine3.11
WORKDIR /app
RUN pip install flask Flask-SQLAlchemy PyMySQL
EXPOSE 5000
CMD python ./index.py
