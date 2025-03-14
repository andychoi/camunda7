
camunda/
│── server/
│   ├── camunda-bpm-platform-7.x.x/
│   │   ├── server/
│   │   │   ├── webapps/
│   │   │   │   ├── app/
│   │   │   │   │   ├── forms/
│   │   │   │   │   │   ├── simple-form.html  <-- Place the form here
│   │   │   │   ├── cockpit/
│   │   │   │   ├── tasklist/
│   │   │   │   ├── admin/
│   │   │   │   ├── welcome/

⸻

Deployment Steps via REST API
	1.	Deploy the BPMN file

curl -X POST http://localhost:8080/engine-rest/deployment/create \
     -H "Content-Type: multipart/form-data" \
     -F "deployment-name=simpleProcess" \
     -F "simple-process.bpmn=@path/to/your/simple-process.bpmn"


	2.	Start the Process

curl -X POST http://localhost:8080/engine-rest/process-definition/key/simpleProcess/start


	3.	Retrieve the Active User Task

curl -X GET http://localhost:8080/engine-rest/task


	4.	Submit the Form Data

curl -X POST http://localhost:8080/engine-rest/task/{TASK_ID}/complete \
     -H "Content-Type: application/json" \
     -d '{"variables": {"userInput": {"value": "User Data", "type": "String"}}}'



Replace {TASK_ID} with the retrieved task ID.

⸻

Instead of manually uploading simple-form.html to the Camunda server’s webapps/app/forms/ folder, you can deploy the form dynamically from your client PC using the Camunda REST API.

⸻

1. Use External Form Deployment Approach

Instead of embedding the form inside the Camunda web UI, you can deploy the form as part of the BPMN model package and serve it dynamically.

Steps:
	•	Package the form (simple-form.html) within the deployment.
	•	Reference it as an external form via a URL.
	•	Deploy both the BPMN and form in a single API request.

⸻

2. Modify BPMN to Use an External Form

Instead of using:

<userTask id="UserTask_1" name="Enter Data" camunda:formKey="embedded:app:forms/simple-form.html">

Change it to:

<userTask id="UserTask_1" name="Enter Data" camunda:formKey="external:http://your-host/forms/simple-form.html">

	•	This tells Camunda to load the form from an external web server or API.
	•	Replace http://your-host/forms/simple-form.html with your actual hosting URL (it can be an API that serves the form).

⸻

3. Deploy BPMN and Form Using REST API from Client PC

Instead of manually placing the form on the Camunda server, you can deploy both the BPMN and form as part of a process definition.

Use curl to Deploy Both BPMN and Form:

curl -X POST http://localhost:8080/engine-rest/deployment/create \
    -H "Content-Type: multipart/form-data" \
    -F "deployment-name=simpleProcess" \
    -F "simple-process.bpmn=@/path/to/simple-process.bpmn" \
    -F "simple-form.html=@/path/to/simple-form.html"

	•	This sends both files (BPMN and HTML form) to Camunda from your local machine.
	•	Camunda will store the form internally, and you can reference it as deployment://simple-form.html instead.

⸻

4. Use the Form from Deployment Instead of External URL

Once deployed, reference it as:

<userTask id="UserTask_1" name="Enter Data" camunda:formKey="deployment:simple-form.html">

This means Camunda will load the form directly from the deployment package, avoiding manual file placement on the server.

⸻

5. Start and Complete the Process via REST API

Start the Process

curl -X POST http://localhost:8080/engine-rest/process-definition/key/simpleProcess/start

Retrieve Active User Task

curl -X GET http://localhost:8080/engine-rest/task

Find taskId from the response.

Complete the Task Using REST API

curl -X POST http://localhost:8080/engine-rest/task/{TASK_ID}/complete \
    -H "Content-Type: application/json" \
    -d '{
          "variables": {
            "userInput": {"value": "Test Data", "type": "String"}
          }
        }'



⸻

6. Alternative: Use an External File Server (Optional)
	•	If you don’t want to store the form in Camunda, host it on a separate file server.
	•	Reference it as:

<userTask id="UserTask_1" name="Enter Data" camunda:formKey="external:https://yourserver.com/forms/simple-form.html">


	•	This works well if your organization has an existing web server or API to serve forms dynamically.

⸻

Conclusion

✅ You don’t need to manually copy files to the Camunda server.
✅ Use deployment:simple-form.html to reference the form dynamically from a REST API call.
✅ Alternatively, use external:http://your-host/forms/simple-form.html to load forms from an external server.


Deploying an External Form-Based Process in Camunda 7 (Spring Boot with Docker)

You are running Camunda 7 with Spring Boot inside Docker and need to deploy a process with an external form that can be accessed dynamically. Here’s a step-by-step guide.

