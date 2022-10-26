
output "zones" {
  value = data.aws_availability_zones.available.names
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "igw-arn" {
  value = aws_internet_gateway.igw.arn
}

output "countofaz" {
  value = length(data.aws_availability_zones.available.names)
}