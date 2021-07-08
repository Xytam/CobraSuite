import botocore
import botocore.exceptions
import boto3
import locale
import json
from pkg_resources import resource_filename
import re
import scrape
import traceback

#ask AZs, throughput, replication, rhel or just linux, ondemand/[reserved(1,3yr)],
def getInstanceNeeds(data_file):
    AZ = str(input("Enter desired AZ (us-east-1 default): ") or 'us-east-1')
    desiredMBpsIngress = int(input("Enter desired input in MegaBYTES per second(5 default)") or 5)
    desiredMBpsEgress = int(input("Enter desired output in MegaBYTES per second(defaults to previous answer eg 1:1 input/output)") or desiredMBpsIngress)
    replicationFactor = int(input("Enter desired replication factor average (default 3)") or 3)
    instanceCount = int(input("Enter amount of brokers, this assumes you have enough partitions to evenly distribute load (default 5)") or 5)
    desiredRefeed = int(input("How much data are you re-feeding in MegaBYTES per second? (0 default)") or 0)

    with open(data_file, 'r') as f:
        instanceData = json.load(f)
        filtered = []
    for i in range(0,len(instanceData)):
        #doing calculation of mbps here but may move it
        if(instanceData[i]['vCPU'] > 4 and instanceData[i]['memory'] > 32 and instanceData[i]['ebs_baseline_bandwidth'] > 0 and bool(instanceData[i]['pricing']) and
        ((((desiredRefeed + desiredMBpsIngress)*replicationFactor) + (desiredMBpsEgress)) / instanceCount) < (float(instanceData[i]['ebs_baseline_throughput_mbps']))):
            #doesn't currently take memory to memory operations in account but should
            #should also take into account % fullness of bandwidth and maybe throw error if disk can't keep up because memory to memory ops are fine
            instanceData[i].update({'mbPerDollar': (instanceData[i]['ebs_baseline_bandwidth']*60*60)/float(instanceData[i]['pricing'][AZ]['linux']['ondemand'])})

            #This should dynamically calculate on frontend from js eventually
            instanceData[i].update({'bandwidthUtilization': ( ((desiredMBpsIngress*replicationFactor/instanceCount) + (desiredMBpsEgress/instanceCount)) / float(instanceData[i]['ebs_baseline_throughput_mbps'])) })
            #should calculate total annual cost to run and give option to sort annual operating cost vs "best value"
            instanceData[i].update({'totalCostToRun': float(instanceData[i]['pricing'][AZ]['linux']['ondemand'])*24*7*365})
            filtered.append(instanceData[i])

    sorted_data = sorted(filtered,key=lambda k: k['totalCostToRun'],reverse=False)
    for i in range(0,len(sorted_data)):
        print("Name: ",sorted_data[i]['instance_type']," / mbPerDollar: ",sorted_data[i]['mbPerDollar']," / Total Anual Cost: ",sorted_data[i]['totalCostToRun'], " / EBS Bandwidth Utilization %: " , round(sorted_data[i]['bandwidthUtilization']*100,2) )
    print("Viable Instance Count: ",len(sorted_data))


if __name__ == '__main__':
    scrape('www/instances.json')