⸻

1. Define the BPMN Process with External Form Reference

Modify your BPMN file (simple-process.bpmn) to reference an external form served by Spring Boot.

<bpmn:process id="simpleProcess" name="Simple Process" isExecutable="true">
  <bpmn:startEvent id="StartEvent_1" name="Start">
    <bpmn:outgoing>Flow_1</bpmn:outgoing>
  </bpmn:startEvent>

  <bpmn:userTask id="UserTask_1" name="Enter Data" camunda:formKey="external:http://localhost:8080/forms/simple-form.html">
    <bpmn:incoming>Flow_1</bpmn:incoming>
    <bpmn:outgoing>Flow_2</bpmn:outgoing>
  </bpmn:userTask>

  <bpmn:sequenceFlow id="Flow_1" sourceRef="StartEvent_1" targetRef="UserTask_1"/>
  <bpmn:sequenceFlow id="Flow_2" sourceRef="UserTask_1" targetRef="EndEvent_1"/>

  <bpmn:endEvent id="EndEvent_1" name="End">
    <bpmn:incoming>Flow_2</bpmn:incoming>
  </bpmn:endEvent>
</bpmn:process>

💡 The external:http://localhost:8080/forms/simple-form.html tells Camunda to fetch the form from the running Spring Boot service.

⸻

2. Serve the Form in Spring Boot

You need to create a simple REST controller to serve the form dynamically.

Create FormController.java

package com.example.workflow.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.file.Files;

@RestController
public class FormController {

    @GetMapping(value = "/forms/simple-form.html", produces = MediaType.TEXT_HTML_VALUE)
    public String getSimpleForm() throws IOException {
        ClassPathResource resource = new ClassPathResource("static/forms/simple-form.html");
        return new String(Files.readAllBytes(resource.getFile().toPath()));
    }
}

This will allow Camunda to access simple-form.html via http://localhost:8080/forms/simple-form.html.

⸻

3. Store simple-form.html Inside Spring Boot Static Resources

Create the folder structure inside src/main/resources/static/forms/ and place simple-form.html inside:

📂 src/main/resources/static/forms/simple-form.html

<form class="form-horizontal">
  <div class="form-group">
    <label for="userInput">Enter your data:</label>
    <input type="text" id="userInput" class="form-control" name="userInput" required />
  </div>
  <button type="submit" class="btn btn-primary">Submit</button>
</form>

<script>
  function submitForm(event) {
    event.preventDefault();
    const formData = { userInput: document.getElementById("userInput").value };
    camForm.submit(formData);
  }

  document.querySelector("form").addEventListener("submit", submitForm);
</script>

This ensures your external form is served when Camunda requests it.

⸻

4. Deploy the BPMN Process Using REST API

Since we are not manually placing files on the server, use the REST API to deploy your BPMN process.

curl -X POST http://localhost:8080/engine-rest/deployment/create \
    -H "Content-Type: multipart/form-data" \
    -F "deployment-name=simpleProcess" \
    -F "simple-process.bpmn=@/path/to/simple-process.bpmn"



⸻

5. Start the Process Using REST API

curl -X POST http://localhost:8080/engine-rest/process-definition/key/simpleProcess/start



⸻

6. Retrieve the Active User Task

curl -X GET http://localhost:8080/engine-rest/task

Find taskId from the response.

⸻

7. Complete the Task via REST API

curl -X POST http://localhost:8080/engine-rest/task/{TASK_ID}/complete \
    -H "Content-Type: application/json" \
    -d '{
          "variables": {
            "userInput": {"value": "Test Data", "type": "String"}
          }
        }'



⸻

8. Running in Docker

Since you’re using Docker, ensure your Spring Boot app inside the container can expose http://camunda-app:8080/forms/simple-form.html.

Update the BPMN Form Key

<bpmn:userTask id="UserTask_1" name="Enter Data" camunda:formKey="external:http://camunda-app:8080/forms/simple-form.html">

Camunda inside the container will reach the form at http://camunda-app:8080/forms/simple-form.html (not localhost).

⸻

Rebuild & Restart Docker

docker-compose down
docker-compose up --build -d



⸻

Verify in Camunda Tasklist
	1.	Open Camunda Tasklist: http://localhost:8080/camunda/app/tasklist/
	2.	Select the task → The form should load from http://localhost:8080/forms/simple-form.html.
	3.	Submit the form → The process should complete.

⸻

Conclusion

✅ No manual file placement on Camunda server.
✅ Forms are served dynamically from Spring Boot.
✅ Camunda accesses forms via HTTP.

Let me know if you need further improvements! 🚀