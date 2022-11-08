https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ecs/update-service.html

When the service scheduler launches new tasks, it determines task placement in your cluster with the following logic.

Determine which of the container instances in your cluster can support your service’s task definition. For example, they have the required CPU, memory, ports, and container instance attributes.

By default, the service scheduler attempts to balance tasks across Availability Zones in this manner even though you can choose a different placement strategy.

Sort the valid container instances by the fewest number of running tasks for this service in the same Availability Zone as the instance. For example, if zone A has one running service task and zones B and C each have zero, valid container instances in either zone B or C are considered optimal for placement.

Place the new service task on a valid container instance in an optimal Availability Zone (based on the previous steps), favoring container instances with the fewest number of running tasks for this service.

When the service scheduler stops running tasks, it attempts to maintain balance across the Availability Zones in your cluster using the following logic:

Sort the container instances by the largest number of running tasks for this service in the same Availability Zone as the instance. For example, if zone A has one running service task and zones B and C each have two, container instances in either zone B or C are considered optimal for termination.

Stop the task on a container instance in an optimal Availability Zone (based on the previous steps), favoring container instances with the largest number of running tasks for this service.
