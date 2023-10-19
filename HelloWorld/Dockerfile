FROM python:3.8-alpine
ADD . /code
WORKDIR /code
RUN pip install -r requirements.txt
#CMD python app.py
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=8080" ]
