# Python and Flask Workshop
Today we will be building the image and running the container for Python and Flask.

* What's Python? - https://www.w3schools.com/python/python_intro.asp
* What's Flask? - 

You will use Flask to build a web application to interact with your MariaDB servier.

#### Steps
1. Create a free github user account - https://github.com/join?plan=free&source=pricing-card-free
1. Install SublimeText for syntax coloring - https://www.sublimetext.com/
1. Review Dockerfile
1. Install Flask


## Install Flask

1.  In the command line, move to our class repo
    * `cd docker/python-flask`
1.  Build the docker image `docker build -t munners17/python-flask .`
1.  Create a docker network to allow different docker containers to easily communicate with each other over an IP network. Then bind the existing mariadb container to the newly created network bridge.
    * `docker network create --driver=bridge db-network`
    * `docker network connect db-network mariadb-diveshop`
1.  Create and run the container, connecting it to the shared network, db-network
    *`docker run --name python-app -p 5000:5000 --mount type=bind,source="${PWD}"/webapp,target=/app --net db-network munners17/python-flask`

## Flask Workshop

### Create the first app
Edit the file called index.py

```
from flask import Flask
app = Flask(__name__)
 
@app.route("/")
def hello():
   return "Hello World!"
 
if __name__ == "__main__":
   app.run(debug=True)
```
Open http://localhost:5000/ in your webbrowser, and “Hello World!” should appear.

### Creating URL routes
URL Routing makes URLs in your Web app easy to remember.

We will now create some URL routes:
- /destinations
- /customers/
- /members/name/

Copy the code below into index.py
```
from flask import Flask, render_template, request, redirect
app = Flask(__name__)
 
@app.route("/")
def index():
   return "Index!"
 
@app.route("/destinations")
def dest():
   return "Destinations!"
 
@app.route("/customers")
def customers():
   return "Customers"
 
@app.route("/customers/<string:name>/")
def getMember(name):
   return name
 
if __name__ == "__main__":
   app.run(debug=True)
```
Try the URLs in your browser:

- http://127.0.0.1:5000/
- http://127.0.0.1:5000/hello
- http://127.0.0.1:5000/members
- http://127.0.0.1:5000/members/Jordan/
    
    
### Rendering HTML

Flask can generate HTML by referencing template files you locate in the /templates/ subdirectory. Use the render_template() function to call on the appropriate template and pass it any data you want displayed.

Create show_c.html in the templates subdirectory:
```
<html>
<head><title>INFO 257 workshop show data</title>
</head>

<h1> Hello {{customer}}</h1>

</body>
</html>
```

Edit the customers/name route in the Flask app to render the new template:

```
@app.route("/customers/<string:name>/")
def getMember(name):
   return render_template(
   'show_c.html',customer=name)
```

You can then open to see an HTML formatted page : http://127.0.0.1:5000/customers/Jackson/

### Passing Data 
The template HTML file can reference data passed by render_template() by utilizing a special syntax defined by the [Jinja2 template](https://jinja.palletsprojects.com/en/2.11.x/templates/) engine. You implemented this in the step above by passing the `name` variable to show_c.html as `customer`.

You can pass any data the python/flask app has access to, such as a local variable:

```
@app.route("/customers")
def customers():
   name_local="Keith Lucas"
   return render_template('show_c.html',customer=name_local)
```
You can then open to see an HTML formatted page with the local variable passed: http://127.0.0.1:5000/customers


#### Task: Create a Template
1.  Create a new template file (show_d.html) that prints out a destination name of your choosing when accessing this URL: `localhost:5000/destinations`


### Accessing the Database

Flask extends a library that allows for connecting to a database, SQLAlchemy: https://flask-sqlalchemy.palletsprojects.com/en/2.x/quickstart/

You will be able to execute SQL querires and receive the results programatically (similar to your DataGrip client).

First, update the python app (index.py) to connect to your Diveshop database via SQLAlchemy by adding the following lines:

```
from flask import Flask,render_template, request, redirect
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:mypass@mariadb-diveshop.db-network/Diveshop'
db = SQLAlchemy(app) 

@app.route("/database")
def index():
   result = db.engine.execute("SELECT DATABASE()")
   names = [row[0] for row in result]
   return names[0] 

```
`Diveshop` should be displayed when accessing : http://127.0.0.1:5000/database

### List Customers in the Database

Edit the show_c.html template to display all the customers in Diveshop. Utilize the Jinja2 template syntax referenced above to loop through the customers passed by the flask app, creating a new HTML table row for each customer.

**show_c.html**:

```
<html>
<head><title>INFO 257 workshop show data</title>
</head>

<body>
	<table class="table">
		<tr>
			<th>Customer Name</th>
			<th>City</th>
			<th>State</th>
		</tr>
			{% for ui_row in customers %}
		<tr>
			<td>{{ ui_row.Cust_Name }}</td>
			<td>{{ ui_row.City }}</td>
			<td>{{ ui_row.State }}</td>
		</tr>
			{% endfor %}
	</table>
</body>
</html>
```
**index.py:**:

Now query the database to select all customers (all rows in DIVECUST relation) in the web app and pass to rendering engine for show_c.html. Update the /customers URL:

```
@app.route("/customers")
def customers():
    result = db.engine.execute("select * from DIVECUST")
    names = []
    
    for row in result:
        name = {}
        name["Cust_Name"] = row[1]
        name["City"] = row[3]
        name["State"] = row[4]
        names.append(name)

    return render_template('show_c.html',customers=names)
   ```
   ### TASK: List Destinations
   1.  Have all the Diveshop Destinations returned when accessing http://127.0.0.1:5000/destinations
   
   
   ### TODO
   1.  FORM example with Button: FORM submit via button to query the database
   1.  FORM example with free form text field: Capture specific FORM fields and SEARCH DB
   1.  STYLE of HTML
   
