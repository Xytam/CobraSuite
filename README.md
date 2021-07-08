# CobraSuite

Instructions for EC2Instance.info rewrite (Note, I run this on anb AWS ec2 instance with their prebuild aws ami):
1. Install AWS CLI, python3, and pip
2. Run AWS Configure and set up an access key with view and read permissions in AWS
3. cd into the ec2instances directory
4. Run the following
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt (I believe I had to make some edits to this but it may not work on all machines/builds)
invoke build
invoke serve
open http://localhost:8080
deactivate



TODO: Convert this to a nice webpage?
TODO: Set connector download into a for loop

Additional Projects WIP:
JMX Exporter 6.0 Update
Load Balanced Kafka Demo (only expose 1 endpoint)
Self-Balancing Kafka Scaling Up and Down
Non-Functional Requirements Testing Suite / Ducktape modification
Clusterbreak?
