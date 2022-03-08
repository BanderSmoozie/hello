output "url" {
  value = "http://${aws_instance.web.public_ip}:8080"
}

output "public_ip" {
  value = "${aws_instance.web.public_ip}"
}
