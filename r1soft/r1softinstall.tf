resource "aws_instance" "r1soft" {
  ami           = data.aws_ami.centos.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.bastion_host3.key_name
  # associate_public_ip_address = true
  availability_zone = "us-east-1a"

  vpc_security_group_ids = [aws_security_group.r1softsecurity.id]

  #copy r1softrepohost file to install repo
  provisioner "file" {
    source      = "./r1soft.repo"
    destination = "/tmp/r1soft.repo"
  }
  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.r1soft.public_ip
  }

  # run the following commands
  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/r1soft.repo /etc/yum.repos.d/",
      "sudo  yum install r1soft-cdp-enterprise-server -y",
      "sudo r1soft-setup --user emir --pass dev@psteam --http-port 80 --http-port 443",
      "sudo systemctl restart sbm-server",
    ]
  }

  tags = {
    Name = "r1soft"
  }
}
