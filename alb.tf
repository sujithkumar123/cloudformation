 # Security Group for ALB
resource "aws_security_group" "atlassian_alb" {
    name = "sujithloadbalancer"
    description = "allow HTTPS to  Load Balancer (ALB)"
    vpc_id = "${aws_vpc.default.id}"
    ingress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
     egress {
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }


    tags {
        Name = "sujithsg"
    }
}
# Create a single load balancer for all Atlassian services
resource "aws_alb" "atlassian" {
  name            = "sujithalb"
  internal        = false
  idle_timeout    = "300"
  security_groups = ["${aws_security_group.atlassian_alb.id}"]
  subnets = [
    "${aws_subnet.us-west-2a-public1.id}",
    "${aws_subnet.us-west-2a-public2.id}"

]
  enable_deletion_protection = true

# access_logs {
#   bucket = "${aws_s3_bucket.alb_logs.bucket}"
#   prefix = "test-alb"
# }

  tags {
    Name = "sujith"
  }
}

# Define a listener
resource "aws_alb_listener" "atlassian" {
  load_balancer_arn = "${aws_alb.atlassian.arn}"
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    target_group_arn = "${aws_alb_target_group.bitbucket1.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "bitbucket1" {
  listener_arn = "${aws_alb_listener.atlassian.arn}"
  priority     = 99

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.bitbucket1.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["in/image"]
  }
}
resource "aws_alb_listener_rule" "bitbucket2" {
  listener_arn = "${aws_alb_listener.atlassian.arn}"

  priority     = 100

  action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.bitbucket1.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["im/index.html"]
  }
}



# Connect bitbucket ASG up to the Application Load Balancer (see load-balancer.tf)
resource "aws_alb_target_group" "bitbucket1" {
  name     = "sujith-bitbucket1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 10
    timeout = 5
    interval = 10
    path = "/in/image"
  }
}
  resource "aws_alb_target_group" "bitbucket2" {
  name     = "sujith-bitbucket2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/im/index.html"    
      
  }
}

  
resource "aws_launch_configuration" "als" {
  name = "als"
  image_id = "ami-08692d171e3cf02d6"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  security_groups = ["${aws_security_group.nat.id}"]
  user_data = <<-EOF
             #!/bin/bash
             sudo apt-get update
             sudo apt-get install apache2 -y
             sudo service start apache2
             sudo usermod -a -G ubuntu root
             sudo chown -R root:ubuntu /var/www
             sudo chmod 2755 /var/www
             sudo mkdir -p /var/www/html/in
             sudo mkdir -p /var/www/html/im
             sudo rm /var/www/html/index.html
             sudo echo "hello everytwo">>/var/www/html/im/index.html
             sudo echo "hello everyone">> /var/www/html/in/image
             EOF
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "agh" {
   
  launch_configuration = "${aws_launch_configuration.als.id}"
  max_size                  = 1
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier = [
    "${aws_subnet.us-west-2a-public1.id}",
    "${aws_subnet.us-west-2a-public2.id}",
    "${aws_subnet.us-west-2a-private1.id}",
    "${aws_subnet.us-west-2a-private2.id}"
  ] 
 
  target_group_arns  = [ 
    "${aws_alb_target_group.bitbucket1.arn}",  
    "${aws_alb_target_group.bitbucket2.arn}"
]
 
 
  tags {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    }
  
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_policy" "bat1" {
  name                   = "foobar3terraformtest1"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.agh.name}"
}
resource "aws_autoscaling_policy" "bat2" {
  name                   = "foobar3terraformtest2"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = "${aws_autoscaling_group.agh.name}"
}

resource "aws_cloudwatch_metric_alarm" "foobar1" {
  alarm_name          = "terraformtestfoobar5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = "120"
  evaluation_periods  = "5"
  threshold           = "40"
  alarm_actions     = ["${aws_autoscaling_policy.bat1.arn}"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.agh.name}"
  }
  comparison_operator = "GreaterThanThreshold"
}
resource "aws_cloudwatch_metric_alarm" "foobar2" {
  alarm_name          = "terraformtestfoobar51"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = "120"
  evaluation_periods  = "30"
  threshold           = "20"
  alarm_actions     = ["${aws_autoscaling_policy.bat2.arn}"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.agh.name}"
  } 
 comparison_operator = "LessThanThreshold"
}
