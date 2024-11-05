output "attrs" {
  value = {
    id        = aws_eip.this.id
    public_ip = aws_eip.this.public_ip
  }
}