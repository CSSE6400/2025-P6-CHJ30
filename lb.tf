resource "aws_lb_target_group" "taskoverflow" {
name = "taskoverflow"
port = 6400
protocol = "HTTP"
vpc_id = aws_security_group.taskoverflow.vpc_id
target_type = "ip"
health_check {
path = "/api/v1/health"
port = "6400"
protocol = "HTTP"
healthy_threshold = 2
unhealthy_threshold = 2
timeout = 5
interval = 10
}
}
resource "aws_appautoscaling_target" "taskoverflow" {
max_capacity = 4
min_capacity = 1
resource_id = "service/taskoverflow/taskoverflow"
scalable_dimension = "ecs:service:DesiredCount"
service_namespace = "ecs"
depends_on = [ aws_ecs_service.taskoverflow ]
}
resource "aws_appautoscaling_policy" "taskoverflow-cpu" {
name = "taskoverflow-cpu"
policy_type = "TargetTrackingScaling"
resource_id = aws_appautoscaling_target.taskoverflow.resource_id
scalable_dimension = aws_appautoscaling_target.taskoverflow.scalable_dimension
service_namespace = aws_appautoscaling_target.taskoverflow.service_namespace
target_tracking_scaling_policy_configuration {
predefined_metric_specification {
predefined_metric_type = "ECSServiceAverageCPUUtilization"
}
target_value = 20
}
}
import http from 'k6/http';
import { sleep, check } from 'k6';
export const options = {
stages: [
{ target: 1000, duration: '1m' },
{ target: 5000, duration: '10m' },
],
};
export default function () {
const res = http.get('http:// your-loadBalancer-url-here /api/v1/todos');
check(res, { 'status was 200': (r) => r.status == 200 });
sleep(1);
}
