resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
       name = "terraform-aws-vpc"
     }
  }

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
   }
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description= "allow trafic to pass from the private subnet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private1_subnet_cidr}"]
  }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private1_subnet_cidr}"]
}
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"
    tags {
        Name = "NATSG"
    }
}
resource "aws_instance" "nat" {
    ami = "ami-0b707a72" # this is a special ami preconfigured to do NAT
    availability_zone = "us-west-2a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.us-west-2a-public1.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "VPC NAT"
    }
}

resource "aws_subnet" "us-west-2a-public1" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public1_subnet_cidr}"
    availability_zone = "us-west-2a"

    tags {
        Name = "Public Subnet1"
    }
}
resource "aws_subnet" "us-west-2a-public2" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public2_subnet_cidr}"
    availability_zone = "us-west-2b"

    tags {
        Name = "Public Subnet2"
    }
}


resource "aws_route_table" "us-west-2a-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}
resource "aws_route_table_association" "us-west-2a-public1" {
    subnet_id = "${aws_subnet.us-west-2a-public1.id}"
    route_table_id = "${aws_route_table.us-west-2a-public.id}"
}
resource "aws_route_table_association" "us-west-2a-public2" {
    subnet_id = "${aws_subnet.us-west-2a-public2.id}"
    route_table_id = "${aws_route_table.us-west-2a-public.id}"
}


resource "aws_subnet" "us-west-2a-private1" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private1_subnet_cidr}"
    availability_zone = "us-west-2a"

    tags {
        Name = "Private Subnet1"
    }
}
resource "aws_subnet" "us-west-2a-private2" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private2_subnet_cidr}"
    availability_zone = "us-west-2b"

    tags {
        Name = "Private Subnet2"
    }
}

resource "aws_route_table" "us-west-2a-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "Private Subnet"
    }
}
resource "aws_route_table_association" "us-west-2a-private1" {
    subnet_id = "${aws_subnet.us-west-2a-private2.id}"
    route_table_id = "${aws_route_table.us-west-2a-private.id}"
}
resource "aws_route_table_association" "us-west-2a-private2" {
    subnet_id = "${aws_subnet.us-west-2a-private1.id}"
    route_table_id = "${aws_route_table.us-west-2a-private.id}"
}



