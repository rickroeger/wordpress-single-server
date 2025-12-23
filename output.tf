output "wordpress-url" {
  value      = format("http://%s/WordPress", module.ec2_wordpress.public_dns)
  depends_on = [module.ec2_wordpress]
}
