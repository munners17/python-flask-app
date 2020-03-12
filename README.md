# Python and Flask Workshop
Welcome to the python-flask-app repo.  Today we will be building the image and running the container for **Python** and **Flask**, which can be found in this repo.  But in order to make this general app your own, we will need to learn more about **Github**.

* What's Github? - https://guides.github.com/activities/hello-world/
* What's Python? - https://www.w3schools.com/python/python_intro.asp
* What's Flask? - https://palletsprojects.com/p/flask/
   * Flask API: https://flask.palletsprojects.com/en/1.1.x/api/

You will use Flask to build a web application to interact with your MariaDB servier.

#### Prerequisites
1. Create a free github user account - https://github.com/join?plan=free&source=pricing-card-free
1. Install [SublimeText](https://www.sublimetext.com/) or [Textmate for Mac](https://software.berkeley.edu/textmate) for syntax coloring (or editor of your choosing) 
## Github Primer
1. Complete the Github hello-world activity linked to above: https://guides.github.com/activities/hello-world/ 

## Create your final project webapp
1. From the https://github.com/munners17/python-flask-app repo, click the *Use this template* button
1. Name the repo after a webapp name related to your final project
1. Choose a private repo!  
	*Note:  Feel free to make your project repo public after projects have been turned in*
1. Clone your newly created repo using your method of choice.

## Review the Dockerfile
A Dockerfile is just a text file that that contains all the commands, in order, for building a specific docker image. The Docker Engine will automatically build the image when running the `docker build` command. For the class project, you may have to edit the Dockefile if you have additional dependencies.
   * Dockerfile Reference: https://docs.docker.com/engine/reference/builder/
   * Dockerfile best practices: https://docs.docker.com/develop/develop-images/dockerfile_best-practices/

Some basic Dockerfile commands are:
   * `FROM`: Identifies the base application of the image. A Dockerfile must start with a `FROM` instruction. 
   * `RUN`: Install any dependencies
   * `WORKDIR`: Sets the working directory other commands will work from
   * `CMD`:  Sets the command to be executed when running a container based on this image (not when the image is being built). This in essence identifies the application the container is encapsulating.
   * `COPY`: Adds files from your Docker client’s current directory.
   
Note we are not COPYING python files into the container. Instead we will create a mount point that will allow the webapp/ subfolder on your host (inside this repo) to be shared inside the container, similar to a network mount.

## Build and Start Flask Container
1.  On the command line, move to your previously cloned repo
    * `cd path/to/repo`
1.  Build the docker image `docker build -t munners17/python-flask .`
1.  Create a docker network to allow different docker containers to easily communicate with each other over an IP network. Then bind the existing mariadb container to the newly created network bridge.
    * `docker network create --driver=bridge db-network`
    * `docker network connect db-network mariadb-diveshop`
1.  Create and run the container, connecting it to the shared network, db-network
    * `docker run --name python-app -p 5000:5000 --mount type=bind,source="${PWD}"/webapp,target=/app --net db-network munners17/python-flask`
    * Remember `docker run` CREATES AND STARTS the container. When needing to start the container in the future, use `docker start -a python-app`, since it does not need to be re-created.
1.  Verify the container is Up by checking the STATUS column after executing `docker ps` in another terminal

## Login to your Flask Container
1. Use `docker exec` to start an interactive session inside the container and run the `bash` shell to access the terminal.  Command to login: `docker exec -it python-app bash`
1. Start python and run a few python commands. Hit <enter> after each of the following:

* `python3`
* `4 + 3`
* `x = [1, 2, 3, 4, 5]`
* `print(x)`
* `exit()`

Depending on your skill level, you may want to walk through this introduction: https://www.w3schools.com/python/python_intro.asp

## Flask Workshop

### Update Existing Web App
You will find a basic implementation of the Flask web application framework in `webapp/index.py`. The python container is currently running **index.py**. See what index.py is doing by navigating to http://localhost:5000/

`[CHANGE ME]` should appear in your browser window.

You may have noticed we have not started a Web Server to handle the HTTP traffic from our web app to the browser! Well, Flask is being run in Developmemnt mode which launces its own local web server for testing purposes - this is the web server serving your browser client right now. This is not recommended for a Production environment.

Also notice in **index.py** that debug=True when running the Flask object. This enables the debugger and also allows the server to reload whenever it detects a code change. Try it out by starting to build out your web application:
1.  Use Sublime Text or a text editor of your choice to edit the **index.py** and replace "[CHANGE ME!] with "Hello World!":

```
from flask import Flask
app = Flask(__name__)
 
@app.route("/")
def hello():
   return "Hello World!"
 
if __name__ == "__main__":
   app.run(host="0.0.0.0",debug=True)
```
Open http://localhost:5000/ in your web browser, and “Hello World!” should appear without having to restart the application.

### Creating URL routes
URL routing make URLs in your Web app easy to remember and organize. Use the @route() decorator to bind functions to a specific URL. The function will be called when the URL is accessed by the browser.

We will now create some URL routes:
- /destinations
- /customers/
- /members/name/

Replace the code in **index.py** with the code below
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
   app.run(host="0.0.0.0", debug=True)
```
Try the URLs in your browser:

- http://127.0.0.1:5000/
- http://127.0.0.1:5000/destinations
- http://127.0.0.1:5000/customers
- http://127.0.0.1:5000/customers/Jordan/
    
    
### Rendering HTML

Flask can generate HTML by referencing template files you locate in the /templates/ subdirectory. Use the render_template() function to call on the appropriate template and pass it any data you want to use or display.

Create a file named **show_c.html** in a new /templates/ subdirectory relative to where **index.py** is located (inside `/webapp/):
```
<html>
<head><title>INFO 257 workshop show data</title>
</head>

<h1> Hello {{customer}}</h1>

</body>
</html>
```

