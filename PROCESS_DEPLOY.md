To deploy new BPMN processes, you need to ensure that:
	1.	Process Definitions (BPMN files) are available for deployment.
	2.	They persist across container restarts (so they don’t get lost when the container stops).
	3.	Camunda automatically deploys them when the engine starts.

⸻

🎯 Why Add Volumes to Store Processes?

✅ Ensures that deployed processes persist even after the container is restarted.
✅ Allows mounting a local folder where you can drop .bpmn files for deployment.
✅ Facilitates updates without rebuilding the Docker image.

⸻

🚀 How to Store and Auto-Deploy BPMN Processes?

✅ 1️⃣ Add a Volume to Store BPMN Processes

Modify the docker-compose.yml to persist process files in a shared volume.

📌 Updated docker-compose.yml

version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: camunda_postgres
    restart: always
    environment:
      POSTGRES_DB: camunda
      POSTGRES_USER: camunda
      POSTGRES_PASSWORD: camunda_password
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  camunda:
    image: camunda-community
    container_name: camunda
    restart: always
    depends_on:
      - postgres
    environment:
      - DB_DRIVER=org.postgresql.Driver
      - DB_URL=jdbc:postgresql://postgres:5432/camunda
      - DB_USERNAME=camunda
      - DB_PASSWORD=camunda_password
      - WAIT_FOR=postgres:5432
    volumes:
      - camunda_processes:/camunda/configuration/resources  # Mount folder for BPMN files
    ports:
      - "8080:8080"
      - "8000:8000"
      - "9404:9404"

volumes:
  pg_data:
  camunda_processes:  # Volume for BPMN deployment



⸻

✅ 2️⃣ Mount a Local Folder for BPMN Deployment

Instead of using a Docker volume, you can mount a local folder so you can drag-and-drop BPMN files for deployment.

📌 Mount a Local Folder in docker-compose.override.yml (Optional)

If you prefer using a local folder, create docker-compose.override.yml:

version: "3.8"
services:
  camunda:
    volumes:
      - ./processes:/camunda/configuration/resources  # Mount local folder for BPMN files

Then, create a processes/ directory in your project:

mkdir -p processes

Now, any BPMN files inside processes/ will be automatically deployed when Camunda starts.

⸻

✅ 3️⃣ Deploy a BPMN Process

Option 1: Copy a Process Manually

cp my-process.bpmn processes/
docker-compose restart camunda

🔹 The BPMN file will be deployed automatically when Camunda starts.

Option 2: Upload via Camunda REST API

Use the Camunda Deployment API to deploy a new process:

curl -X POST http://localhost:8080/engine-rest/deployment/create \
  -H "Content-Type: multipart/form-data" \
  -F "deployment-name=my-deployment" \
  -F "enable-duplicate-filtering=true" \
  -F "deploy-changed-only=true" \
  -F "process.bpmn=@my-process.bpmn"

🔹 This immediately deploys the BPMN file without restarting Camunda.

⸻

🎯 Summary

✅ Added a volume (camunda_processes) to persist BPMN files
✅ Mounted a local folder (./processes) for easy BPMN file management
✅ Supported auto-deployment on container start
✅ Provided an alternative REST API method for deploying processes

⸻

🎯 Final Steps

🚀 Start Camunda with Auto-Deploy

docker-compose up -d

🚀 Deploy a New Process

1️⃣ Drop BPMN files into processes/ and restart:

cp my-process.bpmn processes/
docker-compose restart camunda

or
2️⃣ Use the REST API to deploy dynamically:

curl -X POST http://localhost:8080/engine-rest/deployment/create \
  -H "Content-Type: multipart/form-data" \
  -F "deployment-name=my-deployment" \
  -F "deploy-changed-only=true" \
  -F "process.bpmn=@my-process.bpmn"

Now, your Camunda setup is fully ready for process deployment! 🚀🔄

## PROCESS ASSETS
📌 How to Embed Forms, HTML, CSS, and Images for Camunda BPM Processes?

Camunda BPM allows embedding task forms, custom HTML pages, CSS, JavaScript, and images related to BPMN processes. To store and deploy them properly, follow these best practices:

⸻

🎯 Best Approach: Store Forms & Assets in the Deployment Volume

✅ Keep forms and assets inside the same volume as BPMN processes
✅ Ensure Camunda can load HTML, CSS, and images for user tasks
✅ Auto-deploy assets along with BPMN files on container restart

⸻

