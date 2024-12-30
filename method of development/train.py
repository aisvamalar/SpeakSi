import uuid

# Generate a UUID based on the host ID and current time
time_based_uuid = uuid.uuid1()
print(time_based_uuid)