Edit the `customers/<string:name>` route in the Flask app to render the new template:

```
@app.route("/customers/<string:name>/")
def getMember(name):
   return render_template(
   'show_c.html',customer=name)
```

You can then open to see an HTML formatted page: http://127.0.0.1:5000/customers/Jackson/

### Passing Data 
The template HTML file can reference data passed by render_template() by utilizing a special syntax defined by the [Jinja2 template](https://jinja.palletsprojects.com/en/2.11.x/templates/) engine. You implemented this in the step above by passing the `name` variable to show_c.html as the variable `customer`.

You can pass any data the python/flask app has access to, such as a local variable. Replace the `/customers` route in **index.py**:

```
@app.route("/customers")
def customers():
   name_local="Keith Lucas"
   return render_template('show_c.html',customer=name_local)
```
You can then open to see an HTML formatted page with the local variable passed: http://127.0.0.1:5000/customers


#### Task: Create a Template
1.  Create a new template file (show_d.html) that displays a Diveshop destination name of your choosing when accessing this URL: `localhost:5000/destinations`


### Accessing the Database

Flask extends the SQLAlchemy library that allows for connecting to a database named : https://flask-sqlalchemy.palletsprojects.com/en/2.x/quickstart/

You will be able to execute SQL querires and receive the results programatically (similar to your DataGrip client).

Use the `SQLALCHEMY_DATABASE_URI` configuration of the Flask object to designate the location and credentials of your mariaDBMS and database name. Note the the docker containers can identify themselves over the Docker network using DNS where their address is <container-name>.<network-name>. In this case, our mariaDB container can be identified using `mariadb-diveshop.db-network`

First, update the web app to connect to your Diveshop database via SQLAlchemy. 
Replace the first 2 lines in **index.py** with the following:
```
from flask import Flask,render_template, request, redirect
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:mypass@mariadb-diveshop.db-network/Diveshop'
db = SQLAlchemy(app) 

@app.route("/database")
def datab():
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

The list of customers in Diveshop should be displayed when accessing: http://127.0.0.1:5000/customers

   ### TASK: List Destinations
   1.  Have all the Diveshop Destinations names and their travel cost display when accessing http://127.0.0.1:5000/destinations
      * Note: Copy+Paste from the Customers logic to allow you to just change the SQL query
   
   ### Forms
   Basic user input is handled by HTTP Forms.
   
   Try letting the user hit a button to choose which list of records to return from the home page.
   
   Create a new template: `index.html`:
   ```
   <html>
  <head>
    <title>INFO 257 Workshop Form</title>
    <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
  </head>

  <body>
    <br>
    
    <form method="POST" action="/customers">

      <div class="form-group">
        <input type="submit" value="List Customers" />
      </div>
    </form>
    
    <br>
    
    <form method="POST" action="/destinations">

      <div class="form-group">
        <input type="submit" value="List Destinations" />
      </div>
    </form>
    
  </body>

</html>
```

### TASK: List Customers and Destinations with Button Click
1.  Update index.py to render the new index.html at the root/home location: http://127.0.0.1:5000/ . You should see 2 new buttons
   * You should receive an error message declaring an unallowalbe method after clicking on the bugtton. To proceed, complete the next step:
1.  The HTTP POST method must be declared as an allowable request for the "destinatons/" and "customers/" routes (Note HTTP/GET is the default). Edit existing route parameters in **index.py** that the POST in **index.html** is linked with:

```
@app.route("/destinations", methods=["POST", "GET"])

@app.route("/customers", methods=["POST", "GET"])
```

Click the buttons on http://127.0.0.1:5000/ to confirm they produce the correct lists of data

Now try a text box to search the database. We will enter the Accomodation Type to return destinations that match that type (Expensive, Moderate, Cheap)

First add a text box form element that posts to the `/destinations` URL.

**index.html**:
Add this form element after the last `</form>` tag
```
<br>
<form method="GET" action="/destinations">
	<label for="search">Find Destinations by Accomodation</label>
	<input id="search" name="search" class="form-control" type="text" /><br />
</form>
```

Now there are two form methods handled by the `/destinations` flask method. Produce different logic depending on the method issued:

**index.py**:
Replace the beginning of the `dest()` method, everything before `names = []`, with the following logic. Note this may have to be update to integrate with the varialbe names you used in a previous Task that implemented this function():
```
if request.method == "GET":
    search = request.args.get('search')

    result = db.engine.execute("select * from DEST where Accomodations=%s",search)
else:
    result = db.engine.execute("select * from DEST")
```
Try it out by typing an Accomodation type into the text box @ http://127.0.0.1:5000/	

Now a text box is not very friendly for matching an enumerated list of types, like Accomodation Type. Let's create a dropdown to allow the user to select from the available options.

**index.html**:
Replace the GET form elements with the following which dynamically generates the dropdown options based on the `data` variable passed:
```
<form method="GET" action="/destinations">
	<label for="search">Find Destinations by Accomodation</label>
  	<select id="accomodations" name="accomodations">
  				
		    {% for ui_row in data %}
    		<option value="{{ui_row.Accomodations}}">{{ui_row.Accomodations}}</option>
	    	{% endfor %}
    	</select>
   	<input type="submit" value="Submit" />
</form>
```

Edit the flask route method for URL(/) to send the proper Accomodation type data to be displayed in the drop down button:
**index.py**:

```
@app.route("/")
def index():
   result = db.engine.execute("select DISTINCT(Accomodations) from DEST")
   accs = []

   for row in result:
       name = {}
       name["Accomodations"] = row[0]
       accs.append(name)

   return render_template("index.html", data=accs)
```

Right-click the web page and select "View Source" to view the web page returned back from the server to your client (browser). Verify the HTML has been updated dynamically to include all the Accomodation options:
```
<form method="GET" action="/destinations">
			<label for="search">Find Destinations by Accomodation</label>
  			<select id="accomodations" name="accomodations">
  				
    			<option value="Cheap">Cheap</option>
    			
    			<option value="Moderate">Moderate</option>
    			
    			<option value="Expensive">Expensive</option>
    			
    		</select>
    		<input type="submit" value="Submit" />
		</form>
```

### TASK: Capture dropdown value
1.  Edit the `/destinations` route method to capture the selected dropdown value to allow the proper Destinations to be displayed [Only requires editing one word]
1.  Verify proper destinations displayed after hitting submit button next to dropdown


## Workshop Continued... Web Styling

HTML elements can be changed by changing the style for how that element is displayed. Styling refers to properties like color, sizing, font etc...  CSS allows you to set a combination of properties into a style, identified by a name, called a class.

Bootstrap is a framework that, among other things, contains many pre-defined styles declared in CSS format. Instead of setting your own style by having to declare the many properties that define the look of an element, you can get a page up and running more quickly by utilizing existing styles.

Bootstrap Resources
   * CSS Styling: https://getbootstrap.com/docs/3.4/css/
   * Components (buttons, forms etc): https://getbootstrap.com/docs/3.4/components/
   * Tutorial: https://www.w3schools.com/bootstrap/default.asp
      * Focus especially on:  Grid Basic, Typography, Tables, Alerts, Buttons, Forms, and Inputs

### Integrate Bootstrap
First add some text before your existing buttons using the heading and paragraph HTML elements. Paste in some new lines after the `<body>` tag in **index.html**:

```
<h1>My INFO 257 Workshop</h1>
<p>Select from the options below:</p>
```

Load the index.html on your browser to review the look of how default html displays the page: http://127.0.0.1:5000/

Next, import the bootstrap templates by linking to a server hosting the bootstrap content. Add the following after the `<meta>` element in index.html:
```
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">

<!-- jQuery library: Supports Javascript Plugins -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>

<!-- Latest compiled JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
```

Now refresh index.html and see how Bootstrap affects the look of the HTML elements

Bootstrap has changed the default header element styling (h1 in this case).

Let's override the Bootstrap styling with our own. Paste the following after the `</head>` tag to define our own CSS rules for the body and h1 elements:

```
<!-- Create our own custom CSS -->
<style>
@import url(http://fonts.googleapis.com/css?family=Amatic+SC:700);
body{
    text-align: center;
    background-color: lightblue;
}
h1{
    font-family: 'Amatic SC', cursive;
    font-weight: normal;
    color: #8ac640;
    font-size: 2.5em;
}
</style>
```

Refresh http://127.0.0.1:5000/

The standard HTML body and h1 elements will now have the style defined by the corresponding CSS rules (inside the brackets {}).

#### TASK: Style index.html
1.  Utilize Bootstrap Grids to create 1 row of 3 columns that span the entire viewport. There are 3 forms currently on our page. Place one form in each column.
      * https://www.w3schools.com/bootstrap/bootstrap_grid_basic.asp

1.  Create your own paragraph (`<p>`) styling with any style properties of your liking. After h1 {...} create a new CSS entry for `p {}` and declare at least 3 different property styles.
      * https://www.w3schools.com/html/html_css.asp


### Boostrap Classes
Now, let's utilize the class attribute to quickly style the rest of the document. 

The bootstrap framework includes pre-defined styles that are referred to by a class name. HTML elements just need to set their "class" attribute to the class names defined by Bootstrap and the associated styling will be applied to that element.

Review button customization documentation: https://getbootstrap.com/docs/3.4/css/#buttons

Add `class="btn btn-default"` to the submit button elements

Refresh the page.

Change one of the button's class to the following: `btn-primary btn-lg`

Refresh.

#### TASK: Boostrap-ify the rest of the page
1.  Place the entire page within a Bootstrap container class (use `<div>`): https://www.w3schools.com/bootstrap/bootstrap_get_started.asp

1.  Change the styling of the existing drop down button to utilize Bootstrap form styling: https://www.w3schools.com/bootstrap/bootstrap_forms.asp

### External CSS

Move your custom styling to a stylesheet (CSS) file to separate our HTML layout from its style

1.  Create a new sub-directory `/static`. Flask knows to look for static files like CSS here.
1.  Create a new file mystyle.css inside the `/static` subfolder
1.  **CUT**+Paste everything between the <style> tags into mystyle.css. Be sure to CUT so there is no text between the `<style></style>` tags.
1.  Reference the mystyle.css file in **index.html** by utilizing the Flask/Jinja template engine to generate the file location for the HTML link tag:
      * Insert the following before `</head>`: `<link rel= "stylesheet" type= "text/css" href= "{{ url_for('static',filename='mystyle.css') }}">`

Refresh the page and nothing should have changed - your custom styling should still appear, now referenced from your own CSS file.