🚀 Updated docker-compose.yml with Embedded Forms & Assets

Modify docker-compose.yml to store and deploy forms, HTML, CSS, and images inside Camunda.

version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: camunda_postgres
    restart: always
    environment:
      POSTGRES_DB: camunda
      POSTGRES_USER: camunda
      POSTGRES_PASSWORD: camunda_password
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  camunda:
    image: camunda-community
    container_name: camunda
    restart: always
    depends_on:
      - postgres
    environment:
      - DB_DRIVER=org.postgresql.Driver
      - DB_URL=jdbc:postgresql://postgres:5432/camunda
      - DB_USERNAME=camunda
      - DB_PASSWORD=camunda_password
      - WAIT_FOR=postgres:5432
    volumes:
      - camunda_processes:/camunda/configuration/resources  # BPMN processes
      - camunda_assets:/camunda/webapps/forms  # HTML forms, CSS, JS, Images
    ports:
      - "8080:8080"
      - "8000:8000"
      - "9404:9404"

volumes:
  pg_data:
  camunda_processes:  # Stores BPMN files
  camunda_assets:  # Stores forms, HTML, CSS, and images



⸻

🎯 Organizing Forms & Assets for Deployment

Inside camunda_assets, store:
	•	Embedded Task Forms (.html)
	•	Custom Stylesheets (.css)
	•	JavaScript Files (.js)
	•	Images (.png, .jpg, .svg)

📁 Folder Structure

processes/
│── my-process.bpmn  # BPMN process file
assets/
│── forms/
│   ├── task-form.html  # HTML Form
│   ├── custom-style.css  # CSS
│   ├── script.js  # JavaScript
│── images/
│   ├── logo.png  # Images
│   ├── background.jpg



⸻

🚀 How to Deploy Embedded Forms, HTML, CSS, and Images?

✅ Option 1: Mount a Local Folder for Assets

Modify docker-compose.override.yml to use a local directory instead of a volume.

version: "3.8"
services:
  camunda:
    volumes:
      - ./processes:/camunda/configuration/resources  # BPMN Processes
      - ./assets:/camunda/webapps/forms  # Embedded Forms, HTML, CSS

Now, store your assets in a local assets/ folder, and they will be automatically available in Camunda.

⸻

✅ Option 2: Deploy via REST API

You can also deploy forms and assets dynamically using the Camunda Deployment API.

curl -X POST http://localhost:8080/engine-rest/deployment/create \
  -H "Content-Type: multipart/form-data" \
  -F "deployment-name=my-deployment" \
  -F "deploy-changed-only=true" \
  -F "process.bpmn=@processes/my-process.bpmn" \
  -F "task-form.html=@assets/forms/task-form.html" \
  -F "custom-style.css=@assets/forms/custom-style.css" \
  -F "script.js=@assets/forms/script.js" \
  -F "logo.png=@assets/images/logo.png"

🔹 This uploads BPMN, HTML, CSS, JavaScript, and images dynamically without restarting Camunda.

⸻

🎯 How to Use Embedded Task Forms in Camunda?

Inside your BPMN process, you need to reference embedded task forms for user tasks.

📌 Example: BPMN User Task with Embedded Form

<bpmn:userTask id="UserTask_1" name="Review Request">
    <bpmn:extensionElements>
        <camunda:formKey>embedded:app:forms/task-form.html</camunda:formKey>
    </bpmn:extensionElements>
</bpmn:userTask>

🔹 This tells Camunda to load task-form.html from /camunda/webapps/forms/.

⸻

🎯 Summary

✅ Added a volume (camunda_assets) for forms, HTML, CSS, and images
✅ Mounted a local assets/ folder for easy development
✅ Supported auto-deployment of BPMN + assets
✅ Enabled API-based dynamic deployment
✅ Configured Camunda to load embedded forms for user tasks

⸻

🚀 Final Steps

Start Camunda & PostgreSQL

docker-compose up -d

Deploy New BPMN Processes & Assets

1️⃣ Drag & Drop .bpmn, .html, .css, .js, and images into assets/
2️⃣ Restart Camunda for auto-deployment

docker-compose restart camunda

or
3️⃣ Deploy using REST API

curl -X POST http://localhost:8080/engine-rest/deployment/create \
  -F "process.bpmn=@processes/my-process.bpmn" \
  -F "task-form.html=@assets/forms/task-form.html"

🚀 Now Camunda can load BPMN workflows with embedded forms, styles, and images! 🚀